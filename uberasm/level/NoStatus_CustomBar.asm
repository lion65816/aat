load:
	JSL NoStatus_load
	RTL

init:
	JSR Level_69_init
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
	lda $0002,x
	CMP #$EC : BNE +
	; quick player 2 check
	LDA $0DB3|!addr ; demo or iris?
	BEQ ++ ; demo
	LDA #$CE ; iris tile
	BRA +
++	lda $0002,x
+	sta $0202|!addr,y ; tile
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
	STZ $22 : STZ $23
	
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
	
	SEP #$30

	LDA $18CB|!addr
	BNE + : RTS : +
	STA $700360
	DEC : TAX 
	PHA
	LDA mespots,x
	CMP #$60 : BNE +
	; quick player 2 check
	LDA $0DB3|!addr ; demo or iris?
	BEQ ++ ; demo
	LDX #$08 ; change line lel
++	
	LDA mespots,x ; reload because idk what to do
+
	STA $0E : INX
	LDA mespots,x
	STA $0F
	STZ $0D

	LDY $0F
-	LDX $0E : LDA CastleDestructionMessage,x
	LDX $0D : STA $40C000,x
	INC $0E : INC $0D : LDA $0E : CMP $0F : BNE -

	PLA
	JSL $0086DF|!bank
		dw .Line1
		dw .Line2
		dw .Line3
		dw .Line4
		dw .Line5
		dw .Line6
		dw .Line7
		dw .Line8
		dw .nonextline
		
.nonextline
	DEC $18CB|!addr
	RTS

.Line1
	LDA #$52 : STA $02 : LDA #$04 : STA $03
	JMP finish

.Line2
	LDA #$52 : STA $02 : LDA #$24 : STA $03
	JMP finish
.Line3
	LDA #$52 : STA $02 : LDA #$44 : STA $03
	JMP finish
.Line4
	LDA #$52 : STA $02 : LDA #$64 : STA $03
	JMP finish
.Line5
	LDA #$52 : STA $02 : LDA #$84 : STA $03
	JMP finish
.Line6
	LDA #$52 : STA $02 : LDA #$A4 : STA $03
	JMP finish
.Line7
	LDA #$52 : STA $02 : LDA #$C4 : STA $03
	JMP finish
.Line8
	LDA #$52 : STA $02 : LDA #$E4 : STA $03
	JMP finish

finish:
;	LDA #$A2 : STA $02
;	LDA #$52 : STA $03

	rep #$30
	STZ $00
	lda $7F837B
	tax : SEP #$20

	LDY #$0000
-	PHY

;	CPY #$0000
;	BNE +
;	LDA #$53 : STA $02
;+

	LDA $02 : sta $7F837D,x : inx
	LDA $03 : sta $7F837D,x : inx
;	LDA $03 : CLC : ADC #$20 : STA $03
	LDA #$00 : sta $7F837D,x : inx
	LDA #(24*2-1) : sta $7F837D,x : inx
	
	LDY $00
	REP #$20 : LDA $00
	CLC : ADC #$0018 : STA $00
	SEP #$20

--	PHX : TYX : LDA $40C000,x : PLX : sta $7F837D,x : inx
	LDA #$38 : sta $7F837D,x : inx
	INY : CPY $00 : BCC --
	
	PLY : DEY : CPY #$0000 : BPL -
	
	lda #$FF : sta $7F837D,x : INX
	
	rep #$20
	txa
	sta $7F837B
	sep #$30
	RTS

table "fort_table.txt"

; in case any of the organizers want to change it
CastleDestructionMessage:
	db "The  cruel  and  chaotic" ; 00
	db "Craigdarroch  Castle has" ; 18
	db "catastrophically crashed" ; 30
	db "to   kingdom  come.  Can" ; 48
	db "Demo     complete    her" ; 60
	db "conquest   out  of  this" ; 78
	db "confusing conundrum? Cue" ; 90
	db "the quest to the climax!" ; A8

	db "Iris     complete    her" ; C0 only if you're Iris

mespots:
	db $00,$18,$30,$48,$60,$78,$90,$A8,$C0,$D8
