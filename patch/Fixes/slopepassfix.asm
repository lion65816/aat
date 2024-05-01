; Slope Pass Glitch Fix 2.1 by lolcats439 (SA-1/SuperFX hybrid by LDA)
; This patch fixes the glitch that lets Mario pass through slopes by flying/jumping/swimming through them at a shallow angle.

; The actual fix is a single hex edit, but there's a side effect, it then doesn't let you jump up
; through a slope normally, it will stick you to it and zero your y speed, which is annoying and
; probably the reason Nintendo made the code only run if moving up in the first place.
; This patch works around that by not running the slope assist code when Mario is moving at a
; shallower angle than the slope itself, so you can jump up through it but not glitch under it.


!addr = $0000
!sa1 = 0
!gsu = 0
if read1($00FFD6) == $15
	sa1rom ; sfxrom doesn't work because asar is drunk
	!addr = $6000
	!gsu = 1
elseif read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!sa1 = 1
endif

org $00EE87					;\ Fix the glitch
	db $80					;/

org $00EED1
	autoclean JML FixSideEffect
	NOP

freecode
FixSideEffect: 
	LDA $00					;\ Use $00 as scratch RAM
	PHA						;|
	PHX						;/
	LDA $7D					;\ If Mario moving down, return
	BPL Return				;/
	TYX						;\ Load what type of slope this is
	LDA $00E53D,x			;/
	CMP #$00				;\ If not on a slope, return
	BEQ Return				;/
	AND #$80				;\ If Mario moving opposite the direction the slope faces, 
	STA $00					;| return
	LDA $7B					;|
	BEQ DontStickToSlope	;|
	AND #$80				;|
	CMP $00					;|
	BEQ DontStickToSlope	;/
	LDA $00E53D,x			;\ Store slope type as positive number to X
	BPL Skip1				;|
	EOR #$FF				;|
	INC A					;|
Skip1:						;|
	TAX						;/
	LDA $7D					;\ Load y-speed, flip it to positive and store it to $00
	EOR #$FF				;|
	STA $00					;/
	LDA $7B					;\ Load x-speed, flip it to positive
	BPL Skip2				;|
	EOR #$FF				;|
Skip2:						;/
	CPX #$02				;\ Normalize the ratio of x-speed:y-speed to assume a 45 degree angle
	BEQ Normal				;| for all slopes to simplify calculation
	CPX #$03				;|
	BEQ Compare				;|
	CPX #$04				;|
	BEQ VerySteep			;|
	LSR A					;|
Normal:						;|
	LSR A					;|
	BRA Compare				;|
VerySteep:					;|
	LSR $00					;/
Compare:					;\ If normalized x/y speed less than x speed, return
	CMP $00					;| Mario is moving at a shallower angle than the slope
	BCS Return				;/ so stick him to it
DontStickToSlope:
	PLX						;\ Restore value of $00 and X
	PLA						;|
	STA $00					;/
	LDA #$00				;\ Zero A, X, and Y before skipping code
	LDX #$00				;|
	LDY #$00				;|
	JML $00EF98				;| Jump to the RTS at the end of the codepath
Return:						;/
	PLX						;\ Restore value of $00 and X
	PLA						;|
	STA $00					;/
	INC $13EF|!addr			;\ Restore overwritten code
	LDA $96					;|
	JML $00EED6				;/ Jump to the line right after the LDA $96