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
!EXPLOISON_HURT = $38

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite init routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
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
  LDA !151C,x	; don't allow carry if switch is pressed
  BNE NoCarry
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
  LDA #$40				;; \ Set explode timer
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
	LDX #$05
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

	INY					; \ Increase 4 times, since we wrote a
	INY					; | 16x16 tile
	INY					; |
	INY					; /
	
	DEX
	BPL -

	LDX $15E9|!Base2
    LDY #$02                            ;all 16x16 tiles
    LDA #$05
    JSL $01B7B3|!BankB                  		;This insert the new tiles into the oam, 
	RTS

.PropertyTable
	db $35,$37,$39,$3B

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
  LDA #$09				; \ Play sound
  STA $1DFC|!Base2      ; /
  LDA #$9B				; \ Set Tweaker byte
  ;LDA #$1B
  STA !167A,x				; / (invincible, unkickable, no default interaction)
  LDA #$11				; \ Set Tweaker byte
  STA !1686,x				; / (inedible, interact with sprites)
  ;STA !1662,x

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