;=======================================
; Mode 2 + Mode 0 COLDATA Gradient
; Channels: Red, Green, Blue
; Table Size: 130
; No. of Writes: 224
; 
; Generated by GradientTool
;=======================================

; Set up the HDMA gradient.
; Uses HDMA channels 3 and 4.
init:
	JSL clusterspawn_uberASM_init
	REP   #$20 ; 16-bit A

	; Set transfer modes.
	LDA   #$3202
	STA   $4330 ; Channel 3
	LDA   #$3200
	STA   $4340 ; Channel 4

	; Point to HDMA tables.
	LDA   #Gradient1_RedGreenTable
	STA   $4332
	LDA   #Gradient1_BlueTable
	STA   $4342

	SEP   #$20 ; 8-bit A

	; Store program bank to $43x4.
	PHK
	PLA
	STA   $4334 ; Channel 3
	STA   $4344 ; Channel 4

	; Enable channels 3 and 4.
	LDA.b #%00011000
	TSB   $6D9F

	RTL ; <-- Can also be RTL.

; --- HDMA Tables below this line ---
Gradient1_RedGreenTable:
db $0E,$20,$45
db $04,$20,$46
db $04,$20,$47
db $04,$20,$48
db $8F,$20,$49,$21,$49,$23,$4A,$24,$4B,$26,$4B,$27,$4C,$28,$4D,$2A,$4E,$2B,$4F,$2B,$50,$2C,$51,$2D,$51,$2E,$52,$2F,$53,$30,$54
db $02,$31,$55
db $01,$32,$56
db $02,$33,$57
db $8D,$34,$58,$35,$58,$35,$59,$36,$5A,$37,$5A,$37,$5B,$38,$5B,$38,$5C,$39,$5D,$3A,$5D,$3B,$5E,$3B,$5F,$3C,$5F
db $02,$3D,$5F
db $02,$3E,$5F
db $80,$3F,$5F
db $21,$3F,$5F
db $00

Gradient1_BlueTable:
db $0D,$8A
db $02,$8B
db $02,$8C
db $02,$8D
db $02,$8E
db $02,$8F
db $02,$90
db $02,$91
db $01,$92
db $02,$93
db $83,$94,$95,$96
db $02,$98
db $86,$99,$9A,$9B,$9C,$9D,$9E
db $80,$9F
db $37,$9F
db $00
