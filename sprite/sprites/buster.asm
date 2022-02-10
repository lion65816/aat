;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SMB3 Buster Beetle
; Coded by SMWEdit
;
; Uses first extra bit: NO
;
; This sprite will pick up block 12E or any block set to act like 12E (by default)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BlockNumber = $0E              ; The sprite number (from list.txt) of buster_block.cfg (the sprite to throw)

!Map16Tile = $012E              ; The Map16 tile the sprite should pick up and throw.
                                ; Acts-like settings are resolved, so this should be on page 0 or 1.

!HorizontalRange = $0080        ; The maximum X distance of Mario for throwing
!VerticalRange = $0030          ; The maximum downward Y distance of Mario for throwing

!RunFrame1 = $0A                ; Sprite tile of the first frame when walking
!RunFrame2 = $0C                ; Sprite tile of the second frame when walking
!GrabFrame = $0E                ; Sprite tile to use while holding a block

!LiftTime = $10                 ; How long it takes for the sprite to lift a block
!HoldThrowTime = $0C            ; How long the sprite should hold a block before throwing it
!PauseMoveTime = $14            ; How long the sprite should wait before walking after picking up a block

; Names for some sprite tables and variables, do not touch.
!sprite_counter = !1504
!sprite_action = !1528
!sprite_tile_index = !1602
!sprite_lift_timer = !163E
!sprite_pause_timer = !1540

!Scratch = $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
    %SubHorzPos()
    TYA
    STA !157C,x
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    JSR SpriteCode
    PLB
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_Speed:        db $10,$F0          ; horizontal speed of the sprite (right, left)
Throw_X_Speed:  db $30,$C0          ; horizontal speed for the thrown block (right, left)

!Throw_Y_Speed = $C0                ; vertical speed for the thrown block

Pickup_Indexes:
    db $02,$02,$02,$02,$02,$02,$02,$02
    db $00,$00,$00,$00,$00,$00,$00,$00

Return:
    RTS

SpriteCode:
    JSR Graphics
    LDA !14C8,x                     ; \  return if
    CMP #$08                        ;  | sprite status
    BNE Return                      ; /  is not 8
    LDA $9D                         ; \ return if
    BNE Return                      ; / sprites locked
    LDA !15D0,x                     ; \ return if
    BNE Return                      ; / being eaten
    LDA #$00
    %SubOffScreen()                 ; only process sprite while on screen

    STZ !B6,x                       ; default: not moving X

    LDA !sprite_pause_timer,x       ; \  if movement is
    BEQ +                           ;  | paused, then
        JMP Returning               ; /  ignore all code
+   LDA !sprite_action,x            ; \  which action
    BEQ +                           ;  | is being performed
        JMP PickingUp               ; /  right now?
+   LDA !1686,x                     ; \  change direction
    AND #%11101111                  ;  | if touched
    STA !1686,x                     ; /
    LDY !157C,x                     ; \  set x speed
    LDA X_Speed,y                   ;  | depending on
    STA !B6,x                       ; /  direction
    LDA !sprite_counter,x           ; \ 
    AND #%00000100                  ;  | set tile index
    LSR A                           ;  | according to
    LSR A                           ;  | a frame counter
    STA !sprite_tile_index,x        ;  |
    INC !sprite_counter,x           ; /
    JSL $01802A|!BankB              ; update position based on speed values, also obj interaction
    LDA !1588,x                     ; \ 
    AND #%00000011                  ;  | not hitting wall? then skip
    BEQ NotHitSide                  ; /
    LDA $1860|!Base2                ; \ 
    CMP.b #!Map16Tile               ;  | Throw block? (or block set to act like one)
    BNE NoPickUp                    ;  | if not, then
    LDA $1862|!Base2                ;  | skip next code
    CMP.b #!Map16Tile>>8            ;  |
    BNE NoPickUp                    ; /
    LDA #$02                        ; \ 
    STA $9C                         ;  | destroy block
    JSL $00BEB0|!BankB              ; /
    LDA.b #!LiftTime                ; \ lifting timer
    STA !sprite_lift_timer,x        ; / for block
    STZ !sprite_counter,x           ; zero counter for next action
    LDA #$01                        ; \ set status to
    STA !sprite_action,x            ; / picking up block
    BRA NotHitSide                  ; skip dir flip code

NoPickUp:
    LDA !157C,x                     ; \  not picking blk
    EOR #%00000001                  ;  | up, so hitting a
    STA !157C,x                     ; /  wall flips dir
NotHitSide:
    JMP Returning                   ; end of running code, return

PickingUp:
    LDA !1686,x                     ; \  don't change
    ORA #%00010000                  ;  | direction if
    STA !1686,x                     ; /  touched
    JSL $01802A|!BankB              ; update position based on speeds, with gravity
    LDY !sprite_lift_timer,x        ; \  set tile index
    LDA Pickup_Indexes,y            ;  | according to how
    STA !sprite_tile_index,x        ; /  far into lifting
    LDA !sprite_lift_timer,x        ; \ skip to end unless
    BNE Returning                   ; / picking up is done
    %SubHorzPos()                   ; \  must face
    TYA                             ;  |
    STA !157C,x                     ; / Mario if ready to Throw
    LDA !sprite_counter,x           ; \ counter != 0 means
    BNE BeginThrow                  ; / throwing already started
    LDA !E4,x                       ; \ 
    CMP $1A                         ;  | if slightly
    LDA !14E0,x                     ;  | off screen (H)
    SBC $1B                         ;  | then Throw
    BNE BeginThrow                  ; /
    LDY #$00                        ; \ 
    LDA !E4,x                       ;  | check H
    STA !Scratch                    ;  | range
    LDA !14E0,x                     ;  |
    STA !Scratch+1                  ;  |
    PHP                             ;  |
    REP #%00100000                  ;  |
    LDA $94                         ;  |
    SEC : SBC !Scratch              ;  |
    BPL +                           ;  |
        EOR.w #$FFFF                ;  |
        INC A                       ;  |
+   CMP.w #!HorizontalRange         ;  |
    BCC +                           ;  |
    LDY #$01                        ;  |
+   PLP                             ;  |
    CPY #$00                        ;  |
    BNE Returning                   ; /
    LDY #$00                        ; \ 
    LDA !D8,x                       ;  | check V
    STA !Scratch                    ;  | range
    LDA !14D4,x                     ;  |
    STA !Scratch+1                  ;  |
    PHP                             ;  |
    REP #%00100000                  ;  |
    LDA $96                         ;  |
    SEC : SBC !Scratch              ;  |
    BMI +                           ;  |
    CMP.w #!VerticalRange           ;  |
    BCC +                           ;  |
    LDY #$01                        ;  |
+   PLP                             ;  |
    CPY #$00                        ;  |
    BNE Returning                   ; /
BeginThrow:
    INC !sprite_counter,x           ; increment counter to get closer to throwing
    LDA !sprite_counter,x           ; \  if throw pause time
    CMP.b #!HoldThrowTime           ;  | has not expired, then
    BCC Returning                   ; /  don't throw the block
    JSR Throw                       ; throw the block
    STZ !sprite_action,x            ; status back to running
    STZ !sprite_counter,x           ; reset counter
    STZ !sprite_tile_index,x        ; tile index = 0 for pause
    LDA.b #!PauseMoveTime           ; \ set timer for
    STA !sprite_pause_timer,x       ; / movement pause
Returning:
    JSL $018032|!BankB              ; interact with other sprites
    JSL $01A7DC|!BankB              ; check for mario/sprite contact
    RTS

Throw:
    JSL $02A9DE|!BankB              ; \ get slot or else
    BMI .end                        ; / end if no slots
    LDA #$01                        ; \ set sprite status
    STA !14C8,y                     ; / as a new sprite
    PHX                             ; back up X
    TYX                             ; new sprite index to X
    LDA.b #!BlockNumber             ; \ store custom
    STA !7FAB9E,x                   ; / sprite number
    JSL $07F7D2|!BankB              ; reset sprite properties
    JSL $0187A7|!BankB              ; get table values for custom sprite
    LDA.b #!CustomBit               ; \ mark as a
    STA !7FAB10,x                   ; / custom sprite
    PLX                             ; load backed up X
    LDA !E4,x                       ; \ 
    STA.w !E4,y                     ;  | set position
    LDA !14E0,x                     ;  | of block to
    STA !14E0,y                     ;  | be thrown
    LDA !D8,x                       ;  |
    SEC : SBC #$0E                  ;  |
    STA.w !D8,y                     ;  |
    LDA !14D4,x                     ;  |
    SBC #$00                        ;  |
    STA !14D4,y                     ; /
    PHY                             ; \ 
    LDY !157C,x                     ;  | set X
    LDA Throw_X_Speed,y             ;  | speed
    PLY                             ;  |
    STA.w !B6|!Base1,y              ; /
    LDA.b #!Throw_Y_Speed           ; \ set Y
    STA.w !AA|!Base1,y              ; / speed
.end
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!TilesDrawn = $04
!CoordIndex = $05

X_Disp:
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$03,$05,$08,$0A,$0C,$0D,$0E
    db $02

Y_Disp:
    db $F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2
    db $F6,$F7,$F8,$F9,$FB,$FC,$FD,$FF
    db $F3

Tilemap:
    db !RunFrame1,!RunFrame2,!GrabFrame

Graphics:
    %GetDrawInfo()

    STZ !TilesDrawn                 ; zero Tilemap drawn so far

    LDA !157C,x                     ; \ direction into
    STA $02                         ; / scratch RAM

    LDA !14C8,x                     ; \  vertical flip
    SEC                             ;  | based on whether or
    SBC #$02                        ;  | not sprite is dying.
    STA $03                         ; /  dying means flip

    LDA $00                         ; \ beetle X
    STA $0300|!Base2,y              ; / position

    LDA $01                         ; \ 
    PHX                             ;  | beetle Y
    LDX $03                         ;  | position,
    BNE +                           ;  | subtract 10
        SEC                         ;  | if dying
        SBC #$10                    ;  |
+   PLX                             ;  |
    STA $0301|!Base2,y              ; /

    PHY                             ; \ 
    LDY !sprite_tile_index,x        ;  | beetle tile based on table
    LDA Tilemap,y                   ;  | entry corresponding to the
    PLY                             ;  | index set in the main code
    STA $0302|!Base2,y              ; /

    LDA !15F6,x                     ; sprite properties
    PHX                             ; \ 
    LDX $02                         ;  | flip if
    BNE +                           ;  | sprite is
        ORA #%01000000              ;  | flipped
+   LDX $03                         ; \ flip V if
    BNE +                           ;  | sprite is
        ORA #%10000000              ;  | dying
+   PLX                             ; /
    ORA $64                         ; add in priority bits
    STA $0303|!Base2,y              ; set properties

    INC !TilesDrawn                 ; indicate a tile was drawn

    LDA !sprite_action,x            ; \ if status is zero, only other status than
    BEQ FinalizeGraphics            ; / block lifting/throwing, don't show block

    LDA !sprite_lift_timer,x        ; \ default coordinate index
    STA !CoordIndex                 ; / is amt left in lift time
    LDA !sprite_counter,x           ; \ 
    CMP #$04                        ;  | if counter for
    BCC +                           ;  | Throw wait time
    CMP #$08                        ;  | elapsed is 4-7,
    BCS +                           ;  | then use slightly
    LDA.b #!LiftTime                ;  | shifted block
    STA !CoordIndex                 ; /
+   INY #4

    PHY                             ; \ 
    LDY !CoordIndex                 ;  | get X
    LDA X_Disp,y                    ;  | coordinate
    LDY $02                         ;  | for block
    BEQ +                           ;  | and flip
        EOR #%11111111              ;  | if sprite
        INC A                       ;  | is flipped
+   PLY                             ; /
    CLC                             ; \ then add it to
    ADC $00                         ; / tile position
    STA $0300|!Base2,y              ; and store the X position

    PHY                             ; \ 
    LDY !CoordIndex                 ;  | get Y
    LDA Y_Disp,y                    ;  | coordinate
    LDY $03                         ;  | for block
    BNE +                           ;  | and flip
        EOR #%11111111              ;  | and subtract
        INC A                       ;  | #$10 if
        SEC                         ;  | sprite is
        SBC #$10                    ;  | dying
+   PLY                             ; /
    CLC                             ; \ then add it to
    ADC $01                         ; / tile position
    STA $0301|!Base2,y              ; and store the Y position

    LDA #$40                        ; \ set block
    STA $0302|!Base2,y              ; / tile number

    LDA $13                         ; \ 
    AND #%00000111                  ;  | cycle through palettes
    ASL A                           ; /
    PHX                             ; \  NOTE: you can cut out the block flipping code, I just thought it might look better with it because the beetle in SMB3 has it
    LDX $02                         ;  | flip if
    BNE +                           ;  | sprite is
        ORA #%01000000              ;  | flipped
+   LDX $03                         ;  | flip V if
    BNE +                           ;  | sprite is
        ORA #%10000000              ;  | dying
+   PLX                             ; /
    ORA $64                         ; add in the priority bits from the level settings
    STA $0303|!Base2,y              ; set properties

    INC !TilesDrawn                 ; indicate a tile was drawn
FinalizeGraphics:
    LDY #$02                        ; #$02 means the Tilemap are 16x16
    LDA !TilesDrawn                 ; \ A = Tilemap-1
    DEC A                           ; /
    JSL $01B7B3|!BankB              ; don't draw if offscreen, set tile size
    RTS
