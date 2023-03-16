;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;											;;
;;	    No-Yoshi Intro Block by Anas		;;
;; Original code by Zeldara109, adapted to	;; 
;;    account for 'mounting off Yoshi'		;;
;;				animation					;;
;;											;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;											;;
;; 			IMPORTANT CONDITIONS			;;
;;											;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; First of all, it is VERY IMPORTANT to disable the vanilla no-Yoshi intro via the 
; 'Change Other Properties' dialog, otherwise the game will show the regular vanilla intro level!

; Second of all, place the block right over the player.

; The tileset must be set to 0x01 via the 'Change Index of Graphics' dialog for a castle door, 
; otherwise you get a ghost house door. For the no-Yoshi sign, you must set the tileset to 0x02.

; Via the 'Change Properties in Header' dialog, set the screen scrolling to 'No Vertical or Horizontal Scroll'.

; If using the castle/ghost house door, the tiles directly to the right for both types of doors 
; (and for the castle door, above it) should have layer priority, but the tiles to the left should not. 
; You may either use extended object 0x80 or 0x84 or make your own Map16 tiles for this purpose.

; Set SP4=0F for the castle/ghost house door and no-Yoshi sign sprite to have the proper vanilla graphics.  
; Otherwise, you may use your own custom graphics for it.

; In screen 0, set Mario's initial position to X=3, Y=17 for the castle/ghost house door or X=3, Y=16 
; for the no-Yoshi sign via the 'Modify Main and Midway Entrance' dialog. 

; Set the screen exits of both screen 0 (for if the player skips the animation) and screen 1 
; (for if the player waits out the animation) to the next level.

; Set the intro level's time limit to 0 and force the next level's time limit to reset upon entering it 
; every time by checking the 'Force the time limit to reset to this value every time the player enters this level' 
; box in the 'Change Music and Time Limit Settings' dialog. To avoid the level's timer from resetting 
; by entering it from a sublevel, make a duplicate of the level without the 'Force the time limit...' box
; checked and make the sublevel lead there instead.

; To properly filter Yoshi at the checkpoint, you must open the 'Modify Main and Midway Entrance' dialog in the 
; intro level and check the 'Redirect Midway Entrance to other level' box. In the 'Level of Midway Entrance' text
; box, enter the level number of the level the intro level leads to. Then in that level, adjust the midway entrance to
; your liking. Once you're done, apply this UberASM code to it: https://www.smwcentral.net/?p=section&a=details&id=29033
; If for some reason you want the intro to play at the checkpoint, simply redirect the midway entrance to a replica
; of the intro level which leads to your desired place. You won't need the UberASM code for this purpose.

db $42 
JMP NYI : JMP NYI : JMP NYI
JMP Ret : JMP Ret : JMP Ret : JMP Ret
JMP NYI : JMP NYI : JMP NYI

NYI:
INC $141A|!addr       ; increment screen-exits-taken counter, to fix a bug where the intro infinitely reloads itself
LDA #$0A        ;\ set player animation to castle entrance movements
STA $71         ;/
LDA #$01        ;\ initialize castle intro movement timer
STA $89         ;/
LDA $187A|!addr ; if riding Yoshi...
BNE +

Ret:
RTL

+
;LDA #$0F ; execute 'mounting off Yoshi' animation
;STA $88
RTL