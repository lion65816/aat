;Egg Plant by smkdan (optimized by Blind Devil)
;A plant from SMW2 that shoots out an item or enemy of your choice.

;USES EXTRA BIT
;If set, a custom sprite is generated.  Else, a standard sprite is generated.

;EXTRA PROP 1:
;Sprite number to generate

;EXTRA PROP 2:
;How many of chosen sprite can be on screen before it stops generating.  A sprite is counted even if it wasn't generated.

;Tilemap defines:
!Plant1 =	$62	;plant frame 1
!Plant2 =	$60	;plant frame 2
!Plant3 =	$46	;plant frame 3
!Plant4 =	$48	;plant frame 4
!Plant5 =	$08	;plant frame 5
!Stem1 =	$7D	;left stem portion
!Stem2 =	$6D	;right stem portion

!StemProp = $06		;stem properties, YXPPCCCT format.

!SpitSFX =	$06	;spit sound effect
!SpitPort =	$1DF9	;port used for above sfx

;1570: Frame # for GFX
;C2: action for shooting
;1602: counter for action

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
print "INIT ",pc
	RTL	;also nothing


Run:
	LDA #$00
	%SubOffScreen()
	JSR GFX			;draw sprite

	LDA !14C8,x
	CMP #$08          	 
	BNE Return           
	LDA $9D			;locked sprites?
	BNE Return

	LDA !C2,x		;load decision bit
	BEQ Idle		;doing nothing, keep counting
	CMP #$01
	BEQ Shooting

Idle:
	LDA !1602,x
	INC A
	STA !1602,x
	CMP #$30
	BNE Return_S		;return if not yet 30h

	INC !C2,x		;+1 for behaviour
	STZ !1602,x		;reset counter, to be used in GFX also
	STZ !1570,x		;reset frame counter for inflating GFX

Shooting:
	LDA !1602,x
	INC A
	STA !1602,x
	CMP #$0C		;return if counter not yet 6 x2
	BNE Return_S

	JSR GenerateX		;attempt to generate sprite

	STZ !C2,x		;back to idling
	STZ !1570,x		;reset frame counter for idling
	STZ !1602,x		;reset counter

Return_S:
    	LDA !1588,x
        AND #$04
        BEQ InAir
        LDA #$10                ;falling yspd, if not already falling
        STA !AA,x
     	
InAir:
	JSL $01802A|!BankB	;speed update
	
Return:
	RTS     

GenerateX:
	JSL $02A9E4|!BankB	;grab free sprite slot
	BMI ReturnG		;return if none left before anything else...

	LDA !7FAB10,x
	AND #$04
	BNE GenCust		;custom sprite if extra bit is set

	JSR SetupStd
	RTS			;return std

GenCust:
	JSR CountSpritesCust	;count sprite routine
	BEQ ReturnG		;Z = 1 if it's to return

	STZ $00			;no X offset
	LDA #$EC
	STA $01			;offset Y, a few pixels upwards
	JSL $01ACF9|!BankB	;'random number'
	AND #$8F		;preserve direction bit and low 4 bits
	BPL PositiveRC
	ORA #$70		;set higher bits if negative
PositiveRC:
	STA $02			;set Xspd
	LDA #$B0
	STA $03			;set Yspd fixed
	LDA !7FAB28,x		;get sprite number to spawn from extra prop 1
	SEC			;set carry (sprite is custom)
	%SpawnSprite()

PlaySFX:
	LDA #!SpitSFX		;gulping sound
	STA !SpitPort|!Base2
	RTS			;return
		
ReturnG:
	STZ $00		;no x-offset
	LDA #$EC
	STA $01		;y-offset a few pixels up
	LDA #$14
	STA $02		;smoke timer
	LDA #$01	;smoke type
	%SpawnSmoke()	;spawn smoke
	RTS     

;===

SetupStd:
	JSR CountSpritesStd	;standard count sprite routine
	BEQ ReturnG		;Z = 1 if it's to return

	STZ $00			;no X offset
	LDA #$EC
	STA $01			;offset Y, a few pixels upwards
	JSL $01ACF9|!BankB	;'random number'
	AND #$8F		;preserve direction bit and low 4 bits
	BPL PositiveRC2
	ORA #$70		;set higher bits if negative
PositiveRC2:
	STA $02			;set Xspd
	LDA #$B0
	STA $03			;set Yspd fixed
	LDA !7FAB28,x		;get sprite number to spawn from extra prop 1
	CLC			;clear carry (sprite is normal)
	%SpawnSprite()

	LDA !7FAB28,x		;compare to see if it's a throw block
	CMP #$53
	BNE IsntThrowBlock

	LDA #$09		;status = stationary
	STA !14C8,y		;normal status, run init routine?
	LDA #$FF		;set stun timer
	STA !1540,y

IsntThrowBlock:
	BRA PlaySFX

CountSpritesStd:
	STZ $09			;$09 will be the sprite counter
	LDY #$00

StdLoop:
	LDA !9E,y		;look into sprite type table
	CMP !7FAB28,x		;compare with generated sprite type
	BNE NoIncS		;if not equal, skip this part

	LDA !14C8,y		;load status
	BEQ NoIncS		;if sprite is dead, don't increment

	INC $09			;else increment
	LDA $09			;compare $09 to count
	CMP !7FAB34,x		;if count is reached....
	BCS ReturnStdN		;just return

NoIncS:
	INY			;advance index
	CPY #!SprSize		;if some left to check...
	BNE StdLoop		;loop again

	LDA #$01		;Z = 0
	RTS

ReturnStdN:
	LDA #$00		;Z = 1
	RTS	
		
;=====

CountSpritesCust:
	STZ $09			;$09 will be the sprite counter
	LDY #$00

CustLoop:
	PHX
	TYX			;Y into X
	LDA !7FAB9E,x		;look into sprite type table for custom sprites
	PLX

	CMP !7FAB28,x		;compare with generated sprite type
	BNE NoIncC		;if not equal, skip this part

	TYX			;Y->X, for long indexed
	LDA !7FAB10,x		;see if it's also a custom sprite...
	AND #$08
	BEQ NoIncC		;return if custom sprite flag is clear

	LDA !14C8,y		;load status
	BEQ NoIncC		;if sprite is dead, don't increment

	INC $09			;else increment
	LDA $09			;compare $09 to count

	LDX $15E9|!Base2	;original sprite index
	CMP !7FAB34,x		;if count is reached....
	BCS ReturnCustN		;just return

NoIncC:
	LDX $15E9|!Base2	;restore sprite index

	INY			;advance index
	CPY #!SprSize		;if some left to check...
	BNE CustLoop		;loop again

	LDA #$01		;Z = 0
	RTS

ReturnCustN:
	LDA #$00		;Z = 1
	RTS	

;===

TILEMAP:	db !Plant1,!Stem1,!Stem2		;body, stem, stem
		db !Plant1,!Stem1,!Stem2
		db !Plant2,!Stem1,!Stem2

;shooting frames

		db !Plant3,!Stem1,!Stem2
		db !Plant4,!Stem1,!Stem2
		db !Plant3,!Stem1,!Stem2
		db !Plant3,!Stem1,!Stem2
		db !Plant5,!Stem1,!Stem2		;generating frame
		db !Plant5,!Stem1,!Stem2

XDISP:		db $01,$00,$08
		db $01,$00,$08
		db $00,$00,$08

		db $00,$00,$08
		db $00,$00,$08
		db $00,$00,$08
		db $00,$00,$08
		db $01,$00,$08
		db $01,$00,$08

YDISP:		db $F8,$07,$07		;It's 8px down from it's origin
		db $F9,$07,$07
		db $F9,$07,$07

		db $F8,$07,$07
		db $F8,$07,$07
		db $F8,$07,$07
		db $F8,$07,$07
		db $F7,$07,$07
		db $F7,$07,$07

SIZE:		db $02,$00,$00

GFX:
	%GetDrawInfo()
	LDA !15F6,x	;load properties
	STA $04		;into $03

	LDA !157C,x	;direction...
	STA $03

	STZ $08	;zero, since it will be added

	LDA !C2,x	;action
	BEQ IdleG	;zero = idling

;shooting
	LDA !1602,x	;load counter
	LSR		;every 2nd advance

	CLC
	ADC #$03	;skip past idle frames
	STA !1570,x
	BRA Skip	
	
IdleG:
	LDA $14
	AND #$07	;every 8th frame
	BNE Skip
	LDA $9D		;due to odd way it animates, skip animating if sprites are locked
	BNE Skip
	LDA !1570,x	;grab frame no.
	INC A
	STA !1570,x
	CMP #$03	;3 = overflow
	BNE Skip
	STZ !1570,x
	
Skip:
	LDA !1570,x	;frame #
	ASL		;x2
	CLC
	ADC !1570,x	;x3
	CLC
	ADC $08
	STA $08

	LDX #$00	;loop index

OAM_Loop:
	TYA
	LSR #2
	PHY
	TAY
	LDA SIZE,x
	STA $0460|!Base2,y		;size table
	PLY			;restore

	TXA	
	CLC
	ADC $08
	PHX
	TAX

	LDA $00
	CLC
	ADC XDISP,x
	STA $0300|!Base2,y
	PLX

	TXA	
	CLC
	ADC $08
	PHX
	TAX

	LDA $01
	CLC
	ADC YDISP,x
	STA $0301|!Base2,y

	PLX

	TXA	
	CLC
	ADC $08
	PHX
	TAX
	LDA TILEMAP,x
	STA $0302|!Base2,y
	PLX

	LDA $04
	CPX #$00
	BEQ UsePalDammit
	AND #$01		;page bit only, ignore palette setting
	ORA #!StemProp		;get stem properties
UsePalDammit:
	ORA $64
	STA $0303|!Base2,y

	INY
	INY
	INY
	INY
	INX
	CPX #$03		;3 tiles for flower body and stem
	BNE OAM_Loop

	LDX $15E9|!Base2

	LDY #$FF		;$460 written
	LDA #$02		;3 tiles
	JSL $01B7B3|!BankB
	RTS