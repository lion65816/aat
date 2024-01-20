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
!Loop = 1               ; Make the code loop (0 = off, 1 = on)

!StepEntries = $0001	; Number of step entries
!StopEntries = $0000	; Number of stop entries (put $0000 to disable stop function)

!Timer = $13E6|!addr	; 2 consecutives bytes of free, unmodified RAM
!Track = $1B97|!addr	; 2 consecutives bytes of free, unmodified RAM
!FPosX = $1923|!addr	; 1 byte of free, unmodified RAM
!FPosY = $1924|!addr	; 1 byte of free, unmodified RAM
!CalcA = $1926|!addr	; 2 consecutives bytes of scratch RAM
!PFlag = $1929|!addr	; 1 byte of free, unmodified RAM

TableXSpeed:
dw $0200

TableYSpeed:
dw $0010

TableTime:
dw $0000,$0020,$0030,$0040

TableStops:
dw $0020

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
    LDY.b #(!sprite_slots-1) ;\ Check if any sprites on screen
    .loop;
    LDA !14C8,y        ;|
    CMP #$08           ;|
    BNE .skip3
    LDX.b #!ListLength
    .loop2:
    LDA !9E,y        ;\ Do not stop scrolling if sprite is
    CMP IgnoreList,x   ;| in ignore list
    BEQ .skip5          ;|
    DEX                ;|
    BPL .loop2          ;/
    BRA .skip4
    .skip5:
    TYX                ;\ make sure it's not a custom sprite
    LDA !7FAB10,x  ;| this will not ignore custom sprites
    CMP #$02           ;|
    BCC .skip3          ;/
    .skip4:
    LDA !14E0,y        ;\ make sure sprite is actually on screen (killable)
    XBA                ;|
    LDA !E4,y          ;|
    REP #$20           ;|
    SEC                ;|
	SBC $1462|!addr    ;|
    CMP #$0100         ;|
    SEP #$20           ;|
    BCS .skip3         ;|
    LDA #$00           ;/
    RTS
    .skip3:
    DEY                ;\ branch up if loop not finished
    CPY #$00
    BPL .loop          ;/
    LDA.b #!Sound        ;\ Timer has run out
    STA !SBank         ;| play sound effect
    LDA #$01
    RTS

;----------------------------------------------------------------------------- ACTUAL CODE BELOW (NO TOUCH)

init:
	STZ $1411|!addr
	STZ $1412|!addr
	REP #$20
	STZ !Track
	STZ !Timer
	STZ !FPosX
	STZ !FPosY
	SEP #$20
	LDA $01
	STA !PFlag
main:
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
	
	