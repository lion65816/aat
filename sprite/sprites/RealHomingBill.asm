;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Real Homing Bill
; by 33953YoShI (Akaginite)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This sprite will aim to Mario.
;                                                       Default
; Extra Property Byte 1: moving speed         [Slow $01 - $18 - $FF Fast]
; Extra Propetry Byte 2: accuracy of aiming   [Low  $01 - $04 - $FF High]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Uses first extra bit: YES
; This sprite will explode when a period of time passes.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Use16Frames = 0            ; Set to 0 if you want the sprite to only use 8 frames
                            ; If set, requires the SP4 graphics, too.

!TickSFX = $23              ;\ Sound effect to play when the sprite ticks
!TickBank = $1DFC           ;/

!ExplodeSFX = $09           ;\ Sound effect to play when the sprite explodes
!ExplodeBank = $1DFC        ;/

!InitialTickTime = 255
!TickTime = 60

!TickCount = $03

if !Use16Frames == 0
    Tilemap:
        db $A6,$A6,$A2,$A6,$A6,$A4,$A2,$A4
        ;db $A6,$A8,$A4,$A8,$A6,$A6,$A4,$A6
    Properties:
        db $72,$73,$B3,$33,$32,$73,$33,$33
        ;db $42,$43,$83,$03,$02,$43,$03,$03
        ;db $40,$41,$81,$01,$00,$41,$01,$01
else
    Tilemap:
        db $A6,$67,$A8,$69,$A4,$69,$A8,$67
        db $A6,$42,$A6,$44,$A4,$44,$A6,$42
    Properties:
        db $40,$41,$41,$41,$81,$01,$01,$01
        db $00,$41,$41,$41,$01,$01,$01,$01
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!sprite_tick = !C2
!sprite_tick_timer = !1558
!sprite_back_dist_low = !1534
!sprite_back_dist_high = !1528
!sprite_angle_dist_low = !1594
!sprite_angle_dist_high = !1FD6
!sprite_angle_low = !1504
!sprite_angle_high = !151C
!sprite_accuracy = !1510

!GetSin = $07F7DB|!BankB
!GetCos = $07F7DB|!BankB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
InitCode:
    LDA #$02
    STA !sprite_angle_dist_high,x
    LDA.b #!InitialTickTime
    STA !sprite_tick_timer,x
    LDA !extra_prop_2,x
    STA !sprite_accuracy,x
    LDA #$00
    STA !extra_prop_2,x
    LDA #!TickCount
    STA !sprite_tick,x
    LDA !sprite_back_dist_high,x
    ORA !sprite_back_dist_low,x
    BNE .Return
    LDA $94
    CMP !E4,x
    LDA $95
    SBC !14E0,x
    BPL .Return
    INC !sprite_angle_high,x
.Return
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    JSR MainCode
    PLB
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Workaround for sublabels; wastes 8 bytes, but ensures the sprite assembles.
%SubOffScreen()
%GetDrawInfo()

MainCode:
    JSR Graphics
    LDY $9D
    BNE .Return
    LDA #$00
    %SubOffScreen()
    LDA !14C8,x
    CMP #$08
    BEQ .Normal
.Dying
    STZ !sprite_back_dist_high,x
    STZ !sprite_back_dist_low,x
    LDY #$00
    LDA !B6,x
    BPL +
        DEY
+   STA $00
    STY $01

    LDY #$00
    LDA !AA,x
    BPL +
        DEY
+   STA $02
    STY $03
    ORA !B6,x
    BEQ .Return

    JSR GetAngle
    LDA $00
    STA !sprite_angle_low,x
    LDA $01
    STA !sprite_angle_high,x
.Return
    RTS

.Normal
    %BEC(.SkipTick)
    LDA !sprite_tick_timer,x
    BNE .SkipTick
    DEC !sprite_tick,x
    BPL .SetTick
    LDA.b #!ExplodeSFX
    STA.w !ExplodeBank|!Base2
    JMP GenExplode

.SetTick
    LDA.b #!TickTime
    STA !sprite_tick_timer,x
    LDA.b #!TickSFX
    STA.w !TickBank|!Base2
.SkipTick
    LDA !sprite_angle_low,x
    STA $0E
    LDA !sprite_angle_high,x
    STA $0F

    LDA !sprite_angle_dist_high,x
    ORA !sprite_angle_dist_low,x
    BNE .SkipUpdate
    LDA !sprite_accuracy,x
    BEQ .SkipUpdate
    LDA $D1
    SEC : SBC !E4,x
    STA $00
    LDA $D2
    SBC !14E0,x
    STA $01

    LDA $D3
    SEC : SBC !D8,x
    XBA
    LDA $D4
    SBC !14D4,x
    XBA
    REP #$21
    ADC.w #$0010
    STA $02
    SEP #$20
    JSR GetAngle
    LDA !sprite_accuracy,x
    REP #$30
    AND.w #$00FF
    STA $02
    LDA $0E
    SEC : SBC $00
    BIT.w #$0100
    BEQ .IfPlus
    CLC                 ;\ CMP -$02 => ADD --$02 => ADD $02
    ADC $02             ;/
    BCC +
    LDA $00
    BRA .StoreAngle

+   LDA $0E
    ADC $02
    BRA ++

.IfPlus
    CMP $02
    BCS +
    LDA $00
    BRA .StoreAngle

+   LDA $0E
    SBC $02
++  AND.w #$01FF
.StoreAngle
    STA $0E
    SEP #$20
    STA !sprite_angle_low,x
    XBA
    STA !sprite_angle_high,x

.SkipUpdate
    if !SA1 == 0
        LDA !extra_prop_1,x
        STA $4202
    else
        STZ $2250
        LDA !extra_prop_1,x
    endif

    STA $0A
    REP #$31
    AND.w #$00FF
    ASL #4

    if !SA1 == 0
        STA $08
    else
        STA $2251
    endif

    LDA $0E
    ADC.w #$0080
    AND.w #$01FF
    TAY
    AND.w #$00FF
    ASL A
    TAX
    LDA.l !GetCos,x

    if !SA1 == 0
        CMP.w #$0100
        STA $4203
        LDX $15E9|!Base2
        LDA $08
        BCS .SkipCos
        LDA $4216
        LSR #4
    .SkipCos
        CPY.w #$0100
        LDY.w #$0000
        BCC .NotNegCos
        EOR.w #$FFFF
        DEY
    .NotNegCos
        SEP #$30
        ADC !14EC,x
        STA !14EC,x
        XBA
        ADC !E4,x
        STA !E4,x
        TYA
    else
        CPY.w #$0100
        BCC +
        EOR.w #$FFFF
        INC A
        CLC
+       STA $2253
        SEP #$30
        LDX.w $15E9|!Base2
        LDA $2307
        ADC !14EC,x
        STA !14EC,x
        LDA $2308
        ADC !E4,x
        STA !E4,x
        LDA $2309
    endif

    ADC !14E0,x
    STA !14E0,x
    REP #$30

    LDA $0E
    TAY
    AND.w #$00FF
    ASL A
    TAX
    LDA.l !GetSin,x

    if !SA1 == 0
        CMP.w #$0100
        STA $4203
        LDX $15E9|!Base2
        LDA $08
        BCS .SkipSin
        LDA $4216
        LSR #4
    .SkipSin
        CPY.w #$0100
        LDY.w #$0000
        BCC .NotNegSin
        EOR.w #$FFFF
        DEY
    .NotNegSin
        SEP #$30
        ADC !14F8,x
        STA !14F8,x
        XBA
        ADC !D8,x
        STA !D8,x
        TYA
    else
        CPY.w #$0100
        BCC +
        EOR #$FFFF
        INC A
        CLC
+       STA $2253
        SEP #$30
        LDX.w $15E9|!Base2
        LDA $2307
        ADC !14F8,x
        STA !14F8,x
        LDA $2308
        ADC !D8,x
        STA !D8,x
        LDA $2309
    endif

    ADC !14D4,x
    STA !14D4,x

    SEC
    LDA !sprite_angle_dist_low,x
    ORA !sprite_angle_dist_high,x
    BEQ ++
    LDA !sprite_angle_dist_low,x
    SBC $0A
    BCS +
    SEC
    DEC !sprite_angle_dist_high,x
    BPL +
    LDA #$00
    STA !sprite_angle_dist_high,x
+   STA !sprite_angle_dist_low,x

++  LDA !sprite_back_dist_low,x
    ORA !sprite_back_dist_low,x
    BEQ ++
    LDA !sprite_back_dist_low,x
    SBC $0A
    BCS +
    DEC !sprite_back_dist_high,x
    BPL +
    LDA #$00
    STA !sprite_back_dist_high,x
+   STA !sprite_back_dist_low,x

++  JSL $01A7DC|!BankB
    RTS

GenExplode:
    LDA #$0D
    STA !9E,x
    JSL $07F7D2|!BankB
    LDA #$08
    STA !14C8,x
    LDA #$01
    STA !1534,x
    LDA #$30
    STA !1540,x
    LDA !1656,x
    ORA #$80
    STA !1656,x
    LDA !167A,x
    ORA #$02
    STA !167A,x
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Graphics:
    %GetDrawInfo()
    LDA $00
    STA $0300|!Base2,y
    LDA $01
    STA $0301|!Base2,y
    LDA !15F6,x
    LDY !sprite_tick,x
    CPY.b #!TickCount
    BEQ +
    AND #$01
    STA $02
    LDA $14
    AND #$0E
    ORA $02
+   LDY !sprite_back_dist_high,x
    BNE .Back
    LDY !sprite_back_dist_low,x
    BEQ .Front
.Back
    ORA #$10
    BRA ++

.Front
    ORA $64
++  STA $02
    LDA !sprite_angle_high,x
    XBA
    LDA !sprite_angle_low,x
    REP #$21

    if !Use16Frames == 0
        ADC.w #$0020
        ASL #2
        XBA
        SEP #$20
        AND #$07
    else
        ADC.w #$0010
        ASL #3
        XBA
        SEP #$20
        AND #$0F
    endif

    LDY !15EA,x
    TAX
    LDA.w Tilemap,x
    STA $0302|!Base2,y
    LDA.w Properties,x
    ;EOR $02
    STA $0303|!Base2,y
    LDX $15E9|!Base2
    LDA #$00
    LDY #$02
    JSL $01B7B3|!BankB
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GetAngle - Low precision version (x0.5)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetAngle:
    REP #$20
    LDY #$00
    LDA $00             ;\ 
    BPL .X_Plus         ; |
    LDY #$04            ; |
    EOR.w #$FFFF        ; | Get absolute value of X
    INC A               ; |
    STA $00             ;/
.X_Plus
    LDA $02             ;\ 
    BPL .Y_Plus         ; |
    INY #2              ; |
    EOR.w #$FFFF        ; | Get absolute value of Y
    INC A               ; |
    STA $02             ;/
.Y_Plus
    CMP $00             ;\ If X is smaller than Y...
    BCC +               ;/
    STA $04             ;\ 
    LDA $00             ; |
    STA $02             ; | swap X and Y.
    LDA $04             ; |
    STA $00             ; |
    INY                 ;/
+   STY $06
    LDA $02
    STA $04
    STZ $02
    ORA $00
    AND.w #$FF00
    BEQ .Next
    XBA
-   LSR $00
    LSR $04
    ROR $02
    LSR A
    BNE -
.Next
    if !SA1 == 0
        LDY $00
        BEQ .DivZero
        LDA $03
        STA $4204
        STY $4206
        SEP #$20            ;\ 
        STZ $01             ; |
        LDA #$40            ; | Wait 16 cycles...
        CPY $03             ; |
        BEQ +               ; |
        BRA $00             ;/
        LDA $4214
        LSR A
    else
        LDY #$01
        STY $2250
        LDA $03
        STA $2251
        LDA $00
        BEQ .DivZero
        STA $2253
        SEP #$20            ;\ wait 5 cycles
        STZ $01             ;/
        LDA $2306
        LDY $2307
        BEQ +
        LDA #$FF
+       LSR A
    endif

    TAY
    LDA.w AtanTable,y
+   LSR $06
    BCC +
    EOR #$7F
    INC A
+   LSR $06
    BCC +
    EOR #$FF
    INC A
    BEQ +
    INC $01
+   LSR $06
    BCC +
    EOR #$FF
    INC A
    BNE +
    INC $01
+   STA $00
    LDA #$FE
    TRB $01
    RTS

.DivZero
    SEP #$20
    LDY #$00
    LDA $06
    LSR A
    BCS +
    LDY #$80
    LSR A
+   AND #$01
    STA $01
    STY $00
    RTS

AtanTable:
    db $00,$01,$01,$02,$03,$03,$04,$04,$05,$06,$06,$07,$08,$08,$09,$0A
    db $0A,$0B,$0B,$0C,$0D,$0D,$0E,$0E,$0F,$10,$10,$11,$12,$12,$13,$13
    db $14,$15,$15,$16,$16,$17,$18,$18,$19,$19,$1A,$1A,$1B,$1C,$1C,$1D
    db $1D,$1E,$1E,$1F,$1F,$20,$21,$21,$22,$22,$23,$23,$24,$24,$25,$25
    db $26,$26,$27,$27,$28,$28,$29,$29,$2A,$2A,$2B,$2B,$2C,$2C,$2D,$2D
    db $2E,$2E,$2E,$2F,$2F,$30,$30,$31,$31,$32,$32,$32,$33,$33,$34,$34
    db $34,$35,$35,$36,$36,$36,$37,$37,$38,$38,$38,$39,$39,$39,$3A,$3A
    db $3B,$3B,$3B,$3C,$3C,$3C,$3D,$3D,$3D,$3E,$3E,$3E,$3F,$3F,$3F,$40
