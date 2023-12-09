if read1($00FFD5) == $23		; check if the rom is sa-1
	sa1rom
	!SA1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!bankA = $400000
else
	lorom
	!SA1 = 0
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!bankA = $7E0000
endif

; Exact Horizontal Scroll Disable by AmazingChest

; Disables horizontal scrolling at an exact position.

; Place this block 9 tiles left of where you want the right edge of the screen to stop when
; the player is moving to the right, and place it 8 tiles right of where you want the left
; edge of the screen to stop when the player is moving to the left.

; Avoid placing scroll disable blocks and scroll enable blocks next to each other. This will
; create visual stuttering when the player moves between them. Place them exactly 1 tile apart
; for best results.

; This block assumes that you are NOT using a custom camera patch that changes Mario's
; position on screen, for example one that centers him. If you are, this will not work properly.

; If you place this block where the player can fall below the screen it is possible
; that the player can move underneath it and not activate it. To fix this, apply the
; "Level Constrain v3.4" patch by HammerBrother: https://smwc.me/s/24700

; For a block to enable screen scrolling, use the one from "Enable/Disable Horizontal Scroll"
; by Apollyon: https://smwc.me/s/3860

; Act as 25

db $42
JMP Scroll : JMP Scroll : JMP Scroll : JMP Return : JMP Return : JMP Return : JMP Return
JMP Scroll : JMP Scroll : JMP Scroll

Scroll:
LDA $1411|!addr                       ;\ Abort if scroll is already disabled
BEQ Return                      ;/

LDA $17BD|!addr                       ; Determine if the camera (layer 1) is moving left or right
BEQ Return                      ; Abort if the camera isn't moving
BPL .scrollingRight

REP #$20
ORA #$FF00                      ; Convert left movement of camera to negative 16-bit value
CLC : ADC $001A|!dp                 ;\ Add current camera position to create predicted camera
STA $00                         ;/ position next frame and store to scratch RAM
LDA $009A|!dp                       ;\ Get desired camera stopping position from the position
AND #$FFF0                      ;| of this block minus 8 tiles (to left edge of screen)
SEC : SBC #$0080                ;/
CMP $00                         ;\ Abort if desired camera position is less than or equal
BEQ Return                      ;| to predicted camera position
BCC Return                      ;/
BRA StopScroll

.scrollingRight
REP #$20
AND #$00FF                      ; Convert right movement of camera to positive 16-bit value
CLC : ADC $001A|!dp                 ;\ Add current camera position to create predicted camera
STA $00                         ;/ position next frame and store to scratch RAM
LDA $009A|!dp                       ;\ Get desired camera stopping position from the position
AND #$FFF0                      ;| of this block minus 7 tiles (to left edge of screen)
SEC : SBC #$0070                ;/
CMP $00                         ;\ Abort if desired camera position is greater than or equal
BCS Return                      ;/ to predicted camera position

StopScroll:
STA $1462|!addr                       ;\ Store desired camera position to next frame's layer 1
SEP #$20                        ;/ position
STZ $1411|!addr                       ; Disable horizontal scrolling

Return:
SEP #$20
RTL

print "Disables horizontal scrolling at an exact position."