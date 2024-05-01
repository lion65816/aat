if read1($00FFD5) == $23
    sa1rom
    !sa1    = 1
    !dp     = $3000
    !addr   = $6000
    !bank   = $000000
    !7EC800 = $40C800
else
    lorom
    !sa1    = 0
    !dp     = $0000
    !addr   = $0000
    !bank   = $800000
    !7EC800 = $7EC800
endif

!Up    = $00
!Down  = $02
!Left  = $04
!Right = $06

function level(x) = select(greaterequal((x),$DC),(x)-$DC,(x))

macro offsets(entry)
    dw paths_<entry>_1-paths_00_1
    dw paths_<entry>_2-paths_00_1
endmacro

org $04952D
    autoclean jml settle_on_level_fix

org $049312
    autoclean jml hardcoded_paths_check

org $0495B6
    bra $08

org $0495C3
    autoclean jsl hardcoded_paths_movement
    nop #2

org $049798
    autoclean jsl hardcoded_paths_animation
    nop

freecode

hardcoded_paths_check:
    phb : phk : plb
    ldx.w #paths-levels-1
.tile_check_loop:
    lda.w levels,x : and #$00FF
    cmp #$00FF : bne ..normal
..ci2_pipe:
    phx
    ldx $0DD6|!addr
    lda $1F17|!addr,x : cmp.w ci2_pipe_x_pos : bne +
    lda $1F19|!addr,x : cmp.w ci2_pipe_y_pos : bne +
    lda $0DB3|!addr : and #$00FF : tax
    lda $1F11|!addr,x : and #$00FF : cmp.w ci2_pipe_submap : bne +
    plx
    bra ..found
+   plx
..next:
    dex : bpl .tile_check_loop
..return_not_found:
    plb
    jml $04937A|!bank
..normal:
    cmp $00 : bne ..next
..found:
    sty $02
    lda.w directions,x : and #$00FF
    cmp $02 : bne ..next
    txa : asl : tax
    lda.w offsets,x : tax
    dec : sta $1B7A|!addr
    jsl hardcoded_paths_movement
..return_found:
    plb
    jml $049384|!bank

hardcoded_paths_movement:
    lda.l animation,x : and #$00FF
    clc : ror #3 : inc : sta $1B78|!addr
    lda.l paths,x : and #$00FF
    rtl

hardcoded_paths_animation:
    bit $1B78|!addr : bpl +
    sep #$20
    lda #$01 : sta $1B80|!addr
    rep #$20
    lda #$0014
    bra ++
+   lda $04
    bvc ++
    ora #$0008
++  sta $1F13|!addr,x
    rtl

settle_on_level_fix:
    ; Update Mario's position/$10 mirrors to fix level names
    ; being sometimes wrong at the end of a hardcoded path
    lda $1F17|!addr,x : lsr #4 : sta $00 : sta $1F1F|!addr,x
    lda $1F19|!addr,x : lsr #4 : sta $02 : sta $1F21|!addr,x
    
    ; Update level tile Mario is standing on
    ; to overwrite the tile used in the hardcoded path
    ; (fixes issue with destroyed castle tiles)
    txa : lsr #2 : tax
    phk : pea.w (+)-1
    pea.w $048414-1
    jml $049885|!bank
+   ldx $04
    lda !7EC800,x : sta $13C1|!addr

    jml $04953E|!bank

incsrc "more_hardcoded_paths_tables.asm"
