init:
	LDA #$01
	STA $140B|!addr
	JSL RequestRetry_init
	RTL

!screen_num = $0D

main:
    LDA ($19B8+!screen_num)|!addr
    STA $0C
    LDA ($19D8+!screen_num)|!addr
    STA $0D
    JSL MultipersonReset_main
	JSL RequestRetry_main
	RTL
