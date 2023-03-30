;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tap-Tap, from Yoshi's Island, by Dispari Scuro (optimized by Blind Devil)
;;
;; Place normally to make a walking tap-tap, or with extra bit set to make a jumping tap-tap.
;; Tap-tap can be hit by items and thrown around, but gets back up.
;;
;; Based on the following sprites:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shy Guy, by mikeyk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Yoshi's Island O Spike
;; Programmed by edit1754
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!WalkSound = $1B	;sound to play for sprite walking
		!WalkPort = $1DF9	;port used for above sfx
		!KnockoutSound = $13	;sound to play when hit by something
		!KnockoutBank = $1DF9	;port used for above sfx

!Body =		$E2	;body tile
!Feet1 =	$E4	;feet frame 1
!Feet2 =	$E5	;feet frame 2
!Feet3 =	$F4	;feet frame 3

Stunmap:	db $EC,$CC,$CE,$EE		; facing E, facing SE, facing S (XY flip), facing SW (XY flip)
		db $EC,$CC,$CE,$EE		; facing W (XY flip), facing NW (XY flip), facing N, facing NE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "INIT ",pc
	LDA #$01		
	STA !151C,x

	STZ !1504,x		; Default = walking

	LDA !7FAB10,x			; \ Get Extra Info
	AND #$04			; /
	BNE Scratch_1			; \
	LDA #$00			; | Extra Info is kinda wacky
	BRA Scratch_2			; /	
Scratch_1:
	LDA #$01
Scratch_2:
	STA !1504,x		;DONE!
	
        %SubHorzPos()		; Face Mario
        TYA
        STA !157C,x
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
		LDA !167A,x				; Set to interact with Mario
		AND #$7F
		STA !167A,x

		LDY !15EA,x				; Replace Goomba's tile
		PHX
		LDX Tilemap
		LDA $0302|!Base2,y
		CMP #$A8
		BEQ SetTile
		LDX Tilemap
		
SetTile:
		TXA
 		STA $0302|!Base2,y
		PLX	
		PLB
		RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpeedX:
		db $08,$F8,$0C,$F4	
		
KILLED_X_SPEED:
		db $F0,$10

Return:
	RTS
	
SpriteMainSub:
	LDA !1504,x
	BEQ StartGraphics
	%SubHorzPos()		; \
	TYA			; | Jumping tap-taps always face Mario
        STA !157C,x		; /

StartGraphics:
	JSR SubGfx
	
        LDA $9D                 ; \ if sprites locked, return
        BNE Return              ; /
	LDA !14C8,x
	CMP #$08
	BNE Return

	LDA #$00
        %SubOffScreen()		; handle off screen situation
	INC !1570,x
	
SetXSpeed:
		LDA !C2,x		; \ Don't set speed normally if being thrown
		BEQ ResumeSpeed		; /
		LDA !B6,x		; \
		BEQ MaybeGetUp		; |
		LDA !B6,x		; |
		CMP #$80		; | Continually decrease speed
		BCC GoDown		; |
		INC !B6,x		; | until the sprite is stationary
		BRA UpdatePosition	; |
GoDown:					; |
		DEC !B6,x		; |
		BRA UpdatePosition	; /
MaybeGetUp:
		STZ !B6,x		; \
		LDA !1528,x		; | If sit timer is going...
		BEQ StandUp		; |
		DEC !1528,x		; | decrement it...
		BRA UpdatePosition	; /
StandUp:	
		LDA #$E0		; \ Make tap-top hop
		STA !AA,x		; /
		DEC !C2,x		; No longer stunned
		BRA UpdatePosition

ResumeSpeed:
		LDA !1504,x		; \
		BEQ WalkingType		; |
		STZ !B6,x		; | Jumping Tap-Tap
		LDA !AA,x		; |
		BNE UpdatePosition	; /
		LDA !160E,x
		BEQ MakeJump
		DEC !160E,x
		BRA UpdatePosition
MakeJump:
		LDA #$C0		; \
		STA !AA,x		; | Make the Tap-Tap jump...
		LDA #$20		; |
		STA !160E,x		; | ...and set the pause timer
		BRA UpdatePosition	; /
WalkingType:
		LDY !157C,x		; Set x speed based on direction
		LDA !7FAB28,x
		AND #$01
		BEQ NoFastSpeed		; Increase speed if bit 0 is set
		INY
		INY
		
NoFastSpeed:
        LDA SpeedX,y           
        STA !B6,x
UpdatePosition:
	JSL $01802A|!BankB	; Update position based on speed values
	LDA !1588,x             ; If sprite is in contact with an object...
        AND #$03                  
        BEQ NoObjContact	
        JSR SetSpriteTurning    ;    ...change direction

	LDA !C2,x
	BEQ NoObjContact
	STZ !B6,x
        
NoObjContact:
		JSR MaybeStayOnLedges
		LDA !1588,x             ; if on the ground, reset the turn counter
		AND #$04
		BEQ NotOnGround
		STZ !151C,x			; Reset turning flag (used if sprite stays on ledges)
NotOnGround:
	JSR Knockout
	JSL $01A7DC|!BankB	; Check for mario/sprite contact (carry set = contact)
        BCC Return1             ; return if no contact
	
        %SubVertPos()		; \
        LDA $0E                 ;  | if mario isn't above sprite, and there's vertical contact...
        CMP #$E6                ;  |     ... sprite wins
        BPL SpriteWins          ; /
        LDA $7D                 ; \ if mario speed is upward, return
        BMI Return1             ; /

        LDA !7FAB28,x		; Check property byte to see if sprite can be spin jumped
        AND #$10
        BEQ SpinKillDisabled    
        LDA $140D|!Base2	; Branch if mario is spin jumping
        BNE SpinKill
        
SpinKillDisabled:	
		LDA $187A|!Base2
		BNE RideSprite
		LDA !7FAB28,x
		AND #$20
		BEQ RideSprite
		BIT $16					; Don't pick up sprite if not pressing button
        	BVC RideSprite
		LDA #$0B				; Sprite status = Carried
		STA !14C8,x
		LDA #$FF				; Set time until recovery
		STA !1540,x
RideSprite:
	        RTS                     

SpriteWins:
        LDA $1490|!Base2               ; Branch if Mario has a star
        BNE MarioHasStar        
        JSL $00F5B7|!BankB
        
Return1:
	RTS                    

SpinKill:
	JSR SUB_STOMP_PTS       ; give mario points
	LDA #$F8		; Set Mario Y speed
	STA $7D
        JSL $01AB99|!BankB	; display contact graphic
        LDA #$04                ; \ status = 4 (being killed by spin jump)
        STA !14C8,x             ; /   
        LDA #$1F                ; \ set spin jump animation timer
        STA !1540,x             ; /
        JSL $07FC3B|!BankB
        LDA #$08                ; \ play sound effect
        STA $1DF9|!Base2        ; /
        RTS                     ; return

MarioHasStar:
	%Star()		;call star subroutine
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MaybeStayOnLedges:	
		LDA !7FAB28,x	; Stay on ledges if bit 1 is set
		AND #$02                
		BEQ NoFlipDirection
		LDA !1588,x             ; If the sprite is in the air
		ORA !151C,x             ;   and not already turning
		BNE NoFlipDirection
		JSR SetSpriteTurning 	;   flip direction
        	LDA #$01                ;   set turning flag
		STA !151C,x
		 
NoFlipDirection:
		RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ThrowSpeedX:
		db $D0,$30

Knockout:
		LDY #!SprSize		; load number of times to go through loop
KO_LOOP:	CPY #$00		; \ zero? if so,
		BEQ END_KO_LOOP		; / end loop
		DEY			; decrease # of times left+get index
		LDA !14C8,y		; \  if sprite's status
		CMP #$09		;  | is less than 9 (9,A,B = shell modes)
		BCC KO_LOOP		; /  ignore sprite
		LDA !1686,y		; \  if sprite doesn't
		AND #$08		;  | interact with others
		BNE KO_LOOP		; /  don't continue
		JSL $03B69F|!BankB	; \
		PHX			;  | if sprite is
		TYX			;  | not touching
		JSL $03B6E5|!BankB	;  | this sprite
		PLX			;  |
		JSL $03B72B|!BankB	;  |
		BCC KO_LOOP		; /
		LDA !14C8,y		; \  speed doesn't matter
		CMP #$0B		;  | if mario is holding
		BEQ MOVING		; /  the shell (status=B)
		LDA !AA,y		; \ continue if sprite
		BNE MOVING		; / has Y speed
		LDA !B6,y		; \ continue if sprite
		BNE MOVING		; / has X speed
		BRA KO_LOOP		; no speed / not holding -> don't kill
MOVING:		LDA !1656,y		; \  force shell
		ORA #$80		;  | to disappear
		STA !1656,y		; /  in smoke
		LDA #$02		; \ set shell into
		STA !14C8,y		; / death mode (status=2)
		INC !C2,x		; next sprite mode
		
		LDA !E4,y	; Mario = 94	; \
		SEC				; | Check to see which side of the sprite...
		SBC !E4,x			; |
		STA $0F				; | the tap-tap is on so it knows which...
		LDA !14E0,y			; |
		SBC !14E0,x	; Mario = 95	; | way to be thrown.
		BPL NoIncY			; |
		PHY				; | Turn to face the direction...
		LDY #$01			; |
		BRA ContinueOn			; | they were hit from.
NoIncY:						; |
		PHY				; |
		LDY #$00			; |
ContinueOn:					; |
		TYA				; |
		STA !157C,x			; /

		LDA #$C0		; \ Throw the tap-tap upward
		STA !AA,x		; /
		LDY !157C,x             ; Set x speed based on direction
		LDA ThrowSpeedX,y           
        	STA !B6,x
		PLY

		LDA #!KnockoutSound		; \ Play a sound
		STA !KnockoutBank|!Base2	; /

		LDA #$60		; \ Set timer for how long Tap-tap sits on the ground
		STA !1528,x		; /

NO_INVERT_DIR:	BRA KO_LOOP		; repeat loop
END_KO_LOOP:	RTS

SetSpriteTurning:
	LDA #$08                ; Set turning timer 
	STA !15AC,X   
        LDA !157C,x
        EOR #$01
        STA !157C,x

Return0190B1:	
        RTS
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tilemap:
		db !Body,!Feet1,!Feet2			; Walking 1 (body), Left Foot, Right Foot
		db !Body,!Feet1,!Feet2			; Walking 2 (body), Left Foot, Right Foot
		db !Body,!Feet2,!Feet3			; Walking 3 (body), Left Foot, Right Foot
		db !Body,!Feet3,!Feet3			; Walking 4 (body), Left Foot, Right Foot
		db !Body,!Feet3,!Feet3			; Walking 5 (body), Left Foot, Right Foot
		db !Body,!Feet3,!Feet3			; Walking 6 (body), Left Foot, Right Foot
		db !Body,!Feet2,!Feet3			; Walking 7 (body), Left Foot, Right Foot
		db !Body,!Feet3,!Feet2			; Walking 8 (body), Left Foot, Right Foot

		db !Body,!Feet1,!Feet2
		db !Body,!Feet1,!Feet2
		db !Body,!Feet2,!Feet3
		db !Body,!Feet3,!Feet3
		db !Body,!Feet3,!Feet3
		db !Body,!Feet3,!Feet3
		db !Body,!Feet2,!Feet3
		db !Body,!Feet3,!Feet2			;wish I knew a non-broken way to remove these duplicates

Jumpmap:	db !Body,!Feet1,!Feet1		; Standing (body), left foot, right foot
		db !Body,!Feet1,!Feet1

		db !Body,!Feet2,!Feet2		; Jumping (body), left foot, right foot
		db !Body,!Feet2,!Feet2

Horiz_Disp:
		db $00,$FF,$0D
		db $00,$03,$08
		db $00,$00,$06
		db $00,$07,$FF
		db $00,$FE,$08
		db $00,$FE,$08
		db $00,$FC,$0A
		db $00,$FD,$0E
		
		db $00,$09,$FB
		db $00,$04,$FF
		db $00,$08,$02
		db $00,$01,$08
		db $00,$0A,$00
		db $00,$0A,$00
		db $00,$0C,$FE
		db $00,$0B,$FA

JumpHoriz:	db $00,$00,$08			; Standing (body), left foot, right foot
		db $00,$00,$08

		db $00,$FE,$06			; Jumping (body), left foot, right foot
		db $00,$02,$0A

Verti_Disp:
		db $FD,$0B,$08
		db $FC,$0B,$07
		db $FC,$07,$0A
		db $FC,$0A,$04
		db $FC,$06,$0A
		db $FC,$06,$0A
		db $FD,$04,$0A
		db $FF,$0A,$08
		
		db $FD,$0B,$08
		db $FC,$0B,$07
		db $FC,$07,$0A
		db $FC,$0A,$04
		db $FC,$06,$0A
		db $FC,$06,$0A
		db $FD,$04,$0A
		db $FF,$0A,$08

JumpVerti:	db $FD,$0C,$0C			; Standing (body), left foot, right foot
		db $FD,$0C,$0C

		db $FD,$0C,$0C			; Jumping (body), left foot, right foot
		db $FD,$0C,$0C
		
Tile_Size:
        	db $02,$00,$00			; 00 = 8x8
		db $02,$00,$00			; 02 = 16x16
		db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00

        	db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00
		db $02,$00,$00

JumpTiles:	db $02,$00,$00			; Standing (body), left foot, right foot
		db $02,$00,$00

		db $02,$00,$00			; Jumping (body), left foot, right foot
		db $02,$00,$00
        
Tile_Flip:
		db $00,$00,$00			; 00 = no flip
		db $00,$00,$00			; 40 = horizontal flip
		db $00,$40,$40			; 80 = vertical flip
		db $00,$40,$80			; C0 = horizontal and vertical flip
		db $00,$00,$40
		db $00,$00,$40
		db $00,$00,$40
		db $00,$00,$00
		
		db $40,$40,$40
		db $40,$40,$40
		db $40,$00,$00
		db $40,$00,$C0
		db $40,$40,$00
		db $40,$40,$00
		db $40,$40,$00
		db $40,$40,$40

StunFlip:
		db $00,$00,$C0,$C0
		db $C0,$C0,$00,$00

JumpFlip:	db $00,$00,$00			; Standing (body), left foot, right foot
		db $40,$40,$40

		db $00,$40,$40			; Jumping (body), left foot, right foot
		db $40,$00,$00

SubGfx:
	%GetDrawInfo()
	LDA !1602,x
        STA $03                 ; | $03 = index to frame start (0 or 4)                   
       
NOT_DEAD:
	LDA !C2,x
	BEQ NotStunned
		;=============
		;=============
	LDA !157C,x             ; $02 = direction
        STA $02

        LDA $14                 ; Set animation frame based on frame counter
        LSR #3
        AND #$07		; 8 frames
        STA $03                 

	PHX
	LDA $00                 ; Tile x position = sprite x location ($00)
        STA $0300|!Base2,y             

        LDA $01                 ; Tile y position = sprite y location ($01)
        STA $0301|!Base2,y             

	LDA !1528,x
	CMP #$40
	BCS StillRolling
	LDA !15F6,x             ; Yile properties xyppccct, format
        LDX $02                 ; If direction == 0...
        BNE NoFlipStun                
        ORA #$40                ;    ...flip tile
NoFlipStun:
        ORA $64                 ; Add in tile priority of level
        STA $0303|!Base2,y
	LDX #$00
	BRA FinishDrawingStun

StillRolling:
	LDA !15F6,x             ; get palette info
        PHX
	LDX $03
	ORA StunFlip,x		; flip tile if necessary
        ORA $64			; add in tile priority of level
        STA $0303|!Base2,y	; store tile properties
	PLX

        LDX $03                 ; Store tile
FinishDrawingStun:
        LDA Stunmap,x           
        STA $0302|!Base2,y             
        PLX

        LDY #$02                ; Set tiles to 16x16
        LDA #$00                ; We drew 1 tile
        JSL $01B7B3|!BankB      
        RTS

	;=============
	;============= 

NotStunned:
		LDA $14					; Frame Counter
		LSR #2					; Change every 4 frames
		AND #$07				; 8 walking "frames"
		STA $0F					; Scratch RAM to "multiply by 3"
		ASL A					; x2
		CLC
		ADC $0F
		STA $03
		
		LDA !1504,x				; \ If walking type...
		BNE NoSounds				; / ...do not play sounds
		LDA $14					; \
		AND #$10				; |
		BEQ NormalDirCheck			; | Play walking sound every 16 frames
		LDA #!WalkSound				; |
		STA !WalkPort|!Base2			; /
		BRA NormalDirCheck
        
NoSounds:
	STZ $03			; Correct frame counter for jumping type

	LDA !AA,x		; \
	BEQ NotInAir		; |
	LDA $03			; |
	CLC			; | Correct tile skip when in the air for jumping
	ADC #$06		; |
	STA $03			; /

NotInAir:
	LDA !157C,x		; \ $02 = sprite direction
	STA $02			; /
	BNE WhichLoop		; \
	LDA $03			; |
	CLC			; | Correct tile skip for direction for jumping
	ADC #$03		; |
	STA $03			; /

	BRA WhichLoop

NormalDirCheck:
        LDA !157C,x             ; \ $02 = sprite direction
        STA $02                 ; /
        BNE WhichLoop
        LDA $03
        CLC
        ADC #$18 				; skip some tiles if facing the other way
        STA $03

WhichLoop:
	LDA !1504,x
	BNE LOOP_STARTj

LOOP_START:
	PHX                     ; push sprite index
        LDX #$02                ; loop counter = (number of tiles per frame) - 1

LOOP_START_2:
        PHX						; push current tile number
        
        TXA                     ; \ X = index of frame start + current tile
        CLC                     ;  |
        ADC $03                 ;  |
        TAX                     ; /
        
        PHY                     ; \
        TYA                     ; |
        LSR #2			; |
        TAY                     ; | Set tile to be either 8x8 ($00) or 16x16 ($02)
        LDA Tile_Size,x         ; |
        STA $0460|!Base2,y	; |
        PLY                     ; /

        LDA $00                 ; \ tile x position = sprite x location ($00)
        CLC                     ;  |
        ADC Horiz_Disp,x        ;  |
        STA $0300|!Base2,y	; /
        
        LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
        CLC                     ;  |
        ADC Verti_Disp,x        ;  |
        STA $0301|!Base2,y	; /

        LDA Tilemap,x           ; \ store tile
        STA $0302|!Base2,y	; /

	PHX			;preserve tile index
        LDX $15E9|!Base2
        LDA !15F6,x             ; get palette info
        PLX			; restore tilemap index yay
        ORA Tile_Flip,x		; flip tile if necessary
        ORA $64                 ; add in tile priority of level
        STA $0303|!Base2,y	; store tile properties
      
	PLX                     ; \ pull, X = current tile of the frame we're drawing
        INY                     ;  | increase index to sprite tile map ($300)...
        INY                     ;  |    ...we wrote 1 16x16 tile...
        INY                     ;  |    ...sprite OAM is 8x8...
        INY                     ;  |    ...so increment 4 times
        DEX                     ;  | go to next tile of frame and loop
        BPL LOOP_START_2        ; /

        PLX                     ; pull, X = sprite index
        LDY #$FF                ; \ We've already set 460, so use FF!
        LDA #$02                ; | A = number of tiles drawn - 1
        JSL $01B7B3             ; / don't draw if offscreen
        RTS                     ; return              

LOOP_STARTj:
	PHX                     ; push sprite index
        LDX #$02                ; loop counter = (number of tiles per frame) - 1

LOOP_START_2j:
        PHX						; push current tile number
        
        TXA                     ; \ X = index of frame start + current tile
        CLC                     ;  |
        ADC $03                 ;  |
        TAX                     ; /
        
        PHY                     ; \
        TYA                     ; |
        LSR #2                  ; |
        TAY                     ; | Set tile to be either 8x8 ($00) or 16x16 ($02)
        LDA Tile_Size,x         ; |
        STA $0460|!Base2,y	; |
        PLY                     ; /

	LDA $00			; \
	CLC			; | Horizontal offset
	ADC JumpHoriz,x		; |
	STA $0300|!Base2,y	; /

	LDA $01			; \
	CLC			; | Vertical offset
	ADC JumpVerti,x		; |
	STA $0301|!Base2,y	; /

	LDA Jumpmap,x
	STA $0302|!Base2,y

ReturnToGraphics:
	PHX
	LDX $15E9|!Base2
	LDA !15F6,x
	PLX
	ORA JumpFlip,x
	ORA $64
	STA $0303|!Base2,y

        PLX                     ; \ pull, X = current tile of the frame we're drawing
        INY                     ;  | increase index to sprite tile map ($300)...
        INY                     ;  |    ...we wrote 1 16x16 tile...
        INY                     ;  |    ...sprite OAM is 8x8...
        INY                     ;  |    ...so increment 4 times
        DEX                     ;  | go to next tile of frame and loop
        BPL LOOP_START_2j       ; /

        PLX                     ; pull, X = sprite index
        LDY #$FF                ; \ We've already set 460, so use FF!
        LDA #$02                ; | A = number of tiles drawn - 1
        JSL $01B7B3|!BankB      ; / don't draw if offscreen
        RTS                     ; return

SUB_STOMP_PTS:
	PHY                      
        LDA $1697|!Base2	; \
        CLC                     ;  | 
        ADC !1626,x             ; / some enemies give higher pts/1ups quicker??
        INC $1697|!Base2	; increase consecutive enemies stomped
        TAY                     ;
        INY                     ;
        CPY #$08                ; \ if consecutive enemies stomped >= 8 ...
        BCS NO_SOUND            ; /    ... don't play sound 
        LDA sound,y		; \ play sound effect
        STA $1DF9|!Base2        ; /   
NO_SOUND:
	TYA                     ; \
        CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
        BCC NO_RESET            ;  |
        LDA #$08                ; /
NO_RESET:
	JSL $02ACE5|!BankB
        PLY                     
        RTS                     ; return

sound:	db $00,$13,$14,$15,$16,$17,$18,$19