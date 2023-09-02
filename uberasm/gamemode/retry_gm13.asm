init:
	JSL retry_level_init_3_init

	; Display the item box during level load.
	; To be used with the Sprite Item Box patch.
	; Source: https://smwc.me/s/26887/62613
	PHK : PEA.w (+)-1
	PEA.w ($02|!bank8)|(init>>16<<8)
	PLB
	JML $028B20|!bank
+	PEA.w ($00|!bank8)|(init>>16<<8)
	PLB
	PHK
	PEA.w (+)-1
	PEA.w $0084CF-1
	JML $008494|!bank
+	PLB

	RTL

main:
	JSL retry_level_init_3_main

	; Handle Iris palette with ExAnimation custom trigger.
	LDA $0DB3|!addr
	CMP #$00
	BNE .Iris
	LDA #$00
	STA $7FC0FC
	JML .Return
.Iris
	LDA #$01  ;Bit value
	STA $7FC0FC
.Return
	RTL
