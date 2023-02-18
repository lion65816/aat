        ; Portable Orb of Teleportation, or P.O.O.T.
        ; A carryable orb that activates upon being touched. Pressing L or R will teleport the player
        ; to the orb, and holding a direction during the teleport will cause the player to be launched
        ; in that direction after the teleport is finished. The P.O.O.T. is a single use sprite which
        ; destroys itself after being used once.

        ; based on carryable pipe, by WhiteYoshiEgg
        ; modified by algae5 originally for his KLDC level
        ; FreeRAM Used: $1FFF and $1870


        ; Stuff you can change

        !TeleportingSpeed = $40                 ; Speed the camera/teleport moves
        !FreezeTimeWhenTeleporting = 1          ; 0 = no, 1 = yes
        !CurrentTeleportTarget = $1870|!Base2   ; freeRAM value with the index of the last touched sprite of this type

        !DashSpeed = #$50                       ; Rightward Speed post-teleport
        !DashSpeedNegative = #$AF               ; Leftward Speed post-teleport
        !UpSpeed = #$9F                         ; Upward Speed post-teleport
        !DownSpeed = #$40                       ; Downward Speed post-teleport

        !CanStandOnIt = 0                       ; 1 = Mario can stand on the sprite
        !SolidSides = 0                         ; 1 = the sprite is solid from the sides
        
        ; Change these GFX tiles if you wish to rearrange what part of your GFX file is used.
        ; Assign the same value to Tile and SwappedTile if you want to condense the GFX space necessary.

        !Tile = $6C                             ; Initial tile
        !SwappedTile = $4E                      ; Palette swapped version of the tile to indicate being ready to teleport
        !TeleportingTile = $6E                  ; Explosion tile used when teleporting is activated


        ;  The below defines are used if !FreezeTimeWhenTeleporting is 1.
        ;  Due to an issue in timing, sprites may not properly freeze while using a pipe.
        ;  Setting !FixFreeze to 1 will fix this issue, in exchange for using one byte of free RAM.
        
        !FixFreeze  =   1               ; 0 = no, 1 = yes
        !FreezeRAM  =   $1FFF|!Base2    ; 1 byte of free RAM.


        ; stuff you shouldn't need to change

        !State = !1504,x
        !ControllerBackup = !151C,x
        !Timer = !1528,x
        !TeleportReady = !1534,x




if !FreezeTimeWhenTeleporting && !FixFreeze
    pushpc
    org $00A2E2 : JSL RestoreFreeze
    pullpc
        
    RestoreFreeze:
        LDA !FreezeRAM
        BEQ +
        STA $9D
        LDA #$00
        STA !FreezeRAM
      + JML $01808C|!BankB
else
    pushpc
    org $00A2E2 : JSL $01808C|!BankB
    pullpc
endif


print "INIT ",pc

        LDA #$09
        STA !14C8,x
        STZ !TeleportReady      ; Make sure that it starts as not teleport ready
        RTL




print "MAIN ",pc

        PHB : PHK : PLB : JSR SpriteCode : PLB : RTL : SpriteCode:
        
        LDA !Timer
        BEQ +
        DEC !Timer
      +
        LDA $71      ;\ Just draw graphics if Mario is dying.
        CMP #$09     ;|
        BEQ .return  ;/

        LDA $9D
        BNE .noCarry
        JSR HandleCarryableSpriteStuff
    .noCarry
        JSR HandleState
    .return
        JSR Graphics

        RTS



; state handling

HandleState:

        LDA !State
        JSL $0086DF|!BankB
        dw .idle, .enteringPipe, .teleporting, .stalling, .exitingPipe



        ; state 00: idle (carryable and solid, waiting for player to enter)

.idle      
        JSR HandleInteraction                   ; \
        CPX !CurrentTeleportTarget              ;  | Only initiate if this was the last teleport sprite touched
        BNE ..notLastTarget                     ;  |           
        LDA $18								    ;  | initiate teleporting if you press L or R
        AND #$30                                ;  |
        BNE ..beginTeleporting                  ; /
..notLastTarget
        RTS

..beginTeleporting

        LDA $1470|!Base2                        ; \
        ORA $148F|!Base2                        ;  | don't allow teleporting if you're carrying something
        BNE ..dontTeleport                      ; /

        LDA $1426|!Base2                        ; \  don't allow teleporting if a message box is active
        BNE ..dontTeleport                      ; /

        LDA !TeleportReady                      ; \ don't allow teleporting if the sprite is not touched yet
        BEQ ..dontTeleport                      ; /

        LDA $5D                                 ; \
        DEC                                     ;  |
        XBA                                     ;  | don't allow teleporting if the other pipe
        LDA #$F0                                ;  | is beyond the edges of the level
        REP #$20                                ;  |
        STA $00                                 ;  |
        SEP #$20                                ;  |
        LDA !14E0,x                             ;  |
        CMP #$FF                                ;  |
        BEQ ..dontTeleport                      ;  |
        XBA                                     ;  |
        LDA.w !E4,x                             ;  |
        REP #$20                                ;  |
        CMP $00                                 ;  |
        BCS ..dontTeleport                      ;  |
        SEP #$20                                ; /

        LDA $13F9|!Base2                        ; \  don't allow teleporting (and don't even play "wrong" sound)
        BNE .return                             ; /  if you're already teleporting (this can happen when you're standing on two at once)

..doTeleport

        JSR EraseFireballs

        ; STZ $17C0|!Base2                      ; \
        ; STZ $17C1|!Base2                      ;  | erase all smoke sprites?
        ; STZ $17C2|!Base2                      ;  | (this doesn't seem to work)
        ; STZ $17C3|!Base2                      ; /

        LDA #$10                                ; \  play blargg roar
        STA $1DF9|!Base2                        ; / 

        LDA #$02                                ; \ all kinds of teleportation settings
        STA $13F9|!Base2                        ; /

        LDY $18DF|!Base2 						
        BEQ ..noYoshi
        DEY
        LDA #$00
        STA !151C,y
        STA !1594,y
        STZ $18AE|!Base2
        STZ $14A3|!Base2
        LDA !160E,y
        BEQ ..noYoshi
        TAY
        LDA #$00
        STA !15D0,y
..noYoshi

        LDA #$08
        STA !Timer
        INC !State
        RTS

..dontTeleport
        SEP #$20
        LDA $16                                 ; \
        AND #$04                                ;  | if you're not allowed to teleport,
        BEQ .return                             ;  | play "wrong" sound once
        LDA #$2A                                ;  |
        STA $1DFC|!Base2                        ; /

.return
        RTS


        ; state 01: "entering pipe" animation

.enteringPipe

        LDA !Timer
        BEQ ..nextState

        STZ $73                                 ; \
        STZ $7B                                 ;  |
        LDA #$01                                ;  | all kinds of teleportation settings
        STA $185C|!Base2                        ;  | (hiding the player, disabling interaction etc.)
        LDA #$02                                ;  |
        STA $13F9|!Base2                        ;  |
        if !FreezeTimeWhenTeleporting           ;  |
          LDA #$FF                              ;  |
          STA $9D                               ;  |
          if !FixFreeze                         ;  |
            STA !FreezeRAM                      ;  |
          endif                                 ;  |
        endif                                   ; /
        RTS

..nextState

        JSR EraseFireballs

        JSR SetTeleportingXSpeed
        JSR SetTeleportingYSpeed

        INC !State
        RTS

        ; state 02: teleporting (player is invisible and moving between pipes)

.teleporting

        LDA #$01                                ; \
        STA $1404|!Base2                        ;  |
        STA $1406|!Base2                        ;  | all kinds of teleportation settings
        STZ $73                                 ;  |
        LDA #$01                                ;  |
        STA $185C|!Base2                        ;  |
        LDA #$02                                ;  |
        STA $13F9|!Base2                        ;  |
        LDA #$FF                                ;  |
        STA $78                                 ;  |
        if !FreezeTimeWhenTeleporting           ;  |
          STA $9D                               ;  |
          if !FixFreeze                         ;  |
            STA !FreezeRAM                      ;  |
          endif                                 ;  |
        endif                                   ; /

        JSR SetTeleportingXSpeed                ; \  move the player to the other pipe
        JSR SetTeleportingYSpeed                ; /

        LDA $7B                                 ; \
        ORA $7D                                 ;  | if the player doesn't need to move anymore
        ORA $17BC|!Base2                        ;  | and the screen has caught up with them too,
        ORA $17BD|!Base2                        ;  | we're done teleporting
        BNE ..keepTeleporting                   ; /

..doneTeleporting

        LDA.w !E4,x                             ; \
        STA $94                                 ;  |
        LDA !14E0,x                             ;  | fix the player's position to
        STA $95                                 ;  | right beneath the other pipe
        LDA.w !D8,x                             ;  |
        STA $96                                 ;  |
        LDA !14D4,x                             ;  |
        STA $97                                 ; /

        LDA #$0D                                ; \  play Thunder sound
        STA $1DF9|!Base2                        ; /

        LDA #$FF
        STA !Timer
        INC !State

        LDA.w !E4,x                             ; \
        STA $94                                 ;  | fix the player's position to
        LDA !14E0,x                             ;  | right on the sprite
        STA $95                                 ;  |
        LDA.w !D8,x                             ;  |
        SEC : SBC #$11                          ;  |
        STA $96                                 ;  |
        LDA !14D4,x                             ;  |
        SBC #$00                                ;  |
        STA $97                                 ; /

..keepTeleporting
        RTS


        ; state 03: Stalling for 08 frames. 
        ; this is very finicky, so be careful if you want to change how long the stalling occurs.

.stalling
        LDA !Timer
        BEQ +
        LDA #$08
        STA !Timer
        INC !State
        RTS
      +

        RTS


        ; state 04: "exiting pipe" animation

.exitingPipe

        LDA !Timer
        BEQ ..nextState

        LDA.w !E4,x                             ; \
        STA $94                                 ;  | fix the player's position to
        LDA !14E0,x                             ;  | right on the sprite
        STA $95                                 ;  |
        LDA.w !D8,x                             ;  |
        SEC : SBC #$11                          ;  |
        STA $96                                 ;  |
        LDA !14D4,x                             ;  |
        SBC #$00                                ;  |
        STA $97                                 ; /

        LDA #$01                                ; \
        STA $185C|!Base2                        ;  | all kinds of teleportation settings
        LDA #$02                                ;  |
        STA $13F9|!Base2                        ;  |
        if !FreezeTimeWhenTeleporting           ;  |
          LDA #$FF                              ;  |
          STA $9D                               ;  |
          if !FixFreeze                         ;  |
            STA !FreezeRAM                      ;  |
          endif                                 ;  |
        endif                                   ;  |
        RTS                                     ; /

..nextState

        LDA.w !E4,x                             ; \
        STA $94                                 ;  | fix the player's position to
        LDA !14E0,x                             ;  | right on the sprite
        STA $95                                 ;  |
        LDA.w !D8,x                             ;  |
        SEC : SBC #$11                          ;  |
        STA $96                                 ;  |
        LDA !14D4,x                             ;  |
        SBC #$00                                ;  |
        STA $97                                 ; /

        LDA #-$20
        STA $7D

        LDA $15
        AND #$04
        BEQ ..upPressed
        LDA !DownSpeed
        STA $7D
        BRA ..nonePressed
..upPressed
        LDA $15
        AND #$08
        BEQ ..nonePressed
        LDA !UpSpeed
        STA $7D
..nonePressed
                                                ; \
        STZ $185C|!Base2                        ;  |
        STZ $13F9|!Base2                        ;  | all kinds of teleportation settings
        STZ $1419|!Base2                        ;  |
        STZ $78                                 ; /

        STZ !14C8,X                             ; Destroy the sprite after use once

        LDA $15
        AND #$01
        BEQ ..leftButton
        LDA !DashSpeed
        STA $7B
..leftButton
        LDA $15
        AND #$02
        BEQ ..return
        LDA !DashSpeedNegative
        STA $7B
..return
        RTS


; determines where to move the player horizontally when teleporting

SetTeleportingXSpeed:

        LDA !14E0,x                             ; \
        XBA                                     ;  | calculate the distance
        LDA.w !E4,x                             ;  | between the player and the sprite
        REP #$20                                ;  |
        SEC : SBC $D1                           ;  |
        STA $00                                 ; /

        BPL + : EOR #$FFFF : INC : +            ; \
        CMP #$0010                              ;  |
        SEP #$20                                ;  | if the distance is less than a tile,
        BCS .notCloseEnough                     ;  | stop moving
.closeEnough                                    ;  | (it doesn't need to be an exact match,
        STZ $7B                                 ;  | the player's position will be set to the exact value later on)
        RTS                                     ;  |
.notCloseEnough                                 ; /

        REP #$20                                ; \
        LDA $00                                 ;  |
        SEP #$20                                ;  | otherwise, move the player left or right
        BMI .negativeSpeed                      ;  | depending on whether the distance is negative or positive
.positiveSpeed                                  ;  |
        LDA #!TeleportingSpeed                  ;  |
        BRA +                                   ;  |
.negativeSpeed                                  ;  |
        LDA #-!TeleportingSpeed                 ;  |
+       STA $7B                                 ;  |
.return                                         ;  |
        RTS                                     ; /




; determines where to move the player vertically when teleporting

SetTeleportingYSpeed:

        LDA !14D4,x
        XBA
        LDA.w !D8,x
        REP #$20
        SEC : SBC $D3
        STA $00

        BPL + : EOR #$FFFF : INC : +
        CMP #$0010
        SEP #$20
        BCS .notCloseEnough
.closeEnough
        STZ $7D
        RTS
.notCloseEnough
        REP #$20
        LDA $00
        SEP #$20
        BMI .negativeSpeed
.positiveSpeed
        LDA #!TeleportingSpeed
        BRA +
.negativeSpeed
        LDA #-!TeleportingSpeed
+       STA $7D
.return
        RTS




; erases (player's) fireballs on screen

EraseFireballs:

        LDY #$09
.loop
        LDA !extended_num,y
        CMP #$05
        BNE .continue
        LDA #$00
        STA !extended_num,y
.continue
        DEY
        BPL .loop

        RTS




; the code below is mostly copied from RussianMan's Key disassembly (thanks!)
; Currently set to not ever alter Mario's speed.

HandleCarryableSpriteStuff:

        LDA !14C8,x
        CMP #$0B
        BEQ .carried
.notCarried
        JSL $019138|!BankB
.carried
        LDA !1588,x
        AND #$04
        BEQ .notOnGround

        JSR HandleLandingBounce

        LDA !1588,x
        AND #$08
        BEQ .notAgainstCeiling

.againstCeiling
        LDA #$10
        STA !AA,x
        LDA !1588,x
        AND #$03
        BEQ .notAgainstWall
        LDA !E4,x
        CLC : ADC #$08
        STA $9A
        LDA !14E0,x
        ADC #$00
        STA $9B
        LDA !D8,x
        AND #$F0
        STA $98
        LDA !14D4,x
        STA $99
        LDA !1588,x
        AND #$20
        ASL #3
        ROL
        AND #$01
        STA $1933|!Base2
        LDY #$00
        LDA $1868|!Base2
        JSL $00F160|!BankB
        LDA #$08
        STA !1FE2,x

.notAgainstCeiling
        LDA !1588,x
        AND #$03
        BEQ .notAgainstWall
        JSR HandleBlockHit
        LDA !B6,x
        ASL
        PHP
        ROR !B6,x
        ASL
        ROR !B6,x
        PLP
        ROR !B6,x

.notOnGround
.notAgainstWall

        RTS





HandleBlockHit:

        LDA #$01
        STA $1DF9|!Base2

        LDA !15A0,x
        BNE .return

        LDA !E4,x
        SEC : SBC $1A
        CLC : ADC #$14
        CMP #$1C
        BCC .return

        LDA !1588,x
        AND #$40
        ASL #2
        ROR
        AND #$01
        STA $1933|!Base2

        LDY #$00
        LDA $18A7|!Base2
        JSL $00F160|!BankB

        LDA #$05
        STA !1FE2,x

.return
        RTS





HandleLandingBounce:

        LDA !B6,x
        PHP
        BPL +
        EOR #$FF : INC
+       LSR
        PLP
        BPL +
        EOR #$FF : INC
+       STA !B6,x
        LDA !AA,x
        PHA

        LDA !1588,x
        BMI .speed2
        LDA #$00
        LDY !15B8,x
        BEQ .store
.speed2
        LDA #$18
.store
        STA !AA,x

        PLA
        LSR #2
        TAY
        LDA .bounceSpeeds,y
        LDY !1588,x
        BMI .return
        STA !AA,x

.return
        RTS

.bounceSpeeds
        db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
        db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
        db $E8,$E8,$E8,$00,$00,$00,$00,$FE
        db $FC,$F8,$EC,$EC,$EC,$E8,$E4,$E0
        db $DC,$D8,$D4,$D0,$CC,$C8





HandleInteraction:

        LDA !154C,x          ; Interaction timer
        BNE .return
        JSL $01803A|!BankB   ; Player interaction
        BCC .return

        STX !CurrentTeleportTarget            ; Assign this sprite as the most recently carried version
        LDA #$01
        STA !TeleportReady
        LDA $15
        AND #$40
        BEQ .checkSprite

        LDA $1470|!Base2     ; Checking if the player can carry it
        ORA $148F|!Base2
        ORA $187A|!Base2
        BNE .checkSprite

        LDA #$0B
        STA !14C8,x

.keepCarried
        INC $1470|!Base2
        LDA #$08
        STA $1498|!Base2
        CLC
        RTS

.checkSprite
        LDA !14C8,x
        CMP #$09
        BNE .return

        ; Player carries object
        STZ !154C,x
        LDA !D8,x
        SEC : SBC $D3
        CLC : ADC #$08
        CMP #$20
        BCC .solidSides
        BPL .onTop

        LDA #$10
        STA $7D

        CLC
        RTS

.onTop
        ; I do not want the player to be able to stand on top to avoid key jump type tricks.
        ; Uncomment this code if you wish to re-enable it.
if !CanStandOnIt
        LDA $7D            
        BMI .return

        STZ $7D
        STZ $72
        INC $1471|!Base2

        LDA #$1F           ; Check Yoshi state
        LDY $187A|!Base2
        BEQ .notOnYoshi
        LDA #$2F
.notOnYoshi
        STA $00

        LDA !D8,x
        SEC : SBC $00
        STA $96
        LDA !14D4,x
        SBC #$00
        STA $97

        SEC
        RTS
endif

.return
        CLC
        RTS

.solidSides
if !SolidSides
        STZ $7B
        %SubHorzPos()
        TYA : ASL : TAY
        REP #$21
        LDA $94
        ADC .DATA_01AB2D,y
        STA $94
        SEP #$20
        CLC
endif
        RTS

.DATA_01AB2D
        db $01,$00,$FF,$FF





; graphics routine

Graphics:

        %GetDrawInfo()

        LDA $13F9|!Base2                        ; \  if the player is teleporting,
        BNE .priority                           ; /  use a different graphics routine to draw the tile on top of them

.normal

        LDA $00                                 ;    otherwise, it's about the most basic graphics routine you can get
        STA $0300|!Base2,y
        LDA $01
        STA $0301|!Base2,y
        LDA !State                              ; \
        BNE ..continue                          ;  | 
        LDA !TeleportReady                      ;  | Based upon the state, load the orb or the explosion
        BNE ..other                             ;  |
        LDA #!Tile                              ;  |
        BRA ..after                             ; /
..other
        LDA #!SwappedTile                       ; If the orb has been touched, load the palette swapped tile
        BRA ..after
..continue
        LDA #!TeleportingTile                   ; Load the teleporting GFX
..after
        STA $0302|!Base2,y
        LDA !extra_byte_1,x
        PHX : TAX
        LDA .properties,x
        PLX
        STA $0303|!Base2,y

        LDY #$02
        LDA #$00
        JSL $01B7B3|!BankB

        RTS



.priority
        LDA #$F0                                ; \  carryable custom sprites draw their own tile in this slot for some reason,
        STA $0301|!Base2,y                      ; /  so we need to explicitly remove that

        LDY #$00                                ; \
..loop                                          ;  |
        LDA $0201|!Base2,y                      ;  | find a new free slot, this time in the $0200 area
        CMP #$F0                                ;  | so it has priority over the player sprite
        BEQ ..break                             ;  |
        INY #4                                  ;  |
        CPY #$FC                                ;  |
        BNE ..loop                              ;  |
        RTS                                     ;  |
..break                                         ; /

        LDA $00                                 ; \
        STA $0200|!Base2,y                      ;  |
        LDA $01                                 ;  | draw the tile there
        STA $0201|!Base2,y                      ; /

        LDA !State                              ; \
        BNE ..continue                          ;  | 
        LDA !TeleportReady                      ;  | Based upon the state, load the orb or the explosion
        BNE ..other                             ;  |
        LDA #!Tile                              ;  |
        BRA ..after                             ; /
..other
        LDA #!SwappedTile                       ; If the orb has been touched, load the tile that uses palettes
        BRA ..after
..continue
        LDA #!TeleportingTile                   ; Load the teleporting GFX
..after
        STA $0202|!Base2,y                      ; \
        LDA !extra_byte_1,x                     ;  |
        PHX : TAX                               ;  |
        LDA .properties,x                       ;  |
        PLX                                     ;  |
        STA $0203|!Base2,y                      ; /

        TYA : STA !15EA,x                       ; \
        LDY #$02                                ;  | finish the OAM write with a custom routine
        LDA #$00                                ;  | that handles the $0200 area
        JSR FinishOAMWriteRt                    ; /

        RTS


.properties

        db $3D,$39,$37,$35


; a version of $01B7B3 that uses slots in the $0200 area
; (changes marked with <--)

FinishOAMWriteRt:

        STY $0B
        STA $08
        LDY !15EA,x
        LDA !D8,x
        STA $00
        SEC : SBC $1C
        STA $06
        LDA !14D4,x
        STA $01
        LDA !E4,x
        STA $02
        SEC : SBC $1A
        STA $07
        LDA !14E0,x
        STA $03

.loop
        TYA
        LSR
        LSR
        TAX
        LDA $0B
        BPL +
        LDA $0420|!Base2,x ; <---
        AND #$02
        STA $0420|!Base2,x ; <---
        BRA ++
+       STA $0420|!Base2,x ; <---
++      LDX.B #$00
        LDA $0200|!Base2,y ; <---
        SEC : SBC $07
        BPL +
        DEX
+       CLC : ADC $02
        STA $04
        TXA
        ADC $03
        STA $05

        REP #$20
        LDA $04
        SEC : SBC $1A
        CMP #$0100
        SEP #$20

        BCC +
        TYA
        LSR
        LSR
        TAX
        LDA $0420|!Base2,x ; <---
        ORA #$01
        STA $0420|!Base2,x ; <---
+       LDX.B #$00
        LDA $0201|!Base2,y ; <---
        SEC : SBC $06
        BPL +
        DEX
+       CLC : ADC $00
        STA $09
        TXA
        ADC $01
        STA $0A

        REP #$20
        LDA $09
        PHA
        CLC : ADC #$0010
        STA $09
        SEC : SBC $1C
        CMP #$0100
        PLA
        STA $09
        SEP #$20

        BCC +
        LDA #$F0
        STA $0201|!Base2,y ; <---
+       INY #4
        DEC $08
        BPL .loop

        LDX $15E9|!Base2
        RTS
