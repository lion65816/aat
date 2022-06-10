main:
	LDA $13D4|!addr		; Is level paused ?
	ORA $1426|!addr		; Is a message box active ?
	ORA $9D				; Are sprites and animations locked ?
	BNE .return			; Cuz' if yes, return.
	LDA $75		; Is Mario in water ?
	BEQ .return	; Cuz' if not, return.
	LDA $77		; \ Is Mario touching the ground ?
	AND #$04	; /
	BNE .return	; Cuz' if he is, return.
	LDA #$80		; \ Disable any first frame input B.
	TRB $16			; /
	LDA $187A|!addr	; Is Mario riding Yoshi ?
	BNE .return		; Cuz' if yes, that's all.
	LDA #$80		; \ Otherwise, also disable first frame input A.
	TRB $18			; /
.return:
	RTL