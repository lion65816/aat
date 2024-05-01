; Fix for the fireball conveyor belt glitch.

if read1($00FFD5) == $23
    sa1rom
endif

org $00FA29
	autoclean JSL fixFire

freecode
fixFire:
	LDA [$82],Y
	CMP #$18
	BEQ +
	CMP #$1B
	BNE .notLeft
  + LDA #$0C
	BRA .notRight
	
  .notLeft
	CMP #$19
	BEQ +
	CMP #$1A
	BNE .notRight
  + LDA #$0D
	
  .notRight
	STA $08
	RTL