!rect_layout = 1		; If set to 0, the giant block uses a linear layout, otherwise a rectangular one
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

Return:
MarioAbove:
MarioSide:
Fireball:
MarioCorner:
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
	PHY
	PHX
	REP #$20
if !rect_layout || !invisible_block
	STZ $00
	LDA $03
	LSR
	BCC +
	LDA $9A
	SEC : SBC #$0010
	STA $9A
+
	if !invisible_block
		LDA $98
		SEC : SBC #$0010
		STA $98
	else
		LDA $03
		AND	#$0010
		BEQ +
		LDA $98
		SEC : SBC #$0010
		STA $98
	+
	endif
else
	LDA $03
	AND #$0003
	ASL
	TAX
	LDA $9A
	SEC : SBC X_offset,x
	STA $9A
	LDA $98
	SEC : SBC Y_offset,x
	STA $98
endif
	SEP #$20

	LDA #!SoundEffect
	STA !APUPort

if !shake_timer != 0
	LDA #!shake_timer
	STA $1887|!addr
endif

	REP #$30
	LDA $9A
	PHA
	LDA $98
	PHA
	STA $98
	LDX.w #!Map16
	JSR ChangeBlock
	PLA
	STA $98
	PLA
	STA $9A
	SEP #$30

if !item_memory_dependent
	%set_item_memory()
endif
	
	JSR SpawnThing

	PLX
	PLY
RTL

ChangeBlock:
	LDY #$0006
.Loop:
	PHX
	%change_map16()
	%swap_XY()
if !rect_layout
	PLA
	CLC : ADC Map16Offset-2,y
	TAX
else
	PLX
	INX
endif
	LDA $9A
	CLC : ADC X_placement-2,y
	STA $9A
	LDA $98
	CLC : ADC Y_placement-2,y
	STA $98
	DEY #2
	BPL .Loop
RTS

X_placement:
dw $0010,$FFF0,$0010

Y_placement:
dw $0000,$0010,$0000

if !rect_layout
Map16Offset:
dw $0001,$000F,$0001
endif

if not(!rect_layout) && not(!invisible_block)
X_offset:
dw $0000,$0010,$0000,$0010

Y_offset:
dw $0000,$0000,$0010,$0010
endif
