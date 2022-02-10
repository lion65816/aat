;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configurable Thwomp, by Tattletale
;; This version contemplates thwompsprfix.asm
;;
;; Base on smwedit stuff and mikeyk's stuff too + Davros & Lui37's thwompsprfix
;;   and also thanks to whoever all.log + Thomas + Alcaroni
;;	 and also whoever else I should've credited that I forgot
;;
;; Features TM:
;;   - Fixes ascension glitch partially for upward fast movements
;;   - All fixes in thwompsprfix.asm are also coded for all Thwomp versions
;;   - All Thwomps have their proper Mad versions
;;     - Mad Thwomps go up and down / left and right endlessly once triggered
;;       they also have a shorter 'remain on ground / ceiling / whatever' timer
;;   - All Thwomps can be configured to be Power Thwomps
;;   - Power Thwomps stun you when they land
;;   - All Power Thwomps can also be Mad Thwomps :crash: - crazy aint it?
;;   - I also added the Thwomp Face Flip Fix patch, check the flags
;;
;; Configurations:
;; extra_bit
;;   off - normal thwomp
;;   on	 - mad thwomp (that thing that goes up and down like a madman, y'know)
;;
;; extra_prop_1:
;;   0 = Thwomp Up
;;   1 = Thwomp Down
;;   2 = Thwomp Right
;;   3 = Thwomp Left
;; Adding 40 to any of those you get a power thwomp :crash:
;;   "But that's a super bad way of coding and configuring it"
;;   - w/e dude
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; partially fixes ascension glitch when holding boost button A/B after clashing with it
; requires that routines folder to be merged with your pixi routines
; (requires SubVertPosWithClipping)
; (requires SpinPlayerUp)
!FixAscensionGlitchPLS = 0

; Blink based on mario's horizontal relative position to this sprite
; Check the Thwomp Face Flip Fix patch
!ThwompFacePatch = 0
; Invert Eye config
; This only works with the flag above, otherwise, just change the Sprite Tile Property table
!InvertEyeConfig = 0

; turns off ground shake
!TurnOffScreenShake = 0
; timer for it, ignore this if the above flag is set to 1
!ShakeScreenTimer = $18

; ignores 40 since that's for power thwomp configuration
; don't use 80 tho, it's used for custom death routine
!TypeBitMask = $3F

!SfxToPlay = $09
!SfxPort = $1DFC|!Base2

; how many frames to stun the player for in power mode
!StunPlayerFor = $18

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attacking config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!FastRaiseMaxSpeed = $C2
!FastRaiseGravity = $04

!FastFallMaxSpeed = $3E
!FastFallGravity = $04

!FastRightMaxSpeed = $3E
!FastRightGravity = $04

; CLC ADC lul
!FastLeftMaxSpeed = $C2
!FastLeftGravity = $FC

!NormalNextStateTimer = $40
!MadNextStateTimer = $10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returning config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!SlowFallSpeed = $10
!SlowRaiseSpeed = $F0
!SlowLeft = $F0
!SlowRight = $10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

ThwompDispX:                    ;$01AF40    | X position offsets for each of the Thwomp's tiles.
    db $FC,$04,$FC,$04,$00                  ; Fifth byte is used only when the Thwomp isn't using its normal expression. Same for the below.

ThwompDispY:                    ;$01AF45    | Y position offsets for each of the Thwomp's tiles.
    db $00,$00,$10,$10,$08

ThwompTiles:                    ;$01AF4A    | Tile numbers for the Thwomp.
    db $8E,$8E,$AE,$AE,$C8

ThwompGfxProp:					;$01AF4F    | YXPPCCCT for each of the Thwomp's tiles, no colors tho cfg colors now
		db $01,$41,$01,$41,$01

if !ThwompFacePatch
	if !InvertEyeConfig
		EyeProperties:
			db $00,$40
	else
		EyeProperties:
			db $40,$00
	endif
endif

!AngryThwompTile = $CA

; Range checks distance
AWARE_RANGE:
	dw $0040	; up
	dw $0040	; down
	dw $0080	; right
	dw $0080	; left
	
ATTACK_RANGE:
	dw $0024	; up
	dw $0024	; down
	dw $0060	; right
	dw $0060	; left
	
InitialThwompType:
	db $00
	db $01
	db $02
	db $03
; init pointer offset / length
; Normal then mad
StateSize:
	db $00,$03
	db $03,$03
	
	db $06,$03
	db $09,$03
	
	db $0C,$03
	db $0F,$03
	
	db $12,$03
	db $15,$03
States:
	dw WaitForPlayer, FastRaise, SlowFall
	dw WaitForPlayer, FastRaise, FastFall
	
	dw WaitForPlayer, FastFall, SlowRaise
	dw WaitForPlayer, FastFall, FastRaise
	
	dw WaitForPlayer, FastRight, SlowLeft
	dw WaitForPlayer, FastRight, FastLeft
	
	dw WaitForPlayer, FastLeft, SlowRight
	dw WaitForPlayer, FastLeft, FastRight
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	; need tables
	PHB
	PHK
	PLB

	LDA !extra_prop_1,x
	AND #!TypeBitMask
	TAY
	LDA InitialThwompType,y
	STA !160E,x
	TYA
	ASL
	ASL
	TAY
	; displace by 2 (extra bit / mad)
	LDA !extra_bits,x
	BIT #$04
	BEQ +
		INY #2
+
	; init pointer
	LDA StateSize,y
	STA !1504,x
	; length
	LDA StateSize+1,y
	STA !1602,x
	
	STZ !1FD6,x
	
	;LDA !extra_prop_1,x
	; thwomp offset
	LDA !sprite_x_low,x
    CLC
    ADC.b #$08
    STA !sprite_x_low,x
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x

	; Mad thwomp doesn't need that
	LDA !extra_bits,x
	BIT #$04
	BNE .return
	
	; Restore positions Y/X based on thwomp type
	LDA !160E,x
	CMP #$02
	BCC .updownThwomp
	CMP #$04
	BCS .updownThwomp

	; left/right thwomp
	LDA !sprite_x_low,x
    STA.w !151C,x
	LDA !sprite_x_high,x
	STA.w !1510,x
	
	PLB
	RTL
.updownThwomp
	LDA !sprite_y_low,x
    STA.w !151C,x
	LDA !sprite_y_high,x
	STA.w !1510,x
.return
	PLB
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR ThwompMain
	PLB
	RTL

ThwompMain:
	JSR ThwompGFX
	
	LDA.w !sprite_status,x
    CMP.b #$08
    BNE .return
    LDA $9D
    BNE .return
	
	%SubOffScreen()
	
	; interacts with sprites (makes sure this thing dies to actual thrown sprites, when toggled)
	JSL $018032|!BankB

	If !FixAscensionGlitchPLS
		JSR InteractWithMario
	else
		JSL $01A7DC|!BankB
	endif

	; mod % length + initial pointer * 2 (dw)
	LDA !C2,x
	CMP !1602,x
	BNE +
		LDA #$00
		STA !C2,x
+
	CLC
	ADC !1504,x
	CLC
	ASL
	TAY

	LDA States,y
	STA $00
	LDA States+1,y
	STA $01
	JMP ($0000|!Base1)
.return
	RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state - WaitForPlayer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WaitForPlayer:
	LDA !extra_bits,x
	BIT #$04
	BEQ +
	
	LDA !1570,x
	BNE WaitNextState
+

	; Make the Thwomp not fall if vertically offscreen.
	LDA.w !sprite_off_screen_vert,x
    BNE WaitReturn
    
	; Never fall if offscreen horizontally.
	LDA.w !sprite_off_screen_horz,x
    BNE WaitReturn

	; avoids right / left thwomp from triggering from the other sides
	%SubHorzPos()
	LDA !160E,x
	CMP #$02
	BNE +
	TYA
	BNE WaitReturn
+
	CMP #$03
	BNE +
	TYA
	BEQ WaitReturn
+
    TYA
    STA.w !157C,x 
	
	STZ.w !1528,x
	JSR AwareRangeCheck
    BCS .attackRangeCheck
	; aware expression
    LDA.b #$01
    STA.w !1528,x
.attackRangeCheck
	JSR AttackRangeCheck
    BCS WaitReturn
	; anger expression
    LDA.b #$02
    STA.w !1528,x
	
	; passed through wait once
	INC !1570,x	
WaitNextState:
	; change to attacking state
	INC !C2,x
WaitReturn:
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state - FastRaise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FastRaise:
if !FixAscensionGlitchPLS
	; set ascension flag
	INC !1534,x
endif
	LDA !1540,x
	BNE .skipSpeedUpdate
	
	LDA !1594,x
	BNE .skipInitialSpeed
		STZ !sprite_speed_y,x
		INC !1594,x
.skipInitialSpeed
	; apply speed
	JSL $01801A|!BankB

	; if max speed
	LDA !sprite_speed_y,x
	CMP #!FastRaiseMaxSpeed
	BMI .skipSpeedUpdate
		; apply gravity
		SEC
		SBC #!FastRaiseGravity
		STA !sprite_speed_y,x
.skipSpeedUpdate
	; blocked flags
	LDA #$08
	STA $45
	JSR CheckGroundVert
	BEQ .dontFinishState
		JSR SetSomeYSpeed
		JMP FinishThwompAttack
.dontFinishState
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state - FastFall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FastFall:
	LDA !1540,x
	BNE .skipSpeedUpdate
	
	LDA !1594,x
	BNE .skipInitialSpeed
		STZ !sprite_speed_y,x
		INC !1594,x
.skipInitialSpeed
	; apply speed
	JSL $01801A|!BankB

	; if max speed
	LDA !sprite_speed_y,x
	CMP #!FastFallMaxSpeed
	BCS .skipSpeedUpdate
		; apply gravity
		CLC
		ADC #!FastFallGravity
		STA !sprite_speed_y,x
.skipSpeedUpdate
	; blocked flags
	LDA #$04
	STA $45
	JSR CheckGroundVert
	BEQ .dontFinishState
		JSR SetSomeYSpeed
		JMP FinishThwompAttack
.dontFinishState
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state - FastRight
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FastRight:
	LDA !1540,x
	BNE .skipSpeedUpdate
	
	LDA !1594,x
	BNE .skipInitialSpeed
		STZ !sprite_speed_x,x
		INC !1594,x
.skipInitialSpeed
	; apply speed
	JSL $018022|!BankB

	; if max speed
	LDA !sprite_speed_x,x
	CMP #!FastRightMaxSpeed
	BCS .skipSpeedUpdate
		; apply gravity
		CLC
		ADC #!FastRightGravity
		STA !sprite_speed_x,x
.skipSpeedUpdate
	; blocked flags
	LDA #$01
	STA $45
	JSR CheckGroundRight
	BEQ .dontFinishState
		JSR SetSomeXSpeed
		BRA FinishThwompAttack
.dontFinishState
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state - FastLeft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FastLeft:
	; this code is only relevant for the mad mode
	LDA !1540,x
	BNE .skipSpeedUpdate
	
	LDA !1594,x
	BNE .skipInitialSpeed
		LDA #$FF
		STA !sprite_speed_x,x
		INC !1594,x
.skipInitialSpeed
	; apply speed
	JSL $018022|!BankB

	; if max speed
	LDA !sprite_speed_x,x
	CMP #!FastLeftMaxSpeed
	BCC .skipSpeedUpdate
		; apply gravity
		CLC
		ADC #!FastLeftGravity
		STA !sprite_speed_x,x
.skipSpeedUpdate
	; blocked flags
	LDA #$02
	STA $45
	JSR CheckGroundLeft
	BEQ .dontFinishState
		JSR SetSomeXSpeed
		BRA FinishThwompAttack
.dontFinishState
	RTS
	
FinishThwompAttack:
if !TurnOffScreenShake == 0
	LDA #!ShakeScreenTimer
	; shake screen timer
	STA $1887|!Base2
endif

	LDA #!SfxToPlay
	STA !SfxPort
	
	LDA !extra_bits,x
	AND #$04
	BEQ +
		LDA #!MadNextStateTimer
		BRA ++
	+
		LDA #!NormalNextStateTimer
	++
	; change state timer
	STA !1540,x
	
	LDA !extra_prop_1,x
	BIT #$40
	BEQ +
		; if not blocked downwards
		LDA $77
		AND #$04
		BEQ +
		LDA #!StunPlayerFor
		; set timer to freeze mario
		STA $18BD|!Base2
	+

	INC !C2,x
	STZ !1594,x			; reset start speed lock
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state - SlowFall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SlowFall:
	STZ $47
	LDA #!SlowFallSpeed
	STA $45
	BRA GoBackToOriginalYPosition
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state - SlowRaise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SlowRaise:
	STZ $47
	LDA #!SlowRaiseSpeed
	STA $45

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GoBackToOriginalYPosition
; $45 - what speed has to be set when going back to original position
; $47 - expression
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GoBackToOriginalYPosition:
	; if we're still waiting on the ground, return
	LDA !1540,x			
    BNE GoBackToOriginalYPositionNoCheckAnimation_return

GoBackToOriginalYPositionNoCheckAnimation:
    ; set expression
	LDA $47
    STA !1528,x

	;check if the sprite is in original position
	LDA !sprite_y_low,x	
	CMP !151C,x  
	BNE +

	LDA !sprite_y_high,x
	CMP !1510,x
	BNE +
		; reset speed lock for realignment
		STZ !1594,x
		; next state
		INC !C2,x
		RTS                     
+
	;set speed and apply it
	LDA $45
	STA !sprite_speed_y,x     
	JSL $01801A|!BankB             
.return         
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state - SlowLeft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SlowLeft:
	STZ $47
	LDA #!SlowLeft
	STA $45
	BRA GoBackToOriginalXPosition
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state - SlowRight
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SlowRight:
	STZ $47
	LDA #!SlowRight
	STA $45

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GoBackToOriginalXPosition
; $45 - what speed has to be set when going back to original position
; $47 - expression
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GoBackToOriginalXPosition:
	; if we're still waiting on the ground, return
	LDA !1540,x
    BNE GoBackToOriginalXPositionNoCheckAnimation_return

GoBackToOriginalXPositionNoCheckAnimation:
	; set expression
	LDA $47
    STA !1528,x

	;check if the sprite is in original position
	LDA !sprite_x_low,x	
	CMP !151C,x  
	BNE +

	LDA !sprite_x_high,x
	CMP !1510,x
	BNE +
		; reset speed lock for realignment
		STZ !1594,x
		; next state
		INC !C2,x
		RTS                     
+
	;set speed and apply it
	LDA $45
	STA !sprite_speed_x,x     
	JSL $018022|!BankB             
.return         
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interacts With Mario to avoid ascension glitch
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InteractWithMario:
If !FixAscensionGlitchPLS
	; if this is set, then try to fix ascension
	LDA !1534,x
	BEQ NormalContact
	
	; only on upwards speed
	LDA !sprite_speed_y,x
	BPL NormalContact
	
	LDA $140D|!Base2
	BEQ NormalContact
		JSL $03B664|!BankB
		JSL $03B69F|!BankB
		JSL $03B72B|!BankB
		BCC ContactReturn
		
		%SubVertPosWithClipping()
		TYA
		BEQ NormalContact
		
		; player displacement
		LDY #$00
		LDA $19
		BEQ .checkYoshi
			INY
			INY
		.checkYoshi:
			LDA $187A|!Base2
			BEQ .useDisplacement
			INY
		.useDisplacement
		
		LDA YDisplacementFromAbove,y
		STA $04
		
		LDA $0C
		CMP $04
		BCC NormalContact
		
		%SpinPlayerUp()
		RTS
NormalContact:
	JSL $01A7DC|!BankB
ContactReturn:
	; reset fix ascension glitch flag, this gets set at the states that need this
	STZ !1534,x
	RTS
	
YDisplacementFromAbove:
	db $F6,$E6,$E6,$DE
endif
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thwomp Ground Detection fix code
; $45 - what configuration byte has to be checked for !sprite_blocked_status,x
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckGroundVert:
	JSL $019138|!BankB					; interact with object
	LDA !sprite_blocked_status,x		; \ if on the ground...
	AND $45								;  |
	BNE +								; /
	
	LDA #$07
	STA $46
	
TryClipping:
	LDA !1656,x             			; \ preserve object clipping field
	PHA                     			; /
	ORA $46                			; \ set object clipping field
	STA !1656,x             			; /
	JSL $019138|!BankB					; interact with objects
	PLA                     			; \ restore object clipping field
	STA !1656,x             			; /

	LDA !sprite_blocked_status,x		; \ if on the ground...
	AND $45								;  |
	RTS

CheckGroundRight:
	LDA !sprite_x_low,x
	PHA
	CLC
	ADC #$06
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	PHA
	ADC #$00
	STA !sprite_x_high,x
	JMP StandardHorzGroundCheck

CheckGroundLeft:
	LDA !sprite_x_low,x
	PHA
	SEC
	SBC #$06
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	PHA
	SBC #$00
	STA !sprite_x_high,x
	
StandardHorzGroundCheck:
	JSL $019138|!BankB
	
	PLA
	STA !sprite_x_high,x
	PLA
	STA !sprite_x_low,x
	
	LDA !sprite_blocked_status,x		; \ if on the ground...
	AND $45
	BNE +
	
	LDA #$08
	STA $46
	JMP TryClipping
+
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thwomp Proximity Range fix code
; code extracted from thwompsprfix.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AwareRangeCheck:
	LDA !160E,x
	ASL
	TAY

	REP #$20
	LDA AWARE_RANGE,y
	BRA Store_Value         ; /

AttackRangeCheck:
	LDA !160E,x
	ASL
	TAY

	REP #$20
	LDA ATTACK_RANGE,y
Store_Value:
	STA $0C
	SEP #$20

; Horizontal proximity check
	LDA !sprite_x_high,x            ; \ if Mario is near the sprite...
	XBA                     		;  |
	LDA !sprite_x_low,x				;  |
	REP #$20						;  |
	SEC								;  |
	SBC $94							;  |
	BPL +							;  |
	EOR #$FFFF						;  |
	INC								;  |
+									;  |
	CMP $0C							;  | compare value of temp ram
	SEP #$20						;  |
	RTS								; / return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SetSomeXSpeed:
	LDA !sprite_speed_y,x
	PHA
	JSR SetSomeYSpeed
	STA !sprite_speed_x,x
	PLA
	STA !sprite_speed_y,x
	RTS

SetSomeYSpeed:					;-----------| Subroutine to set Y speed for a sprite when on the ground.
    LDA.w !sprite_blocked_status,x
    BMI +
		LDA.b #$00
		LDY.w !sprite_slope,x	;$019A0B    || If standing on a slope or Layer 2, give the sprite a Y speed of #$18.
		BEQ ++					; Else, clear its Y speed.
+
    LDA.b #$18
++
    STA !sprite_speed_y,x
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ThwompGFX:
    %GetDrawInfo()
	LDA !15F6,x             ; get sprite palette info
	STA $03
    LDA.w !1528,x			; expressions state
    STA $02

	; max tile count
	STZ $0A

	; how many tiles to draw in loop
    LDX.b #$03
    CMP.b #$00				; if facial expression is 0 then upload only 4 tiles
    BEQ InitThwompGFXLoop
	INX
InitThwompGFXLoop:
	STX $0A
ThwompGFXLoop:
    LDA $00
    CLC
    ADC.w ThwompDispX,x
    STA.w $0300|!Base2,y
	
    LDA $01
    CLC 
    ADC.w ThwompDispY,x
    STA.w $0301|!Base2,y
	
    LDA.w ThwompGfxProp,x
    ORA $64
	ORA $03
    STA.w $0303|!Base2,y
	
	LDA.w ThwompTiles,x
	; if X is equal to 4, then facial expression code will run, otherwise, use what's loaded to A
    CPX.b #$04
    BNE PrepareNextGFXLoop
	
	PHX
    LDX $02						; load exprenssion state, use default 4th tile if expression is no in state 02
    CPX.b #$02
    BNE DefaultExpression
    LDA.b #!AngryThwompTile
DefaultExpression:
if !ThwompFacePatch
	XBA
	STY $0B
	LDX $15E9|!Base2
	%SubHorzPos()
	LDA EyeProperties,y
	LDY $0B
	ORA $0303|!Base2,y
	STA $0303|!Base2,y
	XBA
endif
	PLX
PrepareNextGFXLoop:
    STA.w $0302|!Base2,y
    INY #4
    DEX
    BPL ThwompGFXLoop

	LDX $15E9|!Base2
	LDY #$02
	; relative amount of tiles
	LDA $0A
	JSL $01B7B3|!BankB
	RTS