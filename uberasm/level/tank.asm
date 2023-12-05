!ParallaxLayer = 2		; Which layer is affected by the HDMA
!DisableHdmaAtGoal = 1	; HDMA and IRQ don't mix very well

load:
	JSL FilterYoshi_load
	RTL

init:
	;JSL FilterFireCape_init
	JSL freescrollbabey_init

	LDA.b #$0D+((!ParallaxLayer-1)<<1)
	JSL ParallaxToolkit_init
	RTL

main:
	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main

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
db $00 : dw $0030,$00DE
db $00 : dw $0010,$00EE
db $00 : dw $0035,$00FE
db $00 : dw $0025,$0107
db $00 : dw $0018,$010D
db $00 : dw $0000,$0123
db $00 : dw $0050,$013E
db $00 : dw $0080,$017F
db $00 : dw $0100,$FFFF
