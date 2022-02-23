;---------------------------------------------
; upside ninji                  by  E.Larva
;---------------------------------------------

;---------------------------------------------
; extra bits - walking flag
;---------------------------------------------
; extra byte 1 - jump power A
;---------------------------------------------
; extra byte 2 - jump power B
;---------------------------------------------
; extra byte 3 - jump power C
;---------------------------------------------

;---------------------------------------------
; config
;---------------------------------------------

!jump_timer = $60

tilemap:
	db $A7,$A9
	
speed_table:
	db $10,$F0
	
;---------------------------------------------
; do not change
;---------------------------------------------
!state = !C2
!pose = !1510
!timer = !1540
!direction = !157C
;---------------------------------------------
	
print "INIT ",pc
	
	%SubHorzPos()
	TYA
	STA !direction,x
	
	LDA !extra_byte_1,x
	AND #$7F
	STA !extra_byte_1,x
	
	LDA !extra_byte_2,x
	AND #$7F
	STA !extra_byte_2,x
	
	LDA !extra_byte_3,x
	AND #$7F
	STA !extra_byte_3,x
	
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR sprite
	PLB
	RTL
	
accelerator_table:
	db $FC,$FF
	
falls_point_table:
	db $C0,$F0
	
sprite:
	%GetDrawInfo()
	LDA !direction,x
	EOR #$01
	ASL #6
	STA $02
	
	LDA $00
	STA $0300|!Base2,y
	
	LDA $01
	INC
	INC
	STA $0301|!Base2,y
	
	PHX
	LDA !pose,x
	TAX
	LDA tilemap,x
	STA $0302|!Base2,y
	PLX
	
	LDA !sprite_oam_properties,x
	ORA #$80
	ORA $02
	ORA $64
	STA $0303|!Base2,y
	
	LDY #$02
	LDA #$00
	%FinishOAMWrite()
	
;---------------------------------------------
; sprite
;---------------------------------------------
	LDA #$00
	%SubOffScreen()
	LDA $9D
	BEQ +
	RTS
+
	%BES(+)
	%SubHorzPos()
	TYA
	STA !direction,x
	BRA ++
+
	LDA !direction,x
	TAY
	LDA speed_table,y
	STA !sprite_speed_x,x
	LDA $14
	LSR #3
	AND #$01
	STA !pose,x
++
	JSL $019138|!BankB
	LDA !sprite_blocked_status,x
	AND #$03
	BEQ +
	LDA !direction,x
	EOR #$01
	STA !direction,x
+
	LDA !sprite_blocked_status,x
	AND #$04
	BEQ +
	STZ !sprite_speed_y,x
+
	LDA !sprite_blocked_status,x
	AND #$08
	BEQ +
	STZ !sprite_speed_y,x
	LDA !timer,x
	BNE ++
	LDA #!jump_timer
	STA !timer,x
	
	LDA !extra_byte_1,x
	STA $00
	STA $03
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	
	INC !state,x
	LDA !state,x
	AND #$03
	TAY
	LDA $00,y
	STA !sprite_speed_y,x
	BRA ++
+
	LDA !sprite_speed_y,x
	LSR #7
	AND #$01
	STA !pose,x
++
	JSL $018022|!BankB
	JSL $01801A|!BankB
	LDY #$00
	LDA !sprite_in_water,x
	BEQ +
	INY
	LDA !sprite_speed_y,x
	BMI +
	CMP #$18
	BCC +
	LDA #$18
	STA !sprite_speed_y,x
+
	LDA !sprite_speed_y,x
	CLC
	ADC accelerator_table,y
	STA !sprite_speed_y,x
	BPL +
	CMP falls_point_table,y
	BCS +
	LDA falls_point_table,y
	STA !sprite_speed_y,x
+
	JSL $018032|!BankB
	JSL $01A7DC|!BankB
	RTS
	