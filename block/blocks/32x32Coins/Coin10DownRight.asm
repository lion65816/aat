;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 32x32 coin by EternityLarva
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "32x32coin [down right][10coins]"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get coins config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(effect flag is enable)
; $00 - 10coins
; $01 - 30coins
; $02 - 50coins
;(effect flag is disable)
; $xx - coins number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!coins = $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; position config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 0 - up left
; 1 - up right
; 2 - down right
; 3 - down left
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!block_pos = 2


db $42
JMP Mario : JMP Mario : JMP Mario
JMP Sprite : JMP Sprite : JMP Return : JMP Return
JMP Mario : JMP Mario : JMP Mario


Mario:
	incsrc 32x32CoinMain.asm
Sprite:
Return:
	RTL
