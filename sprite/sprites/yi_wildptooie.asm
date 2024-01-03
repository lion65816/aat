;Wild Ptooie Piranha by smkdan (optimized by Blind Devil)
;DOESN'T USE EXTRA BIT

!SpawnNum = $25			; <<< Set this to number yellow needlenose is inserted as

;Tilemap defines:
TILEMAP:	db $E0,$E0		;open mouth shooting frames (top-left, top-right)
		db $E0,$E0		;(bottom-left, bottom-right)
		db $E0			;the stem

		db $E0,$E0		;closed mouth shooting frames
		db $E0,$E0
		db $E0

		db $E0,$E0		;closed mouth tilt frames
		db $E0,$E0
		db $E0

		db $E0,$E0		;closed mouth horz frames
		db $E0,$E0
		db $E0

!StemPal =	$03			;palette used for the plant stem, CCC format ($FF to use palette from CFG, which's same as the body)

XSPD:		db $20,$18,$10		;Set this to each of the three launch speeds
YSPD:		db $40,$40,$40		;Same deal, for Y speed

!SpitSFX =	$06			;Set this to sound you want it to make when it shoots
!SpitPort =	$1DF9			;port to use for above sfx

PALETTE:	db $00,$04,$08

ACTION:		db $01,$02,$03,$00,$00,$00,$00		;long, middle, short, nothing: face mario, stare, look back
		db $00,$00				;struck behaviour

COUNT:		db $40,$40,$20,$20,$20,$30,$20		;count for different stages
		db $30,$20				;struck counter

EORTBL:		db $00,$FF
INCDEC:		db $00,$01

;===

;1602: Shoot counter
;C2: Shoot behaviour
;1570: hit counter

print "INIT ",pc
	%SubHorzPos()
	TYA
	STA !157C,x		;make it face mario initially

	LDA #$03		;doing nothing initially
	STA !C2,x
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL	;also nothing


Return_I:
	RTS

Run:
	LDA #$03
	%SubOffScreen()
	JSR GFX

	LDA !14C8,x
	CMP #$08            	 
	BNE Return_I           
	LDA $9D			;locked sprites?
	BNE Return_I
	LDA !15D0,x		;being eaten by yoshi?
	BNE Return_I

	%SubHorzPos()		;$09: always facing Mario
	TYA
	STA !157C,x

	JSR CheckHurt		;see if a shell or throw block is making contact
	BEQ NoContact		;zero on not contact, continue as normal

	LDA #$07		;behaviour is set to 'struck'
	STA !C2,x
	STZ !1602,x		;reset counter

;HURT HANDLER

NoContact:
	LDA !C2,x		;check if it's past hurt
	CMP #$08
	BNE AdvCounter

	LDA !1570,x		;load hurt counter
	CMP #$02		;dead?
	BNE NotDeadYet

	JSR SUB_SMOKE		;make smoke

	LDA !D8,x
	CLC
	ADC #$04
	STA !D8,x
	LDA !14D4,x
	ADC #$00		;transfer carry
	STA !14D4,x

	LDA !E4,x
	CLC
	ADC #$09
	STA !E4,x
	LDA !14E0,x
	ADC #$00		;transfer carry
	STA !14E0,x

	JSL $07FC3B|!BankB	;make stars
	STZ !14C8,x		;erase sprite

	LDA #$08
	STA $1DF9|!Base2	;plant death sound
	RTS

NotDeadYet:
	LDA #$03		;when counter expires, set it back to normal status
	STA !C2,x
	STZ !1602,x		;reset counter

	INC !1570,x		;$09: increment hurt counter
	LDY !1570,x		;load hit counter as index

	LDA !15F6,x		;palette, page bit
	AND #$F1		;clip pal bits
	ORA PALETTE,y
	STA !15F6,x		;new GFX bits
			
;SHOOTING / BEHAVIOUR CODE
AdvCounter:	
	INC !1602,x		;advance counter
	LDA !1602,x
	LDY !C2,x
	CMP COUNT,y		;different counter for different behaviour stage
	BCC NoGen		;if count not yet reached, check for generate

;advance behaviour since count was reached

	LDA !C2,x		;load shooting behaviour...
	INC A
	CMP #$07		;7 variables
	BNE DontClipVar
	LDA #$00		;reset shooting behaviour

DontClipVar:
	STA !C2,x		;...new shooting behaviour
	LDY !C2,x		;load new behaviour

	STZ !1602,x		;also zero counter

	LDA ACTION,y		;load speed/control, C2 already in Y for index
	BEQ NoGen		;if zero, skip generating $09
	DEC A			;-1, for index since 00 does nothing		
	STA $09			;store loaded speed to generate

	JSR GenCust		;generate if counted

NoGen:
	JSL $01802A|!BankB	;speed update
	JSL $01A7DC|!BankB	;mario interact

Return:
	RTS	

;===

GenCust:
	LDA !157C,x		;test direction
	BNE GoingLeft
	LDA #$18		;load value for X offset of spawned sprite
	STA $00			;store to scratch RAM (X offset).
	BRA +

GoingLeft:
	STZ $00			;reset scratch RAM (X offset).

+
	LDA #$F3		;load value for Y offset of spawned sprite
	STA $01			;store to scratch RAM (Y offset).

	LDY $09			;load index for speeds
	LDA XSPD,y
	PHY
	LDY !157C,x		;load plant direction as index now...
	EOR EORTBL,y		;invert as needed
	CLC
	ADC INCDEC,y		;adjust for two's complement
	STA $02			;store to scratch RAM (X speed).
	PLY

	LDA YSPD,y		;negative on rising, just easier to manage
	EOR #$FF
	INC A			;two's complement
	STA $03			;store to scratch RAM (Y speed).

	LDA #!SpawnNum		;load sprite number to generate
	SEC			;set carry - spawn custom sprite
	%SpawnSprite()		;call sprite spawning routine

	LDA #!SpitSFX		;play shooting sound
	STA !SpitPort|!Base2
	RTS			;return

;damage check routine

CheckHurt:
	LDY #!SprSize-1		;loop count

CheckLoop:
	LDA !14C8,y		;sprite status
	CMP #$09
	BEQ ClipTest		;jump to cliptest

	CMP #$0A		;sprites never have normal status
	BNE NextSprite

	LDA !1686,y		;skip sprites that don't interact with others
	AND #$08
	BNE NextSprite

ClipTest:
	JSL $03B69F|!BankB	;clipA
	PHX
	TYX
	JSL $03B6E5|!BankB	;clipB
	PLX
	JSL $03B72B|!BankB	;check contact between A and B
	BCC NextSprite		;no contact = don't set

	LDA #$01		;set test variable...
	PHX

;adjust position for stars

	LDA !D8,x
	PHA
	CLC
	ADC #$04
	STA !D8,x
	LDA !14D4,x
	PHA
	ADC #$00		;transfer carry
	STA !14D4,x

	LDA !E4,x
	PHA
	CLC
	ADC #$09
	STA !E4,x
	LDA !14E0,x
	PHA
	ADC #$00		;transfer carry
	STA !14E0,x

	PHY
	JSL $07FC3B|!BankB	;create stars
	PLY

;fix position

	PLA
	STA !14E0,x
	PLA
	STA !E4,x

	PLA
	STA !14D4,x
	PLA
	STA !D8,x

	LDA #$03		;enemy hit sound
	STA $1DF9|!Base2

	TYX
	STZ !14C8,x		;erase sprite

	PLX
	RTS			;...and return

NextSprite:	
        DEY
	BPL CheckLoop

	LDA #$00
	RTS		;last return

;smoke routine on exploding

SUB_SMOKE:
	LDA #$F8 : STA $00	;smoke 1 X offset
	JSR SubroutineLulz	;call label as subroutine lol, we want to carry on after it

	LDA #$18 : STA $00	;smoke 2 X offset
SubroutineLulz:
	LDA #$04 : STA $01	;smoke Y offset (both)
	LDA #$14 : STA $02	;time to show smoke (both)
	LDA #$01		;smoke image number (both)
	%SpawnSmoke()		;call smoke spawning routine
	RTS

;GFX
;===

XDISP:	db $00,$10
	db $00,$10
	db $10

YDISP:	db $F8,$F8
	db $08,$08
	db $10

XBIAS:	db $18,$18
	db $18,$18
	db $20

PROP:	db $00,$00
	db $00,$00
	db $40

CPAL:	db $FF,$FF
	db $FF,$FF
	db !StemPal

EORF:	db $40,$00

PALETTEB:	db $02,$04,$03		;yellow, red, blue
		db $05,$02,$04		;green, yellow

Flinch:
	LDA #$0E		;reset palette bits
	TRB $04
	
	LDA !1602,x		;counter...
	LSR #2			;every 4th tick
	AND #$01
	BNE CustomPal

	PHY
	LDY !1570,x		;hit count
	LDA PALETTEB,y		;load appropriate bit
	PLY
	ASL			;into palette bits
	TSB $04			;set palette bits

	JMP ClosedMouth
	
CustomPal:
	PHY
	LDY !1570,x		;hit count
	INY
	INY
	INY			;2 bytes for each
	LDA PALETTEB,y		;load appropriate bit
	PLY
	ASL			;into palette bits
	TSB $04			;set palette bits
	JMP ClosedMouth

;===
	
GFX:
	%GetDrawInfo()
	LDA !157C,x
	STA $03			;convenient

	LDA !15F6,x
	STA $04

	STZ $08			;reset frame index

;check special cases first

	LDA !C2,x		;load shooting behaviour...

	CMP #$03
	BEQ ClosedMouth		;nothing for a bit...

	CMP #$04		;...then look down
	BEQ LookMario

	CMP #$05
	BEQ JustLook

	CMP #$06
	BEQ LookUp		;...then look up

	CMP #$07
	BEQ Flinch		;struck = flick back and flash

	CMP #$08
	BEQ ClosedMouth

;normal shooting
	LDA !1602,x		;loading shooting frame counter...
	AND #$30		;2 high bits of counter
	CMP #$10		;compare high bits, since mouth should only be open for a bit
	BCS ClosedMouth
	BRA SkipClose		;bottom out on skipclose

LookMario:
	LDA !1602,x		;counter
	AND #$18		;2 high bits
	CMP #$18
	BNE DontClipLM		;if not equal to max, do nothing
	AND #$10		;snip off lower bit	

DontClipLM:	
	LSR #3

	STA $09		;$09 storage	
	ASL #2		;x4
	CLC
	ADC $09		;x5
	ADC #$05	;skip past shoot frame
	STA $08		;new frame index
		
	BRA SkipClose	;bottom out on open

;===

LookUp:
	LDA !1602,x		;counter
	EOR #$18		;invert bits, 'counting down'

	AND #$18		;2 high bits
	CMP #$18
	BNE DontClipLU		;if not equal to max, do nothing
	AND #$10		;snip off lower bit	

DontClipLU:
	LSR #3

	STA $09		;$09 storage	
	ASL #2		;x4
	CLC
	ADC $09		;x5
	ADC #$05	;skip past shoot frame
	STA $08		;new frame index
	BRA SkipClose	;bottom out on open

;===

JustLook:
	LDA #$0F		;$09: just horziontal frame
	STA $08

	BRA SkipClose
	
ClosedMouth:
	LDA #$05		;load mouth frames
	STA $08			;new frame index

SkipClose:
	LDX #$00		;reset loop index

OAM_Loop:
	LDA $03
	BNE XLeft

	LDA $00
	SEC
	SBC XDISP,x
	CLC
	ADC XBIAS,x		;add bias since it throws it on the other side
	STA $0300|!Base2,y
	BRA XNext
XLeft:
	LDA $00
	CLC
	ADC XDISP,x
	STA $0300|!Base2,y

XNext:
	LDA $01
	CLC
	ADC YDISP,x
	STA $0301|!Base2,y

	TXA	
	CLC
	ADC $08
	PHX
	TAX
	LDA TILEMAP,x
	STA $0302|!Base2,y
	PLX

	TXA	
	CLC
	ADC $08
	PHX
	TAX
	LDA $64
	PHX
	LDX $03
	EOR EORF,x
	PLX
	PLX

	ORA PROP,x	;use loop index for the properties

	STA $09		;store current value to $09
	LDA CPAL,x
	CMP #$FF
	BEQ CustomPalB	;if $FF, use user supplied palette

	ASL		;else move into palette bits
	TSB $09		;OR with current bits
	LDA $04
	AND #$01	;load only the low bit, page bit
	TSB $09		;OR with current bits
	LDA $09		;get ready to store it

	BRA StoreProp	;skip past custom palette bit
	
CustomPalB:
	LDA #$00	;reset		
	LDA $04		;just OR with $04
	ORA $09		;and also $09

StoreProp:
	STA $0303|!Base2,y

	INY
	INY
	INY
	INY
	INX
	CPX #$05		;5 tiles
	BNE OAM_Loop

	LDX $15E9|!Base2	;restore sprite index

	LDY #$02		;16x16 tiles
	LDA #$04		;5 tiles
	JSL $01B7B3|!BankB
	RTS