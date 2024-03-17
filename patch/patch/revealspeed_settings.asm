;RECOMMENDED SPEED VALUES
;	EVENT PATH FADE ENABLED: $01 (forest of illusion), $02, $04, $08 (regular speed).
;	other values may cause visual glitches. don't try to make it faster with that setting.
;	EVENT PATH FADE DISABLED (via Overworld -> Extra Options in Lunar Magic): $00-$07 (speeds 0-7), $09 (8), $0A (9), $0C (A), $0F (B), $1F (C), $3F (D - fast).

;DEFAULT SPEED
;	NOTE: if you disabled the event path fade, Lunar Magic's speed setting will be the default speed. this will do nothing!
!DefaultSpeed = $08

;CUSTOM EVENT SPEED TABLE
;	$FF = default speed will be used.

EventTable:
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 00-07
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 08-0F
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 10-17
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 18-1F
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 20-27
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 28-2F
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 30-37
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 38-3F
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 40-47
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 48-4F
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 50-57
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 58-5F
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 60-67
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 68-6F
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF		;events 70-77