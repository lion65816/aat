init:
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
	JSL freezetimer_main
	RTL
