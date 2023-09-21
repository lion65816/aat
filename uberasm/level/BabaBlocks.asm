load:
	; Filter Yoshi if the player entered directly from the overworld.
	; Used for levels that need to filter an outside Yoshi,
	; but keep in-level Yoshis through pipes.
	LDA $141A|!addr
	BNE +
	STZ $187A|!addr
	STZ $0DC1|!addr
+
	RTL

init:
	JSL RequestRetry_init
	JSL BabaBlocks_init
	RTL

main:
	JSL RequestRetry_main
	JSL BabaBlocks_main
	RTL
