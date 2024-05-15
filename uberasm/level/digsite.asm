!SprSize = $16			;> Number of SA-1 sprite slots ($16 = 22).
!bank = $000000

!npc_x_high = $05
!npc_x_low = $80
!FreeRAM = $1908|!addr	;> Flag to only show Science's message once per level load.

LoadIris:
	db $C0,$00,$00,$DA,$A0,$00,$60,$F7,$20,$81,$40,$00
LoadDemo:
	db $C0,$00,$00,$DA,$A1,$00,$60,$E7,$20,$81,$40,$00

init:
	STZ !FreeRAM

	; Spawn the NPC sprite once the level starts.
	; Copied mostly from the PIXI %SpawnSprite2() routine.
	LDX #!SprSize-3		;> Skip the last two slots (otherwise, the tweaker properties may not work).
-
	LDA !14C8,x			;\ Find an open sprite slot.
	BEQ +				;| If none are found, then don't load the sprite.
	DEX					;|
	BPL -				;|
	BRA main			;/
+
	;LDA #$A4
	LDA #$28
	STA !9E,x
	JSL $07F7D2|!bank

	LDA !9E,x			;\ Store the sprite number to the custom sprite number table.
	STA !7FAB9E,x		;/

	JSL $0187A7|!bank

	LDA #$08			;\ Indicate that this is a custom sprite.
	STA !7FAB10,x		;/
	LDA #$01			;\ Initialize sprite
	STA !14C8,x			;/
	LDA #!npc_x_low		;\ X position
	STA.w !E4,x			;|
	LDA #!npc_x_high	;|
	STA !14E0,x			;/
	LDA #$70			;\ Y position
	STA.w !D8,x			;|
	LDA #$01			;|
	STA !14D4,x			;/
	STZ.w !B6,x			;\ No X or Y speed
	STZ.w !AA,x			;/

	; If Demo, then load Iris NPC. If Iris, then load Demo NPC.
	; Source: https://smwc.me/1587681 (spawning a custom sprite with 12 extra bytes)
	LDA $0DB3|!addr
	BNE +
	LDA.b #LoadIris
	STA !extra_byte_1,x
	LDA.b #LoadIris>>8
	STA !extra_byte_2,x
	LDA.b #LoadIris>>16
	STA !extra_byte_3,x
	BRA main
+
	LDA.b #LoadDemo
	STA !extra_byte_1,x
	LDA.b #LoadDemo>>8
	STA !extra_byte_2,x
	LDA.b #LoadDemo>>16
	STA !extra_byte_3,x
main:
	LDX #!SprSize-3		;> Skip the last two slots (otherwise, the tweaker properties may not work).
-
	LDA !9E,x			;\ Check if the sprite is a key (resprited as Science).
	CMP #$80			;|
	BNE +				;/
	LDA !15F6,x			;\ Change Science's palette (use row C instead of 8).
	ORA #$08			;|
	STA !15F6,x			;/
	LDA !14C8,x			;\ Show Science's message when carried,
	CMP #$0B			;| once per level load.
	BNE +				;|
	LDA !FreeRAM		;|
	BNE +				;|
	LDA #$01			;|
	STA $1426|!addr		;|
	STA !FreeRAM		;/
+
	DEX
	BPL -

	LDX #!SprSize-1
-
	LDA !9E,x			;\ Check if the sprite is a Green Goopa (in this case, a Green Shell).
	CMP #$04			;|
	BNE +				;/
	LDA !167A,x			;\ Modify fourth tweaker byte to process while off screen
	ORA #$04			;| (i.e., the shell won't despawn).
	STA !167A,x			;/
+
	DEX
	BPL -

	RTL
