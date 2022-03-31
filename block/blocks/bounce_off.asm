;A block that makes sprites and mario bounce with customizable height. this interacts with Mario when on/off is off.
;act as 25 plz
;coded by dogemaster 

db $42
!Shouldmariobounce = 1 ;0 will make mario not bounce
!Shouldspritebounce = 1 ; 0 will not make sprites bounce
!MarioBounce = #$80     ;specifiable range is 80 to FF for both counters, remember that 80 is bigger than FF cuz hex counting system is shit     
!SpriteBounce = #$c0
!ONbounce = 1 ;1 makes the block not bounce mario when on/off status is on and 0 will make it permabounce mario

JMP Mario : JMP Mario : JMP Mario
JMP Sprite : JMP Sprite : JMP Return : JMP Return
JMP Mario : JMP Mario : JMP Mario

Sprite:
if !Shouldspritebounce
    LDA !D8,x          ;sprites reset their y speed when on ground so this snippet make the sprite rise by 2 pixels so y speed is changeable 
    SEC
    SBC #$02
    STA !D8,x
	
	LDA !14D4,x
	SBC #$00
	STA !14D4,x
 
    LDA !14C8,x                ; \ The address thingy that has the value if something is alive and other shit
    CMP #$08                ; | comparing to see if alive
    BCC Return        ; /  
    LDA !SpriteBounce
    STA !AA,x                ; /

endif
RTL
Mario:
if !Shouldmariobounce
if !ONbounce
	LDA $14AF|!addr
	BEQ Return
    LDA !MarioBounce
    STA $7D
	endif
endif
Return:
RTL

print "A block that bounces sprites and mario! Doesn't bounce mario when ON."