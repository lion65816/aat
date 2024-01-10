main:
	; Disable A button.
	LDA #%00000000 : STA $00
	LDA #%10000000 : STA $01
	JSL DisableButton_main

	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main

    RTL
