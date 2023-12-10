;Act as $0130.
;This is the top-left of the 32x32 pixel block gate.

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

	incsrc "../../FlagMemoryDefines/Defines.asm"

	if !Settings_MBCM16_RequireDPadPress != 0
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
		MarioAbove:
		TopCorner:
		MarioSide:
		HeadInside:
	endif

MarioBelow:
BodyInside:
;WallFeet:	; when using db $37
;WallBody:
Main:
	%GetWhatKeyCounter()					;>Get what counter based on what level.
	;BCS Done						;>If not found, skip.
	BCC +
	RTL
	+
	TAX							;>Transfer key counter index to X.
	PHX							;>Preserve key counter index.
	LDA !Freeram_KeyCounter,x				;\No keys, no pass
	;BEQ DonePullX						;/
	BNE +
	JMP DonePullX
	+
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
	LDY #$00						;\Don't be solid the frame the player
	LDA #$25						;|makes this block disappear.
	STA $1693|!addr						;/
	LDA #!Settings_MBCM16_LockedGate_SoundNum		;\SFX
	STA !Settings_MBCM16_LockedGate_SoundRAM		;/
	if !Settings_MBCM16_LockedGate_GenerateSmoke != 0
		.MakeRoomForSmokeSprite
		LDX #$03						;\Since this block will generate 4 smoke sprites, all 4 slots will be used.
		..Loop							;|
		STZ $17C0|!addr,x					;|
		DEX							;|
		BPL ..Loop						;/
	endif
;Change multiple blocks
	REP #$20						;\Preserve collision point position
	LDA $98							;|(in case it messes up other collision points and other things)
	PHA							;|
	LDA $9A							;|
	PHA							;|
	SEP #$20						;/
	
	LDX.b #$06
	
	Loop1:
	PHX
	REP #$30							;\>16-bit AXY
	LDA Map16TurnInto,x						;|
	TAX								;|
	SEP #$20							;|>8-bit A
	%change_map16()							;|
	SEP #$10							;/
	%swap_XY()
	if !Settings_MBCM16_LockedGate_GenerateSmoke != 0
		%create_smoke()						;>smoke
	endif
	PLX
	;Next
	REP #$20			;\Adjust coordinate.
	LDA $9A				;|
	CLC				;|
	ADC Map16DisplaceXCoords-2,x	;|
	STA $9A				;|
	LDA $98				;|
	CLC				;|
	ADC Map16DisplaceYCoords-2,x	;|
	STA $98				;|
	SEP #$20			;/
	DEX #2				;\Loop until all blocks taken care of.
	BPL Loop1			;/
	
	REP #$20						;\Restore collision point position
	PLA							;|
	STA $9A							;|
	PLA							;|
	STA $98							;|
	SEP #$20						;/
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

	Map16TurnInto:
	dw !Settings_MBCM16_LockedGate_32x32_BottomRight
	dw !Settings_MBCM16_LockedGate_32x32_BottomLeft
	dw !Settings_MBCM16_LockedGate_32x32_TopRight
	dw !Settings_MBCM16_LockedGate_32x32_TopLeft
	
	Map16DisplaceXCoords:
	dw $0010	;>Index $02 (BL to BR)
	dw $FFF0	;>Index $04 (TR to BL)
	dw $0010	;>Index $06 (TL to TR)
	
	Map16DisplaceYCoords:
	dw $0000	;>Index $02 (BL to BR)
	dw $0010	;>Index $04 (TR to BL)
	dw $0000	;>Index $06 (TL to TR)

print "A solid 32x32 top-left block locked gate that opens when the player have a matching key."