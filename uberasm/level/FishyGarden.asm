!SprSize = $16		;> Number of SA-1 sprite slots ($16 = 22).

init:
	JSL FilterFireCape_init
	JSL start_select_init
	RTL

main:
	; Change the music as soon as Boss Bass spawns.
	LDX #!SprSize-1
-
	LDA !7FAB9E,x
	CMP #$30
	BNE +
	BRA ++					;> Sprite slot of Boss Bass is in X.
+
	DEX
	BPL -
	BRA .reload				;> Skip if no Boss Bass in custom sprite table.
++
	LDA !sprite_status,x
	CMP #$08
	BNE .reload				;> Skip if Boss Bass isn't spawned.
	LDA #$67				;\ Otherwise, change the music.
	STA $1DFB|!addr			;/

.reload
	JSL start_select_main

	; Reload the room upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
.return
	RTL
