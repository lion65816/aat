;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Flying Disco Shell
;
;This is a disco shell that follows player in air.
;
;By RussianMan. Requested by AbuseFreakHacker.
;Credit is optional.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!MaxRightSpeed = $20
!MaxLeftSpeed = $E0

WallBumpSpeed:
db !MaxLeftSpeed,!MaxRightSpeed

Tilemap:
db $8C,$8A,$8E,$8A

WingTiles:
db $5D,$C6,$5D,$C6

Print "INIT ",pc
INC !187B,x			;flag necessary for correct interactions (bouncing on it and yoshi eating)

LDA #$0A
STA !14C8,x			;spawn as kicked
RTL

Print "KICKED",pc
Print "MAIN ",pc		;when dead, runs this
PHB
PHK
PLB
JSR Code
PLB
RTL

Code:
LDA #$00			;
%SubOffScreen()			;no more dupe shenanigans I hope

JSR GFX				;show graphics

LDA !14C8,x			;if dead
;EOR #$08			;
CMP #$0A
BCC .Re

LDA $9D				;or frozen in time and space
BNE .Re				;return

%SubHorzPos()			;face player. always.
TYA				;
STA !157C,x			;

STZ !AA,x			;no Y-speed
JSL $01802A|!BankB		;

LDY !157C,x			;
;CPY #$00			;and y'see something nintendo did in their code. something useless!
BNE .NoRightSpeed		;
LDA !B6,x
BMI +
CMP #!MaxRightSpeed		;if hit maximum right speed
BCS .NoMoreSpeed		;don't increase speed.
+

INC !B6,x			;increase X-speed
INC !B6,x			;twice
BRA .NoMoreSpeed		;jump over some code

.NoRightSpeed
LDA !B6,x
BPL +
CMP #!MaxLeftSpeed		;if hit max left speed
BCC .NoMoreSpeed		;don't decrease
+
DEC !B6,x			;decrease X-speed
DEC !B6,x			;twice

.NoMoreSpeed
LDA !1588,x			;if hit wall bounce away and maybe trigger bounce sprite
AND #$03			;
BEQ .NoWall			;
PHA				;
JSR WallHit			;
PLA				;
AND #$03			;
DEC				;
TAY				;
LDA WallBumpSpeed,y		;set bumping speed
STA !B6,x			;

.NoWall
LDA $13				;change palette every other frame
LSR				;
BCS .NoPaletteChange		;slightly faster
;AND #$01			;
;BNE .NoPaletteChange		;

LDA !15F6,x			;makes CFG editor useless (for setting palettes i mean, you can set it to use second gfx page).
INC #2				;
AND #$CF			;
STA !15F6,x			;

.NoPaletteChange
;LDA #$0A			;weird workaround for sprites
;STA !14C8,x			;because they don't react to shell like they should unless it's in thrown state (not 100% accurate, yellow koopas won't jump over it)

JSL $01803A|!BankB		;interact with player and sprites

;LDA !14C8,x			;if it got killed in process
;CMP #$0A			;
;BNE .Re			;leave it be

;LDA #$08			;restore state to normal
;STA !14C8,x			;(sadly kills flying shell <-> flying shell death, both must be in kicked state) (not the case anymore, thanks KICKED state)

.Re
RTS

;not so interesting tables stored away

XDisp:
db $04,$00,$FC,$00

YDisp:
db $F1,$00,$F0,$00

WingSize:
db $00,$02,$00,$02

WingXDisp:
db $FB,$F3,$0D,$0D

WingYDisp:
db $FF,$F7,$FF,$F7

WingProps:
db $76,$76,$36,$36

XFlip:
db $00,$00,$00,$40		;only last byte is flip for one of shell's frames

GFX:
%GetDrawInfo()

STZ $03
LDA !14C8,x			;
;EOR #$08			;
CMP #$0A
BCS .OK
INC $03				;set scratch ram to contains information on wether sprite's in normal status.

.OK
LDA $00				;
STA $0300|!Base2,y		;shell tile X-pos

LDA $01				;
STA $0301|!Base2,y		;shell tile Y-pos

PHY				;
LDA $03				;if dead, don't animate shell
BNE .NoAnim			;

LDA $14				;animate with frame counter and all

.NoAnim
LSR #2				;
AND #$03			;fetch correct tile and flip info
TAY				;
LDA XFlip,y			;
STA $02				;
LDA Tilemap,y			;
PLY				;
STA $0302|!Base2,y		;

LDA $02				;flip info
ORA !15F6,x			;+cfg setting which is useless because we set it afterwards
ORA $64				;and priority
STA $0303|!Base2,y		;store as tile property

PHY				;
TYA				;
LSR #2				;
TAY				;
LDA #$02			;
STA $0460|!Base2,y      	;we set different sizes for wings, so we must set size for shell as well
PLY				;

LDA $03				;if dead don't animate wings
BNE .NoAnim2			;

LDA $14				;

.NoAnim2
LSR #3				;
AND #$01			;
STA $02				;

LDX #$01			;2 wings tiles

.Loop
INY #4				;next OAM slot

PHX				;load wing value
TXA				;
ASL				;so we have two wings attached from different sides
CLC				;
ADC $02				;
TAX				;
LDA $00				;
CLC				;wings x pos
ADC WingXDisp,x			;
STA $0300|!Base2,y		;

LDA $01				;
CLC				;wings y pos
ADC WingYDisp,x			;
STA $0301|!Base2,y		;

LDA WingTiles,x			;wings tiles
STA $0302|!Base2,y		;

LDA $64				;
ORA WingProps,x			;wings properties
STA $0303|!Base2,y		;

PHY
TYA				;can be 8x8 or 16x16 depending on frame
LSR #2				;
TAY				;
LDA WingSize,x			;
STA $0460|!Base2,y      	;
PLY
PLX

DEX				;next wing
BPL .Loop			;

LDX $15E9|!Base2		;restore sprite slot

LDA #$02			;3 tiles total
LDY #$FF			;custom sizes
JSL $01B7B3|!BankB		;
RTS				;

WallHit:
LDA #$01			;hit sound effect
STA $1DF9|!Base2		;

LDA !15A0,x			;if offscreen, don't trigger bounce sprite
BNE .NoBlockHit			;

LDA !E4,x			;
SEC : SBC $1A			;
CLC : ADC #$14			;
CMP #$1C			;
BCC .NoBlockHit			;

LDA !1588,x			;
AND #$40			;
ASL #2				;
ROL				;
AND #$01			;
STA $1933|!Base2		;

LDY #$00			;
LDA $18A7|!Base2		;
JSL $00F160|!BankB		;

LDA #$05			;
STA !1FE2,x			;

.NoBlockHit
RTS				;