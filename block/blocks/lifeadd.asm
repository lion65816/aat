db $37

JMP Main : JMP Main : JMP Main : JMP Return : JMP Return : JMP Return : JMP Return
JMP Main : JMP Main : JMP Main : JMP Main : JMP Main

Main:
	LDA $141A|!addr
	CMP #04
	BCS Life
	DEC $0DBE|!addr
	%erase_block()
	
Life:
	INC $0DBE|!addr
	%erase_block()

Return:
	RTL

print "Adds a life to  the player, then disappears."