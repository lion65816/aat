if read1($00FFD5) == $23
    sa1rom
    !sa1    = 1
    !dp     = $3000
    !addr   = $6000
    !bank   = $000000
    !7EC800 = $40C800
    !7FC800 = $41C800
else
    lorom
    !sa1    = 0
    !dp     = $0000
    !addr   = $0000
    !bank   = $800000
    !7EC800 = $7EC800
    !7FC800 = $7FC800
endif

; Stripe image table RAM
!stripe_index = $7F837B
!stripe_table = $7F837D

org $04E702
    autoclean jsl upload_step_tile_1

org $04DA6A
    autoclean jsl upload_step_tile_2

freecode

upload_step_tile_1:
    phb : phk : plb
    lda $1DEA|!addr
    jsr upload_tile_ram
    bcs .return
    jsr upload_tile_vram
.return:
    plb
    lda $1DEB|!addr
    asl
    rtl

upload_step_tile_2:
    sta $04

    lda $0F : and #$00FF : asl : tay

    lda.l $04E6DE|!bank : sta $00
    lda.l $04E6DF|!bank : sta $01
    lda [$00],y : sta $1DEB|!addr

    lda.l $04E6E5|!bank : sta $00
    lda.l $04E6E6|!bank : sta $01
    lda [$00],y : sta $1DED|!addr

    cmp $1DEB|!addr : beq .return
    
    phb : phk : plb
.loop:
    lda $0F
    jsr upload_tile_ram
    inc $1DEB|!addr
    lda $1DEB|!addr : cmp $1DED|!addr : bne .loop
    plb

.return:
    lda $0F
    rtl

upload_tile_ram:
    and #$00FF : asl : tay
    
    lda.l $04E6DE|!bank : sta $00
    lda.l $04E6DF|!bank : sta $01
    lda $1DEB|!addr : sec : sbc [$00],y : sta $02

    lda.w event_index+2,y : sta $00
    lda.w event_index+0,y : tay
.loop:
    cpy $00 : bcs .not_found
    lda $02 : cmp.w event,y : beq .found
    tya : clc : adc #$0008 : tay
    bra .loop
.found:
    ldx.w event+2,y
    lda.w event+4,y : sta $00
    lda.w event+6,y : sta $02
    sep #$20
    sta !7EC800,x
    xba : sta !7FC800,x
    rep #$20
    clc
.not_found:
    rts

upload_tile_vram:
    pea.w $0404 : plb : plb

    lda.w $04DCBC,x : sta $65
    sep #$20
    lda.w $04DCC1,x : sta $67
    rep #$20
    lda $02
    jsl $06F5E4|!bank

    lda !stripe_index : tax
    clc : adc.w #16 : sta !stripe_index

    lda $00 : xba : sta !stripe_table+0,x
    xba : inc : xba : sta !stripe_table+8,x

    lda.w #$8003 : xba
    sta !stripe_table+2,x
    sta !stripe_table+10,x

    lda [$65],y : sta !stripe_table+4,x
    iny #2
    lda [$65],y : sta !stripe_table+6,x
    iny #2
    lda [$65],y : sta !stripe_table+12,x
    iny #2
    lda [$65],y : sta !stripe_table+14,x

    lda #$FFFF : sta !stripe_table+16,x
    rts

macro step(step, x, y, tile)
    ; Need to use X-1 if not the main map
    if <y> < $20
        !_x #= <x>
        !_y #= <y>
    else
        !_x #= <x>-1
        !_y #= <y>
    endif
    dw <step>
    dw (((!_x)&$0F)<<0)|(((!_y)&$0F)<<4)|(((!_x)&$10)<<4)|(((!_y)&$30)<<5)
    dw (((!_x)&$0F)<<1)|(((!_y)&$0F)<<6)|(((!_x)&$10)<<6)|(((!_y)&$10)<<7)|$2000
    dw <tile>
    undef "_x"
    undef "_y"
endmacro

event:
    incsrc "layer1_events_tables.asm"
.end:

macro index(x)
    dw event_<x>-event
endmacro

event_index:
    %index(00) : %index(01) : %index(02) : %index(03) : %index(04) : %index(05) : %index(06) : %index(07)
    %index(08) : %index(09) : %index(0A) : %index(0B) : %index(0C) : %index(0D) : %index(0E) : %index(0F)
    %index(10) : %index(11) : %index(12) : %index(13) : %index(14) : %index(15) : %index(16) : %index(17)
    %index(18) : %index(19) : %index(1A) : %index(1B) : %index(1C) : %index(1D) : %index(1E) : %index(1F)
    %index(20) : %index(21) : %index(22) : %index(23) : %index(24) : %index(25) : %index(26) : %index(27)
    %index(28) : %index(29) : %index(2A) : %index(2B) : %index(2C) : %index(2D) : %index(2E) : %index(2F)
    %index(30) : %index(31) : %index(32) : %index(33) : %index(34) : %index(35) : %index(36) : %index(37)
    %index(38) : %index(39) : %index(3A) : %index(3B) : %index(3C) : %index(3D) : %index(3E) : %index(3F)
    %index(40) : %index(41) : %index(42) : %index(43) : %index(44) : %index(45) : %index(46) : %index(47)
    %index(48) : %index(49) : %index(4A) : %index(4B) : %index(4C) : %index(4D) : %index(4E) : %index(4F)
    %index(50) : %index(51) : %index(52) : %index(53) : %index(54) : %index(55) : %index(56) : %index(57)
    %index(58) : %index(59) : %index(5A) : %index(5B) : %index(5C) : %index(5D) : %index(5E) : %index(5F)
    %index(60) : %index(61) : %index(62) : %index(63) : %index(64) : %index(65) : %index(66) : %index(67)
    %index(68) : %index(69) : %index(6A) : %index(6B) : %index(6C) : %index(6D) : %index(6E) : %index(6F)
    %index(70) : %index(71) : %index(72) : %index(73) : %index(74) : %index(75) : %index(76) : %index(77)
    %index(end)
