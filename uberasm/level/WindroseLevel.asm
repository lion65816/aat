;Windrose's level code
;Lord Ruby

;SA-1 only

math pri on
math round off

;;;Defines
;;Values
;Mode 7 tilemap center (both coordinates for now)
!CenterXY = $0020
;Boss max HP
!BossMHP = $08
;;RAM
;Boss coordinates (note: might be able to get away with only one byte each, since it never goes off-screen)
!BossX = $3500
!BossY = $3502
!BossPos = $350D        ;Byte for the six stationary boss positions
!RotFlag = $350E
!EyeState = $350F
;Behavior
!BossState = $3504
!NextState = $3508
!LastState = $3511
!AttackTimerA = $3505   ;Word, for now, at least
!AttackPhase = $3507    ;0 is for hurt, rest keep track of which part to do next
!AttackVarA = $350B
!AttackVarB = $350C
;NOTE: Will need to be able to resume movement after hurt
;Boss HP
!BossHP = $3509
!BossHPTimer = $350A
!DesperationFlag = $3510
;[3512-351F]
;Sprite tables
!ExpTT = $3520          ;Expiration timer table, 3520-354B (only 21 entries), word table
!SprB = $354C           ;Projectile behavior table, 354C-3561
!SprV = $3562           ;Projectile variant (contained sprite) table, 3562-3577
;[Include others as necessary]
;;Fixed RAM             ;Used for interacting with the game, do not touch
!SprFlags = $6040       ;Extra bit and custom bit, $7FAB10 without SA-1
!PSprNum = $6083        ;PIXI custom sprite number, $7FAB9E
;;HP
;Origin for the HP eyes, YYXX. Note that the top left corner of the screen is 0000.
;Level-specific HP settings
!InitHP = $03
!MaxHP = $03
;Copy from simpleHP.asm:
!HPSettings = $788A
!HPByte = $58
!PowerupResult = $7C

load:
	JSL NoStatus_load
	RTL

init:
    REP #$20

    ;;Mode 7 setup
    LDX.b #$07 : STX $3E            ;Mode 7
    LDA #$2020 : STA $38            ;Default scaling for both axes
    STZ $36                         ;Default rotation (may already default to zero, but to be sure)
    LDA #$FF80+!CenterXY            ;Center position calculation (SMW adds 0x80 to center, so subtract that here)
    STA $2A : STA $2C               ;Center positions
    STZ $30    : STZ $32            ;B, C. Matrix parameters are only automatically set after loading has finished...
    LDA #$0100 : STA $2E : STA $34  ;A, D. ...but they're used for rendering before that.
    ;Initial position (center: 96, 64)
    LDA #$0060 : STA !BossX         ;X position. Note: Top left corner coordinates.
    LDA #$FFA0 : STA $3A            ;X position, mode 7. Note: Value needs to be negative, should be 0000-BossX
    LDA #$0040 : STA !BossY         ;Y position
    LDA #$FFBF : STA $3C            ;Y position, mode 7. Should be FFFF-BossY, because of the missing top row

    ;;VRAM upload
    ;DMA channel 0
    LDX.b #$80 : STX $2115          ;Increment on high write (for interleaved)
    STZ $2116                       ;Start writing from address 0000
    LDA #$1801        : STA $4300   ;Low: 2 registers, write once. High: Write to 2118-2119
    LDA.w #vrdata     : STA $4302   ;Data address, low bytes
    LDX.b #vrdata>>16 : STX $4304   ;Data address, bank byte
    LDA #$8000        : STA $4305   ;Data size (half a bank... -_-)
    LDX #$01 : STX $420B            ;DMA using channel 0

    ;Mode 7 settings 211A?
    ;EXTBG 2133?

    ;set default sprite priority?

    ;;Background
    ;HDMA channel 3
    LDA #$3202 : STA $4330          ;Low: 1 register, write twice. High: Write to 2132
    LDA.w #rgtable     : STA $4332  ;HDMA table address, low bytes
    LDX.b #rgtable>>16 : STX $4334  ;HDMA table address, bank byte
    ;HDMA channel 4. Alas, no write thrice.
    LDA #$3200 : STA $4340          ;Low: 1 register, write once. High: Write to 2132
    LDA.w #btable      : STA $4342  ;HDMA table address, low bytes
    LDX.b #btable>>16  : STX $4344  ;HDMA table address, bank byte

    SEP #$20

    LDA #$18 : TSB $6D9F            ;Activate HDMA channels 3 and 4

    ;NOTE: I guess the rest of this could be executed in parallel on SA-1, but I don't expect it to matter.

    ;;Spawn boss sprite.
    LDX #$00                        ;Hardcode to index 0
    ;Boss position? I don't think it's necessary, will need to update every frame before collision anyway.
    STZ !14E0                       ;Boss high X position, so it doesn't need to be updated each frame
    LDA #$88 : STA !PSprNum         ;Custom sprite number (7FAB9E; uberasm has no define for this :( )
    JSL $07F722                     ;Clear sprite tables
    LDA #$08 : STA !SprFlags        ;Custom sprite flag ($7FAB10)   ;NOTE: Needs to be after 07F722, that's hijacked :(
    STA !14C8                       ;Alive status (skips initialization routine)
    STZ !15A0                       ;On-screen
    JSL $0187A7                     ;Initialize custom sprite tables

    ;;Initialize RAM
    LDA #$06 : STA !BossState       ;Intro state
    LDA #$0C : STA !NextState       ;Run animation after intro
    LDA #$12 : STA !LastState       ;Do not start with rain attack
    LDA #$60 : STA !AttackTimerA    ;Wait for about a second and a half
    STZ !AttackTimerA+1
    STZ !AttackPhase                ;Init phase
    LDA #$01 : STA !BossPos         ;Center-low position
    STZ !RotFlag                    ;Rightside up
    LDA #$04 : STA !EyeState        ;Closed eyes
    STZ !DesperationFlag            ;Has not used desperation attack yet

    ;;HP and retry.                 ;Think I'll just use instant retry without life loss for retry?
    ;Player HP
    LDA #$01 : STA $19              ;Big
    STZ $6DC2                       ;Empty item box
    LDA #$80 : STA !HPSettings      ;Activate HP system.
    LDA #!InitHP : STA !HPByte      ;Starting HP
    ;Boss HP
    LDA #!BossMHP : STA !BossHP

    ;TODO: Filter Yoshi
RTL

main:
    LDA $9D : BNE .return           ;Do nothing if game is frozen   ;NOTE: Not actually pause?? See below
    LDA $73D4 : BNE .return         ;Actual pause flag??
    REP #$20

    ;Parallel SA-1 invocation
    LDA.w #SAMain     : STA $3180   ;SA-1 call address, low bytes
    LDX.b #SAMain>>16 : STX $3182   ;SA-1 call address, bank byte
    LDX.b #$80        : STX $2200   ;Invoke SA-1

    ;Might want to put the rest of this in WRAM.
    ;That is, parallel SNES-side code.

    SEP #$20

    ;Disable sprite interaction on held items
    LDX #$15                        ;Starting index
    .loop:
    LDA !14C8,x                     ;Sprite status
    CMP #$09 : BEQ +                ;Check if carryable
    CMP #$0A : BEQ +                ;Check if kicked
    CMP #$0B : BNE +++              ;Check if held
    LDA #$08 : ORA !1686,x          ;Add noninteraction bit
    BRA ++
+   LDA #$F7 : AND !1686,x          ;Remove noninteraction bit
++  STA !1686,x                     ;Update tweaker bits
+++ DEX : BNE .loop                 ;Iterate, stop upon reaching boss itself

    JSR $1E85                       ;Wait for SA-1 to finish
    .return:
RTL

SAMain:
    PHB
    PHK : PLB
    ;~~to do~~: draw sprites (and everything else)   ;don't draw any sprites in mode 7 level code :(

    ;Make Demo small when she only has one hit point
    LDA !HPByte : DEC : BNE +                   ;Check 1 HP
    STA $19                                     ;Store small

    ;;Attacks
+   LDX !BossState                              ;Load current state
    JSR (States,x)                              ;Execute state-dependent behavior

    ;;Expiration timers
    ;Start X at 1, Y at 2. Increment (no, decrement) Y twice per loop, use as index for word timer table.
    ;NOTE: Indexed STX and STY only support the direct page, so set it to, like, 3500 instead of 3000 if necessary.
    LDX #$15 : LDY #$28                         ;Starting indices
    ;NOTE: Word tables are only 21 bytes/words long, so Y starts at 40. Base tables are 22, so X starts at 21. 0 counts!
    REP #$20
    JSR ExpT_start                              ;Start looping routine

    SEP #$20

    PLB
RTL

GetSpriteSlot:
    LDX #$15                    ;Start at highest slot (remember, zero counts)
    CLC                         ;Carry clear: Success
    .loop:
    LDA !14C8,x : BEQ .return   ;Check slot
    DEX
    BNE .loop                   ;Break loop at zero (boss sprite)
    SEC                         ;Carry set: Failure
.return:
RTS

States:
dw .hurt                        ;00: Hurt
dw .default                     ;02: AI
dw .death                       ;04: Death
dw .intro                       ;06: Intro
dw .move                        ;08: Move
dw .dummy                       ;0A
dw .waking                      ;0C: Opening eyes
dw .meteor                      ;0E: Meteor
dw .wave                        ;10: Wave
dw .rain                        ;12: Rain
dw .half                        ;14: Halfway point
dw .desperation                 ;16: Desperation attack

.hurt:
    LDA !BossHPTimer : BEQ ..end    ;If timer is zero, end hurt state
    LSR : BCS ..return              ;Don't do anything on odd frames
    TAX                             ;Despawn sprite slots from end to beginning
    JSR DespawnGlitter
    BCC ..return                    ;If carry is clear, smoke shouldn't be spawned
    LDA #$06  : STA $77CC,y         ;6 frames, so I can despawn a sprite safely every 2 frames
RTS

..end:
    STZ !EyeState                   ;Open eyes again
    LDA !BossHP : CMP #$04 : BEQ ..special      ;Special attack
    CMP #$01 : BEQ ..special                    ;Special attack
    LDA !NextState                  ;Check next state
    CMP #$02 : BEQ +                ;If AI, go back to that state
    CMP #$0C : BEQ ..waking         ;If waking up, do that; if neither, movement has been interruped.
    STZ !AttackVarB                 ;Teleport movement pattern
    LDA #41 : STA !AttackTimerA     ;Movement timer
    LDA #$08                        ;Move state
+   STA !BossState                  ;Set state
..return:
RTS

..special:
    LDA #$02 : STA !BossState       ;Let the AI handle special phases
RTS

..waking:
    STA !BossState                  ;Set state
    LDA #91 : STA !AttackTimerA     ;Animate for a second and a half
    LDA #$02 : STA !EyeState        ;Opening eyes
RTS

.dummy:
    LDA !AttackTimerA : BNE ..decRet    ;Wait between actions
    LDA !AttackPhase : BNE ..end        ;Check phase
;temp:
;projectile dummy behavior
    ;Init
;     LDA $14 : BNE .return       ;Spawn about ever four seconds
    ;;Test spawning projectiles
    JSR GetSpriteSlot
    LDA #$89 : STA !PSprNum,x       ;Custom sprite number
    JSL $07F722                     ;Clear sprite tables
    LDA #$08 : STA !SprFlags,x      ;Custom sprite flag
    STA !14C8,x                     ;Alive status (skips initialization routine)
    JSL $0187A7                     ;Initialize tables
    ;X position, 256
    STZ !E4,x                       ;Low byte
    LDA #$01 : STA !14E0,x          ;High byte
    ;Y position, 192 (screen position) + 128
    STA !14D4,x                     ;High byte
    LDA #$40 : STA !D8,x            ;Low byte
    ;Speeds
    LDA #$E8 : STA !B6,x            ;X, -24 subpixels per frame
    LDA #$0C : STA !AA,x            ;Y, 12 subpixels per frame
    ;Projectile variables
    STZ !SprB,x                     ;Basic behavior
    LDA #$06 : STA !SprV,x          ;Green Goopa
    TXA : DEC : ASL : TAX           ;Convert to word table index
    REP #$20
    LDA #$0100 : STA !ExpTT,x       ;About 8 seconds
    SEP #$20
;endtemp
    INC !AttackPhase                ;Next, return to AI and movement
    LDA #$40 : STA !AttackTimerA    ;Wait a second
RTS

..decRet
    DEC !AttackTimerA
RTS

..end:
    LDA #$02 : STA !BossState       ;Return to AI and movement
RTS

.default:
    ;General flow:
    ;;Look up last attack, iterate randomly to one of the others
    ;;;Set move as current phase and next attack as next and last phase.
    ;;Look up current position.
    ;;;Retrieve column, add one or two columns, subtract one cycle if out of bounds. Store to scratch.
    ;;;Retrieve column. If center, copy random column as side column to another scratch. If side, store opposite column.
    ;;;Roll random height, store to scratch RAM.
    ;;;Look up next phase, jump to small routine that ors immediates and/or appropriate scratch bytes. Store to scratch.
    ;;;Clear movement pattern. Compare next position with current position, set bits depending on difference types.
    ;;;;Actually, with the right bit structure, we can just take the difference.
    ;;;;Also set movement timer.
    ;;;Finally, store next position as current position? So complicated...

    LDA #$08 : STA !BossState   ;Move before executing next attack

    ;;Attack setup
    ;Halfway attack
    LDA !BossHP : CMP #$04 : BNE ++     ;Check for half HP
    LDA #$14 : STA !NextState           ;Halfway attack (preserve last state from before)
    LDA #$01                            ;Next position (halfway, low center)
    BRA ..pattern                       ;Should just barely reach...?
    ;Desperation attack
++  DEC : BNE +                         ;Check for last hit point
    LDA !DesperationFlag : BNE +        ;Check if desperation attack has already been used
    INC !DesperationFlag                ;Next time, it will have been used
    LDA #$16 : STA !NextState           ;Desperation attack
    LDA #$10 : STA !LastState           ;Based on wave attack, so treat that as used
    BRA ..wave
    ;Normal attack roll
+   JSL $01ACF9                         ;Roll random number (stored in $748D)
    LDA $748D : AND #$02                ;Get coin flip
    SEC : ADC !LastState : INC          ;Add 2 + 2 * coin flip to roll a random other attack
    CMP #$13 : BCC + : SBC #$06         ;If beyond range, cycle back
+   STA !NextState : STA !LastState     ;Execute rolled attack

    ;;Movement setup
    ;Positions: X:  48, 0x30;   96, 0x60;  144, 0x90
    ;Y:  32, 0x20:      0x80,       0x81,       0x82        ;This way, the minus flag corresponds to top row.
    ;    64, 0x40:      0x00,       0x01,       0x02        ;While ANDing that out, a difference yields the 5 X patterns.
    ;Random other column ($00)
    LDA $748D : AND #$01                ;Get coin flip (has already rolled but not used this bit)
    SEC : ADC !BossPos : AND #$07       ;Add 1 + coin flip to column. Discards Y bit.
    CMP #$03 : BCC + : SBC #$03         ;Cap at 2, cycling around
+   STA $00 : STA $01                   ;Store random other column (00). Also sets up center case for the side column.
    ;Non-center column ($01; if on side, store other side, if center, use random other column)
    LDA !BossPos : AND #$03             ;Get column
    CMP #$01 : BEQ +                    ;Use the value set up earlier if center
    EOR #$02                            ;Opposite column
    STA $01                             ;Store opposite side column
    ;Random height ($02)
+   LDA $748D : AND #$80                ;Coin flip
    STA $02                             ;Store random height

    ;Look up next phase, small routine that ors immediates and/or appropriate scratch bytes. Store to scratch.
    LDA !NextState : CMP #$10 : BNE +   ;Wave
    ..wave:
    LDA #$81                            ;Next position (wave, top center)
    BRA ..pattern
+   CMP #$0E : BNE ++                   ;Meteor
    LDA $01 : ORA $02                   ;Next position (meteor, side)
    BRA ..pattern
++  LDA $00 : ORA $02                   ;Next position (rain (process of elimination), free destination)

    ..pattern:
    ;Movement pattern
    STA $03                             ;Store next position to scratch
    SEC : SBC !BossPos                  ;Take difference between next and current position
    BEQ ..teleport                      ;Same position, teleport animation
    AND #$07 : TAX                      ;Get X difference, use as index
    LDA XPattern,x                      ;Load X movement pattern
    BIT !BossPos : BPL +
    BIT $03 : BMI ++                    ;If both positions are top row, no Y movement
    ORA #$40 : BRA ++                   ;Set down bit if next position is bottom but current is top row
+   BIT $03 : BPL ++                    ;If both are bottom row, again, no Y movement
    ORA #$80                            ;Set up bit if next position is top but current is bottom row
++  STA !AttackVarB                     ;Store movement pattern

    LDA $03 : STA !BossPos              ;Store position
    LDA #29-1 : STA !AttackTimerA       ;Movement timer
RTS

..teleport:
    STZ !AttackVarB                     ;Teleport pattern
    LDA $03 : STA !BossPos              ;Store position.
    LDA #41-1 : STA !AttackTimerA       ;Movement timer, longer for teleport
RTS

.teleport:                              ;Teleport movement pattern
    LDX !AttackTimerA                   ;Movement timer
    LDA $36                             ;Current rotation
    SEC : SBC MovTRot,x                 ;Rotate
    BCS + : DEC $37                     ;;2-byte address
+   CPX #14 : BNE ++                    ;Check for teleport frame
    LDY #$20                        ;o:Y;High Y position
    LDA !BossPos                        ;Load boss location
    BMI + : LDY #$40                ;o:Y;Low Y position
+   STY !BossY                      ;i:Y;Set Y position
    AND #$0F : TAX                      ;Set up index for X position (low bits)
    LDA XPos,x : STA !BossX             ;X
    JSR .updateMode7
    TDC                             ;o:A;Reset rotation to half on teleport     ;(TDC loads zero)
++  STA $36                         ;i:A;Set rotation
    DEC !AttackTimerA : BPL ..return    ;Decrement timer
    JSR .updateMode7
    LDA !NextState : STA !BossState     ;Update boss state
    LDA #$02 : STA !NextState           ;Set next state to AI.
    STZ !AttackTimerA : STZ !AttackPhase;Init phase
    ..return:
RTS

.move:
    ;General flow:
    ;;Check for teleport pattern, which uses a special routine. 0?
    ;;Check horizontal movement - positive, negative, or constant. Add, sub, or skip as appropriate.
    ;;;Note: Near and far can be discriminated by just including the offset in the pattern byte. Rest are trinary.
    ;;Check vertical movement - positive, negative, constant. Again, appropriate operation.
    ;;Also, rotation
    ;;On the final frame (and the teleport frame), directly set values based on position byte, as a safeguard...?
    ;;;And implement the next phase.

    ;Movement patterns: UDLfffRf
    ;;0, reserved for teleport (as always, position contains destination). One of UDLR will otherwise be set.
    ;;U, up; D, down; L, left; R, right. Note: UD can be checked with address BIT, nv processor flags.
    ;;ffff: Far X movement. Note, assumed to all be set or clear. Values: 0, or 0b00011101, which is 29 (table size).

    LDA !AttackVarB                     ;Check movement pattern
    BEQ .teleport                       ;Teleporting needs special code

    ;X
    AND #%00011101                      ;Get near/far offset
    CLC : ADC !AttackTimerA : TAX       ;Add to timer index
    LDA !AttackVarB                     ;Movement pattern
    BIT #%00100010 : BEQ +++            ;No X movement, skip
    BIT #%00100000 : BNE +              ;Check for left
    LDA !BossX
    CLC : ADC MovXNear,x                ;Add offset for right
    BRA ++
+   LDA !BossX
    SEC : SBC MovXNear,x                ;Subtract offset for left
++  STA !BossX                          ;Store result

    ;Y
+++ LDX !AttackTimerA               ;o:X;Attack timer index
    BIT !AttackVarB                ;o:nv;Check Y bits
    BMI +                           ;i:n;Check for upward
    BVC +++                         ;i:v;Branch if not down either
    LDA !BossY
    CLC : ADC MovY,x                    ;Add offset for down
    BRA ++
+   LDA !BossY
    SEC : SBC MovY,x                    ;Subtract offset for up
++  STA !BossY                          ;Store result

    ;Rotation
+++ LDA $36                             ;Rotation
    SEC : SBC MovRot,x              ;i:X;Rotate
    BCS + : DEC $37                     ;Store, high byte
+   STA $36                             ;Store, low byte
    JSR .updateMode7

    ;Movement end                       ;Resets positions, to make sure the boss position never bugs out. Hopefully...
    DEC !AttackTimerA : BPL ..return    ;Decrement timer
    LDY #$20                        ;o:Y;High Y position
    LDA !BossPos                        ;Load boss location
    BMI + : LDY #$40                ;o:Y;Low Y position
+   STY !BossY                      ;i:Y;Set Y position
    AND #$0F : TAX                      ;Set up index for X position (low bits)
    STA $3C                             ;Mode 7 Y
    LDA XPos,x : STA !BossX             ;X
    JSR .updateMode7
    STA $3A                             ;Mode 7 X
    LDA !NextState : STA !BossState     ;Update boss state
    LDA #$02 : STA !NextState           ;Set next state to AI.
    STZ !AttackTimerA : STZ !AttackPhase;Init phase
;For move, I think I can restrict it to 1, 2, or 4 possible destinations:
;Never same column, so up to two columns (some attacks might need Windrose to be on the side (also some in the middle?)).
;Possibly same height, so up to two elevations (some attacks would need Windrose to stay high).
;(Should add positions that interpolate nicely and don't overlap with HP eyes, so X>32?) (similarly, Y>24)
;Movement time: 30 frames? Well, 29 frames below, close enough.
;;Y movement: 32 pixels. 2*(1, 0, 0), 3*(1, 0), 6*1, 10*2, 1
;;X near movement: 48..? 3*(1, 0), 2*(1, 0, 1), 2*(1, 2), 2, 10*3, 2, 1
;;X far movement: 96...? 7*1, 2, 2*1, 2*2, 2*3, 2*4, 2*5, 8*6, 5, 3, 1
;;Rotation: 0x100....... 11*0, 2, 3, 5, 8, 12, 16, 9*21, 13, 6, 2
;;Tele-rotation: 0x200.. 11*0, 2, 3, 5, 8, 12, 16, 10*21, teleport, 11*21, 15, 8, 2
    ..return:
RTS

.updateMode7:
    ;Mode 7 ends up one pixel more to the right and down when upside down without using the flag
;     ;Note: $37&01 would make for a valid upside down flag...
;     ;;No wait it sucks, should update about halfway instead.
;     LDA $37 : AND #$01 : PHA                    ;Rotation offset
    LDA $36 : ROL #2 : EOR $37 : AND #$01       ;Check if rotation is in the 0x80-17F range (upside down)
    STA !RotFlag                                ;Use as flag/offset
    CLC : SBC !BossY : STA $3C                  ;Convert Y to mode 7 coordinates        ;0xFF+RotOffset-BossY
    LDA !RotFlag : SEC : SBC !BossX : STA $3A   ;Convert X to mode 7                    ;0x00+RotOffset-BossX
RTS

.waking:
    LDA !AttackTimerA : DEC                     ;Decrement timer
    BEQ ..end                                   ;Finish phase
    STA !AttackTimerA
    CMP #60 : BNE ..return                      ;Check for eye-opening frame (after half a second)
    STZ !EyeState                               ;Open eyes
RTS

..end:
    LDA #$02 : STA !BossState                   ;Start AI
..return:
RTS

.death:
    ;TODO: Do this properly         ;eh, whatever
    STZ $88                     ;Teleport immediately in pipe state
    LDA #$06 : STA $71          ;Enter pipe state
RTS

.intro:
    LDA !AttackTimerA : BNE ..decRet        ;Wait until it's time to execute the next part
    LDY !AttackPhase  : BNE ..main          ;Load spawn index, checking for initialization
    ..init:
    LDA $94 : CMP #$78                  ;o:c;Carry is set if Demo is on the right half of the screen
    LDA #$E8                                ;X speed: -24 subpixels per frame...
    BCC +                               ;i:c;      ...if Demo is on the left half, else...
    LDA #$18                                ;X speed: +24 subpixels per frame
+   STA !AttackVarB                         ;Store X speed reference
    ROL : AND #$01 : STA !AttackVarA    ;i:c;Flag for attacking from the left.
    INC !AttackPhase
RTS

..decRet:
    DEC !AttackTimerA
RTS

..main:
    ..spawn:
    JSR GetSpriteSlot                           ;o:c
    BCS ..prepRet                               ;i:c;Abort if there are no empty sprite slots
    LDA #$89 : STA !PSprNum,x                       ;Custom sprite number
    JSL $07F722                                     ;Clear sprite tables
    LDA #$08 : STA !SprFlags,x                      ;Custom sprite flag
    STA !14C8,x                                     ;Alive status (skips initialization routine)
    JSL $0187A7                                     ;Initialize tables

    ;Position
    LDA ..tableMain-1,y : AND #$F0 : STA !D8,x      ;Y, low byte, from phase table
    LDA #$01 : STA !14D4,x                          ;Y, high byte
    BIT !AttackVarA : BEQ + : LDA #$FF              ;Keep 1 if attacking from the right, FF from the left
+   STA !14E0,x                                     ;X, high byte
    AND #$F0 : STA !E4,x                            ;X, low byte (0 from right, -16 from left)

    ;Speeds
    STZ !AA,x                                       ;Stationary Y speed
    LDA !AttackVarB : STA !B6,x                     ;X speed from variable      ;Optimization: EOR #$E8 should work?

    ;Projectile variables
    STZ !SprB,x                                     ;Basic behavior
    LDA ..tableMain-1,y : AND #$06 : STA !SprV,x    ;Contained sprite from phase table
    BNE + : LDA #$A0 : STA !1656,x                  ;If it contains a Spiny, don't set jumpable flag
+   TXA : DEC : ASL : TAX                           ;Convert to word table index    ;NOTE: Destroys sprite index
    LDA #$02 : STA !ExpTT+1,x : STZ !ExpTT,x        ;About 8 seconds                      ;Wait, I think that's fine?

    ..prepRet:
    ;Prepare for next projectile
    INY                                             ;Increment attack phase
    LDA ..tableMain-2,y : LSR : BCC +               ;Check for swap side flag (last phase)
    LDA !AttackVarA : EOR #$01 : STA !AttackVarA    ;Invert side flag
    LDA !AttackVarB : EOR #$F0 : STA !AttackVarB    ;Invert speed
    LDA ..tableTimer-2,y : BEQ ..spawn              ;Check timer, loop if 0
+   LDA ..tableTimer-2,y : STA !AttackTimerA        ;Set timer until next projectile
    ;Better SFX?    ;Hit 3 will do
;     LDA ..tableMain-2,y : AND #$08 : BEQ +          ;Check sound flag
;     LDA #$23 : STA $7DFC                            ;Sound: step on tile
    ;7DFC: 29 (correct)? 23 (step on tile)? 09 (shot)?? 06 (fireball)?? 14 (unused)?? 19 (pop)? 1C (switch block eject)??
;    LDA #$15 : STA $7DF9                            ;Sound: Hit 3
    LDA #$32 : STA $7DF9                            ;SMAS climb sound
    ;7DF9: 10 (magic)?? 13-19 (hit)???
    ;Pop is kinda nice. Not correct. Step on tile is all right.
    ;Not unused. Not eject.
+   CPY #$1E : BCC + : LDY #$06                     ;Loop attack phase if we've reached the end of the table
+   STY !AttackPhase                                ;Store attack phase
RTS

;Main table     ;NOTE: Call with -1, since 0 is indexing phase  ;Format: YYYYaVVb   ;VV: Variant (00, 02, 04, 06)
..tableMain:                    ;YYYY: Row to spawn on (00 is 5, 80 is 13)  ;a: Sound flag  ;b: Swap side flag
db $84+8, $72, $64              ;Simple alternating ascending pattern
db $32, $06+1                   ;Opportunity for early counterattack
db $84+8, $72, $64, $52+1       ;Ascending 4 blocks                         ;Start loop here
db $84+8, $72, $64, $52, $44    ;And ascending 5 blocks, which should be very tricky to completely clear without bouncing
;Ascending 3 blocks on both sides
db $84+1+8, $82
db $74+1, $72
db $64+1, $62                   ;Next will be on the side opposite to the pattern preceding the two-sided wave
db $80+8, $70, $62, $36+1       ;Introduces Spinies, with another counterattack opportunity
db $80+8, $70+1                 ;Light Spiny pattern if they mess up counterattack
db $80+8, $70, $66+1            ;Final pattern, easiest Goopa opportunity   ;Loop after Y=1D?

..tableTimer:   ;Call with -1.  ;Timer before next enemy    ;NOTE: Delayed by one frame, while 0 spawns it immediately
db $0D, $0D, $29                ;0D is 13, so 14 frames (21 pixels) between roses
db $29, $4F                     ;0D+0E+0E=29. Total cycle time: 0xE*2+0x2A*2+0x50=0xC0=192
db $0D, $0D, $0D, $7F           ;Total time from first of this to first of next: 0xE*3+0x80=0xAA=170
db $0D, $0D, $0D, $0D, $71      ;Should be same cycle time
db $00, $0D
db $00, $0D
db $00, $97                     ;More time to breathe before Spinies. Time: 0xE*2+0x98=0xB4=180
db $0D, $0D, $29, $63           ;Time: 0xE*2+0x2A+0x64=0xAA=170
db $0D, $9B                     ;Time: 0xE+0x9C=0xAA=170
db $0D, $0D, $8D                ;Time: 0xE*2+0x8E=0xAA=170

.half:
    LDA !AttackTimerA : BNE ..decRet        ;Wait until it's time to execute the next part
    LDY !AttackPhase  : BNE ..main          ;Load spawn index, checking for initialization
    ..init:
    LDA $94 : CMP #$78                  ;o:c;Carry is set if Demo is on the right half of the screen
    LDA #$E8                                ;X speed: -24 subpixels per frame...
    BCC +                               ;i:c;      ...if Demo is on the left half, else...
    LDA #$18                                ;X speed: +24 subpixels per frame
+   STA !AttackVarB                         ;Store X speed reference
    ROL : AND #$01 : STA !AttackVarA    ;i:c;Flag for attacking from the left.
    INC !AttackPhase
RTS

..decRet:
    DEC !AttackTimerA
RTS

..main:
    JSR GetSpriteSlot                           ;o:c
    BCS ..prepRet                               ;i:c;Abort if there are no empty sprite slots
    LDA #$89 : STA !PSprNum,x                       ;Custom sprite number
    JSL $07F722                                     ;Clear sprite tables
    LDA #$08 : STA !SprFlags,x                      ;Custom sprite flag
    STA !14C8,x                                     ;Alive status (skips initialization routine)
    JSL $0187A7                                     ;Initialize tables

    ;Position
    LDA ..tableMain-1,y : AND #$F0 : STA !D8,x      ;Y, low byte, from phase table
    LDA #$01 : STA !14D4,x                          ;Y, high byte
    BIT !AttackVarA : BEQ + : LDA #$FF              ;Keep 1 if attacking from the right, FF from the left
+   STA !14E0,x                                     ;X, high byte
    AND #$F0 : STA !E4,x                            ;X, low byte (0 from right, -16 from left)

    ;Speeds
    STZ !AA,x                                       ;Stationary Y speed
    LDA !AttackVarB : STA !B6,x                     ;X speed from variable

    ;Projectile variables
    STZ !SprB,x                                     ;Basic behavior
    LDA ..tableMain-1,y : AND #$0F : ASL : PHA      ;Get contained sprite
    STA !SprV,x                                     ;Contained sprite from phase table
    BNE + : LDA #$A0 : STA !1656,x                  ;If it contains a Spiny, don't set jumpable flag
+   TXA : DEC : ASL : TAX                           ;Convert to word table index
    PLA : CMP #$1A : BNE +                          ;Check if blue Goopa
    INC
+   AND #$01 : STA !ExpTT+1,x                       ;About 4 more seconds counterattack Goopa
    LDA #$BE : STA !ExpTT,x                         ;About 3 seconds

    ..prepRet:
    ;Prepare for next projectile
    INY                                             ;Increment attack phase
+   LDA ..tableTimer-2,y : STA !AttackTimerA        ;Set timer until next projectile
    LDA #$32 : STA $7DF9                            ;SMAS climb sound
    CPY.b #..tableTimer-..tableMain+1               ;Check for end of table
    BCC + : LDY #$01                                ;Loop attack phase if we've reached the end of the table
+   STY !AttackPhase                                ;Store attack phase
RTS

;Main table                     ;Format: YYYYVVVV   ;VVVV: Variant (0: Spiny, 4: Y SL Goopa (C: B), D: Blue Goopa)
..tableMain:                    ;YYYY: Row to spawn on (00 is 5, 80 is 13)
db $8C, $74, $6C, $54, $5C, $40, $40
db $5C, $64, $7C, $74, $6C, $50, $60, $7C, $84
db $84, $7C, $60, $50, $4C, $44, $3C, $20, $20, $3C
db $34, $4C, $54, $60, $60, $7D, $8C, $8C
db $70, $60, $60, $7C, $84
db $8C, $74, $7C, $60, $5C, $5C, $40, $30, $4C, $4C
db $30, $30, $2C, $30, $40, $50, $6C, $64, $6C
db $70, $80
db $8C, $74, $7C, $64, $6C, $50, $50, $40, $40
db $5C, $54, $4C, $34, $3C, $20, $20, $30, $30
db $4C, $44, $50, $6D, $6C, $50, $50, $60
db $7C, $74, $7C, $8D

..tableTimer:
db $0D, $0D, $0D, $0D, $0D, $0D, $0D
db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $45
db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
db $0D, $0D, $0D, $0D, $7D
db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
db $0D, $45
db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
db $0D, $0D, $0D, $8B

.meteor:
    LDA !AttackTimerA : BNE ..decRet        ;Wait until it's time to execute the next part
    LDY !AttackPhase  : BNE ..main      ;o:Y;Load spawn index, checking for initialization
    ..init:
    LDA !BossPos : LSR : DEC : AND #$01     ;Check if on left side
    STA !AttackVarA                         ;Flag (0/1) for attacking from the left.
    LDA #$03                                ;First  half: 3 projectiles
    LDY !BossHP : CPY #$04 : BCS +          ;Check half
    LDA #$05                                ;Second half: 5 projectiles
+   STA !AttackVarB                         ;Store variant
    INC !AttackPhase
RTS

..decRet:
    DEC !AttackTimerA
RTS

..stall:
    INY : STY !AttackPhase
    LDA #$AA : STA !AttackTimerA                    ;Set timer until end (170 frames, about 3 seconds, for 5 total)
RTS

..end:
    LDA #$02 : STA !BossState                       ;Go back to AI
RTS

..main:
    CPY #$09 : BEQ ..stall                  ;Check for end, but pad the timer out a little
    CPY #$0A : BCS ..end                    ;Check for end

    ;Relevant Y range? Say, from 40 pixels off the ground, to 232 (256-24)? Outside range (25%), aim.
    ;;Recall: I believe 0x180 is just above ground, so 0x190 should be ground level. -> Range: 0xA8-168
    ;So, first, store X speed (24 subpixels per frame) to scratch
    ;;Roll, save offset (00-C0 or aim result) to scratch, then add for each sprite's offset (since these differ)
    ;;Get main enemy from table, with enemy 2 and 3 always being shelless Goopas, 4 and 5 (if advanced) are Spinies.
    ;;;Oh, but different tables depending on basic or advanced?

    ;Common preparation
    ;;Effective target position (Y offset)
    JSL $01ACF9 : LDA $748D                 ;Get random number ($148D).
    CMP #$C0 : BCC +                    ;o:c;If in natural range (00-C0), use.
    ;...if not, aim.
    ;Want: From left: 0x170-DemoX. From right: 0x80+DemoX. But could just store her position, since that's the below format.
    LDA !AttackVarA : BNE ..left
    ;Right
    LDA $94 : BRA ++                        ;Just use Demo's position, random roll is like an effective position, then.
    ..left:
    LDA #$F4 : SBC $94 : BRA ++         ;i:c;Attacking from the left, convert effective positon into right format. (Width: 0C?)
+   ADC #$18                            ;i:c;Turn into effective position.
++  STA $04                                 ;Store Y offset (18-D8) to scratch.
    ;;X positions and speed
    LDA !AttackVarA : BNE +
    ;Right
    STZ $06 : STZ $07                       ;Slots 1, 2:   0
    LDA #$11 : STA $08 : STA $09            ;Slots 3, 4:  17
    LDA #$22 : STA $0A                      ;Slot     5:  34
    LDA #$E8 : BRA ++                       ;Speed: -24 subpixels per frame
    ;Left
+   LDA #$F0 : STA $06 : STA $07            ;Slots 1, 2: -16
    LDA #$DF : STA $08 : STA $09            ;Slots 3, 4: -33
    LDA #$CE : STA $0A                      ;Slot     5: -50
    LDA #$18                                ;Speed: +24 subpixels per frame
++  STA $05                                 ;Store common X speed

    ;Spawn routine
    ;;Initialization
    JSR GetSpriteSlot                           ;o:c
    BCS ..prepRet                               ;i:c;Abort if there are no empty sprite slots
    LDA #$89 : STA !PSprNum,x                       ;Custom sprite number
    JSL $07F722                                     ;Clear sprite tables
    LDA #$08 : STA !SprFlags,x                      ;Custom sprite flag
    STA !14C8,x                                     ;Alive status (skips initialization routine)
    JSL $0187A7                                     ;Initialize tables  ;NOTE: Uses $00 and $02 (start at $04 to be safe?)

    ;;Basic projectile variables
    STZ !SprB,x                                     ;Basic behavior
    LDA ..table-1,y :  STA !SprV,x              ;i:Y;Contained sprite from phase table
    LDA !BossHP : CMP #$04 : BCS ++                 ;Check half
    LDA ..table+7,y :  STA !SprV,x                  ;Advanced contained sprites in second half
++  BNE + : LDA #$A0 : STA !1656,x                  ;If it contains a Spiny, don't set jumpable flag

+   LDY #$00
    ..loop:

    ;;Position
    LDA #$80 : SEC : SBC ..yoff,y                   ;Y, sub-projectile-specific offset
    CLC : ADC $04 : STA !D8,x                       ;Y, low byte (offset + 0x80)
    TDC : ROL : STA !14D4,x                         ;Y, high byte
    LDA #$01 : BIT !AttackVarA : BEQ + : LDA #$FF   ;1 if attacking from the right, FF from the left
+   STA !14E0,x                                     ;X, high byte
    LDA $06,y : STA !E4,x                           ;X, low byte

    ;;Speeds
    LDA #$18 : STA !AA,x                            ;Y: +24 subpixels per frame
    LDA $05  : STA !B6,x                            ;X from variable            ;...in retrospect, I could've used varB again...

    ;;Expiration timer
    TXA : DEC : ASL : TAX                           ;Convert to word table index    ;NOTE: Destroys sprite index
    LDA ..expT,y : STA !ExpTT+1,x : STZ !ExpTT,x    ;About 8 seconds for main enemy, 4 for rest

    ;;Loop
    INY : CPY !AttackVarB : BCC ..next              ;Check if more projectiles should be spawned

    ..prepRet:
    ;Prepare for next iteration
    LDY !AttackPhase : INY                          ;Increment attack phase
    LDA #$70 : STA !AttackTimerA                    ;Set timer until next projectile (112 frames, about 2 seconds)
    LDA #$09 : STA $7DFC                            ;Sound: Cannon
    STY !AttackPhase                                ;Store attack phase
RTS

..next:
    ;Initialization
    JSR GetSpriteSlot                           ;o:c
    BCS ..prepRet                               ;i:c;Abort if there are no empty sprite slots
    LDA #$89 : STA !PSprNum,x                       ;Custom sprite number
    JSL $07F722                                     ;Clear sprite tables
    LDA #$08 : STA !SprFlags,x                      ;Custom sprite flag
    STA !14C8,x                                     ;Alive status (skips initialization routine)
    JSL $0187A7                                     ;Initialize tables

    ;Basic projectile variables
    STZ !SprB,x                                     ;Basic behavior
    LDA #$04 :  STA !SprV,x                         ;Contained sprite: Green shelless Goopa
BRA ..loop

;Tip sprites (0: Spiny, 2: Shelless Goopa (4: green, 8: yellow), 14: Yellow Goopa (E: winged), 10: Chuck)
..table:
;Basic
db $02
db $00
db $0E
db $02
db $00
db $02
db $02
db $14
;Advanced
db $00
db $10
db $02
db $08
db $00
db $02
db $0E
db $00
..yoff:
db $00, $11
db $00, $11
db $22
..expT
db $02, $01
db $01, $01
db $01

.wave:
    LDA !AttackTimerA : BNE ..decRet        ;Wait until it's time to execute the next part
    LDY !AttackPhase  : BNE ..main      ;o:Y;Load spawn index, checking for initialization
    ..init:
    INC                                     ;First half: Start at index 1 (A is zero)
    LDY !BossHP : CPY #$04 : BCS +          ;Check half
    LDA #19
+   STA !AttackPhase
RTS

..decRet:
    DEC !AttackTimerA
RTS

..stall:
    INY : STY !AttackPhase
    LDA #$23 : STA $7DFC                            ;Sound: step on tile
    LDA #$F0 : STA !AttackTimerA                    ;Set timer (240 frames, about 4 seconds)
RTS

..end:
    LDA #$02 : STA !BossState                       ;Go back to AI
RTS

..main:
    LDA ..tableTimer-1,y                            ;Check timer table for special routines
    BEQ ..end                                       ;0 for end
    BMI ..stall                                     ;Negative values for stall

    JSR GetSpriteSlot                           ;o:c
    BCS ..prepRet                               ;i:c;Abort if there are no empty sprite slots
    LDA #$89 : STA !PSprNum,x                       ;Custom sprite number
    JSL $07F722                                     ;Clear sprite tables
    LDA #$08 : STA !SprFlags,x                      ;Custom sprite flag
    STA !14C8,x                                     ;Alive status (skips initialization routine)
    JSL $0187A7                                     ;Initialize tables

    ;Position (all fixed)
    LDA #$D8 : STA !D8,x                            ;Y, low byte (ha)
    STZ !14D4,x                                     ;Y, high byte
    LDA #$78 : STA !E4,x                            ;X, low byte
    STZ !14E0,x                                     ;X, high byte

    ;Speeds
    LDA #$18 : STA !AA,x                            ;Y: 24 subpixels per frame
    LDA ..tableXSpeed-1,y : STA !B6,x               ;X from table

    ;Projectile variables
    LDA #$02 : STA !SprB,x                          ;Rotating behavior
    LDA ..tableMain-1,y :  STA !SprV,x              ;Contained sprite from phase table
    BNE + : LDA #$A0 : STA !1656,x                  ;If it contains a Spiny, don't set jumpable flag
+   TXA : DEC : ASL : TAX                           ;Convert to word table index
    LDA #$02 : STA !ExpTT+1,x : STZ !ExpTT,x        ;About 8 seconds

    ..prepRet:
    ;Prepare for next projectile
    INY                                             ;Increment attack phase
    LDA ..tableTimer-2,y : STA !AttackTimerA        ;Set timer until next projectile
    LDA #$32 : STA $7DF9                            ;SMAS climb sound
    STY !AttackPhase                                ;Store attack phase
RTS

..tableMain:    ;Contained sprite (0: Spiny, 2: Shelless Goopa (4: green, 8: yellow), 14: Yellow Goopa (E: winged), 10: Chuck)
db $02, $04, $0A, $04, $02
db $00
db $0E, $04, $04, $00
db $00
db $02, $08, $04, $14, $02
db $00
db $00
;Advanced:      ;Contained sprite (0: Spiny, 14: Yellow Goopa (E: winged), 10, 12: Chuck, 0A: Rainbow shell)
db $00, $04, $00, $04, $00
db $00
db $00, $00, $00, $00
db $00
db $00, $0E, $04, $0E, $00
db $00
db $00
;Desperation:
db $12, $10, $12
db $00
db $00, $00, $00, $00
db $00
db $0A, $0A, $0A, $0A, $0A, $0A, $0A

..tableTimer:
db $07, $07, $07, $07, $2F
db $FF  ;wave
db $07, $07, $07, $33
db $FF
db $07, $07, $07, $07, $2F
db $FF
db $00  ;end
db $07, $07, $07, $07, $2F
db $FF
db $07, $07, $07, $33
db $FF
db $07, $07, $07, $07, $2F
db $FF
db $00
db $0F, $0F, $2F
db $FF
db $07, $07, $07, $33
db $FF
db $0F, $0F, $0F, $0F, $0F, $0F, $0F
db $FF
db $00

..tableXSpeed:
db $EC, $F6, $00, $0A, $14
db $00
db $F1, $FB, $05, $0F
db $00
db $EC, $F6, $00, $0A, $14
db $00
db $00
db $EC, $F6, $00, $0A, $14
db $00
db $F1, $FB, $05, $0F
db $00
db $EC, $F6, $00, $0A, $14
db $00
db $00
db $EC, $00, $14
db $00
db $F1, $FB, $05, $0F
db $00
db $F7, $EE, $F7, $00, $09, $12, $09

.rain:
    LDA !AttackTimerA : BNE ..decRet        ;Wait until it's time to execute the next part
    LDY !AttackPhase  : BNE ..main          ;Load spawn index, checking for initialization
    ..init:
    INC                                     ;First half: Start at index 1 (A is zero)
    LDY !BossHP : CPY #$04 : BCS +          ;Check half
    LDA.b #..advanced-..tableTimer+1
+   STA !AttackPhase
    LDA $94 : CMP #$78                  ;o:c;Carry is set if Demo is on the right half of the screen
    TDC : ROL : STA !AttackVarA         ;i:c;Flag for attacking from the left (inverting X spawn positions).
RTS

..decRet:
    DEC !AttackTimerA
RTS

..end:
    LDA #$02 : STA !BossState                       ;Go back to AI
RTS

..main:
    LDA ..tableTimer-1,y                            ;Check timer table for special routines
    BEQ ..end                                       ;0 for end

    JSR GetSpriteSlot                           ;o:c
    BCS ..prepRet                               ;i:c;Abort if there are no empty sprite slots
    LDA #$89 : STA !PSprNum,x                       ;Custom sprite number
    JSL $07F722                                     ;Clear sprite tables
    LDA #$08 : STA !SprFlags,x                      ;Custom sprite flag
    STA !14C8,x                                     ;Alive status (skips initialization routine)
    JSL $0187A7                                     ;Initialize tables

    ;Position
    LDA #$B0 : STA !D8,x                            ;Y, low byte, just above screen
    STZ !14D4,x                                     ;Y, high byte
    INC : AND !AttackVarA : LSR                 ;o:c;Get inversion bit
    LDA ..tableXPos-1,y : BCC +                 ;i:c;Load X position
    EOR #$FF : SEC : SBC #$0F                       ;Invert
+   STA !E4,x                                       ;X, low byte, from table
    STZ !14E0,x                                     ;X, high byte

    ;Speeds
    LDA #$20 : STA !AA,x                            ;Y: +32 subpixels per frame
    STZ !B6,x                                       ;X: Stationary

    ;Projectile variables
    STZ !SprB,x                                     ;Basic behavior
    LDA ..tableMain-1,y : STA !SprV,x : PHA     ;o:A;Contained sprite from phase table
    BNE + : LDA #$A0 : STA !1656,x                  ;If it contains a Spiny, don't set jumpable flag
+   TXA : DEC : ASL : TAX                           ;Convert to word table index
    PLA : BEQ ++                                    ;Check if Spiny
    CMP #$02 : BEQ ++                               ;Check if red shelless Goopa
    CMP #$16 : BNE +                                ;Check if red Goopa
++  INC
+   AND #$01 : STA !ExpTT+1,x                       ;About 4 more seconds for red enemies
    LDA #$BE : STA !ExpTT,x                         ;About 3 seconds, with appropriate bounce

    ..prepRet:
    ;Prepare for next projectile
    INY                                             ;Increment attack phase
+   LDA ..tableTimer-2,y : STA !AttackTimerA        ;Set timer until next projectile
    LDA #$32 : STA $7DF9                            ;SMAS climb sound
+   STY !AttackPhase                                ;Store attack phase
RTS

..tableMain:    ;Contained sprite (0: Spiny, 4: Shelless Goopa (2 :red), 16: Red Goopa (1A: Blue), 0C: Winged Goopa)
db $04, $02, $04, $04, $04, $04, $04, $04, $02
db $0C
db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
db $04, $02, $04, $04, $04, $04, $04, $04, $02
db $0C
db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
db $0C, $0C, $16, $0C, $0C
db $00
db $04, $02, $04, $00, $04, $00, $04, $04, $04
db $0C
db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
db $04, $02, $04, $00, $04, $00, $04, $04, $04
db $0C
db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
db $02, $0C, $16, $0C, $00

..tableTimer:
db $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A
db $0A
db $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $38
db $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A
db $0A
db $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $38
db $0A, $0A, $0A, $0A, $BE
db $00
..advanced:
db $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A
db $0A
db $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $38
db $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A
db $0A
db $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $38
db $0A, $0A, $0A, $0A, $FF
db $00

..tableXPos:
db $04, $18, $2C, $40, $54, $68, $7C, $90, $A4
db $B8
db $A4, $90, $7C, $68, $54, $40, $2C, $18, $04
db $EC, $D8, $C4, $B0, $9C, $88, $74, $60, $4C
db $38
db $4C, $60, $74, $88, $9C, $B0, $C4, $D8, $EC
db $54, $40, $2C, $18, $04
db $00
db $04, $18, $2C, $40, $54, $68, $7C, $90, $A4
db $B8
db $A4, $90, $7C, $68, $54, $40, $2C, $18, $04
db $EC, $D8, $C4, $B0, $9C, $88, $74, $60, $4C
db $38
db $4C, $60, $74, $88, $9C, $B0, $C4, $D8, $EC
db $54, $40, $2C, $18, $04

.desperation:                               ;Wave variation
    LDA #37  : STA !AttackPhase             ;Start at index 37, the final table
    LDA #$10 : STA !BossState               ;Use wave code for rest
RTS

ExpT:
    DEY #2                      ;Decrement Y only if necessary.
    .start:
    ;;Timer
    LDA !ExpTT,y : BEQ .next    ;If timer is already zero, skip
    DEC : STA !ExpTT,y          ;Decrement timer
    BNE .next                   ;Only despawn if the timer is decreased to zero
    ;Give despawn timer to sprites without one? Nah, those red shelless Goopas can be special extra (non-)threats.

    SEP #$20 : PHY
    JSR DespawnGlitter
    BCC +                       ;Carry is clear if smoke can't be spawned
    LDA #$0C  : STA $77CC,y     ;12 frames, so I can despawn a sprite safely every 4 frames
+   PLY : REP #$20

    .next:
    DEX                         ;Decrement before looping
    BNE ExpT                    ;We're done as soon as we hit sprite 0 (the boss itself)
RTS

DespawnGlitter:                 ;X: Sprite to despawn. Y is modified. NOTE: Does not store to 77CC,y
    LDA !14C8,x : BEQ .return   ;If the slot's empty, the sprite has already despawned
    STZ !14C8,x                 ;Instantly despawns the sprite
    LDA !15A0,x : BNE .return   ;If the sprite is horizontally off-screen, skip glitter (probably won't need vertical check?)
    ;Glitter
    LDY #$03                    ;Four smoke slots
-   LDA $77C0,y : BEQ .glitter  ;Check slot
    DEY : BPL - : BRA .return   ;Loop, but stop if all slots are taken
    .glitter:
    LDA #$05  : STA $77C0,y     ;Glitter smoke
    LDA !D8,x : STA $77C4,y     ;Copy Y position of despawned sprite
    LDA !E4,x : STA $77C8,y     ;Copy X too
    SEC
RTS

.return:
    CLC
RTS

;HDMA tables
;;Functions for turning standard RGB codes into HDMA table entries
function redgreen(rgb) = ((rgb&$F80000)/$80000)|\   ;Red into low byte
                         ((rgb&$00F800)/8)|\        ;Green into high byte
                         $4020                      ;Color flags
function blue(rgb) = ((rgb&$0000F8)/8)|$80

rgtable:
db $0F : dw redgreen($68E080)
db $10 : dw redgreen($90E888)
db $10 : dw redgreen($B0F098)
db $10 : dw redgreen($D0F8A8)
db $10 : dw redgreen($F0F8B8)
db $10 : dw redgreen($F8F8E0)
db $10 : dw redgreen($F0F8F8)
db $10 : dw redgreen($E0F0F8)
db $10 : dw redgreen($E0E0F8)
db $10 : dw redgreen($F0D0F8)
db $10 : dw redgreen($F0B0E0)
db $10 : dw redgreen($F098C8)
db $10 : dw redgreen($E07090)
db $02 : dw redgreen($000000)
db $01 : dw redgreen($F8F0E0)
db $02 : dw redgreen($F8C850)
db $82 : dw redgreen($F8F0E0), redgreen($F8C850)
db $03 : dw redgreen($E0b800)
db $02 : dw redgreen($787018)
db $83 : dw redgreen($F8C850), redgreen($F8F0E0), redgreen($787018)
db $02 : dw redgreen($303008)
db $00

btable:
db $0F, blue($68E080)
db $10, blue($90E888)
db $10, blue($B0F098)
db $10, blue($D0F8A8)
db $10, blue($F0F8B8)
db $10, blue($F8F8E0)
db $10, blue($F0F8F8)
db $10, blue($E0F0F8)
db $10, blue($E0E0F8)
db $10, blue($F0D0F8)
db $10, blue($F0B0E0)
db $10, blue($F098C8)
db $10, blue($E07090)
db $02, blue($000000)
db $01, blue($F8F0E0)
db $02, blue($F8C850)
db $82, blue($F8F0E0), blue($F8C850)
db $03, blue($E0b800)
db $02, blue($787018)
db $83, blue($F8C850), blue($F8F0E0), blue($787018)
db $02, blue($303008)
db $00

MovY:       ;Note: These should iterate backwards.
db 1, 2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  1,  1,  1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1

MovXNear:
db 1, 2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2, 1, 2, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1

MovXfar:
db 1, 3,  5,  6,  6,  6,  6,  6,  6,  6,  6,  5,  5,  4, 4, 3, 3, 2, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1

MovRot:     ;Might need dw instead
db 2, 6, 13, 21, 21, 21, 21, 21, 21, 21, 21, 21, 16, 12, 8, 5, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

MovTRot:    ;Teleport on frame 27, with 41 total frames. Frame 27 should be 14 with decrementation?
db 2, 8, 15, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21                                                 ;Post-teleport
db       21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 16, 12, 8, 5, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ;Pre-teleport

XPattern:   ;Movement patterns: UDLfffRf
db $00, $02, $1F
XPos:       ;Mini table squeezed in here
db $30, $60, $90
;XPattern resumed:
db $3D, $20

%prot_file("level/WindroseMode7.bin", vrdata)
