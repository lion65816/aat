!topEdge = $00A0	; where the "top" wrap point is
!botEdge = $01A0	; where the "bottom" wrap point is
!dist = !botEdge-!topEdge

init:
	JSL DisableSideExit_init
	JSR draw_sign_prep
	JSL DrawSign_init			;> Input parameters are $00-$07.
	RTL

main:
	JSL freezetimer_main
	JSR draw_sign_prep
	JSL DrawSign_main			;> Input parameters are $00-$07.

	LDA $9D
	BNE .noWrap
	JSR WrapMario
	JSR WrapSprites
.noWrap
	RTL

draw_sign_prep:
	;> Draw filter signs for mushroom, fire, and cape.
	LDA #$11					;\ Request 17 tiles
	STA $00						;| to draw the signs.
	STZ $01						;/
	LDA.b #TileCoord			;\ Store 24-bit address
	STA $02						;| to the tile coordinate data.
	LDA.b #TileCoord>>8			;|
	STA $03						;|
	LDA.b #TileCoord>>16		;|
	STA $04						;/
	LDA.b #TileProps			;\ Store 24-bit address
	STA $05						;| to the tile property data.
	LDA.b #TileProps>>8			;|
	STA $06						;|
	LDA.b #TileProps>>16		;|
	STA $07						;/
	RTS

WrapMario:
	LDA $13E0|!addr		; don't wrap if dead
	CMP #$3E
	BEQ .noWrap
	REP #$20
	LDA $96
	CMP #!botEdge
	BMI .checkAbove
	SEC : SBC #!dist
	STA $96
	BRA .noWrap
.checkAbove
	CMP #!topEdge
	BPL .noWrap
	CLC : ADC #!dist
	STA $96
.noWrap
	SEP #$20
	RTS


WrapSprites:
	LDX #!sprite_slots-1
.loop
	LDA !14C8,x
	BEQ .skip
	CMP #$02
	BEQ .skip
	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	CMP #!botEdge
	BMI .checkAbove
	SEC : SBC #!dist
	SEP #$20
	STA !D8,x
	XBA
	STA !14D4,x
	BRA .skip
.checkAbove
	CMP #!topEdge
	BPL .skip
	CLC : ADC #!dist
	SEP #$20
	STA !D8,x
	XBA
	STA !14D4,x
.skip
	SEP #$20
	DEX
	BPL .loop
	RTS

TileCoord:						; YYXX
	dw $B088,$A088				; Sign post
	dw $9080,$9090,$8080,$8090	; Sign face (bottom) (tile order: down -> up, left -> right)
	dw $7080,$7090,$6080,$6090	; Sign face (middle) (tile order: down -> up, left -> right)
	dw $5080,$5090,$4080,$4090	; Sign face (top) (tile order: down -> up, left -> right)
	dw $8888,$6888,$4888		; Sign icons (bottom to top: cape, fire, "A")

TileProps:						; High byte = YXPPCCCT, low byte = tile number
	dw $29C9,$29C9				; Sign post
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (bottom) (tile order: down -> up, left -> right)
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (middle) (tile order: down -> up, left -> right)
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (top) (tile order: down -> up, left -> right)
	dw $240E,$2A26,$2280		; Sign icons (bottom to top: cape, fire, "A")
