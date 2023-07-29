load:
    lda #$01
    sta $13E6|!addr
	
    ;rtl
    
init:
	STZ $1B96|!addr
	RTL
	
main:
	LDA $0DBE|!addr
	INC A
	JSL $00974C ; HexToDec
	STA $7FC071
	TXA
	STA $7FC070
	; screen scroll pipe logic thing
;	LDA $62
;	BEQ +
;	JSR Level_69
;+

	LDY #$B0
	LDA #$10 : STA $00
	LDA #$10 : STA $01

	LDA #$00 ; one tile
;	asl a
	tax
	rep #$30
	lda HEALTH_POS,x
	tax
	SEP #$20
	

	lda $0000,x
	CLC : ADC $1420|!addr ; + amount of dragon coins
	sta $0F;!frame_count
	inx
-
	lda $0000,x : clc : adc $00 : sta $0200|!addr,y ; x
	lda $0001,x : clc : adc $01 : sta $0201|!addr,y ; y
	lda $0002,x : sta $0202|!addr,y ; tile
	lda #$30 : sta $0203|!addr,y ; prop
	phy : REP #$20 : tya : lsr #2 : tay : SEP #$20
	lda $0003,x : sta $0420|!addr,y ; tile size
	ply
	iny #4 : inx #4
	dec $0F;!frame_count
	bne -
	SEP #$10
	RTL

HEALTH_POS:
	dw whatever


whatever:
	; default value
	db $04
	
	; (Demo) x00
	db $00,$C0,$EC,$02	;\
	db $14,$C4,$88,$00	;| Y-positions (2nd byte) modified for Level 5.
	db $1C,$C4,$98,$00	;|
	db $24,$C4,$99,$00	;/

	; dragon coins
	db $B8,$04,$89,$00
	db $C0,$04,$89,$00
	db $C8,$04,$89,$00
	db $D0,$04,$89,$00
	db $D8,$04,$89,$00
