;Behaves #$025
;A door that uses a specific screen exit.

!screen_num = $0F	;>screen number this block uses.

!small_door = 0		;>0 = allow all forms, 1 = small only.

db $42
JMP Ret : JMP Ret : JMP Ret : JMP Ret : JMP Ret : JMP Ret
JMP Ret : JMP Ret : JMP BodyInside : JMP Ret

BodyInside:
	REP #$20		;\if mario is 4 pixels far to the left or further
	LDA $9A			;|or 3 pixels far to the right or further,
	AND #$FFF0		;|then return (this was used on the origional
	SEC : SBC #$0005	;|smw's door to prevent mario from entering from
	CMP $94			;|the very edge)
	BCS ret_16bit		;|
	CLC : ADC #$0008	;|
	CMP $94			;|
	BCC ret_16bit		;|
	SEP #$20		;/
	LDA $16			;\check if mario enters the door correctly.	
	AND #$08		;|
	BEQ Ret			;|
	LDA $8F			;|
if !small_door > 0		;|
	ORA $19			;|
endif				;|
	BNE Ret			;/

	LDA #$0F		;\play door sound
	STA $1DFC|!addr		;/
if !EXLEVEL
	JSL $03BCDC|!bank
else
	LDA $5B
	AND #$01
	ASL 
	TAX 
	LDA $95,x
	TAX
endif	
WarpToLvl:
	LDA ($19B8+!screen_num)|!addr	;\adjust what screen exit to use for
	STA $19B8|!addr,x		;|teleporting.
	LDA ($19D8+!screen_num)|!addr	;|
	STA $19D8|!addr,x		;/
	LDA #$06 		;\Teleport the player.
	STA $71  		;|
	STZ $88			;|
	STZ $89			;/
Ret:
	RTL
ret_16bit:
	SEP #$20
	RTL
print "A door that uses a specific screen exit."