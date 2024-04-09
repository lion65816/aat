	
main:
	LDA $0DC6|!addr
	BEQ .ret
	INC $1F2E|!addr
	LDA #$01
	STA $0DC6|!addr
	.ret
	RTL
