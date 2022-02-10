;shatter for mario
;by lolcats439

db $42

JMP ShatterMario : JMP ShatterMario : JMP ShatterMario
JMP Return : JMP Return : JMP ShatterMario : JMP Return
JMP ShatterMario : JMP ShatterMario : JMP ShatterMario

ShatterMario:
	LDA #$0F
	TRB $9A
	TRB $98   
	%shatter_block()
Return:
	RTL 

print "Shatters if Mario touches it."