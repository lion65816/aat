;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Pile Driver Micro Goomba, by edit1754, adapted for PIXI by imamelia
;
; This is that jumping brick block from a few levels in SMB3.
;
; Extra bytes: 0
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!ActStatus = !1528		; 0 = waiting, 1 = preparing to jump, 2 = jumping
!PrepTime = !163E		; decremental timer address used for preparing to jump
!TimeUntilJump = $27		; amount to set in timer while brick springs
!JumpSpeed = $AF		; jumping speed, works best with an F at the end
!DisableJump = !1558		; time after landing to disable jumping
!DisabledFor = $30		; amount of frames to disable brick after landing
!JumpMaxDist = $30		; how close the player needs to be to make the brick jump
!Tile1 = $88			; brick tile
!Tile2 = $8A			; Micro-Goomba tile (PSI Ninja edit: use a 16x16 tile instead)
;!Tile2 = $9A			; Micro-Goomba tile
!Pal1 = $01			; palette for the brick
!Pal2 = $05			; palette for the Micro-Goomba

XSpeed:
	db $10,$F0

BlockOffset:
	db $01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$02
	db $02,$02,$02,$02,$02,$02,$02,$04,$04,$04,$04,$04,$04,$04,$04,$05
	db $05,$05,$05,$05,$05,$05,$05,$02

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ",pc
	LDA #$0F				; use the death frame of the Goomba
	STA !C2,x			;
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteMainRt
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Return1:					;
	RTS					;

SpriteMainRt:
	JSR SubGFX			; sprite GFX routine
	LDA !14C8,x			;
	EOR #$08				; return if the sprite status is not 08
	ORA $9D				; or sprites are locked
	BNE Return1			;
	LDA #$00			;
	%SubOffScreen()		; offscreen handling
	LDA !1588,x			;
	AND #$03			; if the sprite is touching the side of an object...
	BEQ .NoChangeDir		;
	LDA !157C,x			;
	EOR #$01				; flip its direction
	STA !157C,x			;
.NoChangeDir				;
	STZ !B6,x			; default X speed = 0
	LDA !ActStatus,x		;
	BEQ $03				; if the mode is 00, no special code will be activated
	PEA.w Continue-1		;
	JSL $0086DF|!BankB	; pointers for the different modes
	
	dw Continue			; 00 - skip code (no return address here)
	dw PrepMode			; 01 - preparation mode
	dw JumpMode			; 02 - jump mode

PrepMode:				;
	LDA !PrepTime,x		;
	BNE NoStartJump		; if it is time to start jumping...
	INC !1528,x			; set the action status to 2
	LDA #!JumpSpeed		;
	STA !AA,x			; set the jump speed
	%SubHorzPos()		;
	TYA					; make the sprite jump toward the player
	STA !157C,x			;
NoStartJump:				;
	RTS					;

JumpMode:				;
	LDY !157C,x			;
	LDA XSpeed,y			; set X speed depending on direction
	STA !B6,x			;
	LDA !1588,x			;
	AND #$04			; if the sprite has landed...
	BEQ .NotLanded		;
	STZ !1528,x			; then reset the action state
	LDA #$09			;
	STA $1DFC|!Base2		; and play a sound effect
	LDA #!DisabledFor		; prevent the sprite from jumping
	STA !DisableJump,x		; for a certain number of frames
.NotLanded				;
	RTS					;
	
Continue:				;
	LDA !1588,x			;
	AND #$04			; if the sprite is not on the ground...
	BEQ NoWaitMode		;
	LDA !DisableJump,x	; or jumping is disabled...
	BNE NoWaitMode		;
	LDA !ActStatus,x		; or the action status is not 00...
	BNE NoWaitMode		; don't execute the following code
DistCheck:				;
	LDA !E4,x			;
	STA $04				; put the two bytes of the sprite X position together
	LDA !14E0,x			; so that they can be loaded as a 16-bit value
	STA $05				;
	%SubHorzPos()		; figure out which side of the sprite the player is on
	PHP					;
	REP #$20				;
	LDA $94				; get the distance between the sprite and the player
	SEC					;
	SBC $04				;
	CPY #$00				; if the player is on the right side of the sprite...
	BEQ $04				; then the subtraction will result in a negative value
	EOR #$FFFF			; and should be inverted
	INC					;
	STA $06				;
	PLP					;
	LDA $06				;
	CMP #!JumpMaxDist	; check if the player is within range
	BCS NoSetPrepMode		; if the low byte is too large
	LDA $07				; or the high byte is nonzero,
	BNE NoSetPrepMode	; then the player is out of range
	INC !1528,x			; set the action state
	LDA #!TimeUntilJump	; set the jump timer
	STA !PrepTime,x		;
NoSetPrepMode:			;
NoWaitMode:				;
	LDA !1588,x			;
	AND #$08			; if the sprite is hitting the ceiling...
	BEQ .NoBounceDown	;
	LDA !AA,x			;
	BPL .NoBounceDown	; and it is moving upward...
	LDA #$FF				;
	SEC					;
	SBC !AA,x			; then make the sprite go back down
	STA !AA,x			;
.NoBounceDown			;
	JSL $01802A|!BankB	; update position based on speed values
	JSL $018032|!BankB		; interact with other sprites
	JSL $01A7DC|!BankB	; interact with the player
	BCC Return			; if there was no contact, just return
	%SubVertPos()			; get the vertical distance between the player and the sprite
	LDA $0E				;
	CMP #$E9			; if there is vertical contact and the player is not above the sprite...
	BPL SpriteWins			; then the sprite damages the player
KillSprite:					;
	INC $1697|!Base2		; increase the number of consecutive enemies stomped
	LDA $1697|!Base2		; if this number is greater than 8...
	CMP #$08			;
	BCC $05				; then just keep it at 8
	LDA #$08			;
	STA $1697|!Base2		;
KillSpriteEntry2:			;
	JSL $02ACE5|!BankB	; give points
	LDA #$02			;
	STA !14C8,x			; sprite status = killed
	LDA #$D0			;
	STA !AA,x			; killed Y speed
	STZ !B6,x			;
	LDA !E4,x			;
	STA $9A				; set up the position for the shatter effect
	LDA !14E0,x			;
	STA $9B				;
	LDA !D8,x			;
	STA $98				;
	LDA !14D4,x			;
	STA $99				;
	PHB				;
	LDA.b #02|(!BankB>>16)		;
	PHA				;
	PLB				;
;	LDA.b !BankB>>16		;
	LDA #$FF
	JSL $028663|!BankB		; display the shattering effect
	PLB					;
	JSL $01AA33|!BankB	; boost the player's speed
Return:					;
	RTS					;
SpriteWins:				;
	LDA !154C,x			; if interaction is disabled...
	ORA !15D0,x			; or the sprite is being eaten...
	ORA $1497|!Base2		; or the player is flashing invincible...
	BNE Return			; then don't damage the player
	LDA $1490|!Base2		; if the player has a star...
	BNE .StarKill			; then the sprite gets defeated anyway
	JSL $00F5B7|!BankB		; player hurt routine
	RTS					;
.StarKill					;
	INC $18D2|!Base2		; increase the number of consecutive enemies star-killed
	LDA $18D2|!Base2		; if this number is greater than 8...
	CMP #$08			;
	BCC $05				; then just keep it at 8
	LDA #$08			;
	STA $18D2|!Base2		;
	BRA KillSpriteEntry2		;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; graphics routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubGFX:
	%GetDrawInfo()
	LDA !PrepTime,x		;
	STA $02				; timer goes into $02 for future reference
	STZ $03				;
	LDA !ActStatus,x		;
	CMP #$01			;
	BNE .NoPrepMode		; if the sprite is in preparation mode...
	PHX					;
	LDX $02				;
	LDA.w BlockOffset,x	; set the offset for the block tile
	STA $03				;
	PLX					;
.NoPrepMode				;
	LDA !ActStatus,x		;
	CMP #$02			; if the sprite is in jumping mode...
	BNE .NoJumpMode		;
	LDA !AA,x			;
	BPL .NoJumpMode		; and it is going up...
	LDA #$02			; set the offset of the block to -2 pixels
	STA $03				;
.NoJumpMode				;
	LDA $00				;
	STA $0300|!Base2,y		; brick tile X position
	;CLC				;\ (PSI Ninja edits)
	;ADC #$04			;/
	STA $0304|!Base2,y		; Micro-Goomba tile X position
	LDA $01				;
	CLC				; subtract 1 pixel to compensate for showing up 1 pixel lower
	SBC $03				;
	STA $0301|!Base2,y		; brick tile Y position
	LDA $01				;
	;CLC				;\ (PSI Ninja edits)
	;ADC #$07			;/
	STA $0305|!Base2,y		; Micro-Goomba tile Y position
	LDA #!Tile1			; set the tile number of the brick tile
	STA $0302|!Base2,y		;
	LDA #!Tile2			; set the tile number of the brick tile
	STA $0306|!Base2,y		;
	LDA #!Pal1			; sprite palette
	ORA $64				; priority bits
	STA $0303|!Base2,y		; set the tile properties
	LDA $14				;
	AND #$08			; every 8 frames, flip the Micro-Goomba tile
	ADC #$79			; if bit 3 of the frame counter was set, the overflow flag will be set here
	LDA #!Pal2			;
	ORA $64				;
	BVS $02				; if bit 3 of the frame counter was clear...
	ORA #$40			; then flip the tile
	STA $0307|!Base2,y		;
	PHY				;
	TYA				;
	LSR #2				; OAM index / 4
	TAY				;
	LDA #$02			;
	STA $0460|!Base2,y		; size of the first tile
	;LDA #$00			;\ (PSI Ninja edits)
	LDA #$02			;/
	STA $0461|!Base2,y		; size of the second tile
	PLY				;
	LDA !14C8,x			;
	CMP #$02			;
	BNE .NoDeathFrame		;
	LDA $0307|!Base2,y		;
	ORA #$80			;
	STA $0307|!Base2,y		;
	LDA #$F0			;
	STA $0301|!Base2,y		;
.NoDeathFrame				;
	LDY #$FF			; Y = FF -> the tile size was already set
	LDA #$01			; A = 01 -> there were 2 tiles
	JSL $01B7B3|!BankB		; complete the writes to OAM
	RTS					;