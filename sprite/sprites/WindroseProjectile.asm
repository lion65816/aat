;The code for Windrose's rose projectile
;Lord Ruby

;SA-1

;json notes: Shelled Goopa does not die when jumped on, can be jumped on, and both it and unshelled ones use sprite clipping 00.
;Object clipping 00. Act like 04 (green Goopa with shell) might make sense?
;I'll try having it not die when jumped on and use the default Mario interaction? Might just turn it into shell state
;;If so, I guess I'll need a custom interaction.

math pri on
math round off

;;;Defines
;TODO? Or maybe I just need this.
;;RAM
;Sprite tables
!SprB = $354C       ;Projectile behavior table, 354C-3561
!SprV = $3562       ;Projectile variant (contained sprite) table, 3562-3577
;Boss
!AttackTimerA = $3505
;;ROM (do not touch)
;Sine table
!SineTable = $07F7DB

print "MAIN",pc
    PHB
    PHK : PLB
    JSR Main        ;Just a simple wrapper for now, might wrap multiple subroutines later?
    PLB
print "INIT",pc     ;Put here since init is skipped anyway
RTL

Main:
    ;FIXME: Should only draw if Demo is dying. $9D, should also use in level and sprite code.

    ;Simplified SubOffScreen
    LDA !15A0,x : BEQ .move         ;Only check for despawning if off-screen
    LDA !14E0,x : XBA : LDA !E4,x   ;Load 16-bit X position into C
    REP #$21                    ;o:c
    ADC #$0080 : CMP #$0230    ;io:c;Check range -128 to 432 (screen width of 256 + 176)  ;Should be wide enough now :3
    SEP #$20
    BCC .move : STZ !14C8,x     ;i:c;If outside range, despawn and return
RTS

.move:
    ;TODO: Everything
    ;Check if not alive? Might use that as a sneaky way of continuing after being hit.

    LDA $9D : BNE .gfx                  ;Check if game is frozen

    ;;Movement
    ;Movement speeds
    TXY : LDX !SprB,y                   ;Sprite index to Y, behavior jump index in X
    JSR (Behaviors,x)                   ;Execute behavior

    ;;Collision
    ;Demo
    JSL $01A7DC                         ;Interact with Demo
    LDA !14C8,x : CMP #$08 : BNE .spawn ;If sprite isn't in default status anymore, it has probably been attacked

    ;Ground
    LDA !AA,x : BEQ .gfx                ;Ignore blocks if Y speed is stationary
    JSL $019138                         ;Interact with blocks
    LDA !1588,x : AND #$04 : BEQ .gfx   ;If not touching ground, go straight to drawing

    ;;Sprite spawning
    .spawn:
    LDA !SprV,x                         ;Get sprite variant
    CMP #$0A : BEQ .rainbowSpawn        ;Check if rainbow shell
    LSR : TAY                           ;Sprite variant as index
    LDA CSprite,y                       ;Get contained sprite
    STA !9E,x : STA !7FAB9E,x           ;Overwrite self with new sprite
    JSL $07F7D2                         ;Initialize vanilla sprite (I believe this is safe and doesn't touch XY positions)
    LDA #$01 : STA !14C8,x              ;To-be-initialized sprite status
    STZ !7FAB10,x                       ;Mark as vanilla
    ;TODO: Might need to handle green bouncing Paragoopas if they don't default to high bounce

    ;;Draw setup
    .gfx:
    LDY.b #$01                          ;Request 1 slot
    REP #$30
    LDA.w #$0002                        ;Normal priority
    JSL $0084B0                     ;o:c;Request MaxTile slots
    BCS .draw                       ;i:c;Carry clear: Failed to get OAM slots, abort.
    SEP #$30
RTS

.rainbowSpawn:
    STA !14C8,x                             ;Kicked status
    LDA #$07 : STA !9E,x : STA !7FAB9E,x    ;Overwrite self with yellow Koopa
    JSL $07F7D2                             ;Initialize vanilla sprite (I believe this is safe)
    STZ !7FAB10,x                           ;Mark as vanilla
    INC !187B,x                             ;Rainbow flag
    %SubHorzPos() : TYA : STA !157C,x       ;Face Demo
BRA .gfx

.draw                               ;Draw, featuring an unholy custom version of GetDrawInfo
    SEP #$31                    ;o:c
    LDY $75E9                       ;Use Y - not X - as sprite index
    REP #$10
    LDX $3100                       ;Use X as MaxTile index

    ;X
    LDA !E4,y : STA $400000,x       ;Store X position into MaxTile (no scrolling, only needs low byte)
    LDA !14E0,y : BEQ + : LDA #$01  ;Check if on-screen (0: on-screen, return 0, otherwise, return 1)
+   STA !15A0,y                     ;Horizontal off-screen flag

    ;Y
    LDA !14D4,y : XBA : LDA !D8,y   ;Load 16-bit Y position into C
    REP #$20
    SBC #$00B0              ;o:B;i:c;Set offset to 16 pixels above screen
    SEP #$21                    ;o:c
    SBC #$10 : STA $400001,x    ;i:c;Get Y position on screen (set offset to 0), store to MaxTile
    XBA : BEQ + : LDA #$01      ;i:B;High byte with offset shows if the sprite is at most 16 pixels above or below the screen
+   STA !186C,y                     ;Vertical off-screen flag (NOTE: Despawn sparkles?)

    ;Properties, tiles
    LDA !SprV,y                     ;Load sprite variant (petal color and contained sprite)
    REP #$20
    AND #$00FF                      ;Clear high byte of A
    CMP #$000A : BNE ..default  ;o:c;Use special code if rainbow shell (note: if so, carry is also set)

    ;Rainbow shell
    LDA $13 : AND #$0600            ;Iterate value (based on $14) every two frames (0, 1, 2, 3 *200)
    ADC #$3000+2*$200+$18A-1    ;i:c;Tile and proberties. Sums base palette (2) with iterator above. (Compensates for carry.)
    BRA +

    ..default:
    TAY                             ;Use as index
    LDA TileProp,y                  ;Load tile and properties

+   STA $400002,x                   ;Transfer tile and properties to MaxTile
    SEP #$30

    ;Finish writing
    LDX $75E9                       ;Restore sprite index
    LDY #$02 : TDC                  ;1 16x16 tile
    JSL $0084B4                     ;maxtile_finish_oam (FinishOAMWrite)    ;This time, I'm in a sprite, haha...
RTS

TileProp:               ;Tile + palette x 0x200 + 0x3000 (highest priority)
;Common:
;;2-bit (00000xx0) access:
dw $3000+4*$200+$1A8    ;00: Spiny, black petal                 ;NOTE: Shoot with spiny flag
dw $3000+4*$200+$1AC    ;02: Red Shelless Goopa, black petal
dw $3000+5*$200+$18C    ;04: Green Shelless Goopa, red petal
dw $3000+5*$200+$18A    ;06: Green Goopa, red petal
;;3-bit (0000xxx0) access:
dw $3000+6*$200+$18C    ;08: Yellow Shelless Goopa, black petal
dw $3000+0*$200+$18A    ;0A: Rainbow Shell, red petal           ;Special spawn
dw $3000+5*$200+$188    ;0C: Green Winged Goopa, red petal      ;TODO: Special spawn?
dw $3000+6*$200+$188    ;0E: Yellow Winged Goopa, black petal
;;4-bit (000xxxx0, might want ASL with low half-byte) access:
dw $3000+6*$200+$18E    ;10: Chargin' Chuck, black petal
dw $3000+5*$200+$18E    ;12: Chargin' Chuck, red petal
dw $3000+6*$200+$18A    ;14: Yellow Goopa, black petal
dw $3000+4*$200+$1AA    ;16: Red Goopa, black petal
dw $3000+3*$200+$18C    ;18: Blue Shelless Goopa, red petal
dw $3000+3*$200+$18A    ;1A: Blue Goopa, red petal
;1C
;1E
;Don't think I'll need more, but 20 and above would need more than half a byte in the tables

CSprite:                ;Contained sprite
db $13                  ;Spiny
db $01                  ;Red Shelless Goopa
db $00                  ;Green Shelless Goopa
db $04                  ;Green Goopa
db $03                  ;Yellow Shelless Goopa
db $FF                  ;Rainbow Shell                  ;Special spawn
db $09                  ;Green Winged (Bouncing) Goopa  ;TODO?
db $0C                  ;Yellow Winged Goopa
db $91, $91             ;Chargin' Chuck
db $07                  ;Yellow Goopa
db $05                  ;Red Goopa
db $02                  ;Blue Shelless Goopa
db $06                  ;Blue Goopa
;Others:
;DA-DD, Green/Red/Blue/Yellow Shell

Behaviors:
dw .shoot               ;00: Null behavior, keep speed set when spawned
dw .rotate              ;02: Rotate around boss before being launched

.shoot:
    ;Move
    LDX $75E9                           ;Restore sprite index
    JSL $01801A                         ;Update Y position
    JSL $018022                         ;Update X position
RTS

.rotate:
    ;Note: Sprite index in Y
    LDA !C2,y : INC : STA !C2,y         ;Load and update angle table    ;asar gets angry but makes the correct adjustment

    ;;Offsets
    REP #$30
    ;X
    PHA
    BIT #$0040 : PHP               ;op:z;Check (effective) negative bit
    AND #$003F : ASL #3 : TAX           ;Use as word index (four SMW degrees per unit)
    LDA.l !SineTable,x                  ;Load sine (yes, sine) value
    PLP : BEQ + : EOR #$FFFF : INC ;ri:z;Correct for negative range
+   LSR #3                              ;Reduce radius to 32
    STA $00                             ;Store X offset
    ;Y
    PLA                                 ;Restore angle
    CLC : ADC #$0020                    ;Add for cosine
    BIT #$0040 : PHP               ;op:z;Check (effective) negative bit
    AND #$003F : ASL #3 : TAX           ;Use as word index (four SMW degrees per unit)
    LDA.l !SineTable,x                  ;Load cosine value
    PLP : BNE + : EOR #$FFFF : INC ;ri:z;Correct for negative range
+   LSR #3                              ;Reduce radius to 32
    SEP #$30

    LDX $75E9                           ;Restore sprite index

    ;;Set coordinates
    ;Y
    STZ !14D4,x                         ;Top of screen
    SEC : SBC #$08                  ;o:n;Sprite position (top left instead of center)
    STA !D8,x                           ;Store low Y position
    BMI + : INC !14D4,x             ;i:n;Adjust high Y position
    ;X
+   LDA $00                             ;X offset
    CLC : ADC #$78                      ;Adjust for boss position and top left
    STA !E4,x                           ;Store low X position
    ;Might need to stz to high position, but should be safe

    ;Check for behavior update
    LDA !AttackTimerA : BPL ..return    ;If attack timer is positive, keep rotating
    STZ !SprB,x                         ;If negative (stalling), launch
..return:
RTS


