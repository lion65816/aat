; AAT edits: Added checks for Iris.

!player_gfx_num     #= !freeram+0
!animations_gfx_num #= !freeram+2

!player_gfx_dest     #= $7E2000
!animations_gfx_dest #= $7E7D00

init:
    lda $0DB3|!addr : bne .iris
    rep #$20
    lda.w #!default_demo_player_gfx : sta !player_gfx_num
    lda.w #!default_animation_gfx : sta !animations_gfx_num
    sep #$20
    bra .return
.iris
    rep #$20
    lda.w #!default_iris_player_gfx : sta !player_gfx_num
    lda.w #!default_animation_gfx : sta !animations_gfx_num
    sep #$20
.return
    rtl

main:
    lda $0100|!addr
    cmp #$12 : beq .level_load
    cmp #$0E : beq .overworld_main
    cmp #$0C : beq .overworld_load
    cmp #$19 : beq .cutscene_load
    rtl

.level_load
    lda $0DB3|!addr : bne .iris1
    rep #$30
    lda $010B|!addr : asl : tax
    lda.l level_demo_player_gfx,x
    jsl upload_player
    lda.l level_animations_gfx,x
    jsl upload_animations
    sep #$30
    bra .return1
.iris1
    rep #$30
    lda $010B|!addr : asl : tax
    lda.l level_iris_player_gfx,x
    jsl upload_player
    lda.l level_animations_gfx,x
    jsl upload_animations
    sep #$30
.return1
    rtl

.overworld_main
    lda $13D9|!addr : cmp #$0A : bne .return2
    lda $1DE8|!addr : cmp #$05 : bne .return2
.overworld_load
    ldx $0DB3|!addr
    lda $1F11|!addr,x
    cpx #$00 : bne .iris2
    rep #$30
    and #$00FF : asl : tax
    lda.l overworld_demo_player_gfx,x
    jsl upload_player
    sep #$30
    bra .return2
.iris2
    rep #$30
    and #$00FF : asl : tax
    lda.l overworld_iris_player_gfx,x
    jsl upload_player
    sep #$30
.return2
    rtl

.cutscene_load
    lda $0DB3|!addr : bne .iris3
    rep #$30
    lda $13C6|!addr : and #$00FF : asl : tax
    lda.l cutscene_demo_player_gfx-2,x
    jsl upload_player
    sep #$30
    bra .return3
.iris3
    rep #$30
    lda $13C6|!addr : and #$00FF : asl : tax
    lda.l cutscene_iris_player_gfx-2,x
    jsl upload_player
    sep #$30
.return3
    rtl

upload_player:
    beq +
    cmp !player_gfx_num : beq +
    sta !player_gfx_num
    ldy.w #!player_gfx_dest : sty $00
    ldy.w #!player_gfx_dest>>8 : sty $01
    jml $0FF900|!bank
+   rtl

upload_animations:
    beq +
    cmp !animations_gfx_num : beq +
    sta !animations_gfx_num
    ldy.w #!animations_gfx_dest : sty $00
    ldy.w #!animations_gfx_dest>>8 : sty $01
    jml $0FF900|!bank
+   rtl
