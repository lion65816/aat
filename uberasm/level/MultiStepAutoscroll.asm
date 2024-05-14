;========================================================
; M U L T I - S T E P     A U T O S C R O L L
; by Mathos
;
; An autoscroll code that use tables to determine
; how it precisely behave. You can make it go
; where you want, for the time you want, by using
; multiples steps.
; To start/resume it, store a non-zero value to !PFlag
; To pause/end it, store zero to !PFlag
; Note that when the code reaches the end of the table,
; it behaves according to what's in the "!Loop" define:
; 0			- the code sets itself the flag to end scrolling
; non-zero	- the code reset the table index and thus make
;			  everything loop.
;
; ---TableXSpeed & TableYSpeed---
; 1) These are 16-bit (negative speeds are from $8000 to $FFFF)
; 2) These are fractional: the most significant byte holds a px/s
; value, while the less significant byte holds a 255th-of-px/s value.
; EXAMPLE: $0180 is actually 1.5px/s
; EXAMPLE: $FF80 is actually -0.5px/s
;
; ---TableTime---
; Time (in frames) at which step execution will occur. MUST be non-zero.
; IT IS NOT THE DUARTION OF THE STEP IN FRAMES, BUT REALLY THE VALUE
; OF TIME THAT WILL MARK ITS BEGINNING.
;
; ---CheckProgress---
; This routine is run every time the timer reaches a value in
; TableStops. IT INTERRUPTS THE MULTI-STEP AUTOSCROLL UNTIL
; IT ENDS WITH A BEING 8-BIT AND NON-ZERO.
;========================================================
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Aimed Bullet/Eerie Generator, by yoshicookiezeus
;; based on mikeyk's generic.asm
;;
;; Continuously generates sprites at Mario's height from the direction
;; he is facing.
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    !SpriteToGen        = $1C   ; USE $1C for bullet bills, $38 for eeries
    !TimeBetweenSpawns  = $7F   ; needs to be one less than a power of 2
                                ; recommended: $7F for bills, $3F for eeries

    !RAM_ScreenBndryXLo = $1A
    !RAM_ScreenBndryXHi = $1B
    !RAM_ScreenBndryYLo = $1C
    !RAM_ScreenBndryYHi = $1D
    !RAM_MarioDirection = #$01
    !RAM_MarioYPos      = $96
    !RAM_MarioYPosHi    = $97
    !RAM_SpritesLocked  = $9D

!Loop = 0               ; Make the code loop (0 = off, 1 = on)

!StepEntries = $0002	; Number of step entries
!StopEntries = $0001	; Number of stop entries (put $0000 to disable stop function)

!Timer = $18C5|!addr	; 2 consecutives bytes of free, unmodified RAM
!Track = $18C7|!addr	; 2 consecutives bytes of free, unmodified RAM
!FPosX = $18C9|!addr	; 1 byte of free, unmodified RAM
!FPosY = $18CA|!addr	; 1 byte of free, unmodified RAM
!CalcA = $18CB|!addr	; 2 consecutives bytes of scratch RAM
!PFlag = $1908|!addr	; 1 byte of free, unmodified RAM

; Needs to be the same free RAM address as in RequestRetry.asm.
!RetryRequested = $18D8|!addr

TableXSpeed:
dw $0200,$8001

TableYSpeed:
dw $0020,$8001

TableTime:
dw $0000,$0220

TableStops:
dw $0B80

;----------------------------------------------------------------------------- CHECK PROGRESS CODE BELOW

!Sound = $29      ; sound to play when all enemies on screen are killed
!SBank = $1DFC|!addr
IgnoreList:       
db $0E,$21,$2C,$2D,$2F,$35,$3E,$41,$42,$43,$45,$49,$4A,$52,$54,$55
db $56,$57,$58,$59,$5B,$5C,$5D,$5E,$5F,$60,$61,$62,$63,$64,$6A,$6B
db $6C,$6D,$74,$75,$76,$77,$78,$79,$7A,$7B,$7D,$7E,$7F,$80,$81,$83
db $84,$87,$8A,$8B,$8D,$8E,$8F,$9C,$A3,$B1,$B2,$B7,$B8,$B9,$BA,$BB
db $C0,$C1,$C4,$C6,$C7,$C8,$E0
!ListLength = $47 ; number of items in list in hex

CheckProgress:
        RTS

;----------------------------------------------------------------------------- ACTUAL CODE BELOW (NO TOUCH)

init:
	JSL RequestRetry_init
	JSL MultipersonReset_init

	STZ $1411|!addr
	STZ $1412|!addr
	REP #$20
	STZ !Timer
	STZ !Track
	SEP #$20
	STZ !FPosX
	STZ !FPosY
	LDA #$01
	STA !PFlag
main:
    LDA $14                     ;\  if not time to spawn sprite
    AND #!TimeBetweenSpawns     ; |
    ORA !RAM_SpritesLocked      ; | or if sprites locked,
    BNE .Return                 ;/  branch
    JSL $02A9DE                 ;\  find empty sprite slot
    BMI .Return                 ;/  if no slot found, return
    TYX        
    
    LDA #!SpriteToGen           ;\  set new sprite number
    STA !9E,x                   ;/
    JSL $07F7D2                 ; reset sprite properties
    LDA #$08                    ;\  set new sprite status
    STA !14C8,x                 ;/

JSL $07F7D2|!bank		;Initial table set
JSL $01ACF9|!bank		;Random Number

    PHA				;\
AND #$7F			;|
ADC #$20			;|
ADC $1C				;|
AND #$F0			;|Set sprite's Y Position
STA !D8,x			;|
LDA $1D				;|
ADC #$00			;|
STA !14D4,x			;|
PLA				;/

    LDA !RAM_MarioDirection     ;\ use the direction Mario is facing
    TAY                         ;/ to determine sprite direction
    LDA .OffsetXLo,y            ;\  use direction to determine x offset
    CLC                         ; |
    ADC !RAM_ScreenBndryXLo     ; | add screen position
    STA !E4,x                   ; | and set as sprite x position
    LDA !RAM_ScreenBndryXHi     ; |
    ADC .OffsetXHi,y            ; |
    STA !14E0,x                 ;/
    if !SpriteToGen == $1C
        LDA .Dir,y              ;\ set sprite direction
        STA !C2,x               ;/
        LDA #$09                ;\ play sound effect
        STA $1DFC|!addr         ;/
    endif
    if !SpriteToGen == $38
        LDA .SpeedX,y           ;\ set sprite speed
        STA !B6,x               ;/
    endif
.Return:
    ; Exit out of SPECIAL rooms with a special button combination (A+X+L+R).
    LDA #%11110000 : STA $00
    JSL RequestRetry_main
    LDA !RetryRequested
    BNE .end

    ; Otherwise, the SPECIAL rooms will reload upon death.
    LDA $010B|!addr
    STA $0C
    LDA $010C|!addr
    ORA #$04
    STA $0D
    JSL MultipersonReset_main

	LDA !PFlag
	BEQ .end
	LDA $13D4|!addr
	ORA $1493|!addr
	ORA $9D
	BNE .end
if !StopEntries != $0000
    REP #$30
    LDX #$0000
    .Looping:
    LDA !Timer
    CMP TableStops,x
    BEQ .DoTheCheck
	INX
    INX
    CPX.w #((!StopEntries)*2)
    BNE .Looping
    BRA .AfterCheck
    .DoTheCheck:
    SEP #$30
    JSR CheckProgress
    BEQ .end
    REP #$30
    .AfterCheck:
    SEP #$30
endif
	JSR .DoX
	JSR .DoY
	JSR .CoM
	
	REP #$30	; \ set step index
	LDA !Track	; |
	ASL			; |
	TAY			; /
	INC !Timer		; \ if step finished,
	LDA !Timer		; |
	CMP TableTime,y	; | prepare for next one
	BNE .nonext		; |
	INC !Track		; |
	LDA !Track		; |
	CMP #!StepEntries ;
	BCC .nonext		; /
    STZ !Timer
	SEP #$30
	        LDA #01
        STA $9D

    if !Loop == 0
        STZ !PFlag		; if all steps finished, set flag
    else
        STZ !Track		; or loop autoscroll
    endif
	RTL	
	.nonext:
	SEP #$30
	
	.end:
	
	RTL

	
	
.DoX:
	REP #$30	; \ set step index
	LDA !Track	; |
	ASL			; |
	TAY			; /
	LDA TableXSpeed,y	; \ handle according to sign
	BMI ..HandleXN		; /
	..HandleXP:
	LDA TableXSpeed,y	; \ get high byte as low
	XBA					; |
	AND #$00FF			; /
	CLC					; \ add speed
	ADC $1462|!addr		; |
	STA $1462|!addr		; /
	SEP #$20			; A back to 8-bit
	LDA TableXSpeed,y	; \ get fraction
	STA !CalcA			; /
	CLC					; \ add to fraction pos
	ADC !FPosX			; |
	STA !FPosX			; /
	CMP !CalcA		; \ if went far enough, add one
	BCS ..EndX		; |
	REP #$20		; |
	INC $1462|!addr	; |
	SEP #$20		; /
	BRA ..EndX		; branch to end
	..HandleXN:
	LDA TableXSpeed,y	; \ get high byte as low
	XBA					; |
	AND #$00FF			; /
	ORA #$FF00			; negative again
	CLC					; \ add speed
	ADC $1462|!addr		; |
	STA $1462|!addr		; /
	INC $1462|!addr		; fix negative
	SEP #$20			; A back to 8-bit
	LDA TableXSpeed,y	; \ get fraction
	STA !CalcA			; /
	CLC					; \ add to fraction pos
	ADC !FPosX			; |
	STA !FPosX			; /
	CMP !CalcA		; \ if went far enough, sub one
	BCC ..EndX		; |
	REP #$20		; |
	DEC $1462|!addr	; |
	SEP #$20		; /
	..EndX:
	SEP #$10			; X/Y back to 8-bit
	RTS
	
	
	
.DoY:
	REP #$30	; \ set step index
	LDA !Track	; |
	ASL			; |
	TAY			; /
	LDA TableYSpeed,y	; \ handle according to sign
	BMI ..HandleYN		; /
	..HandleYP:
	LDA TableYSpeed,y	; \ get high byte as low
	XBA					; |
	AND #$00FF			; /
	CLC					; \ add speed
	ADC $1464|!addr		; |
	STA $1464|!addr		; /
	SEP #$20			; A back to 8-bit
	LDA TableYSpeed,y	; \ get fraction
	STA !CalcA			; /
	CLC					; \ add to fraction pos
	ADC !FPosY			; |
	STA !FPosY			; /
	CMP !CalcA		; \ if went far enough, add one
	BCS ..EndY		; |
	REP #$20		; |
	INC $1464|!addr	; |
	SEP #$20		; /
	BRA ..EndY		; branch to end
	..HandleYN:
	LDA TableYSpeed,y	; \ get high byte as low
	XBA					; |
	AND #$00FF			; /
	ORA #$FF00			; negative again
	CLC					; \ add speed
	ADC $1464|!addr		; |
	STA $1464|!addr		; /
	INC $1464|!addr		; fix negative
	SEP #$20			; A back to 8-bit
	LDA TableYSpeed,y	; \ get fraction
	STA !CalcA			; /
	CLC					; \ add to fraction pos
	ADC !FPosY			; |
	STA !FPosY			; /
	CMP !CalcA		; \ if went far enough, sub one
	BCC ..EndY		; |
	REP #$20		; |
	DEC $1464|!addr	; |
	SEP #$20		; /
	..EndY:
	SEP #$10			; X/Y back to 8-bit
	RTS
	
.CoM:
	REP #$20	; A is 16-bit
	LDA $1462|!addr		; \ handle left wall
	CLC					; |
	ADC #$000A			; |
	CMP $94				; |
	BCC ..NotTooLeft	; |
	STA $94				; |
	..NotTooLeft:		; /
	LDA $1462|!addr		; \ handle right wall
	CLC					; |
	ADC #$00EA			; |
	CMP $94				; |
	BCS ..NotTooRight	; |
	STA $94				; |
	..NotTooRight:		; /
	SEP #$20	; A back to 8-bit
	RTS
	
.OffsetXLo: db $F0,$FF
.OffsetXHi: db $FF,$00
.Dir:       db $00,$01
.SpeedX:    db $10,$F0
