load:
	JSL NoStatus_load
	RTL

init:
	JSL SimpleHP_init
	RTL

!screen_num = $0D

main:
    LDA ($19B8+!screen_num)|!addr
    STA $0C
    LDA ($19D8+!screen_num)|!addr
    STA $0D
    JSL MultipersonReset_main
	JSL SimpleHP_main
	RTL
