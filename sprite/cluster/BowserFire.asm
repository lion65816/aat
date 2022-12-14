!60fpsInteract = 0		; If set, Mario will interact with the fireball every frame. If clear, he will interact on alternating frames (the vanilla fireball does this).
						; Might be helpful with consistency in setups, but also increases the chance of lag on LoROM when several cluster fireballs are spawned.

Tiles:
db $48,$68,$66,$64

; --------------------

print "MAIN ",pc

PHB
PHK
PLB
JSR Main
PLB
RTL

; --------------------

Return:
RTS

Main:

JSR Graphics

LDA $9D
BNE Return

TYX								;/
PHY								;|
PEA.w $02|(Main>>16<<8)			;|
PLB								;| Update X position.
PEA.w .return-1					;|
PEA.w $F80E						;|
JML $02FF98|!BankB				;\
.return

; --------------------

if !60fpsInteract == 0
TXA					;/
CLC					;|
ADC $14				;| Alternating slots interact on alternating frames if set to do so.
AND #$01			;|
BNE End				;\
endif

LDA $0F72|!addr,x	;/
BEQ +				;|
DEC $0F72|!addr,x	;| Brief cooldown to reduce the chance of taking damage after spinjumping upwards.
PLY					;|
RTS					;\
+

LDA #$14			; This is almost the same as the vanilla cluster sprite interaction, but some of the clippings are changed.
STA $02				; This one also accounts for spinjumping and riding Yoshi, to closer replicate the statue fireball sprite.
STZ $03
LDA $1E16|!addr,x
STA $00
LDA $1E3E|!addr,x
STA $01
REP #$20
LDA $94
SEC
SBC $00
CLC
ADC #$000A
CMP $02
SEP #$20
BCS End
LDA $1E02|!addr,x
ADC #$03
STA $02
LDA $1E2A|!addr,x
ADC #$00
STA $03
REP #$20
LDA #$0010
LDY $19
BEQ +
LDA #$001C
+
STA $04
LDA $96
LDY $187A|!addr
BEQ +
CLC
ADC #$0010
+
SEC
SBC $02
CLC
ADC #$0020
CMP $04
SEP #$20
BCS End
LDA $187A|!addr
BNE Yoshi
LDA $7D
CMP #$10
BMI Hurt
LDA $140D|!addr
BNE Boost
Hurt:
JSL $00F5B7|!BankB
PLY
RTS
Yoshi:
LDA $7D
CMP #$10
BPL Boost
%LoseYoshi()
End:
PLY
RTS

Boost:
JSL $01AA33|!BankB
JSL $01AB99|!BankB
LDA #$02
STA $1DF9|!addr
STA $0F72|!addr,x
PLY
RTS

Graphics:

JSR GetOffsets			; Gets the tile offsets, and also acts as suboffscreen.

LDA $1E66|!addr,y		;/
ASL						;|
ROL						;| Set up the X flip depending on the direction.
AND #$01				;|
PHP						;\

TYX						;/ OAM index for cluster sprites.
LDA $02FF50|!BankB,x	;| Our ExGFX wastes a bit of space with 16x16 tiles for a 16x8 sprite, but in return we save a lot of processing time by not having to loop through
TAX						;\ OAM to find two free slots.

LDA $00					;/
STA $0300|!addr,x		;\ Tile X position.

LDA $02					;/
STA $0301|!addr,x		;\ Tile Y position.

PHX						;/
LDA $14					;|
LSR						;|
AND #$03				;|
TAX						;| Animate the flame.
LDA Tiles,x				;|
PLX						;|
STA $0302|!addr,x		;\

LDA #$09				;/
PLP						;|
BNE +					;|
LDA #$49				;| Flip the tile if going right (graphics face left by default).
+						;|
ORA $64					;|
STA $0303|!addr,x		;\

TXA						;/
LSR #2					;|
PHA						;|
LDA #$02				;| Handle X high bit.
LDX $01					;|
BEQ +					;|
INC						;|
+						;\
PLX
STA $0460|!addr,x
RTS

; --------------------

GetOffsets:

LDA $1E16|!addr,y
STA $00
LDA $1E3E|!addr,y
STA $01
LDA $1E02|!addr,y
STA $02
LDA $1E2A|!addr,y
STA $03

REP #$20				;/
LDA $00					;|
SEC						;|
SBC $1A					;|
STA $00					;| Like the vanilla statue fireball sprite, this gives the fireball an offscreen range of -$40 to +$30 before despawning.
CMP #$FFC0				;|
BCS +					;|
CMP #$0130				;|
BCS .Delete				;\
+

LDA $02					;/
SEC						;|
SBC $1C					;|
CMP #$FFF0				;|
BCS +					;| Since tile Y position doesn't have a high bit, we need to manually check if we should delete the fireball, or just skip drawing the tile.
CMP #$00F0				;|
BCS .OffScreenY			;|
+						;|
STA $02					;\ 

SEP #$20
RTS

.Delete
SEP #$20				;/
LDA #$00				;|
STA $1892|!addr,y		;|
PLA						;| Deletes the fireball and aborts the GFX routine. Used when the fireball has gone outside of it's despawn range.
PLA						;|
RTS						;\

.OffScreenY
CLC						;/
ADC #$00C0				;|
CMP #$0250				;|
BCS .Delete				;| Deletes the fireball if it's too far offscreen vertically.
PLA						;| I didn't look into the precise range since LM uses it's own checks for the exlevel system, but this range seems to approximate it well enough.
SEP #$20				;|
RTS						;\