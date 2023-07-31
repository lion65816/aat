; Note that since global code is a single file, all code below should return with RTS.

load:
	rts
init:
	jsl mario_exgfx_init
	rts
main:
	jsl mario_exgfx_main
	rts
;nmi:
;	rts
