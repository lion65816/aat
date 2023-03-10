;A disassembly of Ground Dwelling Monty Mole and Ledge Dwelling Monty Mole, sprites 4D and 4E respectively
;Extra bit: clear - ground dwelling, set - ledge dwelling

incsrc EasyPropDefines.txt

!Def_JumpVertSpeed = -$50			;when it jumps out of the ground
!Def_HopVertSpeed = -$28

!Def_HopTime = $50				;how long does it take for the hopping kind to hop

!Def_AppearTimeYI = $68				;how long does it take for the moley to appear (Yoshi's Island, see !Def_UniqueTimerMapID)
!Def_AppearTime = $20				;how long does it take anywhere else

;a tile to generate. NOTE: Uses $9C and $00BEB0 format. see RAM map $9C for possible values. By default $08 - Mole hole (map16 tile 0C6)
;if you want a better customizable map16 tile generation, use custom monty mole.
!Def_9CMap16Tile = $08

;if you want to change what submap gives longer timer (!Def_AppearTimeYI), change this
;possible values:
;$00 = Main map; $01 = Yoshi's Island; $02 = Vanilla Dome; $03 = Forest of Illusion; $04 = Valley of Bowser; $05 = Special World; $06 = Star World.
!Def_UniqueTimerMapID = $01

;a stupid thing is that ground dwelling mole uses graphical props from configuration, but ledge dwelling one overwrites it during its dirt animation. use this if you plan to change its palette and stuff
!Def_LedgeDwellingProp = !Palette8|!SP3SP4

Table_ChasingMoleMaxXSpeed:
db $18,-$18

Table_ChasingMoleXAcceleration:
db $01,-$01

Table_HoppingMoleXSpeed:
db $10,-$10

;mole walk 1, mole walk 2, mole jump up, ledge dwelling tile
Table_16x16Tilemap:
db $AA,$AC,$8E,$AE

;tilemap for ground dwelling kind (a small little pile). first two tiles are completely empty tiles (since it uses shared 8x8 graphic routine that outputs 4 sprite tiles even though it looks like 2 tiles)
Table_8x8Tilemap:
db $FB,$FB,$FE,$FF				;normal
db $FB,$FB,$FF,$FE				;horizontally flipped

Table_8x8GFXXDisp:
db $00,$08,$00,$08

Table_8x8GFXYDisp:
db $00,$00,$08,$08

Table_8x8Flips:
db $00,$00,$00,$00				;no flip
db !PropXFlip,!PropXFlip,!PropXFlip,!PropXFlip	;flip

;some common defines
!SpriteRAM_VerticalSpeed = !AA,x
!SpriteRAM_HorizontalSpeed = !B6,x

!SpriteRAM_SpriteXPositionLow = !E4,x
!SpriteRAM_SpriteXPositionHigh = !14E0,X

!SpriteRAM_SpriteYPositionLow = !D8,x
!SpriteRAM_SpriteYPositionHigh = !14D4,X

!SpriteRAM_SpriteState = !14C8,x
!SpriteRAM_FaceDirection = !157C,x
!SpriteRAM_BlockedStatus = !1588,x
!SpriteRAM_HorzOffscreenFlag = !15A0,x
!SpriteRAM_SlopeStatus = !15B8,x
!SpriteRAM_OnYoshiTongueFlag = !15D0,x
!SpriteRAM_GraphicalProps = !15F6,x		;palette and SP3/4 bit to be specific
!SpriteRAM_VertOffscreenFlag = !186C,x

;this sprite's specific tables
!SpriteRAM_Misc_PhasePointer = !C2,x
!SpriteRAM_Misc_HopFlag = !151C,x		;0 - follows the player, non-0 - hopping
!SpriteRAM_Misc_Timer = !1540,x			;used for various purposes. used as a timer to jump out of the ground, and how long should it stay behind foreground (unused)
!SpriteRAM_Misc_HopTimer = !1558,x		;used for the hopping mole, when runs out the mole hops
!SpriteRAM_Misc_AnimationFrameCounter = !1570,x	;can have other uses depending on the sprites but moslty acts as a frame counter for something
!SpriteRAM_Misc_AnimationFrame = !1602,x	;usually used as such by sprites, but there are exceptions

Print "INIT ",pc
MontyMoleInit:
LDA !SpriteRAM_SpriteXPositionLow		;alternate between following and hopping depending on X-position
AND #$10					;
STA !SpriteRAM_Misc_HopFlag			;
RTL						;

Print "MAIN ",pc
PHB
PHK
PLB
JSR MontyMoleMain
PLB
RTL

MontyMoleMain:
LDA #$00					;erase offscreen
%SubOffScreen()					;

LDA !SpriteRAM_Misc_PhasePointer		;run moley's code
JSL $0086DF|!bank				;

dw Mole_Hidden
dw Mole_DirtAnimation
dw Mole_JumpingOut
dw Mole_Moving

Mole_Hidden:
%SubHorzPos()					;check if the player is close enough
LDA $0E						;
CLC : ADC #$60					;
CMP #$C0					;
BCS .NotClose					;

LDA !SpriteRAM_HorzOffscreenFlag		;if offscreen horizontally, return
BNE .NotClose					;

INC !SpriteRAM_Misc_PhasePointer		;set to appear on-screen

LDY $0DB3|!addr					;get current player
LDA $1F11|!addr,y				;get the map on which the player's at
TAY						;
LDA #!Def_AppearTimeYI				;
CPY #!Def_UniqueTimerMapID			;yoshi's island (by default)
BEQ .StoreAppearTimer				;

LDA #!Def_AppearTime				;

.StoreAppearTimer
STA !SpriteRAM_Misc_Timer			;wait this much

.NotClose
%GetDrawInfo()					;invisible but do exist
RTS						;

Mole_DirtAnimation:
LDA !SpriteRAM_Misc_Timer			;if coming out timer hasn't expired
ORA !SpriteRAM_OnYoshiTongueFlag		;and not being licked
BNE .NotComingOut				;not coming out then

INC !SpriteRAM_Misc_PhasePointer		;jump out

LDA #!Def_JumpVertSpeed				;
STA !SpriteRAM_VerticalSpeed			;set vertical speed

;JSR IsSprOffScreen

LDA !SpriteRAM_HorzOffscreenFlag		;if offscreen in any way
ORA !SpriteRAM_VertOffscreenFlag		;
BNE .NoShatter					;fun fact: shatter spawn routine already has IsSprOffScreen check... so these lines are actually pointless
TAY						;

JSR SpawnShatter				;do what it says

.NoShatter
JSR FaceMario					;face the player

;checks if ledge dwelling or ground dwelling
;LDA !9E,x					;if ground dwelling, doesn't generate a tile
;CMP #$4E					;
;BNE .NoTileGeneration				;

LDA !extra_bits,x				;check if extra bit is set
AND #$04					;
BEQ .NoTileGeneration				;if not, no tile generation

;tile generation setup
LDA !SpriteRAM_SpriteXPositionLow		;
STA $9A						;

LDA !SpriteRAM_SpriteXPositionHigh		;
STA $9B						;

LDA !SpriteRAM_SpriteYPositionLow		;
STA $98						;

LDA !SpriteRAM_SpriteYPositionHigh		;
STA $99						;

LDA #!Def_9CMap16Tile				;mole tile
STA $9C						;
JSL $00BEB0|!bank				;

.NoTileGeneration
.NotComingOut
;now graphics also need to check what mole
;LDA !9E,x
;CMP #$4D
;BNE .LedgeDwellingGFX

LDA !extra_bits,x				;check if extra bit is set
AND #$04					;
BNE .LedgeDwellingGFX				;is ledge dwelling mole, display ledge dwelling GFX

;Ground Dwelling animation
LDA $14						;animate based on frame counter
LSR #4						;
AND #$01					;
;TAY						;
;LDA Table_GroundDwellingFrames,y		;get animation frame
;INC						;since it's either 0 or 1 and the table is 1 and 2, can just INC it
;STA !SpriteRAM_Misc_AnimationFrame		;don't even need to store this as it turns out, in fact don't even need to INC that

;LDA Table_LedgeDwelling8x8FlipOffset,y		;this is for shared graphics routine, which we aren't using.
JSR MontyMole_GroundDwellingGFX			;draw moley's holey/hilley/piley or w/ey
RTS

;Table_GroundDwellingFrames:
;db $01,$02

;Table_LedgeDwelling8x8FlipOffset:
;db $00,$05

;Ledge Dwelling animation
.LedgeDwellingGFX
LDA $14						;
ASL #2						;
AND #!PropXFlip|!PropYFlip			;flip vertically and horizontally to create an animation
ORA #$30|!Def_LedgeDwellingProp			;don't you love hardcoded props? ($30 - highest priority over foreground/background)
STA !SpriteRAM_GraphicalProps			;

LDA #$03					;show ledge dwelling animation
STA !SpriteRAM_Misc_AnimationFrame		;

JSR MontyMole_GFX				;display graphics

LDA !SpriteRAM_GraphicalProps			;clear flips
AND #$3F					;
STA !SpriteRAM_GraphicalProps			;
RTS						;

Mole_JumpingOut:
JSR Mole_PhysicsAndGraphics			;handle some stuff

LDA #$02					;
STA !SpriteRAM_Misc_AnimationFrame		;show jumping frame

;JSR IsOnGround

LDA !SpriteRAM_BlockedStatus			;check if the mole has landed
AND #$04					;
BEQ .NotGrounded				;don't start moving yet

INC !SpriteRAM_Misc_PhasePointer		;now perform as a normal functional member of mole society

.NotGrounded
RTS						;

Mole_Moving:
JSR Mole_PhysicsAndGraphics			;well? physics and graphics

LDA !SpriteRAM_Misc_HopFlag			;check if it should hop like a hopping mole it is
BNE .Mole_Hop					;do its hippity hoppity thing

JSR SetAnimationFrame				;animate FAST
JSR SetAnimationFrame				;

JSL $01ACF9|!bank				;call RNG Reinforcements
AND #$01					;
BNE .Return					;let RNG decide if the mole should move and chase the player

JSR FaceMario					;always face the Mario

LDA !SpriteRAM_HorizontalSpeed			;check if hit max x-speed
CMP Table_ChasingMoleMaxXSpeed,y		;
BEQ .Return					;if so, don't accelerate anymore
CLC : ADC Table_ChasingMoleXAcceleration,y	;do accelerate
STA !SpriteRAM_HorizontalSpeed			;
TYA						;
LSR						;
ROR						;
EOR !SpriteRAM_HorizontalSpeed			;check and see if the mole changed direction while chasing
BPL .Return					;if not, return

JSR SpawnDust					;kick some dust
JSR SetAnimationFrame				;oh and animate FASTER

.Return
RTS						;

.Mole_Hop
;JSR IsOnGround

LDA !SpriteRAM_BlockedStatus			;check if grounded
AND #$04					;
BEQ .IsInAir					;if not, just fall and display a single frame

JSR SetAnimationFrame				;animate
JSR SetAnimationFrame				;

LDY !SpriteRAM_FaceDirection			;set moley's speed
LDA Table_HoppingMoleXSpeed,y			;
STA !SpriteRAM_HorizontalSpeed			;

LDA !SpriteRAM_Misc_HopTimer			;if the timer's still ticking
BNE .NoHop					;don't hop

LDA #!Def_HopTime				;restore timer for the next hop
STA !SpriteRAM_Misc_HopTimer			;

LDA #!Def_HopVertSpeed				;hop up speed
STA !SpriteRAM_VerticalSpeed			;

.NoHop
RTS						;

.IsInAir
LDA #$01					;only show one frame when airborn
STA !SpriteRAM_Misc_AnimationFrame		;
RTS						;

Mole_PhysicsAndGraphics:
LDA $64						;
PHA						;
LDA !SpriteRAM_Misc_Timer			;send behind some stuff if this timer is set... which I don't think it is?
BEQ .NoLowPriority				;

LDA #$10					;lower priority, send behind FG
STA $64						;

.NoLowPriority
JSR MontyMole_GFX				;show mole
PLA						;
STA $64						;restore priority

LDA !14C8,x					;is the sprite dead?
EOR #$08					;
ORA $9D						;is freeze flag set?
BNE .NoPhysics					;don't actually move and stuff

JSL $01803A|!bank				;interact with other sprites and with player
JSL $01802A|!bank				;interact with objects and apply speed and gravity

;JSR IsOnGround

LDA !SpriteRAM_BlockedStatus			;is grounded?
AND #$04					;
BEQ .NotTouchingGround				;

JSR SetGroundYSpeed				;set grounded speed

.NotTouchingGround
;JSR IsTouchingObjSide

LDA !SpriteRAM_BlockedStatus			;is walled?
AND #$03					;
BEQ .NotTouchingWall				;

;JSR FlipSpriteDir

LDA !SpriteRAM_FaceDirection			;face away
EOR #$01					;
STA !SpriteRAM_FaceDirection			;

LDA !SpriteRAM_HorizontalSpeed			;completely bamboozled myself by forgetting these lines (actually move away from the wall)
EOR #$FF					;
INC						;
STA !SpriteRAM_HorizontalSpeed			;

.NotTouchingWall
RTS						;

.NoPhysics
PLA						;terminate all further mole behavour
PLA						;
RTS						;

;----------------------------------------------------------------
;Subroutines:

FaceMario:
%SubHorzPos()					;face the player. 'nuff said
TYA						;
STA !SpriteRAM_FaceDirection			;
RTS						;

;set normal grounded or slope speed
SetGroundYSpeed:
LDA !SpriteRAM_BlockedStatus			;check if on layer 2
BMI .Speed2					;apply other speed

LDA #$00					;don't really pull the sprite
LDY !SpriteRAM_SlopeStatus			;check if on slope
BEQ .Store					;if not, apply normal speed

.Speed2
LDA #$18					;pull the sprite if on layer 2 or slope

.Store
STA !AA,x					;
RTS						;

;2 frame animation routine
SetAnimationFrame:
INC !SpriteRAM_Misc_AnimationFrameCounter	;count up
LDA !SpriteRAM_Misc_AnimationFrameCounter	;
LSR #3						;every 4th frame is a different anim frame
AND #$01					;
STA !SpriteRAM_Misc_AnimationFrame		;
RTS						;

;input Y - shatter property (0 - normal shatter, non-0 - rainbow shatter)
SpawnShatter:
;JSR IsSprOffScreen				;already has offscreen check of its own. don't really need it twice

LDA !SpriteRAM_SpriteXPositionLow		;\setup for shatter spawn routine
STA $9A						;|position for it
						;|
LDA !SpriteRAM_SpriteXPositionHigh		;|
STA $9B						;|
						;|
LDA !SpriteRAM_SpriteYPositionLow		;|
STA $98						;|
						;|
LDA !SpriteRAM_SpriteYPositionHigh		;|
STA $99						;/

PHB						;
LDA #$02					;bank 2 required for tables
PHA						;
PLB						;
TYA						;input
JSL $028663|!bank				;call shatter routine
PLB						;
RTS						;

SpawnDust:
LDA !SpriteRAM_BlockedStatus			;if not blocked in any direction, don't spawn dust
BEQ .Return					;(probably makes more sense if it checked for grounded but ehhh)

LDA $13						;spawn every 4 frames
AND #$03					;
ORA $86						;unless the level is slippery
BNE .Return					;

LDA #$04					;horizontal offset
STA $00						;

LDA #$0A					;vertical offset
STA $01						;

;JSR IsSprOffscreen

LDA !SpriteRAM_HorzOffscreenFlag		;if offscreen in any way
ORA !SpriteRAM_VertOffscreenFlag		;
BNE .Return					;don't spawn dust (to minimize wrapping... keyword minimize, not completely prevent)

LDA #$13					;how long to exist
STA $02						;

LDA #$03					;smoke sprite number
%SpawnSmoke()					;spawn it

.Return
RTS						;

;----------------------------------------------------------------
;Graphics Routines:

!OAM_XPos = $0300|!addr
!OAM_YPos = $0301|!addr
!OAM_Tile = $0302|!addr
!OAM_Prop = $0303|!addr

;8x8 tiles routine
MontyMole_GroundDwellingGFX:
STA $05						;

%GetDrawInfo()					;

LDA !SpriteRAM_GraphicalProps			;
ORA $64						;
STA $03						;

LDX #$03					;4 tiles to draw

Loop:
STX $04						;save x here

LDA $00						;
CLC : ADC Table_8x8GFXXDisp,x			;
STA !OAM_XPos,y					;

LDA $01						;
CLC : ADC Table_8x8GFXYDisp,x			;
STA !OAM_YPos,y					;

LDA $05						;get flips and tilemap tables offset
ASL #2						;
ADC $04						;
TAX						;
LDA Table_8x8Tilemap,x				;tilemap
STA !OAM_Tile,y					;

LDA Table_8x8Flips,x				;apply appropriate flips
ORA $03						;
STA !OAM_Prop,y					;

LDX $04						;reload current tile index

INY #4						;next OAM slot

DEX						;loop for all 4
BPL Loop					;

LDX $15E9|!Base2				;original uses PHX PLX, but i replaced them for optimization sake

LDA #$03					;4 tiles
LDY #$00					;8x8 size
%FinishOAMWrite()				;write 'em
RTS						;

;16x16. both ledge-dwelling and normal walking (it's all shared anyway)
MontyMole_GFX:
%GetDrawInfo()

;some dead stuff (since we have clipping bit enabled, we have to handle dead gfx ourselves)
STZ $04						;

LDA !14C8,x					;
CMP #$08					;check if alive
BEQ .NoVertFlip					;if so, no vertical flip

LDA #!PropYFlip					;vertical flip
STA $04						;

STZ !SpriteRAM_Misc_AnimationFrame		;also show only one frame just like vanilla mole

.NoVertFlip
LDA !SpriteRAM_Misc_AnimationFrame		;show a tile depending on the current graphical frame
TAX						;
LDA Table_16x16Tilemap,x			;
STA !OAM_Tile,y					;

LDX $15E9|!addr					;restore sprite slot in x we've messed with

LDA $00						;tile x
STA !OAM_XPos,y					;

LDA $01						;tile y
STA !OAM_YPos,y					;

LDA !SpriteRAM_FaceDirection			;load which way the sprite's facing
LSR						;
LDA #$00					;
ORA !SpriteRAM_GraphicalProps			;
BCS .NoXFlip					;

EOR #!PropXFlip					;apply x-flip if facing a different direction (right)

.NoXFlip
ORA $04						;
ORA $64						;priority
STA !OAM_Prop,y					;

LDA #$00					;only 1 tile
LDY #$02					;size = 16x16
%FinishOAMWrite()				;display on-screen correctly
RTS						;
;MOLEY ON YOUR PHONE