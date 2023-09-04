;==================================================================================================
; Keyhole Block
;
;  Ends the level via keyhole exit if touched while carrying a key, or if touched while riding
;  a Yoshi with a key in its mouth.
;
;	Acts Like: 25
;
;  Author: Final Theory
;  Keyhole ending sequence from Keyhole Sequence Block by Buu and Ersanio
;  Additional help provided by NGB and Jackthespades
;  Updated by Maarfy and Major Flare
;
; v1.3
;==================================================================================================

!forbid_ride_carry	= 0				; Determines whether the block will activate if the player is
									; carrying a key WHILE riding Yoshi via the glitch
									;	0 = allow activation if carrying while riding
									;	1 = forbid

!keyhole_x_disp		= $007C			;   X position within the screen of level end keyhole effect
!keyhole_y_disp		= $00A0			;   Y position within the screen of level end keyhole effect
!keyhole_SFX		= $07			; \ 
!keyhole_BNK		= $1DFB|!addr	; / Sound effect that plays when triggering level end

;==================================================================================================

db $42		; or db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
MarioAbove:
MarioSide:
MarioCorner:
MarioBody:
MarioHead:

	LDA $187A|!addr			; \ 
	BEQ +					; / Skip to carry checks if not riding Yoshi
	LDA $191C|!addr			; \ 
	BNE .EndLevel			; / Activate level end if riding Yoshi with key in mouth

if !forbid_ride_carry
	RTL						;   Return otherwise if set
endif

	+
	LDA $148F|!addr			; \ 
	BEQ .Return				; / Skip sprite state checks if player is not carrying anything

if !sa1
	LDX #$15
else
	LDX #$0B
endif

	-
	LDA !14C8,x				; \ 
	CMP #$0B				; | Skip if sprite is not in "carried" state
	BNE +					; /
	LDA !9E,x				; \ 
	CMP #$80				; | Activate level end if carrying a key
	BEQ .EndLevel			; /

	+
	DEX						; \ 
	BPL -					; / Check next sprite if any are unchecked
	RTL						;   End if all sprites have been checked

	.EndLevel
	REP #$20				;   16-bit A
	LDA $1A					; \ 
	CLC						; |
	ADC #!keyhole_x_disp	; | Set keyhole X position with respect to Layer 1
	STA $1436|!addr			; /
	LDA $1C					; \ 
	CLC						; |
	ADC #!keyhole_y_disp	; | Set keyhole Y position with respect to Layer 1
	STA $1438|!addr			; /
	SEP #$20				;   8-bit A
	LDA #!keyhole_SFX		; \ 
	STA !keyhole_BNK		; / Play sound
	LDA #$30				; \ 
	STA $1434|!addr			; / Trigger keyhole exit

	.Return

SpriteV:
SpriteH:
MarioCape:
MarioFireball:
;WallFeet:
;WallBody:

	RTL						;   Return

	print "Ends the level via keyhole exit if touched while carrying a key, or if touched while riding a Yoshi with a key in its mouth."

