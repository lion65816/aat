;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Dry Bones (sprites 30 & 32), by imamelia
;;
;; This is a disassembly of sprites 30 and 32 in SMW, the Dry Bones.
;;
;; Uses first extra bit: YES
;;
;; If the extra bit is clear, this will act like the Dry Bones that doesn't stay on ledges,
;; but throws bones (sprite 30).  If the extra bit is set, this sprite will act like the Dry
;; Bones that stays on ledges but doesn't throw bones (sprite 32).  
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XDisp:
db $00,$00,$00,$F0,$F0
db $00,$00,$00,$10,$10
db $00,$00,$00,$F0,$F0
db $00,$00,$00,$10,$10
;db $00,$08,$00,$00,$F8,$00,$00,$04,$00,$00,$FC,$00

YDisp:
db $F4,$F0,$00,$F0,$00
db $F4,$F0,$00,$F0,$00
db $F4,$F0,$00,$F0,$00
;db $F4,$F0,$00,$F4,$F1,$00,$F4,$F0,$00

Tilemap:
db $00,$64,$66,$4A,$6A
db $00,$43,$68,$6C,$6E
db $82,$64,$66,$4A,$6A
;db $00,$64,$66,$00,$64,$68,$82,$64,$E6

TileProp:
db $43,$43,$43,$43,$43
db $03,$03,$03,$03,$03
;db $43,$43,$43,$03,$03,$03

EndLoopCount:
db $00,$00,$FF

SlopeEor:
db $08,$F8,$02,$03,$04,$04,$04,$04,$04,$04,$04,$04

XDisp2:					; displacement of the second crumbled tile depending on sprite direction
db $08,$F8				;

!CrumbledTile1 = $2E	; the fully-crumbled tile (the 16x16 tile 8 pixels to the left is also used)
!CrumbledTile2 = $48	; the half-crumbled tile (the 16x16 tile 8 pixels to the left is also used)

!SND_crumble = $07		; Sound when crumbling
!BNK_crumble = $1DF9	; See http://www.smwcentral.net/?p=viewthread&t=6665 for values

macro jslrts(target,rtl)
	PHB
	PEA.w ((<target>>>16)&$FF)|((?jslrtsreturn>>8)&$FF00)
	PLB
	PEA.w ?jslrtsreturn-1
	PEA.w <rtl>-1
	JML.l <target>
	?jslrtsreturn
	PLB
endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

JSR FacePlayer	; face the player initially

LDA !7FAB10,x	;
AND #$04		; store the extra bit to a misc. sprite table
STA !1510,x		;

RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR DryBonesMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NotCrumbled1:
JMP NotCrumbled

DryBonesMain:

LDA !14C8,x			;
CMP #$08			; if the sprite is in normal status...
BEQ NormalRt		; run the standard code
ASL !15F6,x			; if not...
SEC					; set bit 7 of $15F6,x (sprite palette and GFX page) so that the sprite graphics will be Y-flipped
ROR !15F6,x			; (actually, it doesn't matter, since $15F6,x is never referenced anyway)
JMP SkipToGFX		; and go directly to the GFX routine

NormalRt:			;

LDA !1534,x			; if the crumbled flag is set...
BEQ NotCrumbled1	; go to that part of the code

JSL $0190B2|!bank	; part of the setup for the crumbled GFX (shared GFX routine, but the values are changed anyway)

LDY !1540,x			; if the stun timer is not set...
BNE NoFace1			;
STZ !1534,x			; clear the crumbled flag
PHY					; preserve the OAM index
JSR FacePlayer		;
PLY					; pull back the OAM index

NoFace1:

LDA #!CrumbledTile2		; the half-crumbled tile
CPY #$10				; if the sprite is just about to get up...
BCC StoreCrumbledTile	;
CPY #$F0				; or if it just got squished...
BCS StoreCrumbledTile	; use the half-crumbled tile
LDA #!CrumbledTile1		; if not, use the fully-crumbled tile
StoreCrumbledTile:		;
LDY !15EA,x				; load the sprite OAM index back into Y
STA $0302|!addr,y		; set the tile number
SEC
SBC #$10
STA $030A|!addr,y

TYA						;
CLC						;
ADC #$04				; increment the OAM index by 4
STA !15EA,x				;

PHX						; preserve the sprite index
LDA !157C,x				;
TAX						; get the sprite direction into X
LDA $0300|!addr,y		;
STA $0308|!addr,y
CLC						;
ADC XDisp2,x			; set the tile X displacement depending on the sprite direction
PLX						;
STA $0304|!addr,y		;
STA $030C|!addr,y

LDA $0301|!addr,y		;
STA $0305|!addr,y		; set the same Y displacement
SEC
SBC #$08
STA $0309|!addr,y
STA $030D|!addr,y
LDA $0303|!addr,y		;
STA $0307|!addr,y		; and tile properties for both tiles
STA $030B|!addr,y
STA $030F|!addr,y

LDA $0302|!addr,y		; tile number of the first tile
DEC 					; the second tile always has a tile number one less than the first
STA $0306|!addr,y		; set the tile number of the second tile
SEC
SBC #$10
STA $030E|!addr,y

LDA !1540,x				; if the stun timer is set...
BEQ NoShakeDisp			;
CMP #$40				; and it is less than 40...
BCS NoShakeDisp			;
LSR #2					; right-shift it twice
PHP						; save the processor flags
LDA $0300|!addr,y		;
ADC #$00				; this will actually add 01 if bit 2 of the stun timer was set,
STA $0300|!addr,y		; since that bit went into the carry flag
STA $0308|!addr,y
PLP						; we needed to save those processor flags just in case that ADC unset the carry flag
LDA $0304|!addr,y		;
ADC #$00				; the same is true for the second tile: it will be shifted 00 or 01 pixels to the right
STA $0304|!addr,y		;
STA $030C|!addr,y

NoShakeDisp:

LDY #$02				; the tiles were 16x16
LDA #$03				; and 4 tiles were drawn
;LDA #$01				; and 2 tiles were drawn
JSL $01B7B3|!bank		; finish the OAM write
JSL $01802A|!bank		; update sprite position
LDA !1588,x				;
AND #$04				; if the sprite is on ground...
BEQ EndCrumbledCode		;
STZ !AA,x				; set its Y speed
STZ !B6,x				; and its X speed to zero

EndCrumbledCode:		;
RTS						;

NotCrumbled:

LDA $9D				; if sprites are locked...
ORA !163E,x			; (not sure what this does...$163E,x isn't referenced or modifed anywhere else)
BEQ Continue1		;
JMP Skip1			;

Continue1:

LDY !157C,x			;
LDA SlopeEor,y		; not sure what the purpose of this is...
EOR !15B8,x			; EOR it with the value of the slope the sprite is standing on
ASL					;
LDA SlopeEor,y		; now load the data itself
BCC StoreXSpeed		; if bit 7 of the data/slope EOR was set, store the X speed directly
CLC					;
ADC !15B8,x			; if not, add the value from the slope first
StoreXSpeed:		;
STA !B6,x			;

LDA !1540,x			; if the stun timer is set...
BNE ZeroXSpeed		; set the sprite X speed to 0
TYA					; if not...
INC A				; transfer the sprite direction to A and then increment it
AND !1588,x			; AND it with the sprite direction status
AND #$03			; if the sprite is touching a wall...
BEQ NoZeroXSpeed	;
ZeroXSpeed:			;
STZ !B6,x			;
NoZeroXSpeed:		;

LDA !1588,x			;
AND #$08			; if the sprite is touching the ceiling...
BEQ NoZeroYSpeed	;
STZ !AA,x			; set the sprite Y speed to 0
NoZeroYSpeed:		;
LDA #$00
%SubOffScreen()
JSL $01802A|!bank	; update sprite position

; removed sprite number check:
;CODE_01E4FC:        B5 9E         LDA RAM_SpriteNum,X       
;CODE_01E4FE:        C9 31         CMP.B #$31                
;CODE_01E500:        D0 1C         BNE CODE_01E51E           

LDA !1510,x			; check the extra bit (sprite number acts-like)
BEQ MaybeThrow		; if the sprite acts like sprite 32, skip the bone-throwing...
LDA $13BF|!addr		;
CMP #$31			; unless the overworld level is 10D,
BNE NoThrow			; in which case we treat the sprite as if it were the other variant
MaybeThrow:			;
LDA !1540,x			; $1540,x is *also* used as a throw timer for the bone-throwing Dry Bones.
BEQ NoThrow			; Its purposes are differentiated by $1534,x, which is nonzero if the sprite is crumbled.
CMP #$01			; if the throw timer has dropped to 1...
BNE NoBone			;

JSR ThrowBone		; throw a bone (technically, I could just JSL to $03C44E, but I might as well disassemble that too)

NoBone:				;

LDA #$02			; set the throwing frame
STA !1602,x			;
JMP Skip1			; and skip the speed-setting etc.

NoThrow:

LDA !1588,x			;
AND #$04			; if the sprite is not on the ground...
BEQ NotOnGround		; skip the next part of code

JSR SetSomeYSpeed
JSR SetAnimationFrame

LDA !1510,x			;
BEQ Skip2			;
STZ !C2,x			;
BRA NoUpdate		;

Skip2:				;

LDA !1570,x			;
AND #$7F			; every 80 frames...
BNE NoUpdate		;

JSR FacePlayer		; turn to face the player
BRA NoUpdate

NotOnGround:

STZ !1570,x			;
LDA !1510,x			;
BEQ NoUpdate		; skip the next part if the sprite acts like 30

LDA !C2,x			;
BNE NoUpdate		;
INC !C2,x			;

JSR FlipSpriteDir		; flip the sprite's direction
JSL $018022|!bank		; update sprite X position without gravity...
JSL $018022|!bank		; twice

NoUpdate:

; removed sprite number check:
;CODE_01E57B:        B5 9E         LDA RAM_SpriteNum,X
;CODE_01E57D:        C9 31         CMP.B #$31
;CODE_01E57F:        D0 17         BNE CODE_01E598

LDA !1510,x					;
BEQ MaybeResetThrowTimer	;
LDA $13BF|!addr				;
CMP #$31					; if the sprite acts like 32 and the overworld number isn't 31...
BNE Skip1					; don't reset the throw timer

MaybeResetThrowTimer:

LDA !1570,x		;
CLC				;
ADC #$40		; check the animation frame
AND #$7F		; if it is not 40 or C0...
BNE Skip1		; don't reset the throw timer

LDA #$3F		;
STA !1540,x		; time until the Dry Bones throws another bone

Skip1:
     
JSR Interact		; player interaction code
JSL $018032|!bank	; interact with other sprites
JSR MaybeFlip		;

SkipToGFX:

JSR DryBonesGFX		; draw the sprite

Return00:			;
RTS					;

Interact:

JSL $01A7DC|!bank	; check player/sprite contact
BCC Return00		; if there is none, just return

LDA $D3			;
CLC				;
ADC #$14		; if the player is less than 14 pixels above the sprite 
CMP !D8,x		;
BPL SpriteWins	; hurt the player

LDA $1697|!addr	; check the number of consecutive enemies stomped
BNE PlayerWins	;
LDA $7D			; if the player is moving upward...
BMI SpriteWins	;    

PlayerWins:

;PHK				; code from previous version
;PER $0006			; now it uses a macro, not sure if it's better but just to be certain
;PEA $8020			; - Burning Loaf
;JML $01AB46		; this subroutine handles the consecutive enemies stomped counter

%jslrts($01AB46|!bank,$01AB98|!bank)

JSL $01AB99|!bank	; display contact GFX

LDA #!SND_crumble
STA !BNK_crumble|!addr

JSL $01AA33|!bank	; boost the player's Y speed

INC !1534,x			; set the crumbled flag
LDA #$FF			;
STA !1540,x			; set the time until the sprite gets back up

RTS

SpriteWins:

JSL $00F5B7|!bank	; hurt the player
LDA $1497|!addr		; unless the player is flashing invincible...
BNE Return01		;
JSR FacePlayer		; turn to face him/her

Return01:			;
RTS

MaybeFlip:			; ripped from $019089

LDA !157C,x			;
INC					;
AND !1588,x			; if the sprite is touching an object in the direction that it is facing...
AND #$03			;
BEQ Return01		;
JSR FlipSpriteDir	; flip it
RTS					;

FlipSpriteDir:	; ripped from $019098

LDA !15AC,x		; if the turn timer is already set...
BNE Return01	; return
LDA #$08		;
STA !15AC,x		; set the turn timer
LDA !B6,x		;
EOR #$FF		; invert the sprite X speed
INC				;
STA !B6,x		;
LDA !157C,x		;
EOR #$01		; flip the sprite direction
STA !157C,x		;

RTS

FacePlayer:
%SubHorzPos()
TYA				;
STA !157C,x		;
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DryBonesGFX:

LDA !157C,x		;
PHA				; preserve the sprite direction
LDY !15AC,x		;
BEQ JustDraw	;
CPY #$05		; if the turn timer is 05 or greater...
BCC JustDraw	;
EOR #$01		; flip the sprite direction before drawing it
STA !157C,x		;

JustDraw:		;

JSR MainGFXRt	;
PLA				;
STA !157C,x		;

MainGFXRt:

; removed sprite number check:
;CODE_03C3DA:        B5 9E         LDA RAM_SpriteNum,X       
;CODE_03C3DC:        C9 31         CMP.B #$31                
;CODE_03C3DE:        F0 CE         BEQ CODE_03C3AE           

%GetDrawInfo()

LDA !15AC,x		;
STA $05			; save the turn timer in scratch RAM

LDA !157C,x		;
ASL				;
ASL				;
ADC !157C,x		; sprite direction x 5 -> $02
;ASL			;
;ADC !157C,x	; sprite direction x 3 -> $02
STA $02			;

PHX					; preserve the sprite index
LDA !1602,x			; current frame
PHA					;
ASL					; x2...
ASL					; x4...
ADC !1602,x			; x5
STA $03				; frame x 5 -> $03
;ASL				; x2...
;ADC !1602,x		; x3
;STA $03			; frame x 3 -> $03
PLX					; get the frame into X
LDA EndLoopCount,x	; set the number at which the loop will end
STA $04				;

LDX #$04			; 4 or 5 tiles to draw, depending on whether or not the sprite is throwing a bone
;LDX #$02			; 2 or 3 tiles to draw, depending on whether or not the sprite is throwing a bone        

GFXLoop:

PHX				; preserve the tilemap index
TXA				;
CLC				;
ADC $02			; add the value from the direction to the index
TAX				;
PHX				;
LDA $05			; if the turn timer is set...
BEQ NoIncIndex1	;
TXA				;
CLC				;
ADC #$0A		; increment the index by 10
;ADC #$06		; increment the index by 6
TAX				;
NoIncIndex1:	;

LDA $00				; base X position
CLC					;
ADC XDisp,x			; set the X displacement of the tile
STA $0300|!addr,y	;

PLX					; set the tile properties depending on the sprite direction
LDA TileProp,x		; palette, GFX page, and X flip
ORA $64				; add in sprite priority settings
STA $0303|!addr,y	; set the tile properties

PLA					;
PHA					; the tilemap index from before
CLC					;
ADC $03				; add the value from the frame
TAX					;

LDA $01				; base Y position
CLC					;
ADC YDisp,x			; set the tile Y displacement
STA $0301|!addr,y	;

LDA Tilemap,x		; set the tile number
STA $0302|!addr,y	;

PLX					; the index from the beginning, the tile count
INY #4				; increment the OAM index
DEX					; and decrement the tile counter
CPX $04				; if the counter has dropped to 00 or FF (depending on whether we're drawing 2 tiles or 3)...
BNE GFXLoop			;

PLX					; pull back the sprite index
LDY #$02			; the tiles are 16x16
LDA #$04			; and...well, this just assumes that we drew 5 tiles
;TYA				; and...well, this just assumes that we drew 3 tiles
JSL $01B7B3|!bank	; finish off the OAM write

RTS	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; bone-throwing subroutine, ripped from $03C44E
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ThrowBone:
LDA !15A0,x			; if the sprite is offscreen horizontally...
ORA !186C,x			; or vertically...
BNE NoSpawn			; don't throw a bone

LDA !157C,x			; sprite horizontal direction
LSR					; shift into the carry bit
LDA #$18			; if the sprite was facing right, bone X speed = 18
BCC SetBoneSpeed	;
LDA #$E8			; if the sprite was facing left, bone X speed = E8
SetBoneSpeed:		;
STA $02
LDA #$F0
STA $01
STZ $00
STZ $03
LDA #$06
%SpawnExtended()
NoSpawn:
RTS	

SetSomeYSpeed:		; ripped from $019A04
LDA !1588,x
BMI $07
LDA #$00
LDY !15B8,x
BEQ $02
LDA #$18
STA !AA,x
RTS

SetAnimationFrame:	; ripped from $018E5E

INC !1570,x
LDA !1570,x
LSR #3
AND #$01
STA !1602,x
RTS
