load:
	LDA #$01
	STA $1B9B|!addr
	RTL
	
main:
	LDA $13D2|!addr
	;CMP #$00
	BEQ .flag
	LDA #$FF  ;Bit value
	STA $7FC0FD
	LDA $0DC4|!addr
	BEQ .ret
	INC $1F2E|!addr
	LDA #$01
	STA $0DC4|!addr
	JML .ret
	.flag
	LDA #$00  ;Bit value
	STA $7FC0FD
	.ret
	RTL
