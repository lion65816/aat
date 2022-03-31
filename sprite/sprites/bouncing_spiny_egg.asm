;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Bouncing Spiny Eggs
;
;		GIEPY version 1.0
;			Bouncing Spiny Eggs will bounce off of the ground and slopes
;			at predetermined angles depending on steepness.
;
;			Bounces off walls and kind of "sticks" to ceilings
;			until their y-speed is positive.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(Small config by Rykon-V73)Edit the GFX here:

!SpinyEggFrame1	=	$84
!SpinyEggFrame2	=	$94

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print	"INIT ", pc		
		RTL

print	"MAIN ", pc           
                    PHB                     	; \
                    PHK                     	;  | main sprite function, just calls local subroutine
                    PLB                     	;  |
                    JSR BouncingSpinyEgg_Start	;  |
                    PLB                     	;  |
                    RTL                     	; /
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Tables

Bounce_YSpeeds:
db	$D8,$D4,$D0,$CC,$C8,$CC,$D0,$D4,$D8

Bounce_XSpeeds:
db	$E8,$EC,$F4,$FC,$00,$04,$0C,$14,$18		; Based on slopes.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		Skip:
		RTS

BouncingSpinyEgg_Start:
		JSR DrawGFX
		
		LDA $9D	; Lock Flag
		BNE Skip
	; [$9D EQ #$00]
		%SubOffScreen() ;SubOffScreenYadda
		BCS Skip

		LDA !14C8,x
		CMP #$08
		BNE Skip

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Behavior code.
;		Relevant Base2esses:
;			$1588,x -- "Sprite blocked status". Makes the sprite interact with floors, wall and ceilings.
;
;			$15B8,x -- Which slope the sprite is on.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		JSL $01803A		; Default Sprite and Mario interactions.
		
		JSL $019138		; Sprite <> Objects Interactions routine.
		

		
		INC !AA,x		; Increment sprite's Y Speed.
		
		LDA $14
		AND #$01
		BEQ +
		INC !AA,x		; Increment sprite's Y Speed again every other frame.
		+
	
		LDA !1588,x
		AND #$04
		BEQ ++
			; [$1588,x & #$04 NE #$00] -- Sprite is being blocked by the ground.
			; Time to bounce!
			
			LDA !15B8,x
			CLC
			ADC #$04
			TAY			; Slope Type + 4 -> Y
			
			CMP #$04
			BEQ +
				; [Y NE #$04 -- Slope is *not* a flat surface]
			LDA Bounce_XSpeeds,y
			STA !B6,x	; Set X speed.
			+
			
			LDA Bounce_YSpeeds,y
			STA !AA,x
			
		++
		
		LDA !1588,x
		AND #$08
		BNE +
			; [$1588,x & #$08 EQ #$00] -- Sprite is *not* being blocked by the ceiling.
			JSL $01801A		; Update Y Position
		
	+

		LDA !1588,x
		AND #$03
		BEQ +
			; [$1588,x % #$03 NE #$00] -- Sprite is being blocked by a wall (either left or right)
		LDA !B6,x
		EOR #$FF
		INC
		STA !B6,x
	+
		JSL $018022		; Update X Position.		

; Graphic complementary - Tile index handler.
		
	LDA !B6,x
	BPL +
	EOR #$FF
	INC
	+
	STA $00			; Scratch RAM = Abs(sprite's X speed)
	
	LDA !AA,x
	BPL +
	EOR #$FF
	INC
	+
	ASL #2			; A = Abs(sprite's Y speed) times 4.

	CLC
	ADC $00

	CLC
	ADC !1528,x		; ""Timer"" for tile changing.
	STA !1528,x
	
	BCC +			
					; If it got past 255...
	LDA !1602,x		; Change tile.
	EOR #$01
	STA !1602,x
	+
	
	RTS
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Graphics Routine
;
;	Relevant Base2esses:
;		$160E,x -- Holds current tile index for sprite to use.
;			The handler for what $1602,x contains is within the behavior code,
;			and not within the drawing routine.		
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XDisp:
db	$00,$08,$00,$08
YDisp:
db	$00,$00,$08,$08

Tile:		; Index for this table is stored to $160E,x during the main code.
db	!SpinyEggFrame1,!SpinyEggFrame2
	
Props:
db	$00,$40,$80,$C0

DrawGFX:
	%GetDrawInfo()

	LDA !15F6,x
	STA $03		; Copy of $15F6,x (sprite YXPPCCCT properties)
	
	LDA !1602,x
	TAX
	LDA Tile,x
	STA $02	
	
		LDX #$04
	--
		DEX
		BMI ++
		
	; X position
		LDA $00
		CLC
		ADC XDisp,x
		STA $0300|!Base2,y

	; Y position
		LDA $01
		CLC
		ADC YDisp,x
		STA $0301|!Base2,y
		
	; Tile
		LDA $02
		STA $0302|!Base2,y

	; Properties
		LDA $03
		ORA Props,x
		ORA $64
		STA $0303|!Base2,y
		
		
		INY #4 ; Increment Y four times.
		BRA --
	++
	
		LDX $15E9|!Base2	; Get Sprite Slot Index back in X.
		LDA #$03			; 4 tiles
		LDY #$00			; 8x8
		JSL $01B7B3			; Finish OAM Write
		
		RTS