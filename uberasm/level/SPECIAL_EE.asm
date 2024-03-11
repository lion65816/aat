; Needs to be the same free RAM address as in RequestRetry.asm.
!RetryRequested = $18D8|!addr

init:
	JSL RequestRetry_init
	JSL freescrollbabey_init
	RTL

main:
	; Exit out of SPECIAL rooms with a special button combination (A+X+L+R).
	LDA #%11110000 : STA $00
	JSL RequestRetry_main
	LDA !RetryRequested
	BNE .return

	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main

	; Otherwise, the SPECIAL rooms will reload upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
.return
	RTL
