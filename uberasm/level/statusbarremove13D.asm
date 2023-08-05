
init:
	STZ $1B96|!addr
	JSL statusbarremove_init
	RTL
