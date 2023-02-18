;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spikeball                                                     by EternityLarva
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; extra_bits : no
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; extra_byte1 : start x speed ($00 - $7F)
; extra_byte2 : start y speed ($00 - $FF)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; config : shatter effect extended
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!extended_shatter = $06  ;extended number ( spikeball_shatter.asm )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; config : spikeball tilemap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ball_tile:
	db $64,$66,$68,$6A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; config : spikeball slope accelerator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

accelerator: db $FF,$FF,$FF,$FF,$00,$01,$01,$01,$01
flame:       db $00,$01,$03,$07,$FF,$07,$03,$01,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; config : speed table (after cape attack) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cape_speed_table:
	db $E8,$18
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; don't change it
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fast_speed_table:
	db $00,$7F,$80
	
!timer = !163E
!slope_timer = !15AC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

	%SubHorzPos()
	LDA !extra_byte_1,x
	CPY #$00
	BEQ +
	EOR #$FF
	INC A
+
	STA !sprite_speed_x,x
	
	LDA !extra_byte_2,x
	STA !sprite_speed_y,x
	
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Sprite
	PLB
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sprite:
	JSR gfx
	LDA #$00
	%SubOffScreen()

	LDA $9D
	BNE return
+
	LDA !sprite_status,x
	CMP #$02
	BNE +
	JSR del_spike
	RTS
+
	CMP #$07
	BCC return
	SEC
	SBC #$07
	JSL $0086DF|!BankB

	dw return,normal,kicked,stateABC,stateABC,stateABC
	
return:
	RTS
	
kicked:

	LDA !timer,x
	BNE normal

	LDA $15
	AND #$08
	BEQ +
	
	LDA #$C0
	STA !sprite_speed_y,x
+

stateABC:

	LDA #$08
	STA !sprite_status,x

normal:

	LDA !timer,x
	CMP #$01
	BNE +
	JSR del_spike
+
	JSL $01802A|!BankB
	JSL $01A7DC|!BankB
	
	LDA !timer,x
	BNE +
	
	LDA !sprite_being_eaten,x
	ASL A
	STA $00
	
	LDA !sprite_tweaker_1686,x
	AND #$FD
	ORA $00
	STA !sprite_tweaker_1686,x
+
	LDA !sprite_being_eaten,x
	BEQ +
	RTS
+
;check sprite
	JSL $03B69F|!BankB    ;(A)

	PHY
	LDY #!SprSize
-
	CPY $15E9|!Base2
	BEQ +

	LDA !sprite_status,y       ;if sprite is living
	CMP #$08
	BCC +

	LDA !sprite_being_eaten,y  ;if not eaten by yoshi
	BNE +

	LDA !sprite_tweaker_167a,y ;if not invisible object
	AND #$02
	BNE +

	PHX
	TYX
	JSL $03B6E5|!BankB    ;(B)
	JSL $03B72B|!BankB    ;check(A)and(B)
	BCC p2

	PHX
	LDX $15E9|!Base2
	LDA !new_sprite_num,x
	PLX
	CMP !new_sprite_num,x
	BNE not_spike

	JSR del_spike
	PLX
	PLY
	JSR del_spike
	RTS

not_spike:

	STZ $00
	STZ $01
	LDA #$08
	STA $02
	LDA #$02
	%SpawnSmoke()

	LDA #$13
	STA $1DF9|!Base2
	LDA #$D0
	STA !sprite_speed_y,x
	LDA #$02
	STA !sprite_status,x

p2:
	PLX
+
	DEY
	BPL -
	PLY

;check wall
	
	LDA !sprite_blocked_status,x
	AND #$03
	BEQ +
	
	PHY
	TAY
	LDA fast_speed_table,y
	STA !sprite_speed_x,x
	PLY
	
	LDA #$03
	STA !timer,x
	
	LDA #$09
	STA !sprite_status,x
+

;update speed

	PHY
	LDA !sprite_slope,x
	CLC
	ADC #$04
	TAY

	LDA accelerator,y
	STA $00 

	LDA flame,y
	STA $01

	PLY
	
	LDA $14
	AND $01
	BNE +

	LDA !sprite_speed_x,x
	CLC
	ADC $00
	STA !sprite_speed_x,x
+
	JSR bounce

;chack cape

	JSR check_cape
	BCC +
	
	JSL $01AB6F|!BankB
	
	LDA #$C0
	STA !sprite_speed_y,x
	
	%SubHorzPos()
	LDA cape_speed_table,y
	STA !sprite_speed_x,x
	
+
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphic routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gfx:
	%GetDrawInfo()

	LDA $00
	STA $0300|!Base2,y

	LDA $01
	STA $0301|!Base2,y

	LDA !sprite_x_low,x
	AND #$06
	LSR
	PHY
	TAY
	LDA ball_tile,y
	PLY
	STA $0302|!Base2,y

	PHY
	LDA !15F6,x
	ORA $64
	PLY
	STA $0303|!Base2,y

	LDY #$02
	LDA #$00
	JSL $01B7B3|!BankB
	RTS
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sub cape routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_cape:
	
	LDA $13E8|!Base2
	BEQ not_cape
	
	LDA !sprite_being_eaten,x
	ORA !154C,x
	ORA !1FE2,x
	BNE not_cape
	
	LDA !1632,x
	PHY
	LDY $74
	BEQ +
	
	EOR #$01
+
	PLY
	EOR $13F9|!Base2
	BNE not_cape
	
	JSL $03B69F|!BankB
	
	LDA $13E9|!Base2
	SEC
	SBC #$02
	STA $00
	
	LDA $13EA|!Base2
	SBC #$00
	STA $08
	
	LDA #$14
	STA $02
	
	LDA $13EB|!Base2
	STA $01
	
	LDA $13EC|!Base2
	STA $09
	
	LDA #$10
	STA $03
	
	JSL $03B72B|!BankB
	BCC not_cape
	
	SEC
	RTS
	
not_cape:
	CLC
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sub shatter spikeball
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

del_spike:

	LDA !sprite_tweaker_1686,x
	ORA #$01
	AND #$FD
	STA !sprite_tweaker_1686,x
	
	PHY
	LDY #$05
-
	JSL $01ACF9|!BankB
	LDA $148D|!Base2
	AND #$1F
	SEC
	SBC #$10
	STA $00
	LDA $148E|!Base2
	AND #$1F
	SEC
	SBC #$10
	STA $01

	JSL $01ACF9|!BankB
	LDA $148D|!Base2
	AND #$1F
	SEC
	SBC #$10
	STA $02
	LDA $148E|!Base2
	AND #$1F
	SEC
	SBC #$40
	STA $03
	
	PHY
	%SpawnExtended()
	
	LDA #!extended_shatter+!ExtendedOffset
	STA !extended_num,y
	
	JSL $01ACF9|!BankB
	LDA $148D|!Base2
	STA !extended_behind,y
	LDA $148E|!Base2
	STA !extended_table,y
	PLY
	
	DEY
	BPL -
	PLY

	LDA #$13
	STA $1DF9|!Base2

	STZ !sprite_status,x
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sub bound routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bounce:

	LDA !sprite_blocked_status,x
	AND #$04
	BEQ return34

	LDA !sprite_speed_y,x
	PHA

	LDA !sprite_blocked_status,x
	BMI Speed2
	LDA #$00
	LDY !sprite_slope,x
	BEQ Store

Speed2:
	LDA #$01
	STA !slope_timer,x
	LDA #$18

Store:
	STA !sprite_speed_y,x

	PLA
	LSR #2
	TAY

	LDA !slope_timer,x
	BNE +

	LDA BounceSpeeds,y
	LDY !sprite_blocked_status,x
	BMI +
	STA !sprite_speed_y,x
+
return34:

	LDA !sprite_blocked_status,x
	AND #$08
	BEQ return35
	
	STZ !sprite_speed_y,x
	
return35:

	RTS

BounceSpeeds:
	db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
	db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
	db $E8,$E8,$E8,$00,$00,$00,$00,$FE
	db $FC,$F8,$EC,$EC,$EC,$E8,$E4,$E0
	db $DC,$D8,$D4,$D0,$CC,$C8
	