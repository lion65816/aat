init:
	LDA #$01
	STA $140B|!addr
	RTL

load:
    lda #$01
    sta $13E6|!addr
    rtl

    JSL FilterYoshi_load
    RTL 
    
