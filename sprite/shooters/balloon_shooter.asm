;rideable baloon shooter by smkdan (optimized by Blind Devil)
;This will spawn a stream of rideable balloons

;CHANGE THIS TO SPRITE NUMBER OF RIDEABLE BALLOON
!SPRITE_NUM = $46

;CHANGE THIS TO FREQUENCY OF GENERATION	
!GEN_INTERVAL = $C0	;rate of generation

;SET TO 01 TO USE RANDOM PALETTES OR 00 TO STICK WITH DEFAULT
!CUSTOM_PAL = $01

;17AB: counter for shooter

;179B: Xpos low
;17A3: Xpos high

;178B: Ypos low
;1793: Ypos high

CP:	db $88,$8C

	print "INIT ",pc
	print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL

Run:
	LDA $17AB|!Base2,x	;load counter
	BNE Return		;return if not yet reached

	JSL $02A9E4|!BankB	;grab free sprite slot
	BMI Return		;return if none lef

	LDA #!GEN_INTERVAL
	STA $17AB|!Base2,x	;restore counter

	LDA #$01
	STA !14C8,y		;normal status, run init routine

	LDA #!SPRITE_NUM	;load sprite number to generate
	PHX
	TYX
	STA !7FAB9E,x		;into sprite type table for custom sprites
	PLX

	LDA $179B|!Base2,x	;load Xlow
	STA !E4,y		;same Xpos
	LDA $17A3|!Base2,x	;Xhigh
	STA !14E0,y

	REP #$20		;16bit math
	LDA $1C			;scroll Y
	CLC
	ADC #$00E0		;add 224
	SEP #$20		;8bit A for stores...

	STA !D8,y		;Ypos low
	XBA
	STA !14D4,y		;Ypos high

	TYX			;new sprite slot into X
	JSL $07F7D2|!BankB	;create sprite
	JSL $0187A7|!BankB	;tweaker tabless

	LDY #!CUSTOM_PAL	;load user supplied custom palette value
        LDA CP,y
        STA !7FAB10,x

Return:
	RTS