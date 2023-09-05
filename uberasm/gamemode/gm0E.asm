init:
main:
    jsl author_display_main
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

