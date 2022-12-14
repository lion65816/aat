

; its tile number is stored in !extra_prop_1 (not byte, PROP!)
; this is set at spawn by the parent sprite


	print "MAIN ", pc
	MAIN:
		PHB : PHK : PLB

		LDA #$00
		%SubOffScreen()

		LDA !sprite_status,x
		SEC : SBC #$08
		ORA $9D
		BEQ .Process
		JMP Graphics

		.Process

		LDA !1510,x : BEQ .Infinite
		LDA !1540,x : BNE .Infinite
		STZ !sprite_status,x
		PLB
		RTL

		.Infinite



		; movement

		JSL $01801A|!BankB
		JSL $018022|!BankB

		; player interaction

		LDA !sprite_x_low,x
		CLC : ADC #$06
		STA $04
		LDA !sprite_x_high,x
		ADC #$00
		STA $0A
		LDA !sprite_y_low,x
		CLC : ADC #$06
		STA $05
		LDA !sprite_y_high,x
		ADC #$00
		STA $0B
		LDA #$02
		STA $06
		STA $07
		JSL $03B664|!BankB
		JSL $03B72B|!BankB
		BCC .Ok
		JSR HurtPlayer


		.Ok

	Graphics:
		STZ $0E
		STZ $0F
		LDA !sprite_y_low,x : STA $02
		LDA !sprite_y_high,x : STA $03
		LDA !sprite_x_high,x : XBA
		LDA !sprite_x_low,x
		REP #$20
		SEC : SBC $1A
		CMP #$01F0 : BCC +
		CMP #$FFF0 : BCS +
		INC $0F
		+
		STA $00
		LDA $02
		SEC : SBC $1C
		CMP #$00E0 : BCC +
		CMP #$FFF0 : BCS +
		INC $0F
		+
		STA $02
		SEP #$20

		LDY !sprite_oam_index,x
		LDA $00 : STA $0300|!Base2,y
		LDA $02 : STA $0301|!Base2,y
		LDA !extra_prop_1,x : STA $0302|!Base2,y
		LDA !15F6,x
		AND #$0F
		ORA $64
		STA $0303|!Base2,y

		LDA $0F : BEQ .Finish

		.Hide
		LDA #$F0 : STA $0301|!Base2,y

		.Finish
		TYA
		LSR #2
		TAY
		LDA $01
		AND #$01
		STA $0460|!Base2,y
		PLB
	print "INIT ", pc
	INIT:
		RTL


	HurtPlayer:
		LDA $187A|!Base2 : BEQ .NoYoshi
		LDA $1490|!Base2 : BNE .Return
		LDY $18E2|!Base2 : BEQ .NoYoshi
		DEY
		LDA #$10 : STA !163E,y
		LDA #$03 : STA $1DFA|!Base2			; disable yoshi drums
		LDA #$13 : STA $1DFC|!Base2			; lose yoshi sfx
		LDA #$02 : STA.w !C2|!Base1,y
		STZ $187A|!Base2
		STZ $7B
		LDA #$C0 : STA $7D
		PHX
		TYX
		%SubHorzPos()
		PHX
		TYX
		LDA.l $01EBBE,x
		PLX
		STA !sprite_speed_x,x
		STZ !1594,x
		STZ !151C,x
		STZ $18AE|!Base2
		STZ $0DC1|!Base2
		LDA #$30 : STA $1497|!Base2

		LDA !sprite_y_low,x
		SEC : SBC #$04
		STA $96
		STA $D3
		LDA !sprite_y_high,x
		SBC #$00
		STA $97
		STA $D4
		PLX

		.Return
		RTS

		.NoYoshi
		JSL $00F5B7|!BankB
		RTS



