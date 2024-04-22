main:
	; Increment the event counter when the
	; Green Switch room is pressed for the first time.
	LDA $13D2|!addr
	BEQ .ret
	LDA $0DC3|!addr
	BNE .ret
	INC $1F2E|!addr
	LDA #$01
	STA $0DC3|!addr
.ret
	RTL
