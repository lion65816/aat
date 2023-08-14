; This code will reload the current room.

load:
	JSL NoStatus_load
	RTL

main:
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL LRReset

	LDA #$01
	STA $140B|!addr
	RTL
