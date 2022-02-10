;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sledge Bro
;; By Sonikku
;; Description: Walks back and forth, frequently throwing 2 hammers in the
;; direction of the player and will attempt to catch them when they return.

!HammerNumber = $02         ; Extended sprite number (from list.txt) of the hammer (hammer.asm).

!HammerSound = $00          ; Sound to play when throwing a hammer. $00 to disable.
!HammerBank = $1DFC

!GroundSound = $09          ; Sound to play when landing after a jump.
!GroundBank = $1DFC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
    JSR FaceMario
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

    %SubOffScreen()

    JSL $01A7DC|!BankB              ; sprite interacts with mario.
    JSR FaceMario                   ; sprite faces mario always.
    LDA !163E,x                     ; generate hammer sometimes.
    CMP #$01
    BNE .noHammer
    PHY
    JSR GenerateHammer
    PLY
.noHammer
    TXA
    ASL #3
    ADC $14
    AND #$3F                        ; smb3 did this to "spice things up" I guess.
    ORA !163E,x
    BNE +
        LDA #$10
        STA !163E,x                 ; set timer sometimes.
+   LDY #$00
    LDA !151C,x
    AND #$10
    BEQ +
        INY
+   LDA !163E,x                     ; show throwing frames if throwing timer is on.
    BEQ +
        INY #2
+   TYA
    STA !1602,x                     ; handle frame.
    LDA !1594,x                     ; branch if sprite isn't jumping.
    BEQ .notJump
    JSL $01801A|!BankB              ; \
    JSL $018022|!BankB              ;  | handle x/y speed and object interaction without gravity.
    JSL $019138|!BankB              ; /
    LDA !AA,x
    BMI +
    CMP #$70                        ; if y speed is above #$70 we branch.
    BCS .above
    BCC .positive
+   EOR #$FF
    INC A
.positive
    LSR #2                          ; all this does is do weird math..
    LDY !AA,x                       ; .. to make it fall faster.
    BPL +
        LSR #2
+   CLC : ADC #$01
    ADC !AA,x
    STA !AA,x
.above
    LDA !1588,x
    AND #$04
    BEQ +
    STZ !1594,x                     ; sprite isn't jumping now.
    LDA #$10
    STA $1887|!Base2                ; shake screen.
    LDA.b #!GroundSound
    STA.w !GroundBank|!Base2        ; set sound effect.
    JSR GroundSmoke                 ; show smoke.
    STZ !AA,x                       ; fix y speed.
    LDA $72                         ; if mario is on the ground..
    BNE +
        LDA #$40                    ; stun him.
        STA $18BD|!Base2
+   RTS

.notJump
    LDA !1534,x
    BEQ +
        DEC !1534,x
+   TXA
    ASL #4
    ADC $14
    AND #$7F
    BNE +
    JSL $01ACF9|!BankB              ; 1/4th chance to jump.
    AND #$03
    BNE +
    INC !1594,x                     ; set jumping state.
    LDA #$A8                        ; set y speed.
    STA !AA,x
    STZ !B6,x                       ; no x speed.
    RTS

+   LDA !C2,x
    AND #$03
    ASL A
    TAX
    JMP.w (.pointers,x)

.pointers
    dw .walkLeft
    dw .stopWalk
    dw .walkRight
    dw .stopWalk

.stopWalk
    LDX $15E9|!Base2
    LDA !1534,x
    BNE +
    INC !C2,x
    LDA #$40
    STA !1534,x
+   BRA .finish

.walkLeft
    LDX $15E9|!Base2
    LDY #$FC                        ; set left speed.
    BRA +

.walkRight
    LDX $15E9|!Base2
    LDY #$04                        ; set right speed.
+   LDA !1534,x
    BNE +
    INC !C2,x
    LDA #$20
    STA !1534,x
    TYA
    STA !B6,x
.finish
    JSL $01802A|!BankB              ; handle x/y speed with gravity.
    LDA !1588,x
    AND #$04
    BEQ +
    LDA !B6,x
    BEQ .noAnim
    INC !151C,x                     ; only show animation when moving.
.noAnim
    LDA !AA,x
    BMI +
        STZ !AA,x                   ; no y speed unless moving upwards.
+   RTS

Graphics:
    %GetDrawInfo()

    LDA !157C,x
    ASL #2
    STA $02

    LDA !1602,x
    ASL #2
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
    ASL #2
    STA $05

    LDA !163E,x
    BEQ .noHammer
    CMP #$01
    BEQ .noHammer
    PHX
    LDX #$FC                        ; hammer x position
    LDA $02
    BEQ +
        LDX #$14                    ; hammer x position
+   TXA
    CLC : ADC $00
    STA $0300|!Base2,y

    LDA $01
    CLC : ADC #$E9                  ; hammer y position
    STA $0301|!Base2,y

    LDA #$6D                        ; hammer tilemap
    STA $0302|!Base2,y

    LDA #$07
    LDX $02
    BNE .noFlip
    ORA #$40
.noFlip
    ORA $64
    STA $0303|!Base2,y
    BRA ++

+   LDA #$F0                        ; hide hammer
    STA $0301|!Base2,y
++  INY #4
    PLX
.noHammer
    PHX
    LDX #$03
-   PHX
    TXA
    CLC : ADC $02
    TAX
    LDA $00
    CLC : ADC X_Disp,x
    STA $0300|!Base2,y
    PLX

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
    LDA #$04
    JSL $01B7B3|!BankB
    RTS

X_Disp:
    db $0C,$04,$0C,$04
    db $04,$0C,$04,$0C

Y_Disp:
    db $F0,$F0,$00,$00
    db $00,$00,$F0,$F0

Tilemap:
    db $89,$8A,$C4,$C5
    db $89,$8A,$C7,$C8
    db $86,$87,$C4,$C5
    db $86,$87,$C7,$C8

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

+
    if !HammerSound != $00
        LDA.b #!HammerSound
        STA.w !HammerBank|!Base2
    endif

    LDA.b #!HammerNumber+!ExtendedOffset
    STA $170B|!Base2,y
    LDA !E4,x
    CLC : ADC #$08
    STA $171F|!Base2,y
    LDA !14E0,x
    ADC #$00
    STA $1733|!Base2,y
    LDA !D8,x
    CLC : ADC #$EC
    STA $1715|!Base2,y
    LDA !14D4,x
    ADC #$FF
    STA $1729|!Base2,y
    LDA #$D0
    STA $173D|!Base2,y
    PHX
    LDA !157C,x
    TAX
    LDA Hammer_X_Speed,x
    PLX
    STA $1747|!Base2,y
    RTS

Hammer_X_Speed:
    db $12,$EE                      ; not recommended to change.

GroundSmoke:
    LDA !15A0,x
    ORA !186C,x
    BNE .noSmoke
    LDA #$FC
    STA $00
    JSR +
    LDA #$14
    STA $00
+   LDY #$03
-   LDA $17C0|!Base2,y
    BEQ +
    DEY
    BPL -
    RTS

+   LDA #$01
    STA $17C0|!Base2,y
    LDA !D8,x
    CLC : ADC #$08
    STA $17C4|!Base2,y
    LDA #$1B
    STA $17CC|!Base2,y
    LDA !E4,x
    CLC : ADC $00
    STA $17C8|!Base2,y
    LDX $15E9|!Base2
.noSmoke
    RTS

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
