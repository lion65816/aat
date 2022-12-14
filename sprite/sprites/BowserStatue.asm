; ------------------------------ ;
;  Cluster Sprite Bowser Statue  ;
;         by JamesD28            ;
; ------------------------------ ;

; A variant of the Bowser Statue, that will shoot cluster sprites as it's flame projectiles instead of normal sprites. Additionally, you can customize the jumping
; speed/height of the statue, the X speed of the projectiles, and how often it shoots.

; Extra byte 1: Behaviours. Format: TTDDHPPP
	; T: Statue type.
		; 0 = Stationary.
		; 1 ($40) = Shoot fire.
		; 2 ($80) = Jumping.
		; 3 ($C0) = Jumping, shoot fire.
	; D: Initial direction and jumping behaviour.
		; 0 = Face/jump right.
		; 1 ($10) = Face/jump left.
		; 2 ($20) = Face/jump towards player.
		; 3 ($30) = Face/jump away from player.
	; H: If set ($08), the statue will hurt and can only be spinjumped off. If clear, it can be stood on.
	; P: Palette.

; Extra byte 2: Jump height/speed. Format: YYYYXXXX
	; Y: Y speed of the jump (how high the statue goes). Ranges from -$08 to -$78 in $10 increments.
	; X: X speed of the jump (how far the statue goes). Ranges from $08 to $78 in $08 increments. (inverted depending on direction).

; Extra byte 3: Projectile X speed.
; Extra byte 4: How often the statue shoots a projectile.

; ------------------------------

!JumpTimer = $30		; Time between each jump for the jumping types. This could have been an extra byte but I didn't feel like going over 4.

!FireNum = $02			; Cluster sprite number the fire projectile was inserted at.

!FireRand = 0			; 0 = Fire statues will always shoot at their regular specified interval.
						; 1 = The time before the first shot will be randomized, then shot at consistent intervals.
						; 2 = Each shot has a randomized time between them (centered around the specified shot interval in the range 0.5x-1.5x).

!FireSFX = $17			; SFX for shooting fire.
!FireSFXBank = $1DFC	; SFX bank.

!StatueHeadTile = $30		; Tile number for the statue's head.
!StatueBodyNormTile = $41	; Tile number for the statue's body when stationary.
!StatueBodyJumpTile = $35	; Tile number for the statue's body when jumping.
!StatueFeetTile = $56		; Tile number for the statue's feet. Used when jumping.

XOffsets:
db $08,$F8,$00,$00,$08,$00

YOffsets:
db $10,$F8,$00

Tiles:
db !StatueFeetTile,!StatueHeadTile,!StatueBodyNormTile,!StatueFeetTile,!StatueHeadTile,!StatueBodyJumpTile

TileSize:
db $00,$02,$02

FireXOffset:
db $10,$F0

; ------------------------------

print "INIT ",pc

LDA !extra_byte_1,x		;/
PHA						;|
LSR #4					;|
AND #$03				;|
STA !1504,x				;|
BIT #$02				;|
BEQ .Face				;|
AND #$01				;|
STA $00					;| Get direction depending on face left, right, towards player or away from player.
PHY						;|
%SubHorzPos()			;|
TYA						;|
PLY						;|
EOR $00					;|
.Face					;|
STA !157C,x				;\

LDA $01,s				;/
ASL						;|
ROL #2					;| Get statue type.
AND #$03				;|
STA !C2,x				;\

LDA $01,s				;/
AND #$08				;|
BEQ +					;|
LDA !167A,x				;| Use default interaction (allows hurting) if set to do so.
AND #$7F				;|
STA !167A,x				;\
+

PLA						;/
AND #$07				;|
ASL						;| Palette.
STA !15F6,x				;\

LDA #$10				;/
STA !AA,x				;\ Prevents the statue from showing the jumping pose for a frame after spawning.

LDA !extra_byte_4,x		;/
if !FireRand			;|
PHA						;|
LSR						;|
STA $00					;|
PLA						;|
%Random()				;| If fire interval randomization is set, get a random value in the range 0.5x-1.5x the specified interval. Otherwise, just set the specified value.
CLC						;| If the output would wrap past $FF, just set it to $FF.
ADC $00					;|
BCC +					;|
LDA #$FF				;|
+						;|
endif					;|
STA !163E,x				;\
RTL

; ------------------------------

print "MAIN ",pc

PHB
PHK
PLB
JSR Main
PLB
RTL

Main:

JSR Graphics

LDA $9D
BNE Return
%SubOffScreen()

LDA !C2,x			;/
ASL					;|
TAX					;| Run states.
JMP (StatePtrs,x)	;\

StatePtrs:
dw Stationary
dw Fire
dw Jump
dw JumpFire

; ------------------------------

Stationary:
LDX $15E9|!addr
JSL $01802A|!BankB	; Update position.
LDA !1588,x			;/
AND #$04			;|
BEQ +				;| If on the ground, reset the Y speed.
STZ !AA,x			;|
+					;\
LDA !C2,x
PHA
JSL $01B44F|!BankB	; Solid sprite routine (this also handles normal interaction if set to do so).
PLA					;/
STA !C2,x			;\ Prevents the glitch of a stationary statue becoming a fire-shooting statue if hit from below.
Return:
RTS

; ------------------------------

Fire:
JSR Stationary		; Run the stationary code.
LDA !163E,x			;/ Don't shoot if it's not time to do so, or the statue is on Yoshi's tongue (shouldn't happen).
ORA !15D0,x			;| The statue can shoot when offscreen, since the cluster sprite has proper handling for being offscreen (and vanilla statues shoot when offscreen).
BNE .NoFire			;\

LDY #$13			;/
.loop				;|
LDA $1892|!addr,y	;|
BEQ +				;| Find a free cluster sprite slot, or give up if none found.
DEY					;|
BPL .loop			;|
RTS					;\
+

LDA #!FireNum+!ClusterOffset	;/
STA $1892|!addr,y				;\ Cluster sprite number.
LDA #$01						;/
STA $18B8|!addr					;\ Run cluster sprite code. Might not be needed?

PHY					;/
LDY !157C,x			;|
LDA FireXOffset,y	;|
STA $00				;|
CLC					;|
ADC !E4,x			;|
PLY					;|
STA $1E16|!addr,y	;| Get X position offset based on statue's direction.
LDA #$00			;|
BIT $00				;|
BPL +				;|
DEC					;|
+					;|
ADC !14E0,x			;|
STA $1E3E|!addr,y	;\

LDA !D8,x			;/
SEC					;|
SBC #$02			;|
STA $1E02|!addr,y	;| Shift the Y position up by 2 pixels to align with the statue's mouth.
LDA !14D4,x			;|
SBC #$00			;|
STA $1E2A|!addr,y	;\

PHY						;/
LDA !extra_byte_3,x		;|
LDY !157C,x				;|
BEQ +					;|
EOR #$FF				;| Set X speed from extra byte 3 - inverted depending on direction.
INC						;|
+						;|
PLY						;|
STA $1E66|!addr,y		;\

LDA !extra_byte_4,x		;/
if !FireRand == 2		;|
PHA						;|
LSR						;|
STA $00					;|
PLA						;|
%Random()				;| Same deal as initial shot timer when spawning, but this depends on !FireRand being set to 2.
CLC						;|
ADC $00					;|
BCC +					;|
LDA #$FF				;|
+						;|
endif					;|
STA !163E,x				;\

LDA #!FireSFX				;/
STA !FireSFXBank|!addr		;\ Shoot a fireball SFX.

.NoFire
RTS

; ------------------------------

Jump:
LDX $15E9|!addr

STZ !1602,x				;/
LDA !AA,x				;|
CMP #$10				;|
BPL +					;| If moving downwards with a speed greater than $10, use the normal frame. Otherwise, jumping frame.
INC !1602,x				;|
+						;\
JSL $01802A|!BankB		; Update position.

LDA $1491|!addr			;/
STA !1528,x				;| Solid sprite routine, moving Mario with the statue if he's stood on top. Doesn't apply if using default interaction.
JSL $01B44F|!BankB		;\

.JumpStuff
LDA !1588,x				;/
AND #$03				;|
BEQ +					;|
LDA !B6,x				;|
EOR #$FF				;| Invert X speed and direction if the statue hit a wall.
INC						;|
STA !B6,x				;|
LDA !157C,x				;|
EOR #$01				;|
STA !157C,x				;\
+

LDA !1588,x				;/
AND #$04				;|
BEQ .Return				;| If the statue is still in the air, return.
LDA #$10				;|
STA !AA,x				;| Reset the X and Y speed if the statue is touching the ground.
STZ !B6,x				;\

LDA !1540,x				;/
BNE +					;|
LDA #!JumpTimer			;|
STA !1540,x				;|
.Return					;|
RTS						;|
+						;|
DEC						;|
BNE .Return				;| Make the statue jump when the timer hits 1, and reset the timer when it hits 0.
						;|
LDA !extra_byte_2,x		;|
PHA						;|
AND #$F0				;|
LSR						;|
EOR #$FF				;|
INC						;|
STA !AA,x				;\

LDA !1504,x				;/
BIT #$02				;|
BEQ .Face				;|
AND #$01				;|
STA $00					;|
PHY						;|
%SubHorzPos()			;|
TYA						;|
PLY						;|
EOR $00					;|
.Face					;| Make statue face/jump in the appropriate direction.
STA !157C,x				;|
						;|
PLA						;|
AND #$0F				;|
ASL #3					;|
LDY !157C,x				;|
BEQ +					;|
EOR #$FF				;|
INC						;|
+						;|
STA !B6,x				;\
RTS

; ------------------------------

JumpFire:
LDX $15E9|!addr
PEA.w Jump+2			;/
JMP Fire+3				;\ Just run the jump code then fire code.

; ------------------------------

Graphics:			; This is pretty much just copied from the Bowser Statue disassembly, with the customization options thrown in.

%GetDrawInfo()

LDA !1602,x
STA $04
EOR #$01
DEC A
STA $03
LDA !15F6,x
STA $05
LDA !157C,x
STA $02
LDX #$02
	
.loop	
PHX
LDA $02
BNE +
INX
INX
INX

+
LDA $00
CLC
ADC XOffsets,x
STA $0300|!addr,y
LDA #$00
CPX #$03
BCC +
LDA #$40
+
ORA $05
ORA $64
INC
STA $0303|!addr,y
PLX
LDA $01
CLC
ADC YOffsets,x
STA $0301|!addr,y
PHX
LDA $04
BEQ +
INX
INX
INX

+
LDA Tiles,x
STA $0302|!addr,y
PLX
PHY
TYA
LSR
LSR
TAY
LDA TileSize,x
STA $0460|!addr,y
PLY
INY
INY
INY
INY
DEX
CPX $03
BNE .loop

LDX $15E9|!addr

LDY #$FF
LDA #$02
%FinishOAMWrite()
RTS