; This code will reload the current room.

main:
    LDA $010B|!addr
    STA $0C
    LDA $010C|!addr
    ORA #$04
    STA $0D
    JSL LRReset
    
    LDA #$01
    STA $140B|!addr
    RTL

load:
    lda #$01
    sta $13E6|!addr
    rtl

    RTL
