; Better Yoshi Interaction Patch
;
; This patch completely erases Yoshi's interaction routines with normal, extended, and
; cluster sprites and moves it into the player hurt routine. The advantage of this is Yoshi
; no longer needs special criteria for sprites of any kind to harm him as any damage the
; player takes will check if the player is riding Yoshi and if so make him run away. This
; fixes odd interaction with examples like ball 'n chains, wooden spikes, dryobones, bowser
; statues, hurt blocks, the koopalings, Reznor, and more. 3rd party patches are no longer
; needed that modify sprite's code or the og Yoshi routine. This patch does not use any
; freespace but instead uses all the space freed up by getting rid all the original Yoshi
; interaction space. This patch also fixes small issues like the player not being allow
; through doors/boss doors with Yoshi, fixing the spawn if taking him in a boss room, and
; fixing a small issue with his face appearing in Morton/Roy's BG. Credit for Sonikku's
; SpriteEdgeTop calculation routine and of course he was the inspiration for this patch.

if read1($00FFD5) == $23
	sa1rom
	!sa1  = 1
	!addr = $6000
	!bank = $000000
else
	lorom
	!sa1  = 0
	!addr = $0000
	!bank = $800000
endif

macro define_sprite_table(name, addr, addr_sa1)
	if !sa1 == 0
		!<name> = <addr>
	else
		!<name> = <addr_sa1>
	endif
endmacro

%define_sprite_table("9E", $9E, $3200)
%define_sprite_table("B6", $B6, $B6)
%define_sprite_table("C2", $C2, $D8)
%define_sprite_table("14C8", $14C8, $3242)
%define_sprite_table("151C", $151C, $3284)
%define_sprite_table("157C", $157C, $3334)
%define_sprite_table("1588", $1588, $334A)
%define_sprite_table("1594", $1594, $3360)
%define_sprite_table("163E", $163E, $33FA)
%define_sprite_table("190F", $190F, $7658)

org $009A13		; fixes starting y pos in Morton/Ludwig/Roy/Reznor's rooms
	JML MortonRoyLudwigPStartY

org $00EBDD		; allows all tiles of door to be enterable with Yoshi
	JML BossDoorswYoshi

org $00EBFD		; allows top half of door to be enterable with Yoshi
	JML DoorwYoshi

org $00F5D5		; start hijack as soon as player takes damage
	JML HurtYoshi

org $01A897
	JSR TopDistance
	NOP

org $01A8FE
	BRA +
	NOP #3
	+

org $01B0FC		; deletes check for yoshi in cheep cheep interaction
	BRA +
	NOP #3
	+

org $01C27F
	JMP YoshiWings
	NOP

org $01EBBE		; x speed Yoshi runs
db $18,$E8

org $01ED76		; deletes JSR to yoshi -> sprites interaction
	BRA +
	NOP
	+

org $01F622		; our new lose Yoshi routine

LoseYoshi:
	PHA
	PHX
	PHY
	LDX $18E2|!addr
	LDA #$10
	STA !163E-1,x
	LDA #$03
	STA $1DFA|!addr
	LDA #$13
	STA $1DFC|!addr
	LDA #$02
	STA !C2-1,x
	STZ $187A|!addr
	STZ $0DC1|!addr
	LDA #$24
	STA $72
	LDA #$C0
	STA $7D
	STZ $7B
	LDY !157C-1,x
	PHX
	TYX
	LDA $01EBBE|!bank,x
	PLX
	STA !B6-1,x
	STZ !1594-1,x
	STZ !151C-1,x
	STZ $18AE|!addr
	LDA #$30
	STA $1497|!addr
	PLY
	PLX
	PLA
	RTL

HurtYoshi:
	LDA $187A|!addr
	BEQ +
	JSL LoseYoshi
	JML $00F628|!bank
+
	LDA $19
	BEQ .Killplayer
	JML $00F5D9|!bank	;return to kill player if he doesn't have a powerup.
.Killplayer
	JML $00F606|!bank

;calculates player's position relative to the sprite's using his actual hitbox
;rather than his absolute position and adds the criteria seen in the vanilla code
;(by Sonikku)

SpriteEdgeTop:
	JSR TopDistance
    LDA $05
    SEC
    SBC $01
    ROL $00
    CMP $D3
    PHP
    LSR $00
    LDA $0B
    SBC #$00
    PLP
    SBC $D4
    BMI .Fail
    LDA $7D
    BPL .CheckOnGround
    LDA !190F,x
    AND #$10
    BNE .CheckOnGround
    LDA $1697|!addr
    BEQ .Fail
.CheckOnGround
    LDA !1588,x
    AND #$04
    BEQ .Pass
    LDA $72
    BEQ .Fail
.Pass
	SEC
    RTL
.Fail
	CLC
    RTL

MortonRoyLudwigPStartY:
	LDX #$B0
	LDA $187A|!addr
	BNE +
	LDA #$90
	BRA ++
+
	LDA #$80
++
	JML $009A17|!bank

BossDoorswYoshi:
	CPY #$98
	BEQ +
	CPY #$99
	BEQ +
	CPY #$9A
	BEQ +
	CPY #$9B
	BEQ +
	CPY #$9C
	BNE ++
+
	JML $00EBE1|!bank
++
	JML $00EBE8|!bank

DoorwYoshi:
	LDA $187A|!addr
	BEQ +
	BRA ++
+
	LDA $19
	BNE +
++
	JML $00EC01|!bank
+
	JML $00EC24|!bank

YoshiWings:
	LDA !C2,x
	BEQ +
	CMP #$02
	BNE ++
	LDA !9E,x
	CMP #$7E
	BNE ++
	LDA $187A|!addr
	BEQ ++
	JSR $A7E4
	BCC ++
	LDA #$08					;|\ Warp to Yoshi wings game.
	STA $71						;||
	LDA #$03					;||\ SFX for collecting wings, when touched.
	STA $1DFC|!addr				;|//
	LDA #$02					;|\ Give Yoshi wings.
	STA $141E|!addr				;|/
	STZ !14C8,x					;| Erase sprite.
++
	JMP $C283
+
	JMP $C287

TopDistance:
	LDA $187A|!addr
	BNE +
    LDA #$14
	BRA ++
+
	LDA #$28
++
    STA $01
	RTS

RidingYoshiClippingWith:
	LDA $187A|!addr
	BNE +
	LDA #$0C
	BRA ++
+
	LDA #$0E
++
	STA $02
	RTL

if !sa1 == 1
	NOP #7
else
	NOP #8
endif

warnpc $01F74C

org $01FAA3
	JSR $A7E4

org $028376
	JML MortonRoyBG

org $02A46C			; delete normal extended and cluster sprite yoshi interaction routine
	BNE ExClStar
	BRA ExClHurt

MortonRoyBG:
	LDA $187A|!addr	
	BEQ +
	LDA $1884|!addr
	BEQ +
	LDA #$00
	BRA ++
+
	LDA #$01
++
	STA $188C|!addr
	JMP $837B

	NOP #40

warnpc $02A4AE

org $02A4AE			; extended and cluster sprite hurt player
	ExClHurt:

org $02A4B5			; Hitting an extended and cluster sprite while player has star power.
	ExClStar:

org $02C7C4
	JSL SpriteEdgeTop
	BCC +			; chuck wins
	BRA ++
	NOP
	++

org $02C810			; deletes check for yoshi in chuck interaction
	BRA +
	NOP #3
	+

org $02F9F5			; deletes check for yoshi in sumo bros flames; potentially normal extended and cluster sprites too?
	BRA +
	NOP #3
	+

org $02F9FF			; deletes JMP to yoshi -> extended sprites interaction
	db $FF,$FF,$FF

org $03959A
	JSL SpriteEdgeTop
	BCC +			; rex wins

org $0395CA
	+

org $0395CD			; deletes check for yoshi in rex interaction
	BRA +
	NOP #3
	+

org $03B672
	JSL RidingYoshiClippingWith