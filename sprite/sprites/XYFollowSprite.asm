;===============================================================================================;
; Mario X/Y Position Tracking Sprite v1.2                                                       ;
; by KevinM                                                                                     ;
;                                                                                               ;
; This sprite will spawn a new sprite and make it stay at the same X or Y position as Mario.    ;
;                                                                                               ;
; Extra bit: if clear, the spawned sprite is vanilla. If set, it's custom.                      ;
;                                                                                               ;
; Extra byte 1: sprite number to spawn.                                                         ;
;                                                                                               ;
; Extra byte 2: offset from Mario's X/Y position to keep the sprite at.                         ;
;   - Positive values ($00-$7F): offset to the right (or none if $00).                          ;
;   - Negative values ($FF-$80): offset to the left.                                            ;
;  Note: if using the Y tracking option, you may want to use $10 as the offset to make the      ;
;    sprite stay at Mario's feet position rather than his head.                                 ;
;                                                                                               ;
; Extra byte 3: additional settings. Format: e------p                                           ;
;   e: if set, the extra bit in the spawned sprite will be set.                                 ;
;   p: 0 = track Mario's X position, 1 = track Mario's Y position.                              ;
;   -: unused.                                                                                  ;
;                                                                                               ;
; Extra bytes 4-7:                                                                              ;
;   These 4 values set the 4 extra bytes for the sprite spawned (only if it's custom).          ;
;                                                                                               ;
; Note: when inserting the sprite from the custom sprite list, there'll probably be some random ;
;   values for the last 3 extra bytes. This is because the list doesn't actually support more   ;
;   than 4, so you'll have to change them manually (although if you're not using extra bytes    ;
;   for the spawned sprite you can leave random values there, as they won't be used).           ;
;===============================================================================================;

; If 1, when using the Y tracking option it will be taken into account if Mario is mounting Yoshi,
; since in this case his position is shifted 10 pixels upwards.
; This is recommended if you want it to track Mario's feet,
; and not recommended if you want it to track Mario's head.
!YoshiOffset = 1

print "INIT ",pc
ExtraBytesSetup:
    lda !extra_byte_1,x
    sta $00
    lda !extra_byte_2,x
    sta $01
    lda !extra_byte_3,x
    sta $02
    ldy #$00
    lda [$00],y                 ;\ $04 = sprite number to spawn.
    sta $04                     ;/
    iny
    lda [$00],y                 ;\ $1504,x = offset.
    sta !1504,x                 ;/
    iny
    lda [$00],y                 ;\ $0A = additional settings.
    sta $0A                     ;/
    iny
    lda [$00],y                 ;\ $06 = extra byte 1.
    sta $06                     ;/
    iny
    lda [$00],y                 ;\ $07 = extra byte 2.
    sta $07                     ;/
    iny
    lda [$00],y                 ;\ $08 = extra byte 3.
    sta $08                     ;/
    iny
    lda [$00],y                 ;\ $09 = extra byte 4.
    sta $09                     ;/
Spawn:
    stz $00
    stz $01
    stz $02
    stz $03
    stz $05
    lda $04
    cmp #$DF                    ;\
    beq ++                      ;|
    cmp #$DA                    ;|
    bmi +                       ;|
    cmp #$DE                    ;| If sprite is a Shell, change number to Koopa.
    bpl +                       ;|
++  sec                         ;|
    sbc #$D6                    ;|
    sta $04                     ;/
    inc $05                     ; Set flag to spawn in carryable state.
+   lda !extra_bits,x           ;\
    and #$04                    ;| Transfer extra bit to carry.
    lsr #3                      ;/
    lda $04                     ; Set sprite number from extra byte 1.
    %SpawnSprite2()             ; Spawn sprite.
    sty !C2,x                   ; Save sprite slot.
    bcc +                       ;\ If failed to spawn, kill this sprite.
    stz !14C8,x                 ;/
    rtl
+   lda $05                     ;\
    beq +                       ;| Spawn in carryable state when flag is set.
    lda #$09                    ;|
    sta !14C8,y                 ;/
+   %BEC(+)                     ;\
    tyx                         ;|
    lda $06                     ;|
    sta !extra_byte_1,x         ;|
    lda $07                     ;| If the sprite is custom, set its extra bytes.
    sta !extra_byte_2,x         ;|
    lda $08                     ;|
    sta !extra_byte_3,x         ;|
    lda $09                     ;|
    sta !extra_byte_4,x         ;/
    ldx $15E9|!addr
+   tyx
    lda $0A                     ;\
    bpl +                       ;|
    lda !extra_bits,x           ;| Also set the extra bit.
    ora #$04                    ;|
    sta !extra_bits,x           ;/
+   ldx $15E9|!addr
    lda $0A                     ;\ $1510,x = X/Y follow flag.
    and #$01                    ;|
    sta !1510,x                 ;/
    rtl

print "MAIN ",pc
    ldy !C2,x                   ; Load other sprite's slot.
    lda !14C8,y                 ;\
    cmp #$08                    ;|
    bcs +                       ;| If the other sprite died, kill this one too.
    stz !14C8,x                 ;|
    lda !15A0,y                 ;|\
    ora !186C,y                 ;|| If the sprite was offscreen, assume it was despawned by SubOffScreen...
    beq ++                      ;|/
    lda !161A,x                 ;|\
    tax                         ;||
    lda #$00                    ;|| ...so allow it to respawn.
    sta !1938,x                 ;||
    ldx $15E9|!addr             ;||
    rtl                         ;|/
++  lda #$FF                    ;|\ If it was killed, don't make it respawn.
    sta !161A,x                 ;|/
    rtl                         ;/
+   stz $01                     ;\
if !YoshiOffset                 ;|
    lda !1510,x                 ;|\ Skip Yoshi check if X tracking.
    beq +                       ;|/
    lda $187A|!addr             ;|\
    beq +                       ;|| If riding Yoshi, add $10 to the offset.
    lda #$10                    ;|| Otherwise, add $00.
    bra ++                      ;||
+   lda #$00                    ;|/
++  clc                         ;|
    adc !1504,x                 ;|
else                            ;|
    lda !1504,x                 ;|
endif                           ;|
    bpl +                       ;| Save 16-bit offset in $00.
    dec $01                     ;|
+   sta $00                     ;/
    lda !1510,x                 ;\ Check if we have to track X or Y position.
    beq X                       ;/
Y:  lda $00                     ;\
    clc                         ;|
    adc $96                     ;|
    sta !sprite_y_low,x         ;| Set this and other sprite's Y position
    sta !sprite_y_low,y         ;| to Mario's position + offset.
    lda $97                     ;|
    adc $01                     ;|
    sta !sprite_y_high,x        ;|
    sta !sprite_y_high,y        ;/
    lda !sprite_x_low,y         ;\
    sta !sprite_x_low,x         ;| Set this sprite's X position to the
    lda !sprite_x_high,y        ;| other sprite's Y position.
    sta !sprite_x_high,x        ;/
    rtl
X:  lda $00                     ;\
    clc                         ;|
    adc $94                     ;|
    sta !sprite_x_low,x         ;| Set this and other sprite's X position
    sta !sprite_x_low,y         ;| to Mario's position + offset.
    lda $95                     ;|
    adc $01                     ;|
    sta !sprite_x_high,x        ;|
    sta !sprite_x_high,y        ;/
    lda !sprite_y_low,y         ;\
    sta !sprite_y_low,x         ;| Set this sprite's Y position to the
    lda !sprite_y_high,y        ;| other sprite's Y position.
    sta !sprite_y_high,x        ;/
    rtl
