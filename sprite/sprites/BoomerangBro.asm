;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boomerang Bros.
;; By Sonikku
;; Description: Walks back and forth, frequently throwing 2 boomerangs in the
;; direction of the player and will attempt to catch them when they return.
;; Requires: Extended Sprites Extender
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BoomerangNumber = $00      ; Extended sprite number (from list.txt) of the boomerang (boomerang.asm).

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

    LDA !157C,x
    STA $02

    LDA !1602,x
    ASL A
    STA $03

    PHY
    LDY #$00
    LDA !14C8,x
    CMP #$08
    BEQ +
        LDY #$01
+   TYA
    PLY
    STA $04
    ASL A
    STA $05

    LDA !163E,x
    BEQ .noHammer
    CMP #$01
    BEQ .noHammer
    PHX
    LDX #$F8                        ; boomerang x position
    LDA $02
    BEQ +
        LDX #$08                    ; boomerang x position
+   TXA
    CLC : ADC $00
    STA $0300|!Base2,y

    LDA $01
    CLC : ADC #$F0                  ; boomerang y position
    STA $0301|!Base2,y

    LDA #$EA                        ; boomerang tilemap
    STA $0302|!Base2,y

    LDX $02
    LDA BoomerangFlip,x
    ORA $64
    STA $0303|!Base2,y
    INY #4
    PLX
.noHammer
    PHX
    LDX #$01
-   LDA $00
    STA $0300|!Base2,y

    PHX
    TXA
    CLC : ADC $05
    TAX
    LDA $01
    CLC : ADC Y_Disp,x              ; y position determined by dead/alive state.
    STA $0301|!Base2,y
    PLX

    PHX
    TXA
    CLC : ADC $03
    TAX
    LDA Tilemap,x                   ; tilemap determined by $1602,x.
    STA $0302|!Base2,y
    PLX

    PHX
    LDX $15E9|!Base2
    LDA !15F6,x                     ; palette based on cfg file.
    PHX
    LDX $02
    BNE +
        ORA #$40                    ; flip by x if $157C,x = #$00
+   LDX $04
    BEQ +
        ORA #$80                    ; flip by y if $14C8,x = #$02 (dead)
+   PLX
    ORA $64                         ; apply level settings
    STA $0303|!Base2,y
    PLX

    INY #4

    DEX
    BPL -
    PLX

    LDY #$02
    LDA #$02
    JSL $01B7B3|!BankB
    RTS

Y_Disp:
    db $F0,$00,$08,$F8

Tilemap:
    db $A2,$C2
    db $A2,$E2
    db $A2,$C0
    db $A2,$E0

BoomerangFlip:
    db $89,$C9

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
