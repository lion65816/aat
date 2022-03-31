;=======================================================================================;
; Koopa / Shell disassembly + additional features (sprites 4-7, DA-DF)                  ;
; v1.0, by KevinM                                                                       ;
;=======================================================================================;
; Koopa/Shell type is set by the act-as and the palette of the sprite (you don't really ;
; need to worry about it, since there's a json file for each one):                      ;
; - 04: Green Koopa / Shell                                                             ;
; - 05: Red Koopa / Shell                                                               ;
; - 06: Blue Koopa / Shell                                                              ;
; - 07: Yellow Koopa / Shell                                                            ;
; - 09: Special Green Shell (originally sprite DF)                                      ;
;=======================================================================================;
; Extra Bit:                                                                            ;
;  - If clear, it'll spawn as a Koopa.                                                  ;
;  - If set, it'll spawn as a Shell (by default, in stationary state).                  ;
;                                                                                       ;
; Note: if using sprite 09 (ParaKoopa), the extra bit must be set (to have the          ;
;  Special Shell), since this disassembly does NOT include ParaKoopas.                  ;
;=======================================================================================;
; Extra Byte 1:                                                                         ;
;  It controls the properties of the Koopa, which are originally hardcoded for each     ;
;   Koopa type, but now you can set freely. Bitwise format: a---jfls.                   ;
;   a = animate twice as fast in air, - = unused, j = jump over Shells,                 ;
;   f = follow Mario, l = stay on ledges, s = move faster.                              ;
;    The vanilla values for each Koopa are the following:                               ;
;     - 04 (G): $40                                                                     ;
;     - 05 (R): $42                                                                     ;
;     - 06 (B): $43                                                                     ;
;     - 07 (Y): $45                                                                     ;
;                                                                                       ;
; Note that these also matter if spawning the sprite in Shell state, since it can       ;
; become a Koopa if a shell-less Koopa enters it.                                       ;
;=======================================================================================;
; Extra byte 2:                                                                         ;
;  Controls additional settings. Bitwise format: idDcftbo                               ;
;   i = if set, the Shell can be bounced on infinite times without stopping (note: if   ;
;        it has a Koopa inside it, the Koopa won't be knocked out when bouncing).       ;
;   d = if set, the Shell disappears after being bounced on (note: doesn't work if i    ;
;        flag set, and if there's a Koopa inside it it won't spawn).                    ;
;   D = if set, the Koopa disappears after being bounced on.                            ;
;   c = if set, the Disco Shell won't be immune to cape. This means that you can stun   ;
;        it with cape spin or cape ground pound and pick it up, and when kicked again   ;
;        it'll resume being a Disco Shell.                                              ;
;   f = if set, the Disco Shell won't be immune to fireballs (this also applies when    ;
;        using the c flag and stunning it with cape).                                   ;
;   t = if set, the Disco Shell will get the same Y boost as normal Shells when         ;
;        touching a purple triangle block.                                              ;
;   b = if set, the kicked/Disco Shell will interact with blocks even when offscreen    ;
;        (like ON/OFF, turn blocks, etc.).                                              ;
;   o = if set, the Koopa/Shell won't despawn when offscreen (same thing as setting     ;
;        the flag in the json file). You can combine this and the b bit to have         ;
;        Shell-based contraptions that sustain during an entire level.                  ;
;=======================================================================================;
; Extra Byte 3: (only applies when the Extra Bit is set)                                ;
;  If $00, the Shell will spawn in carryable state.                                     ;
;  Otherwise, the Shell will spawn kicked towards the player, and its speed will be     ;
;   the value you put here ($00-$7F).                                                   ;
;  Additionally, if the highest bit is set (so it's >=$80) it'll spawn as a Disco Shell ;
;   instead (the lower bits will set its initial speed like for the kicked shell).      ;
;  E.g., using $C0 will make a Disco Shell spawn with initial speed $C0 - $80 = $40.    ;
;                                                                                       ;
; Note: due to how Shells work, using a low speed value ($20 or lower) will spawn it    ;
;  in the carryable state instead, but it will make it bounce towards Mario, as if      ;
;  someone was tossing it to Mario (works better if spawned in the air).                ;
;=======================================================================================;
; Extra Byte 4: (only applies when the Extra Bit is set)                                ;
;  It sets the stun timer when the Shell is spawned.                                    ;
;  If 0, the Shell will spawn as normal, otherwise it'll spawn as a Shell with a Koopa  ;
;  inside it, which will come out when the timer expires.                               ;
;                                                                                       ;
; Note 1: with this you can also spawn a Special Green Shell with Koopa inside.         ;
;  When kicked, the Koopa will be kicked out of it only on the second bounce            ;
;  (when the shell stops moving).                                                       ;
;                                                                                       ;
; Note 2: you can combine this with the Extra Byte 3 to spawn a kicked Shell with a     ;
;  Koopa inside.                                                                        ;
;=======================================================================================;

;=======================================================================================;
; Defines of general properties                                                         ;
; Feel free to edit these.                                                              ;
;=======================================================================================;
; Base X speed for Koopas, the fast one is when the s flag is set in the first Extra Byte.
!KoopaBaseSpeed     = $08
!KoopaBaseSpeedFast = $0C

; Koopa tilemap       Walking1|Walking2|Turning
!KoopaTiles         = $82,$A0, $82,$A2, $84,$A4

; Y speed the Koopa gets when jumping over a Shell.
; Usually this only matters for yellow shell-less Koopas, but you can set this behavior with the j bit in the first Extra Byte.
!JumpYSpeed         = $C0

; If 1, green and red Koopas/Shells will turn into yellow and blue when the special world is passed (vanilla behavior).
; This of course won't apply to the Special Green Shell, like in vanilla.
; This also makes Shells with a Koopa inside not draw the eyes and not shake when the Koopa is about to come out of them.
!SWColorChange      = 1

; If the above flag is set, green and red Koopas will turn into yellow and blue Koopas.
; Since their properties are not based on their sprite number anymore, but on the Extra Byte 1, when changing their color they'll keep the original properties.
; The two defines below will overwrite those properties for the green and red Koopas, when the Special World is passed.
!SWExtraByte1Green  = $45   ; Properties of the Green Koopa when turned into a Yellow Koopa.
!SWExtraByte1Red    = $43   ; Properties of the Red Koopa when turned into a Blue Koopa.

; This is the level that, when beaten, triggers the "Special World passed" flag.
; Change this to what you change in LM (or leave $125 if you don't change it)
!SWPassedLevel      = $0105

; SFX that plays when kicking the sprite.
!KickedSFX          = $03
!KickedSFXAddr      = $1DF9|!addr

; Time to disable contact with Mario after kicking the shell.
!KickNoInteractTime = $10

; X speed when kicked sideways by Mario.
!KickXSpeed         = $2E

; Y speed when thrown upwards by Mario.
!KickYSpeed         = $90

; X speed when dropped by Mario.
!DropXSpeed         = $04

; X offset from Mario of the Shell when dropped..
!DropXOffset        = $0D

; X offset from Mario of the Shell when carried. Depends on Mario's direction and turning animation:
; Right, left, left while turning, right when turning, sliding/going down a pipe/climbing while turning, centered.
!CarryXOffset       = $0B,$F5,$04,$FC,$04,$00

; Shell tilemap (the first tile is used twice while spinning, but X flipped the second time)
!ShellTiles         = $8C,$8A,$8E

; Y/X speed of the shell-less Koopas that jumps out from inside the Shell.
!KoopaSpawnYSpeed   = $D0
!KoopaSpawnXSpeed1  = $08

; X speed of the shell-less Koopa that is spawned from the Shell when Mario jumps on it.
!KoopaSpawnXSpeed2  = $40

; 0 = spinjumping on the Shell doesn't make Mario bounce up, unless he's on Yoshi (vanilla behavior)
; 1 = spinjumping on the Shell always boosts Mario (like Rex)
!AlwaysSpinBoost    = 0

; Y speed Mario gets when killing a Shell with a spinjump (ignored if !AlwaysSpinBoost = 1)
; If using a high negative value, it'll act like the spin boost, with the difference that
; the speed given doesn't depend on if you're holding the jump button or not.
!SpinKillYSpeed     = $F8

; Which sprite turns the Shell when entering it (default = Yellow shell-less Koopa).
; It should be a shell-less Koopa: if not, the sprite never turns into a Disco Shell.
!SpriteTurnDisco    = $03

; Acceleration and max speed when in Disco Shell state
!DiscoXAcceleration = $02
!DiscoMaxXSpeed     = $20

; Speed to give Disco Shells when bumping into a wall
!DiscoBumpXSpeed    = $20

; X speed that Mario gets when jumping on the Disco Shell
!DiscoXBoost        = $18

; Y speed given by purple triangle blocks when a kicked Shell touches it.
!TriangleYSpeed     = $B8

; If 1, the Shell in stationary state will bounce higher on the ground when dropped.
; (Originally this is only done by Goombas).
!DropExtraBoost     = 0

; Which Koopa spawns a coin when jumped on (default = Yellow Koopa)
!KoopaSpawnsCoin    = $07

; Sprite number of the moving coin. Change if you want a different sprite to appear.
!MovingCoinSprite   = $21

; Y speed of the moving coin when spawned.
!MovingCoinYSpeed   = $D0

; Which sprites spawn out of a Shell with Koopa inside. By default they're the shell-less Koopas
;                      G   R   B   Y   -  SpG
!SpriteKoopasSpawn  = $00,$01,$02,$03,$00,$00

;=======================================================================================;
; Sprite code                                                                           ;
; Don't edit from here unless you know what you're doing!                               ;
;=======================================================================================;
!addr = !Base2
!bank = !BankB

!SWPassedFlag = $1EA2|!addr+!SWPassedLevel
if !SWPassedLevel > $24
    !SWPassedFlag := !SWPassedFlag-$DC
endif

;===================================;
; Init routine                      ;
;===================================;
print "INIT ",pc : Init:
    lda !extra_byte_1,x     ;\
    sta !1504,x             ;| Store Extra Bytes 1 and 2 to absolute addresses.
    lda !extra_byte_2,x     ;|
    sta !1510,x             ;/
    lsr                     ;\
    bcc +                   ;|
    lda !167A,x             ;| If the "don't despawn" flag is set, set the "process offscreen" flag in the tweaker byte.
    ora #$04                ;|
    sta !167A,x             ;/
+
if !SWColorChange
    lda !SWPassedFlag       ;\
    bpl .Skip               ;|
    lda !9E,x               ;|
    cmp #$04                ;|
    bne +                   ;|
    lda #$07                ;|
    sta !9E,x               ;|
    lda !15F6,x             ;|
    and #%11110001          ;|
    ora #%00000100          ;| If Special World passed, change sprite number, palette
    sta !15F6,x             ;| and common Koopa properties for green and red Koopas.
    lda #!SWExtraByte1Green ;|
    sta !1504,x             ;|
    bra .Skip               ;|
+   cmp #$05                ;|
    bne .Skip               ;|
    lda #$06                ;|
    sta !9E,x               ;|
    lda !15F6,x             ;|
    and #%11110001          ;|
    ora #%00000110          ;|
    sta !15F6,x             ;|
    lda #!SWExtraByte1Red   ;|
    sta !1504,x             ;/
.Skip:
endif
    lda !extra_byte_4,x     ;\
    sta !1540,x             ;| Set stun timer.
    sta !C2,x               ;/
    %BEC(.Normal)           ;> If extra bit clear, set state as normal.
.Shell:
    lda #$04                ;\ Briefly disable quake sprite interaction
    sta !1FE2,x             ;/ (this is done in vanilla for Shells, don't know why it matters)
    lda !extra_byte_3,x     ;\ Extra Byte 3 = 0 --> stationary.
    beq .Carryable          ;/
    jsr FaceMario
    lda !extra_byte_3,x     ;\ Extra Byte 3 >= 0 --> kicked, but not Disco.
    bpl .Kicked             ;/
.Disco:
    lda #$01                ;\ Set to draw eyes inside.
    sta !C2,x               ;/
    jsr SetDiscoShell       ;> Turn into a Disco Shell.
+   lda !extra_byte_3,x     ;\
    asl                     ;| Clear high bit.
    lsr                     ;/
    bra +
.Kicked:
    lda #!KickedSFX         ;\ Play kicked SFX.
    sta !KickedSFXAddr      ;/
    lda !extra_byte_3,x
+   cpy #$00                ;\
    beq +                   ;| Invert X speed if facing left.
    eor #$FF                ;|
    inc                     ;/
+   sta !B6,x               ;> Set X speed.
    lda #$0A                ;\ Set kicked state.
    bra +                   ;/
.Carryable:
    lda #$09                ;\ Set carryable state.
+   sta !14C8,x             ;/
    rtl
.Normal:
    jsl $01ACF9|!bank       ;\ Random frame counter for animation.
    sta !1570,x             ;/
    jsr FaceMario
    rtl

;===================================;
; Main routine wrapper              ;
;===================================;
print "MAIN ",pc : Main:
    phb
    phk
    plb

; Call appropriate routine for the relevant states (8,9,A,B).
    lda !14C8,x : cmp #$08 : bcc .Dead
                  cmp #$09 : beq +
                  cmp #$0A : beq ++
                  cmp #$0B : beq +++
    jsr HandleNormal     : bra ++++     ;> Koopa
+   jsr HandleStationary : bra ++++     ;> Stunned/Stationary Shell
++  jsr HandleKicked     : bra ++++     ;> Kicked/Disco Shell
+++ jsr HandleCarried    : ++++         ;> Carried Shell

; Set to handle states < 8 with vanilla routines.
    lda !14C8,x
    cmp #$08
    lda #$80
    bcs +
.Dead:
    lda #$00
+   sta !extra_prop_2,x
    plb
    rtl

;===================================;
; HandleNormal routine              ;
;===================================;
HandleNormal:
    lda $9D
    beq +
    jsr SprMarioInteract
    jsr HandleNormalGfx
    rts
+   lda !1588,x             ;\
    and #$04                ;|
    beq +                   ;|
    lda !1504,x             ;|
    lsr                     ;|
    ldy !157C,x             ;| If the sprite is on the ground, set its Y speed
    bcc ++                  ;| depending on what kind of slope it's on.
    iny #2                  ;| Blue and Yellow Koopas move a bit faster.
++  lda KoopaSpeed,y        ;|
    eor !15B8,x             ;|
    asl                     ;|
    lda KoopaSpeed,y        ;|
    bcc ++                  ;|
    clc                     ;|
    adc !15B8,x             ;|
++  sta !B6,x               ;/
+   ldy !157C,x             ;\
    tya                     ;|
    inc                     ;|
    and !1588,x             ;| If the sprite walks into the side of a block, stop it.
    and #$03                ;|
    beq +                   ;|
    stz !B6,x               ;/
+   lda !1588,x             ;\
    and #$08                ;| If touching a ceiling, reset it's Y speed.
    beq +                   ;|
    stz !AA,x               ;/
+   lda #$00
    %SubOffScreen()
    jsl $01802A|!bank       ;> Update X/Y positions with gravity and interact with blocks.
    jsr SetAnimationFrame
    lda !1588,x
    and #$04
    beq InAir

OnGround:
    lda !1588,x             ;\
    bmi +                   ;|
    lda #$00                ;|
    ldy !15B8,x             ;| SetSomeYSpeed routine
    beq ++                  ;|
+   lda #$18                ;|
++  sta !AA,x               ;/
    stz !151C,x             ;> Set "on a ledge" flag.
    lda !1504,x             ;\
    pha                     ;|
    and #$04                ;|
    beq +                   ;|
    lda !1570,x             ;|
    and #$7F                ;| Follow Mario is set to do so.
    bne +                   ;| Don't turn if not time to do so or if already facing Mario.
    lda !157C,x             ;|
    pha                     ;|
    jsr FaceMario           ;|
    pla                     ;|
    cmp !157C,x             ;|
    beq +                   ;|
    lda #$08                ;|\ Set time to turn around.
    sta !15AC,x             ;//
+   pla                     ;\
    and #$08                ;| If the sprite is set to jump over Shells, do it.
    beq +                   ;|
    jsr JumpOverShells      ;/
+   bra InAir_Interaction

InAir:
    ldy !1504,x             ;\
    bpl +                   ;| If set to do so, animate twice as fast in air (a.k.a., call the routine again).
    jsr SetAnimationFrame   ;/
    bra ++
+   stz !1570,x
++  tya                     ;\
    and #$02                ;|
    beq .Interaction        ;|
    lda !151C,x             ;|
    ora !1558,x             ;| If the sprite is set to turn on ledges and is not having a special function run, flip its direction.
    ora !1528,x             ;|
    ora !1534,x             ;|
    bne .Interaction        ;|
    jsr FlipSpriteDir       ;|
    lda #$01                ;|
    sta !151C,x             ;/
.Interaction:
    jsr SprMarioInteract
    lda !157C,x             ;\
    inc                     ;|
    and !1588,x             ;| If touching an object from the side, flip its direction.
    and #$03                ;|
    beq HandleNormalGfx     ;|
    jsr FlipSpriteDir       ;/
HandleNormalGfx:
    lda !157C,x
    pha
    ldy !15AC,x
    beq ++
    lda #$02
    sta !1602,x
    lda #$00
    cpy #$05
    bcc +
    inc
+   eor !157C,x
    sta !157C,x
++  lda !1602,x
    lsr
    lda !D8,x
    pha
    sbc #$0F
    sta !D8,x
    lda !14D4,x
    pha
    sbc #$00
    sta !14D4,x
    jsr KoopaGraphics
    pla
    sta !14D4,x
    pla
    sta !D8,x
    pla
    sta !157C,x
    rts

JumpOverShells:
    txa                     ;\
    eor $13                 ;| Only detect once every 4 frames.
    and #$03                ;|
    bne .Return             ;/
    ldy #!SprSize-1
.Loop:
    lda !14C8,y
    cmp #$0A
    beq .HandleJumpOver
.Continue:
    dey
    bpl .Loop
.Return:
    rts

.HandleJumpOver
    lda.w !E4,y             ;\
    sec                     ;|
    sbc #$1A                ;|
    sta $00                 ;|
    lda !14E0,y             ;|
    sbc #$00                ;|
    sta $08                 ;|
    lda #$44                ;|
    sta $02                 ;| Check if the Shell is in a $44x$10 pixels area around the Koopa.
    lda.w !D8,y             ;|
    sta $01                 ;|
    lda !14D4,y             ;|
    sta $09                 ;|
    lda #$10                ;|
    sta $03                 ;|
    jsl $03B69F|!bank       ;|
    jsl $03B72B|!bank       ;|
    bcc .Continue           ;/
    lda !1588,y             ;\
    and #$04                ;| If the Shell is not on the ground, check next sprite.
    beq .Continue           ;/
    lda !157C,y             ;\
    cmp !157C,x             ;| If Shell and Koopa are going in the same direction, return.
    beq .Return             ;/
    lda #!JumpYSpeed
    sta !AA,x
    stz !163E,x
    rts

FlipSpriteDir:
    lda !15AC,x
    bne .Return
    lda #$08
    sta !15AC,x
    lda !B6,x
    eor #$FF
    inc
    sta !B6,x
    lda !157C,x
    eor #$01
    sta !157C,x
.Return:
    rts

SetAnimationFrame:
    inc !1570,x
    lda !1570,x
    lsr #3
    and #$01
    sta !1602,x
    rts

FaceMario:
    %SubHorzPos()
    tya
    sta !157C,x
    rts

KoopaSpeed:
    db !KoopaBaseSpeed,-!KoopaBaseSpeed,!KoopaBaseSpeedFast,-!KoopaBaseSpeedFast

;===================================;
; HandleSpriteStationary routine    ;
;===================================;
HandleStationary:
    lda $9D                 ;\
    beq +                   ;| If sprites are locked, just draw graphics.
    jmp .DrawGraphics       ;/
+   jsr HandleStunned       ;> Handle stunned timer and stuff.
    jsl $01802A|!bank       ;> Update X/Y positions with gravity and interact with blocks.
    lda !1588,x             ;\
    and #$04                ;| If on the ground, make it bounce on it.
    beq +                   ;|
    jsr BounceOnGround      ;/
+   lda !1588,x             ;\
    and #$08                ;| If not touching the ceiling, skip.
    beq +                   ;/
    lda #$10                ;\ Make it go down.
    sta !AA,x               ;/
    lda !1588,x             ;\
    and #$03                ;| If touching the side of a block, skip.
    bne +                   ;/
    lda !E4,x               ;\
    clc                     ;|
    adc #$08                ;|
    sta $9A                 ;|
    lda !14E0,x             ;|
    adc #$00                ;|
    sta $9B                 ;|
    lda !D8,x               ;|
    and #$F0                ;|
    sta $98                 ;| Interact with the block
    lda !14D4,x             ;| (i.e., hit the block and trigger its effect).
    sta $99                 ;|
    lda !1588,x             ;|
    and #$20                ;|
    asl #3                  ;|
    rol                     ;|
    and #$01                ;|
    sta $1933|!addr         ;|
    ldy #$00                ;|
    lda $1868|!addr         ;|
    jsl $00F160|!bank       ;/
    lda #$08                ;\ Briefly disable interaction with quake sprites
    sta !1FE2,x             ;/ to avoid being hit by the block's bounce sprite.
+   lda !1588,x             ;\
    and #$03                ;| If not touching the side of a block, skip.
    beq +                   ;/
    lda !B6,x               ;\
    asl                     ;|
    php                     ;| Bounce the Shell backwards at 1/4th of its original speed.
    ror !B6,x               ;|
    plp                     ;|
    ror !B6,x               ;/
+   jsr SprMarioInteract    ;> Interact with sprites and Mario.
.DrawGraphics:
    jsr StationaryGFX       ;> Draw GFX.
    lda #$00                ;\ Handle offscreen.
    %SubOffScreen()         ;/
    rts

HandleStunned:
    lda !1540,x
    ora !1558,x
    sta !C2,x
    lda !1558,x             ;\
    beq CheckUnstun         ;|
    cmp #$01                ;|
    bne CheckUnstun         ;| Branch if no Koopa jumping into the Shell.
    ldy !1594,x             ;|
    lda !15D0,x             ;|
    bne CheckUnstun         ;/
    lda !9E,x               ;\
    cmp #$08                ;|
    bcc +                   ;| If it becomes a ParaKoopa, turn into vanilla sprite.
    lda !extra_bits,x       ;|
    and #%11110011          ;|
    sta !extra_bits,x       ;/
+   jsl $07F78B|!bank       ; Load sprite tables.
    jsr FaceMario
    asl !15F6,x             ;\ Clear Shell's Y flip.
    lsr !15F6,x             ;/
    ldy !160E,x             ;\
    lda #$08                ;|
    cpy #!SpriteTurnDisco   ;|
    bne +                   ;| If it's the sprite that turns it into a Disco Shell, do it.
    jsr SetDiscoShell       ;|
    lda #$0A                ;|
+   sta !14C8,x             ;/
.Return:
    rts

IncrementStunTimer:
    lda $13                 ;\
    and #$01                ;|
    bne .Return             ;|
    lda !1540,x             ;| Make so the stun timer decrements every 2 frames.
    inc                     ;|
    beq .Return             ;|
    sta !1540,x             ;/
.Return:
    rts

CheckUnstun:
    lda !1540,x             ;\ If not stunned, return.
    beq HandleStunned_Return;/
    cmp #$03                ;\
    beq Unstun              ;| If stun timer ≠ 1,3, handle as usual.
    cmp #$01                ;|
    bne IncrementStunTimer  ;/

;========================================================;
; Unstun the Shell, and spawn a shell-less Koopa from it ;
;========================================================;
Unstun:
    stz $00
    stz $01
    stz $02
    stz $03
    lda !9E,x
    tax
    lda .SpriteKoopasSpawn-4,x
    sta.w !9E,y
    ldx $15E9|!addr
    clc
    %SpawnSprite()
    bcs HandleStunned_Return
    lda #$08                ;\ Normal state
    sta !14C8,y             ;/
    lda #$10                ;\ Briefly disable sprite contact.
    sta !1564,y             ;/
    lda !164A,x             ;\ Copy "in-liquid" flag.
    sta !164A,y             ;/
    lda !1540,x
    stz !1540,x             ;> Reset stun timer.
    cmp #$01
    beq +
; Koopa is jumping out of the Shell (because the stun timer expired).
    lda #!KoopaSpawnYSpeed  ;\ Set Y speed.
    sta.w !AA,y             ;/
    phy                     ;\
    %SubHorzPos()           ;|
    tya                     ;| Jump away from Mario.
    eor #$01                ;|
    ply                     ;|
    sta !157C,y             ;/
    phx
    tax                     ;\
    lda .XSpeed1,x          ;| Set X speed.
    sta.w !B6,y             ;/
    plx
    rts
; Koopa is thrown out of the Shell (because Mario jumped on it).
+   phy
    %SubHorzPos()           ;\
    lda .XSpeed2,y          ;| Set X speed based on relative position with Mario
    sty $00                 ;| (if Mario is on the left, make it go right and viceversa)
    ply                     ;|
    sta.w !B6,y             ;/
    lda $00                 ;\
    eor #$01                ;| Set direction based on X speed.
    sta !157C,y             ;/
    sta $0F
    lda #$10                ;\ Briefly disable contact with Mario.
    sta !154C,y             ;/
    sta !1528,y             ;> Make the Koopa slide and be kick-killable.
    lda !9E,x               ;\
    cmp #!KoopaSpawnsCoin   ;| If not Yellow Shell, return.
    bne .Return             ;/
    ldy #$08                ;\
-   lda !14C8,y             ;| Search for a free slot in 0-8.
    beq SpawnMovingCoin     ;| (using %SpawnSprite() can cause graphical glitches)
    dey                     ;|
    bpl -                   ;/
.Return:
    rts

.XSpeed1:
    db !KoopaSpawnXSpeed1,-!KoopaSpawnXSpeed1

.XSpeed2:
    db -!KoopaSpawnXSpeed2,!KoopaSpawnXSpeed2

.SpriteKoopasSpawn:
    db !SpriteKoopasSpawn

;===================================================================;
; Routine that spawns a moving coin sprite at the Koopa's position  ;
; Input: Y = sprite slot to put the coin in.                        ;
;===================================================================;
SpawnMovingCoin:
    lda #$08                ;\
    sta !14C8,y             ;|
    lda #!MovingCoinSprite  ;|
    sta.w !9E,y             ;|
    lda !E4,x               ;|
    sta.w !E4,y             ;|
    lda !14E0,x             ;|
    sta !14E0,y             ;| Spawn the moving coin at the sprite's position.
    lda !D8,x               ;|
    sta.w !D8,y             ;|
    lda !14D4,x             ;|
    sta !14D4,y             ;|
    phx                     ;|
    tyx                     ;|
    jsl $07F7D2|!bank       ;|
    plx                     ;/
    lda #!MovingCoinYSpeed  ;\ Set Y speed.
    sta.w !AA,y             ;/
    lda $0F                 ;\ Spawn in the same direction as the shell-less Koopa.
    sta !157C,y             ;/
    lda #$20                ;\ Briefly disable contact with Mario.
    sta !154C,y             ;/
    rts

;===================================================;
; Make the carryable sprite bounce on the ground    ;
; when its speed is non-zero.                       ;
;===================================================;
BounceOnGround:
    lda !B6,x               ;\
    php                     ;|
    bpl +                   ;|
    eor #$FF                ;|
    inc                     ;|
+   lsr                     ;| Halve the sprite's X speed.
    plp                     ;|
    bpl +                   ;|
    eor #$FF                ;|
    inc                     ;|
+   sta !B6,x               ;/
    lda !AA,x
    pha
    lda !1588,x             ;\
    bmi +                   ;|
    lda #$00                ;| Set some Y speed
    ldy !15B8,x             ;| (gets overwritten unless touching layer 2 from above)
    beq ++                  ;|
+   lda #$18                ;|
++  sta !AA,x               ;/
    pla
    lsr #2
if !DropExtraBoost
    clc                     ;\ Use higher values from the table, like Goombas do.
    adc #$13                ;/
endif
    tay
    lda .BounceYSpeed,y     ;\
    ldy !1588,x             ;| Set Y speed using the table
    bmi .Return             ;| (unless it's on layer 2)
    sta !AA,x               ;/
.Return:
    rts

; Bounce speeds for carryable sprites when hitting the ground.
; Indexed by Y speed divided by 4.
.BounceYSpeed:
    db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
    db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
    db $E8,$E8,$E8,$00,$00,$00,$00,$FE
    db $FC,$F8,$EC,$EC,$EC,$E8,$E4,$E0
    db $DC,$D8,$D4,$D0,$CC,$C8

;===========================================================;
; This routine handles graphics for the stationary shell:   ;
; - Set animation frame.                                    ;
; - Draw graphics.                                          ;
; - Shake the shell if Koopa about to exit it.              ;
; - Draw eyes if applicable.                                ;
;===========================================================;
StationaryGFX:
    lda #$06                ;\
    ldy !15EA,x             ;|
    bne .0                  ;| Set animation frame.
    lda #$08                ;|
.0: sta !1602,x             ;/
    lda !15EA,x             ;\
    pha                     ;|
    beq +                   ;| If OAM index is not 0, add 8 to it.
    clc                     ;|
    adc #$08                ;|
+   sta !15EA,x             ;/
    jsr ShellGraphics       ;> Draw the sprite.
    pla
    sta !15EA,x
    lda !SWPassedFlag       ;\ If Special World passed, return.
    bmi .Return             ;/
    lda !1602,x             ;\
    cmp #$06                ;| If the opening of the Shell isn't facing the screen, return.
    bne .Return             ;/
    ldy !15EA,x
    lda !1558,x             ;\ If there's a Koopa inside, draw eyes
    bne +                   ;/ (also applies to Disco Shells).
    lda !1540,x             ;\ If the Shell is not stunned, return.
    beq .Return             ;/
    cmp #$30                ;\ If not time to shake, skip.
    bcs ++                  ;/
+   lsr
    lda $0308|!addr,y       ;\
    adc #$00                ;| Shake the graphics.
    bcs ++                  ;|
    sta $0308|!addr,y       ;/
++  lda !15A0,x             ;\
    ora !186C,x             ;| If offscreen, return.
    bne .Return             ;/
    lda !15F6,x             ;\
    asl                     ;|
    lda #$08                ;| Set Y offset of the eyes depending on if the Shell is upside down or rightside up.
    bcc +                   ;|
    lda #$00                ;|
+   sta $00                 ;/
    lda $0308|!addr,y       ;\
    clc                     ;|
    adc #$02                ;|
    sta $0300|!addr,y       ;|
    clc                     ;|
    adc #$04                ;| Set X/Y positions.
    sta $0304|!addr,y       ;|
    lda $0309|!addr,y       ;|
    clc                     ;|
    adc $00                 ;|
    sta $0301|!addr,y       ;|
    sta $0305|!addr,y       ;/
    phy
    ldy #$64                ;\
    lda $14                 ;|
    and #$F8                ;|
    bne +                   ;|
    ldy #$4D                ;| Set tile.
+   tya                     ;|
    ply                     ;|
    sta $0302|!addr,y       ;|
    sta $0306|!addr,y       ;/
    lda $64                 ;\ Set YXPPCCCT.
    sta $0303|!addr,y       ;|
    sta $0307|!addr,y       ;/
    tya                     ;\
    lsr #2                  ;|
    tay                     ;| Set size (8x8).
    lda #$00                ;|
    sta $0460|!addr,y       ;|
    sta $0461|!addr,y       ;/
.Return:
    rts

;===================================;
; HandleSpriteKicked routine        ;
;===================================;
HandleKicked:
    lda !187B,x             ;\ Branch if Disco Shell.
    beq +                   ;|
    jmp DiscoShell          ;/
+   lda !167A,x             ;\
    and #$10                ;| If it can't be kicked like a shell
    beq KickedShell         ;|
    jsr SetCarryable        ;| turn into carryable state
    jmp StationaryGFX       ;/ and draw graphics.

;===================================;
; Handle normal Kicked Shell        ;
;===================================;
KickedShell:
    lda !1528,x             ;\
    bne +                   ;|
    lda !B6,x               ;|
    clc                     ;| If not being caught by a Koopa, return to carryable if it slows down enough.
    adc #$20                ;|
    cmp #$40                ;|
    bcs +                   ;|
    jsr SetCarryable        ;/
+   stz !1528,x             ;\
    lda $9D                 ;|
    ora !163E,x             ;| If sprites are locked or (?) is happening, just draw graphics.
    beq +                   ;|
    jmp FinishHandleKicked_0;/
+   lda #$00                ;\
    ldy !B6,x               ;|
    beq +                   ;| Set direction based on speed.
    bpl ++                  ;|
    inc                     ;|
++  sta !157C,x             ;/
+   lda !15B8,x
    pha
    jsl $01802A|!bank       ; Update X/Y positions with gravity and interact with blocks.
    pla
    beq +
    sta $00
    ldy !164A,x             ;\
    bne +                   ;|
    cmp !15B8,x             ;|
    beq +                   ;| If just gone onto a slope, not in water and it's moving faster
    eor !B6,x               ;| than the slopes angle, make it bounce slightly.
    bmi +                   ;|
    lda #$F8                ;|
    sta !AA,x               ;/
    bra ++
+   lda !1588,x             ;\
    and #$04                ;|
    beq +                   ;| If on the ground, set Y speed to $10.
    lda #$10                ;|
    sta !AA,x               ;/
++  lda $1860|!addr         ;\
    cmp #$B5                ;|
    beq ++                  ;|
    cmp #$B4                ;| If touching a purple triangle, set Y speed.
    bne +                   ;|
++  lda #!TriangleYSpeed    ;|
    sta !AA,x               ;/
+   lda !1588,x             ;\
    and #$03                ;| If hitting the side of a block, interact with it.
    beq FinishHandleKicked  ;|
    jsr SideBlockInteract   ;/
FinishHandleKicked:
    jsr SprMarioInteract
.0: lda #$00
    %SubOffScreen()
    jmp KickedGFX

;====================================;
; Handle kicked Shell in Disco state ;
;====================================;
DiscoShell:
    lda $9D                 ;\
    beq +                   ;| If sprites are frozen, just draw GFX.
    jmp KickedGFX           ;/
+   jsl $01802A|!bank       ;> Update X/Y positions with gravity and interact with blocks.
    lda !151C,x             ;\
    and #$1F                ;|
    bne +                   ;| Follow Mario, except when $151C is non-zero (unused?)
    jsr FaceMario           ;/
+   lda !B6,x               ;\
    ldy !157C,x             ;|
    bne +                   ;|
    cmp #!DiscoMaxXSpeed    ;|
    bpl ++                  ;|
    clc                     ;|
    adc #!DiscoXAcceleration;| Handle X acceleration.
    bra ++                  ;|
+   cmp #-!DiscoMaxXSpeed   ;|
    bmi +                   ;|
    sec                     ;|
    sbc #!DiscoXAcceleration;|
++  sta !B6,x               ;/
+   lda !1588,x             ;\
    and #$03                ;|
    beq +                   ;|
    pha                     ;| If hitting the side of a block,
    jsr SideBlockInteract   ;| interact with it and bump the Shell.
    pla                     ;|
    and #$03                ;|
    tay                     ;|
    lda .BumpXSpeed-1,y     ;|
    sta !B6,x               ;/
+   lda !1588,x             ;\
    and #$04                ;|
    beq +                   ;| If on the ground, set its Y speed to $10.
    lda #$10                ;|
    sta !AA,x               ;/
+   lda !1588,x             ;\
    and #$08                ;| If hitting a ceiling, clear its Y speed.
    beq +                   ;|
    stz !AA,x               ;/
+   lda !1510,x             ;\
    and #$04                ;| If the "Disco speed boost from triangles" flag is not set, skip.
    beq +                   ;/
    lda $1860|!addr         ;\
    cmp #$B5                ;|
    beq ++                  ;|
    cmp #$B4                ;| If touching a purple triangle, set Y speed.
    bne +                   ;|
++  lda #!TriangleYSpeed    ;|
    sta !AA,x               ;/
+   lda $13                 ;\
    and #$01                ;|
    bne +                   ;|
    lda !15F6,x             ;| Cycle through the palettes every other frame.
    inc #2                  ;|
    and #$CF                ;|
    sta !15F6,x             ;/
+   jmp FinishHandleKicked  ;> Interaction, offscreen handle and GFX.

.BumpXSpeed:
    db -!DiscoBumpXSpeed,!DiscoBumpXSpeed

;===================================================================;
; This routine is called when bumping into a block from the sides:  ;
; - Play bump SFX.                                                  ;
; - Invert the Shell's X speed and direction.                       ;
; - If far anough onscreen, trigger the block that's been touched.  ;
;===================================================================;
SideBlockInteract:
    lda #$01                ;\ Play SFX.
    sta $1DF9|!addr         ;/
    lda !B6,x               ;\
    eor #$FF                ;| Invert X speed.
    inc                     ;|
    sta !B6,x               ;/
    lda !157C,x             ;\
    eor #$01                ;| Invert direction.
    sta !157C,x             ;/
    lda !1510,x             ;\
    and #$02                ;| If the "interact with block offscreen" flag is set, don't check if onscreen.
    bne +                   ;/
    lda !15A0,x             ;\ If offscreen, return.
    bne .Return             ;/
    lda !E4,x               ;\
    sec                     ;|
    sbc $1A                 ;| If not far enough on screen, return.
    clc                     ;|
    adc #$14                ;|
    cmp #$1C                ;|
    bcc .Return             ;/
+   lda !1588,x             ;\
    and #$40                ;|
    asl #2                  ;|
    rol                     ;|
    and #$01                ;| Trigger the block.
    sta $1933|!addr         ;|
    ldy #$00                ;|
    lda $18A7|!addr         ;|
    jsl $00F160|!bank       ;/
    lda #$05                ;\ Briefly disable interaction with quake sprite
    sta !1FE2,x             ;/ (to avoid being hit by the block's bounce sprite).
.Return:
    rts

;===========================================================;
; This routine handles graphics for the kicked shell:       ;
; - Change animation frame every so often.                  ;
; - Draw graphics.                                          ;
; - Flip the Shell when using the 4th animation frame.      ;
;===========================================================;
KickedGFX:
    lda !C2,x               ;\ If it has a Koopa inside, keep drawing eyes while kicked.
    sta !1558,x             ;/
    lda $14                 ;\
    lsr #2                  ;|
    and #$03                ;|
    tay                     ;|
    phy                     ;|
    lda .AnimationFrames,y  ;|
    jsr StationaryGFX_0     ;| Animate the spinning shell.
    stz !1558,x             ;|
    ply                     ;|
    lda .GfxProps,y         ;|
    ldy !15EA,x             ;|
    eor $030B|!addr,y       ;|
    sta $030B|!addr,y       ;/
    rts

.AnimationFrames:
    db $06,$07,$08,$07

.GfxProps:
    db $00,$00,$00,$40

;============================================================;
; Sprite<->Sprite interaction and Mario<->Sprite interaction ;
;============================================================;
SprMarioInteract:
    jsl $01803A|!bank       ;\ Interact with sprites, and check for contact with Mario.
    bcc .Return             ;/ Return if no contact.
    lda $1490|!addr         ;\ If Mario has a star
    beq NoStar              ;|
    lda !167A,x             ;| and the sprite can be starkilled
    and #$02                ;|
    bne NoStar              ;|
    %Star()                 ;/ kill.
.Return:
    rts

NoStar:
    stz $18D2|!addr
    lda !154C,x             ;\ If contact is disabled, return.
    bne SprMarioInteract_Return ;/
    lda #$08                ;\ Briefly disable contact.
    sta !154C,x             ;/
    lda !14C8,x
    cmp #$09
    bne NotStationaryInteract
    jmp StationaryInteract

NotStationaryInteract:
    lda #$14                ;\
    sta $01                 ;|
    lda $05                 ;|
    sec                     ;|
    sbc $01                 ;|
    rol $00                 ;|
    cmp $D3                 ;|
    php                     ;|
    lsr $00                 ;|
    lda $0B                 ;|
    sbc #$00                ;| Don't bounce on the sprite if one of these is true:
    plp                     ;|  - Mario's Y position is too low w.r.t. the sprite's Y position.
    sbc $D4                 ;|  - Mario is moving upwards, the sprite can't be hit while moving upward
    bmi NotBouncing         ;|     and Mario hasn't bounced on any other enemies.
    lda $7D                 ;|  - Both Mario and the sprite are on the ground.
    bpl +                   ;|
    lda !190F,x             ;|
    and #$10                ;|
    bne +                   ;|
    lda $1697|!addr         ;|
    beq NotBouncing         ;|
+   lda !1588,x             ;|
    and #$04                ;|
    beq +                   ;|
    lda $72                 ;|
    beq NotBouncing         ;/
+   lda !1656,x             ;\
    and #$10                ;| If the sprite can be bounced on, jump.
    bne JumpOnSprite        ;/
    lda $140D|!addr         ;\
    ora $187A|!addr         ;| If not spinjumping or riding Yoshi, don't bounce.
    beq NotBouncing         ;/
Boost:                      ; Otherwise, spinjump on the enemy.
    lda #$02                ;\ Play SFX.
    sta $1DF9|!addr         ;/
    jsl $01AA33|!bank       ;> Boost Mario's speed.
    jsl $01AB99|!bank       ;> Display contact GFX.
    rts

NotBouncing:
    lda $13ED|!addr         ;\ If sliding
    beq +                   ;|
    lda !190F,x             ;| and sprite can be killed with slide
    and #$04                ;|
    bne +                   ;|
    lda #$03                ;|
    sta $1DF9|!addr         ;|
    %Star()                 ;/ kill.
    rts
+   lda $1497|!addr         ;\
    bne .Return             ;| If Mario is invulnerable or riding Yoshi, return.
    lda $187A|!addr         ;|
    bne .Return             ;/
    lda !1686,x             ;\
    and #$10                ;| If set to change direction when touched, do it.
    bne +                   ;|
    jsr FaceMario           ;/
+   jsl $00F5B7|!bank       ;> Hurt Mario.
.Return:
    rts

JumpOnSprite:
    lda $140D|!addr         ;\
    ora $187A|!addr         ;| If not spinjumping or riding Yoshi, it's a normal jump.
    beq NormalJump          ;/

SpinJumpKill:               ;> Otherwise, kill with a spinjump.
    jsl $01AB99|!bank       ;> Display contact GFX
if !AlwaysSpinBoost == 0    ;\
    lda #!SpinKillYSpeed    ;|
    sta $7D                 ;|
    lda $187A|!addr         ;| Boost Mario upwards (if on Yoshi).
    beq .0                  ;|
endif                       ;|
    jsl $01AA33|!bank       ;/
.0: lda #$04                ;\
    sta !14C8,x             ;| Set as "spinjump killed".
    lda #$1F                ;|
    sta !1540,x             ;/
    jsl $07FC3B|!bank       ;> Generate stars from spinjump kill.
    jsr GivePoints          ;> Give points.
    lda #$08                ;\ Play SFX.
    sta $1DF9|!addr         ;/
    rts

NormalJump:
    jsr Boost               ;> Set Y speed, display contact GFX, play SFX.
    lda !187B,x             ;\ If not Disco Shell, branch.
    beq NormalBounce        ;/
.DiscoShell:
    %SubHorzPos()           ;\
    tya                     ;| Boost Mario's X speed based on his relative position.
    lda ..XBoost,y          ;|
    sta $7B                 ;/
    rts

..XBoost:
    db !DiscoXBoost,-!DiscoXBoost

NormalBounce:
    jsr GivePoints          ;> Handle consecutive enemies stomped and all that ****.
    lda !1686,x             ;\
    and #$40                ;|
    beq DoesntSpawnNewSprite;|
    ldy !9E,x               ;|
    lda .SpriteToSpawn,y    ;| If set to spawn a new sprite, change its number based on the table.
    sta !9E,x               ;| (this also makes the Special Shell able to be bounced on twice, since it spawns a normal Green Shell).
    lda !15F6,x             ;|
    and #$0E                ;|
    sta $0F                 ;|
    jsl $07F78B|!bank       ;/
    lda !15F6,x             ;\
    and #$F1                ;| Restore palette.
    ora $0F                 ;|
    sta !15F6,x             ;/
    stz !AA,x               ;> Reset speed.
.Return:
    rts

.SpriteToSpawn:
    db $00,$01,$02,$03,$04,$05,$06,$07,$04,$04,$05,$05,$07

DoesntSpawnNewSprite:
    lda !9E,x               ;\
    sec                     ;|
    sbc #$04                ;|
    cmp #$0D                ;|
    bcs +                   ;|
    lda $1407|!addr         ;|
    bne ++                  ;| If the sprite dies when jumped on,
+   lda !1656,x             ;| or if it's sprite 4-10 and Mario flies into it,
    and #$20                ;| squish the sprite.
    beq NoSquish            ;|
++  lda #$03                ;|
    sta !14C8,x             ;|
    lda #$20                ;|
    sta !1540,x             ;|
    stz !B6,x               ;|
    stz !AA,x               ;/
    rts

NoSquish:
    lda !1662,x             ;\
    bpl DontFallStraightDown;|
    lda #$02                ;| If set to fall straight down, set state to 2
    sta !14C8,x             ;| and reset speeds.
    stz !B6,x               ;|
    stz !AA,x               ;/
.Return:
    rts

DontFallStraightDown:
    ldy !14C8,x             ;\
    stz !1626,x             ;| If in kicked state, turn into carryable state.
    cpy #$0A                ;|
    beq SetCarryable        ;/
    lda !1510,x             ;\
    and #$20                ;| If Koopa and "kill after bouncing" flag is not set, set stun timer (to spawn a Koopa from it).
    beq SetStunnedTimer     ;/
    jmp SpinJumpKill_0      ; Otherwise, kill with a spinjump.

SetCarryable:
    bit !1510,x             ;\ If "infinite bounces" flag is set, don't turn carryable.
    bmi NoSquish_Return     ;/
    bvc +                   ;> If "kill after one bounce flag" is not set, turn into carryable.
    jmp SpinJumpKill_0      ;> Otherwise, kill with a spinjump.
+   lda !C2,x               ;\ If it's a Shell with a Koopa inside it, set the stun timer.
    bne SetStunnedTimer     ;/ (to spawn a shell-less Koopa from it)
    stz !1540,x             ; Otherwise, reset stun timer.
    bra +

SetStunnedTimer:
    lda #$02                ;\ Set stun timer to 2, so next frame it'll be 1
    sta !1540,x             ;/ and the Unstun routine will branch accordingly.
+   lda #$09                ;\ Set state to carryable.
    sta !14C8,x             ;/
    rts

StationaryInteract:
    lda $140D|!addr         ;\ If spinjumping
    ora $187A|!addr         ;| or on Yoshi
    beq CheckCarrying       ;|
    lda $7D                 ;| and moving downwards
    bmi CheckCarrying       ;|
    lda !1656,x             ;| and sprite can be jumped on
    and #$10                ;|
    beq CheckCarrying       ;|
    jmp SpinJumpKill        ;/ then kill the sprite with a spinjump.

CheckCarrying:
    bit $15                 ;\ If X/Y held
    bvc KickShell           ;| (for some reason SMW uses LDA $15 : AND #$40 : BEQ but they use BIT $15 : BVC elsewhere)
    lda $1470|!addr         ;| and not carrying a sprite already
    ora $187A|!addr         ;| and not on Yoshi
    bne KickShell           ;|
    lda #$0B                ;| make Mario pick up the sprite.
    sta !14C8,x             ;|
    inc $1470|!addr         ;|
    lda #$08                ;|
    sta $1498|!addr         ;/
    rts

KickShell:
    jsr GivePoints          ; Give points
    lda #!KickedSFX         ;\ Play SFX.
    sta !KickedSFXAddr      ;/
    lda !1540,x             ;\ Probably useless.
    sta !C2,x               ;/
    lda #$0A                ;\ Set kicked state.
    sta !14C8,x             ;/
    lda #!KickNoInteractTime;\ Briefly disable interaction with Mario.
    sta !154C,x             ;/
    %SubHorzPos()           ;\
    lda KickXSpeeds,y       ;| Set X speed based on throw direction.
    sta !B6,x               ;/
    rts

KickXSpeeds:
    db -!KickXSpeed,!KickXSpeed,$CC,$34

;===============================================================;
; This routine:                                                 ;
; - Increases Mario's consecutive enemies killed counter.       ;
; - Play SFX based on (consecutive enemies bounced on by Mario) ;
;    + (consecutive enemies killed by sprite).                  ;
; - Give points based on the same value.                        ;
;===============================================================;
GivePoints:
    lda $1697|!addr         ;\
    clc                     ;|
    adc !1626,x             ;|
    inc $1697|!addr         ;|
    tay                     ;| Play bounce SFX when $1697+$1626,x < #$08
    iny                     ;| (if >= @$08, it spawns a 1up score sprite which plays the SFX)
    cpy #$08                ;|
    bcs +                   ;|
    lda .SFX-1,y            ;|
    sta $1DF9|!addr         ;/
+   tya                     ;\
    cmp #$08                ;|
    bcc +                   ;| Give points accordingly (input capped to $08 = 1up)
    lda #$08                ;|
+   jsl $02ACE5|!bank       ;/
    rts

.SFX:
    db $13,$14,$15,$16,$17,$18,$19

;=======================================================;
; Set fireball and cape immunity for the Disco Shell    ;
; depending on the flags set in the Extra Byte 2.       ;
;=======================================================;
SetDiscoShell:
    inc !187B,x             ; Set Disco Shell flag.
    lda !1510,x             ;\
    and #$18                ;|
    eor #$18                ;| Set fireball and cape immunity in the tweaker byte from the Extra Byte 2 flags.
    asl                     ;|
    ora !166E,x             ;|
    sta !166E,x             ;/
    rts

;===================================;
; HandleSpriteCarried routine       ;
;===================================;
HandleCarried:
    jsr ActuallyHandleCarried
    lda $13DD|!addr         ;\
    ora $1419|!addr         ;| If turning while sliding, going down a pipe, or facing the screen
    bne +                   ;| center the item on Mario, and change OAM index to $00
    lda $1499|!addr         ;| (to make it draw in front of Mario).
    beq ++                  ;|
+   stz !15EA,x             ;/
++  lda $64                 ;\
    pha                     ;|
    lda $1419|!addr         ;| If going down a pipe, send behind objects.
    beq +                   ;|
    lda #$10                ;|
    sta $64                 ;/
+   jsr StationaryGFX       ;> Draw the sprite.
    pla                     ;\ Restore $64.
    sta $64                 ;/
    rts

ActuallyHandleCarried:
    jsl $019138|!bank       ; Interact with blocks
    lda $71                 ;\
    cmp #$01                ;|
    bcc +                   ;|
    lda $1419|!addr         ;| If Mario let go of the sprite, return to carryable state.
    bne +                   ;|
    lda #$09                ;|
    sta !14C8,x             ;/
.Return:
    rts
+   lda !14C8,x             ;\
    cmp #$08                ;| If returned to normal state, return.
    beq .Return             ;/
    lda $9D                 ;\
    beq +                   ;| If sprites locked, just handle offset from Mario.
    jmp OffsetFromMario     ;/
+   jsr HandleStunned       ;> Handle stun timer stuff.
    jsl $018032|!bank       ;> Interact with sprites.
    lda $1419|!addr         ;\
    bne +                   ;|
    bit $15                 ;| If X/Y held or Mario going down a pipe, offset the sprite from his position.
    bvc LetGoOfSprite       ;|
+   jmp OffsetFromMario     ;/

LetGoOfSprite:
    stz !1626,x
    stz !AA,x
    lda #$09
    sta !14C8,x
    lda $15                 ;\
    and #$08                ;| Throw up if up button held.
    bne KickUp              ;/
    lda $15                 ;\
    and #$04                ;| Throw sideways if left/right held.
    beq KickSideways        ;/

Drop:
    ldy $76                 ;\
    lda $D1                 ;|
    clc                     ;|
    adc .XOffsetLow,y       ;| Offset sprite from Mario based on his direction.
    sta !E4,x               ;|
    lda $D2                 ;|
    adc .XOffsetHigh,y      ;|
    sta !14E0,x             ;/
    %SubHorzPos()           ;\
    lda .XSpeed,y           ;|
    clc                     ;| Set sprite's X speed based on drop direction + Mario's X speed.
    adc $7B                 ;|
    sta !B6,x               ;/
    stz !AA,x               ;> Reset sprite's Y speed.
    bra FinishKicking

.XOffsetLow:
    db -!DropXOffset,!DropXOffset

.XOffsetHigh:
    db $FF,$00

.XSpeed:
    db -!DropXSpeed,!DropXSpeed

KickUp:
    jsl $01AB6F|!bank       ;> Show contact GFX.
    lda #!KickYSpeed        ;\ Set Y speed.
    sta !AA,x               ;/
    lda $7B                 ;\
    sta !B6,x               ;| Give the sprite half of Mario's X speed.
    asl                     ;|
    ror !B6,x               ;/
    bra FinishKicking

KickSideways:
    jsl $01AB6F|!bank       ;> Show contact GFX.
    lda !1540,x             ;\ Probably useless.
    sta !C2,x               ;/
    lda #$0A                ;\ Set kicked state.
    sta !14C8,x             ;/
    ldy $76
    lda $187A|!addr         ;\
    beq +                   ;| If on Yoshi, use different speeds.
    iny #2                  ;/ (which is impossible without glitches :thonk:)
+   lda KickXSpeeds,y       ;\
    sta !B6,x               ;|
    eor $7B                 ;|
    bmi FinishKicking       ;|
    lda $7B                 ;| Set base X speed, and add half of Mario's speed
    sta $00                 ;| if moving in the same direction as him.
    asl $00                 ;|
    ror                     ;|
    clc                     ;|
    adc KickXSpeeds,y       ;|
    sta !B6,x               ;/

FinishKicking:
    lda #!KickNoInteractTime;\ Briefly disable interaction with Mario.
    sta !154C,x             ;/
    lda #$0C                ;\ Briefly show kicked pose.
    sta $149A|!addr         ;/
    rts

OffsetFromMario:
    lda $76                 ;\
    eor #$01                ;| SMW uses branches for this...
    tay                     ;/
    lda $1499|!addr         ;\
    beq +                   ;|
    iny #2                  ;| Set Y to 2/3 or 3/4 when turning.
    cmp #$05                ;|
    bcc +                   ;|
    iny                     ;/
+   lda $1419|!addr         ;\
    beq +                   ;|
    cmp #$02                ;|
    beq ++                  ;| If turning while sliding, going down a pipe, or climbing, set Y to 5.
+   lda $13DD|!addr         ;|
    ora $74                 ;|
    beq +++                 ;|
++  ldy #$05                ;/
+++ phy
    ldy #$00                ;\
    lda $1471|!addr         ;|
    cmp #$03                ;|
    beq +                   ;|
    ldy #$3D                ;|
+   lda $94,y               ;|
    sta $00                 ;| Use Mario's position on the next frame,
    lda $95,y               ;| unless Mario is on a brown chained platform or a falling grey platform
    sta $01                 ;| (which use the current frame).
    lda $96,y               ;|
    sta $02                 ;|
    lda $97,y               ;|
    sta $03                 ;/
    ply
    lda $00                 ;\
    clc                     ;|
    adc .XOffsetLow,y       ;|
    sta !E4,x               ;| Offset horizontally.
    lda $01                 ;|
    adc .XOffsetHigh,y      ;|
    sta !14E0,x             ;/
    lda #$0D                ;\> Y offset when big.
    ldy $73                 ;|
    bne +                   ;| Offset vertically.
    ldy $19                 ;|
    bne ++                  ;|
+   lda #$0F                ;|> Y offset when ducking or small.
++  ldy $1498|!addr         ;|
    beq +                   ;|
    lda #$0F                ;|> Y offset when picking up an item.
+   clc                     ;|
    adc $02                 ;|
    sta !D8,x               ;|
    lda $03                 ;|
    adc #$00                ;|
    sta !14D4,x             ;/
    lda #$01                ;\
    sta $148F|!addr         ;| Set carrying item flags.
    sta $1470|!addr         ;/
    rts

.XOffsetLow:
    db !CarryXOffset

.XOffsetHigh:
    db $00,$FF,$00,$FF,$00,$00

;===================================;
; Shell graphics routine            ;
;===================================;
ShellGraphics:
    %GetDrawInfo()
    lda $00                 ;\ Set X/Y position.
    sta $0300|!addr,y       ;|
    lda $01                 ;|
    sta $0301|!addr,y       ;/
    ldy !1602,x             ;\ Set tile based on animation frame.
    lda .Tilemap-6,y        ;| ($1602 starts from 6 for shells)
    ldy !15EA,x             ;| (Restore OAM index).
    sta $0302|!addr,y       ;/
    lda !157C,x             ;\ Set YXPPCCCT.
    lsr                     ;|
    lda #$00                ;|
    ora !15F6,x             ;|
    bcs +                   ;|
    eor #$40                ;| (Flip if facing left)
+   ora $64                 ;|
    sta $0303|!addr,y       ;/
    tya                     ;\ Set size (16x16).
    lsr #2                  ;|
    tay                     ;|
    lda #$02                ;|
    ora !15A0,x             ;|
    sta $0460|!addr,y       ;/
    jsr CheckDrawOnscreen
    rts

.Tilemap:
    db !ShellTiles

;===================================;
; Koopa graphics routine            ;
;===================================;
KoopaGraphics:
    %GetDrawInfo()
    lda !1602,x             ;\
    asl                     ;|
    tax                     ;|
    lda .Tilemap,x          ;| Store tile numbers to OAM.
    sta $0302|!addr,y       ;|
    lda .Tilemap+1,x        ;|
    sta $0306|!addr,y       ;/
    ldx $15E9|!addr
    lda $01                 ;\
    sta $0301|!addr,y       ;|
    clc                     ;| Store YPos and YPos+$10 to OAM.
    adc #$10                ;|
    sta $0305|!addr,y       ;/
    lda $00                 ;\
    sta $0300|!addr,y       ;| Store XPos to OAM.
    sta $0304|!addr,y       ;/
    lda !157C,x             ;\
    lsr                     ;|
    lda #$00                ;|
    ora !15F6,x             ;| Store YXPPCCCT to OAM
    bcs +                   ;| (flip if facing left).
    ora #$40                ;|
+   ora $64                 ;|
    sta $0303|!addr,y       ;|
    sta $0307|!addr,y       ;/
    tya                     ;\
    lsr #2                  ;|
    tay                     ;|
    lda #$02                ;| Set tiles size (16x16).
    ora !15A0,x             ;|
    sta $0460|!addr,y       ;|
    sta $0461|!addr,y       ;/
    jsr CheckDrawOnscreen
    rts

.Tilemap:
    db !KoopaTiles

;===================================================;
; This routine checks if the tile(s) just drawn are ;
; actually onscreen, and hides them if not.         ;
;===================================================;
CheckDrawOnscreen:
    lda !186C,x             ;\ Return if on-screen.
    beq .Return             ;/
    lsr                     ;\ Draw bottom tile if on-screen.
    bcc +                   ;|
    pha                     ;|
    lda #$01                ;|
    sta $0460|!addr,y       ;|
    tya                     ;|
    asl #2                  ;|
    tax                     ;|
    lda #$80                ;|
    sta $0300|!addr,x       ;|
    pla                     ;/
+   lsr                     ;\ Draw top tile if on-screen.
    bcc +                   ;|
    lda #$01                ;|
    sta $0461|!addr,y       ;|
    tya                     ;|
    asl #2                  ;|
    tax                     ;|
    lda #$80                ;|
    sta $0304|!addr,x       ;/
+   ldx $15E9|!addr         ;> Restore sprite index.
.Return:
    rts
