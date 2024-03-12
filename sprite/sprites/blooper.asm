;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Blooper from SMB1 by Romi (optimized by Blind Devil),converted by Thiago678 ;
;Uses first extra bit: NO                                                    ;
;Description: This is a blooper from SMB1,he follows the player and he dies  ;
;when jumped on when it's out of water.                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
;SPRITE_DATA		;
;;;;;;;;;;;;;;;;;;;;;;;;;

TILE_MAP:		db $EB,$EA,$FA,$EB,$EB,$FB,$EB,$EB,$FB
VER_DISP:		db $F8,$00,$08,$00,$00,$08,$08,$08,$00
HORZ_DISP:		db $00,$08
TILE_PROP:		db $00,$40

INIT_SPEED:		db $06,$FA
SPEED_TABLE:	db $03,$FD
X_SPEED:		db $30,$D0		;right / left
Y_SPEED:		db $08,$E8,$F2		;down / up / up slow

;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT & MAIN		;
;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc
			LDA #$10
			STA !1558,x
			RTL

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

SPRITE_ROUTINE:		JSR SPRITE_GFX

			LDA !14C8,x
			CMP #$08
			BNE RETURN
			LDA $9D
			BNE RETURN
			LDA #$00
			%SubOffScreen()
			JSL $018032

MOVE_ROUTINE:		JSR SPRITE_MOVING

			LDA #$00
			LDY $75
			BNE MARIO_SWIM
			LDA #$10
MARIO_SWIM:		STA !1656,x

			JSL $018022|!BankB
			JSL $01801A|!BankB

			JSL $01A7DC|!BankB
RETURN:			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;SPRITE_MOVING		;
;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_MOVING:		
			STZ $03
			LDA !1558,x
			BEQ NOT_DRAW
			LDA #$01
			STA !1602,x
			STZ !B6,x
			JSL $01ACF9|!BankB
			AND #$03
			ASL #3
			CLC
			ADC #$18
			STA !1540,x
JUMP_POINT:		JMP Y_SPEED_SET

NOT_DRAW:		STZ !1602,x
			LDA !151C,x
			BNE ALREADY_SETTING
			JSR SUB_VERT_POS_Alt
			TYA
			BEQ JUMP_POINT
ALREADY_SETTING:	LDA !1540,x
			BNE Y_SPEED_SET
			INC $03
			LDA !151C,x
			BNE SKIP_SETTING
			STZ $00
			JSL $01ACF9|!BankB
			AND #$01
			ORA !1504,x
			BNE NOT_CHANGE_DIR
			INC $00
NOT_CHANGE_DIR:		%SubHorzPos()
			TYA
			EOR $00
			TAY
			STA !157C,x
			STA !C2,x
			LDA INIT_SPEED,y
			STA !B6,x
			INC !151C,x
			LDA #$1D
			STA !163E,x

SKIP_SETTING:		LDA !163E,x
			CMP #$0D
			BNE NOT_CHECK
			JSL $01ACF9|!BankB
			AND #$03
			CMP !1504,x
			BNE NOT_CHECK
			JSR FLIP_STATE_1

NOT_CHECK:		LDY !C2,x
			TYA
			CMP !157C,x
			BEQ NOT_SLOW_Y
			INC $03
NOT_SLOW_Y:		LDA !B6,x
			CLC
			ADC SPEED_TABLE,y
			STA !B6,x
			BEQ RESET_STATE
			LDY !157C,x
			CMP X_SPEED,y
			BNE Y_SPEED_SET
			JSR FLIP_STATE_2
			BRA Y_SPEED_SET

RESET_STATE:		STZ !151C,x
			LDA #$10
			STA !1558,x
			LDA !1504,x
			INC A
			AND #$03
			STA !1504,x

Y_SPEED_SET:		LDY $03
			LDA Y_SPEED,y
			STA !AA,x
			RTS


FLIP_STATE_1:		LDA !157C,x
			EOR #$01
			STA !157C,x
			LDA !B6,x
			EOR #$FF
			INC A
			STA !B6,x
FLIP_STATE_2:		LDA !C2,x
			EOR #$01
			STA !C2,x
			RTS

SUB_VERT_POS_Alt:	LDY #$00
			LDA !D8,x
			STA $00
			LDA !14D4,x
			STA $01
			REP #$20
			LDA $96
			SEC
			SBC $00
			STA $0E
			BPL VERT_RETURN
			INY
VERT_RETURN:		SEP #$20
			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;SPRITE_GFX		;
;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_GFX:		%GetDrawInfo()

			STZ $03

			LDA !14C8,x
			CMP #$02
			BNE DRAW_SET_UP
			LDA #$02
			STA !1602,x
			LDA #$80
			STA $03

DRAW_SET_UP:		LDA !1602,x
			ASL	; = 2
			STA $02
			ASL	; = 4
			CLC
			ADC $02	; + 2
			STA $02	; = 6
			PHX
	
			LDX #$05
LOOP_START:		PHX
			PHX
			
			TXA
			CLC
			ADC $02
			LSR
			TAX

			LDA $01
			CLC
			ADC VER_DISP,x
			STA $0301|!Base2,y

			LDA TILE_MAP,x
			STA $0302|!Base2,y

			PLX
			TXA
			AND #$01
			TAX

			LDA $00
			CLC
			ADC HORZ_DISP,x
			STA $0300|!Base2,y

			LDA TILE_PROP,x
			LDX $15E9|!Base2
			ORA !15F6,x
			ORA $64
			ORA $03
			STA $0303|!Base2,y

			PLX
			INY
			INY
			INY
			INY
			DEX
			BPL LOOP_START

			PLX
			LDY #$00
			LDA #$05
			JSL $01B7B3|!BankB
			RTS