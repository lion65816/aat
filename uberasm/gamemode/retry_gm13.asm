init:
    jsl retry_level_init_3_init
    phk : pea.w (+)-1
    pea.w ($02|!bank8)|(init>>16<<8)
    plb
    jml $028B20|!bank
+   pea.w ($00|!bank8)|(init>>16<<8)
    plb
    phk
    pea.w (+)-1
    pea.w $0084CF-1
    jml $008494|!bank
+   plb
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

