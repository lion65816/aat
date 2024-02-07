load:
	LDA #$01
	STA $1B9B|!addr
	RTL
	
main:
	LDA $1F28|!addr
	;CMP #$00
	BEQ .flag
	LDA #$01  ;Bit value
	STA $7FC0FD
	JML .ret
	.flag
	LDA #$00  ;Bit value
	STA $7FC0FD
	.ret
	RTL
