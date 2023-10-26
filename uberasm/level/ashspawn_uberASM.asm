; UberASM Version

!ParticleId = $14		; The cluster sprite ID
!IsCustom = 1			; 0 = vanilla, 1 = custom
!SpawnFrequency = 4     ; How fast the particles spawn (exponential, only valid up to 8)

!MinAliveTimer = $60    ; How long the particle is alive
!MaxAliveTimer = $F0    ;
!MinYSpeed = $E8        ; How fast the particle raises (must be negative)
!MaxYSpeed = $C0        ;
!MinFlipTimer = $10     ; How fast the particle oscillates
!MaxFlipTimer = $50     ;

; Internal defines, do not change!

!AshXPos = $1E16|!addr
!AshYPos = $1E02|!addr

!AshXAccel = $0F4A|!addr
!AshYSpeed = $1E52|!addr
!AshXSpeed = $1E66|!addr
!AshAliveTimer = $1E2A|!addr
!AshFlipTimer = $0F72|!addr
!AshFlipTimerInit = $0F86|!addr

!DeltaFlipTimer #= !MaxFlipTimer-!MinFlipTimer
!DeltaYSpeed #= !MinYSpeed-!MaxYSpeed
!DeltaAliveTimer #= !MaxAliveTimer-!MinAliveTimer

!ClusterOffset = $09	; As long as UberASM Tool doesn't support it.

Init:
	LDA #$01
	STA $18B8|!addr
RTL

Main:
	LDA $9D
	BEQ .Continue
RTL

.Continue:
	LDA $14
	AND.b #(1<<(8-!SpawnFrequency))-1
	BNE .NoSpawn

	LDX #$13
-	LDA $1892|!addr,x
	BEQ .SlotFound
	DEX
	BPL -
.NoSpawn:
RTL

.SlotFound:
	JSL $01ACF9|!bank
	LDA $148D|!addr
	CLC : ADC $1A
	STA !AshXPos,x
	LDA $1C
	CLC : ADC #$DF
	STA !AshYPos,x
if !IsCustom
	LDA #(!ParticleId+!ClusterOffset)
else
	LDA #!ParticleId
endif
	STA $1892|!addr,x
	LDA $148E|!addr
	STA $4202
	LSR
	LDA #!DeltaAliveTimer
	STA $4203
	LDA #$01
	BCS +
	LDA #$FF
+	STA !AshXAccel,x
	LDA $4217
	CLC : ADC #!MinAliveTimer
	STA !AshAliveTimer,x
	JSL $01ACF9|!bank
	LDA $148D|!addr
	STA $4202
	LDA #!DeltaYSpeed
	STA $4203
	LDA #$00
	STA !AshXSpeed,x
	LDA #!MinYSpeed
	SEC : SBC $4217
	STA !AshYSpeed,x
	LDA $148E|!addr
	STA $4202
	LDA #!DeltaFlipTimer
	STA $4203
	NOP
	LDA #!MinFlipTimer
	CLC : ADC $4217
	STA !AshFlipTimerInit,x
	LSR
	STA !AshFlipTimer,x
RTL
