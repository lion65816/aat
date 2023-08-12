
        ; NPCs (version 4.2 I guess)
        ; made in 2021-22 by WhiteYoshiEgg

        ; This is a sprite that doesn't hurt the player and doesn't interact with any other sprites.
        ; It can stay still, walk around, or jump, and also display a message if the player
        ; presses a button while touching it.

        ; It's compatible with SMW's regular message boxes (can use any message in any level
        ; and show up to two at once), the Message Box Expansion patch,
        ; and also the VWF Dialogues patch.

        ; The movement, graphics and message behavior are *highly* customizable.
        ; All the options are in the extra bytes (of which it uses all 12).
        ; This means you only need to have *one entry* in your sprite list
        ; and can fully customize it *as you place it in your level*!


        ; ### !!! HOW TO USE THIS !!! ###

        ; ##############################################################################################
        ; #                                                                                            #
        ; #  All the customization options are explained in HOW_TO_USE.html, so please refer to that!  #
        ; #  It also has a user-friendly configuration tool.                                           #
        ; #                                                                                            #
        ; ##############################################################################################


        ; You shouldn't need to handle the details yourself, but if you're interested,
        ; the extra byte usage is documented at the bottom of this file.



; definitions

        !State                  = !C2,x
        !JumpTimer              = !1540,x
        !WalkTimer              = !1540,x
        !IdleTimer              = !1558,x
        !MessageTimer           = !163E,x
        !LevelNumberBackup      = !1504,x
        !PowerupGivenFlag       = !1602,x
        !Frame                  = !1570,x
        !SolidContactOccurred   = !187B,x
        !ShowIndicator          = $18CC|!addr   ;> PSI Ninja edit: Free RAM address.

        !WalkingTopLeftTile     = $00
        !JumpingTopLeftTile     = $04
        !TalkingTopLeftTile     = $06



        ; if you have applied the Message Box Expansion patch,
        ; make sure these three definitions are the same as in message_box_expansion.asm
        ; (you probably don't need to change this)

        !MessageBoxState        = $1426|!addr
        !MessageBoxTimer        = $1B88|!addr
        !MessageToShow          = $1B89|!addr



        ; if you have applied the VWF Dialogues Patch, take note!

        ; - do you have version 1.3 (released in 2022) or newer?
        ;   if so, it comes with a file called "vwfsharedroutines.asm".
        ;   copy that file into PIXI's "sprites" folder to make sure that the VWF dialogs work as intended.
        ;   if you don't do that, the NPC sprite should work anyway, it's just not recommended.

        ; - do you have version 1.2 or older?
        ;   if so, don't worry, the NPC sprite still works!
        ;   just make sure these definitions below are the same as in vwfconfig.cfg.
        ;   (if you're not sure what that means, you probably don't need to do anything.)

        !varram                 = $702000 ; for all VWF Dialogues versions
        if read1($00A1DA|!BankB) != $5C
        !varramSA1              = $419000 ; for VWF Dialogues version 1.2
        else
        !varramSA1              = $415000 ; for VWF Dialogues version 1.3 and up
                                          ; (only used if the routine file can't be found)
        endif





; macros

macro prepare_extra_bytes()
        LDA !extra_byte_1,x                     ; \
        STA $00                                 ;  | load extra byte address to into $00-$02
        LDA !extra_byte_2,x                     ;  | (if there's more than 4 extra bytes, the addresses for 1-3
        STA $01                                 ;  | actually serve as pointers to the real data)
        LDA !extra_byte_3,x                     ;  |
        STA $02                                 ; /
endmacro

macro load_extra_byte(num)
        LDY #<num>-1                            ; \  I'm counting extra bytes from 1 to 12
        LDA [$00],y                             ; /
endmacro

macro safe_JSL(addr)
        JSL <addr>                              ; \  after JSLing to something that could mess with $00-$02,
        %prepare_extra_bytes()                  ; /  make sure to set that back to the expected value afterwards
endmacro





; try including shared routines for the VWF Dialogues patch version 1.3 and up

if read1($00A1DA|!BankB) == $5C
        if getfilestatus("vwfsharedroutines.asm") == 0
                incsrc "vwfsharedroutines.asm"
        else
                print "Using legacy code for VWF Dialogues patch. To get rid of this warning, copy 'vwfsharedroutines.asm' from the VWF patch to your 'sprites' folder."
        endif
endif





; init routine

print "INIT ",pc

        STZ !State
        STZ !PowerupGivenFlag
        LDA $13BF|!addr
        STA !LevelNumberBackup

        %prepare_extra_bytes()

        %LDE()                                  ; \
        BEQ +                                   ;  |
        %load_extra_byte(10)                    ;  | set initial direction if walking
        AND #$20                                ;  |
        ROL #4                                  ;  |
        STA !157C,x                             ;  |
+                                               ; /

        %load_extra_byte(7)                     ; \
        AND #$30                                ;  |
        CMP #$30                                ;  | if the sprite is 32x32, change the sprite clipping
        BNE +                                   ;  | (only used for talking contact, solidity is handled by SolidContact)
        LDA #$08                                ;  |
        STA !1662,x                             ; /
+
        RTL





; main routine

print "MAIN ",pc

        PHB : PHK : PLB : JSR SpriteCode : PLB : RTL : SpriteCode:

        %prepare_extra_bytes()

        STZ !SolidContactOccurred
        STZ !ShowIndicator                      ;> PSI Ninja edit: By default, don't show the indicator.

        LDA $9D
        BNE .return

        %LDE()                                  ; \
        BEQ +                                   ;  | handle movement (stationary or walking
        JSR Walking                             ;  | depending on extra bit)
        BRA ++                                  ;  |
+       JSR Stationary                          ; /
++

        %load_extra_byte(6)                     ; \
        AND #$01                                ;  |
        BEQ .notSolid                           ;  | make sprite solid if set to
        JSR SolidContact                        ;  | (using a custom routine instead of sprite clipping)
        %prepare_extra_bytes()                  ;  |
.notSolid                                       ; /

        JSR HandleMessage                       ;    handle the showing of messages

.return

        %load_extra_byte(1)                     ; \
        AND #$01                                ;  | remove when off-screen
        BNE +                                   ;  | (unless it needs to remember giving a powerup,
        LDA #$01 : %SubOffScreen()              ;  | in which case also set the "process when off-screen" flag
        BRA ++                                  ;  | to be safe)
+       LDA !167A,x                             ;  |
        ORA #$04                                ;  |
        STA !167A,x                             ;  |
++                                              ; /

        %load_extra_byte(7)                     ; \
        AND #$40                                ;  |
        BEQ +                                   ;  | set the player pose to default when showing a message
        LDA !MessageTimer                       ;  | if set to
        CMP #$10                                ;  |
        BCC +                                   ;  |
        STZ $13E0|!addr                         ;  |
+                                               ; /

        JSR Graphics
        RTS





; extra bit set: walking

Walking:

        %load_extra_byte(10)                    ; \
        AND #$10                                ;  | if it's following the player it's always in the walking state
        BNE .walking                            ; /

        LDA !State                              ; \  otherwise it's either in the walking or in the idle state
        BEQ .walking                            ; /



        ; idle

.idle
        LDA !IdleTimer
        BNE ..noNextState
..nextState
        LDA !157C,x : EOR #$01 : STA !157C,x    ; \
        %load_extra_byte(11)                    ;  | if the idle timer has expired, turn around
        STA !WalkTimer                          ;  | and go into the walking state
        STZ !State                              ; /
..noNextState
        %safe_JSL($01802A|!BankB)               ;    update position with gravity
        JSR SetFrameWalking1
        RTS



        ; walking

.walking
        %load_extra_byte(10)                    ; \  always stay in the walking state
        BIT #$50                                ;  | if set to follow the player or walk indefinitely
        BNE ..noNextState                       ; /
        LDA !WalkTimer
        BNE ..noNextState
..nextState
        STZ !B6,x                               ; \
        %load_extra_byte(12)                    ;  | if the walk timer has expired,
        STA !IdleTimer                          ;  | stop walking and go into the idle state
        INC !State                              ;  |
        RTS                                     ; /
..noNextState
        %load_extra_byte(10)                    ; \
        BIT #$10                                ;  | don't follow the player if not set to
        BEQ ..dontFollowPlayer                  ; /
        LDA !1588,x                             ; \
        AND #$04                                ;  | only follow the player when on the ground
        BEQ ..dontFollowPlayer                  ; /

        %load_extra_byte(10)                    ; \  if the "initial direction" bit is set
        AND #$20                                ;  | (which doubles as a "flee from player" flag if set to follow),
        BEQ ..dontFlee                          ; /  flee from the player instead
..flee
        LDA !14E0,x                             ; \
        XBA                                     ;  |
        LDA !E4,x                               ;  | stop walking if it's further than $80 pixels from the player
        REP #$20                                ;  | (same behavior as being against a wall and not jumping)
        SEC : SBC $D1                           ;  |
        BPL + : EOR #$FFFF : INC : +            ;  |
        CMP #$0080                              ;  |
        SEP #$20                                ;  |
        BCS ..dontTurnAroundAtWall              ; /
..doFlee
        %SubHorzPos()                           ; \  if all the conditions are met, set direction to walk away from the player
        TYA : EOR #$01 : STA !157C,x            ; /
        BRA ..dontFollowPlayer
..dontFlee
        LDA !14E0,x                             ; \
        XBA                                     ;  |
        LDA !E4,x                               ;  | stop walking if it's within $18 pixels of the player
        REP #$20                                ;  | (same behavior as being against a wall and not jumping)
        SEC : SBC $D1                           ;  |
        BPL + : EOR #$FFFF : INC : +            ;  |
        CMP #$0018                              ;  |
        SEP #$20                                ;  |
        BCC ..dontTurnAroundAtWall              ; /
..doFollowPlayer
        %SubHorzPos()                           ; \  if all the conditions are met, set direction to walk towards the player
        TYA : STA !157C,x                       ; /
..dontFollowPlayer
        %load_extra_byte(9)                     ; \
        AND #$7F                                ;  |
        LDY !157C,x : BEQ +                     ;  | set walking speed depending on direction
        EOR #$FF : INC                          ;  |
+       STA !B6,x                               ; /

        %safe_JSL($019138)                      ;    interact with objects (apparently needed for the wall check?)

        LDA !1588,x                             ; \
        AND #$03                                ;  | check if against a wall
        BEQ ..notAgainstWall                    ; /
..againstWall
        %load_extra_byte(10)                    ; \
        AND #$08                                ;  | if set to jump when against a wall, try jumping
        BNE ..tryJumping                        ; /
        %load_extra_byte(10)                    ; \
        AND #$10                                ;  | if set to follow the player (and not jump), stay still
        BNE ..dontTurnAroundAtWall              ; /
        LDA #$08                                ; \
        STA !15AC,x                             ;  | otherwise, turn around and keep walking
        LDA !157C,x : EOR #$01 : STA !157C,x    ;  |
        BRA ..notAgainstWall                    ; /
..dontTurnAroundAtWall
        STZ !B6,x
        BRA ..notAgainstWall
..tryJumping
        STZ !B6,x
        LDA !1588,x                             ; \
        AND #$04                                ;  | don't jump if in the air
        BEQ +                                   ; /
        %load_extra_byte(10)                    ; \
        AND #$07                                ;  |
        TAY                                     ;  | jump with the given height
        LDA ..jumpSpeeds,y                      ;  |
        EOR #$FF : INC                          ;  |
        STA !AA,x                               ; /
        %load_extra_byte(9)                     ; \
        BPL ..noSound                           ;  | play jump sound if set to
        db $A9 : db read1($00D65F)              ;  |
        db $8D : dw read2($00D661)              ; /
..noSound
+
..notAgainstWall

        %load_extra_byte(10)                    ; \  don't stay on ledges if not set to
        BPL ..dontStayOnLedges                  ; /
        AND #$10                                ; \  don't stay on ledges if set to follow the player
        BNE ..dontStayOnLedges                  ; /
..stayOnLedges                                  ; \
        LDA !1588,x                             ;  | turn around if not on the ground
        AND #$04                                ;  | and the "turn around" timer isn't set
        ORA !151C,x                             ;  |
        BNE ..dontTurnAround                    ;  | (I actually mostly copypasted this from the
        LDA #$08                                ;  | "Mr. Bouncy" sprite by Dispari Scuro and Blind Devil
        STA !15AC,x                             ;  | because I gave up trying to figure out on my own
        LDA !157C,x : EOR #$01 : STA !157C,x    ;  | how the timers and flags and whatnot play together -
        LDA #$01                                ;  | this seems to work)
        STA !151C,x                             ;  |
..dontTurnAround                                ;  |
        LDA !1588,x                             ;  |
        AND #$04                                ;  |
        BEQ +                                   ;  |
        STZ !AA,x                               ;  | this resets y speed if set to stay on ledges and jumping against walls but oh well
        STZ !151C,x                             ; /
+
..dontStayOnLedges
        %safe_JSL($01802A|!BankB)               ;    update position with gravity

        LDA !B6,x                               ; \
        BEQ +                                   ;  |
        JSR SetFrameWalking                     ;  | alternate between two walking frames when moving,
        BRA ++                                  ;  | otherwise show only the first frame
+       JSR SetFrameWalking1                    ;  |
++                                              ; /
        RTS

..jumpSpeeds
        db $20,$30,$3C,$46,$4C,$50,$58,$60      ;    the setting for jump height against a wall has only 8 values
                                                ;    so I picked some reasonable-ish ones





; extra bit clear: stationary

Stationary:

        %load_extra_byte(10)                    ; \
        AND #$01                                ;  |
        BEQ .dontFacePlayer                     ;  | face the player if set to
.facePlayer                                     ;  |
        %SubHorzPos()                           ;  |
        TYA : STA !157C,x                       ;  |
.dontFacePlayer                                 ; /

        %load_extra_byte(10)                    ; \
        AND #$02                                ;  | don't jump if not set to
        BEQ .dontJump                           ; /
        LDA !1588,x                             ; \
        AND #$04                                ;  | don't jump if in the air
        BEQ .dontJump                           ; /

        LDA !JumpTimer                          ; \  only jump when the jump timer has expired
        BNE .dontJump                           ; /

        %load_extra_byte(10)                    ; \
        AND #$FC                                ;  |
        LSR                                     ;  | jump with the given height
        EOR #$FF : INC                          ;  |
        STA !AA,x                               ; /
        %load_extra_byte(11)                    ; \  reset the jump timer
        STA !JumpTimer                          ; /
        %load_extra_byte(12)                    ; \
        AND #$01                                ;  |
        BEQ .noSound                            ;  | play jump sound if set to
        db $A9 : db read1($00D65F)              ;  |
        db $8D : dw read2($00D661)              ; /
.noSound

.dontJump

        LDA !1588,x
        AND #$04
        BEQ +
        JSR SetFrameWalking1
        BRA ++
+       JSR SetFrameJumping
++
        %safe_JSL($01802A|!BankB)               ;    update position with gravity
        RTS





; message box handling

HandleMessage:

        ; things here are handled by the !MessageTimer, which counts down to zero
        ; set to #$18 when the player initiates a message

        ; if >#$10: set frame to talking frame
        ; at #$17: show the first message
        ; at #$13: show the second message if set to show two
        ; at #$09: cleanup (restore level number, give powerup if set to)
        ; at #$01: teleport if set to


        %load_extra_byte(1)                     ; \
        AND #$08                                ;  |
        BEQ .dontChangeFrame                    ;  | while the message timer is >#$10,
        LDA !MessageTimer                       ;  | change the frame to "talking" if set to
        CMP #$10                                ;  |
        BCC .dontChangeFrame                    ;  |
        JSR SetFrameTalking                     ;  |
.dontChangeFrame                                ; /

        LDA !MessageTimer                       ; \
        CMP #$17                                ;  | if the message timer is at #$17, show the first message
        BNE .dontShowFirstMessage               ; /
.showFirstMessage
        %load_extra_byte(1)                     ; \
        AND #$20                                ;  | show a VWF dialog if set to
        BEQ .noVWFDialog                        ; /
.vwfDialog
        ; use the shared routine from version 1.3 and up if available,
        ; otherwise (if the file can't be found or version 1.2 is used) use legacy code
        if defined("vwf_shared_routine_VWF_DisplayAMessage_exists")
                PHX
                %load_extra_byte(2)
                TAX
                %load_extra_byte(3)
                JSL VWF_DisplayAMessage
                PLX
                %prepare_extra_bytes()
        else
                if !SA1
                        !varram = !varramSA1
                endif
                %load_extra_byte(2)             ; \
                XBA                             ;  |
                %load_extra_byte(3)             ;  | show the dialog with the given number
                REP #$20                        ;  | (skip if another dialog is active)
                STA !varram+1                   ;  |
                SEP #$20                        ;  |
                LDA !varram                     ;  |
                BNE ++                          ;  |
                LDA #$01                        ;  |
                STA !varram                     ; /
        endif
        LDA #$22
        STA $1DFC|!addr
        BRA ++
.noVWFDialog
if read1($00A1DF|!BankB) == $22 && read1(read3($00A1E0|!BankB)+3) == $C2
        %load_extra_byte(4)                     ; \
        STA !MessageToShow                      ;  | if the message box expansion patch is applied,
        LDA #$01                                ;  | set the message number and activate the message box
        STA !MessageBoxState                    ; /
        %load_extra_byte(8)
        AND #$04
        BEQ .nosound
        LDA #$22
        STA $1DFC|!addr
.nosound
else
        %load_extra_byte(4)                     ; \
        BPL .dontChangeLevelNumber              ;  |
        LDA $13BF|!addr                         ;  | temporarily change the level number
        STA !LevelNumberBackup                  ;  | if set to use another level's message(s)
        %load_extra_byte(4)                     ;  |
        AND #$7F                                ;  |
        STA $13BF|!addr                         ;  |
.dontChangeLevelNumber                          ; /
        %load_extra_byte(8)                     ; \
        AND #$04                                ;  |
        BEQ .noSound                            ;  | play message sound if set to
        LDA #$22                                ;  |
        STA $1DFC|!addr                         ;  |
.noSound                                        ; /
        %load_extra_byte(1)                     ; \
        LDY #$01                                ;  |
        AND #$C0                                ;  | show the given message
        CMP #$80                                ;  |
        BNE +                                   ;  |
        LDY #$02                                ;  |
+       STY $1426|!addr                         ; /
endif
++
.dontShowFirstMessage

if read1($00A1DF|!BankB) != $22 || read1(read3($00A1E0|!BankB)+3) != $C2
        LDA !MessageTimer                       ; \
        CMP #$13                                ;  | if the message box expansion patch is not applied,
        BNE .dontShowSecondMessage              ;  | the message timer is at #$13
        %load_extra_byte(1)                     ;  | and it's not using a VWF dialog,
        AND #$20                                ;  | show the second message if set to
        BNE .dontShowSecondMessage              ;  |
        %load_extra_byte(1)                     ;  |
        AND #$C0                                ;  |
        CMP #$C0                                ;  |
        BNE .dontShowSecondMessage              ;  |
.showSecondMessage                              ;  |
        LDA #$02                                ;  |
        STA $1426|!addr                         ;  |
.dontShowSecondMessage                          ; /
endif

        LDA !MessageTimer                       ; \
        CMP #$09                                ;  | clean up a while after showing a message
        BNE .dontCleanup                        ; /
.cleanup
        LDA !LevelNumberBackup                  ; \  restore the level number
        STA $13BF|!addr                         ; /
        %load_extra_byte(1)                     ; \
        AND #$01                                ;  | don't give powerup if set to give only once
        AND !PowerupGivenFlag                   ;  | and it's already given a powerup
        BNE .dontGivePowerup                    ; /
        %load_extra_byte(1)                     ; \
        AND #$06                                ;  | don't give powerup if not set to
        BEQ .dontGivePowerup                    ; /
        LSR                                     ; \
        DEC                                     ;  | give powerup (by spawning a sprite,
        TAY                                     ;  | this will take care of sfx, item box etc.)
        LDA .powerupSprites,y                   ;  | and set the "powerup given" flag
        CLC                                     ;  |
        %SpawnSprite()                          ;  |
        LDA $D1                                 ;  |
        STA !E4,y                               ;  |
        LDA $D2                                 ;  |
        STA !14E0,y                             ;  |
        LDA $D3                                 ;  |
        CLC : ADC #$08                          ;  |
        STA !D8,y                               ;  |
        LDA $D4                                 ;  |
        ADC #$00                                ;  |
        STA !14D4,y                             ;  |
        LDA #$00                                ;  |
        STA !B6,y                               ;  |
        STA !AA,y                               ; /
        %load_extra_byte(1)
        AND #$01
        STA !PowerupGivenFlag
.dontGivePowerup
        %load_extra_byte(1)                     ; \
        AND #$10                                ;  |
        BEQ .dontDisappear                      ;  | disappear in a puff of smoke if set to
        STZ !14C8,x                             ;  |
        JSR Smoke                               ;  |
        LDA #$10                                ;  |
        STA $1DF9|!addr                         ;  |
.dontDisappear                                  ; /
.dontCleanup

        LDA !MessageTimer                       ; \
        CMP #$01                                ;  | check if supposed to teleport after cleanup
        BNE .dontTeleport                       ; /
.teleport
        %load_extra_byte(8)                     ; \
        AND #$08                                ;  |
        BEQ .dontTeleport                       ;  | teleport to screen exit if set to
        LDA #$06                                ;  |
        STA $71                                 ;  |
        STZ $88                                 ;  |
        STZ $89                                 ;  |
.dontTeleport                                   ; /

        %load_extra_byte(6)                     ; \
        AND #$01                                ;  |
        BEQ .notSolid                           ;  | if the sprite is solid, touching it from any side should count as contact
        LDA !SolidContactOccurred               ;  | (handled by the SolidContact routine)
        BNE .countAsContact                     ;  |
.notSolid                                       ; /

        %safe_JSL($01A7DC|!BankB)               ; \  if not in contact with the player, don't show a message
        BCC .noContact                          ; /

.countAsContact

        %load_extra_byte(1)                     ; \
        AND #$C0                                ;  | don't show a message if not set to
        BEQ .dontShowMessage                    ; /

        LDA #$01                                ;\ PSI Ninja edit.
        STA !ShowIndicator                      ;/
        PHX : PHY                               ; \
        %load_extra_byte(7)                     ;  |
        AND #$0F                                ;  | show a message if the given button is pressed
        TAY                                     ;  |
        LDA .buttonAddresses,y                  ;  |
        STA $00                                 ;  |
        STZ $01                                 ;  |
        LDA .buttonBits,y                       ;  |
        AND ($00)                               ;  |
        PLY : PLX                               ;  |
        CMP #$00                                ;  |
        BEQ .dontShowMessage                    ; /

.showMessage

        LDA #$18                                ; \  set the message timer
        STA !MessageTimer                       ; /  which sets all the other stuff in motion

.dontShowMessage

        %prepare_extra_bytes()

.noContact
        RTS



.powerupSprites
        db $74,$77,$75

.buttonBits
        ; up, down, left, right, select, start, A, B, X, X or Y, L, R
        db $08,$04,$02,$01,$20,$10,$80,$80,$40,$40,$20,$10
.buttonAddresses
        db $16,$16,$16,$16,$16,$16,$18,$16,$18,$16,$18,$18





; graphics routine

Graphics:

        %prepare_extra_bytes()

        %load_extra_byte(7)                     ; \
        BPL .notInvisible                       ;  | skip the graphics routine
        RTS                                     ;  | if the sprite is set to be invisible
.notInvisible                                   ; /

        ; set up properties byte

        LDA !157C,x                             ; \
        AND #$01                                ;  |
        EOR #$01                                ;  | set the x flip bit based on direction
        ROR #3                                  ;  |
        STA $03                                 ; /
        %load_extra_byte(8)                     ; \
        BPL .defaultPalette                     ;  |
        AND #$70                                ;  | use a custom palette row if set to
        LSR #3                                  ;  |
        BRA +                                   ;  |
.defaultPalette                                 ;  |
        LDA #$0C                                ;  |
+       TSB $03                                 ; /
        AND #$01


        %load_extra_byte(7)
        AND #$30
        ;CMP #$30 : BEQ .32x32
        ;CMP #$10 : BEQ .16x16
        CMP #$30
        BNE +
        JMP .32x32
+
        CMP #$10
        BNE .16x32
        JMP .16x16

.16x32

        %GetDrawInfo()

        LDA $00
        STA $0300|!Base2,y
        LDA $01
        SEC : SBC #$10
        STA $0301|!Base2,y
        LDA !Frame
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        INY #4

        LDA $00
        STA $0300|!Base2,y
        LDA $01
        STA $0301|!Base2,y
        LDA !Frame
        CLC : ADC #$20
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        ;> PSI Ninja edit: Show the NPC message indicator when the player overlaps the NPC (use ExGFX18A in SP2).
        LDA !ShowIndicator
        BEQ +++
        INY #4
        PHY
        %GetDrawInfo()
        PLY
        LDA $00
        STA $0300|!Base2,y
        LDA $01
        SEC : SBC #$20
        STA $0301|!Base2,y
        LDA #$80
        STA $0302|!Base2,y
        LDA $14
        AND #$04                                ;> Change the palette every four frames (flashing).
        BEQ +
        LDA #$38                                ;> YXPP CCCT = 0011 1000 = $38
        BRA ++
+
        LDA #$34                                ;> YXPP CCCT = 0011 0100 = $34
++
        STA $0303|!Base2,y
        LDY #$02
        LDA #$02
        JSL $01B7B3|!BankB
	BRA ++++
+++
        LDY #$02
        LDA #$01
        JSL $01B7B3|!BankB
++++
        RTS



.16x16

        %GetDrawInfo()

        LDA $00
        STA $0300|!Base2,y
        LDA $01
        STA $0301|!Base2,y
        LDA !Frame
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        LDY #$02
        LDA #$00
        JSL $01B7B3|!BankB

        RTS



.32x32

        %GetDrawInfo()

        LDA $157C,x
        BNE + : JMP ..right : +

..left

        LDA $00
        SEC : SBC #$08
        STA $0300|!Base2,y
        LDA $01
        SEC : SBC #$10
        STA $0301|!Base2,y
        LDA !Frame
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        INY #4

        LDA $00
        SEC : SBC #$08
        STA $0300|!Base2,y
        LDA $01
        STA $0301|!Base2,y
        LDA !Frame
        CLC : ADC #$20
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        INY #4

        LDA $00
        CLC : ADC #$08
        STA $0300|!Base2,y
        LDA $01
        SEC : SBC #$10
        STA $0301|!Base2,y
        LDA !Frame
        CLC : ADC #$02
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        INY #4

        LDA $00
        CLC : ADC #$08
        STA $0300|!Base2,y
        LDA $01
        STA $0301|!Base2,y
        LDA !Frame
        CLC : ADC #$22
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        JMP +

..right

        LDA $00
        SEC : SBC #$08
        STA $0300|!Base2,y
        LDA $01
        SEC : SBC #$10
        STA $0301|!Base2,y
        LDA !Frame
        CLC : ADC #$02
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        INY #4

        LDA $00
        SEC : SBC #$08
        STA $0300|!Base2,y
        LDA $01
        STA $0301|!Base2,y
        LDA !Frame
        CLC : ADC #$22
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        INY #4

        LDA $00
        CLC : ADC #$08
        STA $0300|!Base2,y
        LDA $01
        SEC : SBC #$10
        STA $0301|!Base2,y
        LDA !Frame
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

        INY #4

        LDA $00
        CLC : ADC #$08
        STA $0300|!Base2,y
        LDA $01
        STA $0301|!Base2,y
        LDA !Frame
        CLC : ADC #$20
        STA $0302|!Base2,y
        LDA #$31
        ORA $03
        STA $0303|!Base2,y

+

        ;> PSI Ninja edit: Show the NPC message indicator when the player overlaps the NPC (use ExGFX18A in SP2).
        LDA !ShowIndicator
        BEQ +++
        INY #4
        PHY
        %GetDrawInfo()
        PLY
        LDA $00
        CLC : ADC #$08
        STA $0300|!Base2,y
        LDA $01
        SEC : SBC #$20
        STA $0301|!Base2,y
        LDA #$80
        STA $0302|!Base2,y
        LDA $14
        AND #$04                                ;> Change the palette every four frames (flashing).
        BEQ +
        LDA #$38                                ;> YXPP CCCT = 0011 1000 = $38
        BRA ++
+
        LDA #$34                                ;> YXPP CCCT = 0011 0100 = $34
++
        STA $0303|!Base2,y
        LDY #$02
        LDA #$04
        JSL $01B7B3|!BankB
        BRA ++++
+++
        LDY #$02
        LDA #$03
        JSL $01B7B3|!BankB
++++
        RTS





; show smoke

Smoke:

        LDY #$03
.loop
        LDA $17C0|!addr,y
        BEQ .break
        DEY
        BPL .loop
        RTS
.break
        LDA #$01
        STA $17C0|!addr,y
        LDA #$1B
        STA $17CC|!addr,y
        LDA !D8,x
        STA $17C4|!addr,y
        LDA !E4,x
        STA $17C8|!addr,y
        RTS



; routines that set the current animation frame
; (called at various places)

; if the corresponding "use custom frame" bit isn't set it uses the default value,
; otherwise it uses the tile given in the extra bytes.

; the format in the extra bytes is "top left corner in SP3/4, aligned to 16x16 tiles"
; (0 is the first 16x16 tile, 1 is the 16x16 tile next to it, and 3F is the very last 16x16 tile.)
; this is so everything fits into 6 bits.
; there's a few bitwise shenanigans going on to convert that to an actual tile number,
; and the conversion is slightly different for each one because they're at different positions within a byte.

; the tile specified is the top one (if the sprite is not 16x16, the other is always one below that).
; the "custom walking frame" setting has two tiles (the second frame is one to the right, or two for 32x32 sprites).

SetFrameWalking:

        %load_extra_byte(8)                     ; \
        AND #$03                                ;  |
        TAY                                     ;  | slow down the frame counter
        LDA $14                                 ;  | depending on the given walk animation speed
        LSR                                     ;  |
        CPY #$00 : BEQ +                        ;  |
        LSR                                     ;  |
        DEY : BEQ +                             ;  |
        LSR                                     ;  |
        DEY : BEQ +                             ;  |
        LSR                                     ; /
+       AND #$01
        BEQ +
        JSR SetFrameWalking1
        BRA ++
+       JSR SetFrameWalking2
++      RTS



SetFrameWalking1:

        %load_extra_byte(5)
        BPL .default
        AND #$3F
        LSR #2
        AND #$FE
        ASL #4
        STA !Frame
        %load_extra_byte(5)
        AND #$3F
        ASL
        AND #$0F
        CLC : ADC !Frame
        STA !Frame
        RTS
.default
        LDA #!WalkingTopLeftTile
        STA !Frame
        RTS



SetFrameWalking2:

        %load_extra_byte(5)
        BPL .default
        AND #$3F
        LSR #2
        AND #$FE
        ASL #4
        STA !Frame
        %load_extra_byte(5)
        AND #$3F
        ASL
        AND #$0F
        CLC : ADC !Frame
        CLC : ADC #$02
        BRA +
.default
        LDA #!WalkingTopLeftTile+2
+       STA !Frame

        %load_extra_byte(7)                     ; \
        AND #$30                                ;  |
        CMP #$30                                ;  | if the sprite is 32x32,
        BNE +                                   ;  | move the second frame one tile over
        LDA !Frame                              ;  |
        CLC : ADC #$02                          ;  |
        STA !Frame                              ;  |
+       RTS                                     ; /



SetFrameJumping:

        %load_extra_byte(12)
        BPL .default
        AND #$7E
        LSR #3
        AND #$FE
        ASL #4
        STA !Frame
        %load_extra_byte(12)
        AND #$0E
        CLC : ADC !Frame
        STA !Frame
        RTS
.default
        LDA #!JumpingTopLeftTile
        STA !Frame
        %load_extra_byte(7)                     ; \
        AND #$30                                ;  |
        CMP #$30                                ;  | if the sprite is 32x32,
        BNE +                                   ;  | move the default jumping frame two tiles over
        LDA !Frame                              ;  |
        CLC : ADC #$04                          ;  |
        STA !Frame                              ;  |
+       RTS                                     ; /



SetFrameTalking:

        %load_extra_byte(5)
        AND #$40
        BEQ .default
        %load_extra_byte(6)
        AND #$FC
        LSR #5
        AND #$FE
        ASL #5
        STA !Frame
        %load_extra_byte(6)
        LSR
        AND #$1E
        CLC : ADC !Frame
        STA !Frame
        RTS
.default
        LDA #!TalkingTopLeftTile
        STA !Frame
        %load_extra_byte(7)                     ; \
        AND #$30                                ;  |
        CMP #$30                                ;  | if the sprite is 32x32,
        BNE +                                   ;  | move the default talking frame three tiles over
        LDA !Frame                              ;  |
        CLC : ADC #$06                          ;  |
        STA !Frame                              ;  |
+       RTS                                     ; /



; "solid sprite" routine
; adapted from https://www.smwcentral.net/?p=section&a=details&id=9571
; (check that for a commented version)

SolidContact:

        STZ !SolidContactOccurred

        %load_extra_byte(7)                     ; \
        AND #$30                                ;  | set up "sprite clipping A" values
        CMP #$30 : BEQ .32x32                   ;  | depending on size
        CMP #$10 : BEQ .16x16                   ; /

.16x32
        LDA !E4,x
        STA $04
        LDA !14E0,x
        STA $0A
        LDA !14D4,x
        XBA
        LDA !D8,x
        REP #$20
        SEC : SBC #$0010
        SEP #$20
        STA $05
        XBA
        STA $0B
        LDA #$10
        STA $06
        LDA #$20
        STA $07
        BRA +

.16x16
        LDA !E4,x
        STA $04
        LDA !14E0,x
        STA $0A
        LDA !D8,x
        STA $05
        LDA !14D4,x
        STA $0B
        LDA #$10
        STA $06
        STA $07
        BRA +

.32x32
        LDA !14E0,x
        XBA
        LDA !E4,x
        REP #$20
        SEC : SBC #$0008
        SEP #$20
        STA $04
        XBA
        STA $0A
        LDA !14D4,x
        XBA
        LDA !D8,x
        REP #$20
        SEC : SBC #$0010
        SEP #$20
        STA $05
        XBA
        STA $0B
        LDA #$20
        STA $06
        STA $07

+
        JSL $03B664|!BankB

        JSL $03B72B|!BankB
        BCS .contact
        RTS

.contact

        JSR Get_Solid_Vert
        LDY $187A|!Base2
        LDA $0F
        CMP .heightReq,y
        BCS .decideDownOrSides
        BPL .decideDownOrSides

        INC !SolidContactOccurred

        LDA #$01
        STA $1471|!Base2

        %prepare_extra_bytes()                  ; \
        %load_extra_byte(6)                     ;  |
        AND #$02                                ;  | if the sprite is set to be rideable,
        BEQ .dontRide                           ;  | move the player along when they're on top of it
.ride                                           ;  | (taken from imamelia's mega mole disassembly)
        LDY #$00                                ;  |
        LDA $1491|!Base2                        ;  |
        BPL .rightXOffset                       ;  |
        DEY                                     ;  |
.rightXOffset                                   ;  |
        CLC                                     ;  |
        ADC $94                                 ;  |
        STA $94                                 ;  |
        TYA                                     ;  |
        ADC $95                                 ;  |
        STA $95                                 ;  |
.dontRide                                       ; /

        LDA #$E1
        LDY $187A|!Base2
        BEQ .noYoshi
        LDA #$D1
.noYoshi
        CLC
        ADC $05
        DEC
        STA $96
        LDA $0B
        ADC #$FF
        STA $97

        RTS

.heightReq
        db $D4,$C6,$C6

.decideDownOrSides
        LDA $0A
        XBA
        LDA $04
        REP #$20
        SEC
        SBC #$000C
        CMP $D1
        SEP #$20
        BCS .horzCheck

        REP #$20
        CLC
        ADC #$0008
        STA $0C
        SEP #$20

        LDA $0C
        CLC
        ADC $06
        STA $0C
        LDA $0D
        ADC #$00
        STA $0D
        REP #$20
        LDA $0C
        CMP $D1
        SEP #$20
        BCC .horzCheck

        LDA $7D
        BPL .noContact

        LDA #$08
        STA $7D

        INC !SolidContactOccurred

        RTS

.horzCheck
        JSR Get_Solid_Horz
        LDA $0F
        BMI .marioLeft

        SEC
        SBC $06
        BPL .noContact

        INC !SolidContactOccurred

        LDA $04
        CLC
        ADC $06
        DEC
        DEC
        STA $0C

        LDA $0A
        ADC #$00
        STA $0D

        REP #$20
        LDA $0C
        STA $94
        SEP #$20

        LDA $7B
        BPL .noContact
        STZ $7B

        RTS

.marioLeft

        CLC
        ADC #$10
        BMI .noContact

        INC !SolidContactOccurred

        LDA $04
        SEC
        SBC #$0D
        STA $0C

        LDA $0A
        SBC #$00
        STA $0D

        REP #$20
        LDA $0C

        DEC     ; I added this line to prevent the player "sticking" to the left side of the sprite
                ; (originally, when you touched the left edge and started moving left,
                ; you'd need to build up some speed for about half a second before actually moving away)
                ; does it have side effects? who knows

        STA $94
        SEP #$20

        LDA $7B
        BMI .noContact
        STZ $7B

.noContact
        RTS

Get_Solid_Vert:
        LDY #$00
        LDA $D3
        SEC
        SBC #$10
        SBC $05
        STA $0F
        LDA $D4
        SBC $0B
        BPL .marioLower
        INY
.marioLower
        STY $0E
        RTS

Get_Solid_Horz:
        LDY #$00
        LDA $D1
        SEC
        SBC $04
        STA $0F
        LDA $D2
        SBC $0A
        BPL .marioRight
        INY
.marioRight
        STY $0E
        RTS







        ; EXTRA BYTE DOCUMENTATION

        ; extra bytes are counted from 1 to 12; bit 0 is the least significant bit.

        ; extra bytes 1-9 are shared, extra bytes 10-12 have different behavior
        ; depending on whether the sprite is stationary (extra bit clear) or walking (extra bit set).


        ; EXTRA BYTE 1
        ; bits 6-7: message to show (0 = none, 1 = message 1, 2 = message 2, 3 = both 1 and 2 in succession)
        ; bit 5:    show a VWF message (overrides number of messages)
        ; bit 4:    "disappear after talking" flag
        ; bit 3:    "different talking animation frame" flag
        ; bits 1-2: powerup to give the player after showing the message (0 = none)
        ; bit 0:    "give powerup only once per level" flag

        ; EXTRA BYTE 2
        ;           VWF message number (high byte)

        ; EXTRA BYTE 3
        ;           VWF message number (low byte)

        ; IF MESSAGE BOX EXPANSION PATCH IS NOT INSTALLED

                ; EXTRA BYTE 4
                ; bit 7:    "use message from another level" flag
                ; bits 0-6: level number to use message from ($13BF format)

        ; IF MESSAGE BOX EXPANSION PATCH IS INSTALLED

                ; EXTRA BYTE 4
                ;           number of message to show (=number of entry in message_list.asm, starting from 1, plus 6)

        ; EXTRA BYTE 5
        ; bit 7:    "use custom walking frames" flag
        ; bit 6:    "use custom talking frame" flag
        ; bits 0-5: custom walking frames (top left corner of the frame in SP3/4, aligned to 16x16 tiles)

        ; EXTRA BYTE 6
        ; bits 2-7: custom talking frame (top left corner of the frame in SP3/4, aligned to 16x16 tiles)
        ; bit 1:    "rideable" flag (only applies if "solid to player" flag is set")
        ; bit 0:    "solid to player" flag

        ; EXTRA BYTE 7
        ; bit 7:    "invisible" flag
        ; bit 6:    "set player pose" flag
        ; bits 4-5: sprite size (1 = 16x16, 2 = 16x32, 3 = 32x32)
        ; bits 0-3: button to press to show a message (index to a table with the actual bits and address)

        ; EXTRA BYTE 8
        ; bit 7:    "use custom palette row" flag
        ; bits 4-6: custom palette row
        ; bit 3:    "teleport after showing message" flag
        ; bit 2:    "play sound when showing message" flag
        ; bits 0-1: walk animation speed (0 = fast, 3 = slow)

        ; EXTRA BYTE 9
        ; bit 7:    "play jump sound when jumping while against a wall" flag
        ; bits 0-6: walking speed

        ; FOR STATIONARY SPRITES (EXTRA BIT CLEAR)

                ; EXTRA BYTE 10
                ; bits 2-7: jump height
                ; bit 1:    "jump" flag
                ; bit 0:    "face player" flag

                ; EXTRA BYTE 11
                ;           time between jumps

                ; EXTRA BYTE 12
                ; bit 7:    "use custom jumping frame" flag
                ; bits 1-6: custom jumping frame (top left corner of the frame in SP3/4, aligned to 16x16 tiles)
                ; bit 0:    "play jump sound" flag

        ; FOR WALKING SPRITES (EXTRA BIT SET)

                ; EXTRA BYTE 10
                ; bit 7:    "stay on ledges" flag
                ; bit 6:    "walk indefinitely" flag
                ; bit 5:    initial direction
                ; bit 4:    "follow player" flag (overrides "stay on ledges" flag)
                ; bit 3:    "jump when against a wall" flag
                ; bits 0-2: jump height when against a wall (index to a table with 8 sensible values)

                ; EXTRA BYTE 11
                ;       walk time

                ; EXTRA BYTE 12
                ;       idle time
