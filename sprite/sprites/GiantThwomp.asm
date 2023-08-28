;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Giant Thwomp
;;
;; By: Major Flare, inspired by: imamelia, Sonikku
;;
;; This is pretty much a giant thwomp. It tries to crush the player.
;;
;; USES EXTRA BIT: YES
;;
;; - Extra bit clear: goes downwards (standard)
;; - Extra bit set: goes upwards
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Gravity = $04      ; Gravity (00-7F).
!MaxFall = $3E      ; Max Fall Speed in range 00-7F.
!ShakeTime = $28    ; Time to shake the player and the ground.
!Sound = $09        ; Impact sound.
!SoundBank = $1DFC  ; Impact sound bank.
!IdleTime = $40     ; Time to sit on ground after "falling".
!ReturnSpeed = $F0  ; Return Speed. Must be in range 80-FF.

TileDispX:
	db $F0,$00,$10,$F0,$10,$F0,$10,$F0,$00,$10
TileDispY:
	db $E0,$E0,$E0,$F0,$F0,$00,$00,$10,$10,$10
Tilemap:
	db $8A,$8C,$8A,$A0,$A0,$C0,$C0,$E0,$E2,$E0	; body
TileProps:
	db $03,$03,$43,$03,$43,$03,$43,$03,$03,$43	; body
TileIndexes:
	db $00,$0A,$14
	
FaceTileDispX:
	db $F8,$08,$F8,$08
FaceTileDispY:
	db $F0,$F0,$00,$00
FaceTilemap:
	db $EC,$EC,$C1,$C1	; Normal
	db $84,$86,$A4,$A4	; WaitL
	db $86,$84,$A4,$A4	; WaitR
	db $C4,$C4,$E4,$E4	; AngryD
	db $A6,$A6,$E4,$E4	; AngryU(Fix)	;db $C4,$C4,$E4,$E4 ; AngryU
FaceTileProps:
	db $03,$43,$03,$43	; Normal
	db $03,$43,$03,$43	; WaitL
	db $03,$43,$03,$43	; WaitR
	db $03,$43,$03,$43	; AngryD
	db $03,$43,$03,$43	; AngryU
	
print "INIT ",pc
    lda !D8,x
    sta !151C,x
    lda !E4,x
    clc : adc #$08
    sta !E4,x
    
    lda !7FAB10,x
    and #$04
    lsr #2
    sta !1504,x

    rtl

print "MAIN ",pc
    phb : phk : plb
    jsr ThwompMain
    plb
    rtl

Return:
    rts
ThwompMain:
    jsr Graphics
    
    lda !14C8,x
    cmp #$08
    bne Return
    lda $9D
    bne Return
    
    lda #$00
    %SubOffScreen()
    
    stz !1534,x
    jsr InteractionRoutine
    
    lda !C2,x
    jsl $0086DF|!bank
    dw Wait
    dw Fall
    dw Rise

Wait:
    lda !186C,x
    bne .fall
    lda !15A0,x
    bne .return
    
    %SubHorzPos()
    tya
    sta !157C,x
    stz !1528,x
    
    lda $0E
    clc : adc #$40
    cmp #$80
    bcs +
    lda #$01
    sta !1528,x
    lda $0E : bmi +
    inc !1534,x
+   lda $0E
    clc : adc #$24
    cmp #$50
    bcs .return
.fall
    stz !1534,x
    inc !C2,x
    lda #$02
    sta !1528,x
    stz !AA,x
.return
    rts

Fall:
    jsl $01801A|!bank
    ldy !1504,x
    lda !AA,x
    jsr .AbsRoutine
    cmp #!MaxFall
    bcs +
    lda !AA,x
    adc .y_accel,y
    sta !AA,x
+   jsr .objectInteraction
    ldy !1504,x
    lda !1588,x
    and .block_flag,y
    beq .return
    jsr .SomeSlopeSpeed
    ldy #!ShakeTime
    sty $1887|!addr
    lda $77
    and #$04
    beq +
    sty $18BD|!addr
+   lda #!Sound
    sta !SoundBank|!addr
    lda #!IdleTime
    sta !1540,x
    inc !C2,x
.return
    rts

.y_accel
    db !Gravity, -!Gravity

.block_flag
    db $04, $08
    
.AbsRoutine
    bpl +
    eor #$ff
    inc
+   rts

.SomeSlopeSpeed
    lda !1588,x
    bmi +
    lda #$00
    ldy !15B8,x
    beq ++
+   lda #$18
++  sta !AA,x
    rts

.objectInteraction
    lda !D8,x
    pha
    lda !14D4,x
    pha
    lda !1504,x
    beq .call
    
    lda !D8,x
    sec : sbc #$20
    sta !D8,x
    lda !14D4,x
    sbc #$00
    sta !14D4,x
    
.call
    jsl $019138|!bank
    pla
    sta !14D4,x
    pla
    sta !D8,x
    rts

Rise:
    lda !1540,x
    bne .return
    stz !1528,x
    lda !D8,x
    cmp !151C,x
    bne .still_rising
    stz !C2,x
    rts
.still_rising
    ldy !1504,x
    lda .speed,y
    sta !AA,x
    jsl $01801A|!bank
.return
    rts
.speed
    db !ReturnSpeed, -!ReturnSpeed

InteractionRoutine:
    txa : eor $13 : and #$01
    ora !15A0,x
    beq .advance 
.noContact
    clc
    rts
.advance
    lda $71
    bne .noContact
    bit $0D9B|!addr
    bvs .dontCheckLayers
    lda $13F9|!addr
    eor !1632,x
    bne .noContact
.dontCheckLayers
    %SetPlayerClippingAlternate()
    
    rep #$20
    lda.w #$FFF2
    sta $08
    lda.w #$002C
    sta $0C
    lda.w #$FFE0
    sta $0A
    lda.w #$003C
    sta $0E
    sep #$20
    %SetSpriteClippingAlternate()
    
    %CheckForContactAlternate()
    bcc .return
    
    lda $1490|!addr
    bne .star
    
    %SubVertPos()
    lda $0F
    cmp #$CC
    bpl .spriteWins
    lda $140D|!addr
    ora $187A|!addr
    beq .spriteWins
    jsl $01AB99|!bank
    jsl $01AA33|!bank
    lda #$02
    sta $1DF9|!addr
.return
    rts
.spriteWins
    lda !154C,x
    ora !15D0,x
    bne .noHurt
    jsl $00F5B7|!bank
.noHurt
    rts
    
.star
    %Star()
    rts

Graphics:
    lda !1528,x : beq +
    asl : dec
    clc : adc !1534,x
    cmp #$03 : bcc +
    clc : adc !1504,x
    +
    asl #2 : sta $02
    
    %GetDrawInfo()
    phx
    
Face_Graphics:
    ldx #$03
.loop
    stx $04
    lda $00
    clc : adc FaceTileDispX,x
    sta $0300|!addr,y
    lda $01
    clc : adc FaceTileDispY,x
    sta $0301|!addr,y 
    lda FaceTileProps,x
    ora $64
    sta $0303|!addr,y
    
    phx
    lda $02
    clc : adc $04
    tax
    lda FaceTilemap,x
    sta $0302|!addr,y
    plx
    
    iny #4
    dex : bpl .loop
    
Body_Graphics:
    ldx #$09
.loop
    stx $04
    lda $00
    clc : adc TileDispX,x
    sta $0300|!addr,y
    lda $01
    clc : adc TileDispY,x
    sta $0301|!addr,y 
    lda TileProps,x
    ora $64
    sta $0303|!addr,y
    
    lda Tilemap,x
    sta $0302|!addr,y
    
    iny #4
    dex : bpl .loop
    
    plx
    ldy #$02
    lda #$0D
    
    %FinishOAMWrite()
    rts