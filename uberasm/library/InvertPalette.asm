; Free RAM addresses for manually uploading the player palettes.
; Need to be the same as in playerpalupdate.asm.
!RAM_PlayerPalPtr = $418AFF
!RAM_PalUpdateFlag = $418B02

; Free RAM. Needs to be the same address in global_code.asm.
!PaletteUsed = $18B7|!addr

main:

	LDA $0DB3|!addr 
	CMP #$00
	BNE .Iris
	JML .Demo

	.Iris
	LDA $19
	CMP #$03
	BEQ .IrisFirePal
	JML .IrisPal
	
	.IrisFirePal
	LDA.b #iris_fire_palette
	STA !RAM_PlayerPalPtr
	LDA.b #iris_fire_palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #iris_fire_palette>>16
	STA !RAM_PlayerPalPtr+2
	LDA #$01
	STA !RAM_PalUpdateFlag
	STA !PaletteUsed
	JML .return

	
	.IrisPal
	LDA.b #iris_palette
	STA !RAM_PlayerPalPtr
	LDA.b #iris_palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #iris_palette>>16
	STA !RAM_PlayerPalPtr+2
	LDA #$01
	STA !RAM_PalUpdateFlag
	STA !PaletteUsed
	JML .return


	.Demo
	LDA $19
	CMP #$03
	BEQ .DemoFirePal
	JML .DemoPal
	
	.DemoFirePal
	LDA.b #demo_fire_palette
	STA !RAM_PlayerPalPtr
	LDA.b #demo_fire_palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #demo_fire_palette>>16
	STA !RAM_PlayerPalPtr+2
	LDA #$01
	STA !RAM_PalUpdateFlag
	STA !PaletteUsed
	JML .return

	
	.DemoPal
	LDA.b #demo_palette
	STA !RAM_PlayerPalPtr
	LDA.b #demo_palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #demo_palette>>16
	STA !RAM_PlayerPalPtr+2
	LDA #$01
	STA !RAM_PalUpdateFlag
	STA !PaletteUsed
	JML .return
	
	.return
	RTL

demo_palette:
	dw $7FCC,$7DE1,$74E1,$1881
	dw $5E86,$3941,$5294,$214C
	dw $5FFE,$473D,$2E9C,$0D77
	dw $044A
	
demo_fire_palette:
	dw $7FCC,$7DE1,$74E1,$1881
	dw $5E86,$3941,$5294,$214C
	dw $7FF4,$7FEF,$5F62,$3DC1
	dw $1D41

iris_palette:
	dw $3792,$2A6D,$1187,$1881
	dw $5E86,$3941,$5294,$214C
	dw $76FE,$6E7D,$556D,$4571
	dw $394F

iris_fire_palette:
	dw $3792,$2A6D,$1187,$1881
	dw $5E86,$3941,$5294,$214C
	dw $5FFA,$4FF3,$37AC,$2368
	dw $0A62


