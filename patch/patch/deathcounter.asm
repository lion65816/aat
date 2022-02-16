	!700000 = $700000
	!addr = $0000
if read1($00FFD5) == $23
	sa1rom
	!700000 = $41C000
	!addr = $6000
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this part is from Iceguy's Disable Score patch
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $028766
	NOP #3

org $02AE21
	NOP #3   
	LDA $0F35|!addr,x 	;score adding?
	ADC $AD89|!addr,y
	NOP #3

org $05CEF9
	NOP #12			;disable score from adding at level end.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; everything after here is coded by yoshicookiezeus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $00A0A0				; original code:
	autoclean JSL DeathReset	; STZ.W $1F11
	NOP				; LDA.B #$F0   


org $008EC6				; original code:
	autoclean JSL NewScoreUpload	; LDA.W $0F36
	NOP #11				; STA $00
					; STZ $01
					; LDA.W $0F35
					; STA $03
					; LDA.W $0F34

org $008EF4				; original code:
	JSL NewScoreUpload		; LDA.W $0F39
	NOP #11				; STA $00
					; STZ $01
					; LDA.W $0F38
					; STA $03
					; LDA.W $0F37
	

org $00F60F				; original code:
	autoclean JSL IncreaseDeaths	; LDA.B #$FF
	NOP				; STA.W $0DDA

freecode
DeathReset:
	PHX
	LDA $010A|!addr
	ASL
	CLC
	ADC $010A|!addr
	TAX
	LDA #$00
	STA !700000+$07ED,x
	STA !700000+$07EE,x
	STA !700000+$07EF,x
	PLX

	STZ $1F11|!addr		; \ restore original code
	LDA #$F0		; /

	RTL

NewScoreUpload:
	PHX
	LDA $010A|!addr
	ASL
	CLC
	ADC $010A|!addr
	TAX
	LDA !700000+$07EF,x	; \ Store high byte of Mario's score in $00
	STA $00			; /
	STZ $01			; Store x00 in $01
	LDA !700000+$07EE,x	; \ Store mid byte of Mario's score in $03
	STA $03			; /
	LDA !700000+$07ED,x	; \ Store low byte of Mario's score in $02
	PLX
	RTL

IncreaseDeaths:
	PHX
	LDA $010A|!addr
	ASL
	CLC
	ADC $010A|!addr
	TAX
	REP #$20		; set 16-bit accumulator
	LDA !700000+$07ED,x	; \ increase death counter by one
	CLC			; |
	ADC #$0001		; |
	STA !700000+$07ED,x	; /
	SEP #$20		; 8-bit accumulator
	LDA !700000+$07EF,x	; \ if carry flag set, increase high byte of death counter by one
	ADC #$00		; |
	STA !700000+$07EF,x	; /
	PLX

	LDA #$FF		; \ restore original code
	STA $0DDA|!addr		; /

	RTL