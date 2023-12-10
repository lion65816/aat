;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SA-1 handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Only include this if there is no SA-1 detection, such as including this
;in a (seperate) patch.
if defined("!sa1") == 0
	!dp = $0000
	!addr = $0000
	!sa1 = 0
	!gsu = 0

	if read1($00FFD6) == $15
		sfxrom
		!dp = $6000
		!addr = !dp
		!gsu = 1
	elseif read1($00FFD5) == $23
		sa1rom
		!dp = $3000
		!addr = $6000
		!sa1 = 1
	endif
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Freeram
;
;Note: [Must be saved] indicates that you must have these RAM not to
;be reset throughout the entire game other than starting a new file,
;they must retain their values.
;
;You should also be very careful to prevent things that would get the
;player permanently stuck. Example is that locked doors/gate respawning
;while the keys don't, making it possible to run out of keys while
;progressing the stages.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Note: $ indicates hex, this include the !Defines being set to a value
;and the formula explaining how much bytes they use.
;
 if !sa1 == 0
  !Freeram_MemoryFlag = $7FAD49
 else
  !Freeram_MemoryFlag = $4001B9
 endif
 ;^[BytesUsed = NumberOfGroups*$10] [Must be saved] a table containing an array of
 ; "global memory" flags. NumberOfGroups is how many groups of 128 bit flags
 ; you want in your hack, up to 16. For example:
 ;
 ; One level uses all 128 bits on !Freeram_MemoryFlag to !Freeram_MemoryFlag+$0F
 ; Another level also uses 128 bits !Freeram_MemoryFlag+$10 to !Freeram_MemoryFlag+$1F
 ;
 ; This means 2 groups of 128-bits would result the formula [32 = 2 * $10] (32 bytes),
 ; Therefore the range of !Freeram_MemoryFlag is !Freeram_MemoryFlag+$0 to
 ; !Freeram_MemoryFlag+$1F (default example: $7FAD49 to $7FAD68)
 ;
 ; You can also make multiple levels use the same group-128 if any of the level
 ; sharing this uses less than 128 flags to save memory and not have "gaps".
 ;
 ; I would highly recommend make a note in a txt file listing the RAM flag areas
 ; so you can keep track of the flags and where they are, made-up example:
 ;
 ; !Freeram_MemoryFlag+$00 to !Freeram_MemoryFlag+$0F: used in level $105, $106 ($105: 0-63, $106: 64-127)
 ; !Freeram_MemoryFlag+$10 to !Freeram_MemoryFlag+$1F: used in level $107, $102, $103 ($107: 0-49, $102: 50-100, $103: 101-127)
 if !sa1 == 0
  !Freeram_KeyCounter = $7FAD79
 else
  !Freeram_KeyCounter = $4001E9
 endif
 ;^[BytesUsed = How_Many_local_key_counters_you_want] [Must be saved] How many keys the player have. Note that this is stored as a table
 ; with each byte being their own separate key counter local to the level(s) they are associated with. This is to prevent
 ; the player from taking the key they got from one area, exit to the map, go to another "main level"* and use that key on the completely
 ; different level. This is similar to how modern Legend of Zelda's dungeon keys to only be usable in the dungeon you found them.
 ;
 ;*Main level, as in all the levels accessible from the level entered from the map, in case if your dungeon spans multiple levels.
 ;
 ; Here is how the memory works (made-up example):
 ; !Freeram_KeyCounter+$00: $0105, $01CB
 ; !Freeram_KeyCounter+$01: $0106, $01CA
 ; !Freeram_KeyCounter+$02: $0103, $01FD
 ; [...]
 ;
 ; So levels are given what key counter they should use, if you don't have keys matching to the locked gates/doors, it won't open.
 ;
 ; Note: Up to 99 keys can be picked up at any time, if you have 99 (or more, just in case), the player will simply not pick it up (handled
 ; by the blocks).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Custom blocks:
 ;Collectible key:
  !Settings_MBCM16_KeyHitboxSize = 0
   ;^hitbox size:
   ; 0 = Full 16x16 block
   ; 1 = 16x16 Sprite-styled hitbox (actually its hitbox is 12x10, used by
   ;     most powerup sprites).
  
   ;What sound to play with picking up the key.
    !Settings_MBCM16_Key_SoundRAM = $1DFC|!addr
    !Settings_MBCM16_Key_SoundNum = $00
 
 ;Locked Gates:
  ;Require the player to press on the D-Pad towards the block (press right
  ;when standing on the left side of the block, down when on top, up when
  ;under, and left when on right) to unlock. This is intended to prevent
  ;the player from accidentally unlocking the gates when they don't want to.
  ;This also enables the player to stand on top of key locked gates instead
  ;of falling through them (however, you cannot crouch).
   !Settings_MBCM16_RequireDPadPress = 1
    ;^0 = unlock on touch, 1 = Require pressing towards the block to unlock.
  
  ;What sound to play when unlocking a gate:
   !Settings_MBCM16_LockedGate_SoundRAM = $1DF9|!addr
   !Settings_MBCM16_LockedGate_SoundNum = $00
  
  !Settings_MBCM16_LockedGate_GenerateSmoke = 0
   ;^Generate smoke: 0 = no, 1 = yes.
  ;Tiles to turn into when unlocking gates. Note that if you want it to transform into a non tile-$25,
  ;you would checked the "Always show objects", and the tile numbers they transform into is their own
  ;tile number plus (or minus if you decided to make it clear the CM16 flags) $0100.
   ;16x16 block:
    !Settings_MBCM16_LockedGate_16x16_TileToTurnTo = $0025
   ;16x32 block:
    !Settings_MBCM16_LockedGate_16x32_Top_TileToTurnTo = $0025
    !Settings_MBCM16_LockedGate_16x32_Bottom_TileToTurnTo = $0025
   ;16x48 block:
    !Settings_MBCM16_LockedGate_16x48_Top_TileToTurnTo = $0025
    !Settings_MBCM16_LockedGate_16x48_Middle_TileToTurnTo = $0025
    !Settings_MBCM16_LockedGate_16x48_Bottom_TileToTurnTo = $0025
   ;32x16 block:
    !Settings_MBCM16_LockedGate_32x16_Left_TileToTurnTo = $0025
    !Settings_MBCM16_LockedGate_32x16_Right_TileToTurnTo = $0025
   ;48x16 block:
    !Settings_MBCM16_LockedGate_48x16_Left_TileToTurnTo = $0025
    !Settings_MBCM16_LockedGate_48x16_Middle_TileToTurnTo = $0025
    !Settings_MBCM16_LockedGate_48x16_Right_TileToTurnTo = $0025
   ;32x32 block:
    !Settings_MBCM16_LockedGate_32x32_TopLeft = $0025
    !Settings_MBCM16_LockedGate_32x32_TopRight = $0025
    !Settings_MBCM16_LockedGate_32x32_BottomLeft = $0025
    !Settings_MBCM16_LockedGate_32x32_BottomRight = $0025
;HUD stuff:
 !EditTileProps = 0
  ;^0 = no (use if you are using SMW's vanilla status bar).
  ; 1 = yes.
 !StatusBarFormat = $01
  ;^Number of grouped bytes per 8x8 tile for the status bar (not the overworld border):
  ; $01 = each 8x8 tile have two bytes each separated into "tile numbers" and "tile properties" group;
  ;       Minimalist/SMB3 [TTTTTTTT, TTTTTTTT]...[YXPCCCTT, YXPCCCTT] or SMW's default ([TTTTTTTT] only).
  ; $02 = each 8x8 tile byte have two bytes located next to each other;
  ;       Super status bar/Overworld border plus [TTTTTTTT YXPCCCTT, TTTTTTTT YXPCCCTT]...
 ;Status bar position:
  if !sa1 == 0
   !Settings_MBCM16_KeyCounterTileNumbPos = $7FA132
   !Settings_MBCM16_KeyCounterTilePropPos = $7FA133
  else
   !Settings_MBCM16_KeyCounterTileNumbPos = $404132
   !Settings_MBCM16_KeyCounterTilePropPos = $404133
  endif
 ;Static tiles:
  !Settings_MBCM16_KeyCounterBlankTileNumb = $FC
  !Settings_MBCM16_KeyCounterBlankTileProp = %00111000
  !Settings_MBCM16_KeyCounterKeySymbolTileNumb = $4E
  !Settings_MBCM16_KeyCounterKeySymbolTileProp = %00111100
  !Settings_MBCM16_KeyCounterXSymbolTileNumb = $26
  !Settings_MBCM16_KeyCounterXSymbolTileProp = %00111000
  !Settings_MBCM16_KeyCounterDigitsTileProp = %00111000
  