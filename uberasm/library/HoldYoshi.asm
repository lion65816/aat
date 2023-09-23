; Filter Yoshi only if the player entered directly from the overworld.
; This allows in-level Yoshis to be taken through pipes.

load:
	LDA $141A|!addr		;\ Skip if not entered from the overworld.
	BNE +				;/ Allows in-level Yoshis to be taken through pipes.
	STZ $187A|!addr		;> Player on Yoshi (within levels) flag. Zero out just in case.
	STZ $0DC1|!addr		;> Reset player on Yoshi (within levels and on the overworld) flag.
+
	RTL
