load:

	JSL FilterYoshi_load
	JSL NoStatus_load
	RTL


init:

	LDA #$01

	STA $140B|!addr
	RTL
