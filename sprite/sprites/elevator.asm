;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Turn Block Bridge, adapted by mikeyk, further modified by Sukasa into the
;;                        1337 elevator sprite 2.0
;;
;; Description: A 32 x 48 pixel Elevator sp.  F*cking awesome if you ask me.
;; Animated too.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(Small change by Rykon-V73): Edit the tilemap and palette below. It also has a better description.
!ElevUPL		 = $80	;upper-left part of elevator.
!ElevUPR		 = $82  ;upper-right part of elevator.
!ElevMPL		 = $84  ;middle-left part of elevator.
!ElevMPR		 = $86	;middle-right part of elevator.
!ElevContLAnim1		 = $A0	;left part of the control tile of the elevator, frame 1.
!ElevContLAnim2 	 = $C0	;right part of the control tile of the elevator, frame 1.
!ElevContRAnim1		 = $88	;left part of the control tile of the elevator, frame 2.
!ElevContRAnim2		 = $C2  ;right part of the control tile of the elevator, frame 2.
;;Edit the palette below. I'll explain its options.
!PaletteChoice		 = $33	;the values follows the YXPPCCCT format. Only PP, CCC and T are needed. The number in parenthesis are in bit format.(PP-layer priority; 00 - lowest priority; 01 - decent priority; 10 - good priority; 11 - highest priority; CCC -palette; 000 - palette 8; 001 - palette 9; 010 - palette A; 011 - palette B; 100 - palette C; 101 - palette D; 110 - palette E; 111 - palette F) If you want the sprite to be on the 2nd layer priority, use palette C and GFX page 1, not that you want to, then it's $18.

;symbolic names for ram addresses - DON'T change them or you'll break the sprite, and maybe even SMW.  Not good.
!MARIO_X_SPEED   = $7B
!MARIO_Y_SPEED   = $7D
!MARIO_X_POS     = $94
!MARIO_X_POS_HI  = $95
!MARIO_Y_POS     = $96
!MARIO_Y_POS_HI  = $97
!SPRITE_STATE    = !sprite_misc_c2
!STATE           = !sprite_misc_1540
!UPSPEED         = !extra_prop_1
!DOWNSPEED       = !extra_prop_2

!YOSHI_OFFSET    = $10
!SIZE            = $08

; A0, A2, C0, and C2 are the tile numbers for the two frames of animation in the bottom row of tiles.
; The other four bytes are the standard non-animated tiles.
Tilemap:    db !ElevContLAnim1,!ElevContRAnim1,!ElevContLAnim2,!ElevContRAnim2,!ElevUPL,!ElevUPR,!ElevMPL,!ElevMPR
X_Offset:   db $F8,$08,$F8,$08,$F8,$08,$F8,$08
Y_Offset:   db $00,$00,$00,$00,$E0,$E0,$F0,$F0

; Palette E, layer priority 3, Sprite GFX page 1 (page 0x3 in the 8x8 editor)
!Properties = !PaletteChoice

print "INIT ",pc
    LDA !sprite_x_low,x
    CLC : ADC #$08
    STA !sprite_x_low,x
    LDA #$02
    STA !STATE,x
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    JSR SpriteCode
    PLB
    RTL

SpriteCode:
    LDA !STATE,x
    INC A
    STA !STATE,x
    LDA #$00
    %SubOffScreen()
    JSR Graphics
    JSR Platform
    JSR Movement
    RTS

Movement:
    JSL $019138|!BankB

    LDY #$00
    LDA !SPRITE_STATE,x
    BEQ .setSpeed

    LDA !sprite_blocked_status,x   ; if the elevator is on the ground
    AND #$04
    BNE .notDown

    LDA $15                 ; \  Is the player holding down?
    AND #$04                ;  |
    BEQ .notDown            ;  |
    INY                     ;  | Yes, move the sprite down and move to end of routine
    BRA .setSpeed           ; /

.notDown
    LDA !sprite_y_low,x     ; \ Save the Low byte of the Y Position
    PHA                     ; /
    SEC : SBC #$21
    STA !sprite_y_low,x
    LDA !sprite_y_high,x
    PHA
    SBC #$00
    STA !sprite_y_high,x
    PHY

    LDA #$FF                ; must have an upward speed entering this subroutine in order
    STA !AA,x               ; for it to check for ceiling contact
    JSL $019138|!BankB

    PLY
    PLA
    STA !sprite_y_high,x
    PLA
    STA !sprite_y_low,x

    LDA !sprite_blocked_status,x   ; \ And check to see if the sprite is hitting the ceiling.
    AND #$08                ;  |
    BNE .setSpeed           ; /

    LDA $15                 ; \ Original code - is Player holding up?
    AND #$08                ;  |
    BEQ .setSpeed           ;  |
    INY #2

.setSpeed
    CPY #$02                ; Set up sprite speed based on Y value from above routine
    BNE .notUp
    LDA !UPSPEED,x
    BRA .doneSet

.notUp
    CPY #$01
    BNE +
    LDA !DOWNSPEED,x
    BRA .doneSet

+   LDA #$00

.doneSet
    STA !sprite_speed_y,x

    JSL $01801A|!BankB  ; Update Y position without gravity
    RTS

Graphics:
    %GetDrawInfo()
    PHX                     ; push sprite index

    LDX #$07                ; loop counter = (number of tiles per frame) - 1
-   PHX                     ; push current tile number

    CPX #$03
    BNE NoChange            ; Is this the first tile of the bottom bit?
    PLX                     ; Yes, proceed to get spite number into X.
    STX $0F
    PLX
    PHX                     ; Sprite number is now in X, tile number is in $0F
    LDA $15
    AND #$0C                ; Are any D-pad Up/Down keys pressed?
    BEQ NoChange2
    LDA !STATE,x            ; \ This bit slows the animation down to a quarter.
    AND #$0F                ;  |
    INC A
    INC A
    STA !STATE,x            ;  |
    DEC A
    AND #$08                ; /
    BEQ NoChange2
    LDA !SPRITE_STATE,x        ; Only animate if Mario is standing on this sprite, never otherwise.
    BEQ NoChange2
    LDX $0F
    DEX
    DEX
    PHX
    BRA NoChange

NoChange2:
    LDX $0F
    PHX
NoChange:
    LDA $00                 ; \ tile x position = sprite x location ($00)
    CLC : ADC X_Offset,x    ;  |
    STA $0300|!Base2,y       ; /

    LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
    CLC : ADC Y_Offset,x
    STA $0301|!Base2,y       ; /

    LDA Tilemap,x           ; \ store tile
    STA $0302|!Base2,y       ; /

    LDA #!Properties
    STA $0303|!Base2,y       ; / store tile properties

    PLX                     ; \ pull, X = current tile of the frame we're drawing
    INY                     ;  | increase index to sprite tile map ($300)...
    INY                     ;  |    ...we wrote 1 16x16 tile...
    INY                     ;  |    ...sprite OAM is 8x8...
    INY                     ;  |    ...so increment 4 times
    CPX #$02                ;  |    Only draw one set of bottom tiles - if this is last
    BEQ LoopEnd             ;  |    tile of the first set, then exit the loop.
    DEX                     ;  | go to next tile of frame and loop
    BPL -                   ; /

LoopEnd:
    PLX                     ; pull, X = sprite index

    STZ $00
    STZ $01
    STZ $02
    STZ $03
    LDY #$00
    LDA #!SIZE
    STA $0000|!Base1,y
    LSR A
    STA $0001|!Base1,y

    LDA $00
    PHA
    LDA $02
    PHA
    INY #4

    LDY #$02                ; \ 02, because we didn't write to 460 yet
    LDA #$05                ;  | A = number of tiles drawn - 1
    JSL $01B7B3|!BankB      ; / don't draw if offscreen

    PLA
    STA $02
    PLA
    STA $00
    RTS

Platform:
    STZ !SPRITE_STATE,x
    LDA !sprite_off_screen,x
    BNE .return

    LDA $71
    CMP #$01
    BCS .return

    JSR CheckClipping
    BCC .return

    LDA !sprite_y_low,x
    SEC : SBC $1C
    STA $02
    SEC : SBC $0D
    STA $09
    LDA $80
    CLC : ADC #$18
    CMP $09
    BCS LBL06
    LDA !MARIO_Y_SPEED
    BMI .return
    LDA !DOWNSPEED,x
    SEC : SBC #$10
    STA !MARIO_Y_SPEED

    LDA #$01
    STA $1471|!Base2
    LDA $0D
    CLC : ADC #$1F

    LDY $187A|!Base2         ; adjust for yoshi
    BEQ +
        CLC : ADC #!YOSHI_OFFSET
+   STA $00

    LDA #$01
    STA !SPRITE_STATE,x

    LDA !sprite_y_low,x
    SEC : SBC $00
    STA !MARIO_Y_POS
    LDA !sprite_y_high,x
    SBC #$00
    STA !MARIO_Y_POS_HI
    LDY #$00
    LDA $1491|!Base2             ; amount to move mario
    BPL +
        DEY
+   CLC : ADC !MARIO_X_POS
    STA !MARIO_X_POS
    TYA
    ADC !MARIO_X_POS_HI
    STA !MARIO_X_POS_HI
.return
    RTS

LBL06:
    LDA $02
    CLC : ADC $0D
    STA $02
    LDA #$FF
    LDY $73
    BNE LBL07
    LDY $19
    BNE SmallMario
LBL07:
    LDA #$08
SmallMario:
    CLC : ADC $80
    CMP $02
    BCC LBL10
    LDA !MARIO_Y_SPEED
    BPL +
        LDA #$10
        STA !MARIO_Y_SPEED
        LDA #$01
        STA $1DF9|!Base2
+   RTS

LBL10:
    LDA $0E
    CLC : ADC #$10
    STA $00
    LDY #$00
    LDA !sprite_x_low,x
    SEC : SBC $1A
    CMP $7E
    BCC LBL11
    LDA $00
    EOR #$FF
    INC A
    STA $00
    DEY
LBL11:
    LDA !sprite_x_low,x
    CLC : ADC $00
    STA !MARIO_X_POS
    TYA
    ADC !sprite_x_high,x
    STA !MARIO_X_POS_HI
    STZ !MARIO_X_SPEED
    RTS

; Sets up RAM for clipping and checks it against the player.
; The sprite's clipping is defined as 32x16, with the top-left at the
; sprite's position.
CheckClipping:
    LDA $00
    STA $0E
    LDA $02
    STA $0D
    LDA !sprite_x_low,x
    SEC : SBC $00
    STA $04
    LDA !sprite_x_high,x
    SBC #$00
    STA $0A
    LDA $00
    ASL A
    CLC : ADC #$10
    STA $06
    LDA !sprite_y_low,x
    SEC : SBC $02
    STA $05
    LDA !sprite_y_high,x
    SBC #$00
    STA $0B
    LDA $02
    ASL A
    CLC : ADC #$10
    STA $07
    JSL $03B664|!BankB
    JSL $03B72B|!BankB
    RTS
