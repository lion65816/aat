;;;;;;;;
; SMB3 Brick disassembled...
; or at least, emulated ><
; You should not use it, anyway, since custom bounce blocks exist...
; Oh, forgotten: "disassemulated" by SL.
;;;;;;;;;


db $42 ; enable corner and inside offsets
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP MarioCorner : JMP BodyInside : JMP HeadInside

!Bounce = 1	; 0 = no bouncing
		; 1 = bouncing

!AffectedByPOW = 0	; 0 = not affected by blue P-Switch (set block acts like to 130!)
			; 1 = affected by blue P-Switch, acts like brick (set block acts like to 132!)
			; 2 = affected by blue P-Switch, acts like coin (set block acts like to 02B!)

MarioBelow:
	LDA $19
	BNE MarioCape

if !Bounce
	if !AffectedByPOW == 1
		LDA $14AD|!addr
		BNE Return
	else
		if !AffectedByPOW == 2
			LDA $14AD|!addr
			BEQ Return
		endif
	endif
	
	LDA $7D
	BPL Return

	LDA #$0F
	TRB $9A
	TRB $98		; clear low nibble of X and Y position of contact
	
	PHY
	PHB
	LDA #$02
	PHA
	PLB
	
	STZ $04
	STZ $05		; nothing inside the block
	STZ $06
	STZ $07
	JSL $028752|!bank
	
	LDA #$01
	STA $169D|!addr,y
	
	PLB			;restore bank
	PLY
endif

MarioAbove:
MarioSide:
MarioFireBall:
MarioCorner:
HeadInside:
BodyInside:
Return:
	RTL		; return

SpriteV:
	LDA !14C8,x
	CMP #$09	; do nothing if not a carryable sprite (since when you kick a shell upward, it is this status...)
	BNE Return
	LDA !AA,x
	BMI TrySpriteShatter
	
	RTL

SpriteH:
	LDA !14C8,x
	CMP #$0A
	BNE Return
	
TrySpriteShatter:
	%sprite_block_position()

MarioCape:
if !AffectedByPOW == 1
	LDA $14AD|!addr
	BNE Return
else
	if !AffectedByPOW == 2
		LDA $14AD|!addr
		BEQ Return
	endif
endif

	LDA #$0F
	TRB $98
	TRB $9A
	
	LDA $0F
	PHA
	%kill_sprite()
	%shatter_block()
	PLA
	STA $0F

	LDA #$07
	STA $1DFC|!addr
	%give_points()
	RTL

if !AffectedByPOW == 0
	print "A brick block."
else
	if !AffectedByPOW == 1
		print "A brick block that turns into a coin when the blue P-Switch is active."
	else
		print "A coin that turns into a brick block when the blue P-Switch is active."
	endif
endif