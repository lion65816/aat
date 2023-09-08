init:
	STZ $1B96|!addr			;> Disable the side exit flag that was set in the previous sublevel.
	RTL
