


	!tile1		= $00
	!tile2		= $02


	!speed		= 32				; speed of projectile
	!speed_diag	= sqrt((!speed*!speed)/2)	; don't mind this...
	!rate		= 5				; number of frames per shot
	!projectile	= $B3				; custom sprite number of projectile
	!reload_time	= 120				; number of frames between salvos


	print "INIT ", pc
	INIT:
		PHB : PHK : PLB
		%SubHorzPos()
		TYA : STA !157C,x			; determines whether it will shoot clockwise or counterclockwise
		PLB
		RTL


	Clockwise:
	.ShootY
	db -!speed,-!speed_diag
	.ShootX
	db $00,!speed_diag,!speed,!speed_diag,$00,-!speed_diag,-!speed,-!speed_diag

	CounterClock:
	.ShootX
	db $00,-!speed_diag
	.ShootY
	db -!speed,-!speed_diag,$00,!speed_diag,!speed,!speed_diag,$00,-!speed_diag


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
		LDA !sprite_misc_1504,x
		INC !sprite_misc_1504,x
		CMP #!reload_time-1 : BNE +
		STZ !sprite_misc_1504,x
	+	PHX
		LDX #$00
		CMP #!rate*0 : BEQ +
		INX
		CMP #!rate*1 : BEQ +
		INX
		CMP #!rate*2 : BEQ +
		INX
		CMP #!rate*3 : BEQ +
		INX
		CMP #!rate*4 : BEQ +
		INX
		CMP #!rate*5 : BEQ +
		INX
		CMP #!rate*6 : BEQ +
		INX
		CMP #!rate*7 : BEQ +
		JMP .NoShoot
	+	STX $00

		LDY.b #!SprSize-1
	-	LDA !sprite_status,y : BEQ +
		DEY : BPL -
		BRA .NoShoot

	+	TYX
		LDA.b #!projectile : STA !new_sprite_num,x
		LDA #$36 : STA !sprite_num,x
		LDA #$01 : STA !sprite_status,x
		LDA $00 : PHA				; cool routine >:(
		JSL $07F7D2|!BankB			; | > Reset sprite tables
		JSL $0187A7|!BankB			; | > Reset custom sprite tables

		STZ !1510,x				; shoutout to exteremely based pixi... could you even imagine?
							; NOTE! this table needs to match the one in projectile.asm

		PLA : STA $00
		LDA.b #!CustomBit : STA !extra_bits,x
		TXY
		LDX $15E9|!Base2
		LDA !sprite_x_low,x
		CLC : ADC #$04
		STA !sprite_x_low,y
		LDA !sprite_x_high,x
		ADC #$00
		STA !sprite_x_high,y
		LDA !sprite_y_low,x
		CLC : ADC #$04
		STA !sprite_y_low,y
		LDA !sprite_y_high,x
		ADC #$00
		STA !sprite_y_high,y

		LDX $15E9|!Base2
		LDA !157C,x : BEQ .CW
	.CC	LDX $00
		LDA CounterClock_ShootX,x : STA.w !sprite_speed_x|!Base1,y
		LDA CounterClock_ShootY,x : STA.w !sprite_speed_y|!Base1,y
		BRA .NoShoot
	.CW	LDX $00
		LDA Clockwise_ShootX,x : STA.w !sprite_speed_x|!Base1,y
		LDA Clockwise_ShootY,x : STA.w !sprite_speed_y|!Base1,y
		.NoShoot
		PLX


		; movement

		JSL $01801A|!BankB
		JSL $018022|!BankB

		; player interaction
		; ?


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

		LDA !15F6,x
		AND #$0F
		ORA $64
		STA $05
		LDA !157C,x : BEQ +
		LDA #$40 : TSB $05
	+	LDA !sprite_misc_1504,x
		CMP #!rate*8 : BCC .Fast
		CMP #!reload_time-32 : BCC .Slow
	.Fast	ASL #2
	.Slow	AND #$30
		LSR #4
		PHX
		TAX
		LDA .Tilemap,x
		STA $04
		LDA .Prop,x
		EOR $05
		STA $05
		PLX

		LDY !sprite_oam_index,x
		LDA $00 : STA $0300|!Base2,y
		LDA $02 : STA $0301|!Base2,y
		LDA $04 : STA $0302|!Base2,y
		LDA $05 : STA $0303|!Base2,y

		LDA $0F : BEQ .Finish

		.Hide
		LDA #$F0 : STA $0301|!Base2,y

		.Finish
		TYA
		LSR #2
		TAY
		LDA $01
		AND #$01
		ORA #$02
		STA $0460|!Base2,y
		PLB
		RTL

	.Tilemap
	db !tile1,!tile2,!tile1,!tile2

	.Prop
	db $40,$40,$C0,$00


