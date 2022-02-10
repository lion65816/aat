;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Gusty from YI by Romi (optimized by Blind Devil)
;
;Uses first extra bit: YES
;Clear = Normal speed
;Set = Faster speed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILE_MAP:		db $A4,$A6,$B6,$A7,$B7
			db $A4,$A6,$B6,$A8,$B8
			db $A4,$A6,$B6,$A9,$B9
			db $A4,$A6,$B6,$AE,$BE

MAX_X_SPEED:		db $30,$D0
			db $40,$C0
SPEED_TABLE:		db $01,$FF

;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT & MAIN		;
;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc
			STZ !157C,x
			LDA $94
			CMP !E4,x
			LDA $95
			SBC !14E0,x
			BPL INIT_END
			INC !157C,x
INIT_END:		RTL

			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR SPRITE_ROUTINE
			JSR SPRITE_GFX
			PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;
;Main sprite routine	;
;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_ROUTINE:		LDA !14C8,x
			CMP #$08
			BNE RETURN
			LDA $9D
			BNE RETURN
			LDA #$00
			%SubOffScreen()

			INC !1570,x

			LDA $7FAB10,x
			AND #$04
			LSR A
			ORA !157C,x
			TAY
			LDA !B6,x
			CMP MAX_X_SPEED,y
			BEQ FINAL
			LDY !157C,x
			LDA !B6,x
			CLC
			ADC SPEED_TABLE,y
			STA !B6,x
FINAL:			JSL $018022|!BankB
			JSL $01A7DC|!BankB

RETURN:			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite GFX		;
;;;;;;;;;;;;;;;;;;;;;;;;;

TILE_VERT:		db $FF,$00,$08,$01,$09
			db $00,$FF,$07,$00,$08
			db $01,$00,$08,$FF,$07
			db $00,$01,$09,$00,$08

TILE_HORZ:		db $10,$08,$08,$00,$00
			db $00,$10,$10,$18,$18

TILE_SIZE:		db $02,$00,$00,$00,$00
TILE_PROP:		db $40,$00

SPRITE_GFX:		%GetDrawInfo()

			LDA !1570,x
			LSR #2
			AND #$03
			STA $03
			ASL #2
			CLC
			ADC $03
			STA $03

			PHX
			LDX #$04
GFX_LOOP:		PHX

			PHY
			TYA
			LSR #2
			TAY
			LDA TILE_SIZE,x
			STA $0460|!Base2,y
			PLY

			PHX
			PHY
			LDY TILE_HORZ,x
			PHX
			LDX $15E9|!Base2
			LDA !157C,x
			PLX
			CMP #$00
			BEQ NO_FLIP_HORZ
			TXA
			CLC
			ADC #$05
			TAX
			LDY TILE_HORZ,x
NO_FLIP_HORZ:		TYA
			CLC
			ADC $00
			PLY
			STA $0300|!Base2,y
			PLX

			PHX
			TXA
			CLC
			ADC $03
			TAX
			LDA $01
			CLC
			ADC TILE_VERT,x
			STA $0301|!Base2,y

			LDA TILE_MAP,x
			STA $0302|!Base2,y
			PLX

			PHY
			LDX $15E9|!Base2
			LDY !157C,x
			LDA TILE_PROP,y
			ORA !15F6,x
			ORA $64
			PLY
			STA $0303|!Base2,y

			INY
			INY
			INY
			INY

			PLX
			DEX
			BPL GFX_LOOP

			PLX
			LDY #$FF
			LDA #$04
			JSL $01B7B3|!BankB
			RTS