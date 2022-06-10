;Behaves $130

!AllowJumpOnTop		= 0
;^0 = disable, 1 = allow.

!GravFallPatch		= 0
;1 = if you're using GravFall2.asm ONLY.

 !Freeram_JumpHoldEnable	= $79
 ;^Must match with the patch's corresponding freeram.
 ;Not used if previous
 ;define is 0.

!GravAccelPerFrame = $06
;^How much does the player's Y speed being added per frame
;when not holding jump.

!GravAccelPerFrameHold = $03
;^Same as above but holding jump. Not used if
;!GravFallPatch = 0

!MaxSpeedLimitTop	= $10
;^Maximum player X speed for the top block.
;Left speed already calculated, so put $01-$7F only.

!MaxSpeedLimitBottom	= $20
;^Same as above.

!WallSlideSpdY		= $20
;^When touching the side of the block, pressing down
;sets mario's Y speed to this value.

!WallJump		= 1
;^0 = disable, 1 = walljump off side, 

 !WallJumpSpdX		= $20
 ;^X Speed to walljump, negative speed already calculated so put $01-$7F only.

 !WallJumpSpdY		= $C0
 ;^Y speed to walljump, must be $80-$FF, $80 is the fastest/highest.

 !WallJumpSoundNum	= $02
 !WallJumpSoundRAM	= $1DF9

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody
;--------------------------------------------------------------------------------------
MarioAbove:
TopCorner:
	LDA $75
	BNE Done
	if !AllowJumpOnTop == 0
		LDA #$80
		TRB $16
		TRB $18
	endif
	LDA $73
	BNE Crouching
	LDA $7B
	BPL PositiveXSpd

	;NegativeXSpd:
	CMP.b #($100-!MaxSpeedLimitTop)	;\If greater than or equal to, don't set speed
	BCS Done			;/
	LDA.b #($100-!MaxSpeedLimitTop)
	STA $7B
	RTL

	Crouching:
	STZ $7B
	RTL

	PositiveXSpd:
	CMP #!MaxSpeedLimitTop
	BEQ Done			;\if Less than or equal, don't set speed
	BCC Done			;/
	LDA #!MaxSpeedLimitTop
	STA $7B
Done:
	RTL
;--------------------------------------------------------------------------------------
MarioBelow:
	LDA $15			;\Holding down
	AND #%00000100		;/
	ORA $75			;>Or in water
	ORA $1407+!addr		;>Or cape flying
	ORA $13F3+!addr		;>Or balloon
	BNE Done		;>Let player go and don't stick

	JSR FreezeYPos

	LDY #$00				;\Behave $025
	LDA #$25				;|
	STA $1693+!addr			;/
	if !GravFallPatch == 0
		LDX #$00
		LDA $15
		BPL HighGrav		;>If not holding jump
		INX			;>Holding jump

		HighGrav:
		LDA FreezeYSpd,x
		STA $7D
	else
		LDA #$00
		STA !Freeram_JumpHoldEnable
		LDA.b #$100-!GravAccelPerFrame
		STA $7D
	endif
	LDA #$0B				;\UpJump pose
	STA $72					;/
	LDA $15
	AND.b #%00000011
	BEQ NoXSpd
	LDA $7B
	BPL PositiveXSpd1

	;NegativeXSpd1:
	CMP.b #($100-!MaxSpeedLimitBottom)	;\If greater than or equal to, don't set speed
	BCS Done1				;/
	LDA.b #($100-!MaxSpeedLimitBottom)
	STA $7B
	RTL

	PositiveXSpd1:
	CMP #!MaxSpeedLimitBottom
	BEQ Done1			;\if Less than or equal, don't set speed
	BCC Done1			;/
	LDA #!MaxSpeedLimitBottom
	STA $7B
Done1:
	RTL
NoXSpd:
	STZ $7B
	RTL
;--------------------------------------------------------------------------------------
MarioSide:
BodyInside:
HeadInside:
	LDA $75			;>In water
	ORA $1407+!addr		;>Or cape flying
	ORA $13F3+!addr		;>Or balloon
	BNE Done1		;>Return if >= 1 of them is set
	LDA $15			;\If down is pressed, slide down
	AND.b #%00000100	;|
	BNE SlideDownWall	;/
	if !WallJump != 0
		LDA $16		;\Pressing jump
		BMI JumpUp	;/
	endif
	if !GravFallPatch == 0
		LDX #$00
		LDA $15
		BPL HighGrav1		;>If not holding jump
		INX			;>Holding jump

		HighGrav1:
		LDA FreezeYSpd,x
		STA $7D
	else
		LDA #$00
		STA !Freeram_JumpHoldEnable
		LDA.b #$100-!GravAccelPerFrame
		STA $7D
	endif
	RTL
	if !WallJump != 0
		JumpUp:
		LDX #$00
		REP #$20
		LDA $9A			;\Block position
		AND #$FFF0		;/
		CMP $94
		SEP #$20
		BMI WallJumpRight	;>If block is left of mario (or mario is right), jump rightwards (X = #$00)
		INX			;>block is right of mario (or mario is left), jump leftwards (X = #$01)
		
		WallJumpRight:
		LDA WallJumpSpdXTbl,x
		STA $7B
		
		if !GravFallPatch != 0
			LDA #$80			;\Allow higher jump
			STA !Freeram_JumpHoldEnable	;/
		endif
		LDA #!WallJumpSpdY			;\Fling the player up.
		STA $7D					;/
		JSL $01AB99				;>Display contact
		LDA #!WallJumpSoundNum			;\SFX
		STA !WallJumpSoundRAM+!addr		;/
		LDA #$0B				;\Up jump pose
		STA $72					;/
		STZ $140D+!addr				;>Cancel spinjump
		RTL
	endif
	SlideDownWall:
	if !GravFallPatch == 0
		LDX #$00
		LDA $15					;\Holding jump
		BPL HighGrav2				;/
		INX
		
		HighGrav2:
		LDA WallSlideSpeed,x
		STA $7D
	else
		LDA #$00
		STA !Freeram_JumpHoldEnable
		LDA #!WallSlideSpdY-!GravAccelPerFrame
		STA $7D
	endif
;--------------------------------------------------------------------------------------
WallFeet:
WallBody:
	STZ $13E3+!addr

SpriteV:
SpriteH:
MarioCape:
MarioFireball:
	RTL
FreezeYPos:
	PHX
	LDX #$00
	LDA $19
	BEQ SmallHitbox
	LDA $73
	BNE SmallHitbox
	INX #2

	SmallHitbox:

	LDA $187A+!addr		;>Yoshi positioning
	BNE FreezeYPos_yoshi

	REP #$20
	LDA $98					;\Block position, not collision point position
	AND #$FFF0				;/
	CLC
	ADC YPosOffset,x
	STA $96
	SEP #$20
	PLX
	RTS

FreezeYPos_yoshi:	
	SmallHitboxYoshi:
	REP #$20
	LDA $98					;\Block position, not collision point position
	AND #$FFF0				;/
	CLC
	ADC YPosOffsetYoshi,x
	STA $96
	SEP #$20
	PLX
	RTS
YPosOffset:
	dw $FFFF,$0007
YPosOffsetYoshi:
	dw $FFFC,$FFFF
	if !GravFallPatch == 0
		FreezeYSpd:
		db ($00-!GravAccelPerFrame),($00-!GravAccelPerFrameHold)

		WallSlideSpeed:
		db (!WallSlideSpdY-!GravAccelPerFrame),(!WallSlideSpdY-!GravAccelPerFrameHold)
	endif
	if !WallJump != 0
		WallJumpSpdXTbl:
		db !WallJumpSpdX, ($00-!WallJumpSpdX)
	endif