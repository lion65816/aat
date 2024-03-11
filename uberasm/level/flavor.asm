; Needs to be the same free RAM address as in RequestRetry.asm.
!RetryRequested = $18D8|!addr

!screen_num = $0D

init:
	JSL RequestRetry_init
	JSL InitSpriteFacing_init
	RTL

main:
	JSL BG_AutoScroll7B_main

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
