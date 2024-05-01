load:
	JSL FilterYoshi_load
	RTL
	
main:
	LDA $13D2|!addr
	BEQ .flag
	LDA #$FF  ;Bit value
	STA $7FC0FD

	; Increment the event counter when the
	; Yellow Switch is pressed for the first time.
	LDA $0DC4|!addr
	BNE .ret
	;INC $1F2E|!addr
	LDA #$01
	STA $0DC4|!addr
	JML .ret

.flag
	LDA #$00  ;Bit value
	STA $7FC0FD

.ret
	RTL
