load:
	JSL NoStatus_load
	RTL

init:
	JSR Level_69_init
	rtl

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
	JSR Level_69
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
	db $00,$00,$EC,$02
	db $14,$04,$88,$00
	db $1C,$04,$98,$00
	db $24,$04,$99,$00

	; dragon coins
	db $B8,$04,$89,$00
	db $C0,$04,$89,$00
	db $C8,$04,$89,$00
	db $D0,$04,$89,$00
	db $D8,$04,$89,$00


; stuff specifically for the boss fight
; little better for space if it's just global for both Level 128 and Level 69 with a check for one
Level_69_init:
	LDA $010B|!addr
	CMP #$69
	BNE +
	LDA $94
	CLC : ADC #$08
	STA $94 : STA $D1
	LDA #$09 : STA $1DFC|!addr
	ASL A : STA $1887|!addr
	LDA #$FF : STA $1DFB|!addr
+	RTS
Level_69:
	LDA $010B|!addr
	CMP #$69
	BEQ + : RTS : +
	
	LDA $18C5|!addr
	BNE +
	REP #$20
	LDA $96
	SEP #$20
	BPL ++
	INC $18C5|!addr
	BRA +++
++	LDA #$A0 : STA $7D
	LDA #$01 : STA $1412|!addr : STA $1404|!addr
	BRA +++
+	
	LDY #$10
-	REP #$20
	LDA $1463|!addr
	BNE +++
	INC $1A : INC $1462|!addr
	INC $94 : INC $D1
	SEP #$20
	DEY
	BPL -
+++
	SEP #$20
	
	LDA $13EF|!addr
	BEQ +
	STZ $1412|!addr
+
	
	
	RTS