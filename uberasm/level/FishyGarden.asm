; Needs to be the same free RAM address as in RequestRetry.asm.
!RetryRequested = $18D8|!addr

!SprSize = $16		;> Number of SA-1 sprite slots ($16 = 22).
!screen_num = $0D

init:
	JSL RequestRetry_init
	JSL FilterFireCape_init
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
	; Exit out of the room with a special button combination (A+X+L+R).
	LDA #%11110000 : STA $00
	JSL RequestRetry_main
	LDA !RetryRequested
	BNE .return

	; Otherwise, the room will reload upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
.return
	RTL
