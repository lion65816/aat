;~@sa1 <-- DO NOT REMOVE THIS LINE!
; A block that will give Mario 5 lives
; Act like 25

!lives = #$05
print "Adds !lives lives one by one and then disappears in a glitter"
db $42

JMP Mario : JMP Mario : JMP Mario : JMP Return : JMP Return : JMP Return : JMP Return
JMP Mario : JMP Mario : JMP Mario

Mario:
	LDA $78E4 ;\
	CLC       ;| Give Mario
	ADC !lives;| 5 lives.
	STA $78E4 ;/
	
	%glitter()
	%erase_block()
	
Return:
	RTL		; And return.