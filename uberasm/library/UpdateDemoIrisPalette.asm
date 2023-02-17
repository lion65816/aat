
DemoIris:
    LDA $0DB3|!addr
    BNE Iris
    lda.b #Colors       ;\
    sta $00             ;| Copy table address to $00.
    lda.b #Colors>>8    ;|
    sta $01             ;/
    lda $83            ; Color number to upload to
    jsr ChangeColors
    RTL

Colors:
    dw $092E,$1E3A,$2BBF,$FFFF       ; Needs $FFFF terminator
    
Iris:
    lda.b #ColorsI       ;\
    sta $00             ;| Copy table address to $00.
    lda.b #ColorsI>>8    ;|
    sta $01             ;/
    lda $83            ; Color number to upload to
    jsr ChangeColors
    RTL
    
ColorsI:
    dw $4C8E,$59B3,$7299,$FFFF       ; Needs $FFFF terminator

ChangeColors:
    ldx $0681|!addr
    sta $0683|!addr,x
    ldy #$00
    rep #$20
.loop
    lda ($00),y
    bmi .end
    sta $0684|!addr,x
    inx #2
    iny #2
    bra .loop
.end
    sep #$20
    stz $0684|!addr,x
    txa
    ldx $0681|!addr
    sta $0682|!addr,x
    inc #2
    sta $0681|!addr
.return
    rts