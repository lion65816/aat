init:
	JSL DisableSideExit_init
	JSR draw_sign_prep
	JSL DrawSign_init			;> Input parameters are $00-$07.
	RTL

main:
	JSL freezetimer_main
	JSR draw_sign_prep
	JSL DrawSign_main			;> Input parameters are $00-$07.
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

TileCoord:						; YYXX
	dw $C048,$B048				; Sign post
	dw $A040,$A050,$9040,$9050	; Sign face (bottom) (tile order: down -> up, left -> right)
	dw $8040,$8050,$7040,$7050	; Sign face (middle) (tile order: down -> up, left -> right)
	dw $6040,$6050,$5040,$5050	; Sign face (top) (tile order: down -> up, left -> right)
	dw $9848,$7848,$5848		; Sign icons (bottom to top: cape, fire, mushroom)

TileProps:						; High byte = YXPPCCCT, low byte = tile number
	dw $29C9,$29C9				; Sign post
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (bottom) (tile order: down -> up, left -> right)
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (middle) (tile order: down -> up, left -> right)
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (top) (tile order: down -> up, left -> right)
	dw $240E,$2A26,$2824		; Sign icons (bottom to top: cape, fire, mushroom)
