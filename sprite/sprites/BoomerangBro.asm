;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boomerang Bros.
;; By Sonikku
;; Description: Walks back and forth, frequently throwing 2 boomerangs in the
;; direction of the player and will attempt to catch them when they return.
;; Requires: Extended Sprites Extender
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BoomerangNumber = $00      ; Extended sprite number (from list.txt) of the boomerang (boomerang.asm).

TILEMAP:	db $48,$4A,$7F,$4e		;last byte is for hammer (all tables)
		db $48,$5A,$2F,$4e
		db $46,$4A,$7F,$4e
		db $46,$5A,$2F,$4e

HORZ_DISP:	db $00,$00,$08,$0A
		db $00,$08,$00,$F6

VERT_DISP:	db $F8,$08,$08,$F2

TILE_SIZE:	db $02,$00,$00,$02		;$00 - 8x8, $02 - 16x16

PROPERTIES:	db $40,$00			;actually only contains horizontal flip data, properties are set through CFG/json (except for the hammer).

		!HammerProp = #!Palette9|!SP3SP4

;don't touch, made so it's actually easy to change hardcoded prop without having to look up for help

!Palette8 = %00000000
!Palette9 = %00000010
!PaletteA = %00000100
!PaletteB = %00000110
!PaletteC = %00001000
!PaletteD = %00001010
!PaletteE = %00001100
!PaletteF = %00001110

!SP1SP2 = %00000000
!SP3SP4 = %00000001


print "INIT ",pc
    JSR FaceMario
    JSL $01ACF9|!BankB
    AND #$03
    STA !C2,x               ; randomize state
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    JSR SpriteCode
    PLB
    RTL

Return:
    RTS

; Workaround for sublabels.
%SubOffScreen()

SpriteCode:
    JSR Graphics

    LDA !14C8,x
    CMP #$08
    BNE Return                      ; sprite not normal = return.
    LDA $9D
    BNE Return                      ; sprites locked = return.

    %SubOffScreen()                 ; A guaranteed to be 0

    JSL $01802A|!BankB              ; sprite has gravity.
    JSL $01A7DC|!BankB              ; sprite interacts with mario.

    LDA !AA,x
    BMI .noCatch                    ; sprite won't catch when moving upward
    LDA $14
    AND #$03
    BNE .noCatch
    PHY
    LDY #$0A
-   LDA !1534,x
    CMP $0DF5|!Base2,y              ; state must be the same as the sprite's index.
    BNE +
    LDA $170B|!Base2,y
    CMP #$14
    BNE +
    LDA $171F|!Base2,y
    CLC : ADC #$04
    STA $00
    LDA $1733|!Base2,y
    ADC #$00
    STA $08
    LDA #$04
    STA $02
    LDA $1715|!Base2,y
    CLC : ADC #$08
    STA $01
    LDA $1729|!Base2,y
    ADC #$00
    STA $09
    LDA #$08
    STA $03
    JSL $03B69F|!BankB              ;  | check interaction.
    JSL $03B72B|!BankB              ; /
    BCC +
    LDA #$00
    STA $170B|!Base2,y
+   DEY
    BPL -
    PLY
.noCatch
    LDA !1588,x
    AND #$04
    BEQ +                           ; if sprite not on ground, branch.
    STZ !AA,x                       ; make sprite Y speed = #$00
+   LDA $14
    AND #$0F
    BNE +                           ; once every 16 frames..
    JSR FaceMario                   ; sprite faces mario.
+   LDA !C2,x                       ; $C2,x = sprite walking state.
    AND #$03                        ; can be 1 of 4 possibilities.
    ASL A
    TAX
    JMP.w (.pointers,x)

.pointers
    dw .walkStop                    ; #$00
    dw .walkRight                   ; #$01
    dw .walkStop                    ; #$02
    dw .walkLeft                    ; #$03

.walkStop
    LDX $15E9|!Base2
    LDA !1540,x                     ; when timer > #$00..
    BNE +                           ; .. branch.
    INC !C2,x                       ; increment $C2,x.
    LDA #$40
    STA !1540,x                     ; set walking timer to #$40.
+   STZ !B6,x                       ; clear out x speed otherwise.
    RTS

.walkRight
    LDX $15E9|!Base2
    LDA #$F8                        ; walk right.
    BRA +

.walkLeft
    LDX $15E9|!Base2
    LDA #$08                        ; walk left.
+   STA !B6,x                       ; apply x speed.

    INC !151C,x                     ; increment $151C,x (walking animation frame counter).

    LDA $14                         ; unless frame counter is #$00..
    BNE +                           ; branch.

    JSL $01ACF9|!BankB              ; get random number..
    EOR $13                         ; .. flip some bits to randomize more..
    AND #$01                        ; and make it one of two possibilites.
    BNE +                           ; ..if #$01, branch.

    LDA #$D0                        ; make a short hop..
    STA !AA,x                       ; .. and apply y speed.
    LDA #$28
    STA !1528,x
+
    LDA !1540,x                     ; whenever the timer..
    BNE +                           ; .. is zero..
    INC !C2,x                       ; .. we increment $C2,x (to the short pause in the sprite's walking pattern)..
    LDA #$10                        ; .. and set the timer.
    STA !1540,x
+   LDA !1570,x
    INC !1570,x                     ; increment a frame counter..
    AND #$BF                        ; do some ANDy stuff.
    CMP #$1F                        ; so it throws a boomerang twice.
    BNE +
    LDA #$0F                        ; set boomerang throw timer.
    STA !163E,x
+   LDA !151C,x                     ; get frame counter.
    LSR #3                          ; divide several times.
    AND #$01                        ; can be 1 of 2 possibilities.
    TAY                             ; transfer this result to Y.
    LDA !163E,x                     ; whenever the sprite isn't about to throw an extended sprite..
    BEQ +                           ; .. branch away.
    CMP #$01                        ; if the timer isn't #$01..
    BNE ++                          ; .. branch away.
    PHY
    JSR GenerateHammer              ; EVEN THOUGH I AM NOT THROWING A HAMMER.
    PLY
    BRA ++                          ; skip frame increments.

+   INY                             ; increment frame by 1..
    INY                             ; .. and by 1 more.
++  TYA                             ; transfer whatever is in the Y index to A..
    STA !1602,x                     ; .. and store to the sprite's frame.
    RTS

Graphics:
    %GetDrawInfo()

    LDA !1602,x
                ASL A
                ASL A                   ;  | $03 = index to frame start (frame to show * 2 tile per frame)
                STA $03                 ; /

                LDA !157C,x             ; \ $02 = sprite direction
                STA $02                 ; /

		LDA !15F6,x
		STA $05

                LDA !163E,x
                BEQ Pre_LOOP_START
		DEC
		BEQ Pre_LOOP_START

		LDX #$03		;load 4 tiles
		BRA After_Pre_LOOP_START

Pre_LOOP_START:
                LDX #$02                ;3 tiles if hammer isn't shown

After_Pre_LOOP_START:
		STX $04			;amount of tiles to store
		;STX $06		;store current OAM slot index used to eliminate most PHX : PLX combinations (because really)

LOOP_START:
		STX $06

		LDA $02
		BNE NO_ADJ
		;ASL
		;ASL
		TXA
		CLC : ADC #$04		;whoops, i kinda forgot how this works, this should be about right
	        TAX

NO_ADJ:
                LDA $00                 ; \ tile x position = sprite x location ($00)
                CLC
                ADC HORZ_DISP,x
                STA $0300|!Base2,y      ; /
                 
		LDX $06			;restore OAM slot
                                        
		LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
		CLC                     ;  |
		ADC VERT_DISP,x         ;  |
		STA $0301|!Base2,y      ; /
                    
		LDA TILE_SIZE,x
		PHA
		TYA                     ; \ get index to sprite property map ($460)...
		LSR A                   ; |    ...we use the sprite OAM index...
		LSR A                   ; |    ...and divide by 4 because a 16x16 tile is 4 8x8 tiles
		TAX                     ; | 
		PLA
		STA $0460|!Base2,x      ; /  

		LDX $06
		;PHX
		TXA                     ; \ X = index to horizontal displacement
		ORA $03                 ; / get index of tile (index to first tile of frame + current tile number)
		TAX
                                 
		LDA TILEMAP,x           ; \ store tile
		STA $0302|!Base2,y      ; / 

		LDX $06
		LDA !HammerProp
		CPX #$03		;check hammer tile to apply hardcoded prop
		BEQ .ItsHammer

		LDA $05            	; get palette info

.ItsHammer
		LDX $02                 ; \
		ORA PROPERTIES,x        ;  | get tile PROPERTIES using sprite direction
		ORA $64                 ;  | ?? what is in 64, level PROPERTIES... disable layer priority??
		STA $0303|!Base2,y      ; / store tile PROPERTIES

		LDX $06			;and restore OAM slot also

		INY                     ;  | increase index to sprite tile map ($300)...
		INY                     ;  |    ...we wrote 1 16x16 tile...
		INY                     ;  |    ...sprite OAM is 8x8...
		INY                     ;  |    ...so increment 4 times
		;DEC $06                 ;  | go to next tile of frame and loop
		DEX
		BPL LOOP_START          ; / 

		LDX $15E9|!Base2	;
                    
		LDY #$FF                ; \
		LDA $04			;  | A = number of tiles drawn - 1
		JSL $01B7B3|!BankB	; / don't draw if offscreen
		RTS                     ; RETURN

GenerateHammer:
    LDA !15A0,x
    ORA !186C,x
    BNE ++
    LDY #$07
-   LDA $170B|!Base2,y
    BEQ +
    DEY
    BPL -
++  RTS

+   LDA.b #!BoomerangNumber+!ExtendedOffset
    STA $170B|!Base2,y              ; ext. sprite number.
    LDA #$EA                        ; ext. sprite y speed.
    STA $173D|!Base2,y
    LDA !E4,x                       ; ext. sprite x position = same as sprite.
    STA $171F|!Base2,y
    LDA !14E0,x                     ; ext. sprite x position (high) = same as sprite.
    STA $1733|!Base2,y
    LDA !D8,x
    CLC : ADC #$F0                  ; ext. sprite y position = 16 pixels above sprite.
    STA $1715|!Base2,y
    LDA !14D4,x
    ADC #$FF                        ; ext. sprite y position (high) = sets the carry stuff.
    STA $1729|!Base2,y
    LDA #$00                        ; clear information.
    STA $1779|!Base2,y
    LDA #$40                        ; set timer before returning (can be changed for interesting results*).
    STA $176F|!Base2,y

;; * - I'd personally use a random number generator to make it so the boomerangs
;; go in slightly randomized patterns.

    LDA !157C,x                     ; set up ext. sprite direction.
    EOR #$01
    STA $1765|!Base2,y
    TAX
    LDA Hammer_X_Speed,x            ; set up ext. sprite speed.
    STA $1747|!Base2,y
    TXA
    LDX $15E9|!Base2
    STA $0DF5|!Base2,y              ; get sprite index and put into ext. sprite (using overworld sprite data becuase its unused during levels).
    STA !1534,x
    RTS

Hammer_X_Speed:
    db $E0,$20                      ; not recommended to change.

; Modified SubHorzPos; only uses needed information.
FaceMario:
    LDY #$00
    LDA $94
    SEC : SBC !E4,x
    LDA $95
    SBC !14E0,x
    BPL $01
    INY
    TYA
    STA !157C,x
    RTS
