;gamemode 14 (level).
main:
	;You can have codes (including JSL to library codes, just like the one below here) between the main label (above) and the code below here, if you want
	;third-party stuff here.
    jsl retry_in_level_main
	JSL ScreenScrollingPipes_SSPMaincode
	;...or codes here before the RTL.
;	LDA #$7F		;\ Make the player invincible.
;	STA $1497|!addr		;/ (Testing purposes.)
	RTL
    
nmi:
    jsl retry_nmi_level
    rtl
