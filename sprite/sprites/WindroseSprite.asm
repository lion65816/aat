;Windrose's sprite code
;Lord Ruby

;SA-1 only

;json notes: Big Boo uses sprite clipping 07. Object clipping 00. Doesn't use default interaction with Mario.
;Doesn't interact with objects or sprites. Passable from below (??).

math pri on
math round off

;;;Defines
;;Values
;Boss max HP
!BossMHP = $08
;HP sprite tiles
!BossHPUpperLeftTile = $1CE
!BossHPPal = 1
!BossNoHPTile = $1EE
!BossNoHPPal = 7
;Small projectile tile
!ProjectileTile = $1C8      ;$1C8-$1CB
;Origin for the HP sprites, YYXX.
!HPOrigin = $07E8
;;RAM
;Boss coordinates (note: might be able to get away with only one byte each, since it never goes off-screen)
!BossX = $3500
!BossY = $3502
!RotFlag = $350E
!EyeState = $350F
;Behavior
!BossState = $3504
;Boss HP
!BossHP = $3509
!BossHPTimer = $350A
;Expiration timer table
!ExpTT = $3520      ;3520-354B, word table
;[Include others as necessary]
;;HP
;Sprite tiles, 000-1FF.
!EyeOpenUpperLeftTile = $1DA
!EyeClosedLeftTile = $1FA
;Origin for the HP eyes, YYXX. Note that the top left corner of the screen is 0000.
!EyeOrigin = $0708
;Level-specific HP settings
!MaxHP = $03
;Copy from simpleHP.asm:
!HPSettings = $788A
!HPByte = $58
!PowerupResult = $7C

print "MAIN",pc
    PHB
    PHK : PLB
    LDA $9D : BNE +     ;Check if game is frozen
    JSR Main            ;Just a simple wrapper for now, might wrap multiple subroutines later?
    BRA ++
+   JSR Main_playerHP   ;Only draw              ;spaghetti but whatever
++  LDX $75E9           ;Restore sprite index (note: might not be necessary in the end)
    PLB
print "INIT",pc         ;Put here since init is skipped anyway
RTL

Main:
    ;I think movement and attacks can be in level code though, at least.

    ;;Collision
    ;Boss clipping (replicates GetSpriteClippingA) and boss sprite position update
    ;Replicate GetSpriteClippingA, or call?
    ;X
    LDA !BossX : STA !E4                    ;X position (note that we're in 8-bit mode)
    CLC : ADC #$08 : STA $04                ;Clipping displacement: 8
    STZ $0A                                 ;High X clipping byte, but boss never goes off-screen
    LDA #$28 : STA $06                      ;Clipping width
    ;Y
    REP #$20
    LDA !BossY                              ;Load full Y position
    CLC : ADC #$00C0                    ;o:B;Account for discrepancy between mode 7 and interaction coordinates
    SEP #$20
    STA !D8                                 ;Store Y position
    CLC : ADC #$08 : STA $05            ;o:c;Clipping displacement: 8 again
    XBA : STA !14D4                     ;i:B;High byte, sprite tables
    ADC #$00 : STA $0B                  ;i:c;High byte, clipping
    LDA #$30 : STA $07                      ;Clipping height
    LDA !BossState : BEQ .playerHP          ;Only check collision if boss isn't in hurt state (far branch, but should be OK)
    LDX #$15                                ;Loop index
--  LDA !14C8,x                             ;Sprite's status
    CMP #$09 : BEQ .collide                 ;Eligible statuses: Carryable
    CMP #$0A : BNE .next                    ;                   Kicked
    .collide:                               ;Check for collision
    JSL $03B6E5                             ;GetSpriteClippingB
    JSL $03B72B                         ;o:c;CheckForContact
    BCC .next                           ;i:c;If carry is clear, there was no collision
    ;Hurt
    ;;XTODOX: Immediately set music, since it has a long intro...
    ;;;Actually, let's let that be a stretch goal, would need an upcoming addmusic feature.
    LDA #$04 : STA !EyeState                ;Close eyes on hurt
    TDC                                     ;Loads 0, hurt state
    DEC !BossHP                             ;Decrement HP
    BNE +                                   ;If HP was reduced to zero...
    LDA #$16 : STA $7DFC                    ;...collapsing sound effect and...
    LDA #$04                                ;...death state
+   STA !BossState
    LDA #43 : STA !BossHPTimer              ;Hurt for two frames per sprite slot to clear (+1, decremented below)
    STZ !14C8,x                             ;Remove hurting sprite
    LDA #$13 : STA $7DF9                    ;Hurt sound effect
    ;7DF9: 03 (kick shell) is OK? 08 (spin kill)? Enemy stomps (13-19)?
    ;7DFC: 07 (block break)? 16 (collapsing castle)? 19 (pop)? 1A (castle bomb)? 25 (yoshi stomp)?
    ;Let's go with 7DF9 13 for hit, while adding in 7DFC 16 on kill.
    ;Hit Smoke
    LDY #$03                                ;Four smoke slots
-   LDA $77C0,y : BEQ .smoke                ;Check slot
    DEY : BPL - : BRA .playerHP             ;Loop, but stop if all slots are taken
    .smoke:
    LDA #$02  : STA $77C0,y                 ;Hit smoke
    LDA #$06  : STA $77CC,y                 ;6 frames, since sprites are despawned rapidly after hit
    LDA !D8,x : STA $77C4,y                 ;Copy Y position of despawned sprite
    LDA !E4,x : STA $77C8,y                 ;Copy X too
    BRA .playerHP
    .next:
    DEX : BNE --                            ;Loop

    ;;HP
    .playerHP:
    ;Player HP
    LDA !HPByte : CMP #!MaxHP+1 : BCC +     ;Check if HP is above the maximum
    LDA #!MaxHP : STA !HPByte               ;Set to maximum

    ;Player HP blinking
+   LDA $71 : CMP #$03 : CLC : BNE ++   ;o:c;Check for get cape animation, which is repurposed as a hurt animation
    LDA $7496 : LSR #2                  ;o:c;Use animation timer to time blinks
++  LDA !HPByte                             ;HP
    ADC #$00                            ;i:c;If the last hit point was just lost, make it blink a little
    STA $00 : STZ $01                       ;Store HP to scratch ram $00, 8 to 16 bit

    ;Boss HP blinking
    LDA !BossHPTimer : CLC : BEQ +      ;o:c;Check if timer is non-zero, if so, blink
    DEC : STA !BossHPTimer                  ;Decrement timer
    LSR #3                              ;o:c;Now check second bit and use it to time blinks
+   LDA !BossHP                             ;HP
    ADC #$00                            ;i:c;If the last HP was just lost, blink
    STA $02 : STZ $03                       ;Scratch RAM $02, 8 to 16 bit

    Draw:
    LDY.b #$00+(!BossMHP)+(!MaxHP*3)        ;One tile per boss HP, three tiles per eye HP
    REP #$30                                ;(As the index registers were 8-bit, this fills their high bytes with zeroes)
    LDA.w #$0000                            ;Maximum priority
    JSL $0084B0                             ;Request MaxTile slots (does not modify scratch ram at the time of writing)
    BCS .drawBossHP                         ;Carry clear: Failed to get OAM slots, abort.
    SEP #$30                                ;...should never happen, since this will be executed before sprites, but...
RTS

.drawBossHP
    ;;;Main table
    LDX $3100                           ;Main index
    LDY.w #$0000+((!BossMHP-1)*2)       ;Loop index

-   TYA : LSR                           ;Half index to A
    CMP $02                         ;o:c;Compare with current HP

    LDA BossHPCoord,y : STA $400000,x   ;X and Y coordinates

    ;Tiles, properties                  ;Highest priority, no flip; palette and tile below
    LDA.w #$3000+!BossHPPal*$200+!BossHPUpperLeftTile
    BCC +                           ;i:c;If carry is clear, this HP is left
    LDA.w #$3000+!BossNoHPPal*$200+!BossNoHPTile
+   STA $400002,x                       ;Store to MaxTile

    INX #4 : DEY #2 : BPL -             ;Move to next slot and loop

    ;;;Additional bits
    LDX $3102                           ;Bit table index
    LDY.w #$0000+(!BossMHP)/2-1         ;Loop index (assumes even max HP)
    LDA.w #$0202                        ;Big for both tiles
-   STA $400000,x                       ;Store to both
    INX #2 : DEY : BPL -                ;Loop

    ;;;;Player HP
    ;;;Main table
    LDA $3100 : CLC : ADC.w #!BossMHP*4 ;Calculate first index after boss HP tiles
    TAX                                 ;Main index
    LDY.w #$0000+((!MaxHP-1)*2)         ;Loop index

-   TYA : LSR                           ;Half index to A
    CMP $00                         ;o:c;Compare with current HP. This keeps as many eyes open as Demo has HP.
    LDA BaseCoord,y                     ;Load base X and Y coordinates
    BCC .open                       ;i:c
    ;;Closed
    ;Coordinates
    ADC.w #$07FF : STA $400000,x        ;Left           ;Offsets:   Y: 8 (note that carry is set)
    ADC.w #$0008 : STA $400004,x        ;Middle         ;           Y: 8, X:  8
    ADC.w #$0008 : STA $400008,x        ;Right          ;           Y: 8, X: 16

    ;Tiles, properties
    LDA.w #$3000+!EyeClosedLeftTile     ;Highest priority, palette 0, no flip
    STA $400002,x                       ;Left
    LDA.w #$3001+!EyeClosedLeftTile     ;Highest priority, palette 0, no flip, one tile to the right
    STA $400006,x                       ;Middle
    LDA.w #$7000+!EyeClosedLeftTile     ;Highest priority, palette 0, X flip

    BRA +

    ;;Open
    .open:
    ;Coordinates
    STA $400000,x                       ;Left           ;Offsets:
    ADC.w #$0010 : STA $400004,x        ;Top right      ;                 X: 16
    ADC.w #$0800 : STA $400008,x        ;Bottom right   ;           Y: 8, X: 16

    ;Tiles, properties
    LDA.w #$3000+!EyeOpenUpperLeftTile  ;Highest priority, palette 0, no flip
    STA $400002,x                       ;Left
    LDA.w #$7000+!EyeOpenUpperLeftTile  ;Highest priority, palette 0, X flip
    STA $400006,x                       ;Top right
    LDA.w #$7010+!EyeOpenUpperLeftTile  ;Highest priority, palette 0, X flip, one tile below

+   STA $40000A,x                       ;Right/Bottom right
    ;Loop
    TXA : ADC.w #$000C : TAX            ;Increase slot by 3 (4 bytes per slot, so 12).
    DEY #2 : BPL -                      ;Loop

    ;;;Additional bits
    LDA $3102 : CLC : ADC.w #!BossMHP   ;Calculate first index after boss HP tiles
    TAX                                 ;Bit table index
    LDY.w #$0000+!MaxHP-1               ;Loop index

-   LDA.w #$0000 : STA $400001,x        ;Store zero to the second and third tiles
    CPY $00 : BCS + : LDA.w #$0002      ;Big for open eyes, small for closed eyes
+   STA $400000,x                       ;Store zero to second tile, relevant value to first tile

    INX #3 : DEY : BPL -                ;Loop

    ;Draw boss
    ;Note: Use buffer 3 for the boss (behind everything, like the mode 7 layer. Projectiles should use 1. HPUI: 0.)
    LDY.w #$0004                        ;Request 4 slots
    LDA.w #$0003                        ;Low priority (behind everything, like the mode 7 layer)
    JSL $0084B0                     ;o:c;Request MaxTile slots (does not modify scratch ram at the time of writing)
    ;NOTE: XX_finish_oam writes to bit properties (tile size, checks if partially off-screen).
    ;Also clears slots for sprites that are completely off-screen. Should therefore be optional for my purposes.
    BCS .bossDraw                   ;i:c;Carry clear: Failed to get OAM slots, abort.
    SEP #$30
RTS

.bossDraw:
    ;;Main table
    LDX $3100                           ;Main index

    ;Coordinates (note: This code relies on the assumption that the boss never even goes partially off-screen)
    LDA !BossY : XBA : ORA !BossX       ;Y into high byte, X into low byte
    ADC.w #$0F0E : STA $400000,x    ;i:c;Left eye       ;Offsets:   Y: 15, X: 15 (note that carry is set)
    ADC.w #$0013 : STA $400004,x        ;Right eye      ;           Y: 15, X: 34
    ADC.w #$10EE : STA $400008,x        ;Mouth (L)      ;           Y: 32, X: 16
    ADC.w #$0010 : STA $40000C,x        ;Mouth (R)      ;           Y: 32, X: 32 (will never set carry)

    ;Properties, tiles
; Old eyes draw
;     LDA.w #$3FA0 : STA $400002,x        ;Left eye       ;Highest priority, palette 7, no flip, tile 1A0
;     STA $400006,x                       ;Right eye      ;Highest priority, palette 7, no flip, tile 1A0
    ;;New eyes draw (also assumes carry isn't set)
    LDA !EyeState : AND #$00FF          ;Load eye state, use directly
    ADC.w #$3FA0 : STA $400002,x        ;Left eye       ;Highest priority, palette 7, no flip, tile 1A0/1A2/1A4
    STA $400006,x                       ;Right eye      ;Highest priority, palette 7, no flip, tile 1A0/1A2/1A4
; Old mouth draw
;     LDA.w #$3FC0 : STA $40000A,x        ;Mouth (L)      ;Highest priority, palette 7, no flip, tile 1C0
;     LDA.w #$3FC2 : STA $40000E,x        ;Mouth (R)      ;Highest priority, palette 7, no flip, tile 1C2
    ;;New mouth draw (assumes carry is not set, which should be safe)
    LDA !RotFlag : AND #$00FF : ASL #2  ;Load rotation flag, quadruple for tile offset
    ADC.w #$3FC0 : STA $40000A,x        ;Mouth (L)      ;Highest priority, palette 7, no flip, tile 1C0/1C4
    INC #2       : STA $40000E,x        ;Mouth (R)      ;Highest priority, palette 7, no flip, tile 1C2/1C6
    ;TODO: Animate tile choice. Eyes for opening animation (1A4, 1A2, 1A0). Mouth depending on mode 7 rotation (1C0, 1C4).
    ;LDY for each animation, and a small table for LDA with ,y? Actually, just double and add instead of loading.
    ;For simplicity, I think I'll just create some variables that are set as part of the state code.

    ;;Bit table
    LDX $3102                           ;Bit table index
    LDA #$0202                          ;Load big and on-screen for two entries
    STA $400000,x : STA $400002,x       ;Store to two entries at a time

    SEP #$30
RTS

;These loops set up data tables for UI coordinates
BaseCoord:      ;Player HP coordinates
!counter #= !MaxHP
!tempcoordinate #= !EyeOrigin ;+((!MaxHP-1)*$1000)
while !counter > 0
    dw !tempcoordinate
    !tempcoordinate #= !tempcoordinate+$1000
    !counter #= !counter-1
endif

BossHPCoord:    ;Trying a horizontal UI for now, there likely won't be many sprites that far up
!counter #= !BossMHP
!tempcoordinate #= !HPOrigin ;-((!BossMHP-1)*$0012)
while !counter > 0
    dw !tempcoordinate
    !tempcoordinate #= !tempcoordinate-$0012
    !counter #= !counter-1
endif
;Note: Commented out math reverses HP UI directions
