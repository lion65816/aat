init:
    ; jsl retry_fade_to_overworld_init
    jsl author_display_init
    jsl author_display_main_on_level
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

