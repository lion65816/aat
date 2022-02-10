;Customized Firebar
;by Isikoro

Fireball_Tile:	db $2C,$2D,$2C,$2D	;Small
				db $A6,$AA,$A6,$AA	;Big
Fireball_Prop:	db $04,$04,$C4,$C4	;Small
				db $05,$05,$C5,$C5	;Big

Clip_Size:		db $06,$00,$0C
Clip_Disp:		dw $0001,$0002

					print "INIT ",pc
					LDA !extra_byte_1,x	
					STA !AA,x
					
					AND #$20 : BNE +
					LDA !E4,x : CLC : ADC #$04 : STA !E4,x
					LDA !D8,x : CLC : ADC #$04 : STA !D8,x
					
+					LDA !extra_byte_2,x	
					STA !B6,x : BPL +
					AND #$7F : STA !B6,x
					
+					LDA !extra_bits,x : AND #$04
					BEQ +
					LDA !B6,x : EOR #$FF : INC : STA !B6,x
					
+					LDA !extra_byte_3,x : TAY
					ASL #5 : ORA #$08 : STA !C2,x
					TYA : LSR #3 : ORA !1504,x : STA !1504,x
					
					LDA !extra_byte_4,x	
					TAY : LSR #4 : STA $00
					TYA : ASL #4 : ORA $00
					STA !extra_byte_4,x
					
					AND #$F7 : BEQ Init_Not_Pendulum
					
					LDA !extra_bits,x : AND #$FB
					LDY !B6,x : BMI +
					ORA #$04
+					STA !extra_bits,x
					
Init_Not_Pendulum:	LDA !E4,x : STA $04	: LDA !14E0,x : STA $05
					LDA !D8,x : STA $06 : LDA !14D4,x : STA $07
					
					LDA !extra_byte_4,x
					AND #$08 : BEQ +
					
					REP #$20
					
					SEC : LDA $1A : SBC $1E : STA $00
					SEC : LDA $1C : SBC $20 : STA $02
					
					CLC : LDA $04 : ADC $00 : STA $04
					CLC : LDA $06 : ADC $02 : STA $06
					
					SEP #$20
					
					STA !D8,x : XBA : STA !14D4,x
					LDA $04 : STA !E4,x : LDA $05 : STA !14E0,x
					
+					LDA !extra_prop_1,x
					BEQ No_Shift
					
					CLC
					LDA !AA,x : AND #$20 : BEQ +
					SEC
+					LDA !AA,x : AND #$1F : BCC +
					ASL
+					SEC : SBC #$04 : BCC No_Shift
					AND #$FE : ASL #3 : STA $08
					LDA $5B : LSR
					BCS Shift_Vert
					
					LDA !extra_byte_2,x
					BMI Shift_Left
					REP #$20
					LDA $04 : CMP $94 : BMI Shift_Erase
					SEP #$20
					CLC
					LDA !E4,x : ADC $08 : STA !E4,x
					LDA !14E0,x : ADC #$00 : STA !14E0,x
					BRA Overlap_Check
					
No_Shift:			RTL
					
Shift_Left:			SEC
					LDA !E4,x : SBC $08 : STA !E4,x
					LDA !14E0,x : SBC #$00 : STA !14E0,x
					BRA Overlap_Check
					
Shift_Vert:			LDA !extra_byte_2,x
					BMI Shift_Top
					CLC
					LDA !D8,x : ADC $08 : STA !D8,x
					LDA !14D4,x : ADC #$00 : STA !14D4,x
					BRA Overlap_Check
					
Shift_Top:			SEC
					LDA !D8,x : SBC $08 : STA !D8,x
					LDA !14D4,x : SBC #$00 : STA !14D4,x
					BRA Overlap_Check
					
Overlap:			LDX $0E
Shift_Erase:		SEP #$20
					LDA #$80 : STA !14E0,x : STA !14D4,x
					%SubOffScreen_New()
					RTL

Overlap_Check:		LDA !extra_byte_1,x : STA $0C
					LDA !extra_byte_3,x : STA $0D
					LDA !extra_bits,x : STA $0B
					STZ $00 : STZ $01
					LDA $17BE|!Base2 : BPL + : DEC $00
+					LDA $17BF|!Base2 : BPL + : DEC $01
+					LDA !7FAB9E,x
					STA $0F : STX $0E
					TXY
					LDX #!SprSize-1
.Loops:				CPX $0E : BEQ .Next
					LDA !7FAB9E,x
					CMP $0F : BEQ .Position_Check
.Next:				DEX : BPL .Loops
					LDX $0E
					RTL
					
.Position_Check:	LDA !14C8,x : CMP #$08 : BNE .Next
					LDA !extra_byte_1,x : CMP $0C : BNE .Next
					LDA !extra_byte_3,x : CMP $0D : BNE .Next
					LDA !extra_bits,x : CMP $0B : BNE .Next
					
					CPX $0E : BCS .Layer2_Interlocking
					LDA !D8,x : CMP !D8,y : BNE .Next
					LDA !14D4,x : CMP !14D4,y : BNE .Next
					LDA !E4,x : CMP !E4,y : BNE .Next
					LDA !14E0,x : CMP !14E0,y : BNE .Next
					JMP Overlap
					
.Layer2_Interlocking:
					SEC 
+					LDA !D8,y : SBC $17BE|!Base2 : STA $02
					LDA !14D4,y : SBC $00 : CMP !14D4,x : BNE .Next
					LDA $02 : CMP !D8,x : BNE .Next
					SEC
+					LDA !E4,y : SBC $17BF|!Base2 : STA $03
					LDA !14E0,y : SBC $01 : CMP !14E0,x : BNE .Next
					LDA $03 : CMP !E4,x : BNE .Next
					JMP Overlap
					
                    print "MAIN ",pc
                    PHB : PHK : PLB
                    JSR START_SPRITE_CODE
                    PLB
                    RTL
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Carry_Offset:		db $00,$FF
					
RETURN_:			JMP RETURN
					
START_SPRITE_CODE:	LDA !AA,x
					TAY : AND #$20
					LSR #3 : STA $D7 			;ファイアボールのサイズが小なら00、大なら04
					TYA : AND #$1F : STA $0C	;ファイアボールの数－１
					ASL #3
					LDY $D7 : BEQ + : ASL
+					%SubOffScreen_New()
					
					LDA !1504,x : XBA : LDA !C2,x
					REP #$20
					LSR #4 : STA $04
					DEC : LSR : SEP #$21
					SBC #$C0 : STA $0F
					LDA !extra_byte_1,x : AND #$C0
					STA $0E
					SEC
					LDA $0F : SBC $0E : STA $0F
					
					JSR Circle
					
					LDA !14C8,x	: CMP #$08 : BNE RETURN_
					LDA $9D : BNE RETURN_
					
					LDA !extra_byte_4,x : TAY
					AND #$F7 : BEQ Not_Pendulum
					AND #$07 : STA $05
					TYA : AND #$F0 : STA $06 ; Accumulating fraction bits for fixed point Rotational speed.
					LDY $0F : CPY #$7F : BEQ ++
					BCS To_Counter
					
To_Clockwise:		LDA !151C,x : ADC $06 : STA !151C,x
					LDA !B6,x : ADC $05 : STA !B6,x
					LDA !extra_bits,x
					BCC Pendulum_Return : ORA #$04 : STA !extra_bits,x
					BRA Pendulum_Return
					
++					LDA !extra_bits,x
					BRA Pendulum_Return
					
To_Counter:			LDA !151C,x : SBC $06 : STA !151C,x
					LDA !B6,x : SBC $05 : STA !B6,x
					LDA !extra_bits,x
					BCS Pendulum_Return : AND #$FB : STA !extra_bits,x
					
Pendulum_Return:	LDY #$00
					AND #$04 : BNE +
					INY
+					LDA !B6,x : CLC : ADC !C2,x : STA !C2,x
					LDA !1504,x : ADC Carry_Offset,y : STA !1504,x
					BRA With_Layer2
					
					
					
Not_Pendulum:		LDY #$00
					LDA !AA,x : BIT #$C0
					BEQ ONOFF_Unrelated
					BPL ONOFF_Inversion
					
					CLC : AND #$40 : ROL #3 : EOR $14AF|!Base2 : BEQ With_Layer2
					
ONOFF_Inversion:	LDA $14AF|!Base2 : BEQ ONOFF_Unrelated
					LDA !B6,x : EOR #$FF : INC : BRA +
					
ONOFF_Unrelated:	LDA !B6,x
+					BPL +
					INY
+					CLC : ADC !C2,x : STA !C2,x
					LDA !1504,x : ADC Carry_Offset,y : STA !1504,x
					
With_Layer2:		LDA !extra_byte_4,x : AND #$08 : BEQ RETURN
					
					SEC : LDY #$00
					LDA $17BE|!Base2 : BPL + : INY
+					LDA !D8,x : SBC $17BE|!Base2 : STA !D8,x
					LDA !14D4,x : SBC Carry_Offset,y : STA !14D4,x
					
					SEC : LDY #$00
					LDA $17BF|!Base2 : BPL + : INY
+					LDA !E4,x : SBC $17BF|!Base2 : STA !E4,x
					LDA !14E0,x : SBC Carry_Offset,y : STA !14E0,x
					
RETURN:				JSR SUB_GFX
					RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Circle:				PHX : REP #$30
					LDA $04
					AND #$00FF : ASL : TAX		;cos_index
					EOR #$0100 : TAY			;sin_index
					LDA $04 : LSR : STA $D5
					LDA $07F7DB|!BankB,x
					ASL #3
					TYX					;sin
					
					LDY $D4
					BPL + : EOR #$FFFF : INC
+					STA $0DD1|!Base2		;Vertical spacing between fireballs

					LDA $07F7DB|!BankB,x
					ASL #3
					
					CPY #$C000
					BPL + : EOR #$FFFF : INC
+					STA $0DCF|!Base2		;Horizontal spacing between fireballs
					SEP #$30
					
					PLX : RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:            JSR FireBar_GetDrawInfo
					
					LDA $00 : STA $0E			;Center axis drawing X position
					LDA $01 : DEC : STA $D6		;Center axis drawing Y position
					STZ $D5 : STZ $0D			;Multiply the number by 16.
					
					STY $0F					;Fireball_Clipping
					LDA $D7 : LSR : TAY
					LDA Clip_Disp,y
					CLC : ADC !E4,x : STA $04
					LDA !14E0,x : ADC #$00 : STA $05
					LDA Clip_Disp,y
					CLC : ADC !D8,x : STA $0A
					LDA !14D4,x : ADC #$00 : STA $0B
					
					JSL $03B664|!BankB
					
					REP #$21
					STZ $06
					LDA $1A : PHA : ADC Clip_Disp,y : STA $1A
					CLC
					LDA $1C : PHA : ADC Clip_Disp,y : STA $1C
					SEP #$20
					
					LDA $0DD0|!Base2 : BPL + : DEC $06
+					LDA $0DD2|!Base2 : BPL + : DEC $07
					
+					PHX
					
					LDA $14 : AND #$0C : LSR #2
					ADC $D7 : TAX : STY $D7
					
					CPY #$00 : BEQ .Small
					
					PHX : LDA $0C : PHA
					LDY $0F
					
					LDA $0E : STA $0300|!Base2,y
					LDA $D6 : STA $0301|!Base2,y
					
					REP #$21
					LDA $0D : ADC $0DCF|!Base2 : STA $0D
					CLC : LDA $D5 : ADC $0DD1|!Base2 : STA $D5
					
					ASL $0DCF|!Base2 : ASL $0DD1|!Base2
					
					SEP #$21
					LDA $0E : SBC $0300|!Base2,y
					TAX	: BEQ +
					LDX $06
+					STX $0C
					CLC : ADC $04 : STA $04
					LDA $05 : ADC $0C : STA $05
					
					SEC
					LDA $D6 : SBC $0301|!Base2,y
					TAX	: BEQ +
					LDX $07
+					STX $0C
					CLC : ADC $0A : STA $0A
					LDA $0B : ADC $0C : STA $0B
					
					PLA : STA $0C : PLX
					
.Small:				LDY $0F
					
					LDA Fireball_Tile,x
					STA $0302|!Base2,y
					
					LDA Fireball_Prop,x
					ORA $64
					STA $0303|!Base2,y
					
					LDX $0C
					
.Loops:				JMP .Fireball_Contact
					BCC .No_Contact
					PHY
					LDA $187A|!Base2
					BEQ .No_Yoshi : %LoseYoshiOrHurt()
					BRA .Yoshi_Ran_away
.No_Yoshi:			JSL $00F5B7|!BankB
.Yoshi_Ran_away:	PLY
					
.No_Contact:		LDA $0E : STA $0300|!Base2,y
					LDA $D6 : STA $0301|!Base2,y
					
					DEX : BPL +
					JMP .Write_End
+					PHX
					
					TYA : LSR #2 : TAX
					LDA $D7 : STA $0460|!Base2,x
					
					STZ $0F
					REP #$20
					SEC : LDA $04 : SBC $1A : BPL +
					INC $0460|!Base2,x
+					CMP #$0100 : BPL .OverScreen
					CMP #$FFF0 : BMI .OverScreen
					SEC : LDA $0A : SBC $1C
					CMP #$00E0 : BPL .OverScreen
					CMP #$FFF0 : BMI .OverScreen
					BRA .OnScreen_X
					
.OverScreen:		INC $0F
					
.OnScreen_X:		CLC : LDA $0D : ADC $0DCF|!Base2 : STA $0D
					CLC : LDA $D5 : ADC $0DD1|!Base2 : STA $D5
					
					SEP #$21
					LDA $0E : SBC $0300|!Base2,y
					TAX	: BEQ +
					LDX $06
+					STX $0C
					CLC : ADC $04 : STA $04
					LDA $05 : ADC $0C : STA $05
					
					SEC
					LDA $D6 : SBC $0301|!Base2,y
					TAX	: BEQ +
					LDX $07
+					STX $0C
					CLC : ADC $0A : STA $0A
					LDA $0B : ADC $0C : STA $0B
					
					REP #$20
					
					LDX $0F : BEQ +
					LDA #$F000 : STA $0300|!Base2,y
					BRA ++
					
+					LDA $0302|!Base2,y
					INY #4
					STA $0302|!Base2,y
++					SEP #$20
					PLX
					
					JMP .Loops
					
.Write_End:			TYA : LSR #2 : TAX
					LDA $D7 : STA $0460|!Base2,x
					
					STZ $0F
					REP #$20
					SEC : LDA $04 : SBC $1A : BPL +
					INC $0460|!Base2,x
+					CMP #$0100 : BPL ..OverScreen
					CMP #$FFF0 : BMI ..OverScreen
					SEC : LDA $0A : SBC $1C
					CMP #$00E0 : BPL ..OverScreen
					CMP #$FFF0 : BMI ..OverScreen
					BRA ..OnScreen_X
					
..OverScreen:		LDA #$F000 : STA $0300|!Base2,y
..OnScreen_X:		PLX
					
					PLA : STA $1C
					PLA : STA $1A
					SEP #$20
					
					RTS
					


.Fireball_Contact:
CPX $0C : BNE +
LDA $D7 : BNE +
CLC
JMP .Loops+3
+
STY $0F
LDY $D7

LDA $01 : SEC : SBC $0A
PHA : LDA $09 : SBC $0B : STA $0C
PLA : CLC : ADC #$80
LDA $0C : ADC #$00
BNE .No_Contacrt
LDA $0A : SEC : SBC $01
CLC : ADC Clip_Size,y
STA $0C
LDA $03
CLC : ADC Clip_Size,y
CMP $0C : BCC .No_Contacrt

LDA $00 : SEC : SBC $04
PHA : LDA $08 : SBC $05 : STA $0C
PLA : CLC : ADC #$80
LDA $0C : ADC #$00
BNE .No_Contacrt
LDA $04 : SEC : SBC $00
CLC : ADC Clip_Size,y
STA $0C
LDA $02
CLC : ADC Clip_Size,y
CMP $0C

.No_Contacrt:
LDY $0F
JMP .Loops+3


FireBar_GetDrawInfo:
   STZ !186C,x
   LDA !14E0,x
   XBA
   LDA !E4,x
   REP #$20
   SEC : SBC $1A
   STA $00
   CLC
   ADC.w #$0040
   CMP.w #$0180
   SEP #$20
   LDA $01
   BEQ +
   LDA #$01
+  STA !15A0,x
   ; in sa-1, this isn't #$000
   ; this actually doesn't matter
   ; because we change A and B to different stuff
   TDC
   ROL A
   STA !15C4,x

   LDA !14D4,x
   XBA
   LDA !190F,x
   AND #$20
   BEQ .CheckOnce
.CheckTwice
   LDA !D8,x
   REP #$21
   ADC.w #$001C
   SEC : SBC $1C
   SEP #$20
   LDA !14D4,x
   XBA
   BEQ .CheckOnce
   LDA #$02
.CheckOnce
   STA !186C,x
   LDA !D8,x
   REP #$21
   ADC.w #$000C
   SEC : SBC $1C
   SEP #$21
   SBC #$0C
   STA $01
   XBA
   BEQ .OnScreenY
   INC !186C,x
.OnScreenY
   LDY !15EA,x
   RTS