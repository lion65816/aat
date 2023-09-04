; This code will reload the current room.

init:
	JSL freescrollbabey_init
	RTL

main:
	LDA $010B|!addr		;\
	STA $0C			;|
	LDA $010C|!addr		;| Call subroutine with arguments $0C and $0D.
	ORA #$04		;|
	STA $0D			;|
	JSL LRReset		;/
	RTL
