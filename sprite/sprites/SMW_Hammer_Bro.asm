;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SMW Hammer Bro
; Disassembled by Sonikku
; Description: Like the original Hammer Bro, but it 
; doesn't rely on the gray flying blocks. You can place 
; this one anywhere, and he will stay stationary, throwing
; hammers at Mario.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HammerFreq:	db $1F,$1F,$1F,$1F,$1F,$1F,$1F	;> AAT edit: originally $1F,$0F,$0F,$0F,$0F,$0F,$0F

HammerBroDispX:		db $08,$10,$00,$10
HammerBroDispY:		db $F8,$F8,$00,$00

HammerBroTiles:		db $5A,$4A,$46,$48,$4A,$5A,$48,$46
HammerBroTileSize:	db $00,$00,$02,$02

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init and main jsl targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB
                    PHK
                    PLB
                    JSR HammerBro
                    PLB
		print "INIT ",pc
                    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hammer bro sprite routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HammerBro:
	JSR HammerBroGfx
	LDA $9D
	BNE RETURN
	LDA #$08
	CMP !14C8,x
	BNE DEAD
	JSL $01803A|!BankB
	LDA #$00
	%SubOffScreen()
	LDY $0DB3|!Base2
	LDA $1F11|!Base2,y
	TAY
	LDA $13
	AND #$03
	BEQ CODE_02DA89
	INC !1570,x
CODE_02DA89:
	LDA !1570,x
	ASL
	CPY #$00
	BNE CODE_02DA92		;\ AAT edit: Fixes a bug where slow hammers (i.e., $1F)
	;BEQ CODE_02DA92	;/ are only thrown on one side.
	ASL
CODE_02DA92:
	AND #$40
	STA !157C,x
	LDA !1570,x
	AND HammerFreq,y
	ORA !15A0,x
	ORA !186C,x
	ORA !1540,x
	BNE RETURN
	LDA #$03
	STA !1540,x
	LDY #$10
	LDA !157C,x
	BNE CODE_02DAB6
	LDY #$F0
CODE_02DAB6:
	STY $00
	LDY #$07
CODE_02DABA:
	LDA $170B|!Base2,y
	BEQ GenerateHammer
	DEY
	BPL CODE_02DABA
RETURN:
	RTS
DEAD:
	STZ !157C,x
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; generate hammers routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GenerateHammer:
	LDA #$04
	STA $170B|!Base2,y
	LDA !E4,x
	STA $171F|!Base2,y
	LDA !14E0,x
	STA $1733|!Base2,y
	LDA !D8,x
	STA $1715|!Base2,y
	LDA !14D4,x
	STA $1729|!Base2,y
	LDA #$D0
	STA $173D|!Base2,y
	LDA $00
	STA $1747|!Base2,y
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hammer bro graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HammerBroGfx:
	%GetDrawInfo()
	LDA !157C,x
	STA $02
	PHX
	LDX #$03
CODE_02DB08:
	LDA $00
	CLC
	ADC HammerBroDispX,x
	STA $0300|!Base2,y
	LDA $01
	CLC
	ADC HammerBroDispY,x
	STA $0301|!Base2,y
	PHX
	LDA $02
	PHA
	ORA #$37
	STA $0303|!Base2,y
	PLA
	BEQ CODE_02DB2A
	INX
	INX
	INX
	INX
CODE_02DB2A:
	LDA HammerBroTiles,x
	STA $0302|!Base2,y
	PLX
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA HammerBroTileSize,x
	STA $0460|!Base2,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	BPL CODE_02DB08
	PLX
	LDY #$FF
	LDA #$03
	JSL $01B7B3|!BankB
	RTS