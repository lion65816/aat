init:
	JSL DisableSideExit_init
	RTL

main:
	JSL freezetimer_main

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
	JSL DrawSign_main			;> Input parameters are $00-$07.
	RTL

TileCoord:						; YYXX
	dw $B088,$A088				; Sign post
	dw $9080,$9090,$8080,$8090	; Sign face (bottom) (tile order: down -> up, left -> right)
	dw $7080,$7090,$6080,$6090	; Sign face (middle) (tile order: down -> up, left -> right)
	dw $5080,$5090,$4080,$4090	; Sign face (top) (tile order: down -> up, left -> right)
	dw $8888,$6888,$4888		; Sign icons (bottom to top: cape, fire, mushroom)

TileProps:						; High byte = YXPPCCCT, low byte = tile number
	dw $29C9,$29C9				; Sign post
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (bottom) (tile order: down -> up, left -> right)
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (middle) (tile order: down -> up, left -> right)
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (top) (tile order: down -> up, left -> right)
	dw $240E,$2A26,$2824		; Sign icons (bottom to top: cape, fire, mushroom)
