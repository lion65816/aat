;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fire Bros.
;; By Sonikku
;;
;; Description: Walks back and forth, frequently throwing two fireballs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FireballNumber = $01               ; Extended sprite number from list.txt of fireball.asm.

!FireballSFX = $06                  ; Sound effect to play when shooting fire.
!FireballBank = $1DFC

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

; Workaround for sublabels; wastes 4 bytes, but ensures the sprite assembles.
%SubOffScreen()

SpriteCode:
    JSR Graphics

    LDA !14C8,x                     ; If sprite dead of sprites locked, return.
    CMP #$08
    BNE Return
    LDA $9D
    BNE Return

    %SubOffScreen()

    JSL $01A7DC|!BankB              ; Sprite interacts with Mario
    JSR FaceMario                   ; Sprite always faces Mario
    JSL $01802A|!BankB              ; Sprite has gravity

    INC !1570,x

    LDA !1570,x
    CMP #$A0
    BNE .noReset                    ; if timer isn't maximum, branch.

    STZ !1570,x

    LDY #$50                        ; Random option 1
    JSL $01ACF9|!BankB
    AND #$01
    BEQ +
        LDY #$30                    ; Random option 2
+   TYA
    STA !1540,x                     ; Set timer

    STZ !B6,x
.noReset
    LDY #$00                        ; Y = $00

    LDA !151C,x
    AND #$08
    BEQ +                           ; 8 ticks on, 8 ticks off; branch
        INY                         ; Y = $01
+   LDA !1540,x
    BEQ ++                          ; if timer = #$00, branch
    CMP #$20
    BNE +                           ; if timer != #$20, branch
    JSL $01ACF9|!BankB
    AND #$01
    BEQ +                           ; 50% chance to branch.
    LDA !1588,x
    AND #$04
    BEQ +
    LDA #$C8
    STA !AA,x
+   LDY #$02                        ; Y = $02
++  TYA
    STA !1602,x                     ; set frame based on Y
    LDA !1540,x
    CMP #$40
    BCS +                           ; if timer is above #$40, branch
    AND #$1F
    CMP #$0F
    BNE +                           ; if not time to spawn, branch
    JSR GenerateFireball
+   LDA !1540,x
    BNE +
    LDA !1528,x
    BEQ .onGround                   ; if flag is already #$00, branch
+   LDA !1588,x
    AND #$04
    BEQ +                           ; if sprite is in the air, return
    STZ !1528,x                     ; clear flag
    LDA !AA,x
    BMI +
        STZ !AA,x                   ; no speed if positive
+   RTS

.onGround
    LDA !160E,x
    BEQ +
        DEC !160E,x
+   INC !1534,x
    LDA !1534,x
    AND #$1F
    BNE +                           ; only run once every #$20 frames
    JSL $01ACF9|!BankB
    AND #$01
    BNE +                           ; 50% chance to branch
    LDA !1588,x
    AND #$04
    BEQ +                           ; branch if in the air
    INC !1528,x                     ; increment flag
    LDA #$D8
    STA !AA,x                       ; jump
    STZ !B6,x                       ; no x-speed
    RTS

+   LDA !C2,x
    AND #$03                        ; one of 4 possibilities
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
    LDA !160E,x
    BNE +
    INC !C2,x                       ; increment state (to walking left or right)
    LDA #$20
    STA !160E,x                     ; set walk timer
+   BRA .finish

.walkLeft
    LDX $15E9|!Base2
    LDY #$F8
    BRA +

.walkRight
    LDX $15E9|!Base2
    LDY #$08
+   LDA !160E,x
    BNE +
    INC !C2,x                       ; increment state (to waiting)
    LDA #$10
    STA !160E,x                     ; set wait timer
+   TYA
    STA !B6,x

    LDA !160E,x
    AND #$3F
    BNE .finish                     ; every so often we let the sprite hop

    LDA !160E,x
    AND #$40
    ASL #2
    LDY #$E0                        ; possibility 1
    BCC +
        LDY #$D8                    ; possibility 2
+   TYA
    STA !AA,x                       ; set y speed
.finish
    LDA !1588,x
    AND #$04
    BEQ +
    INC !151C,x
    LDA !AA,x
    BMI +
    STZ !AA,x
+   RTS

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

    PHX
    LDX #$01
-   LDA $00
    STA $0300|!Base2,y

    PHX
    TXA
    CLC : ADC $05
    TAX
    LDA $01
    CLC : ADC .ypos,x               ; Y position determined by dead/alive state
    STA $0301|!Base2,y
    PLX

    PHX
    TXA
    CLC : ADC $03
    TAX
    LDA .tilemap,x                  ; tilemap determined by !1602,x
    STA $0302|!Base2,y
    PLX

    PHX
    LDX $15E9|!Base2
    LDA !15F6,x                     ; palette based on cfg file
    PHX
    LDX $02
    BNE +
        ORA #$40                    ; flip by x if $157C,x = #$00
+   LDX $04
    BEQ +
        ORA #$80                    ; flip by y if $14C8,x = #$02 (dead)
+   PLX
    ORA $64                         ; apply level priority settings
    STA $0303|!Base2,y
    PLX

    INY #4

    DEX
    BPL -
    PLX

    LDY #$02
    LDA #$01
    JSL $01B7B3|!BankB
    RTS

.ypos
    db $F0,$00,$08,$F8

.tilemap
    db $A2,$A0,$A2,$E6,$A6,$A4

GenerateFireball:
    LDA !15A0,x
    ORA !186C,x
    BNE ++
    LDY #$07
-   LDA !extended_num,y
    BEQ +
    DEY
    BPL -
++  RTS

+   LDA.b #!FireballSFX
    STA.w !FireballBank|!Base2
    LDA.b #!FireballNumber+!ExtendedOffset
    STA !extended_num,y
    LDA #$20                        ; extended sprite Y speed
    STA $173D|!Base2,y
    LDA !E4,x                       ; extended sprite X position = 4 pixels to the left
    CLC : ADC #$04
    STA !extended_x_low,y
    LDA !14E0,x                     ; extended sprite Y position (high)
    ADC #$00
    STA !extended_x_high,y
    LDA !D8,x
    CLC : ADC #$F8                  ; extended sprite Y position = 8 pixels above sprite
    STA !extended_y_low,y
    LDA !14D4,x
    ADC #$FF                        ; extended sprite Y position (high)
    STA !extended_y_high,y

    LDA !157C,x                     ; set up extended sprite direction
    TAX
    LDA .xspd,x                     ; set up extended sprite speed
    STA $1747|!Base2,y
    LDX $15E9|!Base2
    RTS

.xspd
    db $02,$FE

FaceMario:
    LDY #$00
    LDA $94
    SEC : SBC !E4,x
    LDA $95
    SBC !14E0,x
    BPL +
        INY
+   TYA
    STA !157C,x
    RTS
