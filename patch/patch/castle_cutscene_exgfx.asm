;====================================================
; Custom Castle Destruction Cutscene (Ex-)GFX v1.0
; by KevinM
;
; This patch allows you to load custom GFX or ExGFX in any of
; the 7 vanilla castle destruction cutscenes.
; To do so, edit the tables sp1-4 and fg1-3,bg1 below.
; 
; Note: this patch has a couple limitations:
; - You can't load a GFX in slots BG2-BG3.
; - You can only use (Ex-)GFX numbers $00-$FF.
;====================================================

; SA-1 compatibility stuff.
if read1($00FFD5) == $23
    sa1rom
    !sa1 = 1
    !dp = $3000
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !dp = $0000
    !addr = $0000
    !bank = $800000
endif

; Hijacks.
org $00A9DF
    autoclean jml sprite_gfx

org $00AA20
    autoclean jml fg_bg_gfx

freedata

; These are the tables you need to edit.
; Each one is indexed by cutscene number (1-7), same order as LM's Boss Sequence Levels dialog.
fg1:
    db $8B,$8F,$93,$97,$14,$9D,$9A
fg2:
    db $8C,$90,$94,$98,$17,$9E,$9B
bg1:
    db $8D,$91,$95,$99,$19,$9F,$9C
fg3:
    db $8E,$92,$96,$8E,$2C,$A0,$8E
sp1:
    db $00,$00,$00,$00,$00,$00,$00
sp2:
    db $22,$22,$22,$22,$22,$22,$22
sp3:
    db $85,$86,$87,$88,$13,$8A,$89
sp4:
    db $2D,$83,$83,$2D,$2D,$83,$2D

; Actual code. Don't edit from here if you don't know what you're doing!
sprite_gfx:
    ; If not in a destruction sequence, return.
    ldx $13C6|!addr : beq .orig
    cpx #$08 : bcs .orig

.cutscene:
    ; Load custom GFX numbers and return.
    lda.l sp1-1,x : sta $07
    lda.l sp2-1,x : sta $06
    lda.l sp3-1,x : sta $05
    lda.l sp4-1,x : sta $04
    jml $00A9F0|!bank

.orig:
    ; Restore original code and return.
    ldx #$03
    lda $192B|!addr
    jml $00A9E4|!bank

fg_bg_gfx:
    ; If not in a destruction sequence, return.
    ldx $13C6|!addr : beq .orig
    cpx #$08 : bcs .orig

.cutscene:
    ; Load custom GFX numbers and return.
    lda.l fg1-1,x : sta $07
    lda.l fg2-1,x : sta $06
    lda.l bg1-1,x : sta $05
    lda.l fg3-1,x : sta $04
    jml $00AA31|!bank

.orig:
    ; Restore original code and return.
    ldx #$03
    lda $1931|!addr
    jml $00AA25|!bank  
