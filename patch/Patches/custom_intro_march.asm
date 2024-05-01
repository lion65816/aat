; Offset from initial tile when starting a new game
; Vanilla is: X = +$0000, Y = +$0016
!march_x_offset = -$0020
!march_y_offset = +$0000

; Intro march speed (in 1/$100 pixels/frame, i.e. $0080 is half a pixel per frame)
; Vanilla is: X = +$0000, Y = -$0080
; Note: make sure the signs are consistent with the offsets
; (for example, if X offset is negative, X speed should be positive)
; If you increase the speed and Mario doesn't stop on the starting tile,
; try tinkering with the offset (the movement has to line up to end up exactly
; at the starting tile, if Mario overshoots it he won't stop)
!march_x_speed = +$0100
!march_y_speed = +$0000

; Intro march animation. For what values to use, see
; https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=c12320072611
!march_animation = $06

if read1($00FFD5) == $23
    sa1rom
    !sa1 = 1
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !addr = $0000
    !bank = $800000
endif

org $009F1D
    autoclean jml start_offset

org $048EF6
    autoclean jml check_start_position

org $0498C6
    autoclean jml intro_march

freecode

start_offset:
    ldx #$15
-   lda.w $009EF0,x : sta $1FB8|!addr,x
    dex : bpl -
    ldx $0DD6|!addr
    rep #$20
if !march_x_offset != 0
    lda $1FBE|!addr,x : clc : adc.w #!march_x_offset : sta $1FBE|!addr,x
endif
if !march_y_offset != 0
    lda $1FC0|!addr,x : clc : adc.w #!march_y_offset : sta $1FC0|!addr,x
endif
    sep #$20
    jml $009F28|!bank

check_start_position:
    ldx $0DB3|!addr
    lda $1F11|!addr,x
    cmp.l $009EF0|!bank : bne .skip
    ldx $0DD6|!addr
    rep #$20
    lda $1F17|!addr,x
if !march_x_offset != 0
    sec : sbc.w #!march_x_offset
endif
    cmp.l $009EF6|!bank : bne .skip
    lda $1F19|!addr,x
if !march_y_offset != 0
    sec : sbc.w #!march_y_offset
endif
    cmp.l $009EF8|!bank : bne .skip
.march:
    sep #$20
    jml $048F0B|!bank
.skip:
    sep #$20
    jml $048F13|!bank

intro_march:
    lda $0DB3|!addr : asl : tax
    lda.b #!march_animation : sta $1F13|!addr,x
    ldx $0DD6|!addr
if !march_x_speed != 0
    lda $13D7|!addr : clc : adc.b #!march_x_speed : sta $13D7|!addr
    lda $1F17|!addr,x : adc.b #!march_x_speed>>8 : sta $1F17|!addr,x
if !march_x_speed < 0
    lda #$FF
else
    lda #$00
endif
    adc $1F18|!addr,x : sta $1F18|!addr,x
endif
if !march_y_speed != 0
    lda $13D8|!addr : clc : adc.b #!march_y_speed : sta $13D8|!addr
    lda $1F19|!addr,x : adc.b #!march_y_speed>>8 : sta $1F19|!addr,x
if !march_y_speed < 0
    lda #$FF
else
    lda #$00
endif
    adc $1F1A|!addr,x : sta $1F1A|!addr,x
endif
    rep #$20
if !march_x_speed != 0
    lda $1F17|!addr,x : cmp.l $009EF6|!bank : bne .skip
endif
if !march_y_speed != 0
    lda $1F19|!addr,x : cmp.l $009EF8|!bank : bne .skip
endif
.save:
    sep #$20
    jml $0498F3|!bank
.skip:
    sep #$20
    jml $0498FA|!bank
