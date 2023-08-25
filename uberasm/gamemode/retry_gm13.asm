init:
    jsl retry_level_init_3_init
    rtl

main:
    jsl retry_level_init_3_main
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

