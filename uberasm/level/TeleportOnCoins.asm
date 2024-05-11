;This will teleport the player when they collect X coins

;how many coins to collect to teleport? (Max = 255, unless !16Bit is enabled)
!Coins = 1

;set this to 1 to expand the max amount of coins required for teleporting from 255 to 65535. Requires one more byte of FreeRAM.
!16Bit = 0

;freeRAM to keep track of the number of coins to collect to teleport (independent of actual coin count)
!CoinCountFreeRAM = $1879|!addr
!CoinCountFreeRAM16 = $1E00|!addr	;only used if !16Bit is enabled

;Set to 0 to teleport to current screen exit (you'll probably need to fill all screens that have coins with exits)
;Set to 1 to teleport to a specific screen exit
!TeleportMethod = 1

;what screen to use for screen exit (!TeleportMethod = 1)
!ScreenDestination = $1F

load:
	STZ $187A|!addr		;> Player on Yoshi (within levels) flag. Zero out just in case.
	STZ $0DC1|!addr		;> Reset player on Yoshi (within levels and on the overworld) flag.
	RTL

init:
	JSL start_select_init
	RTL

main:
	JSL start_select_main

	; Reload the room upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main

LDA $13D4|!addr			;dont work when paused
BNE .Re			;(i think that .Re is quite far when !16Bit = 1

.Continue
LDA $13CC|!addr			;this one decreases during 9D afaik
BEQ .NoCoin			;if collected a coin, increase the counter that'll teleport the player once they collect x coins

if !16Bit
	LDA !CoinCountFreeRAM	;prepare for 16bit check
	STA $00

	LDA !CoinCountFreeRAM16
	STA $01

	REP #$20
	LDA $00
	CMP.w #!Coins
	SEP #$20
	BCS .NoCoin		;if collected enough coins, don't oveflow and maybe teleport

	LDA !CoinCountFreeRAM	;count +1
	CLC : ADC #$01
	STA !CoinCountFreeRAM

	LDA !CoinCountFreeRAM16
	ADC #$00
	STA !CoinCountFreeRAM16
else
	LDA !CoinCountFreeRAM	;dont overflow k
	CMP.b #!Coins
	BCS .NoCoin

	INC !CoinCountFreeRAM	;count +1 but simpler
endif

.NoCoin
LDA $9D				;pause or action freeze - no teleport
BNE .Re				;

if !16Bit
	LDA !CoinCountFreeRAM16	;need high byte check
	XBA			;
	LDA !CoinCountFreeRAM	;
	REP #$20		;
	CMP.w #!Coins		;compare
	SEP #$20		;
	BNE .Re			;sorry link, I CAN'T GIVE CREDIT, come back when you're a little MMM richer!
else
	LDA !CoinCountFreeRAM	;if didn't collect enough coins, don't teleport
	CMP.b #!Coins		;
	BNE .Re			;
endif

if !TeleportMethod == 1
;additional code for specific screen teleport (from Specific screen teleport block & door v1.2 by Alcaro, HammerBrother, Ixtab, MarioE, WhiteYoshiEgg)
;if !EXLEVEL			;is this not a thing? it should be
if (((read1($0FF0B4)-'0')*100)+((read1($0FF0B4+2)-'0')*10)+(read1($0FF0B4+3)-'0')) > 253
	JSL $03BCDC|!bank
else
	LDA $5B
	AND #$01
	ASL 
	TAX 
	LDA $95,x
	TAX
endif

	LDA ($19B8+!ScreenDestination)|!addr	;\adjust what screen exit to use for
	STA $19B8|!addr,x			;|teleporting.
	LDA ($19D8+!ScreenDestination)|!addr	;|
	STA $19D8|!addr,x			;/
endif

LDA #$06		;teleport to current screen exit
STA $71			;
STZ $88			;
STZ $89			;

.Re

LDA #$02			;\Give yoshi wings
STA $1410|!addr		;/
LDA $187A|!addr		;\Check if riding yoshi
BEQ .return			;/
LDA $77             ;\
AND #$04			;|Doesn't work if not in air
BNE .return			;/
LDA #$80			;\
CMP $7D			    ;|
BCC .sweetboy		;|Check if your going down
LDA #$24			;|
CMP $7D			    ;|
BCS .sweetboy		;/
LDA #$24			;\ if so, lower speed
STA $7D			    ;/
.sweetboy:
LDA $16				;\
AND #$80			;|check if B is pressed
BEQ .return			;/
LDA #$BF			;\ If so, fly
STA $7D			    ;/
.return:
RTL