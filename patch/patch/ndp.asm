;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Non-Dynamic Podoboo Patch, by imamelia
;;
;; This patch changes the way the Podoboo uses graphics.  Instead of using the
;; tiles normally used by Yoshi, it instead uses graphics from SP3 or SP4 and gets
;; them the same way any other sprite would.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	sa1rom
endif

; change the Podoboo's tilemap
org $019C35
db $67,$67,$77,$77,$68,$68,$78,$78,$77,$77,$67,$67,$78,$78,$68,$68
; 06 06 16 16 07 07 17 17 16 16 06 06 17 17 07 07

; change a JSR to a JMP, bypassing the dynamic GFX routine
org $01E19A
db $4C

; make the sprite use the second GFX page
org $07F431
db $35
