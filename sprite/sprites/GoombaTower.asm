;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Goomba Tower, by Darolac
;;
;; A tower of 4 goombas that moves towards Mario and, when jumped on, it spawns 4 goombas.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!XSpeed = $07

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XSpeed:

db !XSpeed,-!XSpeed

XSpeedS:

db $10,-$10,$20,-$20

Prop:

db $40,$00

YOffset:

db $00,-$10,-$20,-$30

Tiles:

db $A8,$AA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR Goombatowermain
PLB
RTL

print "INIT ",pc
%SubHorzPos()
TYA
STA !157C,x
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Goombatowermain:

JSR GFX

LDA !14C8,x			; \ 
EOR #$08			; |load sprite status, check if default/alive, 
ORA $9D				; |sprites/animation locked flag 
BEQ Continue			; /
RTS

Continue:
%SubOffScreen()	; check if the sprite is offscreen.

JSL $01802A|!BankB	; update sprite position.
JSL $018032|!BankB

LDA !sprite_x_high,x
XBA
LDA !sprite_x_low,x
REP #$20
SEC
SBC $94
BPL +
EOR #$FFFF
INC
+
CMP #$0010             
SEP #$20
BCS Nodamage

LDA !sprite_y_high,x
XBA
LDA !sprite_y_low,x

PHY
SEC
LDY $187A|!Base2
REP #$20
BEQ +
SBC #$0010
+ PLY

SBC $96
CMP #$004A
SEP #$20          
BCS Nodamage 

LDA $1497|!Base2	; if the player is flashing invincible...
BNE Nodamage ; don't interact

LDA $1490|!Base2 ; if the player is invencible...
BNE Goombaspawn	; kill the sprite

LDA !154C,x		; if the interaction-disable timer is set...
BNE Nodamage		; act as if there were no contact at all

LDA #$08		;
STA !154C,x		; set the interaction-disable timer

LDA $7D			;
CMP #$10		; if the player's Y speed is not between 10 and 8F...
BMI SpriteWins		; then the sprite hurts the player
BRA Goombaspawn

SpriteWins:
JSL $00F5B7|!BankB	;

Nodamage:

LDA !1588,x			; \
AND #$03			; | check if it's blocked from the sides
BEQ +				; /
LDA !B6,x			; if it is, then change speed...
EOR #$FF
INC
STA !B6,x
LDA !157C,x			; \
EOR #$01			; | ...and change direction
STA !157C,x			; /
+

LDY !157C,x
LDA XSpeed,y
STA !B6,x

Return:
RTS

Goombaspawn:

LDA #$03
STA $0C

Loop2:

LDY $0C

STZ $00
LDA YOffset,y
STA $01
LDA XSpeedS,y
STA $02
LDA #$05
STA $03
LDA #$0F
CLC
%SpawnSprite()
BCS Nokill

LDA $1490|!Base2
BEQ Nokill

LDA #$02
STA !14C8,y

Nokill:
DEC $0C
BPL Loop2

LDA $1490|!Base2
BEQ +
%Star()
BRA ++
+
JSL $01AA33|!BankB	; boost the player's speed
JSL $01AB99|!BankB	; display contact graphics
LDA #$02
STA $1DF9|!Base2
++

DEC $0C
BPL Loop2

STZ !14C8,x

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GFX:

%GetDrawInfo()

LDA #$03 ; nº of tiles to draw
STA $05

STZ $07
LDA !14C8,x
CMP #$08
BNE Noanimate
LDA $14
LSR #3
AND #$01
STA $07

Noanimate:

LDA !15F6,x
STA $06

LDA !157C,x
TAX
LDA Prop,x
ORA $64
ORA $06
STA $06

Loop:

LDX $05

LDA $00				; load X position of tile
STA $0300|!Base2,y	; store it

LDA $01				; load Y position of tile
CLC
ADC YOffset,x
STA $0301|!Base2,y	; store it

LDX $07
LDA Tiles,x
STA $0302|!Base2,y

LDA $06
STA $0303|!Base2,y

INY #4
DEC $05
BPL Loop

LDX $15E9|!Base2	; recover sprite slot in X register 

LDA #$03			; we draw 4 tiles
LDY #$02			; 16x16 tiles
JSL $01B7B3|!BankB	; finish OAM write routine

RTS					; end this gfx routine