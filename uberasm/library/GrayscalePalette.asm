; Free RAM addresses for manually uploading the player palettes.
; Need to be the same as in playerpalupdate.asm.
!RAM_PlayerPalPtr = $418AFF
!RAM_PalUpdateFlag = $418B02

main:
	LDA.b #grayscale_palette
	STA !RAM_PlayerPalPtr
	LDA.b #grayscale_palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #grayscale_palette>>16
	STA !RAM_PlayerPalPtr+2
	LDA #$01
	STA !RAM_PalUpdateFlag
	RTL

grayscale_palette:
	dw $2D49,$4E73,$6318,$739C
	dw $3DEF,$6318,$318C,$5ED6
	dw $0C43,$1CC6,$2D6B,$4E73
	dw $739C
