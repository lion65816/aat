;Green Needlenose by smkdan (optimized by Blind Devil)
;bouncy green cactus ball that comes with Baron Von Zeppelin

;DOESN'T USE EXTRA BIT

;Extra prop 1: How high the jump is when it bounces off the ground (00-7F).

;Tilemap define:
!TILEMAP =	$0E	;needlenose tile

!BoingSFX =	$08	;needlenose bounce sound effect
!BoingPort =	$1DFC	;port for above sfx

;C2: Bouncy behaviour

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
print "INIT ",pc
	RTL


Run:
	LDA #$00
	%SubOffScreen()
	JSR GFX			;draw sprite

	LDA !14C8,x
	CMP #$08          	 
	BNE Return           
	LDA $9D			;locked sprites?
	BNE Return
	LDA !15D0,x		;yoshi eating?
	BNE Return

	LDA !1588,x		;if on ground, bounce.  else just let gravity do it's stuff.
	AND #$04
	BEQ Falling

	LDA !C2,x
	INC A			;behaviour +1
	STA !C2,x

	CMP #$01
	BEQ Bounce1
	CMP #$02
	BEQ Bounce2
	BRA Falling

Bounce1:
	LDA !7FAB28,x		;extra prop one
	EOR #$FF		;invert
	STA !AA,x		;new Yspd, bouncing up

	LDA #!BoingSFX		;BOING
	STA !BoingPort|!Base2
	BRA Falling		;to falling

Bounce2:
	LDA !7FAB28,x		;extra prop one
	LSR			;not as high, divide by two
	EOR #$FF
	STA !AA,x

	LDA #!BoingSFX		;BOING one more time
	STA !BoingPort|!Base2

	LDA !1686,x
	ORA #$80		;set 'don't interact with objects' in tweaker table
	STA !1686,x		;and roll into falling

Falling:
	JSL $01A7DC|!BankB	;mario interact
	JSL $01802A|!BankB	;speed update

Return:
	RTS        
			
;=====

GFX:
	%GetDrawInfo()
	LDA !157C,x	;direction...
	STA $03

	REP #$20
	LDA $00
	STA $0300|!Base2,y
	SEP #$20

	LDA #!TILEMAP
	STA $0302|!Base2,y

	LDA !15F6,x		;properties
	ORA $64			;level bits
	STA $0303|!Base2,y

	LDY #$02
	LDA #$00		;only 1 tile
	JSL $01B7B3|!BankB	;bookkeeping
	RTS