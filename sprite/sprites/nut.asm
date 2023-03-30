;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The nut from SMB3 by Romi (optimized by Blind Devil)
;
;Uses first extra bit: YES
;Clear = Goes right when Mario rides on the nut.
;Set = Goes left
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILE_MAP:		db $C0,$C0,$C0,$C0,$D0		;four entries for top of the nut, one for bottom

X_SPEED:		db $08,$F8
X_SPEED2:		db $F4,$0C
SPEED_TABLE:		db $FF,$01

;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT & MAIN		;
;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc
			LDA !D8,x
			BNE INIT_00
			DEC !14D4,x
INIT_00:		DEC !D8,x
			LDA !7FAB10,x
			AND #$04
			LSR #2
			STA !157C,x
			RTL

			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR SPRITE_ROUTINE
			JSR OBJECT_CONTACT
			JSR SPEED_SETTING
			JSR SPRITE_GFX
			PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;
;Main sprite routine	;
;;;;;;;;;;;;;;;;;;;;;;;;;

MARIO_VERT_POS:		db $10,$12,$15,$17,$19,$1B,$1C,$1D,$1E,$1F,$1F,$20
MARIO_HORZ_POS:		db $1C,$F4
MARIO_HORZ_POS2:	db $00,$FF
MARIO_X_CHECK:		db $80,$00

X_POS_FOR_OBJ:		db $12,$FD
X_POS_FOR_OBJB:		db $00,$FF
X_POS_FOR_OBJ2:		db $01,$08

IS_DEAD:		JSL $01802A|!BankB
			RTS
SPRITE_ROUTINE:		LDA $9D
			BNE RETURN
			LDA #$00
			%SubOffScreen()
			LDA !151C,x
			BNE IS_DEAD

			LDA !1540,x
			BEQ CONTACT_CHECK
			PHA
			LDY !157C,x
			LDA X_SPEED,y
			STA !B6,x
			%SubHorzPos()
			LDA $0E
			CLC
			ADC #$0C
			CMP #$28
			BCC IS_RIDDEN_CONTACT
			PLA
			STZ !1540,x
			STZ $1471|!Base2
			BRA IS_RIDDEN_Y_SPEED
IS_RIDDEN_CONTACT:	PLA
			DEC A
			TAY
			LDA #$04
			STA !154C,x
			LDA $16
			ORA $18
			BMI MARIO_JUMPED
			LDA !D8,x
			SEC
			SBC MARIO_VERT_POS,y
			STA $96
			LDA !14D4,x
			SBC #$00
			STA $97
IS_RIDDEN_ON:		LDA #$01
			STA $1471|!Base2
IS_RIDDEN_Y_SPEED:	LDA #$10
			STA $7D
			RTS
MARIO_JUMPED:		STZ !1540,x
RETURN:			RTS

CONTACT_CHECK:		LDA !154C,x
			BNE RETURN
			JSL $01A7DC|!BankB
			BCC RETURN
			%SubVertPos()
			LDA $0F
			CMP #$EB
			BPL VERT_POS_CHECK
			LDA $7D
			BMI RETURN
MARIO_RIDE_ON:		LDA !D8,x
			SEC
			SBC #$1F
			STA $96
			LDA !14D4,x
			SBC #$00
			STA $97
			LDA !1558,x
			BNE IS_RIDDEN_ON
			LDA #$0C
			STA !1540,x
			BRA IS_RIDDEN_ON
VERT_POS_CHECK:		PHA
			%SubHorzPos()
			LDA $0E
			CLC
			ADC #$08
			CMP #$20
			BCS SIDES_TOUCH
			LDA #$F4
			LDY $19
			BEQ SMALL_MARIO
			LDY $73
			BNE SMALL_MARIO
			LDA #$00
SMALL_MARIO:		STA $00
			PLA
			CMP $00
			BMI RETURN2
			LDA $7D
			BPL RETURN2
			LDA #$10
			STA $7D
			LDY !157C,x
			LDA X_SPEED2,y
			STA !B6,x
RETURN2:		RTS

SIDES_TOUCH:		PLA
			LDA $7B
			CMP MARIO_X_CHECK,y
			BMI RETURN2
			LDA !E4,x
			CLC
			ADC MARIO_HORZ_POS,y
			STA $94
			LDA !14E0,x
			ADC MARIO_HORZ_POS2,y
			STA $95
			STZ $7B
			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;Speed setting		;
;;;;;;;;;;;;;;;;;;;;;;;;;

SPEED_SETTING:		LDA $9D
			BNE SPEED_F_RETURN
			TXA
			EOR $13
			AND #$01
			BNE SPEED_RETURN
			LDY #$00
			LDA !B6,x
			BEQ SPEED_RETURN
			BPL SPEED_NOT_MINUS
			INY
SPEED_NOT_MINUS:	CLC
			ADC SPEED_TABLE,y
			STA !B6,x

SPEED_RETURN:		JSL $018022|!BankB
			LDA $1491|!Base2
			LDY !157C,x
			BEQ NOT_EXTRA
			EOR #$FF
			INC A
NOT_EXTRA:		CLC
			ADC !1602,x
			STA !1602,x
SPEED_F_RETURN:		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;Object contact		;
;;;;;;;;;;;;;;;;;;;;;;;;;

OBJECT_CONTACT:		LDA !151C,x
			BNE SPEED_F_RETURN
			LDY #$00
			LDA !B6,x
			BPL SPEED_NOT_MINUS2
			INY
SPEED_NOT_MINUS2:	JSR SUB_OBJECT
			LDA !1588,x
			BNE OBJ_02
			LDA $1860|!Base2
			BNE OBJ_CONTACT2
			LDA $1862|!Base2
			DEC A
			BNE OBJ_CONTACT2
OBJ_02:			LDA !1540,x
			BEQ OBJ_00
			JSR MARIO_RIDE_ON

OBJ_00:			STZ $B6,x
			RTS
OBJ_CONTACT2:		JSR SUB_OBJECT2
			BCC OBJ_RETURN
			TYA
			EOR #$01
			TAY
			JSR SUB_OBJECT
			JSR SUB_OBJECT2
			BCC OBJ_RETURN
			INC !151C,x
			LDA #$91
			STA !1686,x
OBJ_RETURN:		RTS

SUB_OBJECT:		PHY
			LDA !E4,x
			PHA
			CLC
			ADC X_POS_FOR_OBJ,y
			STA !E4,x
			LDA !14E0,x
			PHA
			ADC X_POS_FOR_OBJB,y
			STA !14E0,x
			JSL $019138|!BankB
			PLA
			STA !14E0,x
			PLA
			STA !E4,x
			PLY
			RTS

SUB_OBJECT2:		LDA $185F|!Base2
			CMP #$25
			BNE OBJ_01
			LDA $18D7|!Base2
			BNE OBJ_01
			SEC
			RTS
OBJ_01:			CLC
			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite GFX		;
;;;;;;;;;;;;;;;;;;;;;;;;;

TILE_SIZE:		db $02,$02,$02,$00,$00
HORZ_DISP:		db $00,$08,$10,$18,$18
VERT_DISP:		db $00,$00,$00,$00,$08

SPRITE_GFX:		%GetDrawInfo()

			LDA !1602,x
			AND #$03
			STA $03

			PHX
			LDX #$04

GFX_LOOP:		LDA $00
			CLC
			ADC HORZ_DISP,x
			STA $0300|!Base2,y
			LDA $01
			CLC
			ADC VERT_DISP,x
			STA $0301|!Base2,y
			LDA TILE_MAP,x
			CLC
			ADC $03
			STA $0302|!Base2,y
			PHX
			LDX $15E9|!Base2
			LDA !15F6,x
			ORA $64
			STA $0303|!Base2,y
			PLX
			PHY
			TYA
			LSR #2
			TAY
			LDA TILE_SIZE,x
			STA $0460|!Base2,y
			PLY
			INY
			INY
			INY
			INY
			DEX
			BPL GFX_LOOP

			PLX
			LDY #$FF
			LDA #$04
			JSL $01B7B3|!BankB
			RTS