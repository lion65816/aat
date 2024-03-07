; Free RAM addresses for manually uploading the player palettes.
; Need to be the same as in playerpalupdate.asm.
!RAM_PlayerPalPtr = $418AFF
!RAM_PalUpdateFlag = $418B02

; Free RAM. Needs to be the same address in global_code.asm.
!PaletteUsed = $18B7|!addr

main:
	; If Iris, then give her Demo's palette.
	LDA $0DB3|!addr
	BEQ .skip
	LDA $19
	CMP #$03
	BEQ .fire
	LDA.b #demo_palette
	STA !RAM_PlayerPalPtr
	LDA.b #demo_palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #demo_palette>>16
	STA !RAM_PlayerPalPtr+2
	BRA .upload
.fire
	LDA.b #fire_palette
	STA !RAM_PlayerPalPtr
	LDA.b #fire_palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #fire_palette>>16
	STA !RAM_PlayerPalPtr+2
.upload
	LDA #$01
	STA !RAM_PalUpdateFlag
	STA !PaletteUsed
.skip
	RTL

demo_palette:
	dw $0054,$023F,$0F3F,$6B9F
	dw $259A,$4ADF,$318C,$62D4
	dw $2422,$3CE3,$5584,$76A9
	dw $7FD6

fire_palette:
	dw $0054,$023F,$0F3F,$6B9F
	dw $259A,$4ADF,$318C,$62D4
	dw $000C,$0011,$24BE,$465F
	dw $7FFF
