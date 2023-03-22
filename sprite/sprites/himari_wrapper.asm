;;;;;;;;;;;;;;;;;Himari Wraper;;;;;;;;;;;;;;;;;
;Uses extra bit: Yes.
;	Clear = vanilla sprite
;	Set = custom sprite
;Uses extra bytes: yes, 3.
;	Extra byte 1, which sprite to spawn
;	Extra byte 2, how frequently to change direction
;	Extra byte 3, initial duration for movement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!sprite_to_spawn = !1510
!Skip_Frame = !1602			;08
!Init_skip_Frame = !1528	;18


!turn_timer = !1534
!spawned_sprite = !160E


print "INIT ",pc
InitCode:
	%SubHorzPos()
	TYA
	BEQ Init_R
	LDA #$04
	STA !C2,x
Init_R:
	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	LDY #$00
	LDA [$00],y
	STA !sprite_to_spawn,x
	INY
	LDA [$00],y
	STA !Skip_Frame,x
	INY
	LDA [$00],y 
	STA !Init_skip_Frame,x
	INY
	LDA [$00],y 
	PHA
	INY
	LDA [$00],y
	PHA
	INY
	LDA [$00],y
	PHA
	INY
	LDA [$00],y
	PHA
	
	LDA !7FAB10,x
	AND #$04
	BNE .custom
	LDA !sprite_to_spawn,x
	CLC
	BRA .spawn
.custom
	LDA !sprite_to_spawn,x
	SEC
.spawn
	%SpawnSprite() 
	BCC .set_and_finsh
	JSR Erase
.set_and_finsh
	STX $00
	TYX
	PLA
	STA !extra_byte_4,x
	PLA
	STA !extra_byte_3,x
	PLA
	STA !extra_byte_2,x
	PLA
	STA !extra_byte_1,x
	LDX $00
	TYA
	STA !spawned_sprite,x
	LDA !Init_skip_Frame,x
	STA !turn_timer,x
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Main_Code
	PLB
	RTL
	
	
Update_Wrapper_Position:
	LDA !spawned_sprite,x
	TAY
	LDA !14C8,y
	BEQ .not_alive
	CMP #$01
	BEQ .continue
	CMP #$08
	BCC .not_alive
.continue
	LDA !D8,x
	STA !D8,y
	LDA !E4,x
	STA !E4,y
	LDA !14D4,x
	STA !14D4,y
	LDA !14E0,x
	STA !14E0,y
	SEC
	RTS
.not_alive
	CLC
	RTS

Erase:
	STZ !14C8,x
	PHX
	LDA !161A,x
	TAX
	LDA #$00
	STA !1938,x
	PLX
Return:
	RTS
	
	
X_Max:			db $20,$20,$00,$E0,$E0,$E0,$00,$20
Y_Max:			db $00,$20,$20,$20,$00,$E0,$E0,$E0
Accel_X:		db $01,$01,$00,$FF,$FF,$FF,$00,$01
Accel_Y:		db $00,$01,$01,$01,$00,$FF,$FF,$FF
Brake:			db $FC,$04



Main_Code:
	LDA $9D
	BNE Return
	LDA !14C8,x
	CMP #$08
	BNE Erase
	%SubOffScreen()
	JSR Update_Wrapper_Position
	BCC Erase
	DEC !turn_timer,x
	BNE Update_Pos
	JSR Update_Dir
	LDA !Skip_Frame,x
	STA !turn_timer,x
Update_Pos:
	LDY !C2,x
	LDA !B6,x
	STA $00
	STA $03
	JSR Speed_Update
	LDA $03
	STA !B6,x
	LDA !C2,x
	ORA #$08
	TAY
	LDA !AA,x
	STA $00
	STA $03
	JSR Speed_Update
	LDA $03
	STA !AA,x
	
	JSL $01801A
	JSL $018022
	RTS

Killer_Dir:		db $01,$03,$07,$05	;右下,左下,右上,左上
				db $05,$07,$03,$01	;マリオが無敵だった場合使用する


Update_Dir:
	%SubHorzPos()
	STY $00
	%SubVertPos()
	TYA
	ASL A
	ORA $00
	LDY $1490|!addr
	BEQ NoStar
	ORA #$04
NoStar:
	TAY
	LDA Killer_Dir,y
	CMP !C2,x
	BEQ Return2
	
	EOR #$07
	INC A
	CLC
	ADC !C2,x
	AND #$07
	STA $00
	EOR #$07
	INC A
	CMP $00
	LDA !C2,x
	BCS Label0
Label2:
	INC A
	BRA Label1
Label0:
	DEC A
Label1:
	AND #$07
	STA !C2,x
Return2:
	RTS

Speed_Update:
	LDA Accel_X,y
	STA $02
	LDA X_Max,y
	STA $01
	BEQ Label_Zero
	BPL Label_Inc
	LDA $00
	EOR #$FF
	INC A
	STA $00
	LDA $01
	EOR #$FF
	INC A
	STA $01
Label_Inc:
	LDA $00
	CMP $01
	BCS Speed_Max
	LDA $03
	CLC
	ADC $02
	STA $03
	RTS
Speed_Max:
	LDA X_Max,y
	STA $03
	RTS
	
Label_Zero:
	LDY #$00
	LDA $00
	BEQ Return10
	BPL If_Plus10
	INY
If_Plus10:
	CLC
	ADC Brake,y
	STA $03
Return10:
	RTS



