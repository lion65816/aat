load:
	JSL NoStatus_load
	RTL

main:
	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main

	LDA $71			;\ Dying
	CMP #$09		;/
	BNE .return
	LDA #$06		;\ 
	STA $71			;| Teleport Mario
	STZ $89			;| Change if you want (Because it uses the current screen exit dunno if you want that)
	STZ $88			;/
.return
	RTL
