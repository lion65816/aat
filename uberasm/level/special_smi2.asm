init:
	JSL freescrollbabey_init
	JSL gradient_special_smi2_init
	RTL

main:
	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main
	LDA $010B|!addr
    STA $0C
    LDA $010C|!addr
    STA $0D
    JSL MultipersonReset_main
	RTL
