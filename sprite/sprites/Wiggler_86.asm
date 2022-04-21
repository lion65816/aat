;===================================================================================;
; Wiggler disassembly (Sprite 86)                                                   ;
; by KevinM                                                                         ;
;                                                                                   ;
; This sprite is composed of many segments on which Mario can bounce indefinitely.  ;
; It initially walks around slowly, then when Mario jumps on it it becomes stunned  ;
; for a certain amount of time, after which it becomes "angry" and starts moving    ;
; faster and constantly turns around to follow Mario.                               ;
; Some customizations are possible: the extra bit and the first property byte can   ;
; change some properties, as well as the defines below.                             ;
;                                                                                   ;
; Uses extra bit: YES                                                               ;
;  - If the extra bit is set, the wiggler will spawn angry, otherwise it will spawn ;
;    normal and then become angry when jumped on.                                   ;
;                                                                                   ;
; Extra Property Byte 1: it determines the number of segments of the wiggler (w/o   ;
;  counting the head). Values from 0 to 4 are allowed, greater values will make the ;
;  additional segment appear in weird places. Vanilla wigglers have this = 4.       ;
;===================================================================================;

;===============================;
; Defines of general properties ;
;===============================;
    !FollowMario    = 1             ; 0 = the wiggler will never turn around to follow Mario, even when angry. It can still turn around when blocked by something.
                                    ; 1 = vanilla behavior.
    !XSpeedNormal   = $15,$EA       ;\ Right and left speeds in the "normal" and "angry" state.
    !XSpeedAngry    = $24,$DB       ;/

;===================================;
; Defines of addresses and routines ;
;===================================;
    !RAM_FrameCounter       = $13
    !RAM_ScreenBndryXLo     = $1A
    !RAM_ScreenBndryYLo     = $1C
    !RAM_MarioSpeedX        = $7B
    !RAM_MarioSpeedY        = $7D
    !RAM_MarioXPos          = $94
    !RAM_MarioXPosHi        = $95
    !RAM_MarioYPos          = $96
    !RAM_MarioYPosHi        = $97
    !RAM_SpritesLocked      = $9D
    !RAM_SegmentsPntr       = $D5
    !RAM_SpriteSpeedY       = !AA
    !RAM_SpriteSpeedX       = !B6
    !RAM_SpriteState        = !C2
    !RAM_SpriteYLo          = !D8
    !RAM_SpriteXLo          = !E4
    !RAM_SpriteStatus       = !14C8
    !RAM_SpriteXHi          = !14E0
    !RAM_IsWigglerAngry     = !151C
    !RAM_TurningTimer       = !1534
    !RAM_StunAnimTimer      = !1540
    !RAM_DisableInter       = !154C
    !RAM_AnimFrameCntr      = !1570
    !RAM_SpriteDir          = !157C
    !RAM_SprObjStatus       = !1588
    !RAM_SprChangeDirTmr    = !15AC
    !RAM_SprSlope           = !15B8
    !RAM_SprOnYoshiTongue   = !15D0
    !RAM_SprOAMIndex        = !15EA
    !RAM_SpritePal          = !15F6
    !RAM_FlipFrameCntr      = !1602
    !RAM_CurrentSprIndex    = $15E9|!Base2
    !RAM_EnemiesStomped     = $1697|!Base2
    !RAM_ExSpriteNum        = $170B|!Base2
    !RAM_ExSpriteYLo        = $1715|!Base2
    !RAM_ExSpriteXLo        = $171F|!Base2
    !RAM_ExSpriteYHi        = $1729|!Base2
    !RAM_ExSpriteXHi        = $1733|!Base2
    !RAM_ExSprSpeedY        = $173D|!Base2
    !RAM_ExSprSpeedX        = $1747|!Base2
    !RAM_StarKillCntr       = $18D2|!Base2
    !RAM_OnYoshi            = $187A|!Base2
    !OAM_ExtendedDispX      = $0200|!Base2
    !OAM_ExtendedDispY      = $0201|!Base2
    !OAM_ExtendedTile       = $0202|!Base2
    !OAM_ExtendedProp       = $0203|!Base2
    !OAM_DispX              = $0300|!Base2
    !OAM_DispY              = $0301|!Base2
    !OAM_Tile               = $0302|!Base2
    !OAM_Prop               = $0303|!Base2
    !OAM_Tile2DispX         = $0304|!Base2
    !OAM_Tile2DispY         = $0305|!Base2
    !OAM_Tile2Prop          = $0307|!Base2
    !OAM_TileSize           = $0460|!Base2
    !ExecutePtr             = $0086DF|!BankB
    !HurtMario              = $00F5B7|!BankB
    !UpdateYPosNoGrvty      = $01801A|!BankB
    !UpdateXPosNoGrvty      = $018022|!BankB
    !SprSprInteract         = $018032|!BankB
    !SprObjInteraction      = $019138|!BankB
    !BoostMarioSpeed        = $01AA33|!BankB
    !DisplayContactGfx      = $01AB99|!BankB
    !FinishOAMWrite         = $01B7B3|!BankB
    !GivePoints             = $02ACE5|!BankB

; The segments' position table is at $7F9A7B ($418800 if SA-1).
if !SA1 == 0
    !SegBank     = $7F
    !SegTableMid = $9A
    !SegTableLow = $7B
else
    !SegBank     = $41
    !SegTableMid = $88
    !SegTableLow = $00
endif

;===============================;
; Init routine                  ;
;===============================;
print "INIT ",pc
    PHB
    PHK
    PLB
    JSR WritePointer
    LDY #$7E                    ;\ Write the X and Y position of all the segments.
-   LDA !RAM_SpriteXLo,X        ;|
    STA [!RAM_SegmentsPntr],Y   ;|
    LDA !RAM_SpriteYLo,X        ;|
    INY                         ;|
    STA [!RAM_SegmentsPntr],Y   ;|
    DEY                         ;|
    DEY                         ;|
    DEY                         ;|
    BPL -                       ;/
    LDA !extra_bits,x           ;\ If the extra bit is set...
    AND #$04                    ;|
    BEQ +                       ;|
    LDA #$01                    ;|
    STA !RAM_IsWigglerAngry,x   ;| ...make it angry...
    LDA #$08                    ;|
    STA $00                     ;|
    LDA !RAM_SpritePal,X        ;|
    AND #$F1                    ;|
    ORA $00                     ;|
    STA !RAM_SpritePal,X        ;/ ...and use the correct palette.
+   JSR UpdateSpriteDir
    ;TYA                        ;\ Moved inside the sub-routine.
    ;STA !RAM_SpriteDir,x       ;/
    PLB
    RTL

;===============================;
; Main routine wrapper          ;
;===============================;
print "MAIN ",pc
    PHB
    PHK
    PLB
    JSR WigglerMain
    PLB
    RTL

;===============================;
; Main routine                  ;
;===============================;
WigglerSpeed:
    db !XSpeedNormal,!XSpeedAngry

WigglerMain:
    JSR WritePointer
    LDA !RAM_SpritesLocked      ;\ If sprites are not locked, run the main code.
    BEQ SpriteNotLocked         ;/
    JMP DrawWiggler1            ; If sprites are locked, just draw the graphics.

SpriteNotLocked:
    JSL !SprSprInteract         ; Make it interact with other sprites.
    LDA !RAM_StunAnimTimer,X    ;\ Branch if the wiggler is not stunned.
    BEQ NotStunned              ;/
    CMP #$01                    ;\ If it's not the last "stunned" frame, branch.
    BNE .ChangePalette1         ;/
    LDA #$08                    ;\ If it's the last "stunned" frame, set a
    BRA .ChangePalette2         ;/ specific value for A and branch.
.ChangePalette1:
    AND #$0E                    ;\
.ChangePalette2:                ;|
    STA $00                     ;| Change the palette based on A.
    LDA !RAM_SpritePal,X        ;|
    AND #$F1                    ;|
    ORA $00                     ;|
    STA !RAM_SpritePal,X        ;/
    JMP DrawWiggler1            ; Draw the wiggler and do nothing else.

NotStunned:
    JSL !UpdateXPosNoGrvty      ;\ Update X and Y positions.
    JSL !UpdateYPosNoGrvty      ;/
    %SubOffScreen()             ; Erase it if off screen.
    INC !RAM_AnimFrameCntr,X
    LDA !RAM_IsWigglerAngry,X   ;\ If not in angry state, branch.
    BEQ SetXSpeed               ;/
.Angry:
    INC !RAM_AnimFrameCntr,X    ;\ When in angry state, change direction to face Mario every $40 frames.
    INC !RAM_TurningTimer,X     ;|
    LDA !RAM_TurningTimer,X     ;|
    AND #$3F                    ;|
    BNE SetXSpeed               ;|
if !FollowMario == 1
    JSR UpdateSpriteDir         ;/
endif
    ;TYA                        ;\ Moved inside the sub-routine.
    ;STA !RAM_SpriteDir,x       ;/

SetXSpeed:
    LDY !RAM_SpriteDir,X        ;\ Set the X speed based on sprite state and direction.
    LDA !RAM_IsWigglerAngry,X   ;|\ If not angry, branch.
    BEQ +                       ;|/
    INY                         ;|\ Use the "angry" values.
    INY                         ;|/
+   LDA WigglerSpeed,Y          ;|
    STA !RAM_SpriteSpeedX,X     ;/
    INC !RAM_SpriteSpeedY,X     ; ??? Increase Y speed
    JSL !SprObjInteraction      ; Interact with objects.
    LDA !RAM_SprObjStatus,X     ;\ Branch if touching object
    AND #$03                    ;|
    BNE InAirOrTouchObj         ;/
    LDA !RAM_SprObjStatus,X     ;\ Branch if not on ground
    AND #$04                    ;|
    BEQ InAirOrTouchObj         ;/

FreeOnGround:
    LDA !RAM_SprObjStatus,X     ;\ If touching layer 2 from above, branch.
    BMI +                       ;/
    LDA #$00
    LDY !RAM_SprSlope,X         ;\ If not flat ground, branch.
    BEQ .StoreYSpeed            ;/
+   LDA #$18
.StoreYSpeed:
    STA !RAM_SpriteSpeedY,X     ; Y speed = 18 if touching layer 2 from above or on a slope, otherwise = 00.
    BRA FlipSegments

InAirOrTouchObj:
    LDA !RAM_SprChangeDirTmr,X  ;\ If it's not time to change direction, branch.
    BNE FlipSegments            ;/
    LDA !RAM_SpriteDir,X        ;\ Invert the facing direction.
    EOR #$01                    ;|
    STA !RAM_SpriteDir,X        ;/
    STZ !RAM_FlipFrameCntr,X    ; The segments must flip now.
    LDA #$08                    ;\ Don't change direction for 8 frames.
    STA !RAM_SprChangeDirTmr,X  ;/ (this timer decrements every frame)

FlipSegments:
    JSR UpdateSegmentsPos
    LDA !RAM_FlipFrameCntr,X    ;\ If not time to flip the segments, branch.
    INC !RAM_FlipFrameCntr,X    ;|
    AND #$07                    ;|
    BNE DrawWiggler             ;/
    LDA !RAM_SpriteState,X      ;\ Set the direction of each segment.
    ASL                         ;|
    ORA !RAM_SpriteDir,X        ;|
    STA !RAM_SpriteState,X      ;/

DrawWiggler1:
    JMP DrawWiggler

;===========================================;
; Graphics routine + interaction with Mario ;
;===========================================;
DATA_02F103:
    db $00,$1E,$3E,$5E,$7E

DATA_02F108:
    db $00,$01,$02,$01

WigglerTiles:
    db $C4,$C6,$C8,$C6

DATA_02F2D3:
    db $00,$08

WigglerEyesX:
    db $04,$04

DrawWiggler:
    %GetDrawInfo()              ; Sets Y = index of sprite OAM
    LDA !RAM_AnimFrameCntr,X    ;\ Store values for later.
    STA $03                     ;|
    LDA !RAM_SpritePal,X        ;|
    STA $07                     ;|
    LDA !RAM_IsWigglerAngry,X   ;|
    STA $08                     ;|
    LDA !RAM_SpriteState,X      ;|
    STA $02                     ;/
    LDA !extra_prop_1,x         ;\ Store the custom max loop length in $04.
    INC A                       ;|
    STA $04                     ;/
    TYA                         ;\ Y = Y + 4
    CLC : ADC #$04              ;|
    TAY                         ;/
    LDX #$00                    ; Initialize the loop index.
DrawBodyLoop:
    PHX
    STX $05
    LDA $03
    LSR : LSR : LSR
    NOP : NOP : NOP : NOP
    CLC : ADC $05
    AND #$03
    STA $06
    PHY
    LDY DATA_02F103,X
    LDA $08                     ;\ If not angry, branch.
    BEQ +                       ;/
    TYA
    LSR
    AND #$FE
    TAY
+   STY $09
    LDA [!RAM_SegmentsPntr],Y
    PLY
    SEC : SBC !RAM_ScreenBndryXLo
    STA !OAM_DispX,Y
    PHY
    LDY $09
    INY
    LDA [!RAM_SegmentsPntr],Y
    PLY
    SEC : SBC !RAM_ScreenBndryYLo
    LDX $06
    SEC : SBC DATA_02F108,X
    STA !OAM_DispY,Y
    PLX
    PHX
    LDA #$8C
    CPX #$00
    BEQ CODE_02F178
    LDX $06
    LDA WigglerTiles,X
CODE_02F178:
    STA !OAM_Tile,Y
    PLX
    LDA $07
    ORA $64
    LSR $02
    BCS CODE_02F186
    ORA #$40
CODE_02F186:
    STA !OAM_Prop,Y
    PHY
    TYA
    LSR : LSR
    TAY
    LDA #$02
    STA !OAM_TileSize,Y
    PLY
    INY : INY : INY : INY
    INX                         ;\ 
    CPX $04                     ;| Loop until X = #segments + 1
    ;CPX #$05                   ;| ;Loop until X = 5.
    BNE DrawBodyLoop            ;/

DrawEyes:
    LDX !RAM_CurrentSprIndex    ; Restore X = Sprite index
    LDA $08                     ;\ If not angry, branch.
    BEQ .NotAngry               ;/
    PHX
    LDY !RAM_SprOAMIndex,X      ; Y = Index into sprite OAM
    LDA !RAM_SpriteDir,X
    TAX
    LDA !OAM_Tile2DispX,Y
    CLC : ADC WigglerEyesX,X
    PLX
    STA !OAM_DispX,Y
    LDA !OAM_Tile2DispY,Y
    STA !OAM_DispY,Y
    LDA #$88
    STA !OAM_Tile,Y
    LDA !OAM_Tile2Prop,Y
    BRA CODE_02F1EF

.NotAngry:
    PHX
    LDY !RAM_SprOAMIndex,X      ; Y = Index into sprite OAM
    LDA !RAM_SpriteDir,X
    TAX
    LDA !OAM_Tile2DispX,Y
    CLC : ADC DATA_02F2D3,X
    PLX
    STA !OAM_DispX,Y
    LDA !OAM_Tile2DispY,Y
    SEC : SBC #$08
    STA !OAM_DispY,Y
    LDA #$98
    STA !OAM_Tile,Y
    LDA !OAM_Tile2Prop,Y
    AND #$F1
    ORA #$0A

CODE_02F1EF:
    STA !OAM_Prop,Y
    TYA
    LSR : LSR
    TAY
    LDA #$00
    STA !OAM_TileSize,Y
    LDA #$05
    LDY #$FF
    JSL !FinishOAMWrite
    LDA !RAM_SpriteXLo,X
    STA $00
    LDA !RAM_SpriteXHi,X
    STA $01
    REP #$20                    ; Accum (16 bit)
    LDA $00
    SEC : SBC !RAM_MarioXPos
    CLC : ADC #$0050
    CMP #$00A0
    SEP #$20                    ; Accum (8 bit)
    BCS Return
    LDA !RAM_SpriteStatus,X     ;\ If sprite is not in normal status, return
    CMP #$08                    ;| (don't check for interaction with Mario).
    BNE Return                  ;/

; This loop checks if Mario is touching any of the segments and then acts accordingly.
    ;LDA #$04                    
    LDA !extra_prop_1,x         ;\ Initialize the loop counter.
    STA $00                     ;/
    LDY !RAM_SprOAMIndex,X      ; Y = Index into sprite OAM
WigglerMarioInterLoop:
    LDA !OAM_Tile2DispX,Y       ;\ If the current segment's x position - Mario's
    SEC : SBC $7E               ;| x position (low byte) + $0C (or $0D?) > $18,
    ADC #$0C                    ;| branch (Mario is not touching).
    CMP #$18                    ;|
    BCS NextIteration           ;/
    LDA !OAM_Tile2DispY,Y       ;\ If the current segment's y position - Mario's
    SEC : SBC $80               ;| y position (low byte) (- $10 if Mario is on Yoshi)
    SBC #$10                    ;| + $0C > $18, branch (Mario is not touching).
    PHY                         ;|
    LDY !RAM_OnYoshi            ;|
    BEQ +                       ;|
    SBC #$10                    ;|
+   PLY                         ;|
    CLC : ADC #$0C              ;|
    CMP #$18                    ;|
    BCS NextIteration           ;/
    LDA $1490|!Base2            ;\ If Mario has a star, kill the Wiggler.
    BNE KilledWithStar          ;/
    LDA !RAM_DisableInter,X     ;\ If interaction is disabled, or Mario's Y position's
    ORA $81                     ;| (within the screen) high byte is not 0, they should not interact,
    BNE NextIteration           ;/ so go to the next iteration of the loop.
    LDA #$08
    STA !RAM_DisableInter,X
    LDA !RAM_EnemiesStomped     ;\ If Mario hasn't bounced off of another enemy...
    BNE .MarioBounces           ;|
    LDA !RAM_MarioSpeedY        ;| ...and his Y speed is less than 8...
    CMP #$08                    ;|
    BMI HurtMario               ;/ ...hurt Mario.
.MarioBounces:
    LDA #$03                    ;\ Play sound effect for bouncing on the wiggler.
    STA $1DF9|!Base2            ;/
    JSL !BoostMarioSpeed        ; Give Mario a boost.
    LDA !RAM_IsWigglerAngry,X   ;\ If in angry state...
    ORA !RAM_SprOnYoshiTongue,X ;| ...or on Yoshi's tongue...
    BNE Return                  ;/ ...return.
    JSL !DisplayContactGfx
    LDA !RAM_EnemiesStomped     ;\ Increase the consecutive stomps counter.
    INC !RAM_EnemiesStomped     ;/
    JSL !GivePoints             ; Give those useful points to Mario.
    LDA #$40                    ;\ Wiggler will be stunned for $40 frames.
    STA !RAM_StunAnimTimer,X    ;/
    INC !RAM_IsWigglerAngry,X   ; Now wiggler is angry >:-(
    JSR SpawnFlower             ; Deflower the wiggler ;-)
Return:
    RTS

HurtMario:
    JSL !HurtMario
    RTS

NextIteration:
    INY
    INY
    INY
    INY
    DEC $00                     ;\ Go to the next iteration, or return if loop end.
    BMI +                       ;|
    JMP WigglerMarioInterLoop   ;|
+   RTS                         ;/

KilledWithStar:
    LDA #$02                    ;\ Set sprite status to "killed".
    STA !RAM_SpriteStatus,X     ;/
    LDA #$D0                    ;\ Set Y speed.
    STA !RAM_SpriteSpeedY,X     ;/
    INC !RAM_StarKillCntr       ;\ Give points based on how many enemies have been killed with the star.
    LDA !RAM_StarKillCntr       ;|
    CMP #$09                    ;|
    BCC +                       ;|
    LDA #$09                    ;|
    STA !RAM_StarKillCntr       ;|
+   JSL !GivePoints             ;/
    LDY !RAM_StarKillCntr       ;\ Play a different sound effect based on how many enemies have
    CPY #$08                    ;| been killed with the star.
    BCS +                       ;|
    LDA WigglerSfx,Y            ;|
    STA $1DF9|!Base2            ;/
+   RTS

WigglerSfx:
    db $FF,$13,$14,$15,$16,$17,$18,$19

;===============================;
; Spawn flower routine          ;
;===============================;
SpawnFlower:
    LDY #$07                    ;\ Find a free extended sprite slot...
.ExtendedLoop:                  ;|
    LDA !RAM_ExSpriteNum,Y      ;|
    BEQ .ExtendedSlotFound      ;|
    DEY                         ;|
    BPL .ExtendedLoop           ;|
    RTS                         ;/ ...and return if no free slots.

.ExtendedSlotFound:
    LDA #$0E                    ;\ Extended sprite = Wiggler flower
    STA !RAM_ExSpriteNum,Y      ;/
    ;LDA #$01                   ;\ ??? It's not used by the flower.
    ;STA $1765|!Base2,Y         ;/
    LDA !RAM_SpriteXLo,X        ;\ All the flower's positions are equal to the
    STA !RAM_ExSpriteXLo,Y      ;| wiggler's head position.
    LDA !RAM_SpriteXHi,X        ;|
    STA !RAM_ExSpriteXHi,Y      ;|
    LDA !RAM_SpriteYLo,X        ;|
    STA !RAM_ExSpriteYLo,Y      ;|
    LDA !RAM_SpriteYLo,X        ;|
    STA !RAM_ExSpriteYHi,Y      ;/
    LDA #$D0                    ;\ Set the flower Y speed.
    STA !RAM_ExSprSpeedY,Y      ;/
    LDA !RAM_SpriteSpeedX,X     ;\ Flower X speed = -(Wiggler X speed)
    EOR #$FF                    ;|
    INC A                       ;|
    STA !RAM_ExSprSpeedX,Y      ;/
    RTS

;===============================;
; Subroutines                   ;
;===============================;

; Routine to make the sprite face Mario.
; Writes to !RAM_SpriteDir,x:
;  - 0 if Mario is on the right of the sprite
;  - 1 if Mario is on the left of the sprite
UpdateSpriteDir:
    LDY #$00
    LDA !RAM_MarioXPos
    SEC : SBC !RAM_SpriteXLo,X
    STA $0F
    LDA !RAM_MarioXPosHi
    SBC !RAM_SpriteXHi,X
    BPL +
    INY
+   TYA
    STA !RAM_SpriteDir,x
    RTS

; Routine that makes $D5 point to the correct place in the table at $7F9A7B ($418800 if SA-1).
; It can write 4 different addresses based on the last 2 digits of the wiggler's slot X:
;  - 00: $7F9A7B ($418800)
;  - 01: $7F9AFB ($418880)
;  - 10: $7F9B7B ($418900)
;  - 11: $7F9BFB ($418980)
; So basically it allocates 128 bytes for each wiggler.
WritePointer:
    TXA
    AND #$03
    TAY
    LDA #!SegTableLow
    CLC : ADC .Offset1,Y
    STA !RAM_SegmentsPntr
    LDA #!SegTableMid
    ADC .Offset2,Y
    STA !RAM_SegmentsPntr+1
    LDA #!SegBank
    STA !RAM_SegmentsPntr+2
    RTS

.Offset1:
    db $00,$80,$00,$80

.Offset2:
    db $00,$00,$01,$01

; The first part of the routine takes the first 126 bytes in the segments
; table and "shifts" them two bytes to the right.
; The second part stores the X and Y position of the wiggler in the first
; two bytes of the table (which were "allocated" in the first part).
UpdateSegmentsPos:
    PHX                         ;\ Push X.
    PHB                         ;| Push bank.
    REP #$30                    ;| A,X,Y (16 bit)
    LDA !RAM_SegmentsPntr       ;|\
    CLC : ADC #$007D            ;|| X = src addr = $9A7B + $7D = $9AF8
    TAX                         ;|/
    LDA !RAM_SegmentsPntr       ;|\
    CLC : ADC #$007F            ;|| Y = dst addr = $9A7B + $7F = $9AFA
    TAY                         ;|/
    LDA #$007D                  ;| A = number of transfers = #$007D
    MVP !SegBank,!SegBank       ;| src->dst in bank = $7F ($41 if SA-1) until A = #$FFFF
    SEP #$30                    ;| A,X,Y (8 bit)
    PLB                         ;| Restore bank.
    PLX                         ;/ Restore X.
    LDY #$00                    ;\ Store the X and Y position in the
    LDA !RAM_SpriteXLo,X        ;| first two bytes.
    STA [!RAM_SegmentsPntr],Y   ;|
    LDA !RAM_SpriteYLo,X        ;|
    INY                         ;|
    STA [!RAM_SegmentsPntr],Y   ;/
    RTS
