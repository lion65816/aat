;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Panser, "Shower Edition" by Schwa (optimized by Blind Devil)
;;
;; This sprite spits multiple fireballs every once in a while.
;;
;; Extra bit: if clear, sprite will be stationary. Else, it'll move towards the player,
;; and will use a different palette.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tilemap:
	db $8C,$80	; open mouth, closed mouth

!WalkPanserProp = $06	; palette/properties for walking Panser (if extra bit is set), YXPPCCCT format.

SpeedX:
	db $06,$FA	; Panser's walking speed

X_SPEED_BALL:
db $F0,$F2,$F6,$FC,$04,$0A,$0E,$10	; possible X speeds for spit fireballs.

!ExtYSpd = $C2				; Y speed for spit fireballs.

!FireSFX = $27		;sound played when Panser spits fireballs.
!FirePort = $1DFC	;port used for above SFX.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "INIT ",pc
        %SubHorzPos()		; Face Mario
        TYA
        STA !157C,x

	LDA #$01
	STA !151C,x
        RTL                 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "MAIN ",pc
        PHB
        PHK
        PLB
	CMP #09
	BCS HandleStunnd
        JSR SpriteMainSub
        PLB
        RTL

HandleStunnd:
	LDY !15EA,x
	PHX
	LDX Tilemap
	LDA $0302|!Base2,y
	CMP #$A8
	BEQ SetTile
	LDX Tilemap+1
SetTile:
	TXA
 	STA $0302|!Base2,y
	PLX
	PLB
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KILLED_X_SPEED:
	db $F0,$10

Return:
	RTS

SpriteMainSub:
	JSR SubGfx
	
        LDA $9D                 ; \ if sprites locked, return
        BNE Return              ; /
	LDA !14C8,x
	CMP #$08
	BNE Return

	DEC !1534,x		;decrement this every frame

+
	LDA !1534,x
	BNE DontSwitch1		; \ If frame number isn't zero, don't set Firing status to Off.
	STZ !C2,x		; / Otherwise set it to Off.

DontSwitch1:
	CMP #$50		; \  If frame number isn't 50...
	BNE DontSwitch2		;  | ...don't set Firing status to On.
	LDA #$01		;  | 
	STA !C2,x		; /  Otherwise set it to On.

DontSwitch2:
	LDA #$00
        %SubOffScreen()		; handle off screen situation
	INC !1570,x

	LDA !15AC,x
	BNE +

        %SubHorzPos()		; Face Mario
        TYA
        STA !157C,x

+
	LDA !7FAB10,x
	AND #$04
	BNE LetItMove		; Increase speed if extra bit is set
	STZ !B6,x
	BRA ApplySpd

LetItMove:
	LDY !157C,x             ; Set x speed based on direction
        LDA SpeedX,y           
        STA !B6,x

ApplySpd:
	JSL $01802A|!BankB     ; Update position based on speed values
	
	LDA !1588,x             ; If sprite is in contact with an object...
        AND #$03                  
        BEQ NoObjContact

	LDA #$08                ; Set turning timer 
	STA !15AC,x
        LDA !157C,x
        EOR #$01
        STA !157C,x

NoObjContact:
	LDA !1588,x             ; if on the ground, reset the turn counter
        AND #$04
        BEQ NotOnGround
	STZ !AA,x
	STZ !151C,x		; Reset turning flag (used if sprite stays on ledges)

	LDA !C2,x		; 
	BEQ NotOnGround		; If so, do nothing.
	JSR SUB_BALL		; Otherwise, generate fireballs.

NotOnGround:
        JSL $018032|!BankB	; Interact with other sprites
	JSL $01A7DC|!BankB	; Check for mario/sprite contact
	RTS                     ; final return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fireball routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_BALL:
		LDA $14		;load effective frame counter
		AND #$07	;check if bits are set
		BNE NoSpawn	;spawn fireballs only every eighth frame

		STZ $00		;no X offset.
		LDA #$04	;load Y offset
		STA $01		;store to scratch RAM.
		LDA #!ExtYSpd	;load Y speed
		STA $03		;store to scratch RAM.

		JSL $01ACF9|!BankB	;RNG
		AND #$07		;clear all bits except these
		TAY			;transfer A to Y
		LDA X_SPEED_BALL,y	;load X speed from table according to index
		STA $02			;store to scratch RAM.

		LDA #$0B		;load extended sprite number to spawn
		%SpawnExtended()	;spawn extended sprite

		CPY #$FF		;compare Y to value
		BEQ NoSpawn		;if equal, no sprite was spawned so don't bother playing SFX.

		LDA #!FireSFX		; \ play sound effect
		STA !FirePort|!Base2	; /

NoSpawn:
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubGfx:
	%GetDrawInfo()

	LDA !157C,x             ; $02 = direction
        STA $02

        LDA !14C8,x		; If killed...
        CMP #$02
	BNE NotKilled

        STZ $03			;    ...set killed frame

        LDA !15F6,x		;    ...flip vertically
        ORA #$80
        STA !15F6,x

	BRA DrawSprite

NotKilled:
	LDA !C2,x		; If firing...
        CMP #$01
	BNE NotFiring
        STZ $03			;    ...set killed frame
	BRA DrawSprite

NotFiring:
        LDA $14                 ; Set walking frame based on frame counter
        LSR #3
        CLC
        ADC $15E9|!Base2
        AND #$01                
        STA $03                 

DrawSprite:
	REP #$20
	LDA $00
        STA $0300|!Base2,y
	SEP #$20

	PHX

	LDA !7FAB10,x
	AND #$04
	BEQ UseNormProp

        LDA !15F6,x             ;Tile properties yxppccct, format
	AND #$F1		;clear palette bits
	ORA #!WalkPanserProp	;set new palette
	BRA +

UseNormProp:
        LDA !15F6,x             ;Tile properties yxppccct, format

+
        LDX $02                 ; If direction == 0...
        BNE NoFlip                
        ORA #$40                ;    ...flip tile
NoFlip:
        ORA $64                 ; Add in tile priority of level
        STA $0303|!Base2,y             

        LDX $03                 ; Store tile
        LDA Tilemap,x
        STA $0302|!Base2,y
        PLX
	
        LDY #$02                ; Set tiles to 16x16
        LDA #$00                ; We drew 1 tile
        JSL $01B7B3|!BankB      
        RTS