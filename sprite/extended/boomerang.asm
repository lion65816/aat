;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boomerang:
;; Flies to the left or right depending on direction thrown,
;; then flies back toward the direction it was thrown.
;; Can be caught by the Boomerang Bros.

print "MAIN ",pc
Boomerang:
    JSR Graphics

    LDA $9D
    BNE Return

    %SpeedNoGrav()
    %ExtendedHurt()

    INC $0E05|!Base2,x
    LDA $176F|!Base2,x              ; if timer isn't zero, branch.
    BNE NoDecrement

    LDA $1765|!Base2,x
    TAY
    LDA $1747|!Base2,x              ; accelerate sprite based on "direction."
    CMP X_Speed_Max,y
    BEQ NoDecrement
    LDA $1747|!Base2,x
    CLC : ADC X_Accel,y
    STA $1747|!Base2,x
NoDecrement:
    LDA $14                         ; run every other frame.
    LSR A
    BCS Return
    LDA $1779|!Base2,x
    CMP #$01
    BCS ++
    LDA $1779|!Base2,x              ; increment/decrement y speed based on stuff.
    AND #$01
    TAY
    LDA $173D|!Base2,x
    CMP Y_Speed_Max,y
    BNE +
        INC $1779|!Base2,x
+   LDA $173D|!Base2,x
    CLC : ADC Y_Accel,y
    STA $173D|!Base2,x
    RTL

++  LDA $173D|!Base2,x
    BEQ Return
    DEC $173D|!Base2,x              ; decrement timer used by the x speed.
Return:
    RTL

X_Accel:
    db $01,$FF

X_Speed_Max:
    db $20,$E0

Y_Accel:
    db $01,$FF

Y_Speed_Max:
    db $12,$EE

Graphics:
    %ExtendedGetDrawInfo()

    LDA $1747|!Base2,x
    STA $03

    LDA $0E05|!Base2,x              ; get frame based on $0E05,x
    LSR #2
    AND #$03
    PHX
    TAX

    LDA $01
    STA $0200|!Base2,y

    LDA $02
    STA $0201|!Base2,y

    LDA Tilemap,x
    STA $0202|!Base2,y

    LDA #$09                        ; palette
    PHY
    TXY
    LDX $03                         ; flip based on direction.
    BPL +
        INY #4
+   ORA Properties,y                ; set properties.
    ORA $64
    PLY
    STA $0203|!Base2,y

    TYA
    LSR #2
    TAX
    LDA #$02
    STA $0420|!Base2,x
    PLX
    RTS

Properties:
    db $40,$40,$80,$80
    db $00,$00,$C0,$C0

Tilemap:
    db $E8,$EA,$E8,$EA
