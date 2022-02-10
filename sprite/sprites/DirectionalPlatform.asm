;===============================================================================;
; SMB3-like Directional Platform                                                ;
;   by KevinM                                                                   ;
;   optimized by Ice Man                                                        ;
; Description: a semisolid platform that starts moving in a certain direction   ;
;   when Mario steps on it, and then it changes direction every time Mario      ;
;   steps on it again. The current direction is shown by an arrow in the center ;
;   of the platform. It doesn't interact with other sprites or with objects.    ;
;                                                                               ;
; Usage:                                                                        ;
;   - If you want to tweak some properties, you can do by editing the values in ;
;     the next section.                                                         ;
;   - If you want it to use a different palette row, edit the "F1" value in the ;
;     cfg file (3rd number in 3rd row) to one of these values: F1, F3, F5, F7,  ;
;     F9, FB, FD, FF.                                                           ;
;   - Insert the sprite(s) with PIXI (there are 3 cfg files: the number in      ;
;     their name coincides with the tile length of the platform).               ;
;   - You can set the disappearing timer directly in LM using the "extension"   ;
;     field when you insert or edit the sprite. The value you write in that     ;
;     field will be equal to the timer (ranges from 0000 to FFFF). 0000 will    ;
;     make the platform never disappear.                                        ;
;   - Insert the ExGFX files provided. They contain the SMB3 plaforms gfx and   ;
;     the arrow GFX. ExGFX112 must be used in place of GFX12, and ExGFX113 in   ;
;     place of GFX13 (so you'll either use SP3 112 or SP3 113).                 ;
;     NOTE: the arrow gfx overrides some vanilla tiles (the yoshi eggs gfx in   ;
;     112, and part of the net sprite gfx in 113), so you won't be able to use  ;
;     them with these platforms.                                                ;
;                                                                               ;
; Uses extra bit: YES                                                           ;
;   - If the extra bit is not set, the disappear timer will always tick after   ;
;     Mario activates the platform.                                             ;
;   - If the extra bit is set, the disappear timer will only tick when Mario    ;
;     isn't touching the platform, and will reset when it touches it again.     ;
;                                                                               ;
; Extry Byte 1: defines intial direction it goes in. Valid values from 01-04    ;
; right = #$01 / left = #$02 / down = #$03 /up = #$04                           ;
; Extra Bytes 2&3: they define the low and high byte of the platform timer.     ;
;                                                                               ;
; Extra Property Byte 1: number of tiles of the platform - 2 (it's already set  ;
;   in the cfg files provided).                                                 ;
;===============================================================================;


;==============================;
; DEFINES                      ;
; You can change these values! ;
;==============================;

;Tilemaps
	!arrow_tile_horizontal	= $02
	!arrow_tile_vertical 	= $00

	!platform_tile_left		= $60
	!platform_tile_middle	= $61
	!platform_tile_right	= $62

; X and Y speeds.
    !xspeeds            = $0C,$F4
    !yspeeds            = $0C,$F4

; This sets the next moving direction when Mario jumps on the platform again.
; DONT TOUCH!
    !nextDirections     = !up,!down,!right,!left

;=====================;
; DEFINES             ;
; Don't change these! ;
;=====================;

!right  = #$01
!left   = #$02
!down   = #$03
!up     = #$04

; Two miscellaneous sprite tables used to store the directions of the various platforms.
!directionRAM       = !1504
!nextDirectionRAM   = !1510

; Miscellaneous sprite table used to store the timers of the various platforms.
!timerLowRAM        = !151C
!timerHighRAM       = !1534

; If the timer is 00, this is set to 0, else this is set to 1.
!shouldDisappear    = !157C

!spriteXSpeed       = !B6
!spriteYSpeed       = !AA

!UpdateXRoutine     = $018022|!BankB
!UpdateYRoutine     = $01801A|!BankB
!MakeSolidRoutine   = $01B44F|!BankB

;============;
;    CODE    ;
;============;

print "INIT ",pc
    STZ !shouldDisappear,x
    LDA !extra_byte_2,x         ;\ Set the timer for later.
    STA !timerHighRAM,x         ;|
    LDA !extra_byte_3,x         ;|
    STA !timerLowRAM,x          ;/
    LDA !timerHighRAM,x         ;\
    ORA !timerLowRAM,x          ;|
    BEQ +                       ;|
    INC !shouldDisappear,x      ;/ If the timer is not 0, set this to 1.
+   STZ !directionRAM,x

	LDA !extra_byte_1,x         ;|
    STA !nextDirectionRAM,x
    CMP #$03                    ;\ Store the arrow tile to draw based on the
    BCS +                       ;| initial direction.
    LDA #!arrow_tile_horizontal ;| Arrow Horizontal
    BRA ++                      ;|
+   LDA #!arrow_tile_vertical   ;| Arrow Vertical
++  STA !1602,x                 ;/
    RTL

print "MAIN ",pc
    PHB
    PHK
    PLB
    JSR Main   ; Call local subroutine.
    PLB
    RTL

XSpeed:
    db !xspeeds

YSpeed:
    db !yspeeds

NextDirectionVector:
    db !nextDirections


;============;
;    Main    ;
;============;

Return2:
    RTS

Main:
    JSR.w Graphics              ; Always draw graphics for the sprite.
    LDA !14C8,x                 ;\
    EOR #$08                    ;|
    ORA $9D                     ;| If sprites are locked, return.
    BNE Return2                 ;/
    LDA #$00
    %SubOffScreen()
    LDA !directionRAM,x         ;\ If sprite is stationary, branch.
    BEQ MakeSolid               ;/

CheckTimer:
    LDA !shouldDisappear,x      ;\ If the platform should not disappear, branch.
    BEQ UpdatePosition          ;/
    LDA !timerHighRAM,x         ;\\ If the timer reached 0...
    ORA !timerLowRAM,x          ;|/
    BNE .tickTimer              ;|
    STZ !14C8,x                 ;| ...remove the sprite...
    BRA Return2                 ;/ ...and return.
.tickTimer                      ; Tick the timer.
    LDA !timerLowRAM,x
    BEQ +
    DEC !timerLowRAM,x
    BRA UpdatePosition
+   LDA #$FF
    STA !timerLowRAM,x
    DEC !timerHighRAM,x

UpdatePosition:
    LDA !directionRAM,x         ;\ Check which is the current direction...
    CMP #$03                    ;|
    BCS .updateY                ;/ ...and branch if it's up or down.
.updateX
    STZ !spriteYSpeed,x         ; Set Y speed to 0
    PHY
    LDY !directionRAM,x         ;\ Load the correct X speed value.
    DEY                         ;|
    LDA XSpeed,y                ;/
    PLY
    STA !spriteXSpeed,x         ;\ Update the X speed and position.
    JSL.l !UpdateXRoutine       ;/
    STA !1528,x                 ; Prevent Mario from sliding horizontally.
    BRA MakeSolid
.updateY
    STZ !spriteXSpeed,x         ; Set X speed to 0
    PHY
    LDY !directionRAM,x         ;\ Load the correct X speed value.
    DEY #3                      ;|
    LDA YSpeed,y                ;/
    PLY
    STA !spriteYSpeed,x         ;\ Update the Y speed and position.
    STZ !1528,x                 ; Prevent Mario from sliding horizontally.
    JSL.l !UpdateYRoutine       ;/

MakeSolid:
    LDA $77                     ;\ If Mario is touching the ceiling,
    AND #%00001000              ;|
    BNE Return                  ;/ don't make the platform solid.
    LDA !extra_bits,x           ;\ Never reset the timer if the extra bit is clear.
    AND #$04                    ;|
    BNE +                       ;/
    JSL.l !MakeSolidRoutine
    BCC NotTouching
    BRA .isOnTop
+   JSL.l !MakeSolidRoutine     ;\ Make the sprite "solid"...
    BCC NotTouching             ;/ ...and if Mario is not touching, branch.
.resetTimer
    LDA !extra_byte_2,x         ;\ When Mario is on top of the platform, reset
    STA !timerHighRAM,x         ;| the timer (if the extra bit is set).
    LDA !extra_byte_3,x         ;|
    STA !timerLowRAM,x          ;/
.isOnTop
    LDA !nextDirectionRAM,x     ;\ Store the current direction.
    BEQ Return                  ;|
    STA !directionRAM,x         ;/
    CMP #$03                    ;\ Store the arrow tile to draw based on the
    BCS +                       ;| direction.
    LDA #!arrow_tile_horizontal ;| Arrow Horizontal
    BRA ++                      ;|
+   LDA #!arrow_tile_vertical   ;| Arrow Vertical
++  STA !1602,x                 ;/
    STZ !nextDirectionRAM,x     ; Set next direction to 0 to skip this next time.
    BRA Return

NotTouching:
    LDA !nextDirectionRAM,x     ;\ If next direction was already set, return.
    BNE Return                  ;/
    LDA !directionRAM,x         ;\ Store the next direction in the address.
    BEQ Return                  ;|
    PHY                         ;|
    TAY                         ;|
    DEY                         ;|
    LDA NextDirectionVector,y   ;|
    STA !nextDirectionRAM,x     ;|
    PLY                         ;/

Return:
    RTS


;================;
;    Graphics    ;
;================;

XDisp:
    db $00,$10,$20,$30

ArrowProps:
    db $63,$23,$A3,$63          ; right,left,down,up (also contains palette date for the arrows)

ArrowXDisp:
    db $08,$10,$18


Graphics:
    LDA !shouldDisappear,x  ;\ If the platform should not disappear, always draw it.
    BEQ .draw               ;/
    LDA !directionRAM,x     ;\ If the platform is still...
    BEQ .draw               ;|
    LDA !timerHighRAM,x     ;|\ ...or the timer is not close to ending...
    BNE .draw               ;||
    LDA !timerLowRAM,x      ;||
    CMP #$30                ;|/
    BCS .draw               ;/ ...draw the platform.
    AND #$03                ;\ Else, don't draw the platform every 3 frames.
    CMP #$03                ;|
    BEQ Return              ;/

.draw
    %GetDrawInfo()
    LDA !extra_prop_1,x     ;\ Store the amount of tiles to draw (not including the arrow).
    AND #$07                ;|
    CLC : ADC #$02          ;|
    STA $03                 ;/

    LDA !1602,x
    STA $0302|!Base2,y
    LDA !directionRAM,x
    BNE .isMoving           ;\ If the platform is still, use the initial
    LDA !extra_byte_1,x     ;/ direction to draw the arrow.

.isMoving
    PHX
    TAX
    DEX
    LDA ArrowProps,x
    STA $0303|!Base2,y

    LDX $03             ;\ Store the x and y displacement.
    DEX #2              ;|
    LDA ArrowXDisp,x    ;|
    STA $05             ;|
    STZ $06             ;/
    REP #$20
    LDA $00
    ADC $05             ; No CLC here.
    STA $0300|!Base2,y
    SEP #$20
    PLX

    TYA
    ADC #$04        ; No CLC here.
    TAY

    LDA #!platform_tile_right		; Platform Right
    STA $04         ; $04 contains and keeps track of the graphic to draw.

    LDA !15F6,x
    STA $05         ; Copy of $15F6,x -- Sprite properties

    LDX $03         ; Load the number of platform tiles to draw.
-	DEX
    BMI ++
    BNE +

    LDA #!platform_tile_left		; Platform Left
    STA $04

 +	LDA $00
    ADC XDisp,x     ; No CLC here.
    STA $0300|!Base2,y

    LDA $01
    STA $0301|!Base2,y

    LDA $04
    STA $0302|!Base2,y

    LDA $05
    ORA $64
    STA $0303|!Base2,y

    LDA #!platform_tile_middle		; Platform Middle
    STA $04

    INY #4

    BRA -

++	LDX $15E9|!Base2    ; Get sprite slot back.
    LDA $03             ; Tiles to draw
    LDY #$02            ; 16x16
    JSL $01B7B3|!BankB  ; Finish OAM Write
    RTS                 ; Return.
