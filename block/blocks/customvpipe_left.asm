incsrc customvpipe_settings.asm

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody

MarioBelow:
	LDY #$02		;enter a down facing pipe action
	LDA $15			;\
	AND #$08		;/check if pressing up
	BNE CheckPos
	RTL				;return if not

MarioAbove:
	LDY #$03		;enter an up facing pipe action
	LDA $15			;\
	AND #$04		;/check if pressing down
	BEQ Return		;return if not
	
CheckPos:
	LDA $92		;\
	CLC			;|
	SBC #$0A	;|check position relative to pipe
	CMP #$05	;/
	BCS Return	;/return if not good
	
	;get current screen
	if !EXLEVEL	;lm3
		PHY
		JSL $03BCDC|!bank	;get current screen number in x (requires lm3)
		PLY
	else		;no lm3
		LDA $5B		;\
		AND #$01	;/set accumulator if this is a vertical level
		ASL			;shift
		TAX			;get index
		LDA $95,x	;\
		TAX			;/get high byte of x (or y) position (screen number)
	endif
	
	if !Condition
		LDA !Flag		;\
		CMP #!FlagValue	;/compare flag
		BCS SetCondition
	endif
	
	LDA ($19B8+!ScreenExit)|!addr
	STA $19B8|!addr,x
	LDA ($19D8+!ScreenExit)|!addr
	STA $19D8|!addr,x
	
	if !Condition
		BRA Teleport

	SetCondition:
		LDA ($19B8+!ScreenExitCond)|!addr
		STA $19B8|!addr,x
		LDA ($19D8+!ScreenExitCond)|!addr
		STA $19D8|!addr,x
		
	Teleport:
	endif

	LDA #$06		;\
	STA $71			;/teleportation pose
	STA $9D			;freeze game
	LDA #$02		;\
	STA $1419|!addr	;/set yoshi pose
	LDA #$20		;\
	STA $88			;/set pipe transition timer
	STY $89			;set action (go up or down a pipe)
	LDA #$04		;\
	STA $1DF9|!addr	;/play pipe sfx
	
MarioSide:
TopCorner:
BodyInside:
HeadInside:
WallFeet:
WallBody:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
Return:
	RTL

print "The left tile of an exit enabled vertical pipe that uses a specific screen's exit depending on a specified condition."