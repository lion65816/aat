!screen_num = $0D

load:
	JSL MultipersonReset_load	;> Reset switch status to "On".
	RTL

init:
	JSL freescrollbabey_init
	JSL RequestRetry_init

	; If Small Demo, filter to Big Demo.
	LDA $19
	BNE +
	LDA #$01
	STA $19
+
	RTL

main:
	LDA ($19B8+!screen_num)|!addr
	STA $0C
	LDA ($19D8+!screen_num)|!addr
	STA $0D
	JSL MultipersonReset_main

	LDA #%00110000 : STA $00	;\ Retry if pressing L+R.
	JSL RequestRetry_main		;/
	RTL
