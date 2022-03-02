;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hammer Bros.
;; By Sonikku
;; Description: Walks back and forth, frequently throwing hammers in Mario's
;; direction and jumps between blocks.

!HammerNumber = $02         ; Extended sprite number (from list.txt) of the hammer (hammer.asm).

!HammerSound = $00          ; Sound effect to play when throwing a hammer (set to $00 to disable).
!HammerBank = $1DFC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
    JSR FaceMario
    LDA #$20
    STA !1540,x
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    JSR SpriteCode
    PLB
    RTL

Return:
    RTS

SpriteCode:
    JSR Graphics

    LDA !14C8,x
    CMP #$08
    BNE Return                      ; sprite not normal = return.

    JSR FaceMario                   ; sprite faces mario always.

    LDA $9D
    BNE Return                      ; sprites locked = return.

    %SubOffScreen()                 ; A guaranteed to be 0

    JSL $01A7DC|!BankB              ; sprite interacts with mario.

    LDY #$00
    LDA !1540,x                     ; if timer is nonzero, sprite doesn't interact with objects.
    BEQ +
        LDY #$80
+   TYA
    STA !1686,x
    INC !1570,x                     ; increment $1570,x
    LDY #$06
    LDA !1570,x
    AND #$40
    BNE +
        LDY #$FA
+   STY !B6,x
    LDA !1588,x
    AND #$04
    BEQ +
    INC !151C,x
    LDA !1540,x
    BNE ++
    STZ !AA,x
+   LDA !15AC,x
    BNE ++
    JSL $01ACF9|!BankB
    AND #$3E
    ADC #$C0
    STA !15AC,x                     ; set $15AC,x to a random value.
    JSL $01ACF9|!BankB              ; randomize y speeds.
    AND #$02
    TAY
    LDA !14D4,x
    XBA
    LDA !D8,x
    REP #$20
    CMP #$0150                      ; y coordinate in which hammer bros. refuse to jump below.
    SEP #$20
    BCC +
    TYA
    BNE +
        LDY #$01
+   LDA .yspd,y
    STA !AA,x
    LDA .reload,y
    STA !1540,x
++  JSL $01802A|!BankB              ; update x/y position based on speed.
    LDA $14
    AND #$07
    BEQ +
        INC !1528,x
+   LDY #$3F
    LDA !1588,x
    AND #$04
    BEQ +
        LDY #$1F
+   TYA
    AND !1528,x
    CMP #$1F
    BNE +
    LDA !163E,x                     ; only set throwing hammer timer if sprite is on ground.
    BNE +
    LDA #$0F
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
    JSR GenerateHammer              ; throw hammer.
    PLY
    BRA ++                          ; skip frame increments.

+   INY                             ; increment frame by 1..
    INY                             ; .. and by 1 more.
++  TYA                             ; transfer whatever is in the Y index to A..
    STA !1602,x                     ; .. and store to the sprite's frame.
    RTS

.yspd       db $D0,$00,$A0
.reload     db $28,$00,$20

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
    LDX #$F8                        ; hammer x position
    LDA $02
    BEQ +
        LDX #$08                    ; hammer x position
+   TXA
    CLC : ADC $00
    STA $0300|!Base2,y

    LDA $01
    CLC : ADC #$F0                  ; hammer y position
    STA $0301|!Base2,y

    LDA #$6D                        ; hammer tilemap
    STA $0302|!Base2,y

    LDX $02
    LDA .hammerFlip,x
    ORA $64
    STA $0303|!Base2,y
    BRA ++
+   LDA #$F0                        ; hide hammer
    STA $0301|!Base2,y
++  INY #4
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
    CLC : ADC .ypos,x               ; y position determined by dead/alive state.
    STA $0301|!Base2,y
    PLX

    PHX
    TXA
    CLC : ADC $03
    TAX
    LDA .tilemap,x                  ; tilemap determined by $1602,x.
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

.ypos
    db $F0,$00,$08,$F8

.tilemap
    db $20,$40,$22,$42,$24,$44,$2B,$4B

.hammerFlip
    db $47,$07

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

    LDA.b #!HammerNumber+!ExtendedOffset    ; ext. sprite number.
    STA $170B|!Base2,y
    LDA #$D0                    ; ext. sprite y speed.
    STA $173D|!Base2,y
    LDA !E4,x                   ; ext. sprite x position = same as sprite.
    STA $171F|!Base2,y
    LDA !14E0,x                 ; ext. sprite x position (high) = same as sprite.
    STA $1733|!Base2,y
    LDA !D8,x
    CLC : ADC #$F0              ; ext. sprite y position = 16 pixels above sprite.
    STA $1715|!Base2,y
    LDA !14D4,x
    ADC #$FF                    ; ext. sprite y position (high) = sets the carry stuff.
    STA $1729|!Base2,y

    LDA #$08                    ; clear information.
    STA $1779|!Base2,y

    LDA !157C,x
    TAX
    LDA .xspd,x                 ; set x speed based on direction.
    STA $1747|!Base2,y
    LDX $15E9|!Base2
    RTS

.xspd
    db $12,$EE                  ; not recommended to change.

;; Modified SubHorzPos; only uses needed information.
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
