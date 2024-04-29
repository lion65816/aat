db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

; by default, sprites who won't interact with the block change its act like to a "blank" tile, but you can change that here to whatever you want
!changeLo = $25
!changeHi = $00

; Mario Interaction setting
; 	0 = Mario doesn't interact
;	1 = Mario always interacts
!marioInteracts = 0
!marioChangeLo = !changeLo
!marioChangeHi = !changeHi

; Fireball interaction settings
; 	0 = Fireballs don't interact
;	1 = Fireballs always interact
!fireballInteracts = 0
!fireballChangeLo = !changeLo
!fireballChangeHi = !changeHi

; Cape interaction settings
; 	0 = Cape doesn't interact
;	1 = Cape always interacts
!capeInteracts = 0
!capeChangeLo = !changeLo
!capeChangeHi = !changeHi

; Stunned Sprites setting
;	0 = Stunned sprites don't interact
;	1 = Stunned sprites always interact
;	2 = Stun state has no bearing on interactions
!stunnedSpriteInteracts = 2
!stunnedChangeLo = !changeLo
!stunnedChangeHi = !changeHi


andtable:
db $80,$40,$20,$10,$08,$04,$02,$01

SpriteFilter:
;	Set flag to 1 to make the sprite interact with the block, 0 to change the act like to [blank tile] and make them pass through
;	Refer to Lunar Magic's "Add Sprites Window" to learn which number corresponds to what sprite
; 	By default, all -enemy- sprites are set to 1, except for
;		- sprites that don't interact with tiles (there's a lot of them)
;		- Jumping Pirahna Plants (4F and 50)
;		- Footballs (1B)
;		- Sumo lightning (2B)
;		- Ninji (51)
; 	By default, all friendly sprites are set to 0; Moving Coin (21), Baby Yoshi (2D), Springboard (2F) Yoshi (35), P-Switches (3E), directional coin (45), 
;	all powerups (74, 75, 76, 77, 78), growing vines (79), Key (80), and Dolphins (41, 42 and 43)

;	feel free to enable or disable any of these as you wish

;	01234567,  89ABCDEF
db %00000000, %11111000 ;0x
db %00000000, %00000000 ;1x
db %00000000, %00000000 ;2x
db %00000000, %00000000 ;3x
db %00000000, %00000000 ;4x
db %00000000, %00000000 ;5x
db %00000000, %00000000 ;6x
db %00000000, %00000000 ;7x
db %00000010, %00000000 ;8x
db %00000000, %00000000 ;9x
db %00000000, %00000000 ;Ax
db %00000000, %00000000 ;Bx
db %00000000, %00000000 ;Cx
db %00000000, %00000000 ;Dx
db %00000000, %00000000 ;Ex
db %00000000, %00000000 ;Fx

CustomSpriteFilter:
;	Set flag to 1 to make the sprite interact with the block, 0 to change the act like to [blank tile] and make them pass through
;	Refer to, uh, PIXI's list.txt? to learn which number corresponds to what sprite? if you've inserted them yourself, you should know
;	01234567,  89ABCDEF
db %00000000, %00000000 ;0x
db %00000000, %00000000 ;1x
db %00000000, %00000000 ;2x
db %00000000, %00000000 ;3x
db %00000000, %00000000 ;4x
db %00000000, %00000000 ;5x
db %00000000, %00000000 ;6x
db %00000000, %00000000 ;7x
db %00000000, %00000000 ;8x
db %00000000, %00000000 ;9x
db %00000000, %00000000 ;Ax
db %00000000, %00000000 ;Bx
db %00000000, %00000000 ;Cx
db %00000000, %00000000 ;Dx
db %00000000, %00000000 ;Ex
db %00000000, %00000000 ;Fx

SpriteV:
SpriteH:
if !stunnedSpriteInteracts == 0 ; 0 = Stunned sprites don't interact
	LDA !14C8,x
	CMP #$08
	BEQ startforreals ;not stunned, just go ahead and do the normal thing
	LDA #!stunnedChangeLo
	STA $1693|!addr
	LDY #!stunnedChangeHi	; change act like and return
	RTL
elseif !stunnedSpriteInteracts == 1 ; 1 = Stunned sprites always interact
	LDA !14C8,x
	CMP #$08
	BEQ startforreals ;not stunned, just go ahead and do the normal thing
	RTL	; just returm
endif
	
startforreals:
PHY

LDA !7FAB10,x
AND #$08
BNE .IsCustom

LDA !9E,x
AND #$07
TAY
LDA andtable,y
STA $00
LDA !9E,x
LSR
LSR
LSR
TAY
LDA SpriteFilter,y
AND $00
BEQ .gothrough
BRA .dontgothrough

.IsCustom
LDA !7FAB9E,x
AND #$07
TAY
LDA andtable,y
STA $00
LDA !7FAB9E,x
.notCustom
LSR
LSR
LSR
TAY
LDA CustomSpriteFilter,y
AND $00
BEQ .gothrough

.dontgothrough
PLY
RTL
.gothrough
PLY

LDA #!changeLo
STA $1693|!addr
LDY #!changeHi

RTL

MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
	if !marioInteracts == 0
		LDA #!marioChangeLo
		STA $1693|!addr
		LDY #!marioChangeHi
	endif
RTL

;WallFeet:	; when using db $37
;WallBody:

MarioFireball:
	if !fireballInteracts == 0
		LDA #!fireballChangeLo
		STA $1693|!addr
		LDY #!fireballChangeHi
	endif
RTL
MarioCape:
	if !capeInteracts == 0
		LDA #!capeChangeLo
		STA $1693|!addr
		LDY #!capeChangeHi
	endif
RTL

print "<Selective Sprite Only> Block"