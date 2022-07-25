LDA $15		;Check if
AND #$80	;X is presset
BEQ .BounceLow	;If not, go a little up
LDA #$A8	;Make mario
STA $7D		;Goes Up
BRA ?+	;Execute sound+effect
.BounceLow:
	LDA #$D0	;Make mario
	STA $7D		;Goes a little up
?+
LDA #$02	;Load sound
STA $1DF9|!Base2	;Store it
JSL $01AB99|!BankB	;Set effect
RTL