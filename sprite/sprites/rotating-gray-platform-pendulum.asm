;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite 9E - Ball 'n Chain
; commented by yoshicookiezeus
;
; Uses extra bit: YES
; If the extra bit is clear, the sprite will rotate clockwise, and if it's set, it will
; rotate counterclockwise.
;
; NOTE: The palette of the sprite is hardcoded inside the ASM file; you can find the
; tile properties on line 389, in YXPPCCCT format.
; The palette for the chain tiles is also hardcoded, and can be found on line 309.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


			!RAM_FrameCounter	= $13
			!RAM_FrameCounterB	= $14
			!RAM_ScreenBndryXLo	= $1A
			!RAM_ScreenBndryYLo	= $1C
			!RAM_MarioDirection	= $76
			!RAM_MarioSpeedX	= $7B
			!RAM_MarioSpeedY	= $7D
			!RAM_MarioXPos		= $94
			!RAM_MarioXPosHi	= $95
			!RAM_MarioYPos		= $96
			!RAM_SpritesLocked	= $9D
			!RAM_SpriteNum		= !9E
			!RAM_SpriteSpeedY	= !AA
			!RAM_SpriteSpeedX	= !B6
			!RAM_SpriteState	= !C2
			!RAM_SpriteYLo		= !D8
			!RAM_SpriteXLo		= !E4
			!OAM_DispX		= $0300|!Base2
			!OAM_DispY		= $0301|!Base2
			!OAM_Tile		= $0302|!Base2
			!OAM_Prop		= $0303|!Base2
			!OAM_Tile2DispX		= $0304|!Base2
			!OAM_Tile2DispY		= $0305|!Base2
			!OAM_Tile2		= $0306|!Base2
			!OAM_Tile2Prop		= $0307|!Base2
			!OAM_TileSize		= $0460|!Base2
			!RAM_RandomByte1	= $148D|!Base2
			!RAM_RandomByte2	= $148E|!Base2
			!RAM_KickImgTimer	= $149A|!Base2
			!RAM_SpriteYHi		= !14D4
			!RAM_SpriteXHi		= !14E0
			!RAM_Reznor1Dead	= $1520|!Base2
			!RAM_Reznor2Dead	= $1521|!Base2
			!RAM_Reznor3Dead	= $1522|!Base2
			!RAM_Reznor4Dead	= $1523|!Base2
			!RAM_DisableInter	= !154C
			!RAM_SpriteDir		= !157C
			!RAM_SprObjStatus	= !1588
			!RAM_OffscreenHorz	= !15A0
			!RAM_SprOAMIndex	= !15EA
			!RAM_SpritePal		= !15F6
			!RAM_Tweaker1662	= !1662
			!RAM_ExSpriteNum	= $170B|!Base2
			!RAM_ExSpriteYLo	= $1715|!Base2
			!RAM_ExSpriteXLo	= $171F|!Base2
			!RAM_ExSpriteYHi	= $1729|!Base2
			!RAM_ExSpriteXHi	= $1733|!Base2
			!RAM_ExSprSpeedY	= $173D|!Base2
			!RAM_ExSprSpeedX	= $1747|!Base2
			!RAM_OffscreenVert	= !186C
			!RAM_OnYoshi		= $187A|!Base2

			!RAM_ExtraBits 		= !7FAB10
			!RAM_NewSpriteNum	= !7FAB9E

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc
			LDA #$30			;\ set platform radius
			STA !187B,x			;/

			LDA #$00			;\ set initial angle ($0000-$01FF)
			STA !151C,x			; | $151C is the high byte
			LDA #$00			; |
			STA !1602,x			;/ $161C is the low byte

			RTL				; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR RotatingPlatformMain
			PLB
			RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RotatingPlatformMain:	LDA #$00
            %SubOffScreen()
			LDA !RAM_SpritesLocked		;\ if sprites locked,
			BNE CODE_02D653			;/ branch

			LDA !RAM_ExtraBits,x		;\ use extra bits to determine direction of rotation
			LDY #$02			; | (original uses sprite x position)
			AND #$04			; |
			BNE CODE_02D63B			; |
			LDY #$FE			; |
CODE_02D63B:		TYA				; |
			LDY #$00			; |
			CMP #$00			; |
			BPL CODE_02D643			; |
			DEY				;/

CODE_02D643:		CLC				;\ update angle depending on direction of rotation
			ADC !1602,x			; | $1602,x is used to store the low byte of the platform angle
			STA !1602,x			; |
			TYA				; |
			ADC !151C,x			; | and $151C,x for the high byte
			AND #$01			; |
			STA !151C,x			; |
CODE_02D653:		LDA !151C,x			; |
			STA $01				; | $00-$01 = platform angle
			LDA !1602,x			; |
			STA $00				;/

			REP #$30			; set 16-bit mode for accumulator and registers
STZ $02
;			LDA $00				;\ $02-$03 = ball n' chain angle + 90 degrees
;			CLC				; |
;			ADC #$0080			; |
;			AND #$01FF			; |
;			STA $02				;/

			LDA $00				;\ $04-$05 = cosines of ball n' chain angle
			AND #$00FF			; |
			ASL				; |
			TAX				; |
;			LDA $07F7DB,x			; | this is SMW's trigonometry table
LDA HorzSineTable,x
SEP #$10
BPL NotHorzFlip
LDX #$01
STX $02
EOR #$FFFF
INC A
NotHorzFlip:
LDX $01
BEQ NotHorzFlip2
LDX $02
DEX
STX $02
NotHorzFlip2:
REP #$10
			STA $04				;/

;			LDA $02				;\ $06-$07 = cosines of ball n' chain angle + 90 degrees = sines for ball n' chain angle
LDA $00
			AND #$00FF			; |
			ASL				; |
			TAX				; |
;			LDA $07F7DB,x			; |
LDA VertSineTable,x
BPL NotVertFlip
SEP #$10
LDX #$01
STX $03
EOR #$FFFF
INC A
NotVertFlip:
			STA $06				;/

			SEP #$30			; set 8-bit mode for accumulator and registers

			LDX $15E9|!Base2			; get sprite index
            if !SA1
            STZ $2250
			LDA $04				;\ multiply $04...
			STA $2251			; |
            STZ $2252
			LDA !187B,x			; |
			LDY $05				; |\ if $05 is 1, no need to do the multiplication
			BNE CODE_02D6A3			; |/
			STA $2253			; | ...with radius of circle ($187B,x)
            STZ $2254
			NOP
            BRA $00
			ASL $2306			; Product/Remainder Result (Low Byte)
			LDA $2307			; Product/Remainder Result (High Byte)
            else
			LDA $04				;\ multiply $04...
			STA $4202			; |
			LDA !187B,x			; |
			LDY $05				; |\ if $05 is 1, no need to do the multiplication
			BNE CODE_02D6A3			; |/
			STA $4203			; | ...with radius of circle ($187B,x)
			JSR CODE_02D800			;/ waste some cycles while the result is calculated
			ASL $4216			; Product/Remainder Result (Low Byte)
			LDA $4217			; Product/Remainder Result (High Byte)
            endif
			ADC #$00			
;CODE_02D6A3:		LSR $01				
;			BCC CODE_02D6AA			
CODE_02D6A3:
LDY $02
BEQ CODE_02D6AA
			EOR #$FF			
			INC A				
CODE_02D6AA:		STA $04				
            if !SA1
            STZ $2250
			LDA $06				;\ multiply $06...
			STA $2251 			; |
            STZ $2252
			LDA !187B,x			; |
			LDY $07				; |\ if $07 is 1, no need to do the multiplication
			BNE CODE_02D6C6			; |/
			STA $2253			; | ...with raidus of circle ($187B,x)
            STZ $2254
            NOP
			BRA $00
			ASL $2306			; Product/Remainder Result (Low Byte)
			LDA $2307			; Product/Remainder Result (High Byte)
            else
			LDA $06				;\ multiply $06...
			STA $4202 			; |
			LDA !187B,x			; |
			LDY $07				; |\ if $07 is 1, no need to do the multiplication
			BNE CODE_02D6C6			; |/
			STA $4203			; | ...with raidus of circle ($187B,x)
			JSR CODE_02D800			;/ waste some cycles while the result is calculated
			ASL $4216			; Product/Remainder Result (Low Byte)
			LDA $4217			; Product/Remainder Result (High Byte)
            endif
			ADC #$00			
;CODE_02D6C6:		LSR $03				
;			BCC CODE_02D6CD			
CODE_02D6C6:
LDY $03
BEQ CODE_02D6CD
			EOR #$FF			
			INC A				
CODE_02D6CD:		STA $06				

			LDA !RAM_SpriteXLo,x		;\ preserve current sprite position (center of rotation)
			PHA				; |
			LDA !RAM_SpriteXHi,x		; |
			PHA				; |
			LDA !RAM_SpriteYLo,x		; |
			PHA				; |
			LDA !RAM_SpriteYHi,x		; |
			PHA				;/

			;LDY $0F86,x			; UNKNOWN RAM ADDRESS ALERT

			STZ $00				;\
			LDA $04				; |   x offset low byte
			BPL CODE_02D6E8			; |
			DEC $00				; |
CODE_02D6E8:		CLC				; |
			ADC !RAM_SpriteXLo,x		; | + x position of rotation center low byte
			STA !RAM_SpriteXLo,x		;/  = sprite x position low byte

			PHP				;\
			PHA				; |
			SEC				; |
			SBC !1534,x			; |
			STA !1528,x			; |
			PLA				; |
			STA !1534,x			; |
			PLP				;/

			LDA !RAM_SpriteXHi,x		;\    x position of rotation center high byte
			ADC $00				; | + adjustment for screen boundaries
			STA !RAM_SpriteXHi,x		;/  = x position of sprite high byte

			STZ $01				;\
			LDA $06				; |   y offset low byte
			BPL CODE_02D70B			; |
			DEC $01				; |
CODE_02D70B:		CLC				; |
			ADC !RAM_SpriteYLo,x		; | + y position of rotation center low byte
			STA !RAM_SpriteYLo,x		;/  = sprite y position low byte

			LDA !RAM_SpriteYHi,x		;\    y position of center of rotation high byte
			ADC $01				; | + adjustment for screen boundaries
			STA !RAM_SpriteYHi,x		;/  = sprite y position high byte

; in between here was a check for sprite number that determined whether the sprite should act like a platform or hurt Mario, since the ball n' chain
; shares its code with the rotating platform
; if you are interested in the exact code, check all.log

			JSL $01B44F			; act like solid platform
			BCC CODE_02D73D			; if Mario not touching platform, branch
			LDA #$03			;\
			STA !160E,x			; |
			STA $1471|!Base2			;/ set Mario on sprite platform flag
			LDA !RAM_OnYoshi		;\ if Mario on Yoshi,
			BNE CODE_02D74B			;/ branch

			PHX				
			JSL $00E2BD			
			PLX
				
			;LDA #$FF			;\ ...turn Mario invisible?
			;STA $78			;/ commented this out because seriously
			BRA CODE_02D74B

CODE_02D73D:		LDA !160E,x			
			BEQ CODE_02D74B			
			STZ !160E,x			
			PHX
			JSL $00E2BD			
			PLX				

CODE_02D74B:		JSR PlatformGFX

			PLA				;\ retrieve sprite position (center of rotation)
			STA !RAM_SpriteYHi,x		; |
			PLA				; |
			STA !RAM_SpriteYLo,x		; |
			PLA				; |
			STA !RAM_SpriteXHi,x		; |
			PLA				; |
			STA !RAM_SpriteXLo,x		;/

			LDA $00				;\ $00 = x position of first chain tile
			CLC				; |
			ADC !RAM_ScreenBndryXLo		; |
			SEC				; |
			SBC !RAM_SpriteXLo,x		; |
			JSR CODE_02D870			; |
			CLC				; |
			ADC !RAM_SpriteXLo,x		; |
			SEC				; |
			SBC !RAM_ScreenBndryXLo		; |
			STA $00				;/

			LDA $01				;\ $01 = y position of first chain tile
			CLC				; |
			ADC !RAM_ScreenBndryYLo		; |
			SEC				; |
			SBC !RAM_SpriteYLo,x		; |
			JSR CODE_02D870			; |
			CLC				; |
			ADC !RAM_SpriteYLo,x		; |
			SEC				; |
			SBC !RAM_ScreenBndryYLo		; |
			STA $01				;/

			LDA !15C4,x			;\ if sprite is off-screen,
			BNE Return02D806		;/ return
			LDA !RAM_SprOAMIndex,x		;\ get new OAM index for chain tiles
			CLC				; |
			ADC #$10			; |
			TAY				;/
			PHX				; preserve sprite index

			LDA !RAM_SpriteXLo,x		;\ make backups of sprite position low bytes that are accessible
			STA $0A				; | without having the sprite index in the x register
			LDA !RAM_SpriteYLo,x 		; |
			STA $0B				;/

; yay more removed sprite number checks

			LDA #$A2			;\ $08 = chain tile number
			STA $08				;/
			LDX #$01			; setup loop

CODE_02D7AF:		LDA $00				;\ set tile x position
			STA !OAM_DispX,y		;/
			LDA $01				;\ set tile y position
			STA !OAM_DispY,y		;/
			LDA $08				;\ set tile number
			STA !OAM_Tile,y			;/
			LDA #$33			;\ set tile properties
			STA !OAM_Prop,y			;/

			LDA $00				;\ $00 = x position of next chain tile
			CLC				; |
			ADC !RAM_ScreenBndryXLo		; |
			SEC				; |
			SBC $0A				; |
			STA $00				; |
			ASL				; |
			ROR $00				; |
			LDA $00				; |
			SEC				; |
			SBC !RAM_ScreenBndryXLo		; |
			CLC				; |
			ADC $0A				; |
			STA $00				;/

			LDA $01				;\ $01 = y position of next chain tile
			CLC				; |
			ADC !RAM_ScreenBndryYLo		; |
			SEC				; |
			SBC $0B				; |
			STA $01				; |
			ASL				; |
			ROR $01				; |
			LDA $01				; |
			SEC				; |
			SBC !RAM_ScreenBndryYLo		; |
			CLC				; |
			ADC $0B				; |
			STA $01				;/

			INY				;\ increase OAM index by four
			INY				; |
			INY				; |
			INY				;/
			DEX				;\ if chain tiles left to draw,
			BPL CODE_02D7AF			;/ go to start of loop

			PLX				; retrieve sprite index
			LDY #$02			; the tiles drawn were 16x16
			LDA #$05			; six tiles were drawn
			JSL $01B7B3			; finish OAM write
			RTS				; return

CODE_02D800:		NOP				;\ this routine exists for the sole purpose of wasting cycles
			NOP				; | while the multiplication or division registers do their work
			NOP				; |
			NOP				; |
			NOP				; |
			NOP				;/
Return02D806:		RTS				; return

XOffset:		db $00,$F0,$00,$10

Tilemap:		db $A2,$60,$61,$62

PlatformGFX:		%GetDrawInfo()
			PHX				; preserve sprite index
			LDX #$03			; setup loop

CODE_02D84E:		LDA $00				;\ set tile x position
			CLC				; |
			ADC XOffset,x			; |
			STA !OAM_DispX,y		;/
			LDA $01				;\ set tile y position
			STA !OAM_DispY,y		;/
			LDA Tilemap,x			;\ set tile number
			STA !OAM_Tile,y			;/
			LDA #$33			;\ set tile properties
			STA !OAM_Prop,y			;/

			INY				;\ increase OAM index by four
			INY				; |
			INY				; |
			INY				;/

			DEX				;\ if tiles left to draw,
			BPL CODE_02D84E			;/ go to start of loop

			PLX				; retrieve sprite index
			RTS				; return

CODE_02D870:		PHP				; preserve processor flags
			BPL CODE_02D876			;\ make sure value is positive
			EOR #$FF			; |
			INC A				;/
CODE_02D876:
            if !SA1
            STA $2252			; low byte of dividend is whatever was in the accumulator when the routine was called
			STZ $2251			; high byte of dividend is zero
            LDA #$01
            STA $2250
			LDA !187B,x			;\ divisor is half the radius of the circle 
			LSR				; |
			STA $2253			;/
            STZ $2254
            NOP
            BRA $00
			LDA $2306			;\ $0E = low byte of result
			STA $0E				;/
			LDA $2307			; noone cares about the high byte, so why is it even loaded?
            else
            STA $4205			; low byte of dividend is whatever was in the accumulator when the routine was called
			STZ $4204			; high byte of dividend is zero
			LDA !187B,x			;\ divisor is half the radius of the circle 
			LSR				; |
			STA $4206			;/
			JSR CODE_02D800			; wait
			LDA $4214			;\ $0E = low byte of result
			STA $0E				;/
			LDA $4215			; noone cares about the high byte, so why is it even loaded?
            endif

			ASL $0E				;\ what
			ROL				; |
			ASL $0E				; |
			ROL				; |
			ASL $0E				; |
			ROL				; |
			ASL $0E				; |
			ROL				;/

			PLP				; retrieve processor flags
			BPL Return02D8A0		;\ if original value was negative,
			EOR #$FF			; | invert result
			INC A				;/
Return02D8A0:		RTS				; return

;For circletool.exe to work, those MUST be last and the labels/format may NOT be changed.
HorzSineTable:
db $00,$00,$04,$00,$09,$00,$0E,$00,$13,$00,$18,$00,$1D,$00,$22,$00
db $27,$00,$2C,$00,$30,$00,$35,$00,$3A,$00,$3F,$00,$43,$00,$48,$00
db $4D,$00,$51,$00,$56,$00,$5A,$00,$5F,$00,$63,$00,$68,$00,$6C,$00
db $70,$00,$74,$00,$79,$00,$7D,$00,$81,$00,$85,$00,$89,$00,$8C,$00
db $90,$00,$94,$00,$98,$00,$9B,$00,$9F,$00,$A2,$00,$A6,$00,$A9,$00
db $AC,$00,$AF,$00,$B2,$00,$B6,$00,$B8,$00,$BB,$00,$BE,$00,$C1,$00
db $C4,$00,$C6,$00,$C9,$00,$CB,$00,$CE,$00,$D0,$00,$D2,$00,$D4,$00
db $D6,$00,$D8,$00,$DA,$00,$DC,$00,$DE,$00,$E0,$00,$E2,$00,$E3,$00
db $E5,$00,$E6,$00,$E8,$00,$E9,$00,$EB,$00,$EC,$00,$ED,$00,$EE,$00
db $EF,$00,$F0,$00,$F1,$00,$F2,$00,$F3,$00,$F4,$00,$F5,$00,$F6,$00
db $F7,$00,$F7,$00,$F8,$00,$F9,$00,$F9,$00,$FA,$00,$FA,$00,$FB,$00
db $FB,$00,$FC,$00,$FC,$00,$FC,$00,$FD,$00,$FD,$00,$FD,$00,$FD,$00
db $FE,$00,$FE,$00,$FE,$00,$FE,$00,$FE,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $00,$01,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FE,$00,$FE,$00,$FE,$00,$FE,$00
db $FE,$00,$FD,$00,$FD,$00,$FD,$00,$FD,$00,$FC,$00,$FC,$00,$FC,$00
db $FB,$00,$FB,$00,$FA,$00,$FA,$00,$F9,$00,$F9,$00,$F8,$00,$F7,$00
db $F7,$00,$F6,$00,$F5,$00,$F4,$00,$F3,$00,$F2,$00,$F1,$00,$F0,$00
db $EF,$00,$EE,$00,$ED,$00,$EC,$00,$EB,$00,$E9,$00,$E8,$00,$E6,$00
db $E5,$00,$E3,$00,$E2,$00,$E0,$00,$DE,$00,$DC,$00,$DA,$00,$D8,$00
db $D6,$00,$D4,$00,$D2,$00,$D0,$00,$CE,$00,$CB,$00,$C9,$00,$C6,$00
db $C4,$00,$C1,$00,$BE,$00,$BB,$00,$B8,$00,$B6,$00,$B2,$00,$AF,$00
db $AC,$00,$A9,$00,$A6,$00,$A2,$00,$9F,$00,$9B,$00,$98,$00,$94,$00
db $90,$00,$8C,$00,$89,$00,$85,$00,$81,$00,$7D,$00,$79,$00,$74,$00
db $70,$00,$6C,$00,$68,$00,$63,$00,$5F,$00,$5A,$00,$56,$00,$51,$00
db $4D,$00,$48,$00,$43,$00,$3F,$00,$3A,$00,$35,$00,$30,$00,$2C,$00
db $27,$00,$22,$00,$1D,$00,$18,$00,$13,$00,$0E,$00,$09,$00,$04,$00
VertSineTable:
db $00,$01,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FE,$00,$FE,$00,$FD,$00
db $FC,$00,$FC,$00,$FB,$00,$FA,$00,$F9,$00,$F8,$00,$F6,$00,$F5,$00
db $F4,$00,$F2,$00,$F0,$00,$EF,$00,$ED,$00,$EB,$00,$E9,$00,$E7,$00
db $E5,$00,$E3,$00,$E1,$00,$DF,$00,$DC,$00,$DA,$00,$D8,$00,$D5,$00
db $D3,$00,$D0,$00,$CD,$00,$CB,$00,$C8,$00,$C5,$00,$C2,$00,$BF,$00
db $BC,$00,$BA,$00,$B7,$00,$B4,$00,$B0,$00,$AD,$00,$AA,$00,$A7,$00
db $A4,$00,$A1,$00,$9E,$00,$9B,$00,$97,$00,$94,$00,$91,$00,$8E,$00
db $8B,$00,$87,$00,$84,$00,$81,$00,$7E,$00,$7B,$00,$77,$00,$74,$00
db $71,$00,$6E,$00,$6B,$00,$68,$00,$65,$00,$62,$00,$5F,$00,$5C,$00
db $59,$00,$56,$00,$53,$00,$50,$00,$4D,$00,$4B,$00,$48,$00,$45,$00
db $42,$00,$40,$00,$3D,$00,$3B,$00,$38,$00,$36,$00,$33,$00,$31,$00
db $2F,$00,$2C,$00,$2A,$00,$28,$00,$26,$00,$24,$00,$22,$00,$20,$00
db $1E,$00,$1C,$00,$1A,$00,$19,$00,$17,$00,$15,$00,$14,$00,$12,$00
db $11,$00,$0F,$00,$0E,$00,$0D,$00,$0C,$00,$0A,$00,$09,$00,$08,$00
db $07,$00,$06,$00,$05,$00,$05,$00,$04,$00,$03,$00,$03,$00,$02,$00
db $01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00
db $01,$00,$02,$00,$03,$00,$03,$00,$04,$00,$05,$00,$05,$00,$06,$00
db $07,$00,$08,$00,$09,$00,$0A,$00,$0C,$00,$0D,$00,$0E,$00,$0F,$00
db $11,$00,$12,$00,$14,$00,$15,$00,$17,$00,$19,$00,$1A,$00,$1C,$00
db $1E,$00,$20,$00,$22,$00,$24,$00,$26,$00,$28,$00,$2A,$00,$2C,$00
db $2F,$00,$31,$00,$33,$00,$36,$00,$38,$00,$3B,$00,$3D,$00,$40,$00
db $42,$00,$45,$00,$48,$00,$4B,$00,$4D,$00,$50,$00,$53,$00,$56,$00
db $59,$00,$5C,$00,$5F,$00,$62,$00,$65,$00,$68,$00,$6B,$00,$6E,$00
db $71,$00,$74,$00,$77,$00,$7B,$00,$7E,$00,$81,$00,$84,$00,$87,$00
db $8B,$00,$8E,$00,$91,$00,$94,$00,$97,$00,$9B,$00,$9E,$00,$A1,$00
db $A4,$00,$A7,$00,$AA,$00,$AD,$00,$B0,$00,$B4,$00,$B7,$00,$BA,$00
db $BC,$00,$BF,$00,$C2,$00,$C5,$00,$C8,$00,$CB,$00,$CD,$00,$D0,$00
db $D3,$00,$D5,$00,$D8,$00,$DA,$00,$DC,$00,$DF,$00,$E1,$00,$E3,$00
db $E5,$00,$E7,$00,$E9,$00,$EB,$00,$ED,$00,$EF,$00,$F0,$00,$F2,$00
db $F4,$00,$F5,$00,$F6,$00,$F8,$00,$F9,$00,$FA,$00,$FB,$00,$FC,$00
db $FC,$00,$FD,$00,$FE,$00,$FE,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
