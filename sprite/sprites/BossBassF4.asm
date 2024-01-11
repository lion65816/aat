;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boss Bass
;; by Sonikku
;; Description: A large fish sprite that will lunge at Mario and attempt to eat him.
;; 
;; Although the code isn't perfect and is prone to odd behavior:
;;     If this sprite detects a vertical Layer 2 Scroll generator, it will attempt to move with layer 2.
;;     If this sprite detects a Layer 3 Tide, it will appear and chase at the surface of the water.
;; If layer 1 can vertically scroll, ensure that layer 2 (or 3) has the "constant" scroll setting, as "variable" or "none"
;; can cause odd behavior.
;; 
;; This sprite does not require Sprite Buoyancy to be enabled.
;; 
;; Uses Extra Bit: YES
;; If Extra Bit is set, it will be 16x16 and move slightly slower, and be capable of dying to stomps and unable to eat Mario.

	print "INIT ",pc
SpriteInit:
	LDA !D8,x	; \
	STA !1510,x	;  | setup surface coordinates
	LDA !14D4,x	;  | 
	STA !151C,x	; /
	LDA !1534,x	; \ branch if already cheep cheep
	BNE .small	; /
	LDA !7FAB10,x	; \
	AND #$04	;  | branch if the extra bit isn't set
	BEQ +		; /
.small	INC !1534,x	; mark sprite as the cheep cheep
	LDA !1656,x	; \
	ORA #$10	;  | sprite can be stomped
	STA !1656,x	; /
	LDA !167A,x	; \
	AND #$7B	;  | sprite uses default interaction
	STA !167A,x	; /
+	RTL		; 

	print "MAIN ",pc
SpriteMain:
	PHB
	PHK
	PLB
	JSR BossBass_Main
	PLB
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite routine

BossBass_Main:
	LDA #$00 : %SubOffScreen()

	LDA !157C,x	; \
	PHA		;  | 
	LDA !B6,x	;  | 
	BEQ +		;  | 
	STZ !157C,x	;  | 
	LDA !B6,x	;  | all this does is make $157C,x be based on x speed, but it only applies graphically
	BMI +		;  | 
	INC !157C,x	;  | 
+	JSR SubGfx	;  | 
	PLA		;  | 
	STA !157C,x	; / 

	LDA $9D		; \ don't run if sprites are locked
	BNE .return	; /

	LDA !C2,x	; \ branch if not being eaten
	BEQ +		; /
	LDA #$C0	; \ put mario's y (high) position at a ridiculously high number
	STA $97		; /
	LDA #$FF	; \ make mario invisible
	STA $78		; /
	STA $18BD|!Base2; 
	STA $1404|!Base2; 
	STZ $13F1|!Base2; 
	STZ $1412|!Base2; \ no camera movement
	STZ $1413|!Base2; / 
	STZ $7D		; no x speed
	STZ $7B		; no y speed
	LDA !1540,x	; \ branch if timer is non-zero
	BNE +		; /
	JSL $00F606|!BankB; kill mario
+
	LDA !14C8,x	; 
	CMP #$08	; 
	BEQ +		; 
.return	RTS
+	JSL $018022|!BankB	; \ update x/y positions based on speed
	JSL $01801A|!BankB	; /

	LDA $1BE3|!Base2; \ branch if no layer 3 image
	BEQ .l2scroll	; /
	CMP #$03	; \ branch if tile-specific layer 3 image
	BEQ .l2scroll	; /

	REP #$20	; \
	LDA $24		;  | 
	SEC		;  | 
	SBC $1C		;  | 
	EOR #$FFFF	;  | 
	INC		;  | do some math to make the surface coordinate the surface of layer 3 tides
	CLC		;  | 
	ADC #$0100	;  | 
	SEP #$20	;  | 
	STA !1510,x	;  | 
	XBA		;  | 
	STA !151C,x	; /
	BRA .no_l2scroll; 
.l2scroll
	REP #$20	; \
	LDA $144C|!Base2;  | branch if layer 2 has no velocity
	SEP #$20	;  | 
	BEQ .no_l2scroll; /
	LDY #$00	; \
	LDA $17BE|!Base2;  | 
	EOR #$FF	;  | 
	INC		;  | 
	BPL +		;  | 
	DEY		;  | move sprite's surface coordinate according to layer 2 movement
+	CLC		;  | 
	ADC !1510,x	;  | 
	STA !1510,x	;  | 
	TYA		;  | 
	ADC !151C,x	;  | 
	STA !151C,x	; /
.no_l2scroll
	LDA !1534,x	; \ branch if sprite is Big Bertha
	BEQ .eatmario	; /
	JSL $01A7DC|!BankB; default interaction with mario
	BRA .nocontact	; 
.eatmario
	LDA !167A,x	; 
	PHA		; 
	LDA $1490|!Base2; \ branch if starman
	BNE .def	; /
	LDA !1594,x	; \
	CMP #$01	;  | branch if lunging
	BEQ +		; /
.def	STZ !167A,x	; default interaction with mario
+	JSL $01A7DC|!BankB; \ branch if no contact
	BCC +		; /
	LDA #$01	; \
	STA !C2,x	;  | eat mario
	LDA #$30	;  | 
	STA !1540,x	; /
+	PLA		; 
	STA !167A,x	; 
.nocontact
	INC !1570,x	; increment frame counter
	LDA !D8,x	; \
	STA $0C		;  | sprite's real-y coordinates
	LDA !14D4,x	;  | 
	STA $0D		; /
	LDA !1510,x	; \
	STA $0E		;  | sprite's surface-y coordinates
	LDA !151C,x	;  | 
	STA $0F		; /
	STZ !1602,x	; display non-lunging frame
	LDY !1594,x	; \
	LDA !B6,x	;  | 
	CLC		;  | 
	ADC .yvel_limit,y; | 
	BMI +		;  | accelerate y speed based on state
	LDA .yaccel,y	;  | 
	CLC		;  | 
	ADC !AA,x	;  | 
+	STA !AA,x	; /
	LDA !1594,x	; \ index by eat state
	JSL $0086DF|!BankB; /
	dw .swimming
	dw .jumpingup
	dw .resurface
.swimming
	LDA !1510,x	; \
	STA !D8,x	;  | sprite is locked onto surface position
	LDA !151C,x	;  | 
	STA !14D4,x	; /

	%SubHorzPos()	; \
	LDA $0E		;  | 
	CLC		;  | 
	ADC .x_diff,y	;  | chase mario and turn around if far enough away
	BPL +		;  | 
	TYA		;  | 
	EOR #$01	;  | 
	STA !157C,x	; /
+	LDA !14E0,x	; \
	XBA		;  | 
	LDA !E4,x	;  | 
	REP #$20	;  | 
	SEC		;  | 
	SBC $94		;  | branch if not close enough horizontally
	CLC		;  | 
	ADC #$0020	;  | 
	CMP #$0040	;  | 
	SEP #$20	;  | 
	BCS +		; /
	LDA !14D4,x	; \
	XBA		;  | 
	LDA !D8,x	;  | 
	REP #$20	;  | 
	SEC		;  | branch if not close enough vertically
	SBC $96		;  | 
	CMP #$0048	;  | 
	SEP #$20	;  | 
	BCS +		; /
	LDA #$D8	; \ set y speed
	STA !AA,x	; /
	LDA !B6,x	; \
	ASL		;  | cut some of sprite's velocity
	ROR !B6,x	; /
	LDA #$01	; \ sprite is in "lunging" state
	STA !1594,x	; /

	JSR WaterSplash	; display water splash
+	LDY !157C,x	; \
	LDA !1534,x	;  | 
	BEQ +		;  | 
	INY : INY	;  | 
+	LDA !B6,x	;  | 
	CLC		;  | accelerate sprite based on direction
	ADC .xvel_limit,y; | 
	BMI +		;  | 
	LDA !B6,x	;  | 
	CLC		;  | 
	ADC .xaccel,y	;  | 
	STA $B6,x	; /
+	RTS		; 
.jumpingup
	INC !1602,x	; lunging frame
	REP #$20	; \
	LDA $0E		;  | 
	SEC		;  | branch if sprite is above surface
	SBC $0C		;  | 
	SEP #$20	;  | 
	BCS +		; /
	LDA !AA,x	; \ branch if sprite is moving up
	BMI +		; /
	LDA #$18	; \ set y speed
	STA !AA,x	; /
	INC !1594,x	; sprite is in "resurfacing" state
	JSR WaterSplash	; display water splash
+	RTS
.resurface
	REP #$20	; \
	LDA $0E		;  | 
	SEC		;  | branch if sprite is below surface
	SBC $0C		;  | 
	SEP #$20	;  | 
	BCC +		; /
	LDA !AA,x	; \ branch if sprite is moving down
	BPL +		; /
	STZ !1594,x	; sprite is in "chasing" state
+	RTS		; 
.yaccel
	db $00,$01,$FE
.yvel_limit
	db $00,$20,$10
.xvel_limit
	db $30,$50,$20,$60
.xaccel	db $FC,$04,$FF,$01
.x_diff	db $10,$70

WaterSplash:
	LDA !1534,x	; \ branch if Big Bertha
	BEQ .bigbertha	; /
	LDA #$02	; \ set index to splash coordinate
	STA $00		; /
	BRA +		; 
.bigbertha
	STZ $00		; splash coordinate = 0
	JSR +		; 
	INC $00		; splash coordinate = 1
+	LDY #$0B	; \
-	LDA $17F0|!Base2,y;| 
	BEQ +		;  | branch if free slot, loop otherwise
	DEY		;  | 
	BPL -		; /
	INY		; if no free slots, create one
+	LDA !D8,x	; \
	CLC		;  | 
	ADC #$F4	;  | 
	STA $17FC|!Base2,y;| sprite y position = splash y position
	LDA !14D4,x	;  | 
	ADC #$FF	;  | 
	STA $1814|!Base2,y;/
	PHY		; \
	LDY $00		;  | 
	LDA !E4,x	;  | 
	CLC		;  | 
	ADC .xpos,y	;  | 
	PLY		;  | 
	STA $1808|!Base2,y;| sprite x position + variable = splash x position
	PHY		;  | 
	LDY $00		;  | 
	LDA !14E0,x	;  | 
	ADC .xpos2,y	;  | 
	PLY		;  | 
	STA $18EA|!Base2,y;/
	LDA #$07	; \ sprite type
	STA $17F0|!Base2,y;/
	LDA #$00	; \ timer for splash
	STA $1850|!Base2,y;/
	RTS		; 
.xpos	db $FC,$04,$00
.xpos2	db $FF,$00,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine

SubGfx:	%GetDrawInfo()       ; sets y = OAM offset

	STZ $04
	LDA !14C8,x
	CMP #$08
	BEQ +
	LDA #$05
	STA $04
+

	LDA !1534,x
	BEQ .bigbertha

	LDA !157C,x
	STA $02

	LDA !1570,x
	LSR : LSR : LSR
	AND #$01
	STA $03

	PHX
	LDA $00
	STA $0300|!Base2,y
	LDA $01
	STA $0301|!Base2,y
	LDX $03
	LDA .tilemap2,x
	STA $0302|!Base2,y

	LDX $15E9|!Base2
	LDA !15F6,x
	LDX $02
	BEQ +
	ORA #$40
+	LDX $04
	BEQ +
	ORA #$80
+	ORA $64
	STA $0303|!Base2,y
	PLX

	LDY #$02
	LDA #$00
	JMP .finishoam

.bigbertha
	LDA !157C,x
	ASL : ASL
	ADC !157C,x
	STA $02

	PHY
	LDY !1602,x
	LDA !1570,x
	LSR : LSR : LSR
	AND #$01
	BNE +
	INY : INY
+	TYA
	PLY
	STA $03
	ASL : ASL
	ADC $03
	STA $03

	PHX
	LDX #$04
-	PHX
	TXA
	CLC
	ADC $02
	TAX
	LDA .xpos,x
	PLX
	CLC
	ADC $00
	STA $0300|!Base2,y

	PHX
	TXA
	CLC
	ADC $04
	TAX
	LDA .ypos,x
	PLX
	CLC
	ADC $01
	STA $0301|!Base2,y

	PHX
	TXA
	CLC
	ADC $03
	TAX
	LDA .tilemap,x
	PLX
	STA $0302|!Base2,y

	PHX
	LDX $15E9|!Base2
	LDA !15F6,x
	LDX $02
	BEQ +
	ORA #$40
+	LDX $04
	BEQ +
	ORA #$80
+	PLX
	ORA $64
	STA $0303|!Base2,y

	PHY
	TYA
	LSR : LSR
	TAY
	LDA .tilesize,x
	STA $0460|!Base2,y
	PLY

	INY : INY : INY : INY
	DEX
	BPL -
	PLX
		LDY #$FF
		LDA #$04
.finishoam	JSL $01B7B3|!BankB
		RTS

.xpos	db $00,$08,$00,$10,$10
	db $08,$00,$08,$00,$00
.ypos	db $FA,$FA,$0A,$0A,$12
	db $0A,$0A,$FA,$02,$FA
.tilesize
	db $02,$02,$02,$00,$00
.tilemap
	db $8B,$8C,$C4,$C8,$D8
	db $8B,$8C,$C6,$C8,$D8
	db $8B,$8C,$C4,$C9,$D9
	db $8B,$8C,$C6,$C9,$D9

.tilemap2
	db $67,$69