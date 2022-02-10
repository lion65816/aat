;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Stretch from SMB3 by Romi (optimized by Blind Devil)
;
;Uses first extra bit: YES
;Clear	:rises from the top of the platform
;Set	:rises from the bottom of the platform
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
;SPRITE_DATA		;
;;;;;;;;;;;;;;;;;;;;;;;;;

TILE_MAP:		db $E0,$E2,$E4,$E6

TIME_TO_MOVE:		db $28,$70

X_SPEED:		db $10,$F0
POS_TABLE:		db $0C,$F4
POS_TABLE2:		db $00,$FF

Y_POSITION:		db $F4,$F7,$FA,$FD
			db $0A,$07,$04,$01

;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT & MAIN		;
;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc
			LDA !7FAB10,x
			AND #$04
			STA !1534,x
			LDA !D8,x
			STA !1504,x
			LDA !14D4,x
			STA !151C,x
			LDY #$00
			LDA $94
			CMP !E4,x
			LDA $95
			SBC !14E0,x
			BPL INIT_END
			INY
INIT_END:		TYA
			STA !157C,x
			LDA #$10
			STA !1540,x
			RTL

			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR SPRITE_ROUTINE
			JSR SPRITE_GFX
			PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;
;SPRITE_ROUTINE		;
;;;;;;;;;;;;;;;;;;;;;;;;;

RETURNLOL:		RTS
SPRITE_ROUTINE:		LDA !14C8,x
			CMP #$08
			BNE RETURNLOL
			LDA $9D
			BNE RETURNLOL
			LDA #$00
			%SubOffScreen()
			JSL $018022|!BankB
			LDY !157C,x
			LDA X_SPEED,y
			STA !B6,x

			LDA !C2,x
			BNE MODE_2
			LDA #$03
			STA !1602,x
MODE_1_FINAL:		LDY !157C,x
			LDA !D8,x
			PHA
			LDA !14D4,x
			PHA
			LDA !1504,x
			STA !D8,x
			LDA !151C,x
			STA !14D4,x
			LDA !E4,x
			PHA
			CLC
			ADC POS_TABLE,y
			STA !E4,x
			LDA !14E0,x
			PHA
			ADC POS_TABLE2,y
			STA !14E0,x
			JSL $019138|!BankB
			LDA $1860|!Base2
			CMP #$40
			BNE DIR_CHANGE
			LDA $1862|!Base2
			DEC A
			BEQ OBJ_END
DIR_CHANGE:		LDA !157C,x
			EOR #$01
			STA !157C,x
OBJ_END:		PLA
			STA !14E0,x
			PLA
			STA !E4,x
			PLA
			STA !14D4,x
			PLA
			STA !D8,x
			LDA !1540,x
			BNE MODE_1_RETURN
			LDA #$1F
			LDY !C2,x
			BEQ MODE_1_1540
			AND #$0F
MODE_1_1540:		STA !1540,x
			INC !C2,x
MODE_1_RETURN:		RTS

MODE_2:			PHA
			JSL $01A7DC|!BankB
			PLA
			AND #$01
			BEQ MODE_1_FINAL
			STZ !B6,x
			LDA #$FF
			STA $01
			PHP
			LDY !C2,x
			LDA !1540,x
			BNE MODE_2_B
			PLP
			TYA
			STA !1602,x
			STA $01
			INC A
			AND #$03
			STA !C2,x
			LSR A
			PHY
			TAY
			LDA TIME_TO_MOVE,y
			STA !1540,x
			PLY
			PHP
MODE_2_B:		DEY
			BEQ MODE_2_A
			EOR #$18
MODE_2_A:		LSR #3
			PLP
			BPL MODE_2_E
			STA !1602,x
MODE_2_E:		ORA !1534,x
			TAY
			LDA $01
			BMI MODE_2_D
			ORA !1534,x
			TAY
MODE_2_D:		STZ $00
			LDA Y_POSITION,y
			BPL MODE_2_C
			DEC $00
MODE_2_C:		CLC
			ADC !1504,x
			STA !D8,x
			LDA !151C,x
			ADC $00
			STA !14D4,x
RETURN:			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;SPRITE_GFX		;
;;;;;;;;;;;;;;;;;;;;;;;;;

TILE_PROP:		db $70,$30

SPRITE_GFX:		LDA !C2,x
			BEQ RETURN
			%GetDrawInfo()

			PHX
			LDA !1534,x
			PHA
			LDA !157C,x
			PHA
			LDA !1602,x
			PHA

			REP #$20
			LDA $00
			STA $0300|!Base2,y
			SEP #$20
			PLX
			LDA TILE_MAP,x
			STA $0302|!Base2,y
			PLX
			LDA TILE_PROP,x
			PLX
			BEQ STORE_0303
			ORA #$80
STORE_0303:		LDX $15E9|!Base2
			ORA !15F6,x			
			STA $0303|!Base2,y

			PLX
			LDY #$02
			LDA #$00
			JSL $01B7B3|!BankB
			RTS