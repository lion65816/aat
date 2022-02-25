;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The Ultimate Mario extended tile editor
;
;by Ladida
;
;With this patch, you can edit Mario's 8x8
;tiles . It is mainly ROM map code, all documented
;and compiled into one easy-to-edit patch.
;
;No freespace needed
;Give credit if you feel nice :)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;20,22
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

header
lorom

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mario 8x8 tiles tilemap
;
;Format:
;(Note = These tiles all use GFX 00)
;1st byte = Head [16x16]
;2nd byte = Body [16x16]
;3rd byte = Extended tile 1 [8x8]
;4th byte = Extended tile 2 [8x8] Is placed below extended tile 1
;
;(xx-yy) is the values for the tilemapping data
;
;$80 denotes a blank tile, though I think
;anything from 80-FF can be used as a blank tile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $00DFDA

db $00,$02,$80,$80	;nothing			(00-03)
db $00,$02,$0C,$80	;running fullspeed		(04-07)
db $00,$02,$1A,$1B	;jumping full speed/flying	(08-0B)
db $00,$02,$0D,$80	;wall-running			(0C-0F)
db $00,$02,$80,$80	;swimming 1			(10-13)
db $00,$02,$80,$80	;swimming 2			(14-17)
db $00,$02,$0A,$0B	;swimming 3			(18-1B)
db $00,$02,$80,$80	;hitting wall behind		(1C-1F)
db $00,$02,$80,$80	;hitting wall infront		(20-23)
db $00,$02,$7E,$80	;punching Yoshi			(24-27)

;Big Mario Balloon:
;Head, Right body, Left body, unused

db $00,$02,$02,$80	;  		    [all 16x16]	(28-2B)

;The below values are for the cape

db $04			;Cape		      [16x16]	(2C)
db $7F,$4A,$5B,$4B,$5A	;Cape gliding stuff  [all 8x8]	(2D-31)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Notes for 8x8 tilemapping data shown
;below ($00D1FA):
;
;00 = nothing
;04 = Small hand when running
;08 = Hands & feet when taking off
;0C = Wall-running hand
;10 = Swimming 1 feet
;14 = Swimming 2 feet
;18 = Swimming 3 feet
;1C = Hitting wall behind fence
;20 = Hitting wall in front of fence
;24 = Punching Yoshi
;28 = Big Mario Balloon
;
;You can use values other than these,	      ^
;but you will need to edit the above section  |
;The highest value you can use is 2E, lowest is 00
;
;With this, you can change which poses use which 8x8 tiles,
;depending on Mario's tileset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $00DF1A

;Small Mario

db $00,$00,$00,$00,$00,$00,$00,$00	;1
db $00,$00,$00,$00,$00,$00,$00,$00	;2
db $00,$00,$00,$00,$00,$00,$00,$00	;3
db $00,$00,$00,$00,$00,$00,$00,$00	;4
db $00,$00,$00,$00,$00,$00,$00,$00	;5
db $00,$00,$00,$00,$00,$00,$00,$00	;6
db $00,$00,$00,$00,$00,$00,$00,$00	;7
db $00,$00,$00,$00,$00			;8

;Other

db $00,$00,$00,$00,$00,$00,$28,$00	;9
db $00					;10

;Big Mario

db $00,$00,$00,$00,$04,$04,$04,$00	;1
db $00,$00,$00,$00,$08,$00,$00,$00	;2
db $00,$0C,$0C,$0C,$00,$00,$10,$10	;3
db $14,$14,$18,$18,$00,$00,$1C,$00	;4
db $00,$00,$00,$20,$00,$00,$00,$00	;5
db $24,$00,$00,$00,$00,$00,$00,$00	;6
db $00,$00,$00,$00,$00,$00,$00,$00	;7
db $00,$00,$00,$00,$00			;8

;Cape Mario

db $00,$00,$00,$00,$04,$04,$04,$00	;1
db $00,$00,$00,$00,$08,$00,$00,$00	;2
db $00,$0C,$0C,$0C,$00,$00,$10,$10	;3
db $14,$14,$18,$18,$00,$00,$1C,$00	;4
db $00,$00,$00,$20,$00,$00,$00,$00	;5
db $24,$00,$00,$00,$00,$00,$00,$00	;6
db $00,$00,$00,$00,$00,$00,$00,$00	;7
db $00,$00,$00,$00,$00			;8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For Above:
;
;1 - Walking 1/Standing, Walking 2, Walking 3, Looking Up, Running 1, Running 2, Running 3, Carrying Item 1
;
;2 - Carrying Item 2, Carrying Item 3, Looking Up with Item, Jumping, Flying/Taking Off, Skidding, Kicking Item, Going Down Pipe/Turning with Item
;
;3 - About to Run Up Wall, Running Up Wall 1, Running Up Wall 2, Running Up Wall 3, Posing on Yoshi, Climbing, Swimming 1, Swimming with Item 1
;
;4 - Swimming 2, Swimming with Item 2, Swimming 3, Swimming with Item 3, Sliding Downhill, Ducking with Item/Ducking on Yoshi, Punching net, Net Turning 1
;
;5 - Riding Yoshi/Net Turning 2, Turning on Yoshi/Net Turning 3, Climbing Behind, Punching Net Behind, Falling, Spinjump Back (Small Mario)/Brushing 1, Posing, About to use Yoshi Tongue
;
;6 - Use Yoshi Tongue, Unused, Gliding 1, Gliding 2, Gliding 3, Gliding 4, Gliding 5, Gliding 6
;
;7 - Burned (Open eyes), Burned (Closed eyes), Looking at Castle, Looking at Flying Castle 1, Looking at Flying Castle 2, Lean Back with Hammer, Hammer in Mid-Air, Smash Hammer
;
;8 - Brushing 3, Brushing 2, Smash Hammer Again (?), Unused (?), Ducking
;
;9 - Growing/shrinking, Dying, Throwing fireball, Unused (?), Unused (?), Balloon small, Balloon big, Spinjump back
;
;10 - Spinjump front
;
;(Mainly copied the descriptions from Smallhacker's Player Tilemap Editor)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;