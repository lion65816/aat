load:
	JSL NoStatus_load
	RTL

init:
	STZ $1B96|!addr		;> Disable side exit.
	RTL
