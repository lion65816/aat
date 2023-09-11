load:
	JSL FilterYoshi_load
	RTL

init:
	JSL freescrollbabey_init
	JSL jumpers_gradient_init

	; Set On/Off Switch value to On.
	LDA #$00
	STA $14AF|!addr

	; Filter flower and cape powerups.
	LDA $19
	BEQ +
	LDA #$01
	STA $19
+	LDA $0DC2|!addr
	BEQ +
	LDA #$01
	STA $0DC2|!addr
+	RTL

main:
	; Don't keep track of consecutive enemies stomped counter.
	LDA #$00
	STA $1697|!addr

	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main
	RTL
