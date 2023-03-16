init:
	LDA #$01
	STA $140B|!addr
	RTL

load:
	JSL FilterYoshi_load
	RTL
