;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  
;  SMM style enemy stacks by dtothefourth
;
;  Uses 8 extra bytes which determine the sprites in the stack from bottom to top
;  FF for an empty slot
;  Use the Lunar Magic numbers for shells (DA-DE)
;
; The 9th extra byte marks each sprite in the stack as a custom sprite
; The bits are in order from left to right with left being the bottom of the stack
; So 80 would make just the bottom a custom sprite
;
; The 10th extra byte is the same, but for the extra bit
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!AllowStackCarry = 1 ; If set to 1 and the bottom sprite is something like a shell can pick up and carry the stack
!StackSway		 = 0 ; If 1, the sprites in the stack sway from side to side like in Maker
!PlatformCheck	 = 0 ; If 1, when Mario is standing on a platform that is part of the stack Mario will be moved with it
					 ; Requires my FindPlatformSprite.asm patch and the !Platform define to match
!Platform = $1696|!addr ; FreeRAM for finding platform sprite

!Sprite1 = !1504,x
!Sprite2 = !1510,x
!Sprite3 = !151C,x
!Sprite4 = !1528,x
!Sprite5 = !1534,x
!Sprite6 = !C2,x
!Sprite7 = !157C,x
!Sprite8 = !1594,x
!Init	 = !1626,x


;Offsets for positioning custom sprites on the stack
YOffsetC: ; Y offset is applied after positioning the current sprite, moving up the rest of the stack
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;00-0F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;10-1F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;20-2F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;30-3F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;40-4F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;50-5F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;60-6F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;70-7F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;80-8F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;90-9F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;A0-AF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;B0-BF
db $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;C0-CF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;D0-DF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;E0-EF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;F0-FF

HeightC: ; Height is applied before positioning the current sprite, so it is moved as well
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;00-0F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;10-1F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;20-2F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;30-3F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;40-4F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;50-5F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;60-6F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;70-7F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;80-8F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;90-9F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;A0-AF
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;B0-BF
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;C0-CF
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;D0-DF
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;E0-EF
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;F0-FF

XOffsetC:
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;00-0F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;10-1F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;20-2F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;30-3F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;40-4F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;50-5F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;60-6F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;70-7F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;80-8F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;90-9F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;A0-AF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;B0-BF
db $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;C0-CF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;D0-DF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;E0-EF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;F0-FF





;Offsets for positioning vanilla sprites on the stack, probably don't need to change these
YOffset: ; Y offset is applied after positioning the current sprite, moving up the rest of the stack
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;00-0F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;10-1F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;20-2F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0E ;30-3F
db $0E, $00, $00, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;40-4F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08 ;50-5F
db $00, $00, $08, $08, $08, $26, $06, $10, $00, $00, $00, $00, $00, $00, $0E, $00 ;60-6F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;70-7F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;80-8F
db $00, $04, $04, $04, $04, $04, $00, $04, $04, $00, $04, $00, $00, $0B, $00, $00 ;90-9F
db $00, $1E, $04, $00, $08, $00, $06, $00, $00, $00, $00, $10, $00, $00, $00, $00 ;A0-AF
db $00, $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $0E ;B0-BF
db $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;C0-CF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;D0-DF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;E0-EF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;F0-FF

Height: ; Height is applied before positioning the current sprite, so it is moved as well
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
db $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0E, $0F ;00-0F
db $0F, $0E, $00, $0E, $0E, $0E, $0E, $0E, $0E, $00, $1E, $10, $0E, $0E, $10, $1E ;10-1F
db $10, $10, $1E, $1E, $1E, $1E, $1E, $10, $40, $00, $1E, $10, $10, $10, $10, $10 ;20-2F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $1E, $1E, $1E, $10, $10, $10 ;30-3F
db $10, $10, $10, $1E, $10, $10, $10, $10, $10, $10, $10, $1E, $10, $10, $10, $10 ;40-4F
db $10, $10, $10, $10, $10, $0C, $1E, $0C, $1E, $10, $10, $10, $0C, $1E, $1E, $08 ;50-5F
db $10, $10, $08, $0C, $48, $08, $28, $10, $10, $10, $10, $08, $08, $10, $10, $10 ;60-6F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $08, $10, $10, $10, $10 ;70-7F
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;80-8F
db $3E, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $3E ;90-9F
db $10, $10, $10, $10, $16, $10, $12, $10, $10, $2E, $10, $10, $50, $50, $1E, $10 ;A0-AF
db $10, $10, $10, $08, $20, $10, $10, $10, $10, $10, $10, $20, $10, $10, $10, $10 ;B0-BF
db $10, $10, $10, $18, $10, $3E, $10, $10, $10, $00, $10, $00, $00, $00, $00, $00 ;C0-CF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $10, $10, $10, $10, $10 ;D0-DF
db $10, $00, $00, $00, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;E0-EF
db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 ;F0-FF

XOffset:
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00 ;00-0F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;10-1F
db $00, $00, $00, $00, $00, $00, $00, $00, $EC, $00, $00, $00, $00, $00, $00, $00 ;20-2F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F8, $F8, $F8, $00, $00, $00 ;30-3F
db $00, $F4, $F4, $00, $F8, $00, $00, $00, $00, $F8, $00, $00, $00, $00, $00, $00 ;40-4F
db $00, $00, $F0, $00, $00, $E0, $F0, $E0, $F0, $00, $00, $F0, $E0, $F0, $F0, $58 ;50-5F
db $F8, $00, $08, $08, $08, $08, $08, $08, $00, $00, $00, $04, $04, $00, $00, $00 ;60-6F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FC, $00, $00, $00, $00 ;70-7F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;80-8F
db $EA, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $E8 ;90-9F
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;A0-AF
db $00, $00, $00, $00, $00, $00, $00, $F8, $F8, $00, $F8, $F8, $00, $00, $00, $F8 ;B0-BF
db $F0, $F0, $00, $00, $E8, $EE, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;C0-CF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;D0-DF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;E0-EF
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;F0-FF

;Sway X offsets
Offset:
db $00, $01, $02, $03, $03, $02, $01, $00, $00, $FF, $FE, $FD, $FD, $FE, $FF, $00

macro SetDirection()
	LDA !9E,x
	CMP #$1C
	BEQ ?C2A

	LDA !157C,x
	BRA ?Dir2
?C2A:
	LDA !C2,x

?Dir2:
	PHA
	LDA !9E,y
	CMP #$1C
	BEQ ?C2B
	PLA
	STA !157C,y
	BRA ?End
?C2B:
	PLA
	STA !C2,y
?End:
endmacro

macro YOffset()

	PHX
	TYX
	LDA !7FAB10,x
	AND #$08
	BNE ?+

	LDA !9E,x
	TAX
	LDA YOffset,x
	STA $00
	STZ $01

	REP #$20
	LDA $0E
	SEC
	SBC $00
	STA $0E
	SEP #$20
	PLX
	BRA ?++
	?+
	LDA !7FAB9E,x
	TAX
	LDA YOffsetC,x
	STA $00
	STZ $01

	REP #$20
	LDA $0E
	SEC
	SBC $00
	STA $0E
	SEP #$20
	PLX
	?++

endmacro

macro Height()

	PHX
	TYX
	LDA !7FAB10,x
	AND #$08
	BNE ?+

	LDA !9E,x
	TAX
	LDA Height,x
	STA $00
	STZ $01

	REP #$20
	LDA $0E
	SEC
	SBC $00
	STA $0E
	SEP #$20
	PLX
	BRA ?++
	?+
	LDA !7FAB9E,x
	TAX
	LDA HeightC,x
	STA $00
	STZ $01

	REP #$20
	LDA $0E
	SEC
	SBC $00
	STA $0E
	SEP #$20
	PLX
	?++

endmacro

macro VarHeightB()

	;carrot platform
	LDA !9E,y
	CMP #$B7
	BNE +

	LDA !D8,y
	SEC
	SBC #$10
	STA !D8,y
	LDA !14D4,y
	SBC #$00
	STA !14D4,y

	+

	;carrot platform
	LDA !9E,y
	CMP #$B8
	BNE +

	LDA !D8,y
	SEC
	SBC #$10
	STA !D8,y
	LDA !14D4,y
	SBC #$00
	STA !14D4,y

	REP #$20

	LDA $0E
	SEC
	SBC #$0010
	STA $0E

	SEP #$20

	+


	;goal post
	LDA !9E,y
	CMP #$7B
	BNE +

	LDA !D8,y
	SEC
	SBC #$08
	STA !D8,y
	LDA !14D4,y
	SBC #$00
	STA !14D4,y


	+

	;pokey segments
	LDA !9E,y
	CMP #$70
	BNE +

	LDA !D8,y
	SEC
	SBC #$40
	STA !D8,y
	LDA !14D4,y
	SBC #$00
	STA !14D4,y

	LDA !C2,y
	AND #$1E
	-
	LSR
	BEQ +
	PHA
	REP #$20

	LDA $0E
	SEC
	SBC #$0010
	STA $0E

	SEP #$20

	
	PLA

	BRA -
	+

endmacro

macro XPosition()
	LDA $0C
	INC
	AND #$0F
	STA $0C


	if !StackSway
	PHX
	TAX
	LDA Offset,X
	STA $0D
	PLX
	else
	STZ $0D
	endif

	PHX
	TYX
	LDA !7FAB10,x
	AND #$08
	BNE ?+

	LDA !9E,x
	TAX
	LDA XOffset,x
	CLC
	ADC $0D
	STA $0D

	PLX
	BRA ?++
	?+
	LDA !7FAB9E,x
	TAX
	LDA XOffsetC,x
	CLC
	ADC $0D
	STA $0D

	PLX
	?++

	if !PlatformCheck

	LDA !9E,y
	CMP #$64
	BNE ?++
	LDA !163E,y
	BEQ ?++
	LDA $18BE|!addr
	BNE ?+++

	?++

	CPY !Platform
	BNE ?+

	?+++

	STZ $07
	LDA $0D
	STA $06
	BPL ?++
	LDA #$FF
	STA $07
	?++
	
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	CLC
	ADC $06
	STA $06
	SEP #$20

	LDA !14E0,y
	XBA
	LDA !E4,y
	REP #$20
	SEC
	SBC $06
	EOR #$FFFF
	INC
	CLC
	PHA
	SEP #$20	
	BMI ?++
	LDA $77
	AND #$01
	BNE ?++++
	BRA ?+++
	?++
	LDA $77
	AND #$02
	BNE ?++++
	?+++
	REP #$20
	PLA
	ADC $94
	STA $94
	SEP #$20
	BRA ?+
	?++++
	PLA
	PLA
	?+

	endif

	LDA $0D
	CMP #$00
	BMI ?XMin


	LDA !E4,x
	CLC
	ADC $0D
	STA !E4,y
	LDA !14E0,x
	ADC #$00
	STA !14E0,y
	BRA ?End

	?XMin:
	LDA $0D
	EOR #$FF
	INC
	STA $0D

	LDA !E4,x
	SEC
	SBC $0D
	STA !E4,y
	LDA !14E0,x
	SBC #$00
	STA !14E0,y
?End:
endmacro

macro IsCustom()
	STA $0A
	LDA #$08
	STA $08
	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$09
	LDA [$00],y
	AND $0A
	BEQ ?+
	LDA #$0C
	STA $08
	?+
	LDY #$08
	LDA [$00],y
	PLY
	AND $0A
endmacro


Print "INIT ",pc
	LDA #$FF
	STA !Sprite1
	STA !Sprite2
	STA !Sprite3
	STA !Sprite4
	STA !Sprite5
	STA !Sprite6
	STA !Sprite7
	STA !Sprite8
	STZ !Init
	RTL
	
Print "MAIN ",pc			
	PHB
	PHK				
	PLB				
	JSR main	
	PLB
	RTL

main:

	LDA !Init
	BNE +

	LDA #$01
	STA !Init

	JSR SpawnSprites

	RTS
	+

	LDA !Sprite1
	TAY
	LDA !14C8,y
	CMP #$08
	BEQ +
	CMP #$09
	BEQ +
	CMP #$0A
	BEQ +
	if !AllowStackCarry
	CMP #$0B
	BEQ +
	endif
	
	STZ !14C8,x

	PHX
	LDA !161A,X
	TAX
	LDA #$00
	STA !1938,X
	PLX

	RTS
	+
	JSR CheckDead

	JSR MoveSprites


	if !AllowStackCarry
	LDA !Sprite1
	BMI +
	TAY

	LDA !14C8,y
	CMP #$0B
	BNE +

	JSR Carry
	+
	endif

	if !PlatformCheck
	LDA #$FF
	STA !Platform
	endif

	RTS

Carry:
	LDA !Sprite2
	BMI +
	TAY
	LDA #$08
	STA !154C,y
	+
	LDA !Sprite3
	BMI +
	TAY
	LDA #$08
	STA !154C,y
	+
	LDA !Sprite4
	BMI +
	TAY
	LDA #$08
	STA !154C,y
	+
	LDA !Sprite5
	BMI +
	TAY
	LDA #$08
	STA !154C,y
	+
	LDA !Sprite6
	BMI +
	TAY
	LDA #$08
	STA !154C,y
	+
	LDA !Sprite7
	BMI +
	TAY
	LDA #$08
	STA !154C,y
	+
	LDA !Sprite8
	BMI +
	TAY
	LDA #$08
	STA !154C,y
	+
	RTS

CheckDead:

	LDA !Sprite2
	BMI Dead3
	TAY
	LDA !14C8,y
	CMP #$08
	BEQ Dead3
	CMP #$09
	BEQ Dead3
	CMP #$0A
	BEQ Dead3

	LDA #$FF
	STA !Sprite2
	STA !Sprite3
	STA !Sprite4
	STA !Sprite5
	STA !Sprite6
	STA !Sprite7
	STA !Sprite8
	RTS

	Dead3:

	LDA !Sprite3
	BMI Dead4
	TAY
	LDA !14C8,y
	CMP #$08
	BEQ Dead4
	CMP #$09
	BEQ Dead4
	CMP #$0A
	BEQ Dead4

	LDA #$FF
	STA !Sprite3
	STA !Sprite4
	STA !Sprite5
	STA !Sprite6
	STA !Sprite7
	STA !Sprite8
	RTS

	Dead4:

	LDA !Sprite4
	BMI Dead5
	TAY
	LDA !14C8,y
	CMP #$08
	BEQ Dead5
	CMP #$09
	BEQ Dead5
	CMP #$0A
	BEQ Dead5


	LDA #$FF
	STA !Sprite4
	STA !Sprite5
	STA !Sprite6
	STA !Sprite7
	STA !Sprite8
	RTS

	Dead5:

	LDA !Sprite5
	BMI Dead6
	TAY
	LDA !14C8,y
	CMP #$08
	BEQ Dead6
	CMP #$09
	BEQ Dead6
	CMP #$0A
	BEQ Dead6


	LDA #$FF
	STA !Sprite5
	STA !Sprite6
	STA !Sprite7
	STA !Sprite8
	RTS

	Dead6:

	LDA !Sprite6
	BMI Dead7
	TAY
	LDA !14C8,y
	CMP #$08
	BEQ Dead7
	CMP #$09
	BEQ Dead7
	CMP #$0A
	BEQ Dead7


	LDA #$FF
	STA !Sprite6
	STA !Sprite7
	STA !Sprite8
	RTS

	Dead7:
	LDA !Sprite7
	BMI Dead8
	TAY
	LDA !14C8,y
	CMP #$08
	BEQ Dead8
	CMP #$09
	BEQ Dead8
	CMP #$0A
	BEQ Dead8


	LDA #$FF
	STA !Sprite7
	STA !Sprite8
	RTS

	Dead8:
	LDA !Sprite8
	BMI DeadEnd
	TAY
	LDA !14C8,y
	CMP #$08
	BEQ DeadEnd
	CMP #$09
	BEQ DeadEnd
	CMP #$0A
	BEQ DeadEnd

	LDA #$FF
	STA !Sprite8
	DeadEnd:
	RTS

MoveSprites:

	;move with sprite 1
	TXY
	PHX

	LDA !Sprite1
	BPL +
	JMP EndMove
	+
	TAX

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y

	LDA !D8,x
	STA $0E
	STA !D8,y
	LDA !14D4,x
	STA $0F
	STA !14D4,y

	LDA $13
	LSR
	LSR
	AND #$0F
	STA $0C

	%YOffset()

	TXY
	JSR VarHeight

	Move2:
	
	TXY
	PLX
	LDA !Sprite2
	PHX
	TYX
	CMP #$00
	BPL +
	JMP Move3
	+

	TAY

	%Height()

	%SetDirection()

	LDA #$00
	STA !AA,y
	STA !B6,y

	LDA $0E
	STA !D8,y	
	LDA $0F
	STA !14D4,y	

	%YOffset()

	%VarHeightB()
	%XPosition()
	
	Move3:
	
	TXY
	PLX
	LDA !Sprite3
	PHX
	TYX
	CMP #$00
	BPL +
	JMP Move4
	+

	TAY

	%Height()
	
	%SetDirection()

	LDA #$00
	STA !AA,y
	STA !B6,y

	LDA $0E
	STA !D8,y	
	LDA $0F
	STA !14D4,y	

	%YOffset()

	%VarHeightB()
	%XPosition()

	print "test ",pc

	Move4:
	
	TXY
	PLX
	LDA !Sprite4
	PHX
	TYX
	CMP #$00
	BPL +
	JMP Move5
	+

	TAY

	%Height()

	%SetDirection()

	LDA #$00
	STA !AA,y
	STA !B6,y

	LDA $0E
	STA !D8,y	
	LDA $0F
	STA !14D4,y	

	%YOffset()

	%VarHeightB()
	%XPosition()

	Move5:
	
	TXY
	PLX
	LDA !Sprite5
	PHX
	TYX
	CMP #$00
	BPL +
	JMP Move6
	+

	TAY

	%Height()

	%SetDirection()

	LDA #$00
	STA !AA,y
	STA !B6,y

	LDA $0E
	STA !D8,y	
	LDA $0F
	STA !14D4,y	

	%YOffset()

	%VarHeightB()
	%XPosition()

	Move6:
	
	TXY
	PLX
	LDA !Sprite6
	PHX
	TYX
	CMP #$00
	BPL +
	JMP Move7
	+

	TAY

	%Height()

	%SetDirection()

	LDA #$00
	STA !AA,y
	STA !B6,y

	LDA $0E
	STA !D8,y	
	LDA $0F
	STA !14D4,y	

	%YOffset()

	%VarHeightB()
	%XPosition()

	Move7:
	
	TXY
	PLX
	LDA !Sprite7
	PHX
	TYX
	CMP #$00
	BPL +
	JMP Move8
	+

	TAY

	%Height()

	%SetDirection()

	LDA #$00
	STA !AA,y
	STA !B6,y

	LDA $0E
	STA !D8,y	
	LDA $0F
	STA !14D4,y	

	%YOffset()

	%VarHeightB()
	%XPosition()

	Move8:
	
	TXY
	PLX
	LDA !Sprite8
	PHX
	TYX
	CMP #$00
	BPL +
	JMP EndMove
	+

	TAY

	%Height()

	%SetDirection()

	LDA #$00
	STA !AA,y
	STA !B6,y

	LDA $0E
	STA !D8,y	
	LDA $0F
	STA !14D4,y	

	%VarHeightB()
	%XPosition()

EndMove:
	PLX
	RTS


VarHeight:

	;carrot platform
	LDA !9E,y
	CMP #$B7
	BNE +

	REP #$20

	LDA $0E
	CLC
	ADC #$0010
	STA $0E

	SEP #$20

	+

	;goal post
	LDA !9E,y
	CMP #$7B
	BNE +

	REP #$20

	LDA $0E
	CLC
	ADC #$0008
	STA $0E

	SEP #$20

	+

	;pokey segments
	LDA !9E,y
	CMP #$70
	BNE +

	REP #$20

	LDA $0E
	CLC
	ADC #$0040
	STA $0E

	SEP #$20

	LDA !C2,y
	AND #$1E
	-
	LSR
	BEQ +
	PHA
	REP #$20

	LDA $0E
	SEC
	SBC #$0010
	STA $0E

	SEP #$20

	PLA
	BRA -
	+
	RTS

SpawnSprites:
	
	LDA !D8,x
	STA $0C
	LDA !14D4,x
	STA $0D


	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$00
	LDA [$00],y
	PLY

	CMP #$FF
	BNE +
	JMP Spawn2
	+

	JSL $02A9DE|!BankB
	BPL +
	JMP EndSpawn
	+

	TYA
	STA !Sprite1

	LDA #$01
	STA !14C8,y

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$00
	LDA [$00],y
	PLY

	JSR ShellCheck

	STA $09
	LDA #$80
	%IsCustom()

	BNE +

	PHX
	TYX
	LDA $09
	STA !9E,x

	JSL $07F7D2|!BankB
	PLX
	BRA ++
	+
	PHX
	TYX
	LDA $09
	STA !7FAB9E,x

	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA $08
	STA !7FAB10,x
	PLX
	++

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y

	LDA $0C
	STA !D8,y	
	LDA $0D
	STA !14D4,y	

	Spawn2:

	REP #$20
	LDA $0C
	SEC
	SBC #$0010
	STA $0C
	SEP #$20

	

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$01
	LDA [$00],y
	PLY

	CMP #$FF
	BNE +
	JMP Spawn3
	+

	JSL $02A9DE|!BankB
	BPL +
	JMP EndSpawn
	+

	TYA
	STA !Sprite2

	LDA #$01
	STA !14C8,y

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$01
	LDA [$00],y
	PLY

	JSR ShellCheck

	STA $09
	LDA #$40
	%IsCustom()

	BNE +

	PHX
	TYX
	LDA $09
	STA !9E,x

	JSL $07F7D2|!BankB
	PLX
	BRA ++
	+
	PHX
	TYX
	LDA $09
	STA !7FAB9E,x

	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA $08
	STA !7FAB10,x
	PLX
	++

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y

	LDA $0C
	STA !D8,y	
	LDA $0D
	STA !14D4,y	

	Spawn3:

	REP #$20
	LDA $0C
	SEC
	SBC #$0010
	STA $0C
	SEP #$20

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$02
	LDA [$00],y
	PLY
	CMP #$FF
	BNE +
	JMP Spawn4
	+

	JSL $02A9DE|!BankB
	BPL +
	JMP EndSpawn
	+

	TYA
	STA !Sprite3

	LDA #$01
	STA !14C8,y

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$02
	LDA [$00],y
	PLY

	JSR ShellCheck

	STA $09
	LDA #$20
	%IsCustom()

	BNE +

	PHX
	TYX
	LDA $09
	STA !9E,x

	JSL $07F7D2|!BankB
	PLX
	BRA ++
	+
	PHX
	TYX
	LDA $09
	STA !7FAB9E,x

	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA $08
	STA !7FAB10,x
	PLX
	++

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y

	LDA $0C
	STA !D8,y	
	LDA $0D
	STA !14D4,y	





	Spawn4:

	REP #$20
	LDA $0C
	SEC
	SBC #$0010
	STA $0C
	SEP #$20

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$03
	LDA [$00],y
	PLY
	CMP #$FF
	BNE +
	JMP Spawn5
	+

	JSL $02A9DE|!BankB
	BPL +
	JMP EndSpawn
	+

	TYA
	STA !Sprite4

	LDA #$01
	STA !14C8,y

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$03
	LDA [$00],y
	PLY

	JSR ShellCheck

	STA $09
	LDA #$10
	%IsCustom()

	BNE +

	PHX
	TYX
	LDA $09
	STA !9E,x

	JSL $07F7D2|!BankB
	PLX
	BRA ++
	+
	PHX
	TYX
	LDA $09
	STA !7FAB9E,x

	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA $08
	STA !7FAB10,x
	PLX
	++

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y

	LDA $0C
	STA !D8,y	
	LDA $0D
	STA !14D4,y	




Spawn5:

	REP #$20
	LDA $0C
	SEC
	SBC #$0010
	STA $0C
	SEP #$20

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$04
	LDA [$00],y
	PLY
	CMP #$FF
	BNE +
	JMP Spawn6
	+

	JSL $02A9DE|!BankB
	BPL +
	JMP EndSpawn
	+

	TYA
	STA !Sprite5

	LDA #$01
	STA !14C8,y

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$04
	LDA [$00],y
	PLY

	JSR ShellCheck

	STA $09
	LDA #$08
	%IsCustom()

	BNE +

	PHX
	TYX
	LDA $09
	STA !9E,x

	JSL $07F7D2|!BankB
	PLX
	BRA ++
	+
	PHX
	TYX
	LDA $09
	STA !7FAB9E,x

	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA $08
	STA !7FAB10,x
	PLX
	++

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y

	LDA $0C
	STA !D8,y	
	LDA $0D
	STA !14D4,y	


Spawn6:

	REP #$20
	LDA $0C
	SEC
	SBC #$0010
	STA $0C
	SEP #$20

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$05
	LDA [$00],y
	PLY
	CMP #$FF
	BNE +
	JMP Spawn7
	+

	JSL $02A9DE|!BankB
	BPL +
	JMP EndSpawn
	+

	TYA
	STA !Sprite6

	LDA #$01
	STA !14C8,y

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$05
	LDA [$00],y
	PLY

	JSR ShellCheck

	STA $09
	LDA #$04
	%IsCustom()

	BNE +

	PHX
	TYX
	LDA $09
	STA !9E,x

	JSL $07F7D2|!BankB
	PLX
	BRA ++
	+
	PHX
	TYX
	LDA $09
	STA !7FAB9E,x

	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA $08
	STA !7FAB10,x
	PLX
	++

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y

	LDA $0C
	STA !D8,y	
	LDA $0D
	STA !14D4,y	



Spawn7:

	REP #$20
	LDA $0C
	SEC
	SBC #$0010
	STA $0C
	SEP #$20

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$06
	LDA [$00],y
	PLY
	CMP #$FF
	BNE +
	JMP Spawn8
	+

	JSL $02A9DE|!BankB
	BPL +
	JMP EndSpawn
	+

	TYA
	STA !Sprite7

	LDA #$01
	STA !14C8,y

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$06
	LDA [$00],y
	PLY

	JSR ShellCheck

	STA $09
	LDA #$02
	%IsCustom()

	BNE +

	PHX
	TYX
	LDA $09
	STA !9E,x

	JSL $07F7D2|!BankB
	PLX
	BRA ++
	+
	PHX
	TYX
	LDA $09
	STA !7FAB9E,x

	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA $08
	STA !7FAB10,x
	PLX
	++

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y

	LDA $0C
	STA !D8,y	
	LDA $0D
	STA !14D4,y	


Spawn8:

	REP #$20
	LDA $0C
	SEC
	SBC #$0010
	STA $0C
	SEP #$20

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$07
	LDA [$00],y
	PLY
	CMP #$FF
	BNE +
	JMP EndSpawn
	+

	JSL $02A9DE|!BankB
	BPL +
	JMP EndSpawn
	+

	TYA
	STA !Sprite8

	LDA #$01
	STA !14C8,y

	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	PHY
	LDY #$07
	LDA [$00],y
	PLY

	JSR ShellCheck

	STA $09
	LDA #$01
	%IsCustom()

	BNE +

	PHX
	TYX
	LDA $09
	STA !9E,x

	JSL $07F7D2|!BankB
	PLX
	BRA ++
	+
	PHX
	TYX
	LDA $09
	STA !7FAB9E,x

	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA $08
	STA !7FAB10,x
	PLX
	++

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y

	LDA $0C
	STA !D8,y	
	LDA $0D
	STA !14D4,y	

	EndSpawn:

	RTS

ShellCheck:
	CMP #$00
	BPL +

	CMP #$DF
	BEQ ++
	CMP #$DA
	BMI +
	CMP #$DE
	BPL +

	++
	SEC
	SBC #$D6
	PHA

	PHX
	TYX
	LDA #$09
	STA !14C8,x
	PLX

	PLA
	+
	RTS