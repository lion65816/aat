!player_gfx_num     #= !freeram+0
!animations_gfx_num #= !freeram+2

!player_gfx_dest     #= $7E2000
!animations_gfx_dest #= $7E7D00

init:
    rep #$20
    lda.w #!default_player_gfx : sta !player_gfx_num
    lda.w #!default_animation_gfx : sta !animations_gfx_num
    sep #$20
    rtl

main:
    lda $0100|!addr
    cmp #$12 : beq .level_load
    cmp #$0E : beq .overworld_main
    cmp #$0C : beq .overworld_load
    cmp #$19 : beq .cutscene_load
    rtl

.level_load:
    rep #$30
    lda $010B|!addr : asl : tax
    lda.l level_player_gfx,x
    jsl upload_player
    lda.l level_animations_gfx,x
    jsl upload_animations
    sep #$30
    rtl

.overworld_main:
    lda $13D9|!addr : cmp #$0A : bne .return
    lda $1DE8|!addr : cmp #$05 : bne .return
.overworld_load:
    ldx $0DB3|!addr
    lda $1F11|!addr,x
    rep #$30
    and #$00FF : asl : tax
    lda.l overworld_player_gfx,x
    jsl upload_player
    sep #$30
.return:
    rtl

.cutscene_load:
    rep #$30
    lda $13C6|!addr : and #$00FF : asl : tax
    lda.l cutscene_player_gfx-2,x
    jsl upload_player
    sep #$30
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
