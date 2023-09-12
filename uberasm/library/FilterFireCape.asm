init:
	; Filter fire and cape status.
	LDA $19
	BEQ +
	LDA #$01
	STA $19
+
	; Also filter fire and cape reserve.
	LDA $0DC2|!addr
	BEQ +
	LDA #$01
	STA $0DC2|!addr
+
	RTL
