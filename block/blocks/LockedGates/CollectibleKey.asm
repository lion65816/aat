;Act as $0025.

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

	incsrc "../../FlagMemoryDefines/Defines.asm"

MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
	if !Settings_MBCM16_KeyHitboxSize != 0
		;MushroomHitbox:
		;.MarioCollision
		JSL $03B664					;>Get player clipping (hitbox/clipping B)
		
		;.MishroomCollision ;>Hitbox A settings
		;;Hitbox notes for mushroom clipping (tested via debugger to find the info):
		;; HitboxXpos = MushroomXPos + $02
		;; HitboxYPos = MushroomYPos + $03
		;; Width = $0C
		;; Height = $0A
		LDA $9A						;\X position
		AND #$F0					;|
		CLC						;|
		ADC #$02					;|
		STA $04						;|
		LDA $9B						;|
		ADC #$00					;|
		STA $0A						;/
		LDA $98						;\Y position
		AND #$F0					;|
		CLC						;|
		ADC #$03					;|
		STA $05						;|
		LDA $99						;|
		ADC #$00					;|
		STA $0B						;/
		LDA #$0C					;\Width
		STA $06						;/
		LDA #$0A					;\Height
		STA $07						;/
		
		;.CheckCollision
		JSL $03B72B					;>Check collision
		BCC Done
	endif
;don't do anything should you have 99 keys.
	%GetWhatKeyCounter()					;>Get what counter based on what level.
	BCS Done						;>Return if level not marked
	TAX							;>Transfer to X.
	LDA !Freeram_KeyCounter,x				;>Key counter
	CMP.b #99						;\If 99+, don't increment.
	BCS Done						;/
;Set flags to not respawn.
	REP #$20
	LDA $9A				;\BlockXPos = floor(PixelXPos/16)
	LSR #4				;|
	STA $00				;/
	LDA $98				;\BlockYPos = floor(PixelYPos/16)
	LSR #4				;|
	STA $02				;/
	SEP #$20
	%BlkCoords2C800Index()
	%SearchBlockFlagIndex()
	REP #$20			;\If flag number associated with this block location not found, return.
	CMP #$FFFE			;|
	BEQ Done			;/
	LSR				;>Convert to index number from Index*2.
	SEP #$20
	CLC
	%WriteBlockFlagIndex()
	%GetWhatKeyCounter()					;>Get what counter based on what level.
	BCS Done						;>Return if level not marked
	TAX							;>Transfer to X.
	LDA !Freeram_KeyCounter,x				;>Key counter
	INC A							;\Increment key counter.
	STA !Freeram_KeyCounter,x				;/
;Code here
	LDA #!Settings_MBCM16_Key_SoundNum			;\SFX
	STA !Settings_MBCM16_Key_SoundRAM			;/
	%erase_block()						;>Key disappears.

	Done:
	SEP #$30

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
	RTL

print "A collectible key. Up to 99 can be carried for each different key."