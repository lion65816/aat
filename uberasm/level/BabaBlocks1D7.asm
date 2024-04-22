load:
	JSL HoldYoshi_load
	LDA #$03			;\ Give Iris Demo's palette.
	STA $1477|!addr		;/ Handled by global_code.asm.
	RTL

init:
	JSL RequestRetry_init
	JSL BabaBlocks_init
	RTL

main:
	LDA $0DB3|!addr
	BEQ +
	LDA #$45					;\ Restore the translevel number
	STA $13BF|!addr				;/ in case it was changed last frame.
	LDA $1F2C|!addr				;\ Display Iris-only message
	BNE +						;| when Iris enters the level
	LDA #$44					;| for the first time.
	STA $13BF|!addr				;| Requires an SRAM flag.
	LDA #$02					;| The message is stored in
	STA $1426|!addr				;| 120-2, so need to briefly
	LDA #$01					;| switch the translevel number.
	STA $1F2C|!addr				;/ It is restored next frame.
+
	LDA #%00110000 : STA $00	;\ Retry if pressing L+R.
	JSL RequestRetry_main		;/
	JSL BabaBlocks_main

	; Increment the event counter only when the
	; Blue Switch is pressed for the first time.
	LDA $13D2|!addr
	BEQ .ret
	LDA $0DC5|!addr
	BNE .ret
	INC $1F2E|!addr
	LDA #$01
	STA $0DC5|!addr
.ret
	RTL
