macro include_once(target, base, offset)
	if !<base> != 1
		!<base> = 1
		pushpc
		if read3(<offset>*3+$0CB66F) != $FFFFFF
			<base> = read3(<offset>*3+$0CB66F)
		else
			freecode cleaned
			#<base>:
			incsrc <target>
			ORG <offset>*3+$0CB66F
			dl <base>
		endif
		pullpc
	endif
endmacro
!change_map16 = 0
macro change_map16()
	%include_once("routines/change_map16.asm", change_map16, $00)
	JSL change_map16
endmacro
!check_sprite_kicked_horizontal = 0
macro check_sprite_kicked_horizontal()
	%include_once("routines/check_sprite_kicked_horizontal.asm", check_sprite_kicked_horizontal, $01)
	JSL check_sprite_kicked_horizontal
endmacro
!check_sprite_kicked_vertical = 0
macro check_sprite_kicked_vertical()
	%include_once("routines/check_sprite_kicked_vertical.asm", check_sprite_kicked_vertical, $02)
	JSL check_sprite_kicked_vertical
endmacro
!create_smoke = 0
macro create_smoke()
	%include_once("routines/create_smoke.asm", create_smoke, $03)
	JSL create_smoke
endmacro
!erase_block = 0
macro erase_block()
	%include_once("routines/erase_block.asm", erase_block, $04)
	JSL erase_block
endmacro
!FaceYoshi = 0
macro FaceYoshi()
	%include_once("routines/FaceYoshi.asm", FaceYoshi, $05)
	JSL FaceYoshi
endmacro
!give_points = 0
macro give_points()
	%include_once("routines/give_points.asm", give_points, $06)
	JSL give_points
endmacro
!glitter = 0
macro glitter()
	%include_once("routines/glitter.asm", glitter, $07)
	JSL glitter
endmacro
!kill_sprite = 0
macro kill_sprite()
	%include_once("routines/kill_sprite.asm", kill_sprite, $08)
	JSL kill_sprite
endmacro
!layer2_sprite_position = 0
macro layer2_sprite_position()
	%include_once("routines/layer2_sprite_position.asm", layer2_sprite_position, $09)
	JSL layer2_sprite_position
endmacro
!move_spawn_above_block = 0
macro move_spawn_above_block()
	%include_once("routines/move_spawn_above_block.asm", move_spawn_above_block, $0A)
	JSL move_spawn_above_block
endmacro
!move_spawn_below_block = 0
macro move_spawn_below_block()
	%include_once("routines/move_spawn_below_block.asm", move_spawn_below_block, $0B)
	JSL move_spawn_below_block
endmacro
!move_spawn_into_block = 0
macro move_spawn_into_block()
	%include_once("routines/move_spawn_into_block.asm", move_spawn_into_block, $0C)
	JSL move_spawn_into_block
endmacro
!move_spawn_relative = 0
macro move_spawn_relative()
	%include_once("routines/move_spawn_relative.asm", move_spawn_relative, $0D)
	JSL move_spawn_relative
endmacro
!move_spawn_to_player = 0
macro move_spawn_to_player()
	%include_once("routines/move_spawn_to_player.asm", move_spawn_to_player, $0E)
	JSL move_spawn_to_player
endmacro
!move_spawn_to_sprite = 0
macro move_spawn_to_sprite()
	%include_once("routines/move_spawn_to_sprite.asm", move_spawn_to_sprite, $0F)
	JSL move_spawn_to_sprite
endmacro
!rainbow_shatter_block = 0
macro rainbow_shatter_block()
	%include_once("routines/rainbow_shatter_block.asm", rainbow_shatter_block, $10)
	JSL rainbow_shatter_block
endmacro
!reset_turn_block = 0
macro reset_turn_block()
	%include_once("routines/reset_turn_block.asm", reset_turn_block, $11)
	JSL reset_turn_block
endmacro
!shatter_block = 0
macro shatter_block()
	%include_once("routines/shatter_block.asm", shatter_block, $12)
	JSL shatter_block
endmacro
!spawn_bounce_sprite = 0
macro spawn_bounce_sprite()
	%include_once("routines/spawn_bounce_sprite.asm", spawn_bounce_sprite, $13)
	JSL spawn_bounce_sprite
endmacro
!spawn_item_sprite = 0
macro spawn_item_sprite()
	%include_once("routines/spawn_item_sprite.asm", spawn_item_sprite, $14)
	JSL spawn_item_sprite
endmacro
!spawn_sprite = 0
macro spawn_sprite()
	%include_once("routines/spawn_sprite.asm", spawn_sprite, $15)
	JSL spawn_sprite
endmacro
!spawn_sprite_block = 0
macro spawn_sprite_block()
	%include_once("routines/spawn_sprite_block.asm", spawn_sprite_block, $16)
	JSL spawn_sprite_block
endmacro
!sprite_block_position = 0
macro sprite_block_position()
	%include_once("routines/sprite_block_position.asm", sprite_block_position, $17)
	JSL sprite_block_position
endmacro
!SSPDragMarioMode = 0
macro SSPDragMarioMode()
	%include_once("routines/SSPDragMarioMode.asm", SSPDragMarioMode, $18)
	JSL SSPDragMarioMode
endmacro
!SSPReverseDirection = 0
macro SSPReverseDirection()
	%include_once("routines/SSPReverseDirection.asm", SSPReverseDirection, $19)
	JSL SSPReverseDirection
endmacro
!swap_XY = 0
macro swap_XY()
	%include_once("routines/swap_XY.asm", swap_XY, $1A)
	JSL swap_XY
endmacro
!teleport = 0
macro teleport()
	%include_once("routines/teleport.asm", teleport, $1B)
	JSL teleport
endmacro
