; A P-Switch in a block format.

; Behaviour changing flags
!Silver = 0			; Set this to 1 if you want to have a silver P-Switch.
!SpritePassable = 1	; Set this to 0 if the P-Switch is solid to sprites
!DisableJumpOff = 0	; If set to 1, the P-Switch will act like air when pressed

; Other configurations
!PowTimer = $B0		; How long the P-Switch last
!ShakeTimer = $20	; How long the camera shakes
!Music = $0E		; Music if using SMW or Aaddmusic4.
!Music_AMK = $0B	; Music if using AddmusicK
!SoundEffect = $0B	; The sound when you press the switch.
!SfxPort = $1DF9	; 

db $37

JMP MarioBelow : JMP MarioAbove : JMP Return
JMP Sprite : JMP Sprite
JMP Sprite : JMP Return
JMP MarioAbove : JMP Return : JMP Return
JMP Return : JMP Return

assert !Silver == 0 || !Silver == 1,"!Silver has to be either 0 or 1."

MarioBelow:
	LDA $7D
	BMI PSwitchMain
RTL

MarioAbove:
	LDA $7D
	BMI Return
if !DisableJumpOff
	LDY #$00
	LDA #$25
	STA $1693|!addr
endif

PSwitchMain:
	REP #$10
	LDX $03
	INX				; Change to the next Map16 tiles.
	%change_map16()
	SEP #$10
if read1($008075) == $5C	; JML $xxxxxx
	LDA #!Music_AMK
	STA $1DFB|!addr
else
	LDA $0DDA|!addr	; If star is playing...
	BMI .NoMusic
	LDA #!Music
	STA $1DFB|!addr
.NoMusic
endif
	LDA #!SoundEffect
	STA !SfxPort|!addr
	LDA #!PowTimer
	STA $14AD+!Silver|!addr
	LDA #!ShakeTimer
	STA $1887|!addr
if !Silver
	PHY
	JSL $02B9BD|!bank
	PLY
endif
RTL

Sprite:
if !SpritePassable
	LDY #$00
	LDA #$25
	STA $1693|!addr
endif
Return:
RTL


if !Silver
print "A silver P-Switch which can be activated from above/below and switches to the next tile."
else
print "A blue P-Switch which can be activated from above/below and switches to the next tile."
endif
