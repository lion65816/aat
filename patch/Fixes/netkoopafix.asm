;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Net Climbing Koopa Turning Fix
;by Ice Man
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SA-1 Check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	; SA-1 base addresses
	sa1rom
	!sa1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!9E = $3200
	!1540 = $32C6
else
	; Non SA-1 base addresses
	lorom
	!sa1 = 0
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!9E = $9E
	!1540 = $1540
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Hijacks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $01B97F|!bank
	autoclean JML NetKoopaFix			;Fix Net Climbing Koopa Turning
	NOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;RATS Tag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freecode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NetKoopaFix:
	LDA !9E,x
	CMP #$23							;Check for Red Koopa (H)
	BEQ RedKoopa
	CMP #$25							;Check for Red Koopa (V)
	BEQ RedKoopa

GreenKoopa:
	LDA !1540,x							;This gets set to #$50 by default.
	BEQ CODE_01B9FB
	CMP #$30							;About to turn yet?
	BCC CODE_01B9A0
	CMP #$40							;Turn around now.
	BCC CODE_01B9A3
	JML $01B98C|!bank

RedKoopa:
	LDA !1540,x
	BEQ CODE_01B9FB
	CMP #$30							;About to turn yet?
	BCC CODE_01B9A0
	CMP #$48							;Turn 8 frames earlier, if Red Koopa
	BCC CODE_01B9A3
	JML $01B98C|!bank

CODE_01B9A0:
	JML $01B9A0|!bank

CODE_01B9A3:
	JML $01B9A3|!bank

CODE_01B9FB:
	JML $01B9FB|!bank
