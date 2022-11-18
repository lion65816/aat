; Activate keyhole when touched, even without a key.
; Keyhole code taken from Password System UberASM (by Nowieso).

db $42				; or db $37
JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody	; when using db $37

BodyInside:
HeadInside:
	REP #$20
	LDA $1A			; Layer 1 X position
	CLC
	ADC #$002A
	STA $1436|!addr		; Keyhole X position
	LDA $1C			; Layer 1 Y position
	CLC
	ADC #$0080
	STA $1438|!addr		; Keyhole Y position
	SEP #$20
	;LDA #$0F		; keyhole SFX (without AddmusicK)
	LDA #$07		; keyhole SFX (with AddmusicK)
	STA $1DFB|!addr		; keyhole SFX Bank
	LDA #$30
	STA $1434|!addr	

;WallFeet:			; when using db $37
;WallBody:

Mario:
	RTL

print "Activate keyhole when touched, even without a key."
