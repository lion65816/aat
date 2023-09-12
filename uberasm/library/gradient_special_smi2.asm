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
	db $01,$36,$42
	db $0D,$37,$42
	db $0D,$38,$43
	db $0F,$39,$44
	db $10,$3A,$45
	db $11,$3B,$46
	db $13,$3C,$47
	db $16,$3D,$48
	db $1A,$3E,$49
	db $26,$3F,$4A
	db $2C,$3F,$4B
	db $00

.Table2
	db $05,$80
	db $0B,$81
	db $0C,$82
	db $0D,$83
	db $0E,$84
	db $0E,$85
	db $10,$86
	db $12,$87
	db $14,$88
	db $19,$89
	db $24,$8A
	db $28,$8B
	db $00
