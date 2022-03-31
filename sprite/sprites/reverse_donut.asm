;-----------------------------------------------------------------------------------------
; Reverse Donut                                                              by E.Larva
;-----------------------------------------------------------------------------------------
; config
;-----------------------------------------------------------------------------------------

	!block = $117D
	!tile = $80

;-----------------------------------------------------------------------------------------
; init
;-----------------------------------------------------------------------------------------

print "INIT ",pc
	RTL

;-----------------------------------------------------------------------------------------
; main
;-----------------------------------------------------------------------------------------

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR sprite
	PLB
	RTL

;-----------------------------------------------------------------------------------------
; gfx
;-----------------------------------------------------------------------------------------

sprite:

	%GetDrawInfo()

	LDA !sprite_speed_y,x
	BNE +

	LDA $14
	AND #$02
	BNE +
	LDA !1558,x
	BEQ +

	DEC $00

+	LDA $00
	STA $0300|!Base2,y
	LDA $01
	STA $0301|!Base2,y

	LDA !15F6,x
	ORA $64
	STA $0303|!Base2,y

	LDA #!tile
	STA $0302|!Base2,y

	LDY #$02
	LDA #$00
	JSL $01B7B3|!BankB

;-----------------------------------------------------------------------------------------
; sprite
;-----------------------------------------------------------------------------------------

	LDA #$00
	%SubOffScreen()

	LDA $9D
	BNE return
	LDA !14C8,x
	CMP #$08
	BNE return
	
	LDA !sprite_speed_y,x
	BEQ ++
	
	LDA !sprite_speed_y,x
	CMP #$E0
	BMI + 
	SEC
	SBC #$02
	STA !sprite_speed_y,x
+
	JSL $01801A|!BankB

	LDA #$01
	STA !1558,x
++
	JSL $01B44F|!BankB
	BCC gen_map16

	LDA !1558,x
	BNE +
	LDA #$28
	STA !1558,x
+
	DEC A
	STA !1558,x
	CMP #$01
	BNE +
	LDA #$F5
	STA !sprite_speed_y,x
+
-
	JSL $01A7DC|!BankB
	BCC +
	LDA $77
	AND #$08
	BEQ +
	JSL $00F606|!BankB
+
return:
	RTS

gen_map16:
	LDA !sprite_speed_y,x
	BNE -

	STZ !sprite_status,x
	STZ !1558,x

	LDA !sprite_y_low,x
	STA $98
	LDA !sprite_y_high,x
	STA $99
	LDA !sprite_x_low,x
	STA $9A
	LDA !sprite_x_high,x
	STA $9B

	PHP
	REP #$30
	LDA #!block
	%ChangeMap16()
	PLP
	RTS