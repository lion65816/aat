!LakituNumber = $BD     ; Make sure this matches the sprite number of the Lakitu (this sprite).
!ClusterNumber = $03    ; Set this to the number of the cluster sprite from list.txt.

!EndLevel = 1           ; Set to 1 to end the level after defeating the Lakitu.
!GoalMusic = $03        ; The music to switch to when ending the level. Set to 3 if using AddmusicK!

!Hits = 6               ; How many hits it takes to kill the Lakitu.
!ShakeTime = $3F        ; The time for which to stun the player and shake the ground when falling.

!FallSFX = $09          ; The sound effect to use when falling to the ground.
!FallBank = $1DFC

!DropSFX = $23          ; The sound effect to use when dropping a lightning bolt.
!DropBank = $1DF9

!HurtSFX = $28          ; The sound effect to use when getting hurt.
!HurtBank = $1DFC

SpeedX: db $0E,$F1
SpeedY: db $30,$F0

WaveSpeed:
    db $00,$F8,$F2,$F8,$00,$08,$0E,$08

Bounce:
    db $E4,$1C

print "INIT ",pc
    %BEC(InitReturn)
    STZ !C2,x
    %SubHorzPos()
    TYA
    STA !157C,x
    LDA #$FF
    STA !1558,x
    LDA #$55
    STA !1528,x
    LDA #$A3
    STA !1662,x
    RTL

InitReturn:
    STZ !1662,x
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    %BEC(MainDifferent)

    JSR Timer
    JSR SpriteCode
    PLB
    RTL

Timer:
    LDA !1528,x
    BEQ .done
    DEC !1528,x
.done
    LDA !1534,x
    BEQ .return
    DEC !1534,x
.return
    RTS

MainDifferent:
    JSR OtherSprite
    PLB
    RTL

Return: RTS

SpriteCode:
    JSR PrimaryGraphics
    LDA #$00
    %SubOffScreen()
    LDA !14C8,x
    CMP #$08
    BNE Return
    LDA $9D
    BNE Return
    LDA !1558,x
    BEQ Vulnerable
    LDA #$80
    STA !163E,x
    LDA !C2,x
    ASL A
    PHX
    TAX
    JMP.w (Pointers,x)

Pointers:
    rep !Hits : dw Fly
    rep 4 : dw Disappear

Vulnerable:
    STZ !sprite_speed_x,x
    LDA !163E,x
    BEQ .set1558
    LDA !sprite_blocked_status,x
    AND #$0C
    BNE .touchingVertical
.notTouching
    LDY !151C,x
    LDA SpeedY,y
    STA !sprite_speed_y,x
    JSL $01802A|!BankB          ; Update X/Y with gravity
    JSL $019138|!BankB          ; Interact with objects
    LDA !1534,x
    ORA !154C,x
    BNE .return
    JSL Contact
.return
    RTS

.touchingVertical
    LDA.b #!ShakeTime           ; Shake layer 1
    STA $1887|!Base2
    LDA $77
    AND #$04
    BEQ +
        LDA.b #!ShakeTime       ; Stun the player if on ground
        STA $18BD|!Base2
+   JSL $02A9DE|!BankB          ; Find free sprite slot
    BMI .notTouching
    PHX
    TYX
    LDA #$01                    ; Reinitialize ourselves
    STA !14C8,x
    LDA.b #!LakituNumber
    STA !7FAB9E,x
    JSL $07F7D2|!BankB
    JSL $0187A7|!BankB
    LDA #$08
    STA !7FAB10,x
    TXY
    PLX
    LDA !E4,x                   ; Copy our sprite tables to the new sprite
    STA.w !E4,y
    LDA !14E0,x
    STA !14E0,y
    LDA !D8,x
    STA.w !D8,y
    LDA !14D4,x
    STA !14D4,y
    LDA.b #!FallSFX
    STA.w !FallBank|!Base2
    LDA !151C,x
    EOR #$01
    STA !151C,x
    BRA .notTouching

.set1558
    LDA !151C,x
    EOR #$01
    STA !151C,x
    LDA #$FF
    STA !1558,x
    RTS

Fly:
    PLX
    %SubHorzPos()
    TYA
    STA !157C,x
    LDY !157C,x
    LDA SpeedX,y
    STA !sprite_speed_x,x
    LDA !sprite_blocked_status,x
    AND #$03
    BEQ .notTouching
    LDA !157C,x
    EOR #$01
    STA !157C,x
.notTouching
    JSR WaveMotion
    LDA !1528,x
    BNE .finish
    LDA.b #!DropSFX
    STA.w !DropBank|!Base2
    JSL $02A9DE|!BankB      ; Find a free sprite slot
    BMI .notTouching
    PHX
    TYX
    LDA #$01                ; Reinitialize ourselves
    STA !14C8,x
    LDA #!LakituNumber
    STA !7FAB9E,x
    JSL $07F7D2|!BankB
    JSL $0187A7|!BankB
    LDA #$08
    STA !7FAB10,x
    TXY
    PLX
    LDA !E4,x               ; Copy the sprite tables to the new sprite
    STA.w !E4,y
    LDA !14E0,x
    STA !14E0,y
    LDA !D8,x
    STA.w !D8,y
    LDA !14D4,x
    STA !14D4,y
    LDA #$55
    STA !1528,x
.finish
    JSL $01802A|!BankB      ; Update X/Y with gravity
    JSL $019138|!BankB      ; Interact with objects
    LDA !1534,x
    ORA !154C,x
    BNE .return
    JSL Contact
.return
    RTS

Disappear:
    PLX
Smoke:
    LDY #$03                ; \ find a free slot to display effect
-   LDA $17C0|!Base2,y      ;  |
    BEQ +                   ;  |
    DEY                     ;  |
    BPL -                   ;  |
    RTS                     ; / return if no slots open

+   LDA #$01                ; \ set effect graphic to smoke graphic
    STA $17C0|!Base2,y      ; /
    LDA #$1B                ; \ set time to show smoke
    STA $17CC|!Base2,y      ; /
    LDA !D8,x               ; \ smoke y position = sprite y position
    STA $17C4|!Base2,y      ; /
    LDA !E4,x               ; \ load sprite x position and store it for later
    STA $17C8|!Base2,y      ; /
    STZ !14C8,x             ; kill the sprite
    if !EndLevel == 1
        INC $13C6|!Base2    ; prevent Mario from walking at the level end
        LDA #$FF            ; \ set goal
        STA $1493|!Base2    ; /
        LDA #!GoalMusic     ; \ set ending music
        STA $1DFB|!Base2    ; /
    endif
    RTS

WaveMotion:
    PHY                 ; Push Y in case something messes it up.
    LDA $14             ; Get the frame counter ..
    LSR #3
    AND #$07            ; Loop through these bytes during H-Blank. (WHAT?)
    TAY                 ; Into Y.
    LDA WaveSpeed,y     ; Load Y speeds..
    STA !sprite_speed_y,x
    PLY                 ; Pull Y.
    RTS

Contact:
    LDA !154C,x
    BNE NoContact
    JSL $01A7DC|!BankB
    BCC NoContact
    %SubVertPos()
    LDA $0E
    CMP #$E6
    BPL SpriteWins
    LDA $7D
    BMI NoContact
    LDA $15
    PHA
    ORA #$C0
    STA $15
    JSL $01AA33|!BankB
    PLA
    STA $15
    %SubHorzPos()
    TYA
    EOR #$01
    TAY
    LDA Bounce,y
    STA $7B
    LDA.b #!HurtSFX
    STA !HurtBank|!Base2
    JSL $01AB99|!BankB          ; Display contact graphics.
    LDA #$6F
    STA !154C,x
    STA !1534,x
    INC !C2,x
NoContact:
    RTL

SpriteWins:
    LDA !154C,x
    ORA !15D0,x
    BNE NoContact
    JSL $00F5B7|!BankB
    RTL

X_Disp:
    db $F8,$08
    db $F8,$08
    db $08,$F8
    db $08,$F8

Y_Disp:
    db $E8,$E8
    db $F8,$F8

Tilemap:
    db $00,$02
    db $20,$22

Size:
    db $02,$02
    db $02,$02

Flash:
    db $00,$02,$04,$06,$08,$0A,$0C,$0E

PrimaryGraphics:
    %GetDrawInfo()
    LDA !157C,x
    STA $02
    LDA !C2,x
    STA $04
    LDA !1534,x
    STA $05

    PHX
    LDX #$03
-   PHX
    LDA $02
    BNE FacingLeft
    INX #4

FacingLeft:
    LDA $00
    CLC : ADC X_Disp,x
    STA $0300|!Base2,y

    PLX
    LDA $01
    CLC : ADC Y_Disp,x
    STA $0301|!Base2,y

    PHX
    LDA Tilemap,x
    STA $0302|!Base2,y

    LDA #$35                ; tile properties yxppccct, format
    LDX $02                 ; \ if direction == 0...
    BNE NoFlip              ; |
    ORA #$40                ; /    ...flip tile
NoFlip:
    ORA $64                 ; add in tile priority of level
    STA $0303|!Base2,y      ; store tile properties
    PLX                     ; \ pull current tile
    LDA $05
    BEQ NoFlash
    PHX
    LDA $14                 ; \ 
    AND #$07                ;  | cycle through all 8 sprite palettes
    TAX                     ;  |
    LDA $0303|!Base2,y      ;  |
    AND #$F1                ;  | <-- F1 = 11110001 = clear all Palette-related bits
    ORA Flash,x             ;  |
    STA $0303|!Base2,y      ; /
    PLX

NoFlash:
    PHY
    TYA
    LSR #2
    TAY
    LDA Size,x
    STA $0460|!Base2,y
    PLY

    INY                     ; | increase index to sprite tile map ($300)...
    INY                     ; |    ...we wrote 1 tile...
    INY                     ; |    ...each OAM entry is 4 bytes long...
    INY                     ; |    ...so increment 4 times
    DEX                     ; | go to next tile of frame and loop
    BPL -                   ; /

    PLX                     ; pull, X = sprite index
    LDY #$FF                ; \ Y = $FF because we've stored to $0460
    LDA #$03                ; | A = number of tiles drawn - 1
    JSL $01B7B3|!BankB      ; / don't draw if offscreen
    RTS

OtherSprite:
    LDA !14C8,x
    CMP #$08
    BNE OtherSprite_return
    LDA $9D
    BNE OtherSprite_return
    LDA #$00
    %SubOffScreen()
    LDA !1588,x
    AND #$04
    BNE GenerateClusterSprite
    STZ !sprite_speed_x,x
    LDA #$20
    STA !sprite_speed_y,x
    JSR SecondaryGraphics

    JSL $01802A|!BankB          ; Update X/Y with gravity
    JSL $019138|!BankB          ; Interact with objects
    JSL $01A7DC|!BankB          ; Interact with Mario
    BCC OtherSprite_return      ; Hurt Mario if touching the sprite
    JSL $00F5B7|!BankB
OtherSprite_return:
    RTS

SecondaryGraphics:
    %GetDrawInfo()

    PHX

    LDX #$00
-   PHX

    LDA $00
    STA $0300|!Base2,y

    PLX
    LDA $01
    STA $0301|!Base2,y

    PHX
    LDA #$40
    STA $0302|!Base2,y

    LDA #$05                ; \ tile properties yxppccct, format
    BNE NoFlipS             ; |
    ORA #$40                ; /    ...flip tile
NoFlipS:
    ORA $64                 ; add in tile priority of level
    STA $0303|!Base2,y             ; store tile properties
    PLX                     ; \ pull, current tile

    INY                     ; | increase index to sprite tile map ($300)...
    INY                     ; |    ...we wrote 1 16x16 tile...
    INY                     ; |    ...sprite OAM is 8x8...
    INY                     ; |    ...so increment 4 times
    DEX                     ; | go to next tile of frame and loop
    BPL -                   ; /

    PLX                     ; pull, X = sprite index
    LDY #$02                ; \ why 02? (460 = 2) all 16x16 tiles
    LDA #$00                ; | A = number of tiles drawn - 1
    JSL $01B7B3|!BankB      ; / don't draw if offscreen
    RTS

GenerateClusterSprite:
    LDY #$01
-   LDA.b #!ClusterNumber+!ClusterOffset
    STA !cluster_num,y
    LDA !sprite_x_low,x
    PHA
    AND #$F0
    STA !cluster_x_low,y
    PLA
    LDA !sprite_y_low,x
    STA !cluster_y_low,y
    DEY
    BPL -
    LDA #$01
    STA $18B8|!Base2
    STZ !14C8,x
    RTS
