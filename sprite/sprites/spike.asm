;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spike, by mikeyk (optimized by Blind Devil)
;;
;; A creature from SMB3/SMW2:YI that walks, occasionally stopping and generating a ball
;; to be thrown at Mario.
;;
;; Extra bit: if clear, it'll behave like a stock Spike sprite.
;; If set, it'll have behaviors similar to shelless Koopas depending on its palette, set
;; through the CFG file:
;;
;; > red: stays on ledges.
;; > blue: walks faster, stays on ledges.
;; > yellow: eventually faces Mario and can jump over kicked shells.
;; > any other palette: nothing special (same as if extra bit is clear).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!BallSpriteNum = $24		;change this to the same sprite number you inserted Spike's ball at!

Tiles:
	db $A0,$A2,$A4,$A2		;walking frames
	db $A2,$A6,$A8,$AA,$A0		;spitting/throwing ball

	!BallTile = $88			;tile used for the ball Spike throws
	!BallPalette = $0B		;palette/properties of the ball, YXPPCCCT format.

SpeedX:
	db $08,$F8,$0C,$F4		;speeds for sprite (normal left, normal right, fast left, fast right)

	!Timing1 = $10			;Paused after throwing
	!Timing2 = $1C			;Holding ball above head
	!Timing3 = $27			;Retrieving ball frame 2
	!Timing4 = $2F			;Retrieving ball frame 1
	!TimeToPause = $3B		;Paused before throwing
	!MinTimeToWalk = $A0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "INIT ",pc
	LDA #$01
	STA !151C,x
        %SubHorzPos()
        TYA
        STA !157C,x
	JSR SetWalkTime
        RTL     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "MAIN ",pc
	PHB
        PHK
        PLB
        JSR MainSub
	PLB
        RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Return:
	RTS
MainSub:
	LDA !1656,x		; Can be stomped on
	ORA #$10
	STA !1656,x
	LDA !1662,x		; 1 tile high
	AND #$C0		
	STA !1662,x
	
	JSR SubGfx
	LDA !14C8,x
	CMP #$08
	BNE Return
	LDA $9D
	BNE Return

	LDA #$00
	%SubOffScreen()

	INC !1570,x
	
	LDA !C2,x
	BEQ WalkingState
	
	LDA !1540,x
	CMP #!Timing1
	BNE NoThrow
	JSR GenerateSprite

NoThrow:
	LDA !7FAB10,x
	AND #$04
	BEQ +

	JSR MaybeFaceMario

+
	JSR UpdInteraction

	LDA !1540,x
	BNE Return2
	STA !C2,x
	JSR SetWalkTime
Return2:	
	RTS                     ; Return
	
WalkingState:	
	LDA !1588,x             ; If sprite is in contact with a wall,
        AND #$03                
        BEQ NoWallContact	;   change direction
        JSR ChangeDirection
NoWallContact:
	LDA !7FAB10,x
	AND #$04
	BEQ +

	JSR MaybeStayOnLedges

+
	LDA !1588,x             ; if on the ground, reset the turn counter
        AND #$04
        BEQ NotOnGround
	STZ !AA,x
	STZ !151C,x		; Reset turning flag (used if sprite stays on ledges)

	LDA !7FAB10,x
	AND #$04
	BEQ +

	JSR MaybeFaceMario
	JSR MaybeJumpShells
+
NotOnGround:	
	LDY !157C,x             ; Set x speed based on direction

	LDA !7FAB10,x
	AND #$04
	BEQ NoFastSpeed

	LDA !15F6,x		;load palette/properties from CFG
	AND #$0E		;only keep palette bits
	CMP #$04		;check if yellow
	BEQ Faster		;if yes, move faster.
	CMP #$06		;else check if blue
	BNE NoFastSpeed		;if yes, move faster. else move with normal speed.

Faster:
	INY
	INY
NoFastSpeed:
        LDA SpeedX,y           
        STA !B6,x

	JSR UpdInteraction

	LDA !1588,x
	AND #$04
	BEQ Return1
	LDA !1540,x
	BNE Return1
	INC !C2,x
	STZ !B6,x
	STZ !AA,x
	LDA #!TimeToPause
	STA !1540,x
Return1:	
	RTS                     ; Return

UpdInteraction:
	JSL $01802A|!BankB	; Update position based on speed values
        JSL $018032|!BankB	; Interact with other sprites
	JSL $01A7DC|!BankB	; Interact with Mario
	RTS

MaybeStayOnLedges:
	LDA !15F6,x		;load palette/properties from CFG
	AND #$0E		;only keep palette bits
	CMP #$06		;check if blue
	BEQ Stay		;if yes, will stay on ledges.
	CMP #$08		;else check if red
	BNE NoFlipDirection	;if yes, will stay on ledges. else, will fall from ledges.

Stay:
	LDA !1588,x             ; If the sprite is in the air
	ORA !151C,x             ;   and not already turning
	BNE NoFlipDirection
	JSR FlipDirection	;   flip direction
        LDA #$01                ;   set turning flag
	STA !151C,x    
NoFlipDirection:
	RTS

MaybeFaceMario:
	LDA !15F6,x		;load palette/properties from CFG
	AND #$0E		;only keep palette bits
	CMP #$04		;check if yellow
	BNE Return4		;if not, won't face Mario.

	LDA !1570,x
	AND #$7F
	BNE Return4
	%SubHorzPos()
        TYA
        STA !157C,x
Return4:	
	RTS

MaybeJumpShells:
	LDA !15F6,x		;load palette/properties from CFG
	AND #$0E		;only keep palette bits
	CMP #$04		;check if yellow
	BNE Return0188AB	;if not, won't jump over kicked shells.

	TXA			  ; \ Process every 4 frames 
        EOR $14                   ;  | 
        AND #$03		  ;  | 
        BNE Return0188AB          ; / 
        LDY #!SprSize-3		  ; \ Loop over sprites: 
JumpLoopStart:
	LDA !14C8,y               ;  | 
        CMP #$0A       		  ;  | If sprite status = kicked, try to jump it 
        BEQ HandleJumpOver	  ;  | 
JumpLoopNext:
	DEY                       ;  | 
        BPL JumpLoopStart         ; / 
Return0188AB:
	RTS                       ; Return 

HandleJumpOver:
	LDA !E4,y             ;man
        SEC                       ;why
        SBC #$1A                ;are
        STA $00                   ;there
        LDA !14E0,y             ;fucking
        SBC #$00                ;plain
        STA $08                   ;spaces
        LDA #$44                ;for
        STA $02                   ;absolutely
        LDA !D8,y             ;no
        STA $01                   ;reason?
        LDA !14D4,y             ;well they have a reason now, as I wrote a lot of crap - Blind Devil
        STA $09                   ;and
        LDA #$10                ;it
        STA $03                   ;goes
        JSL $03B69F|!BankB  ;on
        JSL $03B72B|!BankB     ;and on.
        BCC JumpLoopNext          ; If not close to shell, go back to main loop
	LDA !1588,x 		  ; \ If sprite not on ground, go back to main loop 
	AND #$04		  ;  |
        BEQ JumpLoopNext          ; / 
        LDA !157C,y               ; \ If sprite not facing shell, don't jump 
        CMP !157C,x               ;  | 
        BEQ Return0188EB          ; / 
        LDA #$C0                  ; \ Finally set jump speed 
        STA !AA,x                 ; / 
Return0188EB:
	RTS                       ; Return

FlipDirection:
	LDA !B6,x
        EOR #$FF
        INC A
        STA !B6,x
ChangeDirection:	
        LDA !157C,x
        EOR #$01
        STA !157C,x
        RTS

SetWalkTime:
	JSL $01ACF9|!BankB
	AND #$3F
	CLC
	ADC #!MinTimeToWalk
	STA !1540,x
	RTS

GenerateSprite:
	LDA !15A0,x            	;Don't generate if off screen
        ORA !186C,x            
        ORA !15D0,x		;or being eaten
        BNE Return3

	STZ $00			;no X displacement
	LDA #$F2		;load Y displacement
	STA $01			;store to scratch RAM.
	STZ $02 : STZ $03	;no XY speed
	LDA #!BallSpriteNum	;load sprite number to be spawned
	SEC			;set carry - spawn custom sprite
	%SpawnSprite()
	CPY #$FF
	BEQ Return3

	LDA !157C,x
	STA !157C,y

Return3:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw Sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubGfx:
	%GetDrawInfo()

	LDA !157C,x		; $02 = X flip info
	BNE StoreDirection
	LDA #$40
StoreDirection:	
	STA $02

	LDA #$01
	STA $03

	STZ $04

	LDA !14C8,x
	CMP #$08
	BEQ +

	LDA #$80
	STA $04

+
	PHX
	LDA !C2,x
	BEQ WalkingGfx

ThrowingGfx:	
	LDA !1540,x
	LDX #$04
	CMP #!Timing4
	BCS DrawBody
	INX
	CMP #!Timing3
	BCS DrawBody
	INX
	CMP #!Timing2
	BCS DrawBody
	INX
	CMP #!Timing1
	BCS DrawBall
	INX
	BRA DrawBody
	
WalkingGfx:
	LDA !14C8,x
	CMP #$08
	BEQ +

	LDX #$00

+
	LDA $14			; X = Tile index
	LSR #3
	CLC
	ADC $15E9|!Base2
	AND #$03
	TAX

++
	BRA DrawBody

DrawBall:
	PHX
	LDX $15E9|!Base2		
	LDA !1656,x		; Can't be stomped on
	AND #$EF
	STA !1656,x
	LDA !1662,x		; 2 tiles high
	ORA #$37
	STA !1662,x
	PLX

	INC $03

	LDA $00
        STA $0304|!Base2,y

	LDA $01
	SEC
        SBC #$0E
        STA $0305|!Base2,y   	

	LDA #!BallTile
	STA $0306|!Base2,y

	LDA #!BallPalette
        ORA $02
        ORA $64			; Add in tile priority
        STA $0307|!Base2,y             
	
DrawBody:
	REP #$20
        LDA $00               
        STA $0300|!Base2,y
	SEP #$20

	LDA Tiles,x
	STA $0302|!Base2,y
	
        PLX           
        LDA !15F6,x             ; Get palette number
        ORA $02
        ORA $64                 ; Add in tile priority
	ORA $04
        STA $0303|!Base2,y             

        LDY #$02		; 16x16 tile
        LDA $03			; $03 = number of tiles drawn
        JSL $01B7B3|!BankB
NoDraw:	
        RTS