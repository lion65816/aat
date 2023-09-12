;===================================================
; Customizable Layer 1/2 Horizontal/Vertical Smash
; by KevinM
;===================================================

; Controls which layer is affected (only use 1 or 2!).
!layer = 2

; Controls the direction of the layer.
; 0 = horizontal (for vertical levels)
; 1 = vertical (for horizontal levels)
; Note that the scrolling for the layer in this direction should be set to "None" in LM.
!direction = 1

; SFX to play when smashing down.
; !smash_sfx = $00 -> no SFX.
!smash_sfx      = $00
!smash_sfx_addr = $1DFC|!addr

; Set this to stop horizontal layer 1 (camera) scrolling.
; Useful for vertical levels.
!stop_horz_scroll = 0

; In the following tables, each row is used for a screen and
; each value in a row is used for one of the 3 phases (top, middle, bottom).
; In screens where you don't want the layer to move, use $0000 for the speed and $00 for the timer for all phases.
; I put some example values in the tables to show how it works.

; Layer position in each phase, for each screen.
position:
    dw $00B0,$00B0,$0060 ; 0
    dw $00B0,$00B0,$0060 ; 1
    dw $00B0,$00B0,$0060 ; 2
    dw $00B0,$00B0,$0060 ; 3
    dw $00B0,$00B0,$0060 ; 4
    dw $00B0,$00B0,$0060 ; 6
    dw $00B0,$00B0,$0060 ; 7
    dw $00B0,$00B0,$0060 ; 8
    dw $00B0,$00B0,$0060 ; 9
    dw $00B0,$00B0,$0060 ; A
    dw $00B0,$00B0,$0060 ; B
    dw $00B0,$00B0,$0060 ; C
    dw $00B0,$00B0,$0060 ; D
    dw $00B0,$00B0,$0060 ; E
    dw $00B0,$00B0,$0060 ; F

; Layer speed when coming back to the top/going to the middle/smashing down, for each screen.
; Use $0000 if you want to "skip" a phase (the timer will be waited without movement).
; For non-zero values, the sign depends on the position values: if you want the position
; to increase, you'll set a positive value, otherwise a negative value.
; For example, to replicate a vanilla smash you'd use a positive value for the first, and negative for the third.
speed:
    dw  $0200, $0000,-$0200 ; 0 this doesn't move at all
    dw  $0200, $0000,-$0200 ; 1 this moves up and smashes down without hesitation
    dw  $0200, $0000,-$0200 ; 2 this moves up and smashes down, but hesitates by going down slower before smashing
    dw  $0200, $0000,-$0200 ; 3 this moves up and smashes down, but hesitates by going back up slower before smashing
    dw  $0200, $0000,-$0200 ; 4 this moves down and smashes up, without hesitation.
    dw  $0200, $0000,-$0200 ; 5
    dw  $0200, $0000,-$0200 ; 6
    dw  $0200, $0000,-$0200 ; 7
    dw  $0200, $0000,-$0200 ; 8
    dw  $0200, $0000,-$0200 ; 9
    dw  $0200, $0000,-$0200 ; A
    dw  $0200, $0000,-$0200 ; B
    dw  $0200, $0000,-$0200 ; C
    dw  $0200, $0000,-$0200 ; D
    dw  $0200, $0000,-$0200 ; E
    dw  $0200, $0000,-$0200 ; F

; How long to wait before moving in each phase, for each screen.
timer:
    db $04,$04,$04 ; 0
    db $04,$04,$04 ; 1
    db $04,$04,$04 ; 2
    db $04,$04,$04 ; 3
    db $04,$04,$04 ; 4
    db $04,$04,$04 ; 5
    db $04,$04,$04 ; 6
    db $04,$04,$04 ; 7
    db $04,$04,$04 ; 8
    db $04,$04,$04 ; 9
    db $04,$04,$04 ; A
    db $04,$04,$04 ; B
    db $04,$04,$04 ; C
    db $04,$04,$04 ; D
    db $04,$04,$04 ; E
    db $04,$04,$04 ; F

; How long to shake the screen when smashing ($00 = no shake).
; This table only has one value for each screen.
shake_timer:
    db $00 ; 0
    db $00 ; 1
    db $00 ; 2
    db $00 ; 3
    db $00 ; 4
    db $00 ; 5
    db $00 ; 6
    db $00 ; 7
    db $00 ; 8
    db $00 ; 9
    db $00 ; A
    db $00 ; B
    db $00 ; C
    db $00 ; D
    db $00 ; E
    db $00 ; F

; Defines and stuff. Don't change these!
function offset(addr,x) = (addr)+(4*(!layer-1))+(2*(x))
!phase       #= $1443|!addr
!timer       #= $1444|!addr
!shake_timer #= $1887|!addr
!screen      #= offset($1463|!addr,1-!direction)
!position    #= offset($1462|!addr,!direction)
!position_c  #= offset($1A,!direction)
!speed       #= offset($1446|!addr,!direction)
!fraction    #= offset($144E|!addr,!direction)

init:
    stz !phase
    stz !timer

if !stop_horz_scroll
    stz $1411|!addr
endif

    ; This makes the layer 2 not teleport on the first frame.
    jsl main_run
    rep #$20
    lda !position : sta !position_c
    sep #$20
    rtl

main:
    ; Don't run if the game is paused or during No Yoshi intros.
    lda $9D : ora $13D4|!addr : bne .return
    lda $71 : cmp #$0A : beq .return
.run:
    lda !timer : beq +
    dec !timer
    rtl
+   phb : phk : plb
    lda !screen : asl : clc : adc !screen
    asl : adc !phase : tay
    lsr : tax
    rep #$20
    lda !position : sec : sbc.w position,y
    eor.w speed,y : bpl +
    lda.w speed,y : sta !speed
    jsr update_layer_position
    sep #$20
    plb
    rtl
+   lda.w position,y : sta !position
    sep #$20
    lda.w timer,x : sta !timer
    beq .return2
    lda !phase : clc : adc #$02
    cmp #$06 : bcc +
    lda.b #!smash_sfx : sta !smash_sfx_addr
    ldx !screen
    lda.w shake_timer,x : sta !shake_timer
    lda #$00
+   sta !phase
.return2:
    plb
.return:
    rtl

update_layer_position:
    lda !fraction : and #$00FF
    clc : adc !speed : sta !fraction
    and #$FF00
    bpl +
    ora #$00FF
+   xba : clc : adc !position : sta !position
    rts
