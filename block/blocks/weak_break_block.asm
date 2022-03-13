db $42
JMP Mario : JMP MarioAbove : JMP MarioAbove : JMP Return : JMP Return : JMP Return : JMP Return
JMP MarioAbove : JMP MarioAbove : JMP MarioAbove

MarioAbove:
	lda $140d|!addr
	bne +
	LDA #$D6
	STA $7D
+
Mario:
	LDA #$0F
    	TRB $9A
    	TRB $98  
	%shatter_block()
	RTL
Return:
	RTL