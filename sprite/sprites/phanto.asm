;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phanto, adapted by yoshicookiezeus
;;
;; For usage with PIXI
;; Uses extra bit: YES
;; If the extra bit is set, the sprite will only hurt Mario when he's carrying a key.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Tilemap = $88          ; The sprite tile used by Phanto.

; The horizontal acceleration of the sprite.
X_Accel:
    db $02,$FE

; The vertical acceleration of the sprite.
Y_Accel:
    db $02,$FE

; The maximum horizontal speed of the sprite.
Max_X_Speed:
    db $28,$D8

; The maximum vertical speed of the sprite.
Max_Y_Speed:
    db $18,$E8

; Names for some sprite tables, do not touch.
!sprite_state = !C2
!sprite_direction = !157C

print "INIT ",pc
    RTL

print "MAIN ",pc
    PHB : PHK : PLB            
    JSR SpriteMain        
    PLB            
    RTL              

SpriteMain:
    JSR Graphics
    LDA !14C8,x             ;\ if sprite state not normal
    CMP #$08                ; |
    BNE Return              ;/ return
    LDA $9D                 ;\ if sprites locked,
    BNE Return              ;/ return

    JSR SubHasKey           ;\ if Mario has a key,
    CPY #$01                ; |
    BEQ Chase               ;/ go to main movement routine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Secondary movement routine
;
; This routine is executed if Mario isn't holding a key, and will slow Phanto down
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    %BES(+)
        JSL $01A7DC|!BankB      ; interact with Mario
+   LDA $14                     ;\ only change speeds every second frame
    AND #$01                    ; |
    BNE ApplySpeed              ;/

    LDA !sprite_speed_x,x       ;\ if x speed zero,
    BEQ XSpeedZero              ;/ branch
    BPL XSpeedPositive          ; if positive, branch
    INC A
    INC A
XSpeedPositive:
    DEC A
    STA !sprite_speed_x,x

XSpeedZero:
    LDA !sprite_speed_y,x       ;\ if y speed zero,
    BEQ YSpeedZero              ;/ branch
    BPL YSpeedPositive          ; if positive, branch
    INC A
    INC A
YSpeedPositive:
    DEC A
    STA !sprite_speed_y,x
YSpeedZero:
    BRA ApplySpeed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main movement routine
;
; If Mario is holding a key, this routine moves Phanto towards him, and accelerates it
; if the speed cap hasn't been hit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Chase:
    JSL $01A7DC|!BankB        ; interact with Mario

    LDA $14                 ;\ only change speeds every fourth frame
    AND #$03                ; |
    BNE ApplySpeed          ;/

    %SubHorzPos()           ;\ if max horizontal speed in the appropriate
    LDA !sprite_speed_x,x   ; | direction achieved,
    CMP Max_X_Speed,y       ; |
    BEQ MaxXSpeedReached    ;/ don't change horizontal speed
    CLC                     ;\ else,
    ADC X_Accel,y           ; | accelerate in appropriate direction
    STA !sprite_speed_x,x   ;/
MaxXSpeedReached:
    %SubVertPos()           ;\ if max vertical speed in the appropriate
    LDA !sprite_speed_y,x   ; | direction achieved,
    CMP Max_Y_Speed,y       ; |
    BEQ ApplySpeed          ;/ don't change vertical speed
    CLC                     ;\ else,
    ADC Y_Accel,y           ; | accelerate in appropriate direction
    STA !sprite_speed_y,x   ;/
ApplySpeed:
    JSL $018022|!BankB      ; apply x speed
    JSL $01801A|!BankB      ; apply y speed
Return:
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_HAS_KEY
;
; If Mario is holding a key, the Y register is set to 1 after this routine has been run
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubHasKey:
    PHX                     ; push Phanto sprite number
    LDY #$00                ; clear Y register
    LDA $1470|!Base2        ;\ if carriying flag not set,
    BEQ .Return             ;/ no need to check for key
    LDX.b #!SprSize-1       ; setup loop variable
-   LDA !9E,x               ;\ if sprite currently being checked isn't key,
    CMP #$80                ; | (key = sprite # 80)
    BNE .NextX              ;/ no need to check anything else for that sprite
    LDA !14C8,x             ;\ if sprite is key, check if it is being carried
    CMP #$0B                ; |
    BNE .NextX              ;/ if it isn't, no more checks
    BRA .HasKey             ; if it is, get out of loop

.NextX
    DEX                     ; increase number of sprite to check
    BPL -                   ; if still sprites left to check, repeat loop
    BRA .Return             ; if not, return

.HasKey
    INY                     ; increase Y register to show that key is being carried
.Return
    PLX                     ; get Phanto sprite number back
    RTS                     ; and return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERIC GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Graphics:
    %GetDrawInfo()

    LDA $00                 ; set x position of the tile
    STA $0300|!Base2,y
    LDA $01                 ; set y position of the tile
    STA $0301|!Base2,y
    LDA.b #!Tilemap
    STA $0302|!Base2,y

    LDA !15F6,x             ; get sprite palette info
    ORA $64                 ; add in the priority bits from the level settings
    STA $0303|!Base2,y      ; set properties

    LDY #$02                ; the tiles drawn were 16x16
    LDA #$00                ; one tile was drawn
    JSL $01B7B3|!BankB      ; finish OAM write
    RTS
