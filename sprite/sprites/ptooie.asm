;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ptooie, from SMB3 by Romi (optimized by Blind Devil)
;
;Uses first extra bit: YES
;Clear	: Stays in pipe
;Set	: Walks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite data		;
;;;;;;;;;;;;;;;;;;;;;;;;;

PIRANHA_TILE:		db $AC,$CE,$AE,$CE	;piranha head, piranha stem (static)
			db $AC,$C0,$AE,$C0	;piranha head, piranha stem (walking)

PIRANHA_PROP:		db $08,$0A,$08,$0B	;piranha head pal/prop, piranha stem (static) pal/prop, piranha head pal/prop, piranha stem (walking) pal/prop

TILE_AND_PROP:		db $E0,$03		;spiky ball tile, spiky ball YXPPCCCT properties

X_SPEED:		db $0C,$F4

TABLE_00:		db $E8,$D0
TABLE_01:		db $EC,$E4

;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT & MAIN		;
;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc
			LDA #$F0
			STA !1504,x
			LDA !7FAB10,x
			AND #$04
			BNE INIT_01
			LDA !E4,x
			ORA #$08
			STA !E4,x
			LDA !D8,x
			BNE INIT_02
			DEC !14D4,x
INIT_02:		DEC A
			STA !D8,x
INIT_01:		RTL

			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR SPRITE_ROUTINE
			PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;
;SPRITE_ROUTINE		;
;;;;;;;;;;;;;;;;;;;;;;;;;

DEATH:			LDA !C2,x
			INC A
			BEQ DEATH_00
			STZ !B6,x
			LDA !1534,x
			STA !AA,x
			LDA !1504,x
			CLC
			ADC !D8,x
			STA !D8,x
			LDA !14D4,x
			ADC #$FF
			STA !14D4,x
			LDA #$FF
			STA !C2,x
			LDA #$1F
			STA !1540,x
DEATH_00:		JSR SPIKE_GFX_DRAW
			LDA !D8,x
			PHA
			LDA !14D4,x
			PHA
			JSR CLOUD_GFX_DRAW
			PLA
			STA !14D4,x
			PLA
			STA !D8,x
RETURN4:		RTS

SPRITE_ROUTINE:		JSR SPRITE_GFX
			JSR SPRITE_GFX2

			LDA !14C8,x
			CMP #$08
			BNE DEATH
			LDA $9D
			BNE RETURN4
			LDA #$00
			%SubOffScreen()
			INC !1570,x
			LDA !D8,x
			STA !151C,x
			LDA !14D4,x
			STA !1528,x

			LDA !D8,x
			PHA
			LDA !14D4,x
			PHA
			LDA !AA,x
			PHA
			LDA !1534,x
			STA !AA,x
			JSL $01801A|!BankB
			LDA $1491|!Base2
			CLC
			ADC !1504,x
			STA !1504,x
			PLA
			STA !AA,x
			PLA
			STA !14D4,x
			PLA
			STA !D8,x

			LDA #$FF
			LDY !C2,x
			BPL LABEL_00
			LDA !7FAB10,x
			AND #$04
			LSR #2
			TAY
			LDA !1504,x
			CMP TABLE_01,y
			BCC LABEL_FF
			LDA !C2,x
			AND #$7F
			INC A
			CMP #$03
			BNE LABEL_FE
			LDA #$00
LABEL_FE:		STA !C2,x
			LDA #$0C
			STA !1534,x
LABEL_FF:		LDA #$01
LABEL_00:		CLC
			ADC !1534,x
			STA !1534,x

			TYA
			BMI LABEL_01
			LDA !C2,x
			AND #$03
			LSR A
			TAY
			LDA !1534,x
			CMP TABLE_00,y
			BNE LABEL_01
			LDA !C2,x
			ORA #$80
			STA !C2,x
LABEL_01:		JSL $01A7DC|!BankB

			LDA !7FAB10,x
			AND #$04
			BEQ RETURN
			LDY !157C,x
			LDA X_SPEED,y
			STA !B6,x
			JSL $01802A|!BankB
			LDA !1588,x
			BIT #$03
			BEQ WALK_00
			AND #$01
WALK_02:		STA !157C,x
			RTS
WALK_00:		AND #$04
			BNE WALK_01
			LDA #$20
			STA !1558,x
			LDA !157C,x
			EOR #$01
			BRA WALK_02
WALK_01:		LDA !1558,x
			BNE RETURN
			LDA !157C,x
			EOR #$01
			STA !157C,x
			JSL $01ACF9|!BankB
			AND #$0F
			ORA #$30
			STA !1558,x
RETURN:			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;SPRITE_GFX		;
;;;;;;;;;;;;;;;;;;;;;;;;;

PROPERTY:		db $00,$40
PIRANHA_VERT:		db $00,$10,$F7,$07

SPRITE_GFX:		LDA !14C8,x
			CMP #$08
			BNE RETURN

			%GetDrawInfo()

			LDA !7FAB10,x
			AND #$04
			STA $03
			LSR A
			STA $0F
			LDA !C2,x
			BPL GFX_LABEL00
			LDA $03
			ORA #$02
			STA $03
GFX_LABEL00:		LDA !1570,x
			LSR #3
			AND #$01
			STA $0E

			PHX
			LDX #$01
GFX_LOOP:		PHX
			LDA $00
			STA $0300|!Base2,y
			PHX
			TXA
			ORA $0F
			TAX
			LDA $01
			CLC
			ADC PIRANHA_VERT,x
			STA $0301|!Base2,y
			LDA PIRANHA_PROP,x
			ORA $64
			STA $0303|!Base2,y
			PLX
			TXA
			ORA $03
			TAX
			LDA PIRANHA_TILE,x
			STA $0302|!Base2,y
			PLX
			INY
			INY
			INY
			INY
			DEX
			BPL GFX_LOOP
			LDA $03
			AND #$04
			BEQ GFX_LABEL01
			LDX $0E
			LDA $02FB|!Base2,y
			ORA PROPERTY,x
			STA $02FB|!Base2,y
GFX_LABEL01:		PLX

			LDY #$02
			LDA #$01
			JSL $01B7B3|!BankB
			LDA !15EA,x
			CLC
			ADC #$08
			STA !15EA,x
RETURN2:		RTS

SPRITE_GFX2:		LDA !14C8,x
			CMP #$08
			BNE RETURN2

			LDA !D8,x
			PHA
			CLC
			ADC !1504,x
			STA !D8,x
			LDA !14D4,x
			PHA
			ADC #$FF
			STA !14D4,x
			LDA $9D
			BNE SPIKE_GFX
			LDA !14C8,x
			CMP #$08
			BNE SPIKE_GFX
			STZ !1662,x
			JSL $01A7DC|!BankB
			LDA !7FAB10,x
			AND #$04
			BNE SPIKE_GFX
			INC !1662,x
SPIKE_GFX:		JSR SPIKE_GFX_DRAW
			PLA
			STA !14D4,x
			PLA
			STA !D8,x
			RTS

SPIKE_GFX_DRAW:		LDA !1570,x
			AND #$04
			LSR A
			LSR A
			TAY
			LDA PROPERTY,y
			ORA $64
			STA $03
			STZ $02

			%GetDrawInfo()

			LDA !14C8,x
			CMP #$08
			BNE SPIKE_GFX01
			LDA $9D
			BNE SPIKE_GFX01
			JSL $01ACF9|!BankB
			AND #$03
			DEC A
			DEC A
			CLC
			ADC $00
			STA $00
SPIKE_GFX01:		REP #$20
			LDA $00
			STA $0300|!Base2,y
			LDA TILE_AND_PROP
			ORA $02
			STA $0302|!Base2,y
			SEP #$20
			LDA #$00
			LDY #$02
			JSL $01B7B3|!BankB
			LDA !15EA,x
			CLC
			ADC #$04
			STA !15EA,x
RETURN3:		RTS

CLOUD_GFX_DRAW:		LDA !151C,x
			STA !D8,x
			LDA !1528,x
			STA !14D4,x

			LDA !1540,x
			BEQ RETURN3
			LSR #3
			STA $03
			%GetDrawInfo()

			REP #$20
			LDA $00
			STA $0300|!Base2,y
			SEP #$20
			PHX
			LDX $03
			LDA.l $019A4E|!BankB,x
			STA $0302|!Base2,y
			LDA $64
			STA $0303|!Base2,y
			PLX
			LDA #$00
			LDY #$02
			JSL $01B7B3|!BankB
			RTS