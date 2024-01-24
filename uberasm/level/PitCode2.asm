;Bottomless Pit Code by Blind Devil (based off of old patch by Ramp202)
;Also previously known as 'Floor Generator', this makes it so the player cannot
;move horizontally when offscreen from below, which is useful for people wanting
;to prevent people from skipping parts of a level from below. You can also set it
;to hurt or kill the player.

;Configurable defines:
;HURT/KILL EFFECT
;This determines what should happen to the player when they go offscreen from
;below.
;Possible values: 0 = nothing happens, 1 = hurt player, 2 = kill player.
!PitEffect = 2

init:                         ; Code to be inserted INIT
   	REP #$20                  ;\  16 bit mode
   	LDA #$0000                ; | 
   	STA $4330                 ; | 
   	LDA #.BrightTable         ; | load high and low byte of table address
   	STA $4332                 ; | 
   	SEP #$20                  ; | back to 8 bit mode
   	LDA.b #.BrightTable>>16   ; | load bank byte of table address
   	STA $4334                 ; | 
   	LDA #$08                  ; | 
   	TSB $0D9F|!addr           ; | enable HDMA channel 3
   	RTL                       ;/  

.BrightTable:                 ; 
   db $80 : db $09            ; 
   db $80 : db $09            ; 
   db $00                     ; 



main:
REP #$20		;16-bit A
LDA $80			;load player's Y-pos within the screen
BMI .ret16		;if negative (offscreen from above), do nothing.
CMP #$00F0		;compare to value
BCC .ret16		;if lower, do nothing.
SEP #$20		;8-bit A

STZ $7B			;reset player's X speed.

if !PitEffect == 1
JSL $00F5B7|!bank	;call hurt player subroutine
endif
if !PitEffect == 2
LDA $71			;load player animation pointer
BNE .ret		;if not equal zero, return.
JSL $00F606|!bank	;call kill player subroutine
endif

.ret16
SEP #$20		;8-bit A
.ret
RTL			;return.

