;Behaves #$25 or #$130.
;This block will teleport the player using a specific screen exit.

!screen_num = $03	;>screen number this block uses.

db $42
JMP main : JMP main : JMP main
JMP return : JMP return : JMP return : JMP return
JMP main : JMP main : JMP main

main:
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
return:
	RTL
print "Teleports the player using a specific screen exit."