!SprNum = $BA		;number of sprite portion of mushroom block
!LimitPickup = 0	;if 1, block cannot be picked up when a mushroom sprite is active on screen. attempts to avoid glitches with multiple mushroom block sprite portions in the same place.

!FreeRAM = $0F64|!addr	;One byte of free RAM used to determine if block can be picked or not. Make sure it's the same address in the sprite portion.

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
LDA #$0B
STA !14C8,x

LDA #$01
STA $1470|!addr
PLX

%erase_block()

return:
RTL

print "A solid mushroom block that can be picked up. Requires the sprite portion."