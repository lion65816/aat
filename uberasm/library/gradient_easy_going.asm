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

	RTL

.Table1
	db $04,$4D,$9C
	db $08,$4E,$9C
	db $08,$4F,$9C
	db $08,$50,$9C
	db $09,$51,$9D
	db $09,$52,$9D
	db $0A,$53,$9D
	db $0A,$54,$9D
	db $0B,$55,$9D
	db $0B,$56,$9D
	db $0D,$57,$9D
	db $09,$58,$9D
	db $04,$58,$9E
	db $10,$59,$9E
	db $12,$5A,$9E
	db $17,$5B,$9E
	db $2A,$5C,$9E
	db $0B,$5D,$9E
	db $00

.Table2
	db $02,$20
	db $05,$21
	db $05,$22
	db $06,$23
	db $05,$24
	db $06,$25
	db $05,$26
	db $06,$27
	db $06,$28
	db $07,$29
	db $06,$2A
	db $06,$2B
	db $07,$2C
	db $07,$2D
	db $08,$2E
	db $08,$2F
	db $08,$30
	db $09,$31
	db $09,$32
	db $0B,$33
	db $0B,$34
	db $0D,$35
	db $10,$36
	db $16,$37
	db $1E,$38
	db $00
