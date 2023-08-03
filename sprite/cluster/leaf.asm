; Graphics
!DifferentTiles = 1     ; 0 = all leaves use the same tile, 1 = each leaf uses a different tile

!LeafTile = $D2         ; When the above define is 0
!LeafPage = 1           ;
!LeafSize = 0           ; 0 = 8x8, 2 = 16x16, never use any other value
!LeafMirror = 1         ; Whether the leaf is horizontally flipped or not.

!DifferentPalettes = 1  ; 0 = all leaves use the same colour (defined below), 1 = each leaf uses a different colour
!LeafPalette = $D       ; Palette as on the level editor, not the real value (that's handled internally here)

; Physics
!LeafInitXSpeed = $14   ; The initial swipe speed after a turn
!LeafDecel = $01        ;
!LeafDecelDelay = 1     ; How much the deceleration is slowed down. Exponential: $00 = 1x, $01 = 0.5x, $02 = 0.25x, etc.
!LeafInitYSpeed = $20   ; The initial fall speed after a turn
!LeafGravity = $0C      ; How fast the leaves will fall at most

; Separate data
if !DifferentTiles
; Note: No page information.
LeafTiles:
db $D2,$D2,$D2,$D3,$D2,$D3,$D3,$D2,$D2,$D3,$D3,$D3,$D2,$D3,$D2,$D3,$D2,$D2,$D3,$D2
endif

if !DifferentPalettes
; Note: Raw palette only.
; Format 0000ccc0 or in other words: (Palette - 8) * 2
LeafPalettes:
db $04,$06,$06,$04,$04,$0A,$08,$0A,$04,$04,$04,$04,$0A,$06,$06,$0A,$06,$04,$04,$06
endif

; Internal defines, do not change!

!LeafPalette #= (!LeafPalette&7)<<1
!YPos = $1E02|!addr
!XPos = $1E16|!addr
!YSpeed = $1E52|!addr
!XSpeed = $1E66|!addr
!YSubpix = $1E7A|!addr
!XSubpix = $1E8E|!addr
!Visible = $1E2A|!addr

OAMIndices:
db $40,$44,$48,$4C,$50,$54,$58,$5C,$60,$64,$68,$6C,$80,$84,$88,$8C,$B0,$B4,$B8,$BC ; These are all in $02xx


print "MAIN ",pc
Main:               ;The code always starts at this label in all sprites.
LDA !YPos,x         ; \
SEC                 ; | Check Y position relative to screen border Y position.
SBC $1C             ; | If equal to #$F0...
CMP #$F0            ; |
BCC +               ; |
INC !Visible,x      ; / Appear.

+
LDA $9D             ; \ Don't move if sprites are supposed to be frozen.
BNE Graphics        ; /

if !LeafDecelDelay
LDA $14
AND #(1<<!LeafDecelDelay)-1
BNE .NoXSpeed
endif


LDA !XSpeed,x
BMI .Negative
SEC : SBC #!LeafDecel
BPL .StoreSpeed
LDA.b #-!LeafInitXSpeed
BRA .StoreSpeed

.Negative
CLC : ADC #!LeafDecel
BMI .StoreSpeed
LDA.b #!LeafInitXSpeed
.StoreSpeed
STA !XSpeed,x

.NoXSpeed

LDA !XSpeed,x
BPL +
EOR #$FF : INC
+
SEC : SBC #$05
STA !YSpeed,x

JSR ApplyYSpeed
JSR ApplyXSpeed

; Taken straight from cluster sprite pack, don't credit me plz.
Graphics:
LDA !Visible,x
BEQ .Return

LDY.w OAMIndices,x      ; Get OAM index.
LDA !YPos,x             ; \ Copy Y position relative to screen Y to OAM Y.
SEC                     ;  |
SBC $1C                 ;  |
STA $0201|!addr,y       ; /
LDA !XPos,x             ; \ Copy X position relative to screen X to OAM X.
SEC                     ;  |
SBC $1A                 ;  |
STA $0200|!addr,y       ; /
if !DifferentPalettes
LDA LeafTiles,x         ; \ Tile
else
LDA #!LeafTile          ; \ Tile
endif
STA $0202|!addr,y       ; /
LDA !XSpeed,x
AND #$80
LSR
if !LeafMirror
EOR #$40
endif
if !DifferentPalettes
EOR LeafPalettes,x
EOR.b #!LeafPage
else
EOR.b #!LeafPalette|!LeafPage
endif
ORA $64
STA $0203|!addr,y
PHX
TYA
LSR
LSR
TAX
LDA #!LeafSize
STA $0420|!addr,x
PLX
LDA $18BF|!addr
ORA $1493|!addr
BEQ .Return             ; Change BEQ to BRA if you don't want it to disappear at generator 2, sprite D2.
LDA $0201|!addr,y
CMP #$F0                ; As soon as the sprite is off-screen...
BCC .Return
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

