print "Set $0DD9 to #$03"


db $42
JMP Main : JMP Main : JMP Main
JMP Return : JMP Return : JMP Return : JMP Return
JMP Main : JMP Main : JMP Main

Main:
	LDA #$03
	STA $0DD9|!addr
Return:
	RTL
