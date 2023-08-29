;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; scocs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;# Maxima velocidad horizontal, $24 parece decente, se puede aumentar o disminuir
!max_horiz_speed = $38

;# Maxima velocidad de caida, entre mas alto el numero mas rapido cae
!max_fall_speed = $10
!max_fall_speed_down = $20
!max_fall_speed_up = $06

;# Velocidad de salto, entre mas alto mas arriba llega al presionar el boton de saltar
!jump_speed = $2C
!jump_speed_up = $38
!jump_sfx = $21
!jump_port = $1DFC

;# Desaceleramiento, entre mas grande el numero mas rapido desacelera
!deccel = $01

;# Aceleramiento, entre mas grande el numero mas rapido acelera y alcanza la velocidad maxima
!accel = $02

;# Pon en 1 para poder volar mientras se hace spinjump
!spinjump = 0

;# Que tanto delay hay entre cocos lanzados
!fire_delay = $20

;# Velocidad del proyectil
!nut_speed = $60


    !EXTRA_BITS = !7FAB10
    !NEW_SPRITE_NUM = !7FAB9E    ;08 bytes   custom sprite number

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

y_pos:
    db $F0,$F0,$00,$00
x_pos:
    db $00,$10,$00,$10
    db $00,$F0,$00,$F0

tiles:
    db $00,$02,$20,$22
dynamic_frames:
    db $00,$01,$02,$03
    db $10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT", pc
    LDA #$77
    STA !1528,x
    jsr stick_mario
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN", pc
HAMMER_BRO_JSL:
    PHB                     ; \
    PHK                     ;  | main sprite function, just calls local subroutine
    PLB                     ;  |
    JSR START_HB_CODE       ;  |
    PLB                     ;  |
    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RETURN:
    RTS                    
START_HB_CODE:
    JSR SUB_GFX             ; draw gfx
    LDA !14C8,x             ; \ if hammer bro status != 8...
    CMP #$08                ;  }   ... not (killed with spin jump [4] or star[2])
    BNE RETURN              ; /    ... return
    LDA $9D                 ; \ if sprites locked...
    BNE RETURN              ; /    ... return
    LDA $76
    EOR #$01
    STA !157C,x
    jsr stick_mario
    jsr mario_speed
    jsr animate
    LDA !15AC,x
    BNE RETURN
    LDA $18
    AND #$10
    BEQ RETURN
    JSR SUB_HAMMER_THROW
    LDA #!fire_delay
    STA !15AC,x
    RTS                     ; return

animate:
    ldy !1540,x
    lda $14
    lsr 
    bcs +
    inc !1570,x
+   
    inc !1570,x
    cpy #$02+$20
    bcc .done
    inc !1570,x
    cpy #$0C+$20
    bcc .done
    inc !1570,x
    inc !1570,x
    cpy #$15+$20
    bcc .done 
    inc !1570,x
    inc !1570,x
    inc !1570,x
    inc !1570,x
.done
    lda !1602,x
    sta $00
    LDA !1570,x             ; \ calculate which frame to show:
    LSR A                   ;  | #8ƒtƒŒ[ƒ€‚²‚Æ‚É‰æ‘œ‚ÌØ‚è‘Ö‚¦
    LSR A                   ;  | 
    LSR A                   ;  | 0 1 2 3 4 5 6 7
    AND #$07                ;  | 0 1 2 3 4 3 2 1
    CLC
    CMP #$04
    BCC .write
    STA $18D4|!addr
    LDA #$08
    SBC $18D4|!addr
.write
    STA !1602,x             ; / write frame to show

    lda !1540,x
    beq .no_sfx
    lda !1602,x
    cmp $00
    beq .no_sfx
    cmp #$04
    bne .no_sfx
    if !jump_sfx != $00
        lda.b #!jump_sfx
        sta !jump_port|!addr
    endif
.no_sfx
    rts 

stick_mario:
    LDA $94
    STA !E4,x
    LDA $95
    STA !14E0,x
    CLC
    LDA $96
    STA !D8,x
    LDA $97
    STA !14D4,x
    rts

mario_speed:
    lda $140D|!addr
    bne .return
    lda $72
    bne .on_air
.return
    rts 
.on_air
    lda $16
    bpl ..no_jump
    lda #$28+$20
    sta !1540,x
    ldy.b #-!jump_speed
    lda $15
    and #$08
    beq ..no_up
    ldy.b #-!jump_speed_up
..no_up
    sty $7D
..no_jump

.apply_fall
    ldy #!max_fall_speed
    lda $15
    and #$04
    beq ..no_down
    ldy #!max_fall_speed_down
..no_down
    lda $15
    and #$08
    beq ..no_up
    ldy #!max_fall_speed_up
..no_up
    sty $00
    lda $7D
    bmi ..jumping
    cmp $00
    bcc ..no_deccel
    lda $00
    sta $7D
..no_deccel
..jumping

    lda $7B
    clc 
    adc.b #!max_horiz_speed
    cmp.b #!max_horiz_speed*2
    bcs .over_range
.in_range
.right
    lda $15
    and #$01
    beq ..no_right
    lda $7B
    clc 
    adc #!accel
    cmp #!max_horiz_speed
    bcc ..done
    bmi ..done
    lda #!max_horiz_speed
..done
    sta $7B
    rts 
..no_right
.left 
    lda $15
    and #$02
    beq ..no_left
    lda $7B
    sec 
    sbc #!accel
    cmp.b #-!max_horiz_speed
    bcs ..done
    bpl ..done
    lda.b #-!max_horiz_speed
..done
    sta $7B
    rts 
..no_left
.over_range
    lda $14
    and #$01
    beq ++
    lda $7B
    bpl +
    clc 
    adc.b #(!deccel*2)
+   
    sec
    sbc.b #!deccel
    sta $7B
++  
    rts 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hammer routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NEW_SPEED:
    db !nut_speed, -!nut_speed
X_OFFSET:
    db $10,$F0
X_OFFSET2:
    db $00,$FF

RETURN68:
    RTS     
SUB_HAMMER_THROW:
    JSL $02A9DE             ; \ get an index to an unused sprite slot, return if all slots full
    BMI RETURN68            ; / after: Y has index of sprite being generated

    LDA #$08                ; \ set sprite status for new sprite
    STA !14C8,y             ; /

    PHX
    LDA !NEW_SPRITE_NUM,x
    INC A
    TYX
    STA !NEW_SPRITE_NUM,x
    PLX

    PHY
    LDA !157C,x
    TAY
    LDA !E4,x               ; \ set x position for new sprite
    CLC
    ADC X_OFFSET,y
    PLY
    STA.w !E4,y

    PHY
    LDA !157C,x
    TAY
    LDA !14E0,x             ;  |
    ADC X_OFFSET2,y
    PLY
    STA !14E0,y             ; /

    LDA !D8,x               ; \ set y position for new sprite
    SEC                     ;  | (y position of generator - 1)
    SBC #$05                ;  |
    STA.w !D8,y             ;  |
    LDA !14D4,x             ;  |
    SBC #$00                ;  |
    STA !14D4,y             ; /

    PHX
    TYX
    JSL $07F7D2|!bank             ;  | ...and loads in new values for the 6 main sprite tables                   ; /
    JSL $0187A7|!bank             ;  get table values for custom sprite
    LDA #$88
    STA !EXTRA_BITS,x
    PLX

    LDA #$21
    STA $1DFC|!addr
    LDA #$77
    STA !1528,y

    PHY
    LDA !157C,x
    TAY           ;  |
    LDA NEW_SPEED,y
    PLY
    STA.w !B6,y             ; x speed of new sprite
    RTS                     ; return




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:
    lda.b #scocs_gfx
    sta $02
    lda.b #scocs_gfx>>8
    sta $03
    lda.b #scocs_gfx>>16
    sta $04

	lda !1602,x
	tay           
	lda.w dynamic_frames,y
 	%GetDSXSlot()
	bcs .available
	rts
.available
    sta $02

    ldy #$00
    lda !157C,x
    beq +
    ldy #$04
    lda #$40
+   
    ora $64
    ora !15F6,x
    sta $04
    sty $0A

	%GetDrawInfo()
	phx 
	ldx #$00
gfx_loop:
	phx 
	txa 
	clc 
	adc $0A
	tax 
	lda.w x_pos,x
	clc
	adc $00
	sta $0300|!addr,y
	plx 
	lda.w y_pos,x
	clc 
	adc $01
	sta $0301|!addr,y
		
	lda.w tiles,x
	clc	
	adc $02
	sta $0302|!addr,y
		
	lda $04
	sta $0303|!addr,y
		
	iny #4
	inx 
	cpx #$04
	bne gfx_loop
	plx 
    LDY #$02                ; \ 02, because we didn't write to 460 yet
    LDA #$03                ;  | A = number of tiles drawn - 1
    %FinishOAMWrite()
    RTS                     ; return


scocs_gfx:
	incbin "scocs.bin"

