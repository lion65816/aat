load:
	JSL statusbarremove_load
	RTL

init:
	STZ $1B96|!addr
	RTL
