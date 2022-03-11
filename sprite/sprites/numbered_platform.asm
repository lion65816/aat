;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Super Mario World 2: Yoshi's Island - Numbered Platform
;	by MarioFanGamer
;
; A numbered platform from Yoshi's Island. It's a platform which
; can be jumped of for only a limited amount before exploding.
;
; You can either spawn this from a block (using the included
; custom block) or place them directly as a sprite.
;
; More informations in the readme.
;
; Uses Extra Bit: YES
;    Clear: Big Platform
;    Set: Small Platform
;
; Uses Extra Bytes: YES
;    Number of jumps before getting destroyed.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Hitbox stuff

ClippingYDisplacement:	; Only when pressed
db $04,$02

!ClippingXDisplacement = $03

ClippingWidth:			; Always
db $19,$0A


; Sound effects

!StompSFX = $02
!StompPort = $1DF9|!addr

!ReleaseSFX = $14
!ReleasePort = $1DF9|!addr

!ExplosionSFX = $09
!ExplosionPort = $1DFC|!addr


; Graphics stuff

; 32x32

TileXOffset:
db $00,$10,$00,$10

TileYOffset:
db $00,$00,$10,$10

TileNumber:
db $80,$82,$A0,$A2	; Unpressed
db $84,$86,$A0,$A2	; Pressed

NumberedTile:
db $88,$8A,$8C,$8E

!NumberedXOffset = $08
!NumberedYOffset = $08

; 16x16

SmallTile:
db $C0,$C2,$C4,$C6	; Unpressed
db $C8,$CA,$CC,$CE	; Pressed


; RAM and label defines for readability, don't change!
!PlatformNumber = !C2
!Type = !151C
!IsOnPlatform = !1534
!Map16Low = !157C
!Map16High = !1594
!Standing = !160E

FinishOAMWrite = $01B7B3|!bank
GetMarioClipping = $03B664|!bank
CheckForContact = $03B72B|!bank
DisplayStars = $07FC3B|!bank
StarXSpeed = $07FC33|!addr
StarYSpeed = $07FC37|!addr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Sprite init routine and main wrapper
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	LDA !extra_bits,x
	AND #$04
	ORA #$80
	STA !Type,x
	
	LDA !extra_byte_1,x	;
	STA !C2,x
	
	
RTL

print "MAIN ",pc
	PHB : PHK : PLB
	JSR NumberPlat
	PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SpritePlatform
;
; The main code of a platform which has been placed as a
; sprite directly.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpritePlatform:
	JSR Graphics
	LDA !14C8,x
	EOR #$08
	ORA $9D
	BNE .Return
	; LDA #$00
	%SubOffScreen()
	STZ !IsOnPlatform,x		; Clear this out for every frame.
	LDA !Standing,x			; Go to alternative routine.
	BEQ .No					; U
	LDA !IsOnPlatform,x		; Did Mario jump from the platform?
	PHA						; That is, does Mario still stand on the platform?
	JSR Interaction			; Custom solid sprite interaction.
	PLA						; Did he?
	CMP !IsOnPlatform,x		; 
	BNE .Return				; If it's the same, Mario isn't on the platform anymore.
	DEC !PlatformNumber,x	; One time now.
	BPL .StillActive		;
	STZ !14C8,x				; Killed.
	JSR LetItExplode		; And a visual explosion.
.Return:
RTS

.StillActive
	LDA #!ReleaseSFX		; *plop*
	STA !ReleasePort		;
	STZ !Standing,x			; Release the platform
RTS

.No
	JSR Interaction
	LDA !IsOnPlatform,x		; This is why I love coding so much.
	STA !Standing,x			; Mark the sprite as pressed.
	BEQ .Return				; Don't play a sound if not pressed, though.
	LDA #!StompSFX
	STA !StompPort
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; NumberPlat
;
; The main code of the sprite when spawned from a block
; (excluding the check if it's a sprite).
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NumberPlat:
	STZ !IsOnPlatform,x		; To prevent a bug from running on consecutive platforms.
	LDA !Type,x				; Go to the sprite routine if placed.
	BMI SpritePlatform		;
	LDA !Standing,x			; Disable interaction for one frame.
	BEQ .Okay				; I don't want the platform to explode immedietly.
	INC !Standing,x
.Return:
RTS

.Okay:
	LDA !IsOnPlatform,x		; Did Mario jump from the platform?
	PHA						; That is, does Mario still stand on the platform?
	JSR Interaction			; Custom solid sprite interaction.
	PLA						; Did he?
	CMP !IsOnPlatform,x		; 
	BNE .Return				; If it's the same, Mario isn't on the platform anymore.
	STZ !14C8,x				; We don't need the sprite anymore.
	STZ $1933|!addr			; No layer 2 support yet.
	LDY !PlatformNumber,x	; Can the platform be used again?
	LDA !Type,x				; Small platform requires a different routine.
	AND #$7F				;
	BNE .Small				;
	TYA						; Yes?
	BNE ..NotDestroyed		;
	JSR DestroyPlatform		; No platform anymore!
JMP LetItExplode			;

..NotDestroyed:
	JSR DecrementPlatform	; Else change the tiles to the previous platform.
	LDA #!ReleaseSFX		; *plop*
	STA !ReleasePort		; 
RTS

.Small:
	TYA						; Same as above
	BNE ..NotDestroyed		;
	JSR SetBlockPosition	; Sets the position and gets the tile number.
	REP #$20				;
	LDA #$0025				; Though we want to turn it into air anyway.
	%ChangeMap16()			;
	SEP #$20				;
JMP LetItExplode			; It always ends like this.

.Small_NotDestroyed:		; Hack but sub-sublabels aren't protected.
	JSR SetBlockPosition	; Set the tile position and get the tile number.
	REP #$20				;
	DEC						; Don't care if this crosses boundaries -- 
	%ChangeMap16()			; it should never do this anyway.
	SEP #$20				;
	LDA #!ReleaseSFX		; *plop*
	STA !ReleasePort		; (I swear, this is the last one!)
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Graphics
;
; 'nuff said.
; Except that it's only used for the sprite only platforms.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Graphics:
	LDA !15F6,x				; Properties
	ORA $64					;
	STA $02					;

	LDA !Standing,x			; Activated
	ASL #2					; Though adding more platforms
	STA $04					; does require some tweaking here.

	LDA !Type,x				; Is it a big or small platform?
	CMP #$80				;
	BNE .Small				;
	
	LDY !PlatformNumber,x	; Tile number
	LDA NumberedTile,y		; (Can be easily expanded.)
	STA $03					;

	%GetDrawInfo()

	; Graphics main loop
	LDA #$03				; Four tiles
	STA $0F					;
.Loop:
	LDX $0F					; Load up the current tile.
	LDA $00					; Set the horizontal offset
	CLC : ADC TileXOffset,x	;
	STA $0300|!addr,y		;
	LDA $01					; Set the vertical blah blah blah
	CLC : ADC TileYOffset,x	;
	STA $0301|!addr,y		;
	TXA						; Add in with the offset of the pressed tile.
	CLC : ADC $04			; (We restore X later.)
	TAX						;
	LDA TileNumber,x		;
	STA $0302|!addr,y		;
	LDA $02					; Properties are all the same
	STA $0303|!addr,y		;
	INY #4					; Next object
	DEC $0F					; More tiles?
	BPL .Loop				;

	; Set the number tile separately.
	LDX $15E9|!addr			; \o/
	LDA $00					; Self-explainatory
	CLC : ADC #!NumberedXOffset
	STA $0300|!addr,y		;
	LDA $01					;
	CLC : ADC #!NumberedYOffset
	STA $0301|!addr,y
	LDA $03
	STA $0302|!addr,y
	LDA $02
	STA $0303|!addr,y

	LDY #$02				; 16x16
	LDA #$04				; Five objects
	JSL FinishOAMWrite
RTS

.Small:
	; This one sets the graphics depending on the type.
	AND #$7F				;
	CLC : ADC !PlatformNumber,x
	CLC : ADC $04			;
	TAY						;
	LDA NumberedTile,y		;
	STA $03					; Preserve the tile number (can't use stack).

	%GetDrawInfo()

	; Easy graphics routine.
	LDA !14D4,x				; GetDrawInfo is dumb.
	XBA						;
	LDA !D8,x				; PIXI's GetDrawInfo adds 0x0C to it but this is
	REP #$21				; suboptimal if you want to avoid FinishOAMWrite
	ADC #$0010				; as the tile appears on the top of the screen
	SEC : SBC $1C			; at certain Y positions.
	CMP #$0100				;
	SEP #$20				;
	LDA $00					; X position
	STA $0300|!addr,y		;
	LDA $01					; Y position
	BCC +					; Now you know why I shifted $186C,x to the right.
	LDA #$F0				; It marks that the sprite is offscreen.
+	STA $0301|!addr,y		;
	LDA $03					; Tile number
	STA $0302|!addr,y		;
	LDA $02					; Tile properties
	STA $0303|!addr,y		;

	; Let's set the X high bit manually
	; FinishOAMWrite is too slow anyway
	TYA					;
	LSR #2				; Get the $0460 index.
	TAY					;
	
	LDA !15A0,x			; It's in the offscreen flag anyway.
	ORA #$02			; So why load the 
	STA $0460|!addr,y	;
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Interaction
;
; The top of the sprite needs to be solid and there is no
; fitting vanilla interaction, hence a custom interaction.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Interaction:
	; Set up the interaction boundry manually.
	LDA !Type,x				; Different hitboxes for small and big.
	AND #$7F				;
	LSR #2					;
	TAY						;
	LDA !Standing,x			; Automatically set in the block version.
	BNE .Pressed			;
	LDA !D8,x	; No displacement if unpressed
	BRA .Shared				;
.Pressed:
	LDA !D8,x				;
	CLC : ADC ClippingYDisplacement,y
.Shared:
	STA $05					;
	LDA !14D4,x				;
	ADC #$00				;
	STA $0B					;
	LDA !E4,x
	CLC : ADC #!ClippingXDisplacement
	STA $04					;
	LDA !14E0,x				;
	ADC #$00				;
	STA $0A					;
	LDA ClippingWidth,y		;
	STA $06					;
	LDA #$08				;
	STA $07					;
	PHY						; Preserve Y
	JSL GetMarioClipping
	JSL CheckForContact
	PLY
	BCC .Return
	; Check for Mario's feet.
	LDA $80
	CLC : ADC #$18
	CLC : ADC $1C
	CMP !D8,x
	BPL .Return
	LDA $7D					; Falling?
	BMI .Return				;
	LDA $77					; Or on ground?
	AND #$08				;
	BNE .Return				;
	LDA #$10				; Vertical speed
	STA $7D					;
	LDA #$01				; Set Mario to be on any sprite platform.
	STA $1471|!addr			;
	STA !IsOnPlatform,x		; And set the platform to be pressed.
	; Y Displacement
	LDA #$20
	LDX $187A|!addr			; RIP sprite index
	BEQ .NotYoshi
	LDA #$30
.NotYoshi:
	SEC : SBC ClippingYDisplacement,y
	STA $01
	LDX $15E9|!addr			; Restore srrite index
	LDA !D8,x
	SEC : SBC $01
	STA $96
	LDA !14D4,x
	SBC #$00
	STA $97
	; Potential horizontal movement
	LDY #$00				;
	LDA !1528,x				; Take care of negative values.
	BPL +					;
	DEY						;
+	CLC : ADC $94			;
	STA $94					;
	TYA						; Add in high byte
	ADC $95					;
	STA $95					;
	SEC						; Mark a success interaction
.Return:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SetBlockPosition
;
; Stores the sprite position to $98-$9B and loads the tile
; number into A.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SetBlockPosition:
	LDA !D8,x
	STA $98
	LDA !14D4,x
	STA $99
	LDA !E4,x
	STA $9A
	LDA !14E0,x
	STA $9B

	LDA !Map16High,x
	XBA
	LDA !Map16Low,x
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DecrementPlatform
;
; This one is a pretty complicated way of changing the Map16
; tiles but the idea is that all platforms are located next
; to each other.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DecrementPlatform:
	JSR SetBlockPosition
	LDY #$06
	; Store the Map6 tiles to the stack.
	; It's faster, I guess.
	; I would have to preserve A anyway, so... why not do it now?
	REP #$21
	ADC #$000F
	PHA
	DEC
	PHA
	SEC : SBC #$000F
	PHA
	DEC
	PHA
.Loop:
	PLA
	%ChangeMap16()
	LDA $98
	CLC : ADC YOffset-$0002,y
	STA $98
	LDA $9A
	CLC : ADC XOffset-$0002,y
	STA $9A
	DEY #2
	BPL .Loop
	SEP #$20
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DestroyPlatform
;
; Replaces the platform into air tiles, effectively
; destroying it graphically.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DestroyPlatform:
	JSR SetBlockPosition
	LDY #$06
	REP #$20
.Loop:
	LDA #$0025
	%ChangeMap16()
	LDA $98
	CLC : ADC YOffset-$0002,y
	STA $98
	LDA $9A
	CLC : ADC XOffset-$0002,y
	STA $9A
	DEY #2
	BPL .Loop
	SEP #$20
RTS

TileOffset:
db $0001,$000F,$0001

YOffset:
dw $0000,$0010,$0000

XOffset:
dw $0010,$FFF0,$0010

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; LetItExplode
;
; Creates the contact graphics + four stars in the centre.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LetItExplode:
	LDA #!ExplosionSFX
	STA !ExplosionPort

	LDA !Type,x
	AND #$04
	EOR #$04
	ASL
	STA $00
	STA $01
	LDA #$08
	STA $02
	LDA #$02
	%SpawnSmoke()

	LDA !Type,x
	AND #$7F
	BNE .Small

	STZ !15A0,x	; Not offscreen!
	STZ !15D0,x	;

	LDA #$03
	STA $0F
.Loop:
	LDX $0F
	LDA #$0C
	STA $00
	STA $01
	LDA StarXSpeed,x
	STA $02
	LDA StarYSpeed,x
	STA $03
	LDX $15E9|!addr
	LDA #$10
	%SpawnExtended()
	LDA #$17
	STA $176F|!addr,y
	DEC $0F
	BPL .Loop
RTS

.Small:
	JSL DisplayStars
RTS
