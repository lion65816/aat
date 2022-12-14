;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      Make it act like whatever you want     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!OneOrTwoOrThree = $02	;#$01 = message 1; #$02 = message 2; #$03 = Yoshi thanks message.
!Sound = $22
!Bank = $1DFC|!addr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

db $42
JMP Main : JMP Main : JMP Main
JMP No : JMP No : JMP No : JMP No
JMP Main : JMP Main : JMP Main

Main:
	LDA #!OneOrTwoOrThree
	STA $1426|!addr
	LDA #!Sound
	STA !Bank
	%erase_block()
No:
	RTL

print "Displays level message ", dec(!OneOrTwoOrThree), "."