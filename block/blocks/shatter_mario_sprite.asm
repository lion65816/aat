;shatter for mario and sprites
;by lolcats439

db $42
JMP ShatterMario : JMP ShatterMario : JMP ShatterMario
JMP ShatterSprite : JMP ShatterSprite : JMP ShatterMario : JMP Return
JMP ShatterMario : JMP ShatterMario : JMP ShatterMario


ShatterSprite:
	%sprite_block_position()
ShatterMario:
	LDA #$0F
	TRB $9A
	TRB $98
	%shatter_block()
Return:
	RTL

print "Shatters if Mario or any sprite touches it."