;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!RAM_AirMeter = $1415|!Base2 ;>1 byte

	;;Possible values for the below variables:
	;;   (fast) $00, $01, $03, $07, $0f, $1f, $3f, $7f, $ff (slow)
	!CountDownFrequency = $00
	!CountUpFrequency = $00

	!Type = 2
	;*0 = only water drains the bar.
	;*1 = only a custom freeram drains the bar.
	;*2 = both water and freeram drains the bar.

	!Freeram_Drainbar = $1416|!Base2 ;>[1 byte]
	;^format ------AD
	;D = If set, clear itself and set bit A (so that it stops when a code stops
	;writing this), otherwise if already clear, only clear bit A.
	;A = The actual flag that determines should the bar drain.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;; INIT and MAIN routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print "INIT ",pc
	LDA #$FF            ;\Start meter full.
	STA !RAM_AirMeter   ;/
	STZ !1540,x
	RTL

	print "MAIN ",pc
	PHB                ;\Preserve bank data location for loading tables
	PHK                ;|
	PLB                ;/
	JSR MainSub
	PLB                ;>Restore data location
	RTL
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprite Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MainSub:
	LDA !RAM_AirMeter	; Play warning sounds
	CMP #$1C                ;\Make sound on certain values
	BEQ Sound               ;|(you cannot store sfx every frame)
	CMP #$14                ;|
	BEQ Sound               ;|
	CMP #$0C                ;|
	BNE NoSound             ;/
Sound:	
	LDA #$2a                ;\Incorrect sound
	STA $1DFC|!Base2               ;/
NoSound:
	LDA !RAM_AirMeter       ;\Display gfx if not 100%
	INC                     ;|>The meter uses a value between $00 -> $FF actually...
	ORA !1540,x             ;|>If meter is full or the timer is zero, hide bar.
	BEQ NoGfx

	JSR SubGfx		; Draw the sprite
NoGfx:	

	LDA $9D			;\Return if sprites are locked
	BNE Return              ;/
if !Type == 0
	LDA $75                 ;\Refill if player out of water
	BEQ CountUp             ;/
endif
if !Type == 1
DrainFlag:
	LDA !Freeram_Drainbar
	AND.b #%00000001        ;>Check if the first flag is set
	BNE .FlagSet            ;>If it is, then clear itself and...
.FlagClear
	LDA !Freeram_Drainbar   ;\Clear the bit that determines should
	AND.b #%11111101        ;|the bar drain (only clear the actual flag).
	BRA .SetDrainBarFlg     ;/
.FlagSet
	LDA !Freeram_Drainbar
	ORA.b #%00000010          ;>...Set bit 1 (the actual flag)
	AND.b #%11111110          ;>Clear bit 0 (clear itself)
.SetDrainBarFlg
	STA !Freeram_Drainbar

Determine:
	LDA !Freeram_Drainbar     ;\refill if flag is clear.
	AND.b #%00000010          ;|
	BEQ CountUp               ;/
endif
if !Type >= 2
WaterAndOrRam:
	LDA $75                   ;\If you are not in water,
	BEQ .CheckRAMFlg          ;/check the other factor that drains the bar
	BRA CountDown             ;>If in water, count down

.CheckRAMFlg
	LDA !Freeram_Drainbar
	AND.b #%00000001        ;>Check if the first flag is set
	BNE .FlagSet            ;>If it is, then clear itself and...
.FlagClear
	LDA !Freeram_Drainbar   ;\Clear the bit that determines should
	AND.b #%11111101        ;|the bar drain (only clear the actual flag).
	BRA .SetDrainBarFlg     ;/
.FlagSet
	LDA !Freeram_Drainbar
	ORA.b #%00000010          ;>...Set bit 1 (the actual flag)
	AND.b #%11111110          ;>Clear bit 0 (clear itself)
.SetDrainBarFlg
	STA !Freeram_Drainbar

Determine:
	LDA !Freeram_Drainbar     ;\refill if flag is clear.
	AND.b #%00000010          ;|
	BEQ CountUp               ;/
endif

CountDown:
;(In water, drain bar)
	LDA $13                   ;\Certain frames makes the bar drain
	AND #!CountDownFrequency  ;|
	BNE Return                ;/

	LDA !RAM_AirMeter         ;\Drain the bar
	DEC A                     ;/
	BNE SetMeter              ;>If not zero, continue draining
	JSL $00F606               ;>Kill player (don't decrement to -1 ($FF))
	RTS
	
CountUp:
	LDA $13                   ;\Certain frames fills up the bar
	AND #!CountUpFrequency    ;|
	BNE Return                ;/
	
	LDA !RAM_AirMeter         ;\Fill bar
	INC                       ;/
	BEQ Return                ;>If $FF -> $00, return ($FF is 100%).

	LDA #$48                  ;\Timer to display full bar before disappearing
	STA !1540,x               ;/
	
	LDA !RAM_AirMeter
	INC A
	;; 	LDA #$FF		; NOTE: Reinstate to make the meter instantly reset when not in water
SetMeter:	
	STA !RAM_AirMeter
	
Return:	
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteTileDispX:
		db $00,$08,$10,$18,$20,$27
SpriteTileDispY:
		db $20,$18,$10,$08,$00,$F9
SpriteTileDispYHigh:
		db $00,$00,$00,$00,$00,$FF
SpriteGfxProp:
		db $80,$00,$00,$00,$00,$00

Palettes:
		;db $09,$05,$0B ;>Leave the semicolon before the db there.

		db %00111001, %00110101, %00111011

;^Color the bar will be based on how much fill, order: %LLLLLLLL, %MMMMMMMM, %HHHHHHHH
;L = "danger!" (red), M = "caution" (yellow), H = "OK" (green).
;These are tile properties by the way: YXPPCCCT

AirBarPositionYoshi:
		db $14,$1C,$1C
;^X position of the bar relative to player. The first number is the normal x position,
;the last two is with riding yoshi. Also applies to carrying sprites.

SubGfx:	JSR GetPalette
	;LDA !15F6,x		; NOTE: Reinstate to use the palette from the cfg file
	STA $02
	
	LDA !RAM_AirMeter	; Load address to be timed
	LSR                   ;\-----xxx where x is deleted
	LSR                   ;|(divide by 8; rounded down)
	LSR                   ;/
	STA $03               ;>The amount of fill (number of full 8x8s)
	
	LDY !15EA,x	     ; get offset to sprite OAM			   

	PHX
	LDX #$05
GfxLoopStart:
	PHX
	LDA $1470|!Base2
	ORA $148F|!Base2
	BEQ .CheckYoshi
	TAX
	BRA .SetPos
.CheckYoshi
	LDX $187A|!Base2
.SetPos
	LDA $7E
	CLC
	ADC AirBarPositionYoshi,x
	STA $0300|!Base2,Y
	PLX

	PHY                     ;>Preserve Y index (OAM offset)
	PHP                     ;>save processor flag
	TYA                     ;>Transfer to A
	LSR                     ;\Divide by 4
	LSR                     ;/(LSR only works on A)
	TAY                     ;>Transfer back to A
	PLP                     ;>load processor flag (LSR can effect the carry flag)
	LDA #$00                ;>Load #$00 into A
	BCS Set1                ;>If the restored carry flag is set, INC the OAM
	BIT $7F                 ;\Probably handles of the x position is off-screen
	BEQ Not1                ;/(greater than #$0100)
Set1:	INC
Not1:	STA $0460|!Base2,y
	PLY
	
	LDA $80                 ;>Y position of player on-screen
	CLC
	ADC SpriteTileDispY,x   ;>Move Y position to place tile
	XBA
	LDA $81                 ;>Player Y pos on-screen high byte
	ADC SpriteTileDispYHigh,x ;>Y high byte of sprite tile on-screen
	XBA                       ;>Swap high and low bytes of A
	REP #$20
	PHA
	CLC
	ADC.w #$0010
	CMP.w #$0100
	PLA
	SEP #$20
	BCS NoTile
	STA $0301|!Base2,Y

	LDA $03
	JSR CalculateTile
	STA $0302|!Base2,Y
	
	LDA $02
	ORA SpriteGfxProp,x
	ORA #$20
	STA $0303|!Base2,Y
	
NoTile:	INY              ;\Each sprite OAM has 4 bytes of info:
	INY              ;|xxxxxxxx yyyyyyyy tttttttt yxppccct.
	INY              ;|
	INY              ;/

	DEX              ;>Next index
	BPL GfxLoopStart ;>Loop if 0 or positive
	
	PLX              ;>Restore sprite slot index.
	RTS

GetPalette:
	LDY #$00         ;>Start at color index 0 ()
	LDA !RAM_AirMeter
	CMP #$55
	BCC LoadPalette
	INY              ;>Next color
	CMP #$AA
	BCC LoadPalette
	INY
LoadPalette:
	LDA Palettes,y
	RTS	
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
CalculateTile:
	CPX #$00          ;\End tiles
	BEQ EndPiece      ;|
	CPX #$05          ;|
	BEQ EndPiece      ;/

	PHA               ;\save A, transfer X to A
	TXA               ;/
	DEC A             ;>Decrement "index"
	ASL               ;\Times 8
	ASL               ;|
	ASL               ;/
	STA $00           ;>$00 is part of the tile indexing
	PLA               ;>Restore A

	SEC               ;\Subtract by tile index
	SBC $00           ;/
	BMI EmptyTile     ;>If negative, empty tile (you cannot have -1 out of 8)
	
	CMP #$08          ;\Each 8x8 have a maximum of 8 "fill units" or pixels.
	BCS FullTile      ;/This is how the fraction tile "moves" to another 8x8.

	AND #$07          ;>Modulo by 8 (fraction tile, after full 8x8s)
	CLC
	ADC #$47
	CMP #$4B
	BCC Return0
	CLC
	ADC #$0C
Return0:
	RTS

FullTile:
	LDA #$46          ;>Full 8x8s
	RTS
EmptyTile:
	LDA #$47          ;>Empty 8x8s
	RTS
EndPiece:
	LDA #$56          ;>End of bar
	RTS