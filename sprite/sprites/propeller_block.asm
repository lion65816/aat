;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  
;;  The Propeller Blocks from the NSMB series, simplified for SMW
;;  While holding it, Mario jumps higher and falls slower
;;     by leod
;;
;;  Included ExGFX are for SP2, overwrite the smiley coin's top half.
;;
;;  Extra Bit ON will make the sprite boost Mario's jump a lot more,
;;               which is only really usable in vertical levels.
;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;Block properties
!BlockPalette = $0C
;sprite palette to use for the block portion, from 08-0F (0C = red, 0D = green, 0B = blue, 0A = yellow)

!BlockPalette2 = $0B
;sprite palette to use for the block portion, from 08-0F (0C = red, 0D = green, 0B = blue, 0A = yellow)
;this one is used when the extra bit is set, so the player knows it acts differently

!BlockSP = $00
;which sprite page the block graphics use (uses vanilla turn block graphics by default)
;SP1/2 = $00,  SP3/4 = $01

;;;;Propeller properties
!PropellerPalette = $0A
;sprite palette to use for the propeller, from 08-0F (0A = yellow, 09 = grey)

!PropellerSP = $00
;which sprite page the propeller graphics use (included ExGFX overwrite smiley coin)
;SP1/2 = $00,  SP3/4 = $01



;;;;;;;;;;;;;
;don't change these defines. or do, but it won't help much, they're just random sprite tables
;;;;;;;;;;;;;

!Extra = $160E        ;extra bit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
STZ !Extra,x
LDA $7FAB10,x        ; check for extra bit
AND #$04             ; (bit 2 -> %100 -> $4)
BEQ NoExtraIsSet     ; if not set, skip the following
LDA #$01
STA !Extra,x
NoExtraIsSet:
RTL
                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB                     ; \
PHK                     ;  | The same old
PLB                     ; /
JSR MainCode            ;  Jump to sprite code
PLB                     ; Yep
RTL                     ; Return1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  Return11:
RTS

  MainCode:
JSR SubGFX

LDA $9D             ;if sprites are locked, Return1
BNE Return11

LDA #$03
%SubOffScreen()

LDA $14C8,x
CMP #$0B            ;if the sprite isn't in Mario's hands,
BNE .NotGrabbed     ;check if it should be and act solid

LDA $77
AND #$04            ;if not on ground
BNE .NoLow

;low g
LDA $7D
BMI .Rise           ;if rising, just jump higher

LDA $15
AND #$80            ;check if B is pressed
BEQ .HardDesc       ;if yes, dont go there

LDA $7D
CMP #$0A            ;if not reached slow descent speed yet, do the hard desc
BCC .Rise

LDA #$0A
STA $7D             ;if holding B, soft descent
BRA .NoLow

  .HardDesc
LDA $7D
DEC
DEC
STA $7D

LDA !Extra,x
BNE .Rise           ;if extra bit isn't set, handle falling softly more here
DEC $7D

  .Rise
DEC $7D

LDA !Extra,x
BEQ .NoLow          ;if extra bit is set, handle falling and rising softly more here
DEC $7D
BRA .NoLow2

  .NoLow
LDA $14
AND #$01
BNE .NoLow2
DEC $7D
  .NoLow2
RTS


  .NotGrabbed
LDA $AA,x
BMI .NotStill

LDA #$08            ;normal state
STA $14C8,x

  .NotStill
LDA $14C8,x
CMP #$08            ;only do this in standard state
BEQ .NoSuchContact
JMP Contact
.NoSuchContact

JSL $019138         ;interact with objects
LDA $B6,x
BEQ .DoneX
BMI .GoingLeft

DEC $B6,x

BRA .DoneX

  .GoingLeft

INC $B6,x

  .DoneX
LDA $1588,x
AND #$08            ;check for collision with the ceiling
BEQ .NoCeiling

LDA #$0A
STA $AA,x
BRA .NoFallThisFrame

  .NoCeiling
LDA $1588,x
AND #$04            ;check for collision with the floor
BEQ .NoYRebound     ;if sprite is on the floor..

LDA $AA,x
CMP #$05
BCS .invert
STZ $AA,x
STZ $B6,x
BRA .NoFallThisFrame
BRA .NoYRebound
.invert
LSR
EOR #$FF
STA $AA,x

  .NoYRebound
LDA $14
AND #$03
BNE .NoFallThisFrame

LDA $AA,x
INC
CMP #$1A
BMI .StoreY
BCS .NoFallThisFrame

  .StoreY
STA $AA,x

  .NoFallThisFrame


JSL $018022         ;update x
JSL $01801A         ;update y
STZ $1491
;mario<->sprite
  Contact:
LDA #$00
CLC
%SolidSprite()


LDA $8A			;if mario isn't touching the sprite, don't check for carrying
BEQ .NoContact

LDA $148F
ORA $1470           ;if mario is already carrying a sprite
ORA $187A           ;or riding yoshi, do nothing further
ORA $140D           ;or spinjumping
BNE .NoContact

LDA $15
AND #$40            ;check for X and Y being pressed
BEQ .NoContact      ;if not, return

LDA #$01
STA $148F
STA $1470

LDA #$0B
STA $14C8,x


  .NoContact
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  TileSize:
db $00,$00  ;propeller
db $02      ;body

  TileXOff:
db $00,$08  ;propeller
db $00      ;body

  TileYOff:
db $F8,$F8  ;propeller
db $00      ;body

  TileGFX:
db $C2,$C3  ;propeller
db $40      ;body

  TileProps:
db !PropellerPalette-$08<<1|$20|!PropellerSP,!PropellerPalette-$08<<1|$60|!PropellerSP  ;propeller (contains palette, flip and priority)
db $20|!BlockSP  ;body (contains priority)

  BlockProps:
db !BlockPalette-$08<<1,!BlockPalette2-$08<<1   ;(contains block palette)

  SubGFX:
%GetDrawInfo()
  PHX


LDX #$02
  .PropellerLoop
PHX

CPX #$02        ;if X is 2 aka the body, just keep X, otherwise do this special shit
BEQ .SkipPropelTile

LDA $14
LSR             ;more LSR = slower animation
LSR
AND #$01        ;to get the propeller animation
TAX
  .SkipPropelTile

LDA TileGFX,x   ;load tile
STA $0302,y     ;store it as normal

PLX             ;restore x if we messed with it
PHX

CPX #$02        ;again check if it's the body, but this time skip if it is not
BNE .SkipBlockPal

LDX $15E9
LDA !Extra,x    ;get extra bit in x
TAX
LDA BlockProps,x;and load appropriate palette
PLX             ;get back loop x
PHX
ORA TileProps,x ;and add the Priority
STA $0303,y
BRA .PropsDone

  .SkipBlockPal
LDA TileProps,x ;load props
STA $0303,y

  .PropsDone
LDA $00         ;load sprite x pos
CLC
ADC TileXOff,x
STA $0300,y     ;store to oam x pos

LDA $01         ;load sprite y pos
CLC
ADC TileYOff,x
STA $0301,y     ;store to oam y pos


TYA
LSR A
LSR A
PHY
TAY
LDA TileSize,x ;load size
STA $0460,y    ;store to size table
PLY

INY : INY : INY : INY

PLX
DEX
BPL .PropellerLoop

  PLX

LDY #$FF        ; #$00 = 8x8, #$02 = 16x16, #$FF = variable
LDA #$02        ; tiles drawn; #$00 = 1, #$01 = 2, etc.
JSL $01B7B3     ; handle oam
RTS
