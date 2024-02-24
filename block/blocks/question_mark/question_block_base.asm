!boop_speed = $00		; If set to non-zero, the player boops downwards when carrying
						; a shell underwater similar to SMM2.
!allow_offscreen = 0	; By default, partially on-screen blocks can't be activated.
						; Naturally, since this is a custom block, you're free to
						; keep this behaviour or disable it.
!allow_duplication = 1	; By default, custom blocks are immune to block duplication
						; But it is possible to still enable them if you recreate
						; the code which handles interaction with ?-blocks.

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead
JMP WallRun : JMP WallFeet

if !activate_per_spin_jump && not(!invisible_block)
MarioCorner:
MarioAbove:
	LDA $140D|!addr
	BEQ Return
	LDA $7D
	BMI Return
	LDA #$D0
	STA $7D
	BRA Cape
else
MarioCorner:
MarioAbove:
endif

Return:
MarioSide:
Fireball:
MarioInside:
MarioHead:
WallRun:
WallFeet:

if !invisible_block
SpriteH:
SpriteV:
Cape:
RTL


MarioBelow:
	LDA $7D
	BPL Return
if !boop_speed
	LDA $75
	ORA $1470|!addr
	ORA $148F|!addr
	BEQ .NoBoop
	LDA #!boop_speed
	STA $7D
.NoBoop
endif
else
RTL

SpriteV:
	LDA !14C8,x
	SEC : SBC #$09
	CMP #$02
	BCS Return
	LDA !AA,x
	BPL Return
	LDA !1588,x
	AND #$03
	BNE Return
	LDA #$08
if !allow_duplication
	STA !1FE2,x
	; This code is janky because it doesn't fully replicate
	; the interaction points. This dissonance causes the
	; game to duplicate blocks if you manage to kick a
	; shell at a block when their tops are touching each
	; other.
	LDA !E4,x
	CLC : ADC #$08
	STA $9A
	LDA !14E0,x
	ADC #$00
	STA $9B
	LDA !D8,x
	AND #$F0
	STA $98
	LDA !14D4,x
	STA $99
BRA BlockMain
else
BRA SpriteShared
endif

SpriteH:
	LDA !15A0,x
	BNE Return
	LDA !E4,x
	SEC : SBC $1A
	CLC : ADC #$14
	CMP #$1C
	BCC Return
	%check_sprite_kicked_horiz_alt()
	BCC Return
	LDA #$05

SpriteShared:
	STA !1FE2,x
	%sprite_block_position()
if !boop_speed
	BRA BlockMain
endif

MarioBelow:
if !boop_speed
	LDA $75
	ORA $1470|!addr
	ORA $148F|!addr
	BEQ .NoBoop
	LDA #!boop_speed
	STA $7D
.NoBoop
endif
Cape:
endif

BlockMain:
	PHX
	PHY
if !bounce_num
	if !bounce_block == $FF
		LDA #!bounce_tile
		STA $02
		LDA.b #!bounce_Map16
		STA $03
		LDA.b #!bounce_Map16>>8
		STA $04
	endif
	LDA #!bounce_num
	LDX #!bounce_block
	LDY #!bounce_direction
	%spawn_bounce_sprite()
	LDA #!bounce_properties
	STA $1901|!addr,y
else
	REP #$10
	LDX #!bounce_Map16
	%change_map16()
	SEP #$10
endif

if !item_memory_dependent
	%set_item_memory()
endif

if !SoundEffect
	LDA #!SoundEffect
	STA !APUPort
endif

	JSR SpawnThing

	PLY
	PLX
RTL
