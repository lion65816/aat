;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Floating Platforms (sprites 5B & 5C), by imamelia
;; Modified by Disk Poppy to make them bouncy.
;; Uses parts of disassembly of springboard by RussianMan
;;
;; This is a modified disassembly of sprites 5B and 5C in SMW, floating platforms.
;;
;; Uses first extra bit: NO
;;
;; You must set sprite buoyancy on for this to work.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!WaterRiseSpeed = -$20
!BigBounceSpeed = $9F
!SmallBounceSpeed = $D0
!BounceSFX = $08

TileAnim:
db $00,$02,$04

FrameToShow:
db $00,$01,$02,$02,$02,$01,$01,$00,$00

;offset when player's on springboard for "sinking" animation
MarioOnSpringOffset:
db $1E,$1B,$18,$18,$18,$1A,$1C,$1D,$1E

;used for "sinking" animation to displace tiles correctly
AdditionalYDisp:
db $00,$00,$03

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
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
JSR FloatingPlatformMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FloatingPlatformMain:

LDA $9D			;
BEQ NoSkip1		; if sprites are locked...
JMP SkipToGFX		; skip directly to the GFX routine

NoSkip1:			;

JSL $01801A|!bank	; update sprite Y position without gravity
LDA !164A,x		; \  
PHA			; | preserve and reset "sprite in liquid"
STZ !164A,x		; /
JSL $019138|!bank	; block contact
STZ $1491|!Base2		; reset the "prevent sliding on a platform" flag

; removed sprite number check for the spike ball (CMP #$A4)

LDA !AA,x		; check the sprite Y speed
CMP #$40			; if it is greater than 40...
BPL NoIncYSpeed		; don't increment it
INC !AA,x		; if it is 40 or less, increment it
NoIncYSpeed:		;
PLA			; if the sprite isn't in water or lava...
BEQ NoDecYSpeed		; don't do some subsequent Y speed checks

; another removed sprite number check

LDA !AA,x		; check the sprite's Y speed
BPL DecYSpeed		; if positive, decrement it
CMP #!WaterRiseSpeed			; also decrement it if it is negative
BCC NoDecYSpeed		; and no less than F8
DecYSpeed:		;
SEC			;
SBC #$02			; decrement the sprite's Y speed by 2
STA !AA,x		;

NoDecYSpeed:

STZ $185E|!Base2

LDA !1540,x			;if animation timer isn't set
BEQ NotOnIt			;don't do bouncing on it

OnIt:
LSR				;calculate Y-displacement
TAY				;
LDA $187A|!Base2		;check if on yoshi
CMP #$01			;Moderator changed this to LSR, but I restored it 'cause it offsets player on yoshi incorrectly while turning.
LDA MarioOnSpringOffset,y	;
BCC .NoADC			;
ADC #$11			;add to displacement

.NoADC
STA $00				;

LDA FrameToShow,y		;those are frames for sprite to show
STA !1602,x			;do small pressing and unpressing animation

LDA !D8,x			;displace Mario vertically
SEC : SBC $00			;
STA $96				;

LDA !14D4,x			;
SBC #$00			;
STA $97				;don't forget about high byte

STZ $72				;Reset "in the air" flag, aka "kinda" on ground
STZ $7B				;no X speed

LDA #$02			;
STA $1471|!Base2		;Mario stands on springboard

LDA !1540,x			;check if it's time to make actual bounce
CMP #$07			;
BCS EndInteraction		;

STZ $1471|!Base2		;Mario's not on springboard anymore

LDY #!SmallBounceSpeed
LDA $15
BPL +			; if A or B held, skip
LDA #$80			;set special RAM to make screen scroll vertically (if enabled to)
STA $1406|!Base2		;
LDY #!BigBounceSpeed
+
STY $7D			; bounce player

LDA #!BounceSFX
STA $1DFC|!Base2

INC $185E|!Base2		;
LDA #$08
STA !AA,x		; set the Y speed *again* (surely Nintendo could have done this better)
BRA EndInteraction


NotOnIt:
LDA $7D
BMI EndInteraction

Interaction:
JSL $01A7DC|!bank	; check contact with player
BCC EndInteraction
STZ !154C,x

LDA !D8,x			;welp, it's a solid one
SEC : SBC $96			;
CLC : ADC #$04			;
CMP #$1C			;check if touching from below
BCC EndInteraction			;
BPL .AlmostEnd			;or from above
BRA EndInteraction

.AlmostEnd
LDA #$11			;make a small little bounce off it
STA !1540,x

EndInteraction:

LDA $185E|!Base2		;
CMP !151C,x		; not sure what the purpose of this is
STA !151C,x		;
BEQ SkipYSpd2		;
LDA $185E|!Base2		;
BNE SkipYSpd2		; or this
LDA $7D			;
BPL SkipYSpd2		; branch if the player is moving downward

LDY #$08			; start Y at 08
LDA $19			; if the player is small...
BNE NotSmall2		;
LDY #$06			; use Y = 06 instead
NotSmall2:		;
STY $00			;

LDA !AA,x		; ANOTHER Y speed check?!
CMP #$20			;
BPL SkipYSpd2		; branch if the sprite Y speed is greater than 20...
CLC			;
ADC $00			; Good gravy, how many times are they going to change the Y speed in this thing?
STA !AA,x		;

SkipYSpd2:		;

LDA $14			;
AND #$01		;
BNE SkipToGFX		; skip the next part every other frame

LDA !AA,x		; check the Y speed AGAIN
BEQ NoChangeYSpd1	;
BPL NoIncYSpd2		;
CLC			;
ADC #$02		;
NoIncYSpd2:		; there HAS to be a better way of doing this...
SEC			;
SBC #$01			; because we totally haven't already messed with the sprite's Y speed enough,
STA !AA,x		; we'll set it again

NoChangeYSpd1:		;

LDY $185E|!Base2		; I'd put an enlightening comment here,
BEQ SkipYSpd3		; but your guess is as good as mine.
LDY #$05			;
LDA $19			; Hey, kids! Let's play the "set Y to a number depending on whether or not
BNE SkipYSpd3		; the player is small" game again!
LDY #$02			; This time, our lovely numbers are 05 and 02!
SkipYSpd3:		;
STY $00			;

LDA !D8,x		;
PHA			; save the sprite Y position...this can't be good...
SEC			;
SBC $00			;
STA !D8,x		; Okay, so...apparently we're messing with the sprite's Y position
LDA !14D4,x		; as well as its speed.  Wonderful.
PHA			;
SBC #$00			;
STA !14D4,x		; looks like we want to offset the sprite's Y position...

JSL $019138|!bank		; so that it will use a different base position when interacting with objects.

PLA			; pull back stuff
STA !14D4,x		;
PLA			; All this just to make the sprite float?
STA !D8,x		; Nintendo, you fail.


SkipToGFX:		;
LDA #$00
%SubOffScreen()		; Whoa! Something that we actually semi-know what it does!

LDY !1602,x		;
LDA AdditionalYDisp,y	;
STA $0F
LDA TileAnim,y
STA $0E

%GetDrawInfo()
LDA $00
STA $0300|!Base2,y		; set the tile X displacement
LDA $01
CLC : ADC $0F
STA $0301|!Base2,y		; set the tile Y displacement
LDA $0E
STA $0302|!Base2,y
LDA $64			; priority
ORA !15F6,x		; no hardcoded palette
STA $0303|!Base2,y	; properties
LDA #$00			; 1 tile to draw
LDY #$02			; the tile is 16x16
%FinishOAMWrite()
RTS
