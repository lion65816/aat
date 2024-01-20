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
	;> Draw filter signs for fire and cape.
	LDA #$0D					;\ Request 13 tiles
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
	dw $B088,$A088,$9088		; Sign post
	dw $8080,$8090,$7080,$7090	; Sign face (bottom) (tile order: down -> up, left -> right)
	dw $6080,$6090,$5080,$5090	; Sign face (top) (tile order: down -> up, left -> right)
	dw $7888,$5888				; Sign icons (bottom to top: cape, fire)

TileProps:						; High byte = YXPPCCCT, low byte = tile number
	dw $29C9,$29C9,$29C9		; Sign post
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (bottom) (tile order: down -> up, left -> right)
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (top) (tile order: down -> up, left -> right)
	dw $240E,$2A26				; Sign icons (bottom to top: cape, fire)
