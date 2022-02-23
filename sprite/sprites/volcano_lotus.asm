;============================================================
; Customizable Volcano Lotus
;
; Description: A vanilla volcano lotus with more features
; and customizable options.
;
; Uses extra bit: YES
; if set, the pollen will be homing, once spawned.
;
; Uses extra bytes: YES
; Extra Byte 1:  time before the lotus starts pumping (?).
; Vanilla value: 80
; Extra Byte 2:  time before the lotus starts flashing.
; Vanilla value: 40
; Extra Byte 3:  time before the lotus spawns its pollen.
; Vanilla value: 40
;============================================================

!pollen_to_spawn        = $04   ;   Amount of pollen the volcano lotus will spawn.
                                ;   Modify the speed tables below to add more speed values if you change this!
!pollen_number          = $04   ;   Extended sprite number of the pollen/projectile. As you put it in PIXI's list.txt

pollen_x_speed:
        db $10,$F0,$06,$FA
pollen_y_speed:
        db $EC,$EC,$E8,$E8
volcano_lotus_tilemap:
        db $8E,$9E,$E2
        
!stem_tile              = $CE
!bulb_prop_1            = $39
!bulb_prop_2            = $35

!pollen_number         := !pollen_number+$13

print "INIT ",pc
        LDA !7FAB58,x
        SEC
        SBC #$08
        STA !1594,x
        LDY #$80
        LDA !7FAB10,x
        AND #$04
        BEQ +
        TYA
+       STA !1FD6,x
        RTL

print "MAIN ",pc
        PHB
        PHK
        PLB
        JSR volcano_lotus_main
        PLB
        RTL

volcano_lotus_main:
        JSR draw_sprite
        LDA $9D
        BNE .return
        %SubOffScreen()
        STZ !151C,x
        JSL $01A7DC|!BankB
        JSL $01801A|!BankB
        LDA !AA,x
        CMP #$40
        BPL +
        INC !AA,x
+       JSL $019138|!BankB
        LDA !1588,x
        AND #$04
        BEQ +
        STZ !AA,x
+       LDA !C2,x
        BEQ .not_flashing
        DEC
        BNE .ready_to_spawn
        LDA !1540,x
        BNE +
        LDA !7FAB58,x
        STA !1540,x
        INC !C2,x
+       LSR
        AND #$01
        STA !151C,x
.return
        RTS

.not_flashing
        LDA !1540,x
        BNE +
        LDA !7FAB4C,x
        STA !1540,x
        INC !C2,x
+       LSR #3
        AND #$01
        STA !1602,x
        RTS

.ready_to_spawn
        LDA !1540,x
        BNE +
        LDA !7FAB40,x
        STA !1540,x
        STZ !C2,x
+       CMP !1594,x
        BNE .not_spawn
        JSR spawn_pollen
.not_spawn
        LDA #$02
        STA !1602,x
        RTS

draw_sprite:
        %GetDrawInfo()
        LDA $01                         ;\
        DEC                             ; |
        STA $0301|!Base2,y              ; | y displacement
        STA $0305|!Base2,y              ; | stem, bulb
        STA $0309|!Base2,y              ; |
        STA $030D|!Base2,y              ;/
        LDA $00                         ;\  x diaplacement
        SEC                             ; |
        SBC #$08                        ; | stem 1
        STA $0300|!Base2,y              ; |
        LDA $00                         ; |\ bulb 1
        STA $0308|!Base2,y              ; |/
        CLC                             ; |\
        ADC #$08                        ; | | stem 2, bulb 2
        STA $0304|!Base2,y              ; |/
        STA $030C|!Base2,y              ;/
        LDA.b #!stem_tile               ;\  tilemap
        STA $0302|!Base2,y              ; |\ stem
        STA $0306|!Base2,y              ; |/
        LDA !1602,x                     ; |\
        TAX                             ; | |
        LDA volcano_lotus_tilemap,x     ; | | bulb
        LDX $15E9|!Base2                ; | |
        STA $030A|!Base2,y              ; | |
        INC                             ; |/
        STA $030E|!Base2,y              ;/
        LDA !15F6,x                     ;\  properties
        STA $0303|!Base2,y              ; |\
        ORA #$40                        ; | | stem
        STA $0307|!Base2,y              ; |/
        LDA !151C,x                     ; |\
        LSR                             ; | |
        LDA #!bulb_prop_1               ; | | bulb
        BCC +                           ; | |
        LDA #!bulb_prop_2               ; | |
+       STA $030B|!Base2,y              ; |/
        STA $030F|!Base2,y              ;/
        TYA                             ;\
        LSR #2                          ; |
        TAY                             ; |
        LDA #$02                        ; | tile size
        STA $0460|!Base2,y              ; | stem, bulb
        STA $0461|!Base2,y              ; |
        LDA #$00                        ; |
        STA $0462|!Base2,y              ; |
        STA $0463|!Base2,y              ;/
        LDY #$FF
        LDA #$03
        JSL $01B7B3|!BankB
        RTS

spawn_pollen:
        LDA !15A0,x 
        ORA !186C,x 
        BNE .return
        LDA.b #!pollen_to_spawn-1
        STA $00
.pollen_loop
        LDY #$07
.find_slot_loop
        LDA $170B|!Base2,y
        BEQ .spawn_pollen
        DEY
        BPL .find_slot_loop
        RTS

.spawn_pollen
        LDA #!pollen_number
        STA $170B|!Base2,y
        LDA !E4,x
        CLC
        ADC #$04
        STA $171F|!Base2,y
        LDA !14E0,x
        ADC #$00
        STA $1733|!Base2,y
        LDA !D8,x
        STA $1715|!Base2,y
        LDA !14D4,x
        STA $1729|!Base2,y
        LDX $00
        LDA pollen_x_speed,x
        STA $1747|!Base2,y
        LDA pollen_y_speed,x
        STA $173D|!Base2,y
        LDX $15E9|!Base2
        BIT !1FD6,x
        BPL .no_home
        LDA #$01
        STA $1765|!Base2,y
.no_home
        DEC $00
        BPL .pollen_loop
        LDA !1FD6,x
        BMI .return
        EOR #$01
        STA !1FD6,x
.return
        RTS

