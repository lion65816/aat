;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Portable TNT, by Ymro
;
; to be inserted with PIXI
;
; This sprite can be picked up and thrown like a P-switch, but
; when jumped on, it explodes like a bomb-omb
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Variables
TILEMAP: db $43,$45
TILEMAP_2:
	db $A0,$A2,$A4,$C0,$C2,$A6
BOMB_Y_POS:
	db $F8,$F8,$F8,$08,$08,$08
BOMB_X_POS:
	db $F0,$00,$10,$F0,$00,$10
!EXPLOISON_TIMER = $40

!TNT_COUNTDOWN = $60
!EXPLOSION_ALERT = $30
!EXPLOISON_HURT = $38

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite init routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	;INC !1528,x
	LDA !1528,x
	BEQ +
	JSR SuperFireInitCode
	RTL
+


  STZ !151C,x				; Reset Pressed flag
  STZ !1534,x				; Reset exploding flag
  STZ !1594,x                           ; Reset "Hurt Mario when exploding" flag
  LDA #$09				; \ Set sprite to carriable
  STA !14C8,x				; /
  RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
  PHB                     		; \
  PHK                     		;  | main sprite function, just calls local subroutine
  PLB                     		;  |
  JSR START_SPRITE_CODE   		;  |
  PLB                     		;  |
  RTL                     		; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Sprite code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NoContact:
Return:
  RTS

START_SPRITE_CODE:
	LDA !1528,x
	BEQ +
	JMP SuperFireCode
	RTS
+

  JSR GFX_ROUTINE			; Draw the GFX
  LDA !14C8,x				; Load sprite status
  CMP #$08				; \ If not active, return
  BCC Return				; / 
  LDA $9D				; \ If sprites locked, return
  BNE Return				; /

  %SubOffScreen()			; call suboffscreen 0

	LDA !1534,x
	BEQ + : JMP BombsForThrowingAtYou : +
  JSR Check_Explode			; Check whether it is time to explode
  JSR Explode

  JSL $01A7DC|!BankB        ; \ check for mario/sprice contact
  BCC NoContact				; /

  LDA !154C,x				;; \ No interaction if interaction blocked
  BNE Return				;; /
  
  LDA !1534,x				; \ 
  CMP #$01				; | Only a bomb when flag is set
  BNE NoBomb				; /
  LDA !1540,x				; \ 
  CMP #!EXPLOISON_HURT			; | If timer too large, return
  BPL Return				; /
  
  LDA $1490|!Base2			; \ Do not hurt Mario if star power
  BNE Return3				; /
  LDA $1497|!Base2          ; \ Do not hurt Mario if invincible
  BNE Return3				; /
  LDA !1594,x                           ; \ Do not hurt Mario if that flag is set
  BNE Return3                           ; /
  ; HURT MARIO
  INC !1594,x                           ; Set that flag
  LDA $187A|!Base2          ; \ Hurt on Yoshi if Mario's on Yoshi
  BNE HurtYoshi				; /
  JSL $00F5B7|!BankB        ; Hurt Mario
  Return3:
  RTS					; Return
  ; CODE_01F711
  HurtYoshi:				
  JSR HURT_YOSHI
  RTS

  ; This is partly ripped from the Mario/sprite interaction routine
  ; Handles being jumped on, being carried, etc.
  ; CODE_01AA58, as this sprite is carriable and cannot die while jumped on
  NoBomb:
  LDA !extra_bits,x                     ; \
  AND #$04                              ; | If extra bit set, uncarryable
  BNE NoCarry                           ; /
;  LDA !151C,x	; don't allow carry if switch is pressed
;  BNE NoCarry
  LDA $15				; \ Check if pressing B
  AND #$40				; /
  BEQ NoCarry			; If not, not carrying
  LDA $1470|!Base2		; \ If already carrying an enemy
  ORA $187A|!Base2      ; | or on Yoshi, not carrying
  BNE NoCarry			; /
  LDA #$0B				; \ Set sprite status to carried
  STA !14C8,x			; /
  INC $1470|!Base2      ; Set carry enemy flag
  LDA #$08				; \ Show the Mario picking up an item squat
  STA $1498|!Base2      ; /
  RTS					; Return

  ; CODE_01AAB7, as this sprite behaves (mostly) like a key/p-switch when touched
  NoCarry:
  LDA !14C8,x				;; \
  CMP #$09				;; | Custom code, do not do this if not carriable
  BNE Return2				;; /

  STZ !154C,x				; We now want interaction every frame
  LDA !D8,x				; Load sprite Y-value (low)
  SEC					; \ Subtract player's Y-value (low)
  SBC $D3				; /
  CLC					; \ Add 8 pixels, probably to accomodate Mario's/sprite
  ADC #$08				; / height?
  ;CMP #$20				; Compare with the value 20
CMP #$1D
  BCC NextToSprite			; If lower than 20, Mario is next to the sprite
  BPL AboveSprite			; If positive, Mario is above sprite
  LDA #$10				; \ Mario is now below sprite, set Y speed to 10
  STA $7D				; / so that he is pushed downwards
  RTS					; Return

  ; CODE_01AACD
  AboveSprite:
  LDA $7D				; \ If Mario's speed is negative (upwards)
  BMI Return2				; / return
  STZ $7D				; No more falling
  STZ $72				; No more flying as well
  INC $1471|!Base2      ; Mario is standing on a solid sprite
  LDA #$1F				; Load vertical offset (not Yoshi)
  LDY $187A|!Base2      ; \
  BEQ NoYoshi				; | If on Yoshi, load increased vertical offset
  LDA #$2F				; /
  NoYoshi:

LDY !151C,x ; Pressed flag
BEQ NoPress
SEC
SBC #$03
NoPress:

  STA $00				; Store offset temporary
  LDA !D8,x				; Load sprite Y-value (low)
  SEC					; \ Subtract offset
  SBC $00				; /
  STA $96				; Set Mario's Y-value (low) to offsetted value
  LDA !14D4,x				; Load sprite Y-value (hi)
  SBC #$00				; Subtract 0 immedeatly (or 1 based on carry)
  STA $97				; Store into Mario's Y-value (hi)
  LDA !151C,x				;; Load pressed flag
  BNE Return2				; If 1 (pressed) return
  ; Bounce Mario
  LDA #$0B				; \ Play sound effect
  STA $1DF9|!Base2      ; /
  INC !151C,x				;; Set pressed flag to 1
  LDA #!TNT_COUNTDOWN				;; \ Set explode timer
  STA !15AC,x				;; /

;LDA #$09
;STA !1662,x

  Return2:
  RTS					; Return

HorizontalData: db $01,$00,$FF,$FF

  ; CODE_01AB31
  NextToSprite:
  STZ $7B				; Stop moving horizontally
  %SubHorzPos()				; Get horizontal position relative to Mario
  TYA					; Now A=1 if Mario right of sprite, A=0 otherwise
  ASL					; Multiply it by 2
  TAY					; Transfer it back to Y
  REP #$20				; Set accumulator on 16-bit mode
  LDA $94				; Load Mario's X position
  CLC					; \ Add horizontal offset based on position
  ADC HorizontalData,y			; /
  STA $94				; Set Mario's X position
  SEP #$20				; Set accumulator on 8-bit mode
  Return5:
  RTS					; Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The "Seriously f*** everything" code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KillSprite:
	STZ !14C8,x
	RTS
BombsForThrowingAtYou:
	LDA !1540,x				; \ 
	BEQ KillSprite				; /

	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC : ADC #$0010
	CMP #$0028 : BPL + ; sprite width
	CMP #$FFF6 : BMI + ; player width
	SEP #$20
	; mellon SubVertPos
	lda !sprite_y_high,x
	xba
	lda !sprite_y_low,x
	rep #$20
	sec
	sbc #$0018
	sta $0e

	lda $96
	sec
	sbc $0e
	;/mellon code
	CMP #$0020 : BPL + ; sprite length
	CMP #$FFF4 : BMI + ; player length
	SEP #$20
	LDA $1490|!Base2			; \ Do not hurt Mario if star power
	BNE +				; /
	LDA $1497|!Base2          ; \ Do not hurt Mario if invincible
	BNE +				; /
  ; HURT MARIO
	JSL $00F5B7|!BankB        ; Hurt Mario
+	RTS
  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GFX_ROUTINE:
  LDA !1534,x				; \ draw alternate explosion
  BEQ + : JMP GFX_ROUTINE_2 : +				; /

	STZ $0C
	LDA #$FF : STA $0D

	LDA !15AC,x
	CMP #!EXPLOSION_ALERT : BCS +
	CMP #$00
	LSR A : AND #$01
	BEQ +
	LDA #$09 : STA $0C
	LDA #$F1 : STA $0D
+

	LDA !15AC,x
	CMP #!EXPLOSION_ALERT : BCS +
	AND #$03 : CMP #$01
	BNE +
	LDA #$23 : STA $1DFC|!Base2
+
	
	

  %GetDrawInfo()			; Get the drawing info

  LDA $00				; tile x position
  STA $0300|!Base2,y			;

  LDA $01				; tile y position
  STA $0301|!Base2,y			;

  LDA !151C,x				; Get pressed status
  PHX					; Preserve x
  TAX					; Transfer a to x
  LDA TILEMAP,x				; \ Store tile data, based on pressed byte
  ;LDA #$C0
  STA $0302|!Base2,y			; /
  PLX

  LDX $15E9|!Base2			; Load .cfg file data
  LDA !15F6,x				;
  ORA $64				; Sprite YXPPCCCT data

PHA
LDA $1419|!Base2
BEQ NoBehind
LDA !14C8,x
CMP #$0B
BNE NoBehind
PLA
AND #$CF      ;1100111, clear priority bits
BRA NoPull
NoBehind:
PLA
NoPull:

	ORA $0C
	AND $0D
  STA $0303|!Base2,y			;

  INY					; \ Increase 4 times, since we wrote a
  INY					; | 16x16 tile
  INY					; |
  INY					; /

  LDY #$02				; \ Call the draw routine with for a
  LDA #$00				; | 16x16 tile
  JSL $01B7B3|!BankB				; /
  RTS					; Return


GFX_ROUTINE_2:
	LDA #$FF : STA $09
	LDA !1540,x
	CMP #$20 : BCC +
	EOR #$3F : STA $09
+

	; Flashing colors
	LDA $14
	LSR #2
	AND #$03
	TAY
	LDA .PropertyTable,y
	STA $0C
	
	JSL $01ACF9|!BankB
	LDY #$01
-	LDA $148D|!Base2,y
	AND #$01
	ASL A
	DEC A : DEC A
	STA $0A,y
	DEY
	BPL -



	; call routine, push x out
	%GetDrawInfo()

	; smoke
	LDA $09 : CMP #$FF : BEQ .nosmoke
	LDX #$07 : STX $08
-
	TXA
	AND #$01
	BNE +

	LDA $09 : ASL #2
	AND .SmokeLimX,x
	EOR .SmokeDirX,x
	CLC : ADC $00
	STA $0300|!Base2,y
	
	LDA $09 : ASL A
	AND .SmokeLimY,x
	EOR .SmokeDirY,x
	CLC : ADC $01
	STA $0301|!Base2,y
	BRA ++
+

	LDA $09 : LSR A : STA $0E
	LDA $09 : ASL A : CLC : ADC $0E
	AND .SmokeLimX,x
	EOR .SmokeDirX,x
	CLC : ADC $00
	STA $0300|!Base2,y
	
	LDA $09 : LSR A : STA $0E
	LDA $09 : CLC : ADC $0E
	AND .SmokeLimY,x
	EOR .SmokeDirY,x
	CLC : ADC $01
	STA $0301|!Base2,y
++

	PHX
	LDA $09 : LSR #3 : AND #$03 : TAX
	LDA .SmokeParticle,x
	STA $0302|!Base2,y
	PLX
	
	LDA #$30
	STA $0303|!Base2,y
	
	INY #4 : DEX : BPL -
	BRA +
.nosmoke
	LDX #$05 : STX $08
	BRA ++
+	LDX #$05 : TXA : CLC : ADC $08 : STA $08 : INC $08
++
-
	LDA $00				; tile x position
	CLC : ADC BOMB_X_POS,x
	CLC : ADC $0A
	STA $0300|!Base2,y

	LDA $01				; tile y position
	CLC : ADC BOMB_Y_POS,x
	CLC : ADC $0B
	STA $0301|!Base2,y

	LDA TILEMAP_2,x		; Tiles
	STA $0302|!Base2,y
	
	LDA $0C ; Properties
	; not going to bother with other checks
	STA $0303|!Base2,y

	INY	#4 : DEX : BPL -


	LDX $15E9|!Base2
    LDY #$02                            ;all 16x16 tiles
    LDA $08;#$05 or #$0C
    JSL $01B7B3|!BankB                  		;This insert the new tiles into the oam, 
	RTS

.PropertyTable
	db $35,$37,$39,$3B

.SmokeParticle
	db $60,$62,$64,$66

	; up,upright,right,downright,down,downleft,left,leftup
.SmokeDirX
	db $00,$00,$00,$00,$FF,$FF,$FF,$FF
.SmokeLimX
	db $00,$FF,$FF,$FF,$00,$FF,$FF,$FF
.SmokeDirY
	db $00,$00,$00,$FF,$FF,$FF,$FF,$00
.SmokeLimY
	db $FF,$FF,$00,$FF,$FF,$FF,$00,$FF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Explode Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Check_Explode:
  LDA !15AC,x				; \ If timer not 0, return
  BNE Return4				; |
  LDA !151C,x				; | And if not pressed, return
  BEQ Return4				; |
  LDA !1534,x				; | And not already exploding, return
  BNE Return4				; /
  
  ; Explode
  LDA #$08				; \ Sprite status = alive
  STA !14C8,x				; /
  LDA #$01				; \ Set exploison flag
  STA !1534,x				; /
  LDA #!EXPLOISON_TIMER			; \ Set exploison timer
  STA !1540,x				; /
  LSR
  STA $1887|!Base2
;  LDA #$29				; \ Play sound
;  STA $1DF9|!Base2      ; /
  LDA #$09				; \ Play sound
  STA $1DFC|!Base2      ; /
  LDA #$9B				; \ Set Tweaker byte
  ;LDA #$1B
  STA !167A,x				; / (invincible, unkickable, no default interaction)
  LDA #$11				; \ Set Tweaker byte
  STA !1686,x				; / (inedible, interact with sprites)
  ;STA !1662,x
  


;	LDY #$03
;-	STY $0C
;	LDA SmokeDisplx,y : STA $00
;	LDA SmokeDisply,y : STA $01
;	LDA #$18 : STA $02
;	LDA #$01 : %SpawnSmoke()
;	LDY $0C : DEY : BPL -
	

; Check if sprite on Yoshi's tongue. If so, unlatch from it and hurt Yoshi
LDA !15D0,x				; \ Return if not on tongue
BEQ Return4				; /
STZ !15D0,x				; Unlatch
PHX					; \
JSR FIND_YOSHI				; | Find Yoshi's sprite index and put it in X
CPX #$FF				; |
BEQ Return4				; /
LDA #$FF				; \ Reset Yoshi's tongue contents
STA !160E,x				; /
PLX					; Retore X

  ;JSL $07F7D2				; Reset Sprite tables
  Return4:
  RTS					; Return
;SmokeDisplx:
;	db -$40,-$40,$40,$40
;SmokeDisply:
;	db -$18,$18,-$18,$18

Explode:
  LDA !1534,x				; \ If not exploding, return
  BEQ Return4				; /
  ;PHB					; \ 
  ;LDA.b #(!BankB>>16)|$02				; | Load #$02 into bank
  ;PHA					; |
  ;PLB					; /
  ;JSL $028086|!BankB				; Execute explode routine
  ;PLB					; Recover bank
  RTS					; Return

HURT_YOSHI:
 ; HURT ON YOSHI SUBROUTINE
 ; Find Yoshi in the sprite slots
 PHX                       ; Store current sprite index on the stack
 JSR FIND_YOSHI
 CPX #$FF
 BNE .CODE_01F713 
 PLX                       ; \ Yoshi is not found, so return
 RTS                       ; /

 .CODE_01F713
 LDA #$10                
 STA !163E,x             
 ;LDA #$03                  ; \ Play sound effect 
 ;STA $1DFA|!Base2                 ; / NOT FOR AMK
 LDA #$13                  ; \ Play sound effect 
 STA $1DFC|!Base2                 ; / 
 LDA #$02                
 STA !C2,x                 ; Store in sprite state
 STZ $187A|!Base2                 ; Clear on Yoshi flag
 LDA #$C0                  ; \ Set vertical speed
 STA $7D			  ; /
 STZ $7B       		  ; Clear horizontal speed
 %SubHorzPos()        
 LDA DATA_01EBBE,Y       
 STA !B6,x    		  ; Store in sprite speed X
 STZ !1594,x             
 STZ !151C,x             
 STZ $18AE|!Base2               
 STZ $0DC1|!Base2                 ; Overworld has no Yoshi anymore
 LDA #$30                  ; \ Mario invincible timer = #$30 
 STA $1497|!Base2                 ; / 
 JSR CODE_01EDCC           ; Do some other routine?
 PLX                       ; Restore current sprite index
 RTS                       ; Return

DATA_01EBBE:                      db $E8,$18

CODE_01EDCC:
LDY #$00                
LDA !D8,x		  ; Load sprite Y position, low       
SEC                       
SBC DATA_01EDE2,Y         
STA $96                   ; Set Mario Y position, low  
STA $D3                   
LDA !14D4,x               ; Load sprite Y position, high
SBC #$00                
STA $97                   ; Store in Mario Y position, high  
STA $D4                   
RTS                       ; Return

DATA_01EDE2:                      db $04,$10

; Subroutine that finds Yoshi and stores its sprite index into the X register
; Make sure to PHX first. X contains #$FF is Yoshi is not found
FIND_YOSHI:
 LDX.b #!SprSize-1
 .YoshiLoop
 LDA !9E,x
 CMP #$35
 BEQ .FIND_YOSHI_RETURN
 DEX
 BPL .YoshiLoop
 LDX #$FF                  ;Yoshi is not found, return
.FIND_YOSHI_RETURN
 RTS                       ;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
; jesus hell all the slots are filled
	!addr = !Base2
    !rom = !BankB

;########################################
;######## Scratchs Rams [$00,$0F] #######
;########################################
!Scratch0 = $00
!Scratch1 = $01
!Scratch2 = $02
!Scratch3 = $03
!Scratch4 = $04
!Scratch5 = $05
!Scratch6 = $06
!Scratch7 = $07
!Scratch8 = $08
!Scratch9 = $09
!ScratchA = $0A
!ScratchB = $0B
!ScratchC = $0C
!ScratchD = $0D
!ScratchE = $0E
!ScratchF = $0F

;########################################
;############## Counters ################
;########################################
!TrueFrameCounter = $13
!EffectiveFrameCounter = $14

;########################################
;############## Control #################
;########################################
!ButtonPressed_BYETUDLR = $15
!ButtonDown_BYETUDLR = $16
!ButtonPressed_AXLR0000 = $17
!ButtonDown_AXLR0000 = $18

;########################################
;############## Layers ##################
;########################################
!Layer1X = $1A
!Layer1Y = $1C
!Layer2X = $1E
!Layer2Y = $20
!Layer3X = $22
!Layer3Y = $24

;########################################
;############## Player ##################
;########################################
!PlayerX = $94
!PlayerY = $96
!PlayerXSpeed = $7B
!PlayerYSpeed = $7D
!PowerUp = $19
!Lives = $0DBE|!addr
!Coins = $0DBF|!addr
!ItemBox = $0DC2|!addr
!PlayerInAirFlag = $72
!PlayerDuckingFlag = $73
!PlayerClimbingFlag_N00SIFHB = $74
!PlayerWaterFlag = $75
!PlayerDirection = $76
!PlayerBlockedStatus_S00MUDLR = $77
!PlayerHide_DLUCAPLU = $78
!CurrentPlayer = $0DB3|!addr
!CapeImage = $13DF|!addr
!PlayerPose = $13E0|!addr
!PlayerSlope = $13E1|!addr
!SpinjumpTimer = $13E2|!addr
!PlayerWallRunningFlag = $13E3|!addr
!PlayerFrozenFlag = $13FB|!addr
!PlayerCarryingFlag = $1470|!addr
!PlayerCarryingFlagImage = $148F|!addr
!PlayerAnimationTimer = $1496|!addr
!PlayerFlashingTimer = $1497|!addr
!P1PowerUp = $0DB8|!addr
!P2PowerUp = $0DB9|!addr
!P1Lives = $0DB4|!addr
!P2Lives = $0DB5|!addr
!P1Coins = $0DB6|!addr
!P2Coins = $0DB7|!addr
!P1YoshiColor = $0DBA|!addr
!P2YoshiColor = $0DBB|!addr
!P1ItemBox = $0DBC|!addr
!P2ItemBox = $0DBD|!addr

;########################################
;############### Global #################
;########################################
!LockAnimationFlag = $9D
!HScrollEnable = $1411|!addr
!VScrollEnable = $1412|!addr
!HScrollLayer2Type = $1413|!addr
!VScrollLayer2Type = $1414|!addr
!WaterFlag = $85
!SlipperyFlag = $86
!GameMode = $0100|!addr
!TwoPlayersFlag = $0DB2|!addr

;########################################
;################ OAM ###################
;########################################
!TileXPosition200 = $0200|!addr
!TileYPosition200 = $0201|!addr
!TileCode200 = $0202|!addr
!TileProperty200 = $0203|!addr
!TileSize420 = $0420|!addr
!TileXPosition = $0300|!addr
!TileYPosition = $0301|!addr
!TileCode = $0302|!addr
!TileProperty = $0303|!addr
!TileSize460 = $0460|!addr

;########################################
;############### Yoshi ##################
;########################################
!YoshiX = $18B0|!addr
!YoshiY = $18B2|!addr
!YoshiKeyInMouthFlag = $191C|!addr

;########################################
;############## Clusters ################
;########################################
!ClusterNumber = $1892|!addr
!ClusterXLow = $1E16|!addr
!ClusterYLow = $1E02|!addr
!ClusterXHigh = $1E3E|!addr
!ClusterYHigh = $1E2A|!addr
!ClusterMiscTable1 = $0F4A|!addr
!ClusterMiscTable2 = $0F5E|!addr
!ClusterMiscTable3 = $0F72|!addr
!ClusterMiscTable4 = $0F86|!addr
!ClusterMiscTable5 = $0F9A|!addr
!ClusterMiscTable6 = $1E52|!addr
!ClusterMiscTable7 = $1E66|!addr
!ClusterMiscTable8 = $1E7A|!addr
!ClusterMiscTable9 = $1E8E|!addr

;########################################
;############## Extended ################
;########################################
!ExtendedNumber = $170B|!addr
!ExtendedXLow = $171F|!addr
!ExtendedYLow = $1715|!addr
!ExtendedXHigh = $1733|!addr
!ExtendedYHigh = $1729|!addr
!ExtendedXSpeed = $1747|!addr
!ExtendedYSpeed = $173D|!addr
!ExtendedXSpeedAccumulatingFraction = $175B|!addr
!ExtendedYSpeedAccumulatingFraction = $1751|!addr
!ExtendedBehindLayersFlag = $1779|!addr
!ExtendedMiscTable1 = $1765|!addr
!ExtendedMiscTable2 = $176F|!addr

;########################################
;############### Sprites ################
;########################################
!SpriteIndex = $15E9|!Base2
!SpriteNumber = $9E
!SpriteStatus = !14C8
!SpriteXLow = !E4
!SpriteYLow = !D8
!SpriteXHigh = !14E0
!SpriteYHigh = !14D4
!SpriteXSpeed = !B6
!SpriteYSpeed = !AA
!SpriteXSpeedAccumulatingFraction = $14F8
!SpriteYSpeedAccumulatingFraction = $14EC
!SpriteDirection = $157C
!SpriteBlockedStatus_ASB0UDLR = !1588
!SpriteHOffScreenFlag = !15A0
!SpriteVOffScreenFlag = !186C
!SpriteHMoreThan4TilesOffScreenFlag = !15C4
!SpriteSlope = $15B8
!SpriteYoshiTongueFlag = $15D0
!SpriteInteractionWithObjectEnable = $15DC
!SpriteIndexOAM = $15EA
!SpriteProperties_YXPPCCCT = $15F6
!SpriteLoadStatus = $161A
!SpriteBehindEscenaryFlag = !1632
!SpriteInLiquidFlag = $164A
!SpriteDecTimer1 = !1540
!SpriteDecTimer2 = !154C
!SpriteDecTimer3 = !1558
!SpriteDecTimer4 = !1564
!SpriteDecTimer5 = !15AC
!SpriteDecTimer6 = !163E
!SpriteDecTimer7 = !1FE2
!SpriteTweaker1656_SSJJCCCC = !1656
!SpriteTweaker1662_DSCCCCCC = !1662
!SpriteTweaker166E_LWCFPPPG = !166E
!SpriteTweaker167A_DPMKSPIS = !167A
!SpriteTweaker1686_DNCTSWYE = !1686
!SpriteTweaker190F_WCDJ5SDP = !190F
!SpriteMiscTable3 = !C2
!SpriteMiscTable4 = !1504
!SpriteMiscTable5 = !1510
!SpriteMiscTable6 = !151C
!SpriteMiscTable7 = !1528
!SpriteMiscTable8 = !1534
!SpriteMiscTable9 = !1570
!SpriteMiscTable10 = !1594
!SpriteMiscTable11 = !1602
!SpriteMiscTable12 = !160E
!SpriteMiscTable13 = !1626
!SpriteMiscTable14 = !187B
!SpriteMiscTable15 = !1FD6

;########################################
;############### GIEPY ##################
;########################################
!ExtraBits = !7FAB10
!NewCodeFlag = !7FAB1C
!ExtraProp1 = !7FAB28
!ExtraProp2 = !7FAB34
!ExtraByte1 = !7FAB40
!ExtraByte2 = !7FAB4C
!ExtraByte3 = !7FAB58
!ExtraByte4 = !7FAB64
!ShooterExtraByte = $7FAB70
!GeneratorExtraByte = $7FAB78
!ScrollerExtraByte = $7FAB79
!CustomSpriteNumber = $7FAB9E
!ShooterExtraBits = $7FABAA
!GeneratorExtraBits = $7FABB2
!Layer1ExtraBits = $7FABB3
!Layer2ExtraBits = $7FABB4
!SpriteFlags = $7FABB5

;######################################
;############## Defines ###############
;######################################

!FrameIndex = !SpriteMiscTable3
;!AnimationTimer = !SpriteDecTimer1
;!AnimationIndex = !SpriteMiscTable2
;!AnimationFrameIndex = !SpriteMiscTable3
!LocalFlip = !SpriteMiscTable4
!GlobalFlip = !SpriteMiscTable5

!FrameTimer = !SpriteMiscTable6
!FasterFire = !SpriteMiscTable7
;!InitRAM = !SpriteMiscTable15

;######################################
;########### Init Routine #############
;######################################
;print "INIT ",pc
SuperFireInitCode:
	LDA #$00
	STA !GlobalFlip,x
	;JSL InitWrapperChangeAnimationFromStart
    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 
	
	LDA #$17 : STA $1DFC|!Base2
RTS

;######################################
;########## Main Routine ##############
;######################################
;print "MAIN ",pc
  ;  PHB
 ;   PHK
;    PLB
SuperFireCode:
    JSR SuperFireCodeCode
    JSR GraphicRoutine
	RTS
 ;   PLB
;RTL

;>Routine: SpriteCode
;>Description: This routine excecute the logic of the sprite
;>RoutineLength: Short
;HandleInit:
;	LDA !InitRAM,x
;	BNE +
;	INC !InitRAM,x
;	%SubHorzPos()
;	TYA
;	STA !SpriteDirection,x
;	LDA #$17 : STA $1DFC
;+	RTS

;SpeedDir:
;	db $20,-$20
;	db $38,-$38
ReturnAAA:
RTS
SuperFireCodeCode:
;	JSR HandleInit

    LDA !SpriteStatus,x			        
	CMP #$08                            ;if sprite dead return
	BNE ReturnAAA	

	LDA !LockAnimationFlag				    
	BNE ReturnAAA			                    ;if locked animation return.

    %SubOffScreen()

	INC !FrameTimer,x
	LDA !FrameTimer,x
	LSR A
	AND #$07
	STA !FrameIndex,x

    JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

    ;Here you can write your sprite code routine
    ;This will be excecuted once per frame excepts when 
    ;the animation is locked or when sprite status is not #$08

    ;JSR AnimationRoutine                ;Calls animation routine and decides the next frame to draw
    
	
;	LDY !SpriteDirection,x
;	LDA !FasterFire,x
;	BEQ +;
;	TYA : CLC : ADC #$02 : TAY
;+	LDA SpeedDir,y : STA !SpriteXSpeed,x
	JSL $018022|!BankB
	
	LDA !sprite_speed_x,x
	BMI +
	LDA #$01 : STA !GlobalFlip,x
+
	RTS

;>EndRoutine

;######################################
;######## Sub Routine Space ###########
;######################################

;######################################
;########## Graphics Space ############
;######################################
;SPR_DIR:
;	db ($0A*8),$00
GraphicRoutine:

;	LDA !SpriteDirection,x
;	STA !GlobalFlip,x
;	LSR A
;	STA !GlobalFlip,x
;	LDA SPR_DIR,y
;	STA $0C

	%GetDrawInfo()

    STZ !Scratch3                       ;$02 = Free Slot but in 16bits
    STY !Scratch2

    STZ !Scratch5
    LDA !GlobalFlip,x   
    ASL
    STA !Scratch4                       ;$04 = Global Flip but in 16bits


    PHX                                 ;Preserve X
    
    STZ !Scratch7
    LDA !FrameIndex,x
    STA !Scratch6                       ;$06 = Frame Index but in 16bits

    REP #$30                            ;A/X/Y 16bits mode
    LDY !Scratch4                       ;Y = Global Flip
    LDA !Scratch6
    ASL
	CLC
    ADC FramesFlippers,y
    TAX                                 ;X = Frame Index

	LDA #$0009
    STA !Scratch8

    LDA FramesEndPosition,x
    STA !Scratch4                       ;$04 = End Position + A value used to select a frame version that is flipped

    LDA FramesStartPosition,x           
    TAX                                 ;X = Start Position
    SEP #$20                            ;A 8bits mode
    LDY !Scratch2                       ;Y = Free Slot
    CPY #$00FD
    BCS .return                         ;Y can't be more than #$00FD
-
    LDA Tiles,x
    STA !TileCode,y                     ;Set the Tile code of the tile Y

    LDA Properties,x
    STA !TileProperty,y                 ;Set the Tile property of the tile Y

    LDA !Scratch0
	CLC
	ADC XDisplacements,x
	STA !TileXPosition,y                ;Set the Tile x pos of the tile Y

    LDA !Scratch1
	CLC
	ADC YDisplacements,x
	STA !TileYPosition,y                ;Set the Tile y pos of the tile Y

    INY
    INY
    INY
    INY                                 ;Next OAM Slot
    CPY #$00FD
    BCS .return                         ;Y can't be more than #$00FD

    DEX
    BMI .return
    CPX !Scratch4                       ;if X < start position or is negative then return
    BCS -                               ;else loop

.return
    SEP #$10
    PLX                                 ;Restore X
    
	LDY #$00
    LDA !Scratch8                       ;Load the number of tiles used by the frame
    JSL $01B7B3|!rom                  		;This insert the new tiles into the oam, 
                                        ;A = #$00 => only tiles of 8x8, A = #$02 = only tiles of 16x16, A = #$04 = tiles of 8x8 or 16x16
                                        ;if you select A = #$04 then you must put the sizes of the tiles in !TileSize
	RTS
;>EndRoutine

;All words that starts with '@' and finish with '.' will be replaced by Dyzen

;>Table: FramesFlippers
;>Description: Values used to add values to FramesStartPosition and FramesEndPosition
;To use a flipped version of the frames.
;>ValuesSize: 16
;FramesFlippers:
;    dw $0000,$0010
FramesFlippers:
    dw $0000,$0010
FramesStartPosition:
    dw $0009,$0013,$001D,$0027,$0031,$003B,$0045,$004F
	dw $0059,$0063,$006D,$0077,$0081,$008B,$0095,$009F
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$000A,$0014,$001E,$0028,$0032,$003C,$0046
	dw $0050,$005A,$0064,$006E,$0078,$0082,$008C,$0096
	
Tiles:
    
Frame0_SFire1_Tiles:
	db $33,$34,$32,$50,$33,$34,$33,$34,$33,$34
Frame1_SFire2_Tiles:
	db $32,$50,$33,$34,$32,$50,$32,$50,$32,$50
Frame2_SFire3_Tiles:
	db $33,$34,$32,$50,$33,$34,$33,$34,$33,$34
Frame3_SFire4_Tiles:
	db $32,$50,$33,$34,$32,$50,$32,$50,$32,$50
Frame4_SFire5_Tiles:
	db $33,$34,$32,$50,$33,$34,$33,$34,$33,$34
Frame5_SFire6_Tiles:
	db $32,$50,$33,$34,$32,$50,$32,$50,$32,$50
Frame6_SFire7_Tiles:
	db $33,$34,$32,$50,$33,$34,$33,$34,$33,$34
Frame7_SFire8_Tiles:
	db $32,$50,$33,$34,$32,$50,$32,$50,$32,$50
Frame0_SFire1_TilesFlipX:
	db $33,$34,$32,$50,$33,$34,$33,$34,$33,$34
Frame1_SFire2_TilesFlipX:
	db $32,$50,$33,$34,$32,$50,$32,$50,$32,$50
Frame2_SFire3_TilesFlipX:
	db $33,$34,$32,$50,$33,$34,$33,$34,$33,$34
Frame3_SFire4_TilesFlipX:
	db $32,$50,$33,$34,$32,$50,$32,$50,$32,$50
Frame4_SFire5_TilesFlipX:
	db $33,$34,$32,$50,$33,$34,$33,$34,$33,$34
Frame5_SFire6_TilesFlipX:
	db $32,$50,$33,$34,$32,$50,$32,$50,$32,$50
Frame6_SFire7_TilesFlipX:
	db $33,$34,$32,$50,$33,$34,$33,$34,$33,$34
Frame7_SFire8_TilesFlipX:
	db $32,$50,$33,$34,$32,$50,$32,$50,$32,$50
;>EndTable


;>Table: Properties
;>Description: Properties of each tile of each frame
;>ValuesSize: 8
Properties:
    
Frame0_SFire1_Properties:
	db $37,$37,$37,$37,$37,$37,$37,$37,$37,$37
Frame1_SFire2_Properties:
	db $37,$37,$37,$37,$37,$37,$37,$37,$37,$37
Frame2_SFire3_Properties:
	db $B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7
Frame3_SFire4_Properties:
	db $B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7
Frame4_SFire5_Properties:
	db $37,$37,$37,$37,$37,$37,$37,$37,$37,$37
Frame5_SFire6_Properties:
	db $37,$37,$37,$37,$37,$37,$37,$37,$37,$37
Frame6_SFire7_Properties:
	db $B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7
Frame7_SFire8_Properties:
	db $B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7
Frame0_SFire1_PropertiesFlipX:
	db $67,$67,$67,$67,$67,$67,$67,$67,$67,$67
Frame1_SFire2_PropertiesFlipX:
	db $67,$67,$67,$67,$67,$67,$67,$67,$67,$67
Frame2_SFire3_PropertiesFlipX:
	db $E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7
Frame3_SFire4_PropertiesFlipX:
	db $E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7
Frame4_SFire5_PropertiesFlipX:
	db $67,$67,$67,$67,$67,$67,$67,$67,$67,$67
Frame5_SFire6_PropertiesFlipX:
	db $67,$67,$67,$67,$67,$67,$67,$67,$67,$67
Frame6_SFire7_PropertiesFlipX:
	db $E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7
Frame7_SFire8_PropertiesFlipX:
	db $E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7
;>EndTable
;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_SFire1_XDisp:
	db $00,$08,$FC,$04,$04,$0C,$00,$08,$04,$0C
Frame1_SFire2_XDisp:
	db $00,$08,$FC,$04,$04,$0C,$00,$08,$04,$0C
Frame2_SFire3_XDisp:
	db $04,$0C,$FC,$04,$00,$08,$04,$0C,$00,$08
Frame3_SFire4_XDisp:
	db $04,$0C,$FC,$04,$00,$08,$04,$0C,$00,$08
Frame4_SFire5_XDisp:
	db $04,$0C,$FC,$08,$00,$08,$04,$0C,$00,$08
Frame5_SFire6_XDisp:
	db $04,$0C,$FC,$04,$00,$08,$04,$0C,$00,$08
Frame6_SFire7_XDisp:
	db $00,$08,$FC,$04,$04,$0C,$00,$08,$04,$0C
Frame7_SFire8_XDisp:
	db $00,$08,$FC,$04,$04,$0C,$00,$08,$04,$0C
Frame0_SFire1_XDispFlipX:
	db $08,$00,$0C,$04,$04,$FC,$08,$00,$04,$FC
Frame1_SFire2_XDispFlipX:
	db $08,$00,$0C,$04,$04,$FC,$08,$00,$04,$FC
Frame2_SFire3_XDispFlipX:
	db $04,$FC,$0C,$04,$08,$00,$04,$FC,$08,$00
Frame3_SFire4_XDispFlipX:
	db $04,$FC,$0C,$04,$08,$00,$04,$FC,$08,$00
Frame4_SFire5_XDispFlipX:
	db $04,$FC,$0C,$00,$08,$00,$04,$FC,$08,$00
Frame5_SFire6_XDispFlipX:
	db $04,$FC,$0C,$04,$08,$00,$04,$FC,$08,$00
Frame6_SFire7_XDispFlipX:
	db $08,$00,$0C,$04,$04,$FC,$08,$00,$04,$FC
Frame7_SFire8_XDispFlipX:
	db $08,$00,$0C,$04,$04,$FC,$08,$00,$04,$FC
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_SFire1_YDisp:
	db $04,$04,$04,$04,$F2,$F2,$04,$04,$16,$16
Frame1_SFire2_YDisp:
	db $FE,$FE,$04,$04,$F4,$F4,$0A,$0A,$14,$14
Frame2_SFire3_YDisp:
	db $0E,$0E,$04,$04,$10,$10,$FA,$FA,$F8,$F8
Frame3_SFire4_YDisp:
	db $0A,$0A,$04,$04,$14,$14,$FE,$FE,$F4,$F4
Frame4_SFire5_YDisp:
	db $04,$04,$04,$04,$F2,$F2,$04,$04,$16,$16
Frame5_SFire6_YDisp:
	db $FE,$FE,$04,$04,$F4,$F4,$0A,$0A,$14,$14
Frame6_SFire7_YDisp:
	db $0E,$0E,$04,$04,$10,$10,$FA,$FA,$F8,$F8
Frame7_SFire8_YDisp:
	db $0A,$0A,$04,$04,$14,$14,$FE,$FE,$F4,$F4
Frame0_SFire1_YDispFlipX:
	db $04,$04,$04,$04,$F2,$F2,$04,$04,$16,$16
Frame1_SFire2_YDispFlipX:
	db $FE,$FE,$04,$04,$F4,$F4,$0A,$0A,$14,$14
Frame2_SFire3_YDispFlipX:
	db $0E,$0E,$04,$04,$10,$10,$FA,$FA,$F8,$F8
Frame3_SFire4_YDispFlipX:
	db $0A,$0A,$04,$04,$14,$14,$FE,$FE,$F4,$F4
Frame4_SFire5_YDispFlipX:
	db $04,$04,$04,$04,$F2,$F2,$04,$04,$16,$16
Frame5_SFire6_YDispFlipX:
	db $FE,$FE,$04,$04,$F4,$F4,$0A,$0A,$14,$14
Frame6_SFire7_YDispFlipX:
	db $0E,$0E,$04,$04,$10,$10,$FA,$FA,$F8,$F8
Frame7_SFire8_YDispFlipX:
	db $0A,$0A,$04,$04,$14,$14,$FE,$FE,$F4,$F4

;######################################
;######## Interaction Space ###########
;######################################

InteractMarioSprite:
	LDA !SpriteTweaker167A_DPMKSPIS,x
	AND #$20
	BNE ProcessInteract      
	TXA                       
	EOR !TrueFrameCounter      			
	AND #$01                	
	ORA !SpriteHOffScreenFlag,x 				
	BEQ ProcessInteract       
ReturnNoContact:
	CLC                       
	RTS
ProcessInteract:
	%SubHorzPos()
	LDA !ScratchF                  
	CLC                       
	ADC #$50                
	CMP #$A0                
	BCS ReturnNoContact       ; No contact, return 
	%SubVertPos()
	LDA !ScratchE                   
	CLC                       
	ADC #$60                
	CMP #$C0                
	BCS ReturnNoContact       ; No contact, return 
	LDA $71    ; \ If animation sequence activated... 
	CMP #$01                ;  | 
	BCS ReturnNoContact       ; / ...no contact, return 
	LDA #$00                ; \ Branch if bit 6 of $0D9B set? 
	BIT $0D9B|!addr               ;  | 
	BVS +           ; / 
	LDA $13F9|!addr ; \ If Mario and Sprite not on same side of scenery... 
	EOR !SpriteBehindEscenaryFlag,x ;  |
+
	BNE ReturnNoContact2
	JSL $03B664|!rom				; MarioClipping
	JSR Interaction

	BCC ReturnNoContact2
	LDA !ScratchE
	CMP #$01
	BNE +
	JSR DefaultAction
+
	SEC
	RTS
ReturnNoContact2:
	CLC
	RTS

Interaction:
    STZ !ScratchE
	LDA !GlobalFlip,x
    ASL
	TAY                     ;Y = Flip Adder, used to jump to the frame with the current flip

    LDA !FrameIndex,x
	STA !Scratch4
	STZ !Scratch5

    REP #$20
	LDA !Scratch4
	ASL
	CLC
	ADC HitboxAdder,y
	REP #$10
	TAY

    LDA FrameHitboxesIndexer,y
    TAY
    SEP #$20

-
    LDA FrameHitBoxes,y
    CMP #$FF
    BNE +
    LDA !ScratchE
    BNE ++
	SEP #$10
	LDX !SpriteIndex
    CLC
    RTS
++
	SEP #$10
	LDX !SpriteIndex
    SEC
    RTS
+
    STA !Scratch4
    STZ !Scratch5
    PHY

    REP #$20
    LDA !Scratch4
    ASL
    TAY

    LDA HitboxesStart,y
    TAY
    SEP #$20
+

	STZ !ScratchA
    LDA Hitboxes+1,y
    STA !Scratch4           ;$04 = Low X Offset
    BPL +
    LDA #$FF
    STA !ScratchA           ;$0A = High X offset
+

	STZ !ScratchB
    LDA Hitboxes+2,y
    STA !Scratch5           ;$05 = Low Y Offset
    BPL +
    LDA #$FF
    STA !ScratchB           ;$0B = High Y Offset
+

    LDA Hitboxes+3,y
    STA !Scratch6           ;$06 = Width

    LDA Hitboxes+4,y
    STA !Scratch7           ;$07 = Height

	PHY
	SEP #$10
	LDX !SpriteIndex

	LDA !SpriteXHigh,x
	XBA
	LDA !SpriteXLow,x
	REP #$20
	PHA
	SEP #$20

	LDA !ScratchA
	XBA
	LDA !Scratch4
	REP #$20
	CLC
	ADC $01,s
	PHA
	SEP #$20
	PLA 
	STA !Scratch4
	PLA
	STA !ScratchA
	PLA
	PLA

	LDA !SpriteYHigh,x
	XBA
	LDA !SpriteYLow,x
	REP #$20
	PHA
	SEP #$20

	LDA !ScratchB
	XBA
	LDA !Scratch5
	REP #$20
	CLC
	ADC $01,s
	PHA
	SEP #$20
	PLA 
	STA !Scratch5
	PLA
	STA !ScratchB
	PLA
	PLA

    JSL $03B72B|!rom
	REP #$10
	BCS ++
	PLY
	PLY
	INY
	JMP -
++
	PLY
	PLY
	LDA !ScratchE
	ORA #$01
	STA !ScratchE
	SEP #$10
	LDX !SpriteIndex
	SEC
	RTS

HitboxAdder:
    dw $0000,$0010

FrameHitboxesIndexer:
    dw $0000,$0002,$0004,$0006,$0008,$000A,$000C,$000E
	dw $0010,$0012,$0014,$0016,$0018,$001A,$001C,$001E

FrameHitBoxes:
    db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	

HitboxesStart:
    dw $0000,$0006

Hitboxes:
    db $01,$00,$F8,$10,$20,$00
	db $01,$00,$F8,$10,$20,$00
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine
DefaultAction:
	JSL $00F5B7|!BankB
RTS
    
;>End Hitboxes Interaction Section