;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Para-Beetle, by Romi, modified by imamelia
; Toxic version and some customization options by MarkAlarm
;
; This is a sprite from SMB3, a Buzzy Beetle that flies through the air and can
; carry the player.
;
; Extra byte 1:
;
; remember that byte format is in bit order 7/6/5/4/3/2/1/0
; Bits 0-2: index to sprite palette and speed. 00 -> palette 8, 01 -> palette 9... 07 -> palette F. speed table is further down
; Bit 3: size, 0 -> normal, 1 -> giant
; Bits 4-5: initial direction, 00 -> face toward player, 01 -> face left, 02 -> face right, 03 -> face away from player
; Bits 6-7: toxicity, 00 -> do nothing while standing on, 01 -> hurt while standing on, 02/03 -> kill while standing on

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;!GFXFile1 = $008B
;!GFXFile2 = $00B3
;!GFXFile3 = $00B4
;!GFXFile4 = $00B4

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tilemap:
;	db $00,$02
	db $E4,$E6

TileXDisp2:
	db $10,$00,$10,$00
	db $10,$00,$10,$00
	db $00,$10,$00,$10
	db $00,$10,$00,$10

TileYDisp2:
	db $F7,$F7,$07,$07
	db $F7,$F7,$07,$07
	db $F7,$F7,$07,$07
	db $F7,$F7,$07,$07
;	db $00,$00,$10,$10
;	db $00,$00,$10,$10
;	db $00,$00,$10,$10
;	db $00,$00,$10,$10

Tilemap2:
;	db $00,$02,$04,$06
;	db $08,$0A,$0C,$0E
;	db $00,$02,$04,$06
;	db $08,$0A,$0C,$0E
	db $C8,$CA,$E8,$EA
	db $CC,$CE,$EC,$EE
	db $C8,$CA,$E8,$EA
	db $CC,$CE,$EC,$EE

TileProps2:
	db $40,$40,$40,$40
	db $40,$40,$40,$40
	db $00,$00,$00,$00
	db $00,$00,$00,$00

; SpritePalette:
; db $08,$0A,$06,$04

XSpeed:
	db $0C,$0C,$06,$1A,$0C,$14,$0C,$0C		; normal speeds. order is sequential with the palette (first = palette 8, last = palette F)
	db $0A,$0A,$05,$17,$0A,$12,$0A,$0A		; giant speeds
	
	; db $0C,$14,$1A,$06
	; db $0A,$12,$17,$05

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ",pc
	PHB
	PHK
	PLB
	JSR SpriteInitRt
	PLB
	RTL

SpriteInitRt:
;	LDA $7FAB40,x
;	AND #$04
;	BNE .SetAltFile
;	LDA.b #!GFXFile1
;	STA $7F88D0,x
;	LDA.b #!GFXFile1>>8
;	STA $7F88DC,x
;	LDA.b #!GFXFile2
;	STA $7F88E8,x
;	LDA.b #!GFXFile2>>8
;	STA $7F88F4,x
;	BRA .Shared
;.SetAltFile
;	LDA.b #!GFXFile3
;	STA $7F88D0,x
;	LDA.b #!GFXFile3>>8
;	STA $7F88DC,x
;	LDA.b #!GFXFile4
;	STA $7F88E8,x
;	LDA.b #!GFXFile4>>8
;	STA $7F88F4,x
;.Shared
	LDA !7FAB40,x
	STA $00
	AND #$0F
	STA !1510,x						; 1510 = palette and size index for speeds
	AND #$07
	ASL
	STA $01
	
	LDA !15F6,x
	AND #$F1
	ORA $01
	STA !15F6,x
	
	LDA $00
	AND #$C0
	STA !1FD6,x						; 1FD6 = toxicity
	
	; LDA !7FAB40,x
	; STA $00
	; AND #$07
	; STA !1510,x
	; LDA $00
	; AND #$03
	; TAY
	; LDA !15F6,x
	; AND #$F1
	; ORA SpritePalette,y
	; STA !15F6,x
	LDA $00
	AND #$08
	STA !151C,x						; 151C = size
.FacePlayer
	LDA $94
	CMP !E4,x
	LDA $95
	SBC !14E0,x
	BPL .EndInit
	INC !157C,x
.EndInit
	LDA $00
	AND #$30
	BEQ .Return
	CMP #$30
	BEQ .FaceAway
	LSR #4
	DEC
	EOR #$01
	STA !157C,x
.Return
	RTS
.FaceAway
	LDA !157C,x
	EOR #$01
	STA !157C,x
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteMainRt
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SpriteMainRt:
	JSR SubGFX
	LDA !14C8,x
	EOR #$08
	ORA $9D
	BNE ReturnMain
	
	LDA #$00
	%SubOffScreen()
DummyLabel0:
	INC !1570,x
	LDY !1510,x
	LDA XSpeed,y
	LDY !157C,x
	BEQ .NoFlipSpeed
	EOR #$FF
	INC
.NoFlipSpeed
	STA !B6,x
	LDA !1504,x
	BNE .Update
	LDA !151C,x
	BNE .Update
	LDA #$01
	LDY !AA,x
	BEQ .Update
	BMI .YSpeed000
	DEC : DEC
.YSpeed000
	CLC
	ADC !AA,x
	STA !AA,x
.Update
	JSL $01801A|!BankB
	JSL $018022|!BankB
	LDA $1491|!Base2
	STA !1528,x
	LDY #$B9
	LDA $1490|!Base2
	BEQ .StoreTo167A
	LDY #$39
.StoreTo167A
	TYA	
	STA !167A,x
	LDA !15D0,x
	BNE ReturnMain
	
	LDA !151C,x
	BEQ .DefaultClipping
	JSL $018032|!BankB
	JSR CustomClippingRt
	BRA .MakeSpriteSolid
.DefaultClipping
	JSL $01803A|!BankB
.MakeSpriteSolid
	BCC Return2
	PHK
	PEA Continue-1
	PEA $8020
	JML $01B45C|!BankB
ReturnMain:
	RTS
Continue:
	BCC .SpriteWins
	LDA !1504,x
	BNE .PlayerWins000
	LDA #$01
	STA !1504,x
	LDY #$10
	LDA !151C,x
	BEQ .SetYSpeed
	LDY #$03
.SetYSpeed
	STY !AA,x
.PlayerWins000
	LDA !1FD6,x						; if not set to be toxic, don't do anything
	BEQ +
	CMP #$40						; check to hurt
	BNE ..kill						; basically if the highest bit is set, we have to kill
	JSL $00F5B7|!BankB
	BRA +
	..kill
	JSL $00F606|!BankB
	+

	LDA #$08
	STA !154C,x
	LDA !151C,x
	BNE .Return
	LDA !AA,x
	DEC
	CMP #$F0
	BMI .Return
	STA !AA,x
.Return
	RTS
.SpriteWins
	LDA !154C,x
	BNE Return2
	JSL $00F5B7|!BankB
Return2:
	LDA !154C,x
	BNE ReturnMain
	STZ !1504,x
	LDA !151C,x
	BEQ .NoResetSpeed
	STZ !AA,x
.NoResetSpeed
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; graphics routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubGFX:
;	JSL !GetDrawInfoPlus
	%GetDrawInfo()
	LDA !15F6,x
	ORA $64
	STA $03
	LDA !1602,x
	STA $04
	LDA !157C,x
	STA $05
	LDA !1570,x
	LSR #2
	LDY !1504,x
	BNE .FastAnimation
	LSR
.FastAnimation
	AND #$01
	STA $06
	LDY !15EA,x
	LDA !151C,x
	BNE GiantGFX
	LDA $00
	STA $0300|!Base2,y
	LDA $01
	SEC
	SBC #$02
	STA $0301|!Base2,y
	LDX $06
	LDA Tilemap,x
;	ORA $02
	STA $0302|!Base2,y
	LDX $15E9|!Base2
	LDA $03
	LSR $05
	BCS $02
	ORA #$40
	STA $0303|!Base2,y
	LDY #$02
	LDA #$00
	JSL $01B7B3|!BankB	
	RTS

GiantGFX:
;	LDA $15F6,x
;	ORA $64
;	STA $04
	LDA #$03
	STA $07
	LDA $06
	ASL #2
	EOR #$04
	ORA #$03
	STA $06
	LDA $05
	ASL #3
	TSB $06
.Loop
	LDX $06
	LDA $00
	CLC
	ADC TileXDisp2,x
	STA $0300|!Base2,y
	LDA $01
	CLC
	ADC TileYDisp2,x
	STA $0301|!Base2,y
	LDA Tilemap2,x
;	ORA $02
	STA $0302|!Base2,y
	LDA $03
	ORA TileProps2,x
	STA $0303|!Base2,y
	INY #4
	DEC $06
	DEC $07
	BPL .Loop
	LDX $15E9|!Base2
	LDY #$02
	LDA #$03
	JSL $01B7B3|!BankB	
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; custom clipping routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CustomClippingRt:
	JSL $03B664|!BankB
	JSR SetSpriteClipping
	JSL $03B72B|!BankB
	RTS

;------------------------------------------------
; set up the sprite's clipping field
;------------------------------------------------

SetSpriteClipping:		; custom sprite clipping routine, based off $03B69F
	LDA !E4,x		;
	CLC				;
	ADC #$01		;
	STA $04			; $04 = sprite X position low byte + X displacement value
	LDA !14E0,x		;
	ADC #$00		;
	STA $0A			; $0A = sprite X position high byte + X displacement high byte (00 or FF)
	LDA #$1E			;
	STA $06			; $06 = sprite clipping width
	LDA !D8,x		;
;	CLC				;
;	ADC #$0A		;
	STA $05			; $05 = sprite Y position low byte + Y displacement value
	LDA !14D4,x		;
;	ADC #$00		;
	STA $0B			; $0B = sprite Y position high byte + Y displacement high byte (00 or FF)
	LDA #$16		;
	STA $07			; $07 = sprite clipping height
	RTS				;






