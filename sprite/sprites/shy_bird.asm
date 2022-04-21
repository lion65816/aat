;================================================================
; Bird, flies when touched
; By Erik
;
; Description: This bird will fly away when it comes in contact
; with Mario or a sprite.
;
; Uses extra bytes:
; - Extra byte 1: Index to the palette table. The default for
;   every value is:
;    * 00 - Yellow
;    * 01 - Blue
;    * 02 - Red
;    * 03 - Green
;   Anything else will glitch unless you add more values to the
;   table.
;================================================================

palette:
        db $04,$06,$08,$0A
bird_tilemap:
        db $2F,$7F,$6A,$7A,$76
bird_x_speed_adds:
        db $02,-$02
bird_max_x_speeds:
        db $18,-$18

!bird_y_speed_add       = -$02
!bird_max_y_speed       = -$20

!update_speed_freq      = $03

print "MAIN ",pc
        PHB
        PHK
        PLB
        JSR shy_birb
        PLB
        RTL

print "INIT ",pc
        LDA !D8,x
        CLC
        ADC #$08
        STA !1528,x
        JSL $01ACF9|!BankB
        STA !1504,x
        RTL

shy_birb:
        JSR draw_sprite
        LDA !14C8,x
        EOR #$08
        ORA $9D
        BNE return
        %SubOffScreen()
        JSL $018022|!BankB
        JSL $01801A|!BankB
        LDA !1594,x
        BNE .set_speeds
        JSR sprite_interact
        LDA !1594,x
        BNE .set_speeds
        JSL $01A7DC|!BankB
        BCC no_interact
        LDA !157C,x
        EOR #$01
        STA !157C,x
.interacted_with
        INC !1594,x
        LDA #$26
        STA $1DFC|!Base2
        STZ !B6,x
        STZ !AA,x
.set_speeds
        INC !1504,x
        LDA !1504,x
        AND.b #!update_speed_freq
        BNE .frame
        LDA !AA,x
        CLC
        ADC.b #!bird_y_speed_add
        CMP.b #!bird_max_y_speed
        BEQ +
        STA !AA,x
+       LDY !157C,x
        LDA !B6,x
        CLC
        ADC bird_x_speed_adds,y
        CMP bird_max_x_speeds,y
        BEQ .frame
        STA !B6,x
.frame
        LDY #$02
        LDA !1504,x
        LSR
        AND #$03
        BNE +
        INY
+       TYA
        STA !1602,x
return:
        RTS
no_interact:
        LDA !15AC,x
        BEQ +
        LDA #$04
        STA !1602,x
+       LDA !AA,x
        CLC
        ADC #$03
        STA !AA,x
        LDA !C2,x
        BEQ moving_around

        STZ !AA,x
        STZ !B6,x
        STZ !1602,x
        LDA !1540,x
        BEQ .no_pecking
        CMP #$08
        BCS return
        INC !1602,x
        RTS

.no_pecking
        LDA !1570,x
        BEQ start_movement
        DEC !1570,x
        JSL $01ACF9|!BankB
        AND #$1F
        ORA #$0A
        STA !1540,x
        RTS

start_movement:
        STZ !C2,x
        JSL $01ACF9|!BankB
        LSR
        BCS no_flip_dir
        LDA !157C,x
flip_dir:
        EOR #$01
        STA !157C,x
        LDA #$0A
        STA !15AC,x
no_flip_dir:
        JSL $01ACF9|!BankB
        AND #$03
        CLC
        ADC #$02
        STA !1570,x
        RTS

stop_values:
        db $02,$03,$05,$01
flip_values:
        db $FF,$00

moving_around:
        LDY !157C,x
        LDA bird_x_speed_adds,y
        STA !B6,x
        STZ !1602,x
        LDA !AA,x
        BMI return
        LDA !D8,x
        CMP !1528,x
        BCC return
        AND #$F8
        STA !D8,x
        LDA #$F0
        STA !AA,x
        LDY !157C,x
        LDA !E4,x
        EOR flip_values,y
        CMP #$30
        BCC .check_if_flip
        LDA !1570,x
        BEQ .stop_moving
        DEC !1570,x
        RTS

.stop_moving
        INC !C2,x
        JSL $01ACF9|!BankB
        AND #$03
        TAY
        LDA stop_values,y
        STA !1570,x
        RTS

.check_if_flip
        LDA !15AC,x
        BNE +
        JSR flip_dir
        LDA #$10
        STA !154C,x
+       RTS

sprite_interact:
        LDY.b #!SprSize-1
.loop
        LDA !14C8,y
        CMP #$08
        BCC .keep_looping
        CMP #$0B
        BCS .keep_looping
        LDA !1686,y
        AND #$08
        BEQ .interact
.keep_looping
        DEY
        BPL .loop
        RTS

.interact
        JSL $03B69F|!BankB
        TYX
        JSL $03B6E5|!BankB
        LDX $15E9|!Base2
        JSL $03B72B|!BankB
        BCC .keep_looping
        LDA.w !E4,y
        SEC
        SBC !E4,x
        LDA.w !14E0,y
        SBC !14E0,x
        LDY #$01
        CMP #$00
        BPL +
        DEY
+       TYA
        STA !157C,x
        JMP shy_birb_interacted_with

bird_flip:
        db $71,$31

draw_sprite:
        LDA !7FAB40,x
        TAY
        LDA palette,y
        LDY !157C,x
        ORA bird_flip,y
        STA $02
        %GetDrawInfo()
        REP #$20
        LDA $00
        STA $0300|!Base2,y
        SEP #$20
        LDA !1602,x
        TAX
        LDA bird_tilemap,x
        STA $0302|!Base2,y
        LDX $15E9|!Base2
        LDA $02
        STA $0303|!Base2,y
        TDC
        TAY
        JSL $01B7B3|!BankB
        RTS

