load:
	; Don't carry Yoshi over levels.
	STZ $0DC1|!addr
	RTL

init:
	JSL FilterFireCape_init
	JSL freescrollbabey_init
	RTL

main:
	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main
	RTL
