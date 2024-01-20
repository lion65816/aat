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
	;> Draw filter sign for cape.
	LDA #$08					;\ Request 8 tiles
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
	dw $C048,$B048,$A048		; Sign post
	dw $9040,$9050,$8040,$8050	; Sign face (tile order: down -> up, left -> right)
	dw $8848					; Sign icon (cape)

TileProps:						; High byte = YXPPCCCT, low byte = tile number
	dw $29C9,$29C9,$29C9		; Sign post
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (tile order: down -> up, left -> right)
	dw $240E					; Sign icon (cape)
