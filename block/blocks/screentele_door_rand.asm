;Behaves #$025
;A door that uses 1 of 4 screens "randomly".
;Note that its not truly "random", It uses a frame counter,
;I don't know how to use the random number generation, feel
;free to update this block if you need to.

!Warp0 = $00		;\screen numbers this block uses.
!Warp1 = $01		;|
!Warp2 = $02		;|
!Warp3 = $03		;|
!Warp4 = $04		;|
!Warp5 = $05		;|
!Warp6 = $06		;|
!Warp7 = $07		;|
!Warp8 = $08		;|
!Warp9 = $09		;|
!WarpA = $0A		;|
!WarpB = $0B		;|
!WarpC = $0C		;|
!WarpD = $0D		;|
!WarpE = $0E		;/

!small_door = 0		;>0 = allow all forms, 1 = small only.

db $42
JMP Ret : JMP Ret : JMP Ret : JMP Ret : JMP Ret : JMP Ret
JMP Ret : JMP Ret : JMP BodyInside : JMP Ret


BodyInside:
	PHY
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
	BEQ PullYret		;|
	LDA $8F			;|
if !small_door > 0		;|
	ORA $19			;|
endif				;|
	BNE PullYret		;/

	LDA #$0F		;\play door sound
	STA $1DFC|!addr		;/

	LDA $14			;\use frame #$00-#$03
	AND #$0E		;/
	TAX			;\use for table
	LDA randomtable,x	;/
	TAY
Tele:
	PHY
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
warp2lvl:
	PLY
	LDA $19B8|!addr,y		;\adjust what screen exit to use for
	STA $19B8|!addr,x		;|teleporting.
	LDA $19D8|!addr,y		;|
	STA $19D8|!addr,x		;/
	LDA #$06 		;\Teleport the player.
	STA $71  		;|
	STZ $88			;|
	STZ $89			;/
PullYret:
	PLY
Ret:
	RTL
ret_16bit:
	SEP #$20
	PLY
	RTL
randomtable:
	db !Warp0, !Warp1, !Warp2, !Warp3, !Warp4, !Warp5, !Warp6, !Warp7, !Warp8, !Warp9, !WarpA, !WarpB, !WarpC, !WarpD, !WarpE
print "A door that uses 1 of 15 screens randomly."