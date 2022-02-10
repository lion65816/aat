;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Silent Bullet Bill has now got sound!			;
; Made by Ramp202					;
; Description: Since people (mostly mods) complained	;
; about how the Bullet bills when placed in a level	;
; are silent and don't play any SFX, i decided to make	;
; this patch. REQUIRES 11 (0B) bytes of			;
; Freespace/Empty Space in the rom			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!bank = $000000
	!1540 = $32C6
else
	lorom
	!addr = $0000
	!bank = $800000
	!1540 = $1540
endif

;;;;;;;;;;;
; Defines ;
;;;;;;;;;;;

		!SFX = $09			; The Sound the Bullet Bill will make
		!SFXBank = $1DFC|!addr		; The Bank the SFX will be uploaded from.

;;;;;;;;;;;;;;;;;;
; Start of Patch ;
;;;;;;;;;;;;;;;;;;

org $0184E3|!bank			; Hijack the Init Code of the Bullet Bill
	autoclean JSL MakeSFX
	NOP				; NOP out the extra byte that's left over


freecode

MakeSFX:		LDA #!SFX	;\ Make SFX
			STA !SFXBank	;/
			LDA #$10	;\ Restore Hijacked Code
			STA !1540,x	;/
			RTL