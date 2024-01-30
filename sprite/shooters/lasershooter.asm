!ClusterSprite = $01        ; The cluster sprite number of the laser from list.txt

!ShootAbove    = 0          ; Set to 1 to shoot even when the player is above the shooter

!SoundEffect   = $23        ; Sound effect to play when shooting
!SoundBank     = $1DF9

print "INIT ",pc
print "MAIN ",pc
    PHB : PHK : PLB
    JSR ShooterCode
    PLB
    RTL

Return:
    RTS

ShooterCode:
    LDA !shoot_timer,x
    BEQ Return
    CMP #$11                ; On shooter load, timer is always #$10 for some reason.
    BCC Return
    STZ !shoot_timer,x

    if !ShootAbove == 0
        LDA $96             ; Don't shoot if Mario is above shooter.
        SEC : SBC !shoot_y_low,x
        LDA $97
        SBC !shoot_y_high,x
        BMI Return
    endif

    PHX
    TXY
    LDX #$13
-   LDA !cluster_num,x      ; Find a free cluster sprite slot.
    BEQ +
    DEX
    BPL -
    PLX
    RTS

+   LDA.b #!SoundEffect
    STA !SoundBank|!Base2
    LDA.b #!ClusterSprite+!ClusterOffset
    STA !cluster_num,x

    LDA !shoot_num,y
    AND #$40
    STA $00
    BEQ +
        LDA #$01
        STA $1E52|!Base2,x
+   LDA $00
    BNE +

    LDA !shoot_x_low,y
    SEC : SBC #$08
    STA !cluster_x_low,x
    LDA !shoot_x_high,y
    SBC #$00
    STA !cluster_x_high,x
    BRA ++

+   LDA !shoot_x_low,y
    CLC : ADC #$08
    STA !cluster_x_low,x
    LDA !shoot_x_high,y
    ADC #$00
    STA !cluster_x_high,x

++  LDA !shoot_y_low,y
    SEC : SBC #$08
    STA !cluster_y_low,x
    LDA !shoot_y_high,y
    SBC #$00
    STA !cluster_y_high,x

    PLX

    LDA #$01            ; Run cluster sprite code.
    STA $18B8|!Base2

    RTS
