!700000 = $41C000
!NumDemos = $0063		;> #$0063 = 99, #$03E7 = 999, #$270F = 9999

init:
	LDA $010A|!addr
	ASL
	CLC
	ADC $010A|!addr
	TAX
	REP #$20
	LDA #!NumDemos
	STA !700000+$07ED,x
	SEP #$20
	RTL
