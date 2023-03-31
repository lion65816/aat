;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Stationary Magikoopa, by yoshicookiezeus
; 
; Description: This Magikoopa sits in one place repeatedly firing magic,
; disappearing whenever Mario gets near and reappearing when he goes away.
; Unlike the normal Magikoopa, several of these can be active at once,
; and after getting killed (by a thrown sprite, for instance) it does
; not respawn.
; Note that wherever you place the sprite in Lunar Magic is where its head
; appears, so it should be placed one tile above the floor you want it to
; stand on.
;
; Uses the extra bit: No
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite constants - feel free to change these
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!MagicNumber = $20              ; The normal sprite number to generate (Magikoopa magic)
!WandTile = $99                 ; The sprite tile to use for the wand

!ShootSFX = $10                 ; The sound effect to play when shooting magic
!ShootBank = $1DF9

Tilemap:
    db $A0,$C0,$A0,$C0,$A4,$C4,$A4,$C4,$A0,$C0,$A0,$C0
Y_Disp:
    db $10,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ROM and RAM defines - don't mess with these
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!RAM_FrameCounter       = $13
!RAM_FrameCounterB      = $14
!RAM_ScreenBndryXLo     = $1A
!RAM_ScreenBndryXHi     = $1B
!RAM_ScreenBndryYLo     = $1C
!RAM_ScreenBndryYHi     = $1D
!RAM_MarioSpeedX        = $7B
!RAM_MarioXPos          = $94
!RAM_MarioXPosHi        = $95
!RAM_SpritesLocked      = $9D
!RAM_SpriteNum          = !9E
!RAM_SpriteSpeedY       = !AA
!RAM_SpriteSpeedX       = !B6
!RAM_SpriteState        = !C2
!RAM_SpriteYLo          = !D8
!RAM_SpriteXLo          = !E4
!OAM_DispX              = $0300|!Base2
!OAM_DispY              = $0301|!Base2
!OAM_Tile               = $0302|!Base2
!OAM_Prop               = $0303|!Base2
!OAM_Tile2DispX         = $0304|!Base2
!OAM_Tile2DispY         = $0305|!Base2
!OAM_Tile2              = $0306|!Base2
!OAM_Tile2Prop          = $0307|!Base2
!OAM_Tile3DispX         = $0308|!Base2
!OAM_Tile3DispY         = $0309|!Base2
!OAM_Tile3              = $030A|!Base2
!OAM_Tile3Prop          = $030B|!Base2
!OAM_TileSize           = $0460|!Base2
!RAM_SpriteStatus       = !14C8
!RAM_SpriteYHi          = !14D4
!RAM_SpriteXHi          = !14E0
!RAM_SpriteDir          = !157C
!RAM_SprObjStatus       = !1588
!RAM_OffscreenHorz      = !15A0
!RAM_CurrentSprIndex    = $15E9|!Base2
!RAM_SprOAMIndex        = !15EA
!RAM_SpritePal          = !15F6
!RAM_SmokeNum           = $17C0|!Base2
!RAM_SmokeYLo           = $17C4|!Base2
!RAM_SmokeXLo           = $17C8|!Base2
!RAM_SmokeTimer         = $17CC|!Base2
!RAM_OffscreenVert      = !186C

!FinishOAMWrite     = $01B7B3|!BankB
!InitSpriteTables   = $07F7D2|!BankB

print "INIT ",pc
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    JSR SpriteCode
    PLB
    RTL

SpriteCode:
    LDA #$00
    %SubOffScreen()
    LDA #$01
    STA !15D0,x
    LDA !RAM_SpriteState,x
    JSL $0086DF|!BankB

MagiKoopaPtrs:
    dw Gone
    dw Attacking

Gone:
    LDA !RAM_SpritesLocked          ;\ if sprites locked,
    BNE Gone_Return                 ;/ return
    JSR CheckProximityMario
    BNE Gone_Return

    INC !RAM_SpriteState,x          ; go to next sprite state
    STZ !1570,x
    %SubHorzPos()                   ;\ make sprite face Mario
    TYA                             ; |
    STA !RAM_SpriteDir,x            ;/
    JSR SpawnSmoke
    LDA #$70
    STA !1540,x
Gone_Return:
    RTS

DATA_01BE69:
    db $04,$02,$00

DATA_01BE6C:
    db $10,$F8

Attacking:
    STZ !15D0,x
    JSL $01803A|!BankB              ; interact with Mario and with other sprites
    %SubHorzPos()                   ;\ make sprite face Mario
    TYA                             ; |
    STA !RAM_SpriteDir,x            ;/
    LDA !1540,x                     ;\ if attack cycle not complete,
    BNE .DontReset                  ;/ branch
    LDA #$70                        ;\ reset cycle
    STA !1540,x                     ;/
.DontReset
    JSR CheckProximityMario
    BEQ .DontDisappear
    STZ !RAM_SpriteState,x          ; go to next sprite state
    JSR SpawnSmoke
    BRA .SetGraphics

.DontDisappear
    LDA !1540,x
    CMP #$40                        ;\ if not time to generate magic,
    BNE .SetGraphics                ;/ branch
    PHA                             ; preserve sprite state timer
    LDA !RAM_SpritesLocked          ;\ if sprites locked
    ORA !RAM_OffscreenHorz,x        ; | or sprite is offscreen,
    BNE .DontSpawn                  ;/ branch
    JSR SpawnMagic
.DontSpawn
    PLA                             ; retrieve sprite state timer
.SetGraphics
    LSR #6                          ;\ use sprite state timer to determine graphics frame to use
                                    ; | in some very complicated manner
    TAY                             ; | get two highest bits of sprite state timer into y register
    PHY                             ; | and preserve them
    LDA !1540,x                     ; |
    LSR #3                          ; |
    AND #$01                        ; | get fourth bit of sprite state timer
    ORA DATA_01BE69,y               ; | add in something determined by two highest bits
    STA !1602,x                     ;/ and use it to determine sprite graphics frame to use

    JSR Graphics

    LDA !1602,x                     ;\ if sprite graphics frame less than 4,
    SEC : SBC #$02                  ; |
    CMP #$02                        ; |
    BCC .Label1                     ;/ branch
    LSR                             ;\ if it's less than 
    BCC .Label1                     ;/ branch
    LDA !RAM_SprOAMIndex,x          ;\ place head tile one pixel lower
    TAX                             ; |
    INC !OAM_DispY,x                ;/

    LDX !RAM_CurrentSprIndex        ; load sprite index

.Label1
    PLY                             ;\ retrieve seventh bit of sprite state timer
    CPY #$01                        ; | if it's clear,
    BNE DisplayWand                 ;/ branch
    JSR CODE_01B14E                 ; sparkle effect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisplayWand:
    LDA !1602,x                     ;\ if sprite graphics frame less than 4,
    CMP #$04                        ; |
    BCC .Return                     ;/ return
    LDY !RAM_SpriteDir,x            ;\ use sprite direction to determine x position of wand tile
    LDA !RAM_SpriteXLo,x            ; |
    CLC : ADC DATA_01BE6C,y         ; |
    SEC : SBC !RAM_ScreenBndryXLo   ; |
    LDY !RAM_SprOAMIndex,x          ; |
    STA !OAM_Tile3DispX,y           ;/
    LDA !RAM_SpriteYLo,x            ;\ set y position of wand tile
    SEC : SBC !RAM_ScreenBndryYLo   ; |
    CLC : ADC #$10                  ; |
    STA !OAM_Tile3DispY,y           ;/
    LDA !RAM_SpriteDir,x            ;\ set properties of wand tile
    LSR                             ; |
    LDA #$00                        ; |
    BCS +                           ; |
        ORA #$40                    ; |
+   ORA $64                         ; |
    ORA !RAM_SpritePal,x            ; |
    STA !OAM_Tile3Prop,y            ;/
    LDA.b #!WandTile                ;\ set wand tile number
    STA !OAM_Tile3,y                ;/
    TYA                             ;\ set wand tile size
    LSR #2                          ; |
    TAY                             ; |
    LDA #$00                        ; |
    ORA !RAM_OffscreenHorz,x        ; |
    STA $0462|!Base2,y              ;/
.Return
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckProximityMario:
    %SubHorzPos()           ;\ if sprite not closer to Mario than 0x20 pixels horizontally,
    LDA $0E                 ; |
    CLC : ADC #$30          ; |
    CMP #$60                ; |
    BCS +                   ;/ branch
    %SubVertPos()           ;\ if sprite not closer to Mario than 0x20 pixels horizontally,
    LDA $0F                 ; |
    CLC : ADC #$30          ; |
    CMP #$60                ; |
    BCS +                   ;/ branch
    LDA #$01
    RTS

+   LDA #$00
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpawnMagic:
    LDY.b #!SprSize-3       ; setup loop
-   LDA !14C8,y             ;\ check if sprite slot is free
    BEQ +                   ;/ if so, branch
    DEY                     ;\ if not, check next slot
    BPL -                   ;/
    RTS                     ; if no slots left, return

+   LDA.b #!ShootSFX            ;\ sound effect
    STA.w !ShootBank|!Base2     ;/ 
    LDA #$08                    ;\ set sprite status
    STA !14C8,y                 ;/ 
    LDA.b #!MagicNumber         ;\ set sprite number       
    STA.w !9E,y                 ;/
    LDA !sprite_x_low,x         ;\ set sprite x position
    STA.w !sprite_x_low,y       ; |
    LDA !sprite_x_high,x        ; |
    STA.w !sprite_x_high,y      ;/
    LDA !sprite_y_low,x         ;\ set sprite y position
    CLC : ADC #$0A              ; |
    STA.w !sprite_y_low,y      ; |
    LDA !sprite_y_high,x        ; |
    ADC #$00                    ; |
    STA !sprite_y_high,y        ;/
    TYX                       
    JSL !InitSpriteTables       ; clear out old sprite values
    LDA #$20
    JSR CODE_01BF6A             ; aiming routine
    LDX !RAM_CurrentSprIndex
    LDA $00                             ;\ set sprite speeds
    STA.w !sprite_speed_y|!Base1,y      ; |
    LDA $01                             ; |
    STA.w !sprite_speed_x|!Base1,y      ;/
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Graphics:
    %GetDrawInfo()
    LDA !1602,x                 ;\ use graphics frame to determine initial tile table offset
    ASL                         ; |
    STA $03                     ;/
    LDA !RAM_SpriteDir,x
    STA $02
    PHX                         ; preserve sprite index
    LDX #$01                    ; setup loop counter
-   LDA $01                     ;\ set y position of tile
    CLC : ADC Y_Disp,x          ; |
    STA !OAM_DispY,y            ;/
    LDA $00                     ;\ set x position of tile
    STA !OAM_DispX,y            ;/
    PHX                         ; preserve loop counter
    LDX $03                     ; get tilemap index
    LDA Tilemap,x               ;\ set tile number
    STA !OAM_Tile,y             ;/
    LDX !RAM_CurrentSprIndex    ; load sprite index
    LDA !RAM_SpritePal,x        ; load sprite graphics properties
    PLX                         ; retrieve loop counter
    PHY                         ; preserve OAM index
    LDY $02                     ;\ if sprite facing right,
    BNE +                       ; |
        EOR #$40                ;/ flip tile
+   PLY                         ; retrieve OAM index
    ORA $64                     ; add in level properties
    STA !OAM_Prop,Y             ; set tile properties
    INY #4                      ; increase OAM index so that the next tile can be written
    INC $03
    DEX                         ; decrease loop counter
    BPL -                       ; if still tiles left to draw, go to start of loop
    PLX                         ; retrieve sprite index
    LDY #$02                    ; the tiles written were 16x16
    LDA #$01                    ; we wrote two tiles
    JSL !FinishOAMWrite
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; aiming routine
; input: accumulator should be set to total speed (x+y)
; output: $00 = y speed, $01 = x speed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_01BF6A:
    STA $01
    PHX                     ;\ preserve sprite indexes of Magikoopa and magic
    PHY                     ;/
    JSR CODE_01AD42         ; $0E = vertical distance to Mario
    STY $02                 ; $02 = vertical direction to Mario
    LDA $0E                 ;\ $0C = vertical distance to Mario, positive
    BPL +                   ; |
        EOR #$FF            ; |
        CLC : ADC #$01      ; |
+   STA $0C                 ;/
    %SubHorzPos()           ; $0F = horizontal distance to Mario
    STY $03                 ; $03 = horizontal direction to Mario
    LDA $0E                 ;\ $0D = horizontal distance to Mario, positive
    BPL +                   ; |
        EOR #$FF            ; |
        CLC : ADC #$01      ; |
+   STA $0D
    LDY #$00
    LDA $0D                 ;\ if vertical distance less than horizontal distance,
    CMP $0C                 ; |
    BCS +                   ;/ branch
        INY                 ; set y register
        PHA                 ;\ switch $0C and $0D
        LDA $0C             ; |
        STA $0D             ; |
        PLA                 ; |
        STA $0C             ;/
+   LDA #$00                ;\ zero out $00 and $0B
    STA $0B                 ; | ...what's wrong with STZ?
    STA $00                 ;/
    LDX $01                 ;\ divide $0C by $0D?
-   LDA $0B                 ; |\ if $0C + loop counter is less than $0D,
    CLC : ADC $0C           ; | |
    CMP $0D                 ; | |
    BCC +                   ; |/ branch
        SBC $0D             ; | else, subtract $0D
        INC $00             ; | and increase $00
+   STA $0B                 ; |
    DEX                     ; |\ if still cycles left to run,
    BNE -                   ;/ / go to start of loop
    TYA                     ;\ if $0C and $0D was not switched,
    BEQ +                   ;/ branch
        LDA $00             ;\ else, switch $00 and $01
        PHA                 ; |
        LDA $01             ; |
        STA $00             ; |
        PLA                 ; |
        STA $01             ;/
+   LDA $00                 ;\ if horizontal distance was inverted,
    LDY $02                 ; | invert $00
    BEQ +                   ; |
        EOR #$FF            ; |
        CLC : ADC #$01      ; |
        STA $00             ;/
+   LDA $01                 ;\ if vertical distance was inverted,
    LDY $03                 ; | invert $01
    BEQ +                   ; |
        EOR #$FF            ; |
        CLC : ADC #$01      ; |
        STA $01             ;/
+   PLY                     ;\ retrieve Magikoopa and magic sprite indexes
    PLX                     ;/
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display smoke effect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpawnSmoke:
    LDA !RAM_OffscreenVert,x
    ORA !RAM_OffscreenHorz,x
    BNE .Return

    LDY #$03                    ; find a free slot to display effect
-   LDA !RAM_SmokeNum,y
    BEQ +
    DEY
    BPL -
.Return
    RTS                         ; return if no slots open

+   LDA #$01                    ;\ set effect graphic to smoke graphic
    STA !RAM_SmokeNum,y         ;/
    LDA !RAM_SpriteYLo,x        ;\ set smoke y position
    CLC : ADC #$08              ; |
    STA !RAM_SmokeYLo,y         ;/
    LDA !RAM_SpriteXLo,x        ;\ smoke x position = shooter x position
    STA !RAM_SmokeXLo,y         ;/
    LDA #$1B                    ;\ set time to show smoke
    STA !RAM_SmokeTimer,y       ;/
    RTS     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_01B14E:
    LDA !RAM_FrameCounter           ;\ only run code every fourth frame
    AND #$03                        ; |
    ORA !RAM_OffscreenVert,x        ; | if sprite offscreen vertically
    ORA !RAM_SpritesLocked          ; | or sprites locked,
    BNE Return01B191                ;/ return
    JSL $01ACF9|!BankB              ;\ #$02 = sprite xpos low byte + random number between 0x-5 and 0xB
    AND #$0F                        ; |
    CLC                             ; |
    LDY #$00                        ; |
    ADC #$FC                        ; |
    BPL +                           ; |
        DEY                         ; |
+                                   ; |
    CLC : ADC !RAM_SpriteXLo,x      ; |
    STA $02                         ;/
    TYA                             ;\ if $02 means an offscreen location?
    ADC !RAM_SpriteXHi,x            ; |
    PHA                             ; |
    LDA $02                         ; |
    CMP !RAM_ScreenBndryXLo         ; |
    PLA                             ; |
    SBC !RAM_ScreenBndryXHi         ; |
    BNE Return01B191                ;/ return
    LDA $148E                       ;\ #$00 = sprite ypos low byte + random number between 0x-2 and 0xD
    AND #$0F                        ; |
    CLC : ADC #$FE                  ; |
    ADC !RAM_SpriteYLo,x            ; |
    STA $00                         ;/
    LDA !RAM_SpriteYHi,x            ;\ #$01 = sprite ypos high byte with changes for earlier random number
    ADC #$00                        ; |
    STA $01                         ;/
    JSL $0285BA|!BankB              ; sparkle effect
Return01B191:
    RTS

CODE_01AD42:
    LDY #$00
    LDA $D3
    CLC                     ;\ make subroutine use position of Mario's lower half instead of the upper one
    ADC #$08                ;/ this wasn't in the original routine
    SEC : SBC !RAM_SpriteYLo,x
    STA $0E
    LDA $D4
    SBC !RAM_SpriteYHi,x
    BPL +
        INY
+   RTS
