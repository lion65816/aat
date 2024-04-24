; Free RAM addresses for manually uploading the player palettes.
; Need to be the same as in playerpalupdate.asm.
!RAM_PlayerPalPtr = $418AFF
!RAM_PalUpdateFlag = $418B02

; Free RAM. Needs to be the same address in global_code.asm.
!PaletteUsed = $18B7|!addr

load:
	JSL NoStatus_load
	RTL
main:	
	LDA #$04
	STA !RAM_PalUpdateFlag
	STA !PaletteUsed
	RTL
