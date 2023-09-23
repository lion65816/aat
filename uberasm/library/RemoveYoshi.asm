; Zero out all player on Yoshi-related flags.

load:
	STZ $187A|!addr		;> Player on Yoshi (within levels) flag.
	STZ $0DC1|!addr		;> Player on Yoshi (within levels and on the overworld) flag.
	STZ $1B9B|!addr		;> Save Yoshi on the overworld during No-Yoshi cutscenes flag.
	RTL
