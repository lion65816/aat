
init:
	JSL RequestRetry_init
	JSL BabaBlocks_init
	RTL

main:
	JSL RequestRetry_main
	JSL BabaBlocks_main
	RTL
