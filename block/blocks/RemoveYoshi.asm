print "A block that removes yoshi upon entering the next room."

db $42
JMP Mario : JMP Mario : JMP Mario
JMP Yoshi : JMP Yoshi : JMP End : JMP End
JMP Mario : JMP Mario : JMP Mario

Mario:
	LDA $187A ;checks for yoshi.
	BEQ End   ; no yoshi, the end.
Yoshi:
	LDA #$01	; removes yoshi upon entering next room, but will return at the overworld.
	STA $1B9B|!addr
End:
	RTL





