	
main:
	LDA $0DC3|!addr
	BNE .ret
	INC $1F2E|!addr
	LDA #$01
	STA $0DC3|!addr
	.ret
	RTL
