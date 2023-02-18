;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; super mario maker 2 - super mario world - spike           by EternityLarva
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; extra bits clr : normal
;            set : with wing (like red vertical parakoopa)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; extra_byte 1 : throw timer $01 - $FF (default = $60)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; gen sprite config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!spike_ball = $A8  ;sprite number ( spikeball.json )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; throw speed config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!throw_y_speed = $D0

throw_x_speed:
	db $18,$E8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; tilemap config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!g3 = $CF      ; 8x8 tile green3
!g4 = $CF      ; 8x8 tile green4
!g5 = $CF      ; 8x8 tile green5
!b2 = $CF      ; 8x8 tile black2
!b3 = $CF      ; 8x8 tile black3
!b4 = $CF      ; 8x8 tile black4
!sp = $64      ;16x16 tile spike

!poseA = $40   ; stand tile A
!poseB = $42   ; stand tile B
!poseC = $44   ; open tile A
!poseD = $46   ; open tile B
!poseE = $48   ; hand it over

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; tilemap table config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tilemap:
	db !poseA,!g5,$55,$55
	db !poseB,!g5,!b2,$55
	db !poseC,!g5,!b2,!sp
	db !poseD,!b4,!b3,!sp
	db !poseE,!g3,!g4,!sp

xoffset:
	db $00,$02,$55,$55,$00,$06,$55,$55
	db $00,$02,$10,$55,$00,$06,$F8,$55
	db $00,$04,$10,$00,$00,$04,$F8,$00
	db $00,$10,$FF,$00,$00,$F8,$09,$00
	db $00,$FE,$04,$00,$00,$0A,$04,$00

yoffset:
	db $00,$F8,$55,$55,$00,$10,$55,$55
	db $00,$F8,$08,$55,$00,$10,$00,$55
	db $00,$F8,$09,$55,$00,$10,$FF,$55
	db $00,$07,$09,$55,$00,$01,$FF,$55
	db $00,$F8,$F8,$55,$00,$10,$10,$55

sizemap:
	db $02,$00,$00,$02

tilemax:
	db $01,$02,$02,$02,$02

spike_y:
	db $00,$FD,$FC,$FB,$FA,$F9,$F8,$F7
	db $F6,$F5,$F4,$F3,$F2,$F1,$F0,$F1
	db $F2

wing_index_table:
	db $02,$03,$04,$04,$04
	
wing_x:
	db $F4,$FA,$0C,$0C
	
wing_y:
	db $F8,$00
	
wing_tile:
	db $C6,$5D
	
wing_size:
	db $02,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; don't change 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!pose         = !1504
!spike_timer  = !1FD6
!flying_timer = !1540
!timer        = !15AC
!flying_count = !1602
!wing_flag    = !151C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

	LDA !extra_byte_1,x
	BNE +
	
	LDA #$60
	STA !extra_byte_1,x
	
+
	STA !timer,x
	
	LDA !extra_bits,x
	AND #$04
	LSR
	LSR
	STA !wing_flag,x
	
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpikeMain
	PLB
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

flying_speed_table:
	db $FF,$01

flying_max_table:
	db $F0,$10

SpikeMain:
	JSR gfx
	LDA #$00
	%SubOffScreen()

	LDA $9D
	BNE return

	LDA !sprite_status,x
	CMP #$08
	BNE return
	
	JSL $018032|!BankB

	LDA !sprite_misc_c2,x
	CMP #$04
	BCS +

	PHY
	%SubHorzPos()
	TYA
	STA !sprite_misc_157c,x
	PLY
+
	
	LDA !wing_flag,x
	BEQ wingless
	
	JSL $01801A|!BankB
	JSR wing_contact
	
	LDA $14
	AND #$03
	BNE moveend
	
	LDA !flying_timer,x
	BNE moveend

	LDA !flying_count,x
	AND #$01
	TAY

	LDA !sprite_speed_y,x
	CLC
	ADC flying_speed_table,y
	STA !sprite_speed_y,x
	
	CMP flying_max_table,y
	BNE moveend

	INC !flying_count,x

	LDA #$30
	STA !flying_timer,x
	BRA moveend

wingless:
	JSL $01802A|!BankB
	JSL $01A7DC|!BankB
	
moveend:

	LDA !sprite_blocked_status,x
	AND #$04
	BEQ +
	STZ !sprite_speed_y,x
+
	LDA !sprite_misc_c2,x
	JSL $0086DF|!BankB

	dw s0,s1,s2,s3,s4

return:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wait
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
anim_table:  db $00,$01

s0:

	PHY
	LDA $14
	AND #$10
	LSR #4
	TAY
	LDA anim_table,y
	STA !pose,x
	PLY

	LDA !timer,x
	BNE +
	LDA #$08
	STA !timer,x
	INC !sprite_misc_c2,x
+
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s1:
	LDA #$02
	STA !pose,x
	LDA !timer,x
	BNE +
	LDA #$10
	STA !timer,x
	INC !sprite_misc_c2,x
+
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s2:
	LDA #$03
	STA !pose,x
	INC !spike_timer,x
	LDA !timer,x
	BNE +
	LDA #$08
	STA !timer,x
	INC !sprite_misc_c2,x
	

+
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s3:
	LDA #$02
	STA !pose,x
	LDA !timer,x
	BNE +
	LDA #$10
	STA !timer,x
	INC !sprite_misc_c2,x
+
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s4:
	LDA #$04
	STA !pose,x
	LDA !timer,x
	BNE +
	LDA !extra_byte_1,x
	STA !timer,x
	STZ !sprite_misc_c2,x
	STZ !spike_timer,x
	
	LDA !sprite_misc_157c,x
	STA $00

	STZ $00
	LDA #$F0
	STA $01
	PHY
	LDY !sprite_misc_157c,x
	LDA throw_x_speed,y
	STA $02
	PLY
	LDA #!throw_y_speed
	STA $03
	LDA #!spike_ball
	SEC
	%SpawnSprite()
	
	LDA #$08
	STA !sprite_status,y
+
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wing -> not wing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wing_contact:

	JSL $01A7DC|!BankB
	BCC not_contact
	
	LDA $140D|!Base2  ;is spinjump
	ORA $187A|!Base2  ;is on yoshi
	BNE not_contact
	
	LDA #$08
	STA !sprite_status,x
	
	STZ !wing_flag,x
	
	STZ !sprite_speed_y,x
	
not_contact:
	RTS
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphic routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gfx:
	%GetDrawInfo()

;---;

	PHY
	LDA !pose,x
	TAY
	LDA tilemax,y
	STA $02                ;$02 - loop max(send tilemap)
	PLY

;---;

	LDA !pose,x
	STA $08                ;$08 - pose x1
	ASL #2
	STA $03                ;$03 - pose x4
	ASL
	STA $04                ;$04 - pose x8

;---;

	LDA !sprite_misc_157c,x
	ASL
	STA $0B                ;$0B - dir x2(wing_x_offset)
	ASL
	STA $05                ;$05 - dir x4

;---;

	STZ $07
	LDA !sprite_status,x   ;$07 - y flip x4
	CMP #$02
	BNE +
	LDA #$04
	STA $07
+
	PHY
	LDA !spike_timer,x
	TAY
	LDA spike_y,y
	PLY
	STA $06                ;$06 - y pos

;---;

	LDA $06
	BEQ +
	
	LDA $07
	BNE is_y_flip
	
	INC $02
+
	LDA $07
	BNE is_y_flip
	
	LDA !wing_flag,x
	BEQ +
	INC $02
	
	LDA !spike_timer,x
	BNE +
	LDA !pose,x
	CMP #$02
	BNE +
	INC $02
+
	
is_y_flip:

;---;

	PHX
	LDX #$00
-
	TXA
	STA $09
	
	PHY
	LDY $08
	LDA wing_index_table,y
	PLY
	
	CMP $09
	BNE +
	JSR wing_gfx
	BRA skip_gfx
+

;---;

	PHX
	TXA
	ORA $04
	ORA $05
	TAX
	LDA xoffset,x
	CLC
	ADC $00
	STA $0300|!Base2,y
	PLX

;---;

	PHX
	TXA
	ORA $04
	ORA $07
	TAX
	LDA yoffset,x
	CMP #$55
	BNE +
	LDA $06
+
	CLC
	ADC $01
	STA $0301|!Base2,y
	PLX

;---;

	PHX
	TXA
	ORA $03
	TAX
	LDA tilemap,x
	STA $0302|!Base2,y
	PLX

;---;

	PHY
	PHX
	LDX $15E9|!Base2
	LDA !15F6,x
	PLX
	LDY $05
	BNE +
	ORA #$40
+
	LDY $07
	BEQ +
	ORA #$80
+
	ORA $64
	PLY
	STA $0303|!Base2,y

;---;

	PHX
	LDA sizemap,x
	PHA
	TYA
	LSR #2
	TAX
	PLA
	STA $0460|!Base2,x
	PLX

;---;

skip_gfx:
	
	INY #4
	INX
	CPX $02
	BCC -
	BEQ -

	PLX

	LDY #$FF
	LDA $02
	JSL $01B7B3|!BankB
	RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wing gfx routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wing_gfx:

	LDA $14
	AND #$10
	LSR #4
	STA $0A
	
	PHX
	LDA $0A
	ORA $0B
	TAX
	LDA wing_x,x
	CLC
	ADC $00
	STA $0300|!Base2,y
	
	LDX $0A
	LDA wing_y,x
	CLC
	ADC $01
	STA $0301|!Base2,y
	
	LDA wing_tile,x
	STA $0302|!Base2,y

	PHY
	LDA #$36
	LDY $0B
	BNE +
	ORA #$40
+
	ORA $64
	PLY
	STA $0303|!Base2,y

	LDA wing_size,x
	PHA
	TYA
	LSR #2
	TAX
	PLA
	STA $0460|!Base2,x
	PLX
	
	RTS