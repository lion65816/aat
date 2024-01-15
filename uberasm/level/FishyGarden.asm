!SprSize = $16		;> Number of SA-1 sprite slots ($16 = 22).
!screen_num = $0D

main:
	; Change the music as soon as Boss Bass spawns.
	LDX #!SprSize-1
-
	LDA !7FAB9E,x
	CMP #$30
	BNE +
	LDA #$67
	STA $1DFB|!addr
+
	DEX
	BPL -

	; This code will reload the current room upon death.
	LDA ($19B8+!screen_num)|!addr
	STA $0C
	LDA ($19D8+!screen_num)|!addr
	STA $0D
	JSL MultipersonReset_main
	RTL
