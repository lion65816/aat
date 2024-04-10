;gamemode 14 (level).
main:
	;You can have codes (including JSL to library codes, just like the one below here) between the main label (above) and the code below here, if you want
	;third-party stuff here.
	JSL retry_in_level_main
	JSL ScreenScrollingPipes_SSPMaincode

	;...or codes here before the RTL.
;	LDA #$7F			;\ Make the player invincible.
;	STA $1497|!addr		;/ (Testing purposes.)

	; Wiggler Interaction Fix
	LDX #!sprite_slots-1
.loop
	LDY !sprite_misc_154c,x
	LDA !sprite_num,x
	CMP #$86 : BNE +
	LDA !sprite_being_eaten,x
	BEQ +
	LDY #$80
+
	TYA
	STA !sprite_misc_154c,x
	DEX : BPL .loop

	RTL

nmi:
	JSL retry_nmi_level
	RTL
