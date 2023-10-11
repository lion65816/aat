;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Real homing bill shooter - Standard version
; by 33953YoShI (Akaginite)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Uses first extra bit: NO
; Generated sprite's extra bit will be set to the same value as this shooter's extra bit.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!CustSprite = $31           ; Set to the homing bill's sprite number from list.txt
!GenTimer = $60             ; Set interval for shooting

!ShootSFX = $09             ; Sound effect to play when firing a bullet
!ShootBank = $1DFC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!sprite_back_dist_low = !1534
!sprite_back_dist_high = !1528
!sprite_angle_low = !1504
!sprite_angle_high = !151C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
print "MAIN ",pc
    PHB : PHK : PLB
    JSR MainCode
    PLB
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainCode:
    LDA !shoot_timer,x
    BNE .Return
    LDA.b #!GenTimer
    STA !shoot_timer,x
    LDA !shoot_y_low,x
    CMP $1C
    LDA !shoot_y_high,x
    SBC $1D
    BNE .Return
    LDA !shoot_x_high,x
    XBA
    LDA !shoot_x_low,x
    REP #$21
    ADC.w #$0010
    SEC : SBC $1A
    CMP.w #$0120
    SEP #$20
    BCS .Return
    LDA $94
    ADC #$11
    SEC : SBC !shoot_x_low,x
    CMP #$22
    BCC .Return
    JSL $02A9DE|!BankB
    BPL +
.Return
    RTS

+   LDA #$88
    BIT !shoot_num,x
    BVC +
        ORA #$04
+   STA $02
    TYX
    LDA.b #!CustSprite
    STA !new_sprite_num,x
    JSL $07F7D2|!BankB
    LDA $02
    STA !extra_bits,x
    LDA #$01
    STA !sprite_back_dist_high,x
    LDA #$80
    STA !sprite_back_dist_low,x
    LDA #$01
    STA !14C8,x
    LDA.b #!ShootSFX
    STA.w !ShootBank|!Base2

    TXY
    LDX $15E9|!Base2

    LDA !shoot_x_low,x
    STA.w !E4,y
    LDA !shoot_x_high,x
    STA !14E0,y
    LDA !shoot_y_low,x
    SEC : SBC #$01
    STA.w !D8,y
    LDA !shoot_y_high,x
    SBC #$00
    STA !14D4,y

    LDA $94
    CMP !shoot_x_low,x
    LDA $95
    SBC !shoot_x_high,x
    ASL A
    LDA #$00
    ROL A
    STA !sprite_angle_high,y
    TAY

GenSmoke:
    LDA .X_Offset_Low,y
    STA $00
    CLC : ADC !shoot_x_low,x
    STA $01
    LDA .X_Offset_High,y
    ADC !shoot_x_high,x
    LDY $01
    CPY $1A
    SBC $1B
    BNE .Return
    LDA !shoot_y_low,x
    CMP $1C
    LDA !shoot_y_high,x
    SBC $1D
    BNE .Return

    LDY #$03
.FindFree
    LDA $17C0|!Base2,y
    BEQ .FoundFree
    DEY
    BPL .FindFree
.Return
    RTS

.FoundFree
    LDA #$01
    STA $17C0|!Base2,y
    LDA !shoot_y_low,x
    STA $17C4|!Base2,y
    LDA #$1B
    STA $17CC|!Base2,y
    LDA !shoot_x_low,x
    CLC : ADC $00
    STA $17C8|!Base2,y
    RTS

.X_Offset_Low   db $08,$F8
.X_Offset_High  db $00,$FF
