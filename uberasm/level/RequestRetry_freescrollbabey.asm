init:
	LDA #$01
	STA $140B|!addr
	JSL RequestRetry_init
	RTL

main:
	JSL RequestRetry_main
	RTL
