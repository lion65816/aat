init:
	JSL freescrollbabey_init
	RTL

main:
	LDX #!sprite_slots-1
.loop
	LDY !sprite_misc_154c,x
	LDA !sprite_num,x
	CMP #$86 : BNE +
	LDA !sprite_being_eaten,x
	BEQ +
	LDY #$80
+
	TYA
	STA !sprite_misc_154c,x
	DEX : BPL .loop

	RTL
