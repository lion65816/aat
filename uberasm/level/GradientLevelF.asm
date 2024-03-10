;=======================================
; Mode 2 + Mode 0 COLDATA Gradient
; Channels: Red, Green, Blue
; Table Size: 60
; No. of Writes: 224
; 
; Generated by GradientTool
;=======================================

; Set up the HDMA gradient.
; Uses HDMA channels 3 and 4.
init:
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

	main:
	STZ $1413|!addr
	REP #$20
	LDA $1462|!addr
	EOR #$FFFF
	LSR A
	STA $1466|!addr
	SEP #$20

	RTL ; <-- Can also be RTL.

; --- HDMA Tables below this line ---
Gradient1_RedGreenTable:
db $24,$24,$43
db $02,$25,$44
db $01,$26,$44
db $02,$26,$45
db $04,$27,$45
db $01,$27,$46
db $06,$28,$46
db $05,$29,$47
db $01,$2A,$47
db $02,$2A,$48
db $80,$2B,$48
db $24,$2B,$48
db $00

Gradient1_BlueTable:
db $24,$85
db $01,$86
db $02,$87
db $03,$88
db $05,$89
db $04,$8A
db $04,$8B
db $03,$8C
db $03,$8D
db $80,$8E
db $23,$8E
db $00
