
load:
    lda #$01
    sta $13E6|!addr
    JSL FilterYoshi_load
    rtl
    