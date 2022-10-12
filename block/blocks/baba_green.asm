;> PSI Ninja edit: The base code is from MushBlk.asm. Changed the sprite number, pickup limit, and FreeRAM address. Added "BlockSet" flag.
;>                 To save global sprite slot space, added extra byte information to distinguish the different type of sprite to be generated.

!SprNum = $B9		;number of sprite portion of mushroom block
!SprType = $04		;> PSI Ninja edit: Extra byte value.
!LimitPickup = 1	;if 1, block cannot be picked up when a mushroom sprite is active on screen. attempts to avoid glitches with multiple mushroom block sprite portions in the same place.

!FreeRAM = $140B|!addr	;One byte of free RAM used to determine if block can be picked or not. Make sure it's the same address in the sprite portion.
!BlockSet = $140C|!addr	;> PSI Ninja edit: FreeRAM flag to tell us once a block has been set by the player.

db $37

JMP return : JMP Main : JMP return : JMP return : JMP return : JMP return : JMP return
JMP return : JMP return : JMP return
JMP return : JMP return

Main:
if !LimitPickup
	LDA !FreeRAM
	BNE return
endif

BIT $16
BVC return
JSL $02A9DE|!bank
BMI return

PHX
LDA #!SprNum
SEC
%spawn_sprite()
TAX

LDA #$08
STA !7FAB10,x
LDA #!SprType		;\ PSI Ninja edit: Generate a different sprite based on the extra byte value.
STA !extra_byte_1,x	;/
LDA #$0B
STA !14C8,x

LDA #$01
STA $1470|!addr
PLX

%erase_block()

LDA #$01
STA !BlockSet

return:
RTL

print "A GREEN block that can be picked up. Requires the sprite portion."
