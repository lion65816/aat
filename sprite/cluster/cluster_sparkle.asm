;; Happy Moon sparkle
;; by Sonikku
;; Description: a small yellow sparkle that falls down. intended to trail off of the Happy Moon sprite

print "MAIN ",pc
Main:
	JSR +
	RTL
+	JSR .subgfx
	LDA $9D
	BEQ +
.return	RTS
+	LDA $1E3E|!Base2,y
	XBA
	LDA $1E16|!Base2,y
	REP #$20
	SEC
	SBC $1A
	CLC
	ADC #$FFFC
	CMP #$00F8
	SEP #$20
	BCS .killspr
	LDA $0F5E|!Base2,y
	BNE +
.killspr
	LDA #$00
	STA $1892|!Base2,y
	RTS
+	DEC
	STA $0F5E|!Base2,y
+
	LDA $14
	AND #$01
	BNE +
	LDA $1E02|!Base2,y
	CLC
	ADC #$01
	STA $1E02|!Base2,y
+	RTS

.subgfx
	LDA $0F5E|!Base2,x
	LSR : LSR
	STA $02

	LDX.w .oam_slots,y
	LDA $1E02|!Base2,y
	SEC
	SBC $1C
	STA $0201|!Base2,x
	LDA $1E16|!Base2,y
	SEC
	SBC $1A
	STA $0200|!Base2,x
	PHX
	LDX $02
	LDA .tilemap,x
	PLX
	STA $0202|!Base2,x
	LDA #$04
	ORA $64
	STA $0203|!Base2,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA #$00
	STA $0420|!Base2,x
	PLX
	LDA $0201|!Base2,x
	CMP #$F0
	BCC +
	LDA #$00
	STA $1892|!Base2,y
+	RTS
.tilemap
	db $66,$6E,$FF,$6D,$6C,$5C
.oam_slots
	db $40,$44,$48,$4C,$50,$54,$58,$5C,$60,$64,$68,$6C,$80,$84,$88,$8C,$B0,$B4,$B8,$BC
