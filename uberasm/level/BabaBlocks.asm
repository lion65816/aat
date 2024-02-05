; Free RAM addresses for manually uploading the player palettes.
; Need to be the same as in playerpalupdate.asm.
!RAM_PlayerPalPtr = $418AFF
!RAM_PalUpdateFlag = $418B02

; Free RAM. Needs to be the same address in global_code.asm.
!PaletteUsed = $18B7|!addr

load:
	JSL HoldYoshi_load
	RTL

init:
	JSL RequestRetry_init
	JSL BabaBlocks_init
	RTL

main:
	; If Iris, then give her Demo's palette.
	LDA $0DB3|!addr
	BEQ .skip
	LDA #$45					;\ Restore the translevel number
	STA $13BF|!addr				;/ in case it was changed last frame.
	LDA $1F2C|!addr				;\ Display Iris-only message
	BNE +						;| when Iris enters the level
	LDA #$44					;| for the first time.
	STA $13BF|!addr				;| Requires an SRAM flag.
	LDA #$02					;| The message is stored in
	STA $1426|!addr				;| 120-2, so need to briefly
	LDA #$01					;| switch the translevel number.
	STA $1F2C|!addr				;/ It is restored next frame.
+
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

	JSL RequestRetry_main
	JSL BabaBlocks_main
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
