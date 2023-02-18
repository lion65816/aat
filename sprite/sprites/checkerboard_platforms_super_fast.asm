;; Super Fast Checker Platforms H&V
;;
;; If the first extra bit is clear, the sprite will move horizontally, acting like 55.
;; If the first extra bit is set, the sprite will move vertically, acting like 57.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; defines and tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!CheckerboardTile1 = $EA        ; the left tile of the checkerboard platform
!CheckerboardTile2 = $EB        ; the middle tile of the checkerboard platform
!CheckerboardTile3 = $EC        ; the right tile of the checkerboard platform

Acceleration:
    db $F8,$08

MaxSpeed:
    db $D8,$28

!ExtraBit = $04

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; init routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
    INC !1602,x
    LDA !7FAB10,x
    AND.b #!ExtraBit
    STA !1504,x
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; main routine wrapper
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
    PHB : PHK : PLB
    JSR CheckerboardPlatformsMain
    PLB
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; main routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckerboardPlatformsMain:
    JSR CheckerboardPlatformGFX

    LDA $9D                         ; if sprites are locked...
    BNE Return0                     ; return

    LDA !1540,x                     ; if the timer is set...
    BNE ContinueMain                ; skip to the position-updating and player interaction routines

    INC !C2,x                       ; increment the sprite state
    LDA !C2,x
    AND #$03                        ; if the sprite state isn't 0...
    BNE ContinueMain                ; skip to the position-updating and player interaction routines

    LDA !151C,x
    AND #$01
    TAY
    LDA !AA,x
    CLC : ADC Acceleration,y        ; give the sprite some acceleration
    STA !AA,x                       ; set its Y speed
    STA !B6,x                       ; set its X speed
    CMP MaxSpeed,y                  ; if the sprite has reached maximum speed...
    BNE ContinueMain

    INC !151C,x
    LDA #$18                        ; timer = 18 if the platform moves vertically
    LDY !1504,x
    BNE StoreTimer
    LDA #$08                        ; timer = 08 if the platform moves horizontally
StoreTimer:
    STA !1540,x
ContinueMain:
    LDY !1504,x                     ; if the extra bit is set...
    BNE UpdateY                     ; make the sprite move vertically

    JSL $018022|!BankB              ; else, make the sprite move horizontally
    BRA EndOfMain

UpdateY:
    JSL $01801A|!BankB
    STZ $1491|!Base2
EndOfMain:
    LDA $1491|!Base2
    STA !1528,x                     ; prevent the player from sliding
    JSL $01B44F|!BankB              ; make it solid
    LDA #$01
    %SubOffScreen()
Return0:
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckerboardPlatformGFX:
    %GetDrawInfo()

    LDA !1602,x
    STA $01

    LDA !D8,x
    SEC : SBC $1C
    STA $0301|!Base2,y
    STA $0305|!Base2,y
    STA $0309|!Base2,y
    STA $030D|!Base2,y
    STA $0311|!Base2,y
    LDX $15E9|!Base2
    LDA !E4,x
    SEC : SBC $1A
    STA $0300|!Base2,y              ; set the tile X displacement
    CLC : ADC #$10
    STA $0304|!Base2,y              ; second tile 16 pixels to the right of the first
    CLC : ADC #$10
    STA $0308|!Base2,y              ; third tile 16 pixels to the right of the second
    CLC : ADC #$10
    STA $030C|!Base2,y              ; fourth tile 16 pixels to the right of the third
    CLC : ADC #$10
    STA $0310|!Base2,y              ; fifth tile 16 pixels to the right of the fourth

    LDA.b #!CheckerboardTile1
    STA $0302|!Base2,y              ; first tile
    LDA.b #!CheckerboardTile2
    STA $0306|!Base2,y              ; second,
    STA $030A|!Base2,y              ; third,
    STA $030E|!Base2,y              ; and fourth tiles
    LDA.b #!CheckerboardTile3
    STA $0312|!Base2,y              ; fifth tile

    LDA $64
    ORA !15F6,x                     ; no hardcoded palette this time, and the two platforms use the same one
    STA $0303|!Base2,y              ; properties for the first...
    STA $0307|!Base2,y              ; second...
    STA $030B|!Base2,y              ; third...
    STA $030F|!Base2,y              ; fourth...
    STA $0313|!Base2,y              ; and fifth tile

    LDA #$04                        ; 5 tiles to draw
    LDY #$02                        ; all tiles are 16x16
    JSL $01B7B3|!BankB
    RTS
