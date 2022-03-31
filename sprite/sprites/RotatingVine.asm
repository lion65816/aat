;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; Multi-directional Growing Vine by dtothefourth
;
; Based on the Growing Vine disassembly by imamelia
;
; Uses two extra bytes, set using the extension box in LM as below:
; 
; SS DD
;	SS - starting speed, 0-7F
;   DD - starting direction
;		0 - up, 1 - down, 2 - left, 3 - right
;
; To have the proper sideways vine tiles, you can use the included Tile.bin
; and make a custom map16 tile that acts like 6, then set that tile number
; in !XTile below
;
; It will work fine with vanilla vine tiles, just look odd
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!PlayerControl = 0 ; If 1, holding directions will control it like a coin snake

;Two tiles of animation used when moving horizontally
!XHeadTile1 = $C0
!XHeadTile2 = $E0
!XHeadProp  = $01

;Two tiles of animation used when moving vertically
!YHeadTile1 = $AC
!YHeadTile2 = $AE
!YHeadProp  = $00


;Tiles created when moving horizontal or vertical
!XTile      = $07A0
!YTile      = $0006


print "INIT ",pc
	LDA #$FF
	STA !1534,x

	LDA !extra_byte_1,x
	STA !1510,x

	LDA #$AB
	STA $02

	LDA !extra_byte_2,x
	STA !151C,x

	BIT #$02
	BNE +

	LDA !D8,x
	CLC
	ADC #$30
	JSR SpawnTileY
	RTL
	+
	LDA !E4,x
	CLC
	ADC #$30
	JSR SpawnTileX	
	RTL


print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteMainRt
	PLB
	RTL


SpriteMainRt:
	JSR SubGFX
	LDA $9D
	BEQ +
	RTS
	+

	if !PlayerControl
	LDA $15
	BIT #$08
	BEQ ++
	LDA !151C,x
	CMP #$01
	BEQ +
	LDA #$00
	STA !1534,x
	BRA +

	++
	BIT #$04
	BEQ ++
	LDA !151C,x
	CMP #$00
	BEQ +
	LDA #$01
	STA !1534,x
	BRA +

	++
	BIT #$02
	BEQ ++
	LDA !151C,x
	CMP #$03
	BEQ +
	LDA #$02
	STA !1534,x
	BRA +

	++
	BIT #$01
	BEQ +
	LDA !151C,x
	CMP #$02
	BEQ +
	LDA #$03
	STA !1534,x

	+
	endif

	LDA !151C,x
	BIT #$02
	BEQ Vertical
	JMP Horizontal

Vertical:
	BIT #$01
	BNE .NoNeg
	LDA !1510,X
	EOR #$FF
	INC
	BRA ++
	.NoNeg:
	LDA !1510,X
	++
	STA !AA,x
	JSL $01801A|!BankB
	LDA !1540,x
	CMP #$20
	BCS .Continue
	JSL $019138|!BankB
	LDA !1588,x
	AND #$0C
	BNE .EraseSprite

	JSR CheckBounds
	BCC .Continue
.EraseSprite
	JMP OffScrEraseSprite
.Continue
	LDA !D8,X
	AND #$F0
	STA $00
	CMP !1528,X
	BEQ ReturnY

	LDA !AA,x
	PHA

	BIT #$0F
	BEQ ++

	CMP #$00
	BMI +
	AND #$F0
	CLC
	ADC #$10
	STA !AA,x

	BRA ++
	+

	AND #$F0
	SEC
	SBC #$10
	STA !AA,x

	++

	LDA !D8,x
	PHA
	LDA !14D4,x
	PHA

	JSL $01801A|!BankB
	
	LDA !D8,x
	AND #$F0
	STA $01

	PLA
	STA !14D4,x
	PLA
	STA !D8,x
	
	PLA
	STA !AA,x

	LDA $00
	CMP $01
	BNE SpawnTileY
ReturnY:
	RTS

SpawnTileY:
	STA !1528,x

	LDA !E4,x
	STA $9A
	LDA !14E0,x
	STA $9B

	LDA !D8,x
	STA $98
	LDA !14D4,x
	STA $99

	LDA $02
	CMP #$AB
	BEQ +
	LDA !151C,x
	AND #$01
	BEQ +
	REP #$20
	LDA $98
	CLC
	ADC #$0010
	STA $98
	+
	
	REP #$30
	LDA #!YTile
	%ChangeMap16()
	SEP #$30

	LDA !1534,x
	BMI +

	STA !151C,x
	LDA #$FF
	STA !1534,x

	LDA !E4,x
	CLC
	ADC #$08
	AND #$F0
	STA !E4,x
	LDA !14E0,x
	ADC #$00
	STA !14E0,x

	LDA !D8,x
	CLC
	ADC #$08
	AND #$F0
	STA !D8,x
	LDA !14D4,x
	ADC #$00
	STA !14D4,x

	LDA !151C,x
	BIT #$02
	BNE ++

	LDA !D8,x
	CLC
	ADC #$30
	STA !1528,x
	RTS
	++
	LDA !E4,x
	CLC
	ADC #$30
	STA !1528,x

	+
	RTS

Horizontal:
	BIT #$01
	BNE .NoNeg
	LDA !1510,X
	EOR #$FF
	INC
	BRA ++
	.NoNeg:
	LDA !1510,X
	++
	STA !B6,x
	JSL $018022|!BankB
	LDA !1540,x
	CMP #$20
	BCS .Continue
	JSL $019138|!BankB
	LDA !1588,x
	AND #$03
	BNE .EraseSprite
	JSR CheckBounds
	BCC .Continue
.EraseSprite
	JMP OffScrEraseSprite
.Continue
	LDA !E4,X
	AND #$F0
	STA $00
	CMP !1528,X
	BEQ ReturnX

	LDA !B6,x
	PHA

	BIT #$0F
	BEQ ++

	CMP #$00
	BMI +
	AND #$F0
	CLC
	ADC #$10
	STA !B6,x

	BRA ++
	+

	AND #$F0
	SEC
	SBC #$10
	STA !B6,x

	++
	
	LDA !E4,x
	PHA
	LDA !14E0,x
	PHA

	JSL $018022|!BankB
	
	LDA !E4,x
	AND #$F0
	STA $01

	PLA
	STA !14E0,x
	PLA
	STA !E4,x

	PLA
	STA !B6,x
	

	LDA $00
	CMP $01
	BNE SpawnTileX
ReturnX:
	RTS

SpawnTileX:
	STA !1528,x

	LDA !E4,x
	STA $9A
	LDA !14E0,x
	STA $9B

	LDA !D8,x
	STA $98
	LDA !14D4,x
	STA $99
	
	LDA $02
	CMP #$AB
	BEQ +
	LDA !151C,x
	AND #$01
	BEQ +
	REP #$20
	LDA $9A
	CLC
	ADC #$0010
	STA $9A
	+
	REP #$30
	LDA #!XTile
	%ChangeMap16()
	SEP #$30

	LDA !1534,x
	BMI +

	STA !151C,x
	LDA #$FF
	STA !1534,x

	LDA !E4,x
	CLC
	ADC #$08
	AND #$F0
	STA !E4,x
	LDA !14E0,x
	ADC #$00
	STA !14E0,x

	LDA !D8,x
	CLC
	ADC #$08
	AND #$F0
	STA !D8,x
	LDA !14D4,x
	ADC #$00
	STA !14D4,x

	LDA !151C,x
	BIT #$02
	BNE ++

	LDA !D8,x
	CLC
	ADC #$30
	STA !1528,x
	RTS
	++
	LDA !E4,x
	CLC
	ADC #$30
	STA !1528,x

	+

	RTS


SubGFX:
	%GetDrawInfo()
	LDA $00
	STA $0300|!Base2,y



	LDA $01
	STA $0301|!Base2,y
	LDA $64
	PHA
	LDA !1540,x
	CMP #$20
	BCC .NotBehindBlock
	LDA #$10
	STA $64
.NotBehindBlock

	LDA !151C,x
	BIT #$02
	BNE .Horz
	LDA !151C,x
	AND #$01
	ASL #7
	ORA #!YHeadProp
	STA $00
	LDA $14
	LSR #4
	LDA #!YHeadTile1
	BCC .SetTile
	LDA #!YHeadTile2
	BRA .SetTile
.Horz
	LDA !151C,x
	AND #$01
	EOR #$01
	ASL #6
	ORA #!XHeadProp
	STA $00
	LDA $14
	LSR #4
	LDA #!XHeadTile1
	BCC .SetTile
	LDA #!XHeadTile2
.SetTile
	STA $0302|!Base2,y
	LDA !15F6,x
	ORA $64
	ORA $00
	STA $0303|!Base2,y
	PLA
	STA $64
	LDY #$02
	LDA #$00
	JSL $01B7B3|!BankB
	RTS


OffScrEraseSprite:
	LDA !14C8,x
	CMP #$08
	BCC .OffScrKillSprite
	LDY !161A,x
	CPY #$FF
	BEQ .OffScrKillSprite
	;LDA #$00
    ;PHX
    ;TYX
	;STA !1938,x
    ;PLX
.OffScrKillSprite
	STZ !14C8,x
	RTS

CheckBounds:

	STZ $00
	LDA $5B
	AND #$03
	BNE +

	LDA $5E
	STA $01
	BRA ++
	+
	LDA #$02
	STA $01
	++

	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	CMP #$0000
	BPL +
	SEP #$20
	SEC
	STZ !14C8,x
	RTS
	+
	CMP $00
	BCC +
	SEP #$20
	SEC
	STZ !14C8,x
	RTS
	+
	SEP #$20

	STZ $00
	LDA $5B
	AND #$03
	BEQ +

	LDA $5F
	STA $01
	BRA ++
	+

	if !EXLEVEL
	REP #$20
	LDA $13D7|!Base2
	STA $00
	SEP #$20
	else
	LDA #$01
	STA $01
	LDA #$B0
	STA $00
	endif
	
	++


	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	CMP #$0000
	BPL +
	SEP #$20
	SEC
	STZ !14C8,x
	RTS
	+
	CMP $00
	BCC +
	SEP #$20
	SEC
	STZ !14C8,x
	RTS
	+
	SEP #$20


	CLC
	RTS