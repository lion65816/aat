;=================================================================
; Up/Down-facing burner from Super Mario Bros. 3.
; by lion
;
; Set Extra Bit to face up.
;
; Special Thanks:
; Anon who did Air Ship and Wrecked Ship in VIP5.
;	- without their ASM I would have been fucked.
;=================================================================

;=================================================================
;(Small config by Rykon-V73)Edit the GFX here:
;=================================================================

!SmallFireTile1 	=	$4C
;!SmallFireTile1 	=	$2C
!SmallFireTile2	=	$2E
!MedFireTile1	=	$26
!MedFireTile2	=	$28
!MedFireTile3	=	$4A
;!MedFireTile3	=	$2A
!BigFireTile3	=	$24
!BigFireTile2	=	$22
!BigFireTile1	=	$20

;=================
; Set these!!!
;=================

	; For a general time conversion formula:
	; 60 frames = ~1s.
	; Convert 60 from decimal to hexadecimal using the calculator in Windows for example...
	; 60 = $3C.

	!TimeToWait = $3C
	; The time spent waiting.
	; By default, it's $3C (60 frames, 1 second).

	!TimeToFire = $5A
	; The time spent firing
	; By default, it's $5A (90 frames, 1.5 seconds.)

	!TimeToReturn = $3C
	; The time spent buffering before returning to the waiting period.
	; Basically Wait 2: Electric Boogaloo.
	; By default, it's $3C (60 frames, 1 second).
	; The total waiting value is (TimeToWait + TimeToReturn),
	; so keep that in mind to properly adjust it!

;=================
; Define
;=================

; Sprite specific RAM
	!GFXPointer = !C2				; GFX Pointer. See GFXPointMirror.
	!StatusFlag = !151C				; Sprite Phase flag. $00 - Waiting to Fire, $01 - Firing, $02 - Return to Waiting.
	!LoopCounter = !1528			; Loop Counter. Holds the Loop Counter value to later be used in the GFX routine.
	!DrawGFX = !1534				; Draw GFX call flag. $00 - Don't draw, $01 - Draw.
	!Timer = !154C					; Phase duration timer. Times the frames spent in phase 1 (waiting to fire), phase 2 (firing) and phase 3 (returning to waiting)
	!Direction = !157C				; Direction to fire flag. $00 - Down, $01 - Up.

; Scratch RAM for Draw Routine
	!FramePointer = $02				; Used to help Vertical Flip every other frame.
	!TileAmount = $03				; Used to determine Tile Amount without relying on Loop Counter.
	!YFlipIndex = $04				; Direction Flag Mirror. Used as the Index to tell whether the graphics should be Vertically Flipped or not.
	!YPosIndex = $05				; Loop Counter Mirror #1. Used as the index for the Y Position of the tile in the graphics routine.
	!LoopCounterMirror = $06		; Loop Counter Mirror #2. Used as a Loop Counter for the GFX Routine.
	!GFXPointMirror = $07			; GFX Pointer Mirror. Used as an aid for the tile tables, to draw the correct set of graphics.
	
;=================
; Macro
;=================

macro Hitbox()
	lda.w !E4,y
	clc : adc #$03
	sta $04							; Top left corner of hitbox is 3 pixels to the right from the top left.
	
	lda !14E0,y
	adc #$00
	sta $0A
	
	lda #$0A						; Hitbox extends right $0A (#10) pixels from the top left corner
	sta $06
endmacro
	
;=================
; Init / Main
;=================

print "INIT ", pc
	%BEC(NoFlip)					; \ If extra bit set, fire to the left.
	inc !Direction,x				; / Same hitbox as when firing to the right!
	
NoFlip:
	lda #!TimeToWait		 		; \ Wait for x Frames
	sta !Timer,x					; / before firing.
	
	stz !StatusFlag,x				; Start Phase 1 - Waiting to Fire.
	
	rtl
	
print "MAIN ", pc
	phb : phk
	plb
	jsr Start
	plb
	rtl
	
;=================
; Sprite Routines
;=================

Return:
	rts

Start:
	jsr SubGFX						; Run GFX Routine.
	
	lda !14C8,x						; \
	cmp #$08						; | End code if sprite status != alive
	bne Return						; /
	lda $9D							; \ Halt code if sprites locked.
	bne Return						; /
	
	lda #$00						; \ Draw from range (x) to (y)
	%SubOffScreen()					; /

	lda !StatusFlag,x				; \ Jump to phase routine depending on status flag.
	asl : tax						; | ASL multiplies value in flag by 2,
	jsr (Status,x)					; / as the labels are two bytes long (words).
	rts

Status:
	dw Waiting						; $00 - "To Fire" waiting graphic load routine.
	dw Firing						; $01 - Firing graphic load routine.
	dw Returning					; $02 - "Post-Fire" waiting graphic load routine, returning back to stage 1.
	
;========================
; Wait -> Fire routine
;========================
	
Waiting:
	ldx $15E9|!Base2				; Reload Sprite Index from the JSR.
	lda !Timer,x
	cmp #$12						; \ If the Wait Timer is at $12 or above,
	bcs DontDraw					; / don't draw anything.
	
	cmp #$09						; \ If the Wait Timer is at $11 to $09,
	bcs WaitFrame1					; / draw the first frame of animation.
	
	cmp #$01						; \ If the Wait Timer is at $08 to $01,
	bcs WaitFrame2					; / draw the second frame of animation.

	lda #$17						; \ If Wait Timer is empty,
	sta $1DFC|!Base2				; / Play Fire Spit sfx.
	
	lda #!TimeToFire
	sta !Timer,x					; Fire for x frames.
	
	lda #$01
	sta !StatusFlag,x				; Start Phase 2 - Firing.
	
	lda #$02						; Draw the third frame of animation.
	bra +

DontDraw:
	stz !DrawGFX,x					; Clear flag that tells it's time to draw GFX.
	rts

WaitFrame1:
	lda #$07						; Point to the first frame.
	sta !GFXPointer,x
	
	lda #$01						; Draw two tiles.
	bra ++
	
WaitFrame2:
	lda #$05						; Point to the second frame.
+	sta !GFXPointer,x

	lda #$02						; Draw three tiles.
++	sta !LoopCounter,x

	lda #$01
	sta !DrawGFX,x					; Set flag that tells it's time to draw GFX.
	rts
	
;========================
; Firing routine
;========================

Firing:
	ldx $15E9|!Base2				; Reload Sprite Index from the JSR.
	lda !Timer,x					; \ If FireTimer at the very end,
	beq Over						; / skip to Over.

	jsl $03B664|!BankB				; \ Get Mario hitbox/clipping values

	lda !Direction,x				; | 
	asl : tax						; | Get custom hitbox values depending on direction.
	jsr (Hitbox,x)					; |
	
	jsl $03B72B|!BankB				; / Check if they're intersecting.
	
	bcc NoContact
	jsl $00F5B7|!BankB				; \ If they are, hurt Mario.

NoContact:
	rts								; / Else, just ignore.

Hitbox:
	dw DownHitbox					; $00 - Hitbox when facing down.
	dw UpHitbox						; $01 - Hitbox when facing up.

Over:
	lda #$02
	sta !StatusFlag,x				; Set to Phase 3 - Returning from fire.
	
	lda #!TimeToReturn
	sta !Timer,x					; Cooldown before waiting to fire for x frames.
	rts

;========================
; Fire -> Wait routine
;========================

Returning:
	ldx $15E9|!Base2				; Reload Sprite Index from the JSR.
	lda !Timer,x
	cmp #!TimeToReturn-8			; \ If Return Timer is at the first eight frames,
	bcs ReturnFrame1				; / Draw second frame of animation.
	
	cmp #!TimeToReturn-16			; \ If Return Timer is at the second eight frames,
	bcs ReturnFrame2				; / Draw first frame of animation.
	
	stz !DrawGFX,x					; If else, clear flag that tells it's time to draw GFX.
	
	stz !StatusFlag,x				; Restart from Phase 1 - Waiting to fire.
	
	lda #!TimeToWait
	sta !Timer,x					; Wait for x frames.
	rts

ReturnFrame2:
	lda #$07						; Point to the first frame.
	sta !GFXPointer,x

	lda #$01						; Draw two tiles.
	bra +
	
ReturnFrame1:
	lda #$05						; Draw the second frame.
	sta !GFXPointer,x
	
	lda #$02						; Draw three tiles.
+	sta !LoopCounter,x

	lda #$01
	sta !DrawGFX,x					; Set flag that tells it's time to draw GFX.
	rts
	
;==================
; Hitbox/Clipping routine
;==================

UpHitbox:
	ldx $15E9|!Base2				; Reload Sprite Index from the JSR.
	
	phy : phx
	txy								; Transfer Sprite Index to Y
	
	%Hitbox()
	
	lda.w !D8,y
	sec : sbc #$1D
	sta $05							; Top left corner of hitbox is 3 pixels down from the top left.
	
	lda !14D4,y
	sbc #$00
	sta $0B
	
	lda #$29						; Hitbox extends downwards $29 (#40) pixels from the top left corner.
	sta $07
	
	plx : ply						; Reload X and Y.
	rts
	
DownHitbox:
	ldx $15E9|!Base2				; Reload Sprite Index from the JSR.

	phy : phx
	txy								; Transfer Sprite Index to Y
	
	%Hitbox()
	
	lda.w !D8,y
	clc : adc #$03
	sta $05							; Top left corner of hitbox is 3 pixels down from the top left.
	
	lda !14D4,y
	adc #$00
	sta $0B
	
	lda #$29						; Hitbox extends downwards $0A (#10) pixels from the top left corner.
	sta $07
	
	plx : ply						; Reload X and Y.
	rts
	
;==================
; Graphics routine
;==================

Tilemap:
	db !BigFireTile3,!BigFireTile2,!BigFireTile1	; Frame #3
	db !MedFireTile3,!MedFireTile2,!MedFireTile1	; Frame #2
	db !SmallFireTile2,!SmallFireTile1		; Frame #1
YDisp:
	db $00,$10,$20				; Facing right.
	db $00,$F0,$E0				; Facing left.
XFlip:
	db $03,$43					; X flip every other frame
YFlip:
	db $80,$00					; Y flip depending on extra bit - to be implemented

SubGFX:
	lda !DrawGFX,x
	bne LetsDraw					; Only draw when flag is set.
	rts

LetsDraw:
	%GetDrawInfo()					; Upload OAM Index to Y.
									; Upload Sprite X position relative to screen border to $00.
									; And Sprite Y position relative to screen border to $01.
	
	lda $14
	lsr
	lsr								; Divide by 4 to slow down animation speed x2.
	and #$01						; Count only 2 frames for the horizontal flipping.
	sta !FramePointer				; Create Frame Pointer.
	
	lda !Direction,x
	sta !YFlipIndex					; Mirror direction flag for the Index of the Vertical Flip property byte.
	
	lda !GFXPointer,x
	sta !GFXPointMirror				; Mirror GFX Pointer for use in the graphics routine.
	
	lda !LoopCounter,x				; \ Loop Loop Counter for:
	sta !TileAmount					; | Use as Drawn Tile Amount.
	sta !YPosIndex					; | Use as Y Offset Index.
	sta !LoopCounterMirror			; / Use as Loop Counter.
	
	lda !Direction,x				; \ If firing left,
	beq +							; |
	lda !YPosIndex					; | Load the three latter Y Offset values.
	clc : adc #$03					; |
	sta !YPosIndex					; /
	
+	phx
	ldx !LoopCounterMirror			; Start Loop

Loop:
	lda $00
	sta $0300|!Base2,y				; Draw Tile in X Position.
	
	phx								; Conserve Loop counter.
	ldx !YPosIndex
	lda $01
	clc	: adc YDisp,x
	sta $0301|!Base2,y				; Draw Tile in Y position, offset by index.

	ldx !GFXPointMirror
	lda Tilemap,x
	sta $0302|!Base2,y				; Display tile, indexed by graphics pointer.

	ldx !FramePointer
	lda XFlip,x						; Horizontal flip depending on frame.
	ldx !YFlipIndex
	ora YFlip,x						; Vertical flip depending on extra bit.
	ora $64
	sta $0303|!Base2,y				; Add property byte.
	plx								; Reload Loop counter
	
	iny #4							; Draw 16x16 tile.
	
	dec !YPosIndex					; Decrement X Offset Index.
	dec !GFXPointMirror				; Decrement Graphics Pointer.
	dex								; Decrement Loop Counter
	bpl Loop						; Loop two or one more time depending on frame drawn.
	plx								; Reload Sprite Index.
	
	ldy #$02						; Size: 16x16
	lda !TileAmount					; Amount: 2/3 tiles.
	jsl $01B7B3|!BankB				; Don't draw when off screen.
	
	rts
	