main:
	; Increment the event counter when the
	; Red Switch room is pressed for the first time.
	LDA $13D2|!addr
	BEQ .ret
	LDA $0DC6|!addr
	BNE .ret
	INC $1F2E|!addr
	LDA #$01
	STA $0DC6|!addr
.ret
	RTL
