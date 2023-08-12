; Block specific defines
!SoundEffect = $02			; Set to zero to play no sound effect
!APUPort = $1DFC|!addr		; Refer to the RAM Map or AMK for more information

!Map16 = $56E0				; The Map16 tile the block turns into (top left corner)

!shake_timer = $3E			; How long the ground is shaking

!item_memory_dependent = 0	; Makes the block stay collected
!invisible_block = 0		; Not solid, doesn't detect sprites, can only be hit from below
; 0 for false, 1 for true


; Placed there for technical reasons
incsrc giant_question_block_base.asm


; Spawn specific defines
!Sprite = $78				; sprite number
!IsCustom = CLC	 			; CLC for normal, SEC custom sprite
!State = $08				; $08 for normal, $09 for carryable sprites
!1540_val = $3E				; If you use powerups, this should be $3E
							; Carryable sprites use it as the stun timer

!ExtraByte1 = $00			; First extra byte
!ExtraByte2 = $00			; Second extra byte
!ExtraByte3 = $00			; Third extra byte
!ExtraByte4 = $00			; Fourth extra byte

!XPlacement = $08			; Remember: $01-$7F moves the sprite to the right and $80-$FF to the left.
!YPlacement = $00			; Remember: $01-$7F moves the sprite to the bottom and $80-$FF to the top.


; Code stuff
SpawnThing:
	LDA #!Sprite
	!IsCustom

	%spawn_sprite_block()
	TAX
	if !XPlacement
		LDA #!XPlacement
		STA $00
	else
		STZ $00
	endif
	if !YPlacement
		LDA #!YPlacement
		STA $01
	else
		STZ $01
	endif
	TXA
	%move_spawn_relative()

	LDA #!State
	STA !14C8,x
	LDA #!1540_val
	STA !1540,x
	LDA #$D0
	STA !AA,x
	LDA #$2C
	STA !154C,x

	LDA #!ExtraByte1
	STA !extra_byte_1,x
	LDA #!ExtraByte2
	STA !extra_byte_2,x
	LDA #!ExtraByte3
	STA !extra_byte_3,x
	LDA #!ExtraByte4
	STA !extra_byte_4,x

	LDA !190F,x
	BPL .Return
	LDA #$10
	STA !15AC,x

.Return:
RTS

print "A giant question mark block which spawns sprite $",hex(!Sprite),"."