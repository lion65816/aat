;~@sa1 <-- DO NOT REMOVE THIS LINE!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ?z?[?~???O?L???[
;						???:??33953YoShI
; ?}???I??u???????B
; ?O?????
;
; $C2,x : ?i?s????
; $00 $01 $02 $03 $04 $05 $06 $07
; ?E,?E??,??,????,??,????,??,?E??
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Uses first extra bit: YES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			;incsrc defs.asm
			!Skip_Frame	= $08		;????????ou????x??????
							;$08?????????
							;$00?Œu?????????
			!Init_Skip_Frame	= $18		;??o?????u????x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
InitCode:
			LDA #!Init_Skip_Frame
			STA $32B0,x
			PHY
			%SubHorzPos()
			TYA
			BEQ Init_R
			LDA #$04
			STA $D8,x
Init_R:			
			PLY
			LDA #$10
			STA $32F2,x
			RTL

print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR Main_Code
			PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_Max:			db $20,$20,$00,$E0,$E0,$E0,$00,$20
Y_Max:			db $00,$20,$20,$20,$00,$E0,$E0,$E0
Accel_X:		db $01,$01,$00,$FF,$FF,$FF,$00,$01
Accel_Y:		db $00,$01,$01,$01,$00,$FF,$FF,$FF
Brake:			db $FC,$04

;Return:			RTS
Main_Code:	
			LDA $9D
			BNE Gfx_Label
			LDA $3242,x
			CMP #$08
			BNE Gfx_Label
			%SubOffScreen()
			DEC $32B0,x
			BNE Update_Pos
			JSR Update_Dir
			LDA #!Skip_Frame
			STA $32B0,x
Update_Pos:
			LDY $D8,x
			LDA $B6,x
			STA $00
			STA $03
			JSR Speed_Update
			LDA $03
			STA $B6,x

			LDA $D8,x
			ORA #$08
			TAY
			LDA $9E,x
			STA $00
			STA $03
			JSR Speed_Update
			LDA $03
			STA $9E,x

			JSL $01801A
			JSL $018022
			;CLC
			JSL $01A7DC
			;BCC Gfx_Label
			;LDA #$80    ; \ If carry is set, mario touched the sprite IS THIS FRAMERULE DEPENDENT?
			;STA $1406   ; / Code to make the camera always scroll after mario touches
Gfx_Label:		
			JSR Gfx_Update
			STA $03
			LDA $64
			PHA
			LDA $32F2,x
			BEQ Gfx_Label1
			LDA #$10
			STA $64
Gfx_Label1:		JSR SubGfx
			PLA
			STA $64
			RTS

Killer_Dir:		db $01,$03,$07,$05	;?E??,????,?E??,????
				db $05,$07,$03,$01	;?}???I?????G?????????g?p????

Update_Dir:	
			%SubHorzPos()
			STY $00
			%SubVertPos()
			TYA
			ASL A
			ORA $00
			LDY $7490
			BEQ NoStar
			ORA #$04
NoStar:			
			TAY
			LDA Killer_Dir,y
			CMP $D8,x
			BEQ Return2

			EOR #$07
			INC A
			CLC
			ADC $D8,x
			AND #$07
			STA $00
			EOR #$07
			INC A
			CMP $00
			LDA $D8,x
			BCS Label0
Label2:			INC A
			BRA Label1
Label0:			DEC A
Label1:			AND #$07
			STA $D8,x
Return2:		RTS

Gfx_Update:		LDA $B6,x	;\
			ORA $9E,x	; | X???x,Y???x????????x??$00????????
			BEQ Dir_Return	;/  ?O???t?B?b?N??X??????s????

			LDA $9E,x
			PHP
			BPL If_Plus0
			EOR #$FF
			INC A
If_Plus0:		STA $00
			STA $02

			LDA $B6,x
			PHP
			BPL If_Plus1
			EOR #$FF
			INC A
If_Plus1:		STA $01
			STA $03

			BEQ X_Zero	;\
			LDA $00		; | ?[?????Z?h?~
			BEQ Y_Zero	;/
			LDA $01
			STA $2252
			STZ $4204
			LDA $00
			STA $2253
			STZ $2254
			NOP
			NOP
			NOP      
			ASL $4214
			LDA $2307
			ADC #$00
			STA $02

			LDA $00
			STA $2252
			STZ $4204
			LDA $01
			STA $2253
			STZ $2254
			NOP
			NOP
			NOP      
			ASL $4214
			LDA $2307
			ADC #$00
			STA $03

			LDA $02
			BEQ X_Zero
			LDA $03
			BEQ Y_Zero

			LDA #$00
			PLP
			BPL If_Plus2
			ORA #$01
If_Plus2:		PLP
			BPL If_Plus3
			ORA #$02
If_Plus3:		TAY
			LDA Killer_Dir,y
Dir_Return:		RTS

X_Zero:			LDA #$02
			PLP
			PLP
			BPL If_Plus4
			ORA #$04
If_Plus4:		RTS

Y_Zero:			LDA #$00
			PLP
			BPL If_Plus5
			ORA #$04
If_Plus5:		PLP
			RTS

Speed_Update:		LDA Accel_X,y
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
Label_Inc:		LDA $00
			CMP $01
			BCS Speed_Max
			LDA $03
			CLC
			ADC $02
			STA $03
			RTS

Speed_Max:		LDA X_Max,y
			STA $03
			RTS

Label_Zero:		LDY #$00
			LDA $00
			BEQ Return10
			BPL If_Plus10
			INY
If_Plus10:		CLC
			ADC Brake,y
			;AND #$FC
			STA $03
Return10:		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TileMap:		db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
TileProp:		db $40,$41,$81,$01,$00,$41,$01,$01
Pals:			db $02,$08

SubGfx:		%GetDrawInfo()
			PHY
			LDA $14
			LSR A
			AND #$01
			TAY
			LDA Pals,y
			STA $04
Gfx_Label0:		PLY
			LDA $00
			STA $6300,y
			LDA $01
			STA $6301,y
			PHX
			LDX $03
			LDA TileMap,x
			STA $6302,y
			LDA TileProp,x
			PLX
			ORA $04
			ORA $64
			STA $6303,y

			LDY #$02
			LDA #$00
			JSL $01B7B3
			RTS
