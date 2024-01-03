;yellow needlenose by smkdan (optimized by Blind Devil)
;yellow cactus ball that blows up on ground contact

;DOESN'T USE EXTRA BIT

!TILEMAP	= $E2		;needlenose tile

!EXPLODE_SOUND = $1A		;sound played when it hits the floor
!EXPLODEPORT = $1DFC		;port used for above sfx

;1602: Smoking counter

;1570: Last xpos for smoke
;1528: Last ypos for smoke

print "INIT ",pc
	LDA !D8,x		;Initial settings for smoking
	STA !1528,x
	LDA !E4,x
	STA !1570,x
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
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

	LDA !1588,x		;check if on ground?
	AND #$04
	BEQ InAir		;if in air, continue...

;dead, GFX and sound

	LDA !D8,x		;next Ypos
	STA !1528,x
	LDA !E4,x		;next Xpos
	STA !1570,x

	LDA #$18 : STA $02	;long time to show smoke
	JSR SUB_SMOKE		;display smoke GFX
	JSL $07FC3B|!BankB	;stars

	LDA #!EXPLODE_SOUND	;sound byte
	STA !EXPLODEPORT|!Base2

	LDA #$FF		;never come back, set sprite index in level to bogus value
	STA !161A,x

	STZ !14C8,x		;erase sprite
InAir:
	INC !1602,x		;advance smoking counter
	LDA !1602,x
	AND #$07		;every X frames
	BNE NoSmoke		;not zero, no smoke

	LDA #$10 : STA $02	;long time to show smoke
	JSR SUB_SMOKE		;smoke routine modified for this

NoSmoke:
	LDA !1602,x
	AND #$03		;4 frames behind
	BNE NoXYUpdate

	LDA !D8,x		;next Ypos
	STA !1528,x
	LDA !E4,x		;next Xpos
	STA !1570,x
	
NoXYUpdate:
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

SUB_SMOKE:
	STZ $00 : STZ $01
	LDA #$01
	%SpawnSmoke()
	RTS