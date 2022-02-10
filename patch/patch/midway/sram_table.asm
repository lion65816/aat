@includefrom "sram_plus.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SRAM Plus, SRAM table
;
; This patch basically rewrites all of the SRAM saving, loading, and erasing
; save file routines that SMW uses. It uses DMA to copy the values, meaning that
; it is much more efficient than before. The patch also frees up 141 bytes at
; $1F49 by moving the SRAM buffer to $1EA2.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file controls what addresses are saved to the SRAM, and their default
; values.
;
; To add a RAM address to the list, simply put dl $xxxxxx : dw $yyyy on a new
; line under sram_table, where $xxxxxx is the RAM address and $yyyy is the
; number of bytes to save. DO NOT get rid of the "dl $7E1EA2 : dw $008D".
;
; For example, to save Mario and Luigi's lives, coins, powerup, item box, and
; yoshi color, you would use:
;
;		dl $7E0DB4 : dw $000A
;
; as these addresses range from $7E0DB4 to $7E0DBD, taking up a total of $000A
; bytes. Note that this actually doesn't work AS IS, though - you need to
; disable the game from automatically clearing those specific addresses when
; loading a save file.
;
; Once this is done, you must supply what the default values for the RAM
; addresses will be. This can be done by placing the appropriate number of
; bytes under sram_defaults, in order.
;
; There is a maximum of 8190 bytes that can be saved to SRAM for any save file.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sram_table:	dl $7E1EA2 : dw $008D
		dl $7FB4D9 : dw $0060
.end
		
sram_defaults:	db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00

		fillbyte $00 : fill $0060