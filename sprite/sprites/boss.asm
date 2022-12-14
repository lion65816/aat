;=================================================================
; And Another Thing Boss
;=================================================================

;=================================================================

;=================
; Define
;=================

; Sprite specific RAM
	!GFXPointer = !C2				; GFX Pointer. See GFXPointMirror.
	!State = !151C                  ; Sprite Phase flag. $00 - Waiting to Fire, $01 - Firing, $02 - Return to Waiting.
	!LoopCounter = !1528			; Loop Counter. Holds the Loop Counter value to later be used in the GFX routine.
	!DrawGFX = !1534				; Draw GFX call flag. $00 - Don't draw, $01 - Draw.
	!Timer = !154C					; Phase duration timer. Times the frames spent in phase 1 (waiting to fire), phase 2 (firing) and phase 3 (returning to waiting)
	!Direction = !157C				; Direction to fire flag. $00 - Right, $01 - Left.

; Scratch RAM for Draw Routine
	!FramePointer = $02				; Used to help Vertical Flip every other frame.
	!TileAmount = $03				; Used to determine Tile Amount without relying on Loop Counter.
	!XFlipIndex = $04				; Direction Flag Mirror. Used as the Index to tell whether the graphics should be Horizontally Flipped or not.
	!XPosIndex = $05				; Loop Counter Mirror #1. Used as the index for the X Position of the tile in the graphics routine.
	!LoopCounterMirror = $06		; Loop Counter Mirror #2. Used as a Loop Counter for the GFX Routine.
	!GFXPointMirror = $07			; GFX Pointer Mirror. Used as an aid for the tile tables, to draw the correct set of graphics.
	
;=================
; Macros
;=================

macro Hitbox()
endmacro
	
;=================
; Init / Main
;=================

print "INIT ", pc
	STZ !State,x				; Start Phase 1 - Waiting to Fire.
	
	RTL
	
print "MAIN ", pc
	PHB : PHK
	PLB
	JSR Start
	PLB
	RTL
	
;=================
; Sprite Routines
;=================

Return:
	RTS

Start:
	JSR SubGFX                      ; Run GFX Routine.
	
	LDA !14C8,x						; \
	CMP #$08						; | End code if sprite status != alive
	BNE Return						; /
	LDA $9D							; \ Halt code if sprites locked.
	BNE Return						; /
	
	LDA #$00						; \ Draw from range (x) to (y)
	%SubOffScreen()					; /

	LDA !State,x				; \ Jump to phase routine depending on status flag.
	ASL : TAX						; | ASL multiplies value in flag by 2,
	JSR (Status,x)					; / as the labels are two bytes long (words).
	RTS

Status:
	dw Teleport
    dw Dummy
    
;========================
; Wait -> Fire routine
;========================
	
Teleport:
	LDX $15E9|!Base2                ; Reload Sprite Index from the JSR.

    LDA !Flag,x
    BNE +

    JSL !RNG
    CLC
    ADC !MarioXLow
    AND #$07
    STA !AmountToTeleport,x
    
    INC !Flag,x

+   LDA !AmountToTeleport,x
    BEQ .next
    
    LDA !TeleportTimer,x
    BNE .ret
    
    LDA #$30
    STA !TeleportTimer,x

    JSL !RNG
    CLC
    ADC !MarioXLow
    ASL
    TAY
    REP #$20
    LDA NewXPos,y
    SEP #$20
    STA !SpriteXLow,x
    XBA
    STA !SpriteXHigh,x
    
    JSL !RNG
    CLC
    ADC !MarioXLow
    ASL
    TAY
    REP #$20
    LDA NewYPos,y
    SEP #$20
    STA !SpriteYLow,x
    XBA
    STA !SpriteYHigh,x
    BRA .ret

.next:
    INC !State,x
    STZ !Flag,x

.ret:
    RTS
    
NewXPos:
    dw

NewYPos:
    dw
    
Dummy:
	LDX $15E9|!Base2                ; Reload Sprite Index from the JSR.
    RTS
	
;==================
; Hitbox/Clipping routine
;==================

RightHitbox:
	ldx $15E9|!Base2				; Reload Sprite Index from the JSR.
	
	phy : phx 
	txy								; Transfer Sprite Index to Y
	
	lda.w !E4,y
	clc : adc #$03
	sta $04							; Top left corner of hitbox is 3 pixels to the right from the top left.
	
	lda !14E0,y
	adc #$00
	sta $0A
	
	%Hitbox()						; Run Hitbox Macro for the rest of the routine.

	plx : ply						; Reload X and Y.
	rts	
	
LeftHitbox:
	ldx $15E9|!Base2				; Reload Sprite Index from the JSR.
	
	phy : phx 
	txy								; Transfer Sprite Index to Y
	
	lda.w !E4,y
	sec : sbc #$1D
	sta $04							; Top left corner of hitbox is 3 pixels to the left from the top left.
	
	lda !14E0,y
	sbc #$00
	sta $0A
	
	%Hitbox()						; Run Hitbox Macro for the rest of the routine.
	
	plx : ply						; Reload X and Y.
	rts
	
;==================
; Graphics routine
;==================

Tilemap:
	db !BigFireTile3,!BigFireTile2,!BigFireTile1		; Frame #3 - BIGG flame.
	db !MedFireTile3,!MedFireTile2,!MedFireTile1		; Frame #2 - Medium flame.
	db !SmallFireTile2,!SmallFireTile1			; Frame #1 - Small flame.
YDisp:
	db $00,$10
YFlip:
	db $03,$83						; Y flip every other frame
XFlip:
	db $40,$00						; X flip depending on extra bit.

SubGFX:

	lda !DrawGFX,x					; \
	bne LetsDraw					; / Only draw when the sprite needs to.
	rts

LetsDraw:
	%GetDrawInfo()					; Upload OAM Index to Y.
									; Upload Sprite X position relative to screen border to $00.
									; And Sprite Y position relative to screen border to $01.

	lda $14
	lsr
	lsr								; Divide by 4 to slow down animation speed x2.
	and #$01						; Count only 2 frames for the vertical flipping.
	sta !FramePointer				; Create Frame Pointer.
	
	lda !Direction,x
	sta !XFlipIndex					; Mirror direction flag for the Index of the Horizontal Flip property byte.
	
	lda !GFXPointer,x
	sta !GFXPointMirror				; Mirror GFX Pointer for use in the graphics routine.
	
	lda !LoopCounter,x				; \ Mirror Loop Counter for:
	sta !TileAmount					; | Use as Drawn Tile Amount.
	sta !XPosIndex					; | Use as X Offset Index.
	sta !LoopCounterMirror			; / Use as actual Loop Counter.
	
	lda !Direction,x				; \ If firing left,
	beq +							; |
	lda !XPosIndex					; | Load the three latter X Offset values.
	clc : adc #$03					; |
	sta !XPosIndex					; /
	
+	phx
	ldx !LoopCounterMirror			; Start Loop

Loop:
	phx								; Conserve Loop counter.
	ldx !XPosIndex
	lda $00
	clc	: adc XDisp,x
	sta $0300|!Base2,y				; Draw Tile in X Position, offset by index.
	
	lda $01
	sta $0301|!Base2,y				; Draw Tile in Y position.

	ldx !GFXPointMirror
	lda Tilemap,x
	sta $0302|!Base2,y				; Display tile, indexed by graphics pointer.

	ldx !FramePointer
	lda YFlip,x						; Vertical flip depending on frame.
	ldx !XFlipIndex
	ora XFlip,x						; Horizontal flip depending on extra bit.
	ora $64
	sta $0303|!Base2,y				; Add property byte.
	plx								; Reload Loop counter
	
	iny #4							; Draw 16x16 tile.
	
	dec !XPosIndex					; Decrement X Offset Index.
	dec !GFXPointMirror				; Decrement Graphics Pointer.
	dex								; Decrement Loop Counter
	bpl Loop						; Loop two or one more time depending on frame drawn (until X is $FF).
	plx								; Reload Sprite Index.
	
	ldy #$02						; Size: 16x16
	lda !TileAmount					; Amount: 2/3 tiles, depending on frame.
	jsl $01B7B3|!BankB				; Don't draw when off screen.
	
	rts
	