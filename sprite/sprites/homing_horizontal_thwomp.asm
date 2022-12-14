;----------------------------------------------------------------
; Homing Horizontal Thwomp               by E.Larva
;----------------------------------------------------------------
; Extra Bits - left or right
;----------------------------------------------------------------

!SoundEf = $09
!SoundBank = $1DFC

y_speed_table:
	db $30,$D0
back_speed:
	db $38,$D8
accelerator_table:
	db $F8,$08
smoke_table:
	db $F8,$08
	
;----------------------------------------------------------------
; do not change
;----------------------------------------------------------------
!state = !C2
!pose = !1528
;----------------------------------------------------------------

Print "INIT ",pc
	LDA !sprite_x_low,x
	CLC
	ADC #$08
	STA !sprite_x_low,x
	STA !151C,x
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x
	STA !1510,x
	RTL

;----------------------------------------------------------------

Print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR sprite
	PLB
	RTL

;----------------------------------------------------------------

sprite:
	JSR GFX
	LDA #$00
	;%SubOffScreen()	;> PSI Ninja edit: Don't kill the Thwomp if it goes offscreen.
	LDA !sprite_status,x
	EOR #$08
	ORA $9D
	BNE return

	JSL $01A7DC|!BankB

	LDA !state,x
	BEQ move
	DEC
	BEQ attack

;----------------------------------------------------------------
; State 3 - back
;----------------------------------------------------------------

	LDA !1540,x
	BNE return
	STZ !pose,x
	LDA !sprite_x_high,x
	CMP !1510,x
	BNE ++
	%BES(+)
	LDA !sprite_x_low,x
	CMP !151C,x
	BCC ++
	STZ !state,x
	RTS
+
	LDA !sprite_x_low,x
	CMP !151C,x
	BCS ++
	STZ !state,x
	RTS
++
	LDY #$00
	%BEC(+)
	INY
+
	LDA back_speed,y
	STA !sprite_speed_x,x
	JSL $018022|!BankB
return:
	RTS

;----------------------------------------------------------------
; State 1 - vertical move
;----------------------------------------------------------------

move:
	STZ !pose,x
	JSR SubVertPosPlus

	REP #$20
	LDA $0E
	INC A
	CMP #$0004
	SEP #$20
	BCS +

	INC !pose,x
	INC !state,x
	STZ !sprite_speed_x,x
	RTS
+
	%SubVertPos()
	LDA y_speed_table,y
	STA !sprite_speed_y,x
	JSL $01801A|!BankB
	RTS
;----------------------------------------------------------------
; State 2 - attack
;----------------------------------------------------------------
attack:
	JSL $018022|!BankB
	LDY #$00
	%BES(+)
	LDA !sprite_speed_x,x
	CMP #$C0
	BMI check_wall
	BRA ++
+
	INY
	LDA !sprite_speed_x,x
	CMP #$40
	BPL check_wall
++
	CLC
	ADC accelerator_table,y
	STA !sprite_speed_x,x
check_wall:
;----------------------------------------------------------------
; check wall
;----------------------------------------------------------------
	%BES(+)
	JSR x_minus
	BRA ++
+
	JSR x_plus
++
	JSL $019138|!BankB
	LDA !sprite_blocked_status,x
	PHA
	
	LDA !sprite_y_low,x
	SEC
	SBC #$10
	STA !sprite_y_low,x
	LDA !sprite_y_high,x
	SEC
	STA !sprite_y_high,x
	
	JSL $019138|!BankB
	PLA
	ORA !sprite_blocked_status,x
	STA !sprite_blocked_status,x
	
	LDA !sprite_y_low,x
	CLC
	ADC #$10
	STA !sprite_y_low,x
	LDA !sprite_y_high,x
	CLC
	STA !sprite_y_high,x
	
	%BES(+)
	JSR x_plus
	BRA ++
+
	JSR x_minus
++
;----------------------------------------------------------------
; check smash
;----------------------------------------------------------------
	LDA !sprite_blocked_status,x
	AND #$03
	BEQ return2
	
	LDA #$00
	LDY !15B8,x	
	BEQ ++
+
	LDA #$E8
++
	STA !sprite_speed_x,x

	LDA #$18
	STA $1887|!Base2

	LDA #!SoundEf
	STA !SoundBank|!Base2

	LDY #$00
	%BEC(+)
	INY
+
	LDA smoke_table,y
	STA $00
	LDA #$F8
	STA $01
	LDA #$18
	STA $02
	LDA #$01
	%SpawnSmoke()
	LDA #$08
	STA $01
	LDA #$01
	%SpawnSmoke()
	LDA #$18
	STA $01
	LDA #$01
	%SpawnSmoke()

	LDA #$20
	STA !1540,x
	INC !state,x
return2:
	RTS
;----------------------------------------------------------------
; sub vert pos plus
;----------------------------------------------------------------
; input no
; output $0E-$0F - height
;           Y    - top or bottom
;----------------------------------------------------------------
SubVertPosPlus:
	LDY #$00
	LDA !sprite_y_low,x
	STA $00
	LDA !sprite_y_high,x
	STA $01

	REP #$20
	LDA $96
	SEC
	SBC $00
	STA $0E
	BPL +
	INY
+
	SEP #$20
	RTS
;----------------------------------------------------------------
; sub x
;----------------------------------------------------------------
x_plus:
	LDA !sprite_x_low,x
	CLC
	ADC #$08
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x
	RTS
x_minus:
	LDA !sprite_x_low,x
	SEC
	SBC #$08
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	SBC #$00
	STA !sprite_x_high,x
	RTS
;----------------------------------------------------------------
; gfx
;----------------------------------------------------------------

xpos_table:
	db $FC,$04,$FC,$04

ypos_table:
	db $00,$00,$10,$10

tile_table:
	db $8E,$8E,$AE,$AE
	db $E0,$E1,$E3,$E4

prop_table:
;	db $03,$43,$03,$43	;> PSI Ninja edit: Gray palette.
;	db $03,$03,$03,$03	;> PSI Ninja edit: Gray palette.
	db $09,$49,$09,$49	;> PSI Ninja edit: Red palette.
	db $09,$09,$09,$09	;> PSI Ninja edit: Red palette.

GFX:
	%GetDrawInfo()

	STZ $03
	LDA !pose,x
	ASL #2
	STA $02
	BEQ +
	%BEC(+)
	LDA #$40
	STA $03
+
	PHX
	LDX #$03
-
	PHX
	LDA xpos_table,x
	LDX $03
	BEQ +
	EOR #$FF
	INC A
+
	CLC
	ADC $00
	STA $0300|!Base2,y
	PLX

	LDA ypos_table,x
	CLC
	ADC $01
	STA $0301|!Base2,y

	PHX
	TXA
	ORA $02
	TAX
	LDA tile_table,x
	STA $0302|!Base2,y
	
	LDA prop_table,x
	ORA $03
	ORA $64
	STA $0303|!Base2,y
	PLX

	INY #4
	DEX
	BPL -

	PLX
	LDY #$02
	LDA #$03
	%FinishOAMWrite()
	RTS
