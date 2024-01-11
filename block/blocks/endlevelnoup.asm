;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;end level block 2
;by Iceguy
;act like tile 25
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "A block that ends the level."

db $42
JMP Main : JMP Main : JMP Main : JMP return : JMP return : JMP return : JMP return
JMP Main : JMP Main : JMP Main

Main:
LDA #$FF	;freeze
STA $9D		;all sprites on screen....
LDA #$FF	;course clear
STA $1493|!addr	;mode
LDA #$04	;type 0C for other music        
STA $1DFB|!addr       ;
DEC $13C6|!addr	;prevent mario from walking

return:
RTL    		;do nothing on sprite/fireball/cape contact  



