!AshPage = 1            ; Which GFX page the graphics are on
!AshSize = 0            ; 0 = 8x8, 2 = 16x16, never use any other value
!AshPalette = $A        ; Palette as on the level editor, not the real value (that's handled internally here)
!AshPriority = 3        ; Whether the ash goes behind the foreground or background, doesn't affect sprites.
                        ; 3 = above everything (recommend)
                        ; 2 = behind layer 1 priority tiles but in front of unprioritised tiles
                        ; 1 = behind layer 1 but in front of layer 3
                        ; 0 = behind layer 3 priority tiles

; Note: No page information.
AshTiles:
db $D7,$C7,$D6,$C6

!Decay = 2              ; How fast the ash decays before disappearing

; Internal defines, do not change!

!AshPalette #= (!AshPalette&7)<<1
!AshPriority #= !AshPriority<<4
!YPos = $1E02|!addr
!XPos = $1E16|!addr
!YSpeed = $1E52|!addr
!XSpeed = $1E66|!addr
!YSubpix = $1E7A|!addr
!XSubpix = $1E8E|!addr
!XAccel = $0F4A|!addr
!AliveTimer = $1E2A|!addr
!FlipTimer = $0F72|!addr
!FlipTimerInit = $0F86|!addr

OAMIndices:
db $40,$44,$48,$4C,$50,$54,$58,$5C,$60,$64,$68,$6C,$80,$84,$88,$8C,$B0,$B4,$B8,$BC ; These are all in $02xx


print "MAIN ",pc
Main:                   ;The code always starts at this label in all sprites.
    LDA $9D             ; \ Don't move if sprites are supposed to be frozen.
    BNE .Graphics       ; /

    LDA !AliveTimer,x
    SEC : SBC.b #!Decay
    BCC .Despawn

.Alive:
    STA !AliveTimer,x

    LDA !FlipTimer,x
    DEC
    BNE .NoFlip
    LDA !XAccel,x
    EOR #$FF : INC
    STA !XAccel,x
    LDA !FlipTimerInit,x
.NoFlip:
    STA !FlipTimer,x

    LDA !XAccel,x
    CLC : ADC !XSpeed,x
    STA !XSpeed,x

    JSR ApplyYSpeed
    JSR ApplyXSpeed

; Taken straight from cluster sprite pack, don't credit me plz.
.Graphics:
    LDA !AliveTimer,x       ; Get timer to get frame
    LSR #6
    TAY
    LDA AshTiles,y
    STA $0F
    REP #$20                ;\ AAT edits:
    LDA $010B|!addr         ;| Remap the ash tiles specifically for
    CMP #$000A              ;| the No-Yoshi intro of SPECIAL.
    BNE +                   ;|
    SEP #$20                ;|
    LDA $0F                 ;|
    CLC                     ;|
    ADC #$20                ;|
    STA $0F                 ;|
+                           ;|
    SEP #$20                ;/
    LDY.w OAMIndices,x      ; Get OAM index.
    LDA !YPos,x             ; \ Copy Y position relative to screen Y to OAM Y.
    SEC                     ;  |
    SBC $1C                 ;  |
    STA $0201|!addr,y       ; /
    LDA !XPos,x             ; \ Copy X position relative to screen X to OAM X.
    SEC                     ;  |
    SBC $1A                 ;  |
    STA $0200|!addr,y       ; /
    LDA $0F                 ; \ Tile
    STA $0202|!addr,y       ; /
    LDA.b #!AshPalette|!AshPage|!AshPriority
    STA $0203|!addr,y
    PHX
    TYA
    LSR
    LSR
    TAX
    LDA #!AshSize
    STA $0420|!addr,x
    PLX
    LDA $0201|!addr,y
    CMP #$F0                ; As soon as the sprite is off-screen...
    BCC .Return
.Despawn:
    LDA #$00                ; Kill it.
    STA $1892|!addr,x       ;

.Return
RTL

ApplyYSpeed:
    LDA #$00
    XBA
    LDA !YSpeed,x
    BEQ .NoSubpix
    REP #$20
    BPL +
    ORA #$0F00
+   ASL #4
    SEP #$20
    ADC !YSubpix,x      ; Carry is never set here
    STA !YSubpix,x
    XBA
    ADC !YPos,x
    STA !YPos,x
RTS

.NoSubpix:
    STZ !YSubpix,x
RTS

ApplyXSpeed:
    TXA
    CLC : ADC #$14      ; Use next sprite table (which happens to have the X position stuff).
    TAX
    JSR ApplyYSpeed
    LDX $15E9|!addr
RTS

