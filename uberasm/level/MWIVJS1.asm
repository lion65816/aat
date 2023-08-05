!ParallaxLayer = 2		; Which layer is affected by the HDMA

!DisableHdmaAtGoal = 0	; HDMA and IRQ don't mix very well

init:
	LDA.b #$0D+((!ParallaxLayer-1)<<1)
	JSL ParallaxToolkit_init

main:
	if !DisableHdmaAtGoal
		LDA $1493|!addr
		BEQ +
		LDA #$20
		TRB $0D9F|!addr
	RTL
	
	+
	endif

	REP #$20
	LDA $14
	AND #$00FF
	ASL
	STA $08
	LDA $1A
	STA $0A
	LDA $1C+((!ParallaxLayer-1)<<2)
	STA $0C

if !sa1
	SEP #$20
	%invoke_sa1(sa1)
RTL

sa1:
endif
	REP #$20
	LDA.w #ScrollVal
	LDX.b #ScrollVal>>16
	JSL ParallaxToolkit_main
RTL

; The values are specified in the readme.
ScrollVal:
db $00 : dw $0050,$00D0
db $00 : dw $0040,$00E0
db $00 : dw $0030,$00F0
db $00 : dw $0020,$0100
db $00 : dw $0010,$010E
db $00 : dw $0008,$015E
db $00 : dw $0010,$0167
db $00 : dw $0028,$0177
db $00 : dw $003A,$0184
db $00 : dw $0050,$FFFF