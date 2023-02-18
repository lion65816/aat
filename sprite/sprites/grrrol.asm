;===============;
;grrrol from NSMBU ;
;===============;
frm1:						;direction 1	(157C=0)
db $00,$01,$02,$03,$04,$05,$06,$07,$00
frm2:						;direction 2	(157C>0)
db $00,$07,$06,$05,$04,$03,$02,$01,$00
xspd:
db $15,$EA

!Yoffset = #$03		;Offset for GFX Y Position.
			;Keep it at #$00 if your GFX occupy the whole 32x32 sheet.
;!ThisSpriteNum = #$3D	;grrrol.cfg sprite num

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print "INIT ",pc
	STZ !157C,x
	LDA !7FAB10,X
	AND #$04
	BEQ EndInit
	INC !157C,x
EndInit:
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL

Return:
	RTS

Run:
	JSR Graphics
	LDA $9D
	BNE Return
	LDA !14C8,x
	CMP #$08
	BNE Return
	JSR SUB_OFF_SCREEN_X0
	JSL $01802A|!bank
	JSL $019138|!bank
	JSL $01A7DC|!bank
	JSR Bump
	LDA !1588,x
	AND #$04
	BNE .roll
	LDA #$01
	STA !160E,x
	RTS

.roll
LDA !160E,x
BEQ .dont
JSR YoshiSmoke
LDA #$09
STA $1DFC|!addr
LDA #$04
STA $1887|!addr
STZ !160E,x
.dont
JSR Anim
JSR SpawnTurn		;turn smoke
;JSR Spritecont
LDY !157C,x
LDA xspd,y
STA !B6,x
RTS

Anim:
LDA !157C,x
BEQ .noflip
JMP .dir2
.noflip
lda !1602,X
lsr
lsr
tay
lda frm1,y
sta !1504,x
JMP .stuff2
.dir2
lda !1602,X
lsr
lsr
tay
lda frm2,y
sta !1504,x
.stuff2
LDA !1602,X
CMP #$21
BNE .thing1
STZ !1602,X
RTS
.thing1
INC !1602,X
RTS

Bump:
LDA !1588,x
AND #$03
BEQ .nobump
LDA !B6,x
EOR #$FF
STA !B6,x
LDA #$EA
STA !AA,x
LDA !157C,x
EOR #$01
STA !157C,x
LDA #$01
STA $1DF9|!addr
.nobump
RTS

SpawnTurn:
LDA $14
LSR
LSR
LSR
AND #$01
BEQ .dospawn
RTS
.dospawn
	LDY #$03
-
	LDA $17C0|!addr,y
	BEQ +
	DEY
	BPL -
	RTS
+
	LDA #$03
	STA $17C0|!addr,y
	LDA #$0F
	STA $17CC|!addr,y
	LDA !D8,x
	CLC
	ADC #$0A
	STA $17C4|!addr,y
	LDA !E4,x
	CLC
	ADC #$04
	STA $17C8|!addr,y
	RTS

YoshiSmoke:
	LDA #$01	; \ load times to run code
	STA $00		; /
--	LDY #$07	; load times to loop
-	LDA $170B|!addr,y	; \ branch if not free slot
	BNE +		; /
	JSR .spawnsmoke	; spawn smoke
	BRA ++		; done searching
+	DEY		; \ loop if not a free slot
	BPL -		; /
++	DEC $00		; \
	LDA $00		;  | loop once more
	BPL --		; /
	RTS		;
.spawnsmoke
	LDA #$0F	; \ extended sprite number
	STA $170B|!addr,y	; /

	LDA !14D4,x	; \
	XBA		;  |
	LDA !D8,x	;  |
	REP #$20	;  |
	CLC		;  | y position from sprite
	ADC #$0008	;  |
	SEP #$20	;  |
	STA $1715|!addr,y	;  |
	XBA		;  |
	STA $1729|!addr,y	; /


	LDA !E4,x	; \
	STA $171F|!addr,y	;  | x position from sprite
	LDA !14E0,x	;  |
	STA $1733|!addr,y	; /

	PHX		; \
	LDX $00		;  |
	LDA .xspd,x	;  | set x speed
	PLX		;  |
	STA $1747|!addr,y	; /
	LDA #$10	; \ set timer to live
	STA $176F|!addr,y	; /
	RTS		;
.xspd	db $18,$E8

;Spritecont:
;JSL $018032
;BCC .ret
;PHX
;TYX
;LDA $7FAB9E,X
;TXY
;PLX
;CMP !ThisSpriteNum		;if the other sprite is also a grrrol, bounce off.
;BNE .ret
;LDA $B6,x
;EOR #$FF
;STA $B6,x
;LDA #$E0
;STA $AA,x
;LDA $157C,x
;EOR #$01
;STA $157C,x
;LDA #$01
;STA $1DF9
;.ret
;RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Graphics routine
;
;don't think this must be the right way to do this but anyway
;also planned was a dynamic version (would be way easier), but i thought it would be unneeded

PROPERTIES:
    db $03,$03,$03,$03	;no flip
    db $03,$03,$03,$03	;no flip
    db $03,$03,$03,$03	;no flip
    db $83,$83,$83,$83	;y flip
    db $83,$83,$83,$83	;y flip
    db $C3,$C3,$C3,$C3	;xy flip
    db $43,$43,$43,$43	;x flip
    db $43,$43,$43,$43	;x flip

TILEMAP:
    db $80,$82,$A0,$A2	;1
    db $84,$86,$A4,$A6	;2
    db $C0,$C2,$E0,$E2	;3
    db $84,$86,$A4,$A6	;2
    db $80,$82,$A0,$A2	;1
    db $84,$86,$A4,$A6	;2
    db $C0,$C2,$E0,$E2	;3
    db $84,$86,$A4,$A6	;2

YDISP:
    db $F0,$F0,$00,$00	;normal
    db $F0,$F0,$00,$00	;normal
    db $F0,$F0,$00,$00	;normal
    db $00,$00,$F0,$F0	;invert
    db $00,$00,$F0,$F0	;invert
    db $00,$00,$F0,$F0	;invert
    db $F0,$F0,$00,$00	;normal
    db $F0,$F0,$00,$00	;normal

XDISP:
    db $F8,$08,$F8,$08	;normal
    db $F8,$08,$F8,$08	;normal
    db $F8,$08,$F8,$08	;normal
    db $F8,$08,$F8,$08	;normal
    db $F8,$08,$F8,$08	;normal
    db $08,$F8,$08,$F8	;invert
    db $08,$F8,$08,$F8	;invert
    db $08,$F8,$08,$F8	;invert

Graphics:
    JSR GET_DRAW_INFO

;    LDA $157C,x	;unused
;    STA $02

    LDA !1504,X		;frm
    ASL #2
    STA $03

    LDA !C2,x
    STA $04

    PHX
    LDX #$03
Loop:
    TXA
    STA $02
    TAX

    PHX
    LDX $03
    TXA
    CLC
    ADC $02
    TAX
    LDA $00
    CLC
    ADC XDISP,x
    STA $0300|!addr,y
    PLX

    PHX
    LDX $03
    TXA
    CLC
    ADC $02
    TAX
    LDA $01
    CLC
    ADC YDISP,x
    CLC
    ADC !Yoffset		;offset y position
    STA $0301|!addr,y
    PLX

    PHX
    TXA
    CLC
    ADC $03
    TAX
    LDA TILEMAP,x
    STA $0302|!addr,y

    PHX
    LDX $03
    TXA
    CLC
    ADC $02
    TAX
    LDA PROPERTIES,x
    ORA $64
    STA $0303|!addr,y
    PLX

    INY #4
    PLX
    DEX
    BPL Loop
    PLX
    LDY #$02
    LDA #$06
    JSL $01B7B3|!bank
    RTS

;=================;
;SUB_HORZ_POS
;=================;

SUB_HORZ_POS:
	LDY #$00
	LDA $D1
	SEC
	SBC !E4,x
	STA $0F
	LDA $D2
	SBC !14E0,x
	BPL SPR_L16
	INY
SPR_L16:
	RTS

;=================;
;SUB_VERT_POS
;=================;

SUB_VERT_POS:
	LDY #$00
	LDA $D3
	SEC
	SBC !D8,x
	STA $0F
	LDA $D4
	SBC !14D4,x
	BPL SPR_L11
	INY
SPR_L11:
	RTS

;=================;
;SUB_OFF_SCREEN
;=================;

SPR_T12:
	db $40,$B0
SPR_T13:
	db $01,$FF
SPR_T14:
	db $30,$C0,$A0,$C0,$A0,$F0,$60,$90
	db $30,$C0,$A0,$80,$A0,$40,$60,$B0
SPR_T15:
	db $01,$FF,$01,$FF,$01,$FF,$01,$FF
	db $01,$FF,$01,$FF,$01,$00,$01,$FF

SUB_OFF_SCREEN_X1:
	LDA #$02
	BRA STORE_03
SUB_OFF_SCREEN_X2:
	LDA #$04
	BRA STORE_03
SUB_OFF_SCREEN_X3:
	LDA #$06
	BRA STORE_03
SUB_OFF_SCREEN_X4:
	LDA #$08
	BRA STORE_03
SUB_OFF_SCREEN_X5:
	LDA #$0A
	BRA STORE_03
SUB_OFF_SCREEN_X6:
	LDA #$0C
	BRA STORE_03
SUB_OFF_SCREEN_X7:
	LDA #$0E
STORE_03:
	STA $03
	BRA START_SUB
SUB_OFF_SCREEN_X0:
	STZ $03

START_SUB:
	JSR SUB_IS_OFF_SCREEN
	BEQ RETURN_35
	LDA $5B
	AND #$01
	BNE VERTICAL_LEVEL
	LDA !D8,x
	CLC
	ADC #$50
	LDA !14D4,x
	ADC #$00
	CMP #$02
	BPL ERASE_SPRITE
	LDA !167A,x
	AND #$04
	BNE RETURN_35
	LDA $13
	AND #$01
	ORA $03
	STA $01
	TAY
	LDA $1A
	CLC
	ADC SPR_T14,y
	ROL $00
	CMP !E4,x
	PHP
	LDA $1B
	LSR $00
	ADC SPR_T15,y
	PLP
	SBC !14E0,x
	STA $00
	LSR $01
	BCC SPR_L31
	EOR #$80
	STA $00
SPR_L31:
	LDA $00
	BPL RETURN_35
	ERASE_SPRITE:
	LDA !14C8,x
	CMP #$08
	BCC KILL_SPRITE
	LDY !161A,x
	CPY #$FF
	BEQ KILL_SPRITE
	LDA #$00
	PHX
	TYX
	STA !1938,x	;
	PLX
KILL_SPRITE:
	STZ !14C8,x
RETURN_35:
	RTS

VERTICAL_LEVEL:
	LDA !167A,x
	AND #$04
	BNE RETURN_35
	LDA $13
	LSR A
	BCS RETURN_35
	LDA !E4,x
	CMP #$00
	LDA !14E0,x
	SBC #$00
	CMP #$02
	BCS ERASE_SPRITE
	LDA $13
	LSR A
	AND #$01
	STA $01
	TAY
	LDA $1C
	CLC
	ADC SPR_T12,y
	ROL $00
	CMP !D8,x
	PHP
	LDA $001D|!dp
	LSR $00
	ADC SPR_T13,y
	PLP
	SBC !14D4,x
	STA $00
	LDY $01
	BEQ SPR_L38
	EOR #$80
	STA $00
SPR_L38:
	LDA $00
	BPL RETURN_35
	BMI ERASE_SPRITE

SUB_IS_OFF_SCREEN:
	LDA !15A0,x
	ORA !186C,x
	RTS

;================;
;GET_DRAW_INFO
;================;

SPR_T1:
	db $0C,$1C
SPR_T2:
	db $01,$02

GET_DRAW_INFO:
	STZ !186C,x
	STZ !15A0,x
	LDA !E4,x
	CMP $1A
	LDA !14E0,x
	SBC $1B
	BEQ ON_SCREEN_X
	INC !15A0,x

ON_SCREEN_X:
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	SEC
	SBC $1A
	CLC
	ADC.w #$0040
	CMP.w #$0180
	SEP #$20
	ROL A
	AND #$01
	STA !15C4,x
	BNE INVALID

	LDY #$00
	LDA !1662,x
	AND #$20
	BEQ ON_SCREEN_LOOP
	INY
ON_SCREEN_LOOP:
	LDA !D8,x
	CLC
	ADC SPR_T1,y
	PHP
	CMP $1C
	ROL $00
	PLP
	LDA !14D4,x
	ADC #$00
	LSR $00
	SBC $1D
	BEQ ON_SCREEN_Y
	LDA !186C,x
	ORA SPR_T2,y
	STA !186C,x
ON_SCREEN_Y:
	DEY
	BPL ON_SCREEN_LOOP
	LDY !15EA,x
	LDA !E4,x
	SEC
	SBC $1A
	STA $00
	LDA !D8,x
	SEC
	SBC $1C
	STA $01
	RTS

INVALID:
	PLA
	PLA
	RTS
;endregion