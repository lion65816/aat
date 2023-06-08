;Act as $025.

!NSMB_NoOldPowerupExtract	= 0
;^0 = mario's previous powerup gets transferred to the item box
;     when getting a new one
; 1 = only place item box when the player grabs a powerup matching
;     his powerup state (NSMB).

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

	MarioBelow:
	MarioAbove:
	MarioSide:
	TopCorner:
	BodyInside:
	HeadInside:
	WallFeet:
	WallBody:
	
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
	BCC Return
	
	LDA #$09					;\Spawn score sprite
	%SpawnScoreSprite()				;/
	%PositionScoreSprite()				;>Position the score sprite.
	%erase_block()					;>Remove block
	
	if !NSMB_NoOldPowerupExtract == 0
		LDX $19						;>If mario is small, don't place item in item box
		LDA ItemBoxItems,x				;>Place item into box i
		BEQ ConsumePowerupAndAnimation			;>Don't erase the item in item box
		STA $0DC2|!addr					;>fill item box
		LDA #$0B					;\Placed item box SFX
		STA $1DFC|!addr					;/
	else
		LDA $19
		CMP #$01				;\if Mario grabs a different powerup
		BNE ConsumePowerupAndAnimation		;/
		STA $0DC2|!addr
		RTL
	endif
	
	ConsumePowerupAndAnimation:
	LDA $19
	BNE AlreadyBig				;>If mario state is flower, cape..., then don't downgrade his powerup.
	
	LDA #$02				;\mushroom growing animation
	STA $71					;|
	LDA #$2F				;|
	STA $1496|!addr				;|
	STA $9D					;/

	AlreadyBig:
	LDA #$0A				;\SFX
	STA $1DF9|!addr				;/


	SpriteV:
	SpriteH:

	MarioCape:
	MarioFireball:
	Return:
	RTL
	if !NSMB_NoOldPowerupExtract == 0
		ItemBoxItems:
		;Refer to $7E0DC2 on the RAM map.
		;
		;Note: When non-small mario grabs a powerup, his old powerup goes to the item box while transforming to the powerup
		;he just touch.
		;
		;When any powerup above super (fire or cape) grabs a mushroom, the player doesn't do whats above (so no downgrades
		;from fire/cape to super and have cape/fire in item box (the item box normally gets a mushroom in even if there is a
		;better item already in there)).
		;
		;Refer to $01C510 on the ROM map (in smwdisc, it is a label "ItemBoxSprite:").
		;SMW simply calculates by subtracting the sprite number by #$74 to get the item index (#$00 = mushroom, #$01 = flower),
		;then multiples by 4 (two ASL) prepare groups of 4 items per table, then "adds" (done by using ORA $19 to add by values #$00
		;to #$03), then index into Y. This code is located at $01C538 (labeled "TouchedPowerUp") and used by $01C4AC.
		;
		;ItemPowerupIndex = SpriteNumber - #$74
		;PlacedItemBoxItem = (ItemPowerupIndex*4) + CurrentPlayerPowerup
		;
		;In NSMB and later games, this doesn't happen, it only adds (or replaces if his item box already has an
		;item in it) to the item box if the player's powerup matches the item he just picked up; giving an allusion that the item
		;he picked up wasn't eaten but stored.
		
		db $00 ;>unused; when small mario grabs any powerup.
		db $01 ;>When super mario grabs mushroom (in smw, would extract mario's previous powerup and places into item box)
		db $01 ;>When cape mario grabs mushroom 
		db $01 ;>When fire mario grabs mushroom

	endif
print "same as the mushroom sprite."