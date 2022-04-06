; -------------------- ;
;   Kun (Beta Sprite)  ;
;      by JamesD28     ;
; -------------------- ;

; An interpretation of the scrapped beta sprite known as "Kun" (one-chr-kun.OBJ) from the July 2020 SMW gigaleak.
; This odd little creature can follow ground, walls and ceilings like a Spike Top, and when touched, can disappear in a puff of smoke and knock the player back.
; Alternatively, it can also hurt the player when touched, or not interact at all and act as a little background buddy.

; Extra bit: Movement type.
	; Clear = Walks back and forth.
	; Set = Wall-following.

; Extra byte 1: Movement speed. Due to wall-following "quirks", this can only apply to back and forth movement (extra bit clear).
; 				The Wall-Following variant will instead use one of two fixed speeds, controllable by the F bit in extra byte 2.

; Extra byte 2: Additional behaviours. Format: -IFfhppp.
	; -: Unused.
	; I: If set ($40), the Kun will not interact with the player, and will effectively be a decorative sprite.
	; F: If set ($20), the Wall-Following Kun will move twice as fast as normal.
	; f: If set ($10), Kun will occasionally turn to face Mario like a Yellow Koopa.
	; h: If set ($08), contact with the Kun will also hurt Mario.
	; p: Palette.

; Extra byte 3: Initial X position offset (signed). This can be set to any value, but is really only useful for shifts between +/- 8 pixels.
; 				$00-$7F = Shift right.
;				$80-$FF = Shift left.

; --------------------

!AniFrameTimer = $0C	; Timer for how often the Kun should animate.

!PuffSFX = $20			; SFX to use when Kun disappears in a puff of smoke. Default is "Yoshi Spit".
!PuffSFXBank = $1DF9	; SFX bank.

!KnockbackSpeed = $40	; Absolute speed to push Mario at when knocked back by the Kun. Actual X/Y speeds are calculated depending on the contact point.

; --------------------

XSpeed:									;/
db $01,$FF,$FF,$01,$FF,$01,$01,$FF		;|
YSpeed:									;| Dummy X/Y speeds for object interaction.
db $01,$01,$FF,$FF,$01,$01,$FF,$FF		;\

XSpeed2:								;/
db $08,$00,$F8,$00,$F8,$00,$08,$00		;|
YSpeed2:								;| Actual wall-following X/Y speeds.
db $00,$08,$00,$F8,$00,$08,$00,$F8		;\

ObjCheckVals:
db $01,$04,$02,$08,$02,$04,$01,$08

KunFrames:
db $6B,$6C,$6B,$6C,$6B,$6C,$6B,$6C		; Frame 1 of Kun's animation.
db $7B,$7C,$7B,$7C,$7B,$7C,$7B,$7C		; Frame 2 of Kun's animation.

KunFlips:
db $40,$80,$80,$40,$00,$C0,$C0,$00		; Tile flips.

TileXTweaks:
db $00,$01,$00,$00,$00,$00,$00,$01		;/
										;| Small tile offsets needed due to wall-following weirdness.
TileYTweaks:							;|
db $01,$00,$00,$00,$01,$00,$00,$00		;\

; --------------------

print "INIT ",pc

PHB
PHK
PLB
JSR KunInit
PLB
RTL

KunInit:

LDA !D8,x				;/
CLC						;|
ADC #$09				;|
STA !D8,x				;| Shift Kun 9 pixels down (it's object clipping is roughly this amount above the ground).
LDA !14D4,x				;|
ADC #$00				;|
STA !14D4,x				;\

LDY #$00				;/
LDA !extra_byte_3,x		;|
BEQ .DontShift			;|
BMI .LeftShift			;|
CLC						;|
ADC !E4,x				;|
STA !E4,x				;|
LDA !14E0,x				;|
ADC #$00				;|
STA !14E0,x				;|
BRA .DontShift			;| Shift the Kun by the amount specified in extra byte 3.

.LeftShift				;|
EOR #$FF				;|
INC						;|
STA $00					;|
LDA !E4,x				;|
SEC						;|
SBC $00					;|
STA !E4,x				;|
LDA !14E0,x				;|
SBC #$00				;|
STA !14E0,x				;\
.DontShift

LDA #!AniFrameTimer		;/
%Random()				;| Get a random number between 0 and the specified animation timer.
STA !163E,x				;\
LDA $148E|!addr			;/ Get a random number for the "turn to face Mario" timer (whether used or not).
STA !15AC,x				;\

%BEC(+)
INC !1504,x				; Use $1504 as a "wall-following" flag.
JSL $019138|!BankB
LDA !1588,x
AND #$04
BEQ .Kill

+
%SubHorzPos()			;/ Make the sprite face Mario.
TYA						;|
ASL #2					;|
STA !C2,x				;| 0-3 = Rightwards/clockwise. 4-7 = Leftwards/anticlockwise. Only 0 and 4 are used if the Kun is set to go back and forth.
LDA !extra_byte_1,x		;|
BPL +					;|
EOR #$FF				;|
INC						;|
+						;|
CPY #$00				;|
BEQ +					;|
EOR #$FF				;|
INC						;|
+						;| Set the X speed depending on the direction.
STA !B6,x				;\
RTS

.Kill
STZ !14C8,x				; Kill the Kun if not on the ground.
RTS

; --------------------

print "MAIN ",pc

PHB
PHK
PLB
JSR KunMain
PLB
RTL

KunMain:

JSR Graphics

LDA $9D
BNE .Return
%SubOffScreen()

LDA !163E,x				;/
BNE .DontChangeFrame	;|
LDA !1602,x				;|
EOR #$08				;| Update animation frame when the animation timer hits 0. We alternate a value of $08 since it indexes 2 sets of 8-byte entries for each frame.
STA !1602,x				;|
LDA #!AniFrameTimer		;|
STA !163E,x				;\
.DontChangeFrame

LDA !extra_byte_2,x		;/
AND #$10				;|
BEQ .DontFace			;|
LDA !15AC,x				;|
BNE .DontFace			;| Check if the Kun is set to face Mario, and check and update the facing timer.
LDA #$30				;|
%Random()				;|
CLC						;|
ADC #$68				;| Get facing timer value of $80 +/- $18. Similar to how vanilla sprites spice up the facing intervals, but this one randomizes every time.
STA !15AC,x				;\

LDA !1504,x					;/
BEQ .NotWallFollowing		;|
LDA !1540,x					;| If the Kun is wall-following, don't turn to face Mario if it's "corner turning" timer is set.
BNE .WallFollowMain			;\
JSR FaceMario
BRA .WallFollowMain

.NotWallFollowing
JSL $019138|!BankB			;/
LDA !1588,x					;|
AND #$04					;| If the Kun is set to move back and forth, don't turn to face Mario if in the air.
BEQ .MoveBackAndForth		;\
JSR FaceMario				;/
BRA .MoveBackAndForth		;\ Face Mario.

.DontFace

LDA !1504,x					;/
BNE .WallFollowMain			;\ Go to the wall-following's main code if that flag is set.

JSL $019138|!BankB			;/
.MoveBackAndForth			;|
LDA !1588,x					;|
BIT #$04					;|
BEQ +						;| 
STZ !AA,x					;|
+							;|
AND #$03					;|
BEQ .NoWallContact			;|
							;| Handle the Kun's object interaction.
LDA !C2,x					;|
EOR #$04					;|
STA !C2,x					;|
LDA !B6,x					;|
EOR #$FF					;|
INC							;|
STA !B6,x					;|
.NoWallContact				;|
JSL $01802A|!BankB			;\
JMP MarioInteract

.Return
RTS

; --------------------

.WallFollowMain			; Taken from the Sparky/Fuzzy disassembly and adapted.

LDA !1540,x				;
BNE Skip1				; Branch if the "turning corner" timer is set.

LDY !C2,x				;
LDA YSpeed,y			;
STA !AA,x				; Dummy X/Y speeds for object interaction.
LDA XSpeed,y			;
STA !B6,x				;

JSL $019138|!BankB		; Interact with objects.

LDA !1588,x				; Check the sprite's object status.
AND #$0F				; If the sprite is touching an object...
BNE Skip1				; branch.

LDA #$08				;
STA !1564,x				; Disable contact with other sprites.
LDA !extra_byte_2,x
AND #$20
PHP
LDA #$0D				; Timer = $0D if slow movement.
PLP
BEQ SetTimer1
LDA #$06				; Timer = $06 if fast movement.
SetTimer1:				;
STA !1540,x				;

Skip1:

LDA !extra_byte_2,x
AND #$20
PHP
LDA #$08				;
PLP						;
BEQ CheckTimer1			;
LDA #$04				;
CheckTimer1:			;
CMP !1540,x				; If the timer has reached the check value...
BNE NoChangeState		;
INC !C2,x				; change the sprite state.
LDA !C2,x				;
CMP #$04				; If the sprite state has reached 04...
BNE NoResetState		;
STZ !C2,x				; reset it to $00.
NoResetState:			;
CMP #$08				; If it is $08...
BNE NoChangeState		;
LDA #$04				; set it to $04.
STA !C2,x				;

NoChangeState:			;
LDY !C2,x				;
LDA !1588,x				; Check the object contact status depending on the sprite state.
AND ObjCheckVals,y		;
BEQ Skip2				; If the sprite isn't touching the specified surface, skip the next part.
LDA #$08				;
STA !1564,x				; Disable contact with other sprites for a few frames.
DEC !C2,x				; Decrement the sprite state.
LDA !C2,x				;
BPL CompareState1		; If the result was positive, branch.
LDA #$03				;
BRA StoreState1			; Set the sprite state to $03.

CompareState1:			;
CMP #$03				;
BNE Skip2				;
LDA #$07				;
StoreState1:			;
STA !C2,x				;

Skip2:					;
LDY !C2,x				;
LDA YSpeed2,y			; Set the sprite's Y speed.
STA !AA,x				;
LDA XSpeed2,y			;
STA !B6,x				;

LDA !extra_byte_2,x		;/
AND #$20				;|
BEQ SlowerSpeed			;|
ASL !AA,x				;| Double the speeds if the F bit of extra byte 2 is set.
ASL !B6,x				;|
SlowerSpeed:			;\
JSL $018022|!BankB		; Update sprite X position without gravity.
JSL $01801A|!BankB		; Update sprite Y position without gravity.

; --------------------

MarioInteract:

LDA !extra_byte_2,x		;/
AND #$40				;| Don't interact if the I bit in extra byte 2 is set.
BEQ +					;|
RTS						;\

+
LDA !E4,x				;/
PHA						;|
SEC						;|
SBC #$04				;|
STA !E4,x				;|
LDA !14E0,x				;| The sprite clipping we're using is centered for a 16x16 sprite, so we need to shift it's X position to match where the Kun tile is drawn.
PHA						;| For some reason the Y clipping plays better if we just leave it how it is.
SBC #$00				;|
STA !14E0,x				;|
JSL $01A7DC|!BankB		;\
PLA
STA !14E0,x
PLA
STA !E4,x
BCC .Return

STZ $00						;/
STZ $01						;|
LDA #$12					;|
STA $02						;| 8x8 puff of smoke.
LDA #$03					;|
%SpawnSmoke()				;|
STZ !14C8,x					;\
LDA #!PuffSFX
STA !PuffSFXBank|!addr

LDA !14E0,x					;/
XBA							;|
LDA !E4,x					;|
REP #$20					;|
SEC							;|
SBC $94						;|
SEC							;|
SBC #$0004					;|
STA $00						;|
SEP #$20					;|
							;|
LDA !14D4,x					;|
XBA							;|
LDA !D8,x					;| Gets X/Y speeds as if the Kun was aiming towards Mario, and instead use this as Mario's knockback speeds.
REP #$20					;|
SEC							;|
SBC $96						;|
SEC							;|
SBC #$0014					;|
STA $02						;|
SEP #$20					;\

LDA !extra_byte_2,x			;/
AND #$08					;| Also hurt the player if that bit is set in extra byte 2.
BEQ .Knockback				;|
LDA $1490|!addr				;|
BNE .Knockback				;| and doesn't have a star
LDA $187A|!addr				;|
BEQ +						;| and not riding Yoshi
%LoseYoshi()				;| but just lose Yoshi if so
BRA .Knockback				;|
+							;|
JSL $00F5B7|!BankB			;\

.Knockback
LDA #!KnockbackSpeed		;/ Defined knockback speed.
%Aiming()					;|
LDA $00						;|
STA $7B						;|
LDA $02						;|
STA $7D						;\

.Return
RTS

; --------------------

Graphics:

%GetDrawInfo()

LDA !extra_byte_2,x			;/
AND #$07					;|
ASL							;|
INC							;|
STA $04						;| Put some tables in scratch for convenience.
LDA !1602,x					;|
STA $02						;|
LDA !C2,x					;|
STA $03						;\
TAX

LDA $00						;/
CLC							;|
ADC TileXTweaks,x			;|
STA $0300|!addr,y			;|
LDA $01						;| Give the tile X/Y positions some pixel shifts based on the wall the Kun is on.
SEC							;|
SBC TileYTweaks,x			;|
STA $0301|!addr,y			;\

LDA $03						;/
CLC							;|
ADC $02						;| Get the tile number based on the wall the Kun's on + the animation frame.
TAX							;| $00-$07 = frame 1. $08-$0F = frame 2.
LDA KunFrames,x				;|
STA $0302|!addr,y			;\

LDX $03						;/
LDA KunFlips,x				;| Get flips based on the wall the Kun's on.
ORA $04						;| Palette data.
ORA $64						;|
STA $0303|!addr,y			;\

LDX $15E9|!addr
LDA #$00					;/
TAY							;\ One 8x8 tile.
%FinishOAMWrite()
RTS

; --------------------

FaceMario:
LDA !C2,x					;/
BIT #$01					;| Handle horizontal and vertical facing separately.
BNE .VerticalFace			;\

STA $00						;/
%SubHorzPos()				;|
STY $01						;|
TYA							;|
CLC							;| Get new horizontal direction indexed by the current wall the Kun is on + whether the Kun is currently facing towards or away from Mario.
ADC $00						;|
TAY							;|
LDA NewHorzDirections,y		;|
STA !C2,x					;\

LDA !1504,x					;/
BNE .Return					;|
LDA !extra_byte_1,x			;|
LDY $01						;|
BEQ +						;| Also change the X speed manually if the Kun is set to move back and forth.
EOR #$FF					;|
INC							;|
+							;|
STA !B6,x					;\

.Return
RTS

.VerticalFace				;/
DEC							;|
STA $00						;|
LDA $96						;|
PHA							;|
CLC							;|
ADC #$20					;|
STA $96						;|
LDA $97						;|
PHA							;|
ADC #$00					;|
STA $97						;|
%SubVertPos()				;|
PLA							;|
STA $97						;|
PLA							;|
STA $96						;|
TYA							;| Get new vertical direction indexed by the current wall the Kun is on + whether the Kun is currently facing towards or away from Mario.
CLC							;|
ADC $00						;|
TAY							;|
LDA NewVertDirections,y		;|
STA !C2,x					;\
RTS

NewHorzDirections:
db $00,$04,$06,$02,$00,$04,$06,$02

NewVertDirections:
db $01,$07,$05,$03,$05,$03,$01,$07