init:
	LDA #$00
	STA $4330
	LDA #$02
	STA $4340

	LDA #$32
	STA $4331
	STA $4341

	REP #$20
	LDA.w #.Table2
	STA $4332
	LDA.w #.Table1
	STA $4342

	SEP #$20

	LDA.b #.Table2>>16
	STA $4334
	LDA.b #.Table1>>16
	STA $4344

	LDA #$18
	TSB $0D9F|!addr

	; Filter flower and cape powerups.
	LDA $19
	BEQ +
	LDA #$01
	STA $19
+	LDA $0DC2|!addr
	BEQ +
	LDA #$01
	STA $0DC2|!addr
+	RTL

.Table1
db $12,$29,$9D
db $21,$28,$9C
db $0A,$27,$9C
db $15,$27,$9B
db $17,$26,$9B
db $0A,$26,$9A
db $20,$25,$9A
db $02,$24,$9A
db $1F,$24,$99
db $0B,$23,$99
db $15,$23,$98
db $0C,$22,$98
db $00

.Table2
db $0D,$4B
db $0C,$4C
db $0C,$4D
db $0C,$4E
db $0C,$4F
db $0C,$50
db $0C,$51
db $0C,$52
db $0C,$53
db $0C,$54
db $0E,$55
db $0C,$56
db $0C,$57
db $0C,$58
db $0C,$59
db $0C,$5A
db $0C,$5B
db $0C,$5C
db $05,$5D
db $00
