;Act as $0130.

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

	incsrc "../../FlagMemoryDefines/Defines.asm"

	if !Settings_MBCM16_RequireDPadPress != 0
		MarioBelow:
		LDA $15
		BIT.b #%00001000
		BNE Main
		RTL
	
		MarioAbove:
		TopCorner:
		LDA $15
		BIT.b #%00000100
		BNE Main
		RTL
	
		MarioSide:
		HeadInside:
		%CheckIfPlayerPressAgainstSidesHoriz()
		BCS +
		RTL
		+
	else
		MarioBelow:
		MarioAbove:
		TopCorner:
		MarioSide:
		HeadInside:
	endif

BodyInside:
;WallFeet:	; when using db $37
;WallBody:
Main:
	%GetWhatKeyCounter()					;>Get what counter based on what level.
	BCS Done						;>If not found, skip.
	TAX							;>Transfer key counter index to X.
	PHX							;>Preserve key counter index.
	LDA !Freeram_KeyCounter,x				;\No keys, no pass
	BEQ DonePullX						;/
;Set flags to not respawn.
	REP #$20
	LDA $9A							;\BlockXPos = floor(PixelXPos/16)
	LSR #4							;|
	STA $00							;/
	LDA $98							;\BlockYPos = floor(PixelYPos/16)
	LSR #4							;|
	STA $02							;/
	SEP #$20
	%BlkCoords2C800Index()
	%SearchBlockFlagIndex()
	REP #$20						;\If flag number associated with this block location not found, return.
	CMP #$FFFE						;|
	BEQ DonePullX						;/
	LSR							;>Convert to index number from Index*2.
	SEP #$20
	CLC
	%WriteBlockFlagIndex()
	PLX							;>Reobtain key counter index.
	LDA !Freeram_KeyCounter,x				;\Decrement key counter
	DEC A							;|
	STA !Freeram_KeyCounter,x				;/
;Code here
	if !Settings_MBCM16_LockedGate_16x16_TileToTurnTo == $0025
		%erase_block()						;>Delete block
	else
		REP #$10
		LDX #!Settings_MBCM16_LockedGate_16x16_TileToTurnTo
		%change_map16()
		SEP #$10
	endif
	if !Settings_MBCM16_LockedGate_GenerateSmoke != 0
		%create_smoke()						;>smoke
	endif
	LDY #$00						;\Don't be solid the frame the player
	LDA #$25						;|makes this block disappear.
	STA $1693|!addr						;/
	LDA #!Settings_MBCM16_LockedGate_SoundNum		;\SFX
	STA !Settings_MBCM16_LockedGate_SoundRAM		;/
;Done
	Done:
SpriteV:
SpriteH:

MarioCape:
MarioFireball:
	RTL
	DonePullX:
	SEP #$30
	PLX
	RTL

print "A solid locked gate that opens when the player have a matching key."