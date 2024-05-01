;Slow Horizontal Layer 2 (BG) Scrolling Rate by lolcats439
;Enables slow bg scrolling horizontally, like you can vertically
;To use this, you must modify the tables below, inserting the value $03 where you want one of the 16 options to have a slow moving bg

	!bank	= $800000
if read1($00FFD5) == $23
	sa1rom
	!bank	= $000000
endif


;For convenience, I included the vertical/horizontal tables in this patch, so you can just change the values here.
;Each byte is the vertical/horizontal scroll setting for each of the scroll options
;found in LM's Modify Other Properties window. The last 4 bytes (previously 8, before LM3.0) in each table are unused, add new combinations there.
;I added $03, $03 (H-Scroll: Slow, V-Scroll: Slow) as the 13th option already. You can then select it in LM for use in a level.

org $05D710|!bank
;vertical scroll settings table
db $03,$01,$01,$00,$00,$02,$02,$01
db $04,$05,$06,$07,$03,$00,$00,$00

;horizontal scroll settings table
db $02,$02,$01,$00,$01,$02,$01,$00
db $02,$02,$02,$02,$03,$00,$00,$00


org $00F7A5|!bank
autoclean JSL Scroll
freedata


Scroll:
BEQ IsZero      ;\ restore old code
LSR             ;|
DEY             ;/
BEQ IsZero      ;\ This is the same thing the slow vertical scroll code does
LSR             ;|
LSR             ;|
LSR             ;|
LSR             ;|
IsZero:         ;|
STA $1E         ;/
RTL