; 0 = horizontal, 1 = vertical
!direction = 1

; One byte of freeram.
!freeram = $1475|!addr

!layer1 = $1A+(!direction*2)
!layer2 = $1E+(!direction*2)

init:
    stz !freeram
    rtl

main:
    ;jsl overworld_map_names_main

    lda $13D9|!addr : cmp #$0A : bne +
    lda $1DE8|!addr : cmp #$06 : beq init
+   inc !freeram
    lda !freeram : bit #$03 : bne .return
    lsr #2 : tax
    stz $01
    lda.l delta,x : sta $00
    bpl +
    dec $01
+   rep #$20
    lda !layer1 : clc : adc $00 : sta !layer1
    lda !layer2 : clc : adc $00 : sta !layer2
    sep #$20
.return:
    rtl

delta:
    db $00,$00,$00,$00,$00,$00,$FF,$00
    db $00,$00,$FF,$00,$00,$FF,$00,$FF
    db $00,$00,$FF,$00,$FF,$00,$00,$FF
    db $00,$00,$00,$FF,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$01,$00
    db $00,$00,$01,$00,$00,$01,$00,$01
    db $00,$00,$01,$00,$01,$00,$00,$01
    db $00,$00,$00,$01,$00,$00,$00,$00
