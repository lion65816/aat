; 1 byte of freeram.
!freeram = $7FBFFF

; Position of the first letter.
!x_pos = $01
!y_pos = $1B

; YXCPPPTT properties for all letters.
!props = $39

; How many letters in each entry (automatically calculated).
!letters = ((AuthorNames_end-AuthorNames)/96)

; OW layer 1 level numbers table.
if !sa1
    !7ED000 = $40D000
else
    !7ED000 = $7ED000
endif

; Stripe image stuff.
!stripe_index = $7F837B
!stripe_table = $7F837D

init:
    lda #$00 : sta !freeram
    rtl

main:
    lda $13D9|!addr : cmp #$03 : beq .on_level
                      cmp #$05 : bne init
.on_level:
    lda !freeram : bne .return
    inc : sta !freeram
    phb : phk : plb
    jsr FindLevel
    jsr GetIndex
    jsr DrawText
    plb
.return:
    rtl

; Get level number of the tile the player is standing on (in A, 8-bit).
FindLevel:
    ldy $0DD6|!addr
    lda $1F17|!addr,y : lsr #4 : sta $00
    lda $1F19|!addr,y : and #$F0 : ora $00 : sta $00
    lda $1F1A|!addr,y : asl : ora $1F18|!addr,y
    ldy $0DB3|!addr
    ldx $1F11|!addr,y : beq +
    clc : adc #$04
+   sta $01
    rep #$10
    ldx $00 : lda !7ED000,x
    sep #$10
    rts

; Get the index in the names table (in Y, 16-bit).
GetIndex:
    sta $4202
    lda.b #!letters : sta $4203
    rep #$10 : nop #3
    ldy $4216
    rts

; Write the tiles to the stripe image table.
DrawText:
    rep #$20
    lda !stripe_index : tax
    lda.w #$5000|(!y_pos<<5)|!x_pos : xba : sta !stripe_table,x
    inx #2
    lda.w #((2*!letters)-1)<<8 : sta !stripe_table,x
    inx #2
    sep #$20
    lda.b #!letters-1 : sta $00
.loop:
    lda AuthorNames,y : sta !stripe_table,x
    lda.b #!props : sta !stripe_table+1,x
    inx #2
    iny
    dec $00 : bpl .loop
.end:
    rep #$20
    txa : sta !stripe_index
    lda #$FFFF : sta !stripe_table,x
    sep #$30
    rts

table "../author_display_config/ascii.txt"

AuthorNames:
    incsrc "../author_display_config/author_display_names.asm"
.end:
