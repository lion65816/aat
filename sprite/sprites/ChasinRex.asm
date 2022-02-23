;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Rex that chases you.
;; Extra Prop. Byte 1:
;; Bit 0 - Flashing variant (immune to stomping)
;; Bit 1 - Hidden (remains hidden untill player comes close)
;;
;; By RussianMan
;;
;; Original chasing sprite requested by Roberto Zampari.
;; Flashing Variant requested by zacmario.
;; Hidden Variant requested by Blizzard Buffalo.
;;
;; Credit is optional.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!XSpeed = $11
!SmushXSpeed = $20

TableXSpeed:
db !XSpeed,$00-!XSpeed,!SmushXSpeed,$00-!SmushXSpeed

Accel:
db $01,$FF,$01,$FF

;ONLY FOR FLASHING REX
!InvinStompSound = $02
!InvinStompBank = $1DF9|!Base2

;ONLY FOR PEEKING REX
!PeekTime = $40			;how long it peeks left<->right

!HorzProximityRange = $30	;how close player must be for it to jump out. 0 - disable set proximity check
!VertProximityRange = $00	;

JumpSpdX:
db $06,-$06			;X-speed for when it jumps out of scenery

!JumpSpdY = $B0			;Y-speed for the same reason

!JumpSnd = $08			;sound effect
!JumpBnk = $1DFC|!Base2		;soun bank

;GFX
XDisp:
db $FC,$00,$FC,$00,$FE,$00,$00,$00,$00,$00,$00,$08
db $04,$00,$04,$00,$02,$00,$00,$00,$00,$00,$08,$00

YDisp:
db $F1,$00,$F0,$00,$F8,$00,$00,$00,$00,$00,$08,$08

Tilemap:
db $8A,$AA,$8A,$AC,$8A,$AA,$8C,$8C,$A8,$A8,$A2,$B2

FaceFlip:
db $40,$00

FlashTable:
db $00,$04,$02,$06		;for flash animation.

;MISC. TABLE USAGE
!ActsLike = !1594,x

!FlashPal = !1534,x

!MovementTimer = !163E,x

!PeekTimer = !15AC,x

!HideTimer = !1540,x		;only used after jumped out of pipe, shouln't mess spinjump star thing

!ChaseFlag = !160E,x		;check if it's peeking

!MovementDir = !187B,x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
%SubHorzPos()			;
TYA				; face the player initially
STA !157C,x			;

LDA !extra_prop_1,x		; to save at least a byte
STA !ActsLike			;
AND #$02			; if it should stay hidden
BNE Pipe			; mission impossible

INC !ChaseFlag
RTL

Pipe:
LDA !E4,x			;center position
CLC : ADC #$08			;to fit pipe or smth
STA !E4,x			;

LDA !14E0,x			;
ADC #$00			;
STA !14E0,x			;
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
JSR RexMain		; $039517
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RexMain:
LDA $64				;
PHA				;
LDA !ChaseFlag			; appear behind foreground if it's hiding
BEQ .Yes

LDA !HideTimer			; if it jumped out of pipe but still partially behind scenes
BEQ .No				;

.Yes
LDA #$10			;
STA $64				;

.No
JSR RexGFX			; draw the Rex
PLA				;
STA $64				;

LDA !14C8,x			; check the sprite status
EOR #$08			; if the Rex is not in normal status...
ORA $9D				; or sprites are locked...
BNE .NoULook			; return
%SubOffScreen()			;

LDA !ActsLike			;check if it should flash
AND #$01
BEQ .NoFlash			;

LDA $14				;flash
LSR				;
AND #$03			;		
TAY				;
LDA FlashTable,y		;
STA !FlashPal			;

.NoFlash
LDA !ChaseFlag			;
BNE .Normal			;
INC				;
STA !1602,x			; show normal frame when hiding

If !HorzProximityRange
  LDA #!HorzProximityRange	;\ check horizontal proximity
  STA $00			;|
  STZ $01			;|
  %ProximityHorz()		;|
  BCS .NoProx			;/
endif

If !VertProximityRange
  LDA #!VertProximityRange	;\ check vertical proximity
  STA $00			;|
  STZ $01			;|
  %ProximityVert()		;|
  BCS .NoProx			;/
endif

LDA #!JumpSpdY
STA !AA,x

%SubHorzPos()			; face player
TYA				;
STA !157C,x			;

LDA JumpSpdX,y			; jump towards them
STA !B6,x			;

INC !ChaseFlag			;

LDA #$0A			; how long it's behind scenery (also disables interaction to not mess with speed)
STA !HideTimer			;

LDA #!JumpSnd			;
STA !JumpBnk			;
RTS				;

.NoProx
LDA !MovementTimer		; check if it must still move up or down
BNE .KeepMove			;

LDA !AA,x			; check if it's speed was upward
BPL .stop			; if not upward, do move up
;BEQ .NoULook			; if zero, doesn't matter (and this line probably too)

LDA !PeekTimer			; check timer
BEQ .init			; initialize if it was zero
DEC				;
BEQ .stop			; if it = 1, change direction, untill then...

LDA $14				; ...look left an right
AND #$07			;
BNE .NoULook			;

LDA !157C,x			;
EOR #$01			;
STA !157C,x			;

.NoULook
RTS				;

.stop
LDA #$50			; timer that i don't think needs adjustments, so it's not a define
STA !MovementTimer		;

LDA !MovementDir		; move other (vertical) direction
EOR #$01			;
STA !MovementDir		;
;BRA .KeepMove			; and apply said movement (no)
RTS

.init
LDA #!PeekTime			;
STA !PeekTimer			;
RTS				;

.KeepMove
JMP UpDown			; branch out of bounds for .Normal, unfortunately (both proximity checks enabled)

.Normal
LDA !1558,x			; if the Rex has been fully squished and its remains are still showing...
BEQ Alive			;

STA !15D0,x			; set the "eaten" flag
DEC				; if this is the last frame to show the squished remains...
BNE Return00			;

STZ !14C8,x			; erase the sprite

Return00:
RTS				;

Alive:
INC !1570,x			; increment this sprite's frame counter (number of frames on the screen)
LDA !1570,x			;
LSR #2				; frame counter / 4
LDY !C2,x			; if the sprite is half-squished...
BEQ NoHSquish			;
AND #$01			; then it changes animation frame every 4 frames
CLC				;
ADC #$03			; and uses frame indexes 3 and 4
BRA SetFrame			;

NoHSquish:
LSR				; if the sprite is not half-squished,
AND #$01			; it changes animation frame every 8 frames

SetFrame:
STA !1602,x			; set the frame number

LDA !HideTimer			; don't interact if just jumped out of scenery
BNE InAir_NoSpeedChange		;

LDA !1588,x			;
AND #$04			; if the Rex is on the ground...
BEQ InAir			;

LDA #$10			; give it some Y speed
STA !AA,x			;

%SubHorzPos()			;
TYA				;
STA !157C,x			;

LDA !C2,x			;
BEQ NoFastSpeed			; if the Rex is half-squished...
INY #2				; increment the speed index so it uses faster speeds
NoFastSpeed:			;
      
LDA !B6,X    			;
CMP TableXSpeed,Y       	;
BEQ InAir        		;
CLC                     	; 
ADC Accel,Y       		;	
STA !B6,X    			;

InAir:
LDA !1588,x			; check if it's bumping a wall
AND #$03			;
BEQ .NoSpeedChange		;

LDA !B6,x			; speed gets inversed
EOR #$FF			;
INC A				;
STA !B6,x			;

.NoSpeedChange
LDA !1FE2,x			; if the timer to show the half-smushed Rex is set...
BNE NoUpdate			; don't update sprite position
JSL $01802A|!BankB		;

NoUpdate:
JSL $018032|!BankB		; interact with other sprites
JSL $01A7DC|!BankB		; interact with the player
BCC NoContact			; carry clear -> no contact

LDA $1490|!Base2		; if the player has a star...
BNE StarDeath			; run the star-killing routine
        
LDA !154C,x			; if the interaction-disable timer is set...
BNE NoContact			; act as if there were no contact at all

LDA #$08			;
STA !154C,x			; set the interaction-disable timer

LDA $7D				;
CMP #$10			; if the player's Y speed is not between 10 and 8F...
BMI SpriteWins			; then the sprite hurts the player

.NoScore
JSL $01AA33|!BankB		; boost the player's speed
JSL $01AB99|!BankB		; display contact graphics

LDA $140D|!Base2		; if the player is spin-jumping...
ORA $187A|!Base2		; or on Yoshi...
BNE SpinKill			; then kill the sprite directly

LDA !ActsLike			; if it's set to be invincible to stomps
AND #$01			;
BNE .StompRe			; jump

%Stomp()			;

INC !C2,x			; otherwise, increment the sprite state

LDA !C2,x			;
CMP #$02			; if the sprite state is now 02...
BNE HalfSmushed			;

LDA #$20			; set the time to show the fully-squished remains
STA !1558,x			;

.Re
RTS				;

.StompRe
LDA #!InvinStompSound		; make spinjump stomp sound effect (by default)
STA !InvinStompBank		;
RTS				;

HalfSmushed:
LDA #$0C			; set the time to show the partly-smushed frame
STA !1FE2,x			; (since when is $1FE2,x a misc. sprite table?)
STZ !1662,x			; change the sprite clipping to 0 for the half-smushed Rex
RTS  				;

SpriteWins:
LDA $1497|!Base2		; if the player is flashing invincible...
ORA $187A|!Base2		; or is on Yoshi...
BNE NoContact			; just return

JSL $00F5B7|!BankB		; hurt the player

NoContact:
RTS				;

StarDeath:
%Star()				;
RTS				;

SpinKill:
%Stomp()			;

LDA #$04			; sprite state = 04
STA !14C8,x			; spin-jump killed

LDA #$1F			; set spin jump animation timer
STA !1540,x			;

JSL $07FC3B|!BankB		; show star animation

LDA #$08			;
STA $1DF9|!Base2		; play spin-jump sound effect
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RexGFX:
LDA !FlashPal			;
STA $0A				;

LDA !1558,x			; if the Rex is not squished...
BEQ NoFullSquish		; don't set the squished frame

LDA #$05			;
STA !1602,x			; set the frame (fully squished)

NoFullSquish:
LDA !1FE2,x			; if the time to show the half-squished Rex is nonzero...
BEQ NoHalfSquish		;

LDA #$02			;
STA !1602,x			; set the frame (half-squished)

NoHalfSquish:			;
%GetDrawInfo()			;

LDA !157C,x			;
STA $02				;
  
LDA !1602,x			;
ASL				; frame x 2
STA $03				; tilemap index

LDA !15F6,x			;
STA $04				;

PHX				;
LDX #$01			; tiles to draw: 2

GFXLoop:
PHX				;
TXA				;
ORA $03				; add in the frame
PHA				; and save the result
LDX $02				; if the sprite direction is 00...
BNE FaceLeft			; then the sprite is facing right...
CLC				;
ADC #$0C			; and we need to add 0C to the X displacement index
FaceLeft:			;
TAX				;
LDA $00				;
CLC				;
ADC XDisp,x			; set the tile X displacement
STA $0300|!Base2,y		;

PLX				; previous index back
LDA $01				;
CLC				;
ADC YDisp,x			; set the tile Y displacement
STA $0301|!Base2,y		;

LDA Tilemap,x			;
STA $0302|!Base2,y		; set the tile number

LDX $02				;
LDA FaceFlip,x			;
ORA $04				;
ORA $0A				;
ORA $64				;
STA $0303|!Base2,y		;

TYA				;
LSR #2				; OAM index / 4
LDX $03				;
CPX #$0A			; if the frame is 5 (squished)...
TAX				;
LDA #$00			; set the tile size as 8x8
BCS SetTileSize			;
LDA #$02			; if the frame is less than 5, set the tile size to 16x16
SetTileSize:			;
STA $0460|!Base2,x		;
PLX				; pull back the tile counter index
INY #4				; increment the OAM index
DEX				; if the tile counter is positive...
BPL GFXLoop			; there are more tiles to draw
				   
PLX				; pull back the sprite index
LDY #$FF			; Y = FF, because we already set the tile size
LDA #$01			; A = 01, because 2 tiles were drawn
JSL $01B7B3|!BankB		; finish the write to OAM
RTS				;

UpDown:
%SubHorzPos()			;
TYA				;
STA !157C,x			;

LDY #$01			; load Y-speed
LDA !MovementDir		;
BNE .NoOverwrite		;
LDY #$01^$FF+1			; invert value

.NoOverwrite
STY !AA,x			; store speed

JSL $01801A|!BankB		;
RTS