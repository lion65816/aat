db $42

!SFX = $08
!APUPort = $1DF9

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead


SpriteV:
SpriteH:
	LDA !9E,x
	CMP #$35
	BEQ Delete_eaten_sprite
	CMP #$2D
	BEQ Yoshi

Return:
Fireball:
Cape:
RTL

MarioBelow:
MarioAbove:
MarioSide:
MarioCorner:
MarioInside:
MarioHead:
	STZ $19
	STZ $0DC2|!addr
if !sa1 == 0
	LDX.b #12-1
else 
	LDX.b #22-1
endif
-	LDA !14C8,x
	CMP #$08
	BCC .next
	LDA !9E,x
	CMP #$35
	BEQ .yoshi
	CMP #$2D
	BEQ .baby
.next
	DEX
	BPL -
RTL

.baby
	LDA !14C8,x
	CMP #$0A
	BEQ Yoshi
RTL

.yoshi
	LDA $187A
	BEQ Return

Delete_eaten_sprite:
; Thanks 33953YoShi for this
	LDA $18AC|!addr	;\ if Yoshi has sprite in mouth.
	BEQ .no		;/
	STZ $18AC|!addr	; Reset mouth timer.
	PHY		;
	LDY !160E,x	;
	BMI +		;
	LDA #$00	;\ Sprite of Yoshi in mouth will be deleted.
	STA !14C8,y	;/
+	PLY		;

.no
	STZ $187A|!addr
	LDA #$02
	STA !1FE2,x
	STZ !C2,x
	LDA #$03
	STA $1DFA|!addr
	STZ $0DC1|!addr

Yoshi:
	LDA #!SFX
	STA !APUPort|!addr
	LDA #$04
	STA !14C8,x
	LDA #$1F
	STA !1540,x
	PHY
	JSL $07FC3B
	PLY
.return
RTL

print "A block which destroys (Baby) Yoshi if touched."