;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Nuts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
!tile = $60

!mata_debiles_fireballs = 0
!mata_debiles_cape_spin = 0
!mata_debiles_estrella = 1
!mata_debiles_slide = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT", pc
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
    JSR SUB_GFX             ; draw hammer bro gfx
    LDA !14C8,x             ; \ if hammer bro status != 8...
    CMP #$08
    BNE RETURN              ; /    ... return
    LDA $9D                 ; \ if sprites locked...
    BNE RETURN              ; /    ... return

    LDA #$00
    %SubOffScreen()
    jsr interaction
    JSL $01802A|!bank             ; update position based on speed values
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:
    %GetDrawInfo()       ; after: Y = index to sprite tile map ($300)
    PHX                     ; push sprite index

    LDA $00                 ; \ tile x position = sprite x location ($00)
    STA $0300|!addr,y             ; /                    

    LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
    STA $0301|!addr,y             ; /

    LDA #!tile
    STA $0302|!addr,y             ; / 

    LDA #$00
    LDX $15E9|!addr               ;  |
    ORA !15F6,x             ;  | get palette info
    ORA $64                 ;  | ?? what is in 64, level properties... disable layer priority??
    ORA #$01                ;  | use the second graphics page
    STA $0303|!addr,y             ; / store tile properties

    PLX                     ; pull, X = sprite index

    LDY #$02
    LDA #$00                ;  | A = number of tiles drawn - 1
    %FinishOAMWrite()            ; / don't draw if offscreen
    RTS                     ; return

!get_sprite_clipping_a = $03B69F|!bank
!get_sprite_clipping_b = $03B6E5|!bank
!check_contact = $03B72B|!bank


interaction:
    jsl !get_sprite_clipping_b
    txy 
    phx 
    ldx.b #!SprSize-1
.loop
    cpx $15E9|!addr
    beq .next_sprite
    lda !14C8,x
    cmp #$08
    bcc .next_sprite
    lda !1686,x
    and #$08
    ora !1564,x
    ora !1632,x
    bne .next_sprite
    if !mata_debiles_estrella == 1
        lda !167A,x
        and #$02
        beq .found_sprite
    endif
    if !mata_debiles_fireballs == 1
        lda !166E,x
        and #$10
        beq .found_sprite
    endif
    if !mata_debiles_cape_spin == 1
        lda !166E,x
        and #$20
        beq .found_sprite
    endif
    if !mata_debiles_slide == 1
        lda !190F,x
        and #$04
        beq .found_sprite
    endif
.next_sprite
    dex 
    bpl .loop
    plx 
    rts 

.found_sprite
    jsl !get_sprite_clipping_a
    jsl !check_contact
    bcc .next_sprite
    phy 
    phx 
    tyx 
    inc !1626,x
    lda !1626,x
    cmp #$08
    bcc +
    lda #$08
    sta !1626,x
+   
    ldy !1626,x
    lda .sound,y
    sta $1DF9|!addr
    stz $00
    stz $01
    lda #$08
    sta $02
    lda #$02
    %SpawnSmoke()
    plx 
    ply 
    lda #$02
    sta !14C8,x
    lda #$D0
    sta !AA,x
    lda #$E8
    sta !B6,x
    lda.w !B6,y
    bmi +
    lda #$18
    sta !B6,x
+   
    lda !1626,y
    jsl $02ACE5|!bank
    jmp .next_sprite

.sound    
    db $00,$13,$14,$15,$16,$17,$18,$19,$03