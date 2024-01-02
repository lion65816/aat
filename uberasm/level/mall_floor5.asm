load:
	JSL FilterYoshi_load
	RTL

main:
	; Set flag for Floor 4 cleared.
	; Note: SRAM addresses $41C7EA~$41C7EC are initialized in the deathcounter.asm patch.
	LDA $010A|!addr
	TAX
	LDA $41C7EA,x	;> Index SRAM by save file.
	ORA #%00001000
	STA $41C7EA,x

	JSL author_room_names_main
	RTL
