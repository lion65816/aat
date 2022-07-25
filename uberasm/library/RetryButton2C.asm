; RetryButton.asm
;	Allow the player to restart a level/sublevel at the press of a button.
;	Code copied from teleport_button.asm (part of Teleport Pack by Alcaro and MarioE).

!fixed = 1			; Teleport to a fixed level? 0 = false, 1 = true.
!screen = 0			; Teleport to the screen's exit? 0 = false, 1 = true.

!controller	= $18		; Up, Down, Left, Right, B, X or Y, Start, Select => $16
				; A, X, L, R => $18
!mask		= $10		; Up = $08,	Down = $04,	Left = $02,	Right = $01
				; B = $80,	X or Y = $40,	Select = $20,	Start = $10
				; A = $80,	X = $40,	L = $20,	R = $10

!level = $002C			; Change this if needed.
!secondary = 0			; Secondary exit? 0 = false, 1 = true.
!water = 0			; If secondary exit, water level? 0 = false, 1 = true.

!EXLEVEL = 1			; Define needed for the %teleport GPS macro. Refers to levels with custom horizontal modes.

main:
	LDA !controller
	AND #!mask
	BEQ return

	;;;;; Start copy from teleport_button.asm.
	if !fixed
		REP #$20
		LDA #!level|(((!water<<3)|(1<<2)|(!secondary<<1))<<8)
		;%teleport()

	;;;;; Start copy from %teleport GPS macro.
	PHX
	PHY

	PHA
	STZ $88

	SEP #$30

	if !EXLEVEL
		JSL $03BCDC|!bank
	else
		LDX $95
		PHA
		LDA $5B
		LSR
		PLA
		BCC ?+
		LDX $97
	?+
	endif
	PLA
	STA $19B8|!addr,x
	PLA
	ORA #$04
	STA $19D8|!addr,x

	LDA #$06
	STA $71

	PLY
	PLX
	RTL
	;;;;; End copy from %teleport GPS macro.

	else
		if !screen
			LDA #$06
			STA $71
			STZ $88
			STZ $89
		endif
	endif
	;;;;; End copy from teleport_button.asm.

return:
	RTL
