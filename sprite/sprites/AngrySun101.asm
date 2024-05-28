;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Angry Sun/Happy Moon
;; By Sonikku
;; Description: Waits a while until Mario gets in a certain screen, and starts
;; spinning in circles and swinging downwards at Mario while locked on the
;; screen horizontally. 
;; Extra Property Byte 1 indicates what screen it starts attacking from.
;; Extra Property Byte 2 bit 0 indicates it uses the Super Mario Maker 2 Angry Sun tilemap
!Clus_SparkleNum = $00		; cluster sprite number (as how it displays in list.txt) for the sparkle that drops off of the Happy Moon
;; changes as of this version:
;; --- no longer triggers if mario has active invincibility frames
;; --- initial y position determines which side of the screen sprite starts on
;; --- no longer dies when mario presses down
;; --- moon no longer deletes sprites that yoshi has in his mouth
;; --- yoshi no longer gets scared if the moon is touched (here's me going on a rant about this behavior: https://twitter.com/SpriterSonikku/status/1248056073757405185)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!base2 = !Base2
!bankb = !BankB

print "INIT ",pc
	LDA !D8,x
	LSR : LSR : LSR : LSR
	AND #$01
	STA !160E,x
	LDA #$50
	CLC
	ADC $1C
	STA !D8,x	 	; initialize y position.
	LDA #$00
	ADC $1D
	STA !14D4,x
	LDA #$10
	LDY !160E,x
	BEQ +
	LDA #$D0
+	CLC
	ADC $1A
	STA !E4,x	 	; initialize x position.
	LDA #$00
	ADC $1B
	STA !14E0,x
	JSR .sunanims
	LDX $15E9|!base2
	STA !1602,x

	STZ !1570,x
	LDA !7FAB10,x
	AND #$04
	BEQ +
	LDA #$02
	STA !1570,x
	LDA !167A,x
	ORA #$82
	STA !167A,x
+	LDA !7FAB34,x
	AND #$01
	BEQ +
	INC !1570,x
+	RTL

print "MAIN ",pc
	PHB : PHK : PLB
	JSR .main
	PLB
	RTL

.main	JSR .subgfx
	LDA !14C8,x
	CMP #$08
	BNE .return
	LDA $9D
	BEQ +
.return	RTS
+	%SubOffScreen()
	STZ $1401|!base2			; disable l/r scroll.

	JSR .sunanims
	LDX $15E9|!base2
	STA !1602,x

	LDY #$00
	LDA $17BD|!base2			; move sprite with screen.
	BPL +
	DEY
+	CLC : ADC !E4,x
	STA !E4,x
	TYA
	ADC !14E0,x
	STA !14E0,x
	JSL $018032|!bankb			; interact with sprites.
	JSL $01A7DC|!bankb			; interact with mario.
	BCC .nocontact
	LDA !167A,x
	AND #$80
	BEQ .nocontact
	JSR .collectedmoon
.nocontact
	LDA !C2,x
	ASL A
	TAX
	JMP.w (.pointers,x)
.pointers
	dw .wait
	dw .attackright
	dw .resettimer
	dw .waitfory
	dw .attackleft
	dw .resettimer
	dw .waitfory2
	dw .resetposition

.wait	LDX $15E9|!base2
	JSR .updatespd
	LDA $1B
	CMP !7FAB28,x			 	; screen number
	BCC .return2
	LDA !160E,x
	BEQ .resetposition
	LDA #$04
	STA !C2,x
	LDA #$00
	BRA ++
.resetposition
	LDX $15E9|!base2
	LDA #$01
	STA !C2,x
	LDA #$01
++	STA !1510,x				; set stuff.
	LDA #$00
	STA !151C,x
	STZ !B6,x				; no x speed.
	LDA #$C0
	STA !AA,x				; set y speed.
	JSL $01ACF9|!bankb
	AND #$03
	TAY
	LDA .reload,y
	STA !1540,x				; randomize spinning time.
.return2
	RTS
.attackright
	LDX $15E9|!base2
	JSR .handlemovement
	LDA !1540,x
	BNE +
	INC !C2,x
	LDA #$40				; set y speed.
	STA !AA,x
	LDA #$14				; set x speed.
	STA !B6,x
	LDA #$10
	STA !1540,x
+	RTS
.attackleft
	LDX $15E9|!base2
	JSR .handlemovement
	LDA !1540,x
	BNE +
	INC !C2,x
	LDA #$40				; set y speed.
	STA !AA,x
	LDA #$EC				; set x speed.
	STA !B6,x
	LDA #$10				; set timer.
	STA !1540,x
+	RTS
.waitfory
	LDX $15E9|!base2
	JSR .updatespd
	DEC !AA,x				; decrement y speed.
	JSR .checkboundary
.settimer
	JSL $01ACF9|!bankb			; randomize timer.
	EOR $13
	ADC $94
	AND #$03
	TAY
	LDA .reload,y
	STA !1540,x
	RTS
.waitfory2
	LDX $15E9|!base2
	JSR .updatespd
	DEC !AA,x				; decrement y speed.
	JSR .checkboundary
	BRA .settimer
.checkboundary
	LDA !D8,x
	CMP #$F8
	BCC .ret
.savpos
	LDA #$FF
	STA !D8,x
	INC !C2,x				; increment state when at original position.
	LDA #$01
	STA !151C,x
	STA !1510,x
	STZ !B6,x				; set x speed.
	LDA #$C0				; set y speed.
	STA !AA,x
.ret	RTS
.resettimer
	LDX $15E9|!base2
	LDA !1540,x	  
	BNE +
	INC !C2,x
	LDY !C2,x
	LDA #$20				; set timer.
	STA !1540,x
+	RTS

.handlemovement
	JSR .updatespd
	LDA !1510,x				; horizontal direction.
	EOR #$01
	AND #$01
	TAY
	LDA !B6,x
	CMP .maxspd,y
	BNE +
	INC !1510,x
	INY
+	CLC : ADC .accel,y			; increment/decrement x speed.
	STA !B6,x

	LDA !151C,x				; vertical direction.
	AND #$01
	TAY
	LDA !AA,x
	CMP .maxspd,y
	BNE +
	INC !151C,x
	INY
+	CLC : ADC .accel,y			; increment/decrement y speed.
	STA !AA,x
	RTS

.accel	db $08,$F8,$08,$F8
.maxspd	db $40,$C0,$40,$C0
.reload	db $40,$60,$80,$A0

.updatespd
	JSL $018022|!bankb
	JSL $01801A|!bankb
	RTS

.sunanims
	LDA !C2,x
	STA $00
	LDA !1570,x
	ASL A
	TAX
	JMP.w (.animtype,x)
.animtype
	dw .SMB3
	dw .SMM2
	dw .Moon
	dw .Moon
.SMB3	LDY #$00
	LDA $00
	BEQ +
	LDA $14
	AND #$0C
	BEQ +
	INY
+	TYA
	STA $00
	RTS

.SMM2	LDA $14
	LSR : LSR
	LDX $00
	BNE +
	LSR
+	AND #$03
	CMP #$03
	BNE +
	LDA #$01
+	LDX $00
	CPX #$03
	BEQ ++
	CPX #$06
	BNE +
++	PHA
	LDA $14
	LSR : LSR : LSR
	AND #$01
	PLA
	BEQ +
	CLC
	ADC #$03
+	INC : INC
	STA $00
	RTS
.Moon	LDA $00
	BNE +
	LDA $17BD|!base2
	ORA $17BE|!base2
	BEQ .nosparkle
+	LDA $00
	PHA
	JSR .sparklespawn
	PLA
	STA $00
.nosparkle
	LDY #$00
	LDX $00
	CPX #$03
	BEQ ++
	CPX #$06
	BNE +
++	LDA $14
	LSR : LSR : LSR
	AND #$01
	BEQ .setframe3
	LDY #$03
	BRA .setframe3
+	LDX $15E9|!base2
	LDA !163E,x
	BEQ +
	CMP #$20
	BCS .setframe3
	LSR : LSR : LSR
	AND #$01
	TAY
.setframe3
	TYA
-	CLC
	ADC #$08
	STA $00
	RTS
+ : --	JSL $01ACF9|!bankb
	CMP #$60
	BCC --
	STA !163E,x
	LDA #$00
	BRA -

.collectedmoon
	STZ !14C8,x
	LDA #$00
	JSR .givepts
	LDA #$1C
	STA $1DF9|!base2
	LDY #!SprSize-1
-	LDA !14C8,y
	CMP #$08
	BCC +
	LDA !167A,y
	AND #$02
	BNE +
	LDA #$14
	STA !1540,y
	LDA #$04
	STA !14C8,y
+	DEY
	BPL -
	RTS
.givepts
	STA $0B
	PHY
	INC !1626,x
	LDA !1626,x
	CMP #$08
	BCC +
	LDA #$08
	STA !1626,x
+	STA $0C
	LDA !14D4,x
	PHA
	LDA !D8,x
	PHA
	LDA !14E0,x
	PHA
	LDA !E4,x
	PHA
	LDA $0B
	BEQ +
	LDA !E4,y
	STA !E4,x
	LDA !14E0,y
	STA !14E0,x
	LDA !D8,y
	STA !D8,x
	LDA !14D4,y
	STA !14D4,x
+	LDA $0C
	JSL $02ACE5
	PLA
	STA !E4,x
	PLA
	STA !14E0,x
	PLA
	STA !D8,x
	PLA
	STA !14D4,x
	PLY
	RTS
.sparklespawn
	LDX $15E9|!base2
	JSL $01ACF9	; \
	AND #$0F	;  | 
	CLC		;  | 
	ADC !E4,x	;  | 
	ADC #$08
	STA $00		;  | 
	LDA #$00
	ADC !14E0,x	;  | 
	STA $01		;  | setup positions
	JSL $01ACF9	; \
	AND #$0F	;  | 
	CLC		;  | 
	ADC !D8,x	;  | 
	ADC #$F8
	STA $02		;  | 
	LDA #$FF
	ADC !14D4,x	;  | 
	STA $03		; /
	LDA $14
	AND #$03
	BEQ .cluster_spawn
	RTS
!cluster_misc1	= $1E52|!base2
!cluster_misc2	= $0F5E|!Base2
.cluster_spawn
	LDY #$03	; \
-	STY $04		;  | 
	PHY		;  | 
	JSR +		;  | loop 4 times
	PLY		;  | 
	DEY		;  | 
	BPL -		;  | 
	RTS		; /
+	LDY #$12	; \
-	LDA !cluster_num,y;| check for free slot
	BEQ +		;  | 
	DEY		;  | 
	BPL -		; /
	RTS		; 
+
	LDA $00		; 
	STA !cluster_x_low,y
	LDA $01		; 
	STA !cluster_x_high,y

	LDA $02		; 
	STA !cluster_y_low,y
	LDA $03		; 
	STA !cluster_y_high,y

	LDA #!Clus_SparkleNum
	CLC
	ADC #$09
	STA !cluster_num,y

	JSL $01ACF9
	AND #$03
	CLC
	ADC #$10
	STA !cluster_misc2,y

	LDA #$01	; cluster sprites = active
	STA $18B8|!base2
	RTS

!0300	= $0300|!Base2
!0301	= $0301|!Base2
!0302	= $0302|!Base2
!0303	= $0303|!Base2
.subgfx
	%GetDrawInfo()

	LDA #$FF
	STA $0F

	LDA !1602,x
	ASL : ASL
	CLC
	ADC !1602,x
	STA $02

	LDA !15F6,x
	ORA $64
	STA $03

	LDA !14C8,x
	STA $04

	PHY
	LDY #$00
	LDA !14C8,x
	CMP #$08
	BNE +
	LDY $17BD|!base2
+	TYA
	STA $05
	PLY

	PHX
	LDX #$03			;> AAT edit: Four tiles per frame.
	;LDX #$04
-	PHX

	TXA
	CLC
	ADC $02
	TAX

	LDA .x_pos,x
	CLC
	ADC $00
	ADC $05
	STA !0300,y

	LDA .y_pos,x
	PHX
	LDX $04
	CPX #$08
	BEQ +
	EOR #$FF
	INC
	CLC
	ADC #$F0
+	PLX
	CLC
	ADC $01
	STA !0301,y

	STZ $06
	LDA .tilemap,x
	STA $07
	CMP #$FF
	BEQ .loop
--	CMP #$FB
	BCC +
	DEX
	LDA .tilemap,x
	BRA --
+	STA !0302,y

	PHX
	LDX #$00
	LDA $07
	CMP #$FB
	BCC +
	CLC
	ADC #$05
	TAX
+	LDA $03
	ORA .properties,x
	LDX $04
	CPX #$07
	BCS +
	EOR #$80
+	PLX
	ORA $64
	STA !0303,y

	INY : INY : INY : INY
	INC $0F

.loop	PLX
	DEX
	BPL -
	PLX

	LDY #$02
	LDA $0F
	JSL $01B7B3|!bankb
	RTS

;; specification for people that wish to remap:
;; if the tile is $FC, the tile is flipped horizontally and uses the previously listed non-$F* tile
;; if the tile is $FD, the tile is flipped vertically and uses the previously listed non-$F* tile
;; if the tile is $FE, the tile is flipped horizontally and vertically and uses the previously listed non-$F* tile
;; if the tile is $FF, no tile is drawn
;; this means that if you have a specific frame set to "$A2,$FC,$FD,$FE,$E0"
;; the first 4 tiles are all $A2, but the second is flipped horizontally, third vertically, and fourth horizontally and vertically

.tilemap
	db $00,$02,$20,$22,$FF	; SMB3
	db $04,$06,$24,$26,$FF

	db $00,$02,$20,$22,$A8	; SMM2; idle (AAT edit: use two frames in SP3)
	db $04,$06,$24,$26,$A8
	db $00,$02,$20,$22,$A8

	db $00,$02,$20,$22,$A6	; SMM2; angry (AAT edit: use two frames in SP3)
	db $04,$06,$24,$26,$A6
	db $00,$02,$20,$22,$A6

	;db $A2,$FC,$FD,$FE,$A8	; SMM2; idle
	;db $C0,$FC,$FD,$FE,$A8
	;db $C2,$FC,$FD,$FE,$A8

	;db $A2,$FC,$FD,$FE,$A6	; SMM2; angry
	;db $C0,$FC,$FD,$FE,$A6
	;db $C2,$FC,$FD,$FE,$A6

	db $8A,$AE,$8E,$FF,$FF	; Happy Moon, normal/blinking
	db $86,$AE,$8E,$FF,$FF

	db $8A,$AE,$8E,$FF,$FF	; Happy Moon, diving
	db $E4,$E8,$E6,$FF,$FF

.x_pos	db $00,$10,$00,$10,$00	; SMB3
	db $00,$10,$00,$10,$00

	db $00,$0F,$00,$0F,$08	; SMM2; idle
	db $00,$0F,$00,$0F,$08
	db $00,$0F,$00,$0F,$08

	db $00,$0F,$00,$0F,$08	; SMM2; angry
	db $00,$0F,$00,$0F,$08
	db $00,$0F,$00,$0F,$08

	db $0D,$0D,$FD,$00,$00
	db $0D,$0D,$FD,$00,$00

	db $0D,$0D,$FD,$00,$00
	db $0D,$0D,$FD,$00,$00

.y_pos	db $F0,$F0,$00,$00,$00	; SMB3
	db $F0,$F0,$00,$00,$00

	db $F1,$F1,$00,$00,$F8	; SMM2; idle
	db $F1,$F1,$00,$00,$F8
	db $F1,$F1,$00,$00,$F8

	db $F1,$F1,$00,$00,$F8	; SMM2; angry
	db $F1,$F1,$00,$00,$F8
	db $F1,$F1,$00,$00,$F8

	db $ED,$FD,$FD,$00,$00
	db $ED,$FD,$FD,$00,$00

	db $ED,$FD,$FD,$00,$00
	db $EC,$FC,$FC,$00,$00

.properties
	db $00,$40,$80,$C0