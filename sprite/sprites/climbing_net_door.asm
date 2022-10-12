;; Pretty much grabbed from p4plus2's/thomas' (kaizoman) disassembly. 
;; 99% of the comments come from the disassembly so credits to them
;; SA-1 hybrid
;; Disassembled by Atari2.0

;; This define lets you decide if you want vanilla hardcoded choice of OAM slot or not
;; If you set this to anything other than 0, it will use dynamic slots
;; If you set this to not 0, use of No More Sprite Tile Limits is very recommended
!hardcodedoamslot = 0


print "INIT", pc
	InitClimbingDoor:			;-----------| Climbing door INIT
	LDA !E4,X					;|\ 
	CLC							;||
	ADC.b #$08					;||
	STA !E4,X					;|| Offset X/Y position to line up with the object.
	LDA !D8,X					;||
	ADC.b #$07					;||
	STA !D8,X					;|/
	RTL

print "MAIN", pc
	PHB
	PHK
	PLB
	JSR RotatingNet
	PLB
	RTL

DrawOffsets:								;| Offsets from their normal position to draw the columns for each frame of the animation.
	db $00,$01,$02,$04,$06,$09,$0C,$0D
	db $14,$0D,$0C,$09,$06,$04,$02,$01

ColumnNumber:								;| Number of columns to not draw for each frame of the animation.
	db $00,$00,$00,$00,$00,$01,$01,$01
	db $02,$01,$01,$01,$00,$00,$00,$00

TileNumber:									;| Tile numbers to use based on the number of columns.
	db $20,$30,$20,$20,$30,$20,$21,$31,$21	; Three columns
	db $25,$35,$25,$25,$35,$25				; Two columns
	db $00,$00,$00							; (unused)
	db $23,$33,$23							; One column
	;db $00,$10,$00,$00,$10,$00,$01,$11,$01	; Three columns
	;db $05,$15,$05,$05,$15,$05				; Two columns
	;db $00,$00,$00							; (unused)
	;db $03,$13,$03							; One column

	; Climbing door misc RAM:
	; $1540 - Timer for the turning animation.
	; $154C - Timer to wait briefly after being hit before turning. Set to #$07 on hit.
RotatingNet:					;-----------| Climbing door MAIN
	LDA #$00
	%SubOffScreen()				;| Process offscreen from -$40 to +$30.
	LDA.w !154C,X				;|\ 
	CMP.b #$01					;|| Handle Mario preparing the fence to turn shortly after being hit.
	BNE CODE_01BAF5				;||
	LDA.b #$0F					;||\ SFX for the door turning.
	STA.w $1DF9|!addr			;||/
	LDA.b #$19					;||\ Erase the net object below.
	JSL $03C000|!BankB			;||/
	LDA.b #$1F					;||\ 
	STA.w !1540,X				;||| Start the turn.
	STA.w $149D|!addr			;||/
	LDA $94						;||\ 
	SEC							;|||
	SBC.b #$10					;||| Preserve Mario's distance from the center of the net.
	SEC							;|||  Routine that uses it is at $00DB17.
	SBC !E4,X					;|||
	STA.w $1878|!addr			;|//
CODE_01BAF5:					;|
	LDA.w !1540,X				;|\ 
	ORA.w !154C,X				;||
	BNE CODE_01BB16				;||
	JSL $03B69F|!BankB			;|| Mark the net as hit and ready to turn if:
	JSR ChangeMarioClipping		;||  - Not already turning/being hit.
	JSL $03B72B|!BankB			;||  - Mario is in contact.
	BCC CODE_01BB16				;||  - Mario has punched the net.
	LDA.w $149E|!addr			;||
	CMP.b #$01					;||
	BNE CODE_01BB16				;||
	LDA.b #$06					;||
	STA.w !154C,X				;|/
CODE_01BB16:					;|
	LDA.w !1540,X				;|\ Return (and don't draw) if not in the process of turning.
	BNE	+
	RTS							;|/
	+ CMP.b #$01				;|\ 
	BNE CODE_01BB27				;||
	PHA							;|| Restore the net object below the fence if finished turning.
	LDA.b #$1A					;||
	JSL $03C000|!BankB			;||
	PLA							;|/
CODE_01BB27:					;|
	CMP.b #$10					;|\ 
	BNE CODE_01BB33				;||
	LDA.w $13F9|!addr			;|| Invert Mario's layer when halfway turned.
	EOR.b #$01					;||
	STA.w $13F9|!addr			;|/
CODE_01BB33:					;| Climbing door GFX routine.
if !hardcodedoamslot != 0
	LDY !15EA,X					;| Thanks to Ragey for this part
	STY $03						;| This modification makes it so it uses dynamic
	TYA							;| index instead of hardcoded
	LSR #2						;|
	STA $0F						;| Also preserve the index for 0400
else
	LDA #$30					;| I guess I'll leave this in
	STA !15EA,x
	STA $03
	TAY
endif
	LDA !E4,X					;|\ 
	SEC							;||
	SBC $1A						;||
	STA $00						;||
	LDA !D8,X					;|| Set up some scratch RAM.
	SEC							;||  $00 - X position
	SBC $1C						;||  $01 - Y position
	STA $01						;||  $02 - Turn timer, divided by 2
	LDA.w !1540,X				;||  $06 - Number of columns to not draw.
	LSR							;||
	STA $02						;||
	TAX							;||
	LDA.w ColumnNumber,X		;||
	STA $06						;|/
	LDA $00						;|\ 
	CLC							;||
	ADC.w DrawOffsets,X			;||
	STA.w $0300|!addr,Y			;||
	STA.w $0304|!addr,Y			;||
	STA.w $0308|!addr,Y			;||
	LDA $06						;||
	CMP.b #$02					;||
	BEQ CODE_01BB8E				;||
	LDA $00						;||
	CLC							;||
	ADC.b #$20					;||
	SEC							;|| Set X positions.
	SBC.w DrawOffsets,X			;||
	STA.w $030C|!addr,Y			;||
	STA.w $0310|!addr,Y			;||
	STA.w $0314|!addr,Y			;||
	LDA $06						;||
	BNE CODE_01BB8E				;||
	LDA $00						;||
	CLC							;||
	ADC.b #$10					;||
	STA.w $0318|!addr,Y			;||
	STA.w $031C|!addr,Y			;||
	STA.w $0320|!addr,Y			;|/
CODE_01BB8E:					;|
	LDA $01						;|\
	STY $08						;|| Preserve Y
	LDX #$02					;|| 2 loops
	.loop						;|| This loop was previously unrolled and it was really ugly to look at
	STA.w $0301|!addr,Y			;||	so I made it a proper loop
	STA.w $030D|!addr,Y			;||
	STA.w $0319|!addr,Y			;||
	CLC							;||
	ADC.b #$10					;||
	INY #4
	DEX
	BPL .loop
	LDX $15E9|!addr
	LDY $08
	LDA.b #$08					;|\ 
	STA $07						;||
	LDA $06						;||
	ASL #3
	ADC $06						;||
	TAX							;||
CODE_01BBBD:					;|| Set tile numbers.
	LDA.w TileNumber,X			;||
	STA.w $0302|!addr,Y			;||
	INY #4
	INX							;||
	DEC $07						;||
	BPL CODE_01BBBD				;|/
	LDY $03						;|\ 
	LDX.b #$08					;||
CODE_01BBD0:					;||
	LDA $64						;||
	ORA.b #$09					;||| CCCT bits.
	CPX.b #$06					;||
	BCS CODE_01BBDA				;||
	ORA.b #$40					;||
CODE_01BBDA:					;||
	CPX.b #$00					;||
	BEQ CODE_01BBE6				;|| Set YXPPCCCT.
	CPX.b #$03					;||  Set X bit for right column,
	BEQ CODE_01BBE6				;||  and Y bit for bottom row.
	CPX.b #$06					;||
	BNE CODE_01BBE8				;||
CODE_01BBE6:					;||
	ORA.b #$80					;||
CODE_01BBE8:					;||
	STA.w $0303|!addr,Y			;||
	INY #4
	DEX							;||
	BPL CODE_01BBD0				;|/
	LDA $06						;|
	PHA							;|
	LDX.w $15E9|!addr			;|\ 
	LDA.b #$08					;|| Draw 9 16x16 tiles.
	JSR FinishOAMWriteWith2		;|/
if !hardcodedoamslot != 0
	LDY.b $0F					;|\ 
else
	LDY.b #$0C
endif
	PLA							;||
	BEQ Return01BC1C			;||
	CMP.b #$02					;||
	BNE CODE_01BC11				;||
	LDA.b #$03					;||
	STA.w $0463|!addr,Y			;|| Send unused columns offscreen.
	STA.w $0464|!addr,Y			;||
	STA.w $0465|!addr,Y			;||
CODE_01BC11:					;||
	LDA.b #$03					;||
	STA.w $0466|!addr,Y			;|| This is ugly
	STA.w $0467|!addr,Y			;||
	STA.w $0468|!addr,Y			;|/
Return01BC1C:					;|
	RTS							;|

FinishOAMWriteWith2:
	LDY #$02
	JSL $01B7B3|!BankB			;| FinishOAMWrite
	RTS

ChangeMarioClipping:			;| Set clipping values for Mario. Used for the rotating fence sprite.
	LDA $94						;|  Why they didn't just change the sprite's hitbox, who knows.
	STA $00						;|
	LDA $96						;|
	STA $01						;|
	LDA.b #$10					;|
	STA $02						;|
	STA $03						;|
	LDA $95						;|
	STA $08						;|
	LDA $97						;|
	STA $09						;|
	RTS							;|