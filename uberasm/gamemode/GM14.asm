;gamemode 14 (level).
main:
	;You can have codes (including JSL to library codes, just like the one below here) between the main label (above) and the code below here, if you want
	;third-party stuff here.
	JSL retry_in_level_main
	JSL ScreenScrollingPipes_SSPMaincode

	;...or codes here before the RTL.
;	LDA #$7F		;\ Make the player invincible.
;	STA $1497|!addr		;/ (Testing purposes.)

	; Handle Iris palette with ExAnimation custom trigger.
	LDA $0DB3|!addr 
	CMP #$00
	BNE .Iris
	LDA #$00
	STA $7FC0FC
	JML .Return
.Iris
	LDA #$01  ;Bit value
	STA $7FC0FC
.Return
	RTL

nmi:
	JSL retry_nmi_level
	RTL
