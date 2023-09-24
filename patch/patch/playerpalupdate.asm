;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Manual Player Palette Update Patch, by imamelia
;;
;; This patch allows up to change the player's palette on the fly (in the middle of
;; a level or whatever you want) by setting a flag in RAM.
;;
;; Usage instructions:
;;
;; To change the player's palette, store a 24-bit pointer to the new color values
;; to !RAM_PlayerPalPtr and set whatever bit of !RAM_PalUpdateFlag is specified
;; (bit 0 by default).  Note that this flag must be set every frame you want to use
;; the custom palette; it clears every time the palette upload routine is run, and
;; the colors don't carry over into the next frame.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
	!RAM_PlayerPalPtr = $418AFF
	!RAM_PalUpdateFlag = $418B02
else
	lorom
	!bank = $800000
	!RAM_PlayerPalPtr = $7FA034
	!RAM_PalUpdateFlag = $7FA00B
endif

!FlagValue = $01

org $00A309
	autoclean JML PlayerPaletteHack

freecode

PlayerPaletteHack:
	LDA !RAM_PalUpdateFlag
	AND.w #!FlagValue
	BEQ .NormalPalette
	;LDY #$86
	LDY #$83					;> AAT edit: Player colors use more of the palette.
	STY $2121
	LDA #$2200
	STA $4320
	LDA !RAM_PlayerPalPtr
	STA $4322
	LDA !RAM_PlayerPalPtr+1
	STA $4323
	;LDA #$0014
	LDA #$001A					;> AAT edit: Player colors use more of the palette.
	STA $4325
	STX $420B
	LDA !RAM_PalUpdateFlag
	AND.w #!FlagValue^$FFFF
	STA !RAM_PalUpdateFlag
.NoUpdate
	JML $00A328|!bank

.NormalPalette
	LDY #$86
	STY $2121
	JML $00A30E|!bank

print "Freespace used: ",freespaceuse," bytes."