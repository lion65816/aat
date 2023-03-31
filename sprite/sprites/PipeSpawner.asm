;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Pipe Spawner by dtothefourth
;
; Spawns sprites as if coming out of a pipe.
;	(Use pipe tiles with priority set for proper visuals)
;
; Uses 10 Extra Bytes
;
; Extra Byte 1 - Direction - 0 - down, 1 - left, 2 - up, 3 - right
;
; Extra Byte 2 - Delay - How many frames between spawns
;
; Extra Byte 3 - Spawn Mode - 0 = Spawn sprite specified in extra bytes
;							  1 = Spawn sprites using list below
;
; Extra Byte 4 - Sprite # - Sprite to spawn if using mode 0
;
; Extra Byte 5 - Sprite Extra Bits - Extra bits for spawned sprite if using mode 0
;					Same as in LM 2 = custom, 3 = custom with extra bit, 0 = normal
;
; Extra Byte 6 - Max on screen - How many sprites can exist from the sprite at once
;					Max of 0 = no limit, must be 0-8
;
; Extra Byte 7 - Total Spawn - How many sprites can come out of the pipe total
;					Total of 0 = no limit 
;
; Extra Byte 8 - Fire Mode - If 0 the sprite will just slowly push out of the pipe
;					Otherwise it will fire out of the pipe like a cannon
;
; Extra Byte 9  - X Speed - Horizontal fire speed if using cannon mode
;
; Extra Byte 10 - Y Speed - Vertical fire speed if using cannon mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteList: ;Sprite numbers to spawn, will loop through them until hitting FF
	db $00, $0F, $05, $80, $FF

SpriteCust:
	db $00, $00, $00, $00, $00



!Timer  = !1540,x
!Drop	= !154C,x

!Phase  = !C2,x
!Count  = !187B,x


!Sprite1 = !1504,x
!Sprite2 = !1510,x
!Sprite3 = !151C,x
!Sprite4 = !1528,x
!Sprite5 = !1534,x
!Sprite6 = !157C,x
!Sprite7 = !1594,x
!Sprite8 = !1626,x

!Dropping = !160E,x

Print "INIT ",pc
	LDA #$01
	JSR GetExtraByte
	STA !Timer
	STZ !Drop
	STZ !Phase
	STZ !Count

	LDA #$FF
	STA !Sprite1
	STA !Sprite2
	STA !Sprite3
	STA !Sprite4
	STA !Sprite5
	STA !Sprite6
	STA !Sprite7
	STA !Sprite8
	STA !Dropping
	RTL
	
Print "MAIN ",pc			
	PHB
	PHK				
	PLB				
	JSR main	
	PLB
	RTL

main:
	LDA $9D
	BEQ +
	RTS
	+

	JSR CheckStates


	LDA #$05
	JSR GetExtraByte
	BEQ +
	STA $01
	JSR GetCount
	CMP $01
	BCS +++
	+

	LDA !Timer
	ORA !Drop
	BNE +

	LDA #$01
	JSR GetExtraByte
	STA !Timer

	LDA #$02
	JSR GetExtraByte
	BEQ NormalSpawn
	JSR SpawnSprite
	BRA SpawnDone
NormalSpawn:
	JSR SpawnFixed
SpawnDone:

	LDA #$07
	JSR GetExtraByte
	BNE Fire
		LDA #$00
		JSR GetExtraByte
		BNE ++++
		LDA #$34
		STA !Drop
		BRA ++
		++++
		LDA #$40
		STA !Drop
	BRA ++
Fire:
		LDA #$08
		STA !Drop
	++

	LDA !Phase
	INC
	STA !Phase
	
	TAY 
	LDA SpriteList,Y
	CMP #$FF
	BNE +

	STZ !Phase

	+

	+++

	LDA !Dropping
	BPL ++
	JMP +
	++
	TAY

	LDA !Drop
	BNE ++
	JMP +
	++

	LDA #$07
	JSR GetExtraByte
	BNE Fire2
		LDA #$00
		STA !AA,y
		STA !B6,y
		BRA ++
Fire2:
		LDA #$09
		JSR GetExtraByte
		STA !AA,y
		LDA #$08
		JSR GetExtraByte
		STA !B6,y
	++

	LDA #$00
	JSR GetExtraByte
	AND #$01
	BNE ++
	LDA !E4,x
	CLC
	ADC #$08
	STA !E4,y
	LDA !14E0,x
	ADC #$00
	STA !14E0,y	
	BRA +++
	++
	LDA !D8,x
	CLC
	ADC #$08
	STA !D8,y
	LDA !14D4,x
	ADC #$00
	STA !14D4,y	
	+++

	LDA #$07
	JSR GetExtraByte
	BNE NoLock
		
	JSR LockDir

NoLock:

	LDA #$01
	STA !15DC,y

	LDA #$00
	JSR GetExtraByte
	CMP #$01
	BNE ++++

	LDA #$01
	STA !157C,y
	BRA +++++
	++++

	CMP #$03
	BNE +++++
	LDA #$00
	STA !157C,y
	
	+++++
		

	LDA !Drop
	CMP #$01
	BNE +

	LDA #$00
	STA !15DC,y

	LDA #$FF
	STA !Dropping

	LDA #$06
	JSR GetExtraByte
	BEQ +
	STA $01
	LDA !Count
	INC
	STA !Count
	CMP $01
	BNE +

	STZ !14C8,x
	RTS

	+

	LDA #$00
	%SubOffScreen()

	RTS

SpawnSprite:

	LDA !Phase
	TAY
	LDA SpriteList,Y
	PHA
	LDA SpriteCust,Y
	PHA
	
	JSL $02A9DE|!BankB
	BMI EndSpawn

	TYA
	STA !Dropping

	JSR SaveSlot

	LDA #$01
	STA !14C8,y

	PLA
	STA $03
	BNE +

	PLA
	STA !9E,y
	BRA ++
	+
	PLA
	PHX
	TYX
	STA !7FAB9E,x
	PLX
	++



	JSR SpawnPos
	
	PHX
	TYX
	JSL $07F7D2|!BankB

	LDA $03
	BEQ +

	ASL #2
	STA !7FAB10,x
	JSL $0187A7|!BankB

	+

	PLX

	LDA #$01
	STA !15DC,y

	RTS
	EndSpawn:
	PLA
	PLA
	RTS

SpawnFixed:

	LDA #$03
	JSR GetExtraByte
	PHA
	LDA #$04
	JSR GetExtraByte
	PHA
	
	JSL $02A9DE|!BankB
	BMI EndSpawn2

	TYA
	STA !Dropping

	JSR SaveSlot

	LDA #$01
	STA !14C8,y

	PLA
	STA $03
	BNE +

	PLA
	STA !9E,y
	BRA ++
	+
	PLA
	PHX
	TYX
	STA !7FAB9E,x
	PLX
	++



	JSR SpawnPos

	PHX
	TYX
	JSL $07F7D2|!BankB

	LDA $03
	BEQ +

	ASL #2
	STA !7FAB10,x
	JSL $0187A7|!BankB

	+

	PLX

	LDA #$01
	STA !15DC,y

	RTS
	EndSpawn2:
	PLA
	PLA
	RTS	

SaveSlot:
	LDA !Sprite1
	BPL +

	TYA
	STA !Sprite1
	RTS
	+

	LDA !Sprite2
	BPL +

	TYA
	STA !Sprite2
	RTS
	+

	LDA !Sprite3
	BPL +

	TYA
	STA !Sprite3
	RTS
	+

	LDA !Sprite4
	BPL +

	TYA
	STA !Sprite4
	RTS
	+

	LDA !Sprite5
	BPL +

	TYA
	STA !Sprite5
	RTS
	+

	LDA !Sprite6
	BPL +

	TYA
	STA !Sprite6
	RTS
	+

	LDA !Sprite7
	BPL +

	TYA
	STA !Sprite7
	RTS
	+

	LDA !Sprite8
	BPL +

	TYA
	STA !Sprite8
	RTS
	+
	RTS


GetCount:
	STZ $00
	LDA !Sprite1
	BMI +

	INC $00
	+

	LDA !Sprite2
	BMI +

	INC $00
	+

	LDA !Sprite3
	BMI +

	INC $00
	+

	LDA !Sprite4
	BMI +

	INC $00
	+

	LDA !Sprite5
	BMI +

	INC $00
	+

	LDA !Sprite6
	BMI +

	INC $00
	+

	LDA !Sprite7
	BMI +

	INC $00
	+

	LDA !Sprite8
	BMI +

	INC $00
	+
	LDA $00
	RTS	

CheckStates:
	LDA !Sprite1
	BMI +

	TAY
	LDA !14C8,Y
	CMP #$08
	BCS +

	LDA #$FF
	STA !Sprite1


	+

	LDA !Sprite2
	BMI +

	TAY
	LDA !14C8,Y
	CMP #$08
	BCS +

	LDA #$FF
	STA !Sprite2


	+

	LDA !Sprite3
	BMI +

	TAY
	LDA !14C8,Y
	CMP #$08
	BCS +

	LDA #$FF
	STA !Sprite3


	+

	LDA !Sprite4
	BMI +

	TAY
	LDA !14C8,Y
	CMP #$08
	BCS +

	LDA #$FF
	STA !Sprite4


	+

	LDA !Sprite5
	BMI +

	TAY
	LDA !14C8,Y
	CMP #$08
	BCS +

	LDA #$FF
	STA !Sprite5


	+

	LDA !Sprite6
	BMI +

	TAY
	LDA !14C8,Y
	CMP #$08
	BCS +

	LDA #$FF
	STA !Sprite6


	+

	LDA !Sprite7
	BMI +

	TAY
	LDA !14C8,Y
	CMP #$08
	BCS +

	LDA #$FF
	STA !Sprite7


	+

	LDA !Sprite8
	BMI +

	TAY
	LDA !14C8,Y
	CMP #$08
	BCS +

	LDA #$FF
	STA !Sprite8


	+

	LDA !Dropping
	BMI +

	TAY
	LDA !14C8,Y
	CMP #$08
	BCS +

	LDA #$FF
	STA !Dropping


	+	
	RTS

GetExtraByte:
	PHY
	TAY
	LDA !extra_byte_1,x
	STA $0D
	LDA !extra_byte_2,x
	STA $0E
	LDA !extra_byte_3,x
	STA $0F
	LDA [$0D],y
	PLY
	CMP #$00
	RTS	


LockDir:
	LDA !Drop
	LSR #2
	STA $00
	STZ $01

	LDA #$00
	JSR GetExtraByte
	BNE +

		LDA !14D4,x
		XBA
		LDA !D8,x

		REP #$20
		CLC
		ADC #$000D
		SEC
		SBC $00
		SEP #$20

		STA !D8,y
		XBA
		STA !14D4,y		
		RTS
	
	+
	DEC
	BNE +
	
		LDA !14E0,x
		XBA
		LDA !E4,x

		REP #$20
		SEC
		SBC #$0010
		CLC
		ADC $00
		SEP #$20

		STA !E4,y
		XBA
		STA !14E0,y		
		RTS

	+
	DEC
	BNE +
		LDA !14D4,x
		XBA
		LDA !D8,x

		REP #$20
		SEC
		SBC #$000D
		CLC
		ADC $00
		SEP #$20

		STA !D8,y
		XBA
		STA !14D4,y		
		RTS
	+
		LDA !14E0,x
		XBA
		LDA !E4,x

		REP #$20
		CLC
		ADC #$0010
		SEC
		SBC $00
		SEP #$20

		STA !E4,y
		XBA
		STA !14E0,y		
	

	RTS

SpawnPos:
	LDA #$07
	JSR GetExtraByte
	BNE +

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x	
	STA !14E0,y

	LDA !D8,x
	STA !D8,y	
	LDA !14D4,x
	STA !14D4,y	
	RTS
	

	+
	LDA #$00
	JSR GetExtraByte
	BNE +
	LDA !E4,x
	STA !E4,y
	LDA !14E0,x	
	STA !14E0,y

	LDA !D8,x
	CLC
	ADC #$08	
	STA !D8,y	
	LDA !14D4,x
	ADC #$00	
	STA !14D4,y	
	RTS
	+
	
	DEC
	BNE +
	LDA !E4,x
	SEC
	SBC #$08	
	STA !E4,y
	LDA !14E0,x
	SBC #$00		
	STA !14E0,y

	LDA !D8,x
	STA !D8,y	
	LDA !14D4,x
	STA !14D4,y	
	RTS
	+
	
	DEC
	BNE +
	LDA !E4,x
	STA !E4,y
	LDA !14E0,x	
	STA !14E0,y

	LDA !D8,x
	SEC
	SBC #$08	
	STA !D8,y	
	LDA !14D4,x
	SBC #$00	
	STA !14D4,y	
	RTS
	+
	
	LDA !E4,x
	CLC
	ADC #$08	
	STA !E4,y
	LDA !14E0,x
	ADC #$00	
	STA !14E0,y

	LDA !D8,x
	STA !D8,y	
	LDA !14D4,x
	STA !14D4,y	
	RTS
				