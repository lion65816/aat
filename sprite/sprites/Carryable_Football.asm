;Carryable football
;A football that player can kick.
;After it's kicked, it'll act like a normal football for set amount of time
;Instead of hurting player it can hit enemies, and even explode on enemy hit.
;Extra Prop 1. set - Explode.
;
;It also can hit blocks when moving, like any carryable sprite.
;Give credit if used.

!ReCatchable = 1		;set to 1 if you want player to be able to re-catch it when it bounces around.

!GFXTile = $8A			;tile to display

!BlockHitSound = $01		;
!BlockHitBank = $1DF9		;

!NormalTimer = $FF		;how long it'll bounce around after being kicked

!Timer = !1564,x		;

;when it's in normal state
XSpeeds:
db $F0,$F8,$FC,$00,$04,$08,$10

;when it's in normal state
YSpeeds:
db $A0,$D0,$C0,$D0

;killed sprite's X-speed
KillXSpeed:
db $F0,$10

;killed sprite's Y-speed
!KillYSpeed = $D0

;copy-pasted from my bullet sprite, because I'm good at it
;Sprite contact flags enable to allow bullet to kill:
;!SprContactCape - If it can be hit/killed with cape attack
;!SprContactFire - If it can be hit/killed with fireball
;!SprContactStarBlks - If it can be hit/killed by star power and bounce sprites.
;
;Note that sprite checks those from CFG settings, specifically $166E's Bits 4 and 5 and $167A's bit 1.
;Glitchy death sprites may occure for some killed sprites, so watch out for that!
;Also those options don't include "Don't interact with other sprites" bit, check for it already included

!SprContactCape = 1
!SprContactFire = 1
!SprContactStarETC = 1

;used in sprite check, where it checks if sprite shouldn't interact with sprites that can't be killed with cape or fire or both
!ConfCheck = $00

if !SprContactFire
  !ConfCheck := !ConfCheck+$10
endif

if !SprContactCape
  !ConfCheck := !ConfCheck+$20
endif

Print "INIT ",pc
LDA #$09			;sprite status = carryable
STA !14C8,x			;
LDA #$D8
STA !B6,X
RTL

Print "MAIN ",pc
PHB
PHK
PLB
JSR Football
PLB
RTL

Football:
JSR HandleGFX			;graphics... I'll never understand how they work for carryable state, but it works, so :crash:

LDA $9D				;it's 9D
BNE .Re				;my dudes

%SubOffScreen()			;originally at the end of the routine, I've moved it up here (Say no to LDA #$00)
				;you need to uncheck "Process when off screen" in CFG file to make it disappear offscreen

LDA !14C8,x			;
CMP #$09			;
BCS .Carryable			;run carryable code if it's, well, carryable
CMP #$08			;if normal, do normal things
BNE .Re				;
;JMP NormalFootball		;
BEQ NormalFootball		;optimizations, dude

.Carryable
CMP #$0A			;
BNE .NotKicked			;

LDA #$08			;become normal after kick
STA !14C8,x			;

LDA #!NormalTimer		;"bounce" timer
STA !Timer			;

LDA #$10			;can't contact with player for a lil' bit
STA !154C,x			;

.Re
RTS				;

.NotKicked
;LDA !14C8,x			;this was subroutine
CMP #$0B			;
BNE .NotCarrying		;check if it's being carried

LDA $76				;it should face "away" from player (with player)
EOR #$01			;
STA !157C,x			;

JSR SprInteraction		;
RTS

.NotCarrying
LDA !AA,x			;interact with sprites only when moving
ORA !B6,x			;
BEQ .NoSprInteraction		;(yes, even if slightly)

JSR SprInteraction		;

.NoSprInteraction
JSL $019138|!BankB		;enable object interaction
JSR HandleInteraction		;
RTS				;some of coding runs before this, so there's not much here.

NormalFootball: 		;football disassembly
LDA !Timer			;if it's not time yet
BNE .Continue			;bounce like normal

INC !14C8,x			;become carryable again
RTS				;

.Continue
JSL $01802A|!BankB     		;update sprite position

JSR SprInteraction		;

If !ReCatchable
  JSR HandleInteraction		;can be recatched if set
endif

LDA !1588,x			;\ if sprite not touching ceiling, branch
AND #$08			; |
BEQ CODE_03803F			;/

STZ !AA,x			; else, set y speed to zero

LDA !1588,x			;\ If no horizontal contact, branch
AND #$03			; | 
BNE CODE_03803F			;/

JSR HandleBlockHit2		;

CODE_03803F:
LDA !1588,x			;
AND #$03			;
BEQ .NoWallHit 			;

JSR HandleBlockHit		;almost the same as above

LDA !B6,x			;\ else, invert horizontal speed
EOR #$FF			; |
INC A				; |
STA !B6,x			;/ 

.NoWallHit
LDA !1588,x			;\ if sprite not on ground, branch
AND #$04			; |
BEQ Return			;/

LDA !157C,x			;\ flip sprite graphics
EOR #$01			; |
STA !157C,x			;/

JSL $01ACF9|!BankB		;\ use random number generator to
AND #$03			; | determine new y speed
TAY				; |
LDA YSpeeds,y			; |
STA !AA,x			;/
LDY !15B8,X			;\ change x speed depending on what type of slope sprite is on (?)
INY #3				; |
LDA XSpeeds,y			; |
CLC				; |
ADC !B6,x			;/
BPL CODE_03807E			; if sprite going to the left, branch
CMP #$E0			;\ if sprite x speed slower than #$E0,
BCS CODE_038084			; |
LDA #$E0			; | load #$E0,
BRA CODE_038084			;/ 

CODE_03807E:
CMP #$20			;\ if sprite x speed slower than #$20,
BCC CODE_038084			; |
LDA #$20			;/ load #$20,

CODE_038084:

STA !B6,X			;and set new sprite x speed (to prevent sprite from going slower than #$20 or #$E0)

Return:
RTS				;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Interactions (sprites, player)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SprInteraction:
LDY #!SprSize

.Loop
LDA !14C8,y
CMP #$08
BCS .Alive

.Next
DEY
BPL .Loop
RTS

.Alive
LDA !1686,y
AND #$08
BNE .Next

If !ConfCheck
  LDA !166E,y			;this checks if sprite we're about to hit can be killed by cape, fire or both
  AND #!ConfCheck		;
  BNE .Next			;if not, NEEEEEEEXT!!!
endif

If !SprContactStarETC
  LDA !167A,y			;if checked sprite can't be killed with star and bouncing blocks, well...
  AND #$02			;
  BNE .Next			;...
endif

PHX				;get enemy's clipping first...
TYX				;
JSL $03B6E5|!BankB		;
PLX				;
JSL $03B69F|!BankB     		;then football's...

JSL $03B72B|!BankB	 	;check if their clippings overlap
BCC .Next			;if not, ok.

LDA #$02			;kill sprite
STA !14C8,y			;

LDA #$0A
JSL $02ACE5

LDA #$0A			;sound effect
STA $1DFC|!Base2		;

LDA #!KillYSpeed		;killed speed for both sprites
STA !AA,y			;
STA !AA,x			;

PHX				;x-speed for sprite we just killed
LDA !157C,y			;
TAX				;
LDA KillXSpeed,x		;
STA !B6,y			;
PLX				;

JSL $01AB6F|!BankB		;show hit effect

LDA !extra_prop_1,x		;if it should  explode
BNE .Explode			;do it

LDY #$00
LDA !B6,x			;if it didn't have any X-speed
BEQ .ResetNO2			;no need to add it

PHA				;don't make Y overwrite check value
LDY #$F0			;
PLA				;
BPL .ResetNO2			;

LDY #$10			;

.ResetNO2
;STY !B6,x			;

;LDA #$02			;
;STA !14C8,x			;
RTS

.Explode
LDA #$08			;Football: Become Normal
STA !14C8,x			;

LDA #$0D			;
STA !9E,x			;

JSL $07F7D2|!BankB		;

LDA #$01
STA !1534,x			;

LDA #$40			;
STA !1540,x			;

LDA #$13			;
STA $1DF9|!Base2		;

LDA !166E,x			;
ORA #$20			;
STA !166E,x			;
RTS

HandleInteraction:
LDA !154C,x			;
BNE .Return			;

JSL $01803A|!BankB		;due to how original sprites work I have to make interaction works correctly myself
BCC .Return			;

;generic code from $01AA42
;LDA $140D|!Base2		;they probably wanted to disable carrying with spinjump, but it's ruined by speed check.
;ORA $187A|!Base2		;this is also pointless, because it's checked again later
;BNE RunGFX

;LDA $7D			;... and this is also pointless, because this sprite isn't shell
;BPL RunGFX			;

LDA $15				;check if player's pressing X or Y button
AND #$40			;
BEQ .CheckSpr			;

LDA $1470|!Base2		;this is better. if carrying something already, say no
ORA $148F|!Base2		;
ORA $187A|!Base2		;if on yoshi, double no
BNE .CheckSpr			;

LDA #$0B			;sprite's being carried
STA !14C8,x			;

.KeepCarried
INC $1470|!Base2		;carrying something flag

LDA #$08			;
STA $1498|!Base2		;picking up timer
RTS

.CheckSpr
LDA !14C8,x			;don't run this code if's being carried
CMP #$09			;
BNE .Return			;

STZ !154C,x			;always contact with player

.Return
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Graphics routine
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HandleGFX:
STZ $02				;

LDA !14C8,x			;Y-flip if dead
CMP #$02			;
BNE .NotDead			;

LDA #$80			;
STA $02				;

.NotDead
%GetDrawInfo()			;

LDA #!GFXTile			;
STA $0302|!Base2,y		;

LDA $00				;
STA $0300|!Base2,y		;

LDA $01				;
STA $0301|!Base2,y		;

LDA !157C,x			;facing
LSR				;
LDA #$00			;
ORA !15F6,x			;
BCS .NoFlip			;
EOR #$40			;

.NoFlip
ORA $02
ORA $64				;
STA $0303|!Base2,y		;

LDY #$02			;tile size = 16x16
LDA #$00			;tiles to display = 1
JSL $01B7B3|!BankB		;
RTS				;

;some boring routines that I didn't even comment propertly

HandleBlockHit:
LDA #!BlockHitSound		;sound effect
STA !BlockHitBank|!Base2	;

;JSR .HandleBreak		;checks if it's a throw block. SPOILER! It's not.

LDA !15A0,x			;prevent sprite from triggering blocks when offscreen
BNE .Return			;

LDA !E4,x			;
SEC : SBC $1A			;
CLC : ADC #$14			;
CMP #$1C			;
BCC .Return			;

LDA !1588,x			;
AND #$40			;
ASL #2				;
ROR				;
AND #$01			;
STA $1933|!Base2		;

LDY #$00			;
LDA $18A7|!Base2		;
JSL $00F160|!BankB		;

LDA #$05			;
STA !1FE2,x			;

.Return
RTS				;

HandleBlockHit2:
LDA !E4,x			;prepare for block interaction
CLC : ADC #$08			;
STA $9A				;

LDA !14E0,x			;
ADC #$00			;
STA $9B				;

LDA !D8,x			;
AND #$F0			;
STA $98				;

LDA !14D4,x			;
STA $99				;

LDA !1588,x			;
AND #$20			;
ASL #3				;
ROL				;
AND #$01			;
STA $1933|!Base2		;

LDY #$00			;
LDA $1868|!Base2		;
JSL $00F160|!BankB		;

LDA #$08			;
STA !1FE2,x			;
RTS