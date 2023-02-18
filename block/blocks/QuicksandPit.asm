;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Quicksand (Pit)
; By Sonikku
; Description: 
; Almost exactly like Magus' quicksand block, except this is more customizable.
; This version makes it very hard for Mario to move left and right. 
; Customization:
; !Power is how hard it is to move while under the effect of the block. Change it 
; lower to make Mario's jump less effective, set it higher for an easier escape.
; !SpriteSink is how fast sprites go in the block. Set it lower for a slower fall, or set it higher
; so sprites fall faster. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "A quicksand block that makes Mario and sprites slowly sink but keeps Mario from walking at full speed."

db $42
JMP Main : JMP Main : JMP Main : JMP SpriteMain : JMP SpriteMain : JMP Return : JMP Return
JMP Main : JMP Return : JMP Return

!Power = $18
!SpriteSink = $04

Main:
LDA #$01	;
STA $1471|!addr	;What type of platform Mario is on.
LDA $7D		;Load Mario's Y-Speed
CLC		;
ADC #!Power	;Load how powerful Mario's jump is.
STA $7D		;Store Mario's Y-Speed
STZ $7B		;Prevent Mario from walking fast/running.
RTL		;Return
SpriteMain:
LDA #!SpriteSink	;How fast sprites sink.
STA !AA,x	;Set sinking effect for sprites.
STZ !B6,x
Return:
RTL		;Return