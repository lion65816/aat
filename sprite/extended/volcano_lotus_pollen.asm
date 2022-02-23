;============================================================
; Customizable Volcano Lotus Pollen
;
; Description: This is a disassembly of the Volcano Lotus
; Pollen, updated to be faster and have more options.
;
; When spawning it, set 1765 to 01 to make it home towards
; the player, else it'll use its default speed routine.
;============================================================

!tile_1         = $A6
!tile_2         = $B6
!props          = $09
!aim_speed      = $30

print "MAIN ",pc
        %ExtendedGetDrawInfo()
        LDA $170B|!Base2,x
        BNE +
        STZ $1765|!Base2,x
        RTL
+       LDA $01
        STA $0200|!Base2,y
        LDA $02
        CMP #$F0
        BCS .off_screen
        STA $0201|!Base2,y
        LDA #!props
        ORA $64
        STA $0203|!Base2,y
        LDA $14
        LSR
        EOR $15E9|!Base2
        LSR #2
        LDA #!tile_1
        BCC +
        LDA #!tile_2
+       STA $0202|!Base2,y
        TYA
        LSR #2
        TAY
        LDA #$00
        STA $0420|!Base2,y
.off_screen
        LDA $9D
        BNE .return
        LDX #$00
        %ExtendedClipping()
        LDA #$00
        %ExtendedMarioInteraction()
        LDA #$01
        %ExtendedSpeed()
        LDA $1765|!Base2,x
        BMI .return
        BEQ .normal_speed
        LDA $173D|!Base2,x
        BMI .normal_speed
        LDA $1733|!Base2,x
        XBA
        LDA $171F|!Base2,x
        REP #$20
        SEC
        SBC $94
        STA $00
        SEP #$21

        LDA $1729|!Base2,x
        XBA
        LDA $1715|!Base2,x
        REP #$20
        SBC #$0008
        SBC $96
        STA $02
        SEP #$20

        LDA #!aim_speed
        %Aiming()
        LDA $02
        STA $173D|!Base2,x
        LDA $00
        STA $1747|!Base2,x
        LDA #$80
        STA $1765|!Base2,x
.return
        RTL
.normal_speed
        LDA $14
        AND #$03
        BNE +
        LDA $173D|!Base2,x
        CMP #$18
        BPL +
        INC $173D|!Base2,x
+       LDA $173D|!Base2,x
        BMI .return
        TXA
        ASL #3
        ADC $14
        LDY #$08
        AND #$08
        BNE +
        LDY #$F8
+       TYA
        STA $1747|!Base2,x
        RTL

