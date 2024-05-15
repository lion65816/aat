load:
	JSL MultipersonReset_load
	RTL

init:
	JSL start_select_init
	JSL freescrollbabey_init
	RTL

main:
	JSL start_select_main

	; Disable A button.
	LDA #%00000000 : STA $00
	LDA #%10000000 : STA $01
	JSL DisableButton_main

	; Reload the room upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
.return
    RTL
