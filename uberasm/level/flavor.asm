init:
	JSL InitSpriteFacing_init
	RTL

!screen_num = $0D

main:
    LDA ($19B8+!screen_num)|!addr
    STA $0C
    LDA ($19D8+!screen_num)|!addr
    STA $0D
    JSL MultipersonReset_main
	JSL BG_AutoScroll7B_main
	RTL
