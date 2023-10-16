; The extra bit determines whether the spawned sprite will have its extra byte activated or not.

!SoundEffect = $20
!SFXPort = $1DF9

!Sprite = $39

; 0 means no, 1 means yes
!IsCustom = 0
!GenerateSmoke = 0
!ShootIfNear = CLC ; This time, CLC means yes and SEC means no

print "INIT ",pc
print "MAIN ",pc
PHB : PHK : PLB
	JSR Shooter
PLB
RTL

Return:
RTS

Shooter:
	LDA #$35 : !ShootIfNear	; Set the timer and don't ignore Mario
	%ShooterMain()
	BCS Return

	;LDA #!SoundEffect	; Play sound effect
	;STA !SFXPort|!Base2	;

	LDA #$00
	STA $0F
	LDA $1783|!Base2,x
	AND #$40
	BEQ +
	LDA #$04
	STA $0F
+	PHX
	TYX
if !IsCustom
	LDA #!Sprite
	STA !7FAB9E,x
	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA #$88
	ORA $0F
	STA !7FAB10,x
else
	LDA #!Sprite
	STA !9E,x
	JSL $07F7D2|!BankB
	LDA $0F
	STA !7FAB10,x
endif
	PLX

	LDA $178B|!Base2,x
	SEC : SBC #$01
	STA.w !D8,y
	LDA $1793|!Base2,x
	SBC #$00
	STA !14D4,y
	LDA $179B|!Base2,x
	STA.w !E4,y
	LDA $17A3|!Base2,x
	STA !14E0,y

	LDA #$01
	STA !14C8,y

if !GenerateSmoke
	PHX
	TYX
	%SubHorzPos()
	LDA SmokeOffset,y
	STA $00
	STZ $01
	LDA #$1B
	STA $02
	LDA #$01
	%SpawnSmoke()
	PLX
endif
RTS

SmokeOffset:
db $0C,$F4
