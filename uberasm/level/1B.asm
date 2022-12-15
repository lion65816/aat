init:
	LDA $141D|!addr
	ORA $13CF|!addr
	BEQ +		; intro
	STZ $1692|!addr
+
    LDA #$01
    STA $140B
	RTL

main:
    LDX #!sprite_slots-1
-
    LDA !14C8,x
    CMP #$08
    BCC +
    LDA !9E,x
    CMP #$1E
    BNE +
    LDA !167A,x
    ORA #$80
    STA !167A,x
    LDA !166E,x
    ORA #$30
    STA !166E,x
    LDA !1686,x
    ORA #$08
    STA !1686,x
    JSL $01A7DC|!bank
    BCC +
    JSL $00F5B7|!bank
+
    DEX
    BPL -
    RTL