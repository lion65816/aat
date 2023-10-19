;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FryGuy
;; By Sonikku
;; A boss that floats from side to side spitting fireballs. Hitting the boss
;; with a thrown object 3 times will defeat it, causing it to split into four
;; mini-FryGuys. Mini-FryGuys hop toward the player and move faster when
;; there's only 1 left.
;
;; Extra Property Byte 1:
;;   - Bit 1 (%00000001/$01): Last mini-FryGuy triggers boss-defeated sequence.
;
;; If the Extra Bit is set, "Hard Mode" is enabled on the boss. This gives it
;; faster moving speed, higher health, more frequent fireball shooting, and
;; also splits into 5 mini-FryGuys rather than 4. Mini-FryGuys in "Hard Mode"
;; move faster, jump more often, and leave "Hopping Flame" flames behind. When
;; defeated, they also explode into a random triangular pattern of fireballs.
;; Fireballs spawned by FryGuy when in "Hard Mode" move slightly faster.

!X_Speed = $02          ; The boss's horizontal acceleration in subpixels/frame² (subpixels/frame^2).
!X_Speed_Hard = $04     ; The boss's horizontal acceleration when the extra bit is set.

!Y_Speed = $01          ; The boss's vertical acceleration in subpixels/frame² (subpixels/frame^2).
!Y_Speed_Hard = $03     ; The boss's vertical acceleration when the extra bit is set.

!HP = $02               ; Number of hits before the boss splits apart
!HP_Hard = $05          ; Number of hits before the boss splits apart when the extra bit is set (AAT edit)
;!HP_Hard = $03          ; Number of hits before the boss splits apart when the extra bit is set

!SpawnFireballs = 1     ; If 0, Mini-Fryguys won't spawn fireballs when they die.

!FireSound = $27        ; Sound to play when spawning a fireball.
!FireBank = $1DFC

!HitSound = $28         ; Sound to play when the boss gets hurt (played together with !ShellSound)
!HitBank = $1DFC

!ShellSound = $13       ; Sound to play when the boss gets hurt (played together with !HitSound)
!ShellBank = $1DF9

!MiniHurtSound = $28    ; Sound to play when a Mini-Fryguy gets killed.
!MiniHurtBank = $1DFC

!GoalMusic = $03        ; Music to play when ending the level. Set to $03 if using AddmusicK! (AAT edit)
;!GoalMusic = $0B        ; Music to play when ending the level. Set to $03 if using AddmusicK!

; Sprite code below, do not touch.

; Workaround for sublabels.
%SubHorzPos()

print "INIT ",pc
    STZ !1510,x
    LDA #$30                        ; \ timer before firing
    STA !15AC,x                     ; /
    LDY.b #!HP
    LDA !7FAB10,x                   ; \
    AND #$04                        ;  | branch if extra bit clear
    BEQ +                           ; /
        LDY.b #!HP_Hard
        ; AAT edit: The palette is yellow when in easy mode.
        LDA #$05                    ; \ set palette
        STA !15F6,x                 ; /
        ;LDA #$09                    ; \ set palette
        ;STA !15F6,x                 ; /
        ;INC !1510,x                 ; set hardmode
+   TYA                             ; \ set health from y
    STA !1528,x                     ; /
    LDA !1686,x                     ; disable sprite interaction
    ORA #$08
    STA !1686,x
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    JSR SpriteCode
    PLB
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite routine

SpriteCode:
    LDA #$00
    %SubOffScreen()

+   LDA !1602,x                 ; \
    CMP #$09                    ;  | make sprite invisible if frame is #$09
    BEQ +                       ; /
        JSR Graphics            ; jump to gfx
+   LDA !C2,x                   ; pointer
    ASL A
    TAX
    JMP.w (Pointers,x)

Pointers:
    dw FryGuyBoss
    dw MiniFryGuy
    dw FryerBall

FryGuyBoss:
    LDX $15E9|!Base2

    ; AAT edit: Change to hard mode when 3 HP is left.
    LDA !1528,x
    CMP #$02
    BNE +
    LDA #$09                        ; \ set palette
    STA !15F6,x                     ; /
    LDA #$01                        ; \ enrage
    STA !1510,x                     ; /
+
    LDA $9D                         ; \ branch if sprites locked
    BNE .return                     ; /
    LDA !1662,x                     ; \
    ORA #$30                        ;  | override clipping
    STA !1662,x                     ; /
    LDA !1504,x                     ; \ branch if sprite should be hurt
    BEQ +                           ; /
    STZ !1504,x                     ; clear hurt flag
    LDA #$40                        ; \ set hurt timer
    STA !163E,x                     ; /
    LDA #$50                        ; \
    STA !15AC,x                     ; /
    DEC !1528,x                     ; decrement health
    LDA.b #!HitSound                ; \ play sound
    STA.w !HitBank|!Base2           ; /
    LDA.b #!ShellSound              ; \ play sound
    STA.w !ShellBank|!Base2         ; /
    LDA #$03                        ; \ give points
    JSL $02ACE5|!BankB              ; /
+   LDA !163E,x                     ; \ branch if not stunned
    BEQ .notStunned                 ; /
    CMP #$01                        ; \ branch if sprite shouldn't split
    BNE +                           ; /
    LDA #$20                        ; \
    STA !1540,x                     ; / reset shoot timer
    STZ !1594,x                     ; reset shoot counter
    LDA !1528,x                     ; \ branch if health positive
    BPL +                           ; /
.split
    STZ !14C8,x                     ; kill sprite
    JSR .spawnMinifryguy
+   INC !1570,x                     ; \
    LSR #3                          ;  |
    AND #$01                        ;  | animate sprite
    INC #2                          ;  |
    STA !1602,x                     ; /
.return
    RTS

.notStunned
    JSR .xMovement
    JSR .yMovement

    LDA $1490|!Base2
    BEQ ++
    LDA !167A,x : PHA
    LDA #$80
    STA !167A,x
    JSL $01A7DC|!BankB
    BCC +
        INC !1504,x
+   PLA : STA !167A,x
    BRA +++

++  JSL $01A7DC|!BankB
+++ LDY.b #!SprSize-1
-   STX $00                         ; \
    CPY $00                         ;  | branch if sprite processed is itself
    BEQ .loop                       ; /
    LDA !14C8,y                     ; \
    CMP #$09                        ;  | branch if sprite isn't carriable
    BCC .loop                       ; /
    CMP #$0B                        ; \ branch if sprite is carried
    BEQ .loop                       ; /
    PHX                             ; \
    TYX                             ;  |
    JSL $03B6E5|!BankB              ;  |
    PLX                             ;  | check interaction between both sprites
    JSL $03B69F|!BankB              ;  |
    JSL $03B72B|!BankB              ;  |
    BCC .loop                       ; /
    INC !1504,x                     ; hurt sprite
    LDA #$02                        ; \ kill thrown sprite
    STA !14C8,y                     ; /
    PHX                             ; \
    LDX #$00                        ;  |
    LDA.w !B6|!Base1,y              ;  |
    BPL +                           ;  | set killed x speed
        INX                         ;  |
+   LDA .killedX,x                  ;  |
    PLX                             ;  |
    STA.w !B6|!Base1,y              ; /
    BRA .noContact

.loop
    DEY
    BPL -
.noContact
    INC !1570,x
    LDA !1570,x                     ; \
    LSR #3                          ;  | animate
    AND #$01                        ;  |
    STA !1602,x                     ; /
    LDA !15AC,x                     ; \ branch if not ready to fire
    BNE +                           ; /
    LDA #$20                        ; \ set time before firing again
    STA !15AC,x                     ; /
    LDA !1510,x                     ; \ branch if sprite is easy mode
    BEQ .clear                      ; /
    LDA #$06                        ; \ set time before firing again
    STA !15AC,x                     ; /
    INC !1594,x                     ; increment counter
    LDA !1594,x                     ; \
    CMP #$03                        ;  | branch if counter is not 4
    BCC .clear                      ; /
    LDA #$20                        ; \ set time before firing again
    STA !15AC,x                     ; /
    STZ !1594,x                     ; clear counter
.clear
    JSR .spawnFireball
+   RTS

.killedX
    db $08,$F8

.xMovement
    JSL $018022|!BankB              ; move x position based on speed
    LDA !157C,x                     ; \
    AND #$01                        ;  | get horizontal direction
    STA $00                         ; /
    TAY
    LDA !1510,x                     ; \ branch if easy mode
    BEQ +                           ; /
        INY #2
+   LDA .X_Max,y                    ;\ branch if sprite is moving left or right
    BPL .positive                   ; /
    LDA !B6,x                       ; \
    CMP .X_Max,y                    ; | accelerate if needed
    BPL .accel                      ; /
    BRA .noAccel

.positive
    LDA !B6,x                       ; \
    CMP .X_Max,y                    ; | accelerate if needed
    BPL .noAccel                    ; /
.accel
    LDA !B6,x                       ; \
    CLC : ADC .X_Accel,y            ;  | accelerate
    STA !B6,x                       ; /
.noAccel
    LDA !14E0,x                     ; \
    XBA                             ;  |
    LDA !E4,x                       ;  |
    REP #$20                        ;  |
    SEC : SBC $1A                   ;  |
    STA $01                         ;  | set direction based on position onscreen
    LDY $00                         ;  |
    BEQ .moveLeft                   ;  |
    LDA $01                         ;  |
    CMP #$0030                      ;  |
    BPL ++                          ;  |
    BRA +                           ;  |

.moveLeft
    CMP #$00B8                      ;  |
    BMI ++                          ;  |
+   SEP #$20                        ;  |
    INC !157C,x                     ;  |
++  SEP #$20                        ; /
    RTS

.X_Max
    db $28,$D8
    db $38,$C8

.X_Accel
    db !X_Speed,-!X_Speed
    db !X_Speed_Hard,-!X_Speed_Hard

.yMovement
    JSL $01801A|!BankB              ; move y position based on speed
    LDY !151C,x
    LDA !1510,x                     ; \ branch if easy mode
    BEQ +                           ; /
        INY #2
+   LDA .Y_Max,y                    ;\ branch if sprite is moving up or down
    BPL +                           ; /
    LDA !AA,x                       ; \
    CMP .Y_Max,y                    ; | accelerate if needed
    BMI .noAccelY                   ; /
    BRA ++

+   LDA !AA,x                       ; \
    CMP .Y_Max,y                    ; | accelerate if needed
    BPL .noAccelY                   ; /
++  LDA !AA,x
    CLC : ADC .Y_Accel,y
    STA !AA,x
.noAccelY
    TYA
    ASL A
    TAY
    STZ !151C,x                     ; \
    LDA !14D4,x                     ;  |
    XBA                             ;  |
    LDA !D8,x                       ;  |
    REP #$20                        ;  |
    SEC : SBC $1C                   ;  | set direction based on position onscreen
    CLC : ADC .Y_Bounds,y           ;  |
    SEP #$20                        ;  |
    BMI +                           ;  |
        INC !151C,x                 ; /
+   RTS

.Y_Max
    db $18,$E8
    db $24,$CC

.Y_Accel
    db !Y_Speed,-!Y_Speed_Hard
    db !Y_Speed_Hard,-!Y_Speed_Hard

.Y_Bounds
    dw $FF90,$FFA0
    dw $FF90,$FFA0

.spawnFireball
    JSL $02A9DE|!BankB              ; when too many sprites on screen..
    BMI .noSpawn                    ; return

    LDA.b #!FireSound               ; \ play sound effect
    STA.w !FireBank|!Base2          ; /

    LDA #$08                        ; \
    STA !14C8,y                     ;  |
    LDA !7FAB9E,x                   ;  |
    PHX : TYX                       ;  | handle sprite spawned
    STA !7FAB9E,x                   ;  |
    PLX                             ; /

    LDA !E4,x                       ; \
    CLC : ADC #$08                  ;  |
    STA.w !E4,y                     ;  |
    LDA !14E0,x                     ;  |
    ADC #$00                        ;  | setup x/y positions relative to sprite
    STA !14E0,y                     ;  |
    LDA !D8,x                       ;  |
    STA.w !D8,y                     ;  |
    LDA !14D4,x                     ;  |
    STA !14D4,y                     ; /

    LDA !1510,x
    PHX : TYX
    STA !1510,x                     ; \
    JSL $07F7D2|!BankB              ;  |
    JSL $0187A7|!BankB              ;  | handle setting as a custom sprite
    LDA #$08                        ;  |
    STA !7FAB10,x                   ; /

    LDA #$02                        ; \ set state
    STA !C2,x                       ; /

    JSL $01ACF9|!BankB              ; \
    EOR $13                         ;  |
    SBC $94                         ;  |
    ADC !E4,x                       ;  |
    ORA !D8,x                       ;  | setup x speeds
    AND #$03                        ;  |
    TAY                             ;  |
    LDA .Fireball_X_Speed,y
    STA !B6,x                       ;  |
    PLX                             ; /
.noSpawn
    RTS

.Fireball_X_Speed
    db $F8,$08,$FE,$02

.spawnMinifryguy
    LDY #$03
    LDA !1510,x                     ; \ branch if easy mode
    BEQ +                           ; /
    LDY #$04
- : +
    STY $0C                         ; set times to loop
    PHY
    JSR +                           ; load multiple times
    PLY
    DEY
    BPL -
    RTS

+   JSL $02A9DE|!BankB              ; when too many sprites on screen..
    BMI .noSpawnMini                ; return

    LDA #$08                        ; \
    STA !14C8,y                     ;  |
    LDA !7FAB9E,x                   ;  |
    PHX : TYX                       ;  | handle sprite spawned
    STA !7FAB9E,x                   ;  |
    PLX                             ; /

    LDA !E4,x                       ; \
    CLC : ADC #$08                  ;  |
    STA.w !E4,y                     ;  |
    LDA !14E0,x                     ;  |
    ADC #$00                        ;  |
    STA !14E0,y                     ;  |
    LDA !D8,x                       ;  |
    CLC : ADC #$F8                  ;  |
    STA.w !D8,y                     ;  |
    LDA !14D4,x                     ;  |
    ADC #$FF                        ;  |
    STA !14D4,y                     ; /

    LDA !1510,x
    PHX : TYX                       ; \
    STA !1510,x                     ;  |
    JSL $07F7D2|!BankB              ;  |
    JSL $0187A7|!BankB              ;  | handle setting as a custom sprite
    LDA #$08                        ;  |
    STA !7FAB10,x                   ; /

    LDA #$01                        ; \ mark as mini fryguy
    STA !C2,x                       ; /

    PHY                             ; \
    LDY $0C                         ;  |
    LDA .minifryguy_X_Speed,y
    STA !B6,x                       ;  | set x and y speeds
    LDA .minifryguy_Y_Speed,y
    STA !AA,x                       ;  |
    PLY                             ;  |
    PLX                             ; /
.noSpawnMini
    RTS

.minifryguy_X_Speed
    db $D0,$30,$F0,$10,$00

.minifryguy_Y_Speed
    db $E0,$E0,$D0,$D0,$F0

MiniFryGuy:
    LDX $15E9|!Base2

    LDA $9D                         ; \ branch if sprites locked
    BNE .return                     ; /

    JSL $018032|!BankB              ; interact with other sprites

    STZ !1656,x                     ; set clipping
    LDA !1528,x                     ; \ branch if last one "alive"
    BEQ .normal                     ; /
    LDA #$09                        ; \ set frame
    STA !1602,x                     ; /
    LDA !1540,x                     ; \ branch if timer says to stay alive
    BNE +                           ; /
    STZ !14C8,x                     ; kill sprite
    LDA !7FAB28,x                   ; \
    AND #$01                        ;  | branch if sprite shouldn't end level
    BEQ +                           ; /
    LDA $1493|!Base2                ; \
    BNE +                           ;  |
    INC $13C6|!Base2                ;  |
    LDA #$FF                        ;  | end level
    STA $1493|!Base2                ;  |
    LDA.b #!GoalMusic               ;  |
    STA $1DFB|!Base2                ; /
+   RTS

.normal
    LDA !14C8,x                     ; \
    CMP #$08                        ;  | branch if alive
    BEQ +                           ; /
    CMP #$01                        ; \ return if init
    BEQ .return                     ; /
    LDA !1540,x                     ; \ branch if timer set
    BNE +                           ; /
-
    if !SpawnFireballs == 1
        JSR .spawnFireballs             ; spawn fireballs    
    endif

    LDA #$08                        ; \ sprite is alive again
    STA !14C8,x                     ; /
    LDA #$10                        ; \ set dead timer
    STA !1540,x                     ; /
    LDA.b #!MiniHurtSound           ; \ play sound
    STA.w !MiniHurtBank|!Base2      ; /
    LDA !1686,x                     ; \
    ORA #$08                        ;  | sprite can't die
    STA !1686,x                     ; /
    LDA #$80                        ; \ don't interact with stuff
    STA !1564,x                     ; /
    JSR .killOwnFires               ; kill own hopping flame fires
.return
    RTS

+   LDA !1540,x                     ; \ branch if alive
    BEQ .alive                      ; /
    CMP #$01                        ; \ branch if not dying right now
    BNE .dying                      ; /
    JSR .killOwnFires               ; kill own hopping flame fires
    JSR .findOthers                 ; \ get number of other alive mini fryguys
    BEQ +                           ; / branch if 0
        STZ !14C8,x                 ; kill sprite
+   LDA #$40                        ; \ set timer
    STA !1540,x                     ; /
    LDA #$01                        ; \ set dead flag
    STA !1528,x                     ; /
    LDA #$09                        ; \
    BRA +                           ;  |

.dying
    LSR #3                          ;  | death animation
    CLC : ADC #$04                  ;  |
+   STA !1602,x                     ; /
    RTS

.alive
    LDA !164A,x                     ; \ branch if falling in water
    BNE -                           ; /
    JSL $01A7DC|!BankB              ; default interaction with mario
    LDA !1588,x                     ; \
    AND #$03                        ;  | branch if not touching wall
    BEQ +                           ; /
    LDA !B6,x                       ; \
    EOR #$FF : INC A                ;  | negate x speed
    STA !B6,x                       ; /
+   INC !1570,x
    LDA !1570,x                     ; \
    LSR #2                          ;  | animate sprite
    AND #$03                        ;  |
    STA !1602,x                     ; /
    JSL $01802A|!BankB              ; gravity
    LDA !157C,x
    BEQ +
    LDA !163E,x                     ; \
    LSR A                           ;  |
    AND #$01                        ;  |
    TAY                             ;  |
    LDA !E4,x                       ;  |
    CLC : ADC .xpos,y               ;  | shake sprite if needed
    STA !E4,x                       ;  |
    LDA !14E0,x                     ;  |
    ADC .xpos2,y                    ;  |
    STA !14E0,x                     ; /
    LDA !163E,x                     ; \ branch if shaking
    BNE +                           ; /
    STZ !157C,x
    JSL $01ACF9|!BankB              ; \
    EOR $13                         ;  |
    SBC $94                         ;  |
    ADC !E4,x                       ;  |
    AND #$03                        ;  |
    TAY                             ;  |
    ASL A                           ;  |
    STA $00                         ;  |
    LDA .yspeed,y                   ;  | make sprite jump
    STA !AA,x                       ;  |
    %SubHorzPos()                   ;  |
    TYA                             ;  |
    CLC : ADC $00                   ;  |
    TAY                             ;  |
    LDA .xspeed,y                   ;  |
    STA !B6,x                       ; /
    LDA !1594,x                     ; \ branch if moving faster
    BNE ++                          ; /
    JSR .findOthers                 ; find other fryguys
    DEC
    BNE ++
    LDA #$01                        ; \ make last one move faster
    STA !1594,x                     ; /
++  LDA !1510,x                     ; \ branch if easy mode
    BEQ +                           ; /
        STZ $00
        JSR .spawnFlame             ; spawn hopping flame fire
+   LDA !1588,x                     ; \
    AND #$04                        ;  | branch if in the air
    BEQ .inAir                      ; /
    LDA !AA,x                       ; \ branch if moving up
    BMI +                           ; /
    LDA !157C,x                     ; \ branch if sprite has been on ground
    BNE +                           ; /
    STZ !B6,x                       ; no x speed
    LDA !1510,x                     ; \
    ASL A                           ;  |
    CLC : ADC !1594,x               ;  | set timer
    TAY                             ;  |
    LDA .timer,y                    ;  |
    STA !163E,x                     ; /
    LDA #$01                        ; \ set on ground (now) state
    STA !157C,x                     ; /
+   RTS

.inAir
    STZ !157C,x
    RTS

.xspeed
    db $18,$E8
    db $14,$EC
    db $10,$F0
    db $0C,$F4

    db $24,$DC
    db $20,$E0
    db $18,$E8
    db $14,$EC

.yspeed
    db $E8,$E0,$D8,$C8
    db $E0,$D8,$D0,$C0

.timer
    db $38,$20
    db $28,$0C

.xpos
    db $01,$FF

.xpos2
    db $00,$FF

.findOthers
    STZ $00
    LDY.b #!SprSize-1
-   LDA !14C8,y                     ; \
    CMP #$08                        ;  | branch if sprite isn't alive
    BNE .loop                       ; /
    PHX : TYX                       ; \
    LDA !7FAB10,x                   ;  | branch if not custom sprite
    AND #$0C                        ;  |
    PLX                             ;  |
    BEQ .loop                       ; /
    PHX : TYX                       ; \
    LDA !7FAB9E,x                   ;  | branch if not THIS sprite
    PLX                             ;  |
    CMP !7FAB9E,x                   ;  |
    BNE .loop                       ; /
    LDA.w !C2|!Base1,y              ; \
    CMP #$01                        ;  | branch if not mini fryguy
    BNE .loop                       ; /
    LDA !1540,y                     ; \ branch if mini fryguy dying
    BNE .loop                       ; /
    INC $00
.loop
    DEY
    BPL -
    LDA $00
    RTS

.spawnFireballs
    JSL $01ACF9|!BankB              ; \ get random pattern
    STA $0C                         ; /
    LDY #$02
    STY $00
-   STY $01
    PHY
    JSR .spawnFlame                 ; spawn flame
    PLY
    DEY
    BPL -
    RTS

.spawnFlame
    LDY #$07
-   LDA $170B|!Base2,y              ; \ branch if free slot
    BEQ ++                          ; /
    DEY
    BPL -
    DEC $18FC|!Base2                ; \ try to find free slot
    BPL +                           ; /
    LDA #$07                        ; \ force free slot
    STA $18FC|!Base2                ; /
+   LDY $18FC|!Base2
++  LDA !E4,x                       ; \
    CLC : ADC #$04                  ;  |
    STA $171F|!Base2,y              ;  | fireballs are center of sprite
    LDA !14E0,x                     ;  |
    ADC #$00                        ;  |
    STA $1733|!Base2,y              ; /
    LDA $00                         ; \ branch if spawned sprite is hopping flame
    BEQ .hoppingFlame               ; /
    LDA !D8,x                       ; \
    CLC : ADC #$04                  ;  |
    STA $1715|!Base2,y              ;  | fireballs are center of sprite
    LDA !14D4,x                     ;  |
    ADC #$00                        ;  |
    STA $1729|!Base2,y              ; /
    LDA #$02                        ; \ extended sprite number
    STA $170B|!Base2,y              ; /
    LDA #$00                        ; \ reset graphics table
    STA $1765|!Base2,y              ;  | and layer flag
    STA $1779|!Base2,y              ; /
    PHX                             ; \
    LDA $0C                         ;  |
    AND #$03                        ;  |
    STA $02                         ;  |
    ASL A                           ;  | get pattern
    CLC : ADC $02                   ;  |
    ADC $01                         ;  |
    TAX                             ; /
    LDA .fireball_xspeed,x
    STA $1747|!Base2,y              ; set x speed
    LDA .fireball_yspeed,x
    STA $173D|!Base2,y              ; set y speed
    PLX
    RTS

.fireball_xspeed
    db $18,$E8,$00
    db $18,$E8,$00
    db $F0,$F0,$18
    db $10,$10,$E8

.fireball_yspeed
    db $F0,$F0,$18
    db $10,$10,$E8
    db $18,$E8,$00
    db $18,$E8,$00

.hoppingFlame
    LDA !D8,x                       ; \
    CLC : ADC #$08                  ;  |
    STA $1715|!Base2,y              ;  | fireballs are at bottom of sprite
    LDA !14D4,x                     ;  |
    ADC #$00                        ;  |
    STA $1729|!Base2,y              ; /
    LDA #$03                        ; \ extended sprite number
    STA $170B|!Base2,y              ; /
    LDA #$80                        ; \ timer
    STA $176F|!Base2,y              ; /
    LDA #$00                        ; \ reset graphics table
    STA $1765|!Base2,y              ;  | and layer flag
    STA $1779|!Base2,y              ; /
    TXA                             ; \ use unused ram so this sprite can flag
    STA $173D|!Base2,y              ; / hopping flame fires as their own (and kill them when they die)
    RTS

.killOwnFires
    LDY #$0A
-   LDA $170B|!Base2,y              ; \
    CMP #$03                        ;  | branch if not hopping flame fire
    BNE +                           ; /
    TXA                             ; \
    CMP $173D|!Base2,y              ;  | branch if it wasn't created by this one
    BNE +                           ; /
    LDA #$00                        ; \ kill extended sprite
    STA $170B|!Base2,y              ; /
+   DEY
    BPL -
    RTS

FryerBall:
    LDX $15E9|!Base2

    LDA $9D                         ; \ branch if sprites locked
    BNE .return                     ; /
    LDA !164A,x                     ; \ branch if sprite isn't in water
    BEQ +                           ; /
    LDA #$04                        ; \
    STA !14C8,x                     ;  | turn to smoke
    LDA #$14                        ;  |
    STA !1540,x                     ; /
+   JSL $01A7DC|!BankB              ; interact with mario
    LDA !1656,x                     ; \
    ORA #$80                        ;  | disappears in smoke
    STA !1656,x                     ; /
    JSL $019138|!BankB              ; interact with objects
    LDA !1588,x                     ; \
    AND #$04                        ;  | branch if not touching ground
    BEQ +                           ; /
        LDA #$04                    ; \
        STA !14C8,x                 ;  | turn to smoke
        LDA #$18                    ;  |
        STA !1540,x                 ; /
+   INC !1570,x
    LDA !1570,x                     ; \
    LSR #2                          ;  |
    AND #$03                        ;  |
    CMP #$03                        ;  |
    BCC +                           ;  | animate sprite
        STZ !1570,x                 ;  |
        LDA #$00                    ;  |
+   CLC : ADC #$06                  ;  |
    STA !1602,x                     ; /
    JSL $01801A|!BankB              ; \ x and y speeds
    JSL $018022|!BankB              ; /
    LDY !1510,x
    LDA !AA,x                       ; \
    CMP .ymax,y                     ;  |
    BPL .return                     ;  |
    LDA !AA,x                       ;  | accelerate sprite y speed
    CLC : ADC .yaccel,y             ;  |
    STA !AA,x                       ; /
.return
    RTS

.ymax
    db $40,$50

.yaccel
    db $02,$04

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine

Graphics:
    %GetDrawInfo()
    LDA !C2,x
    BEQ +
    LDA !1602,x
    PHX
    TAX
    LDA $00
    STA $0300|!Base2,y
    LDA $01
    CLC : ADC .ypos3,x
    STA $0301|!Base2,y
    LDA .tilemap3,x
    STA $0302|!Base2,y
    LDA #$05
    ORA .properties3,x
    ORA $64
    STA $0303|!Base2,y
    PLX
    LDA #$00
    JMP .finishOAM

+   LDA !1570,x
    LSR #2
    AND #$03
    ASL #2
    STA $02
    LDA !1602,x
    STA $03
    PHY
    LDY !15F6,x
    LDA !163E,x
    BEQ +
        ASL A
        INC A
        AND #$0F
        TAY
+   STY $04
    LDY !15F6,x                     ;\ AAT edit: Load palette from this table instead.
    ;LDY #$05                       ;/ Helps account for the enraged state.
    LDA !163E,x
    BEQ +
        ASL A
        INC A
        AND #$0F
        TAY
+   STY $05
    PLY
    PHX
    LDA $00
    CLC : ADC #$08
    STA $0300|!Base2,y
    LDA $01
    ;CLC : ADC #$FE
    CLC : ADC #$F8                  ;> AAT edit: Move face up a bit.
    STA $0301|!Base2,y
    LDX $03
    LDA .tilemap2,x
    STA $0302|!Base2,y
    LDA $04
    ORA .properties2,x
    ORA $64
    STA $0303|!Base2,y
    INY #4

    LDX #$03
-   PHX
    LDA $00
    CLC : ADC .xpos,x
    STA $0300|!Base2,y
    LDA $01
    CLC : ADC .ypos,x
    STA $0301|!Base2,y
    TXA
    CLC : ADC $02
    TAX
    LDA .tilemap,x
    STA $0302|!Base2,y
    LDA .properties,x
    ORA $05
    ORA $64
    STA $0303|!Base2,y
    PLX
    INY #4
    DEX
    BPL -
    PLX
    LDA #$04
.finishOAM
    LDY #$02
    JSL $01B7B3|!BankB
    RTS

.xpos
    db $00,$10,$00,$10

.ypos
    db $F0,$F0,$00,$00

.tilemap
    db $80,$82,$A0,$A2
    db $84,$86,$A4,$A6
    db $82,$80,$A2,$A0
    db $86,$84,$A6,$A4

.properties
    db $00,$00,$00,$00
    db $00,$00,$00,$00
    db $40,$40,$40,$40
    db $40,$40,$40,$40

.tilemap2
    db $C0,$C2,$C4,$C4
.properties2
    db $00,$00,$00,$40

.tilemap3
    db $A8,$AA,$A8,$AA,$AE,$8E
    db $88,$8A,$8C
.ypos3
    db $00,$00,$00,$00,$F4,$FC
    db $00,$00,$00
.properties3
    db $00,$00,$40,$40,$00,$00
    db $00,$00,$00
