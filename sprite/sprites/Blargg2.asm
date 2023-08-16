;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite A8 - Blargg
; adapted for Romi's Spritetool and commented by yoshicookiezeus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


			!RAM_FrameCounter	= $13
			!RAM_FrameCounterB	= $14
			!RAM_MarioSpeedX	= $7B
			!RAM_MarioXPos		= $94
			!RAM_MarioXPosHi	= $95
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
			!OAM_TileSize		= $0460|!Base2
			!RAM_SpriteYHi		= !14D4
			!RAM_SpriteXHi		= !14E0
			!RAM_SpriteDir		= !157C
			!RAM_SprObjStatus	= !1588
			!RAM_OffscreenHorz	= !15A0
			!RAM_SprOAMIndex	= !15EA
			!RAM_SpritePal		= !15F6
			!RAM_OffscreenVert	= !186C




X_Speed:		db $10,$F0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR Blargg
			PLB
			print "INIT ",pc
			RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Blargg:			JSR Sprite_Graphics
			LDA !RAM_SpritesLocked			;\ if sprites locked,
			BNE Return039F56			;/ return
			JSL $01A7DC				; interact with Mario
			LDA #$00
            %SubOffScreen()
			LDA !RAM_SpriteState,x   
			JSL $0086DF

BlarggPtrs:		dw CODE_039F57				; waiting
			dw CODE_039F8B				; emerging
			dw CODE_039FA4				; more waiting
			dw CODE_039FC8				; submerging
			dw CODE_039FEF				; lunging

Return039F56:		RTS					; return

CODE_039F57:		LDA !RAM_OffscreenHorz,x		;\ if sprite offscreen
			ORA !1540,x				; | or still waiting since last lunge,
			BNE Return039F8A			;/ return
			%SubHorzPos()
			LDA $0F					; |
			CLC					; |
			ADC #$70				; |
			CMP #$E0				; |
			BCS Return039F8A			;/ return
			LDA #$E3				;\ set sprite y speed
			STA !RAM_SpriteSpeedY,x			;/
			LDA !RAM_SpriteXHi,x			;\ preserve initial sprite position
			STA !151C,x				; |
			LDA !RAM_SpriteXLo,x			; |
			STA !1528,X				; |
			LDA !RAM_SpriteYHi,x			; |
			STA !1534,x				; |
			LDA !RAM_SpriteYLo,x			; |
			STA !1594,x				;/
			JSR CODE_039FC0         
			INC !RAM_SpriteState,x			; go to next sprite state
Return039F8A:		RTS					; return

CODE_039F8B:		LDA !RAM_SpriteSpeedY,x			;\ if sprite y speed positive and greater than 0x10,
			CMP #$10				; |
			BMI CODE_039F9B				;/ branch
			LDA #$50				;\ set time until next sprite state change
			STA !1540,x				;/
			INC !RAM_SpriteState,x			; go to next sprite state
			STZ !RAM_SpriteSpeedY,x			; reset sprite y speed
			RTS					; return

CODE_039F9B:		JSL $01801A				; update sprite position
			INC !RAM_SpriteSpeedY,x			;\ decelerate sprite downwards
			INC !RAM_SpriteSpeedY,x			;/
			RTS					; return

CODE_039FA4:		LDA !1540,x				;\ if not time to go to next sprite state,
			BNE CODE_039FB1				;/ branch
			INC !RAM_SpriteState,x			; go to next sprite state
			LDA #$0A				;\ set time until next sprite state change
			STA !1540,x				;/
			RTS					; return

CODE_039FB1:		CMP #$20				;\ if sprite state timer is less than 0x20,
			BCC CODE_039FC0				;/ branch
			AND #$1F				;\ if not time to flip sprite direction,
			BNE Return039FC7			;/ return
			LDA !RAM_SpriteDir,x			;\ flip sprite direction
			EOR #$01				;/
			BRA CODE_039FC4           

CODE_039FC0:		%SubHorzPos()			;\ make sprite face Mario
			TYA					; |
CODE_039FC4:		STA !RAM_SpriteDir,x			;/
Return039FC7:		RTS					; return

CODE_039FC8:		LDA !1540,x				;\ if time to go to next sprite state,
			BEQ CODE_039FD6				;/ branch
			LDA #$20				;\ else, set sprite y speed
			STA !RAM_SpriteSpeedY,x			;/
			JSL $01801A				; update sprite position
			RTS					; return

CODE_039FD6:		LDA #$20				;\ set timer
			STA !1540,x				;/
			LDY !RAM_SpriteDir,x			;\ set initial sprite x speed
			LDA X_Speed,y				; |
			STA !RAM_SpriteSpeedX,x			;/
			LDA #$E2				;\ set initial sprite y speed
			STA !RAM_SpriteSpeedY,x			;/
			JSR CODE_03A045
			INC !RAM_SpriteState,x			; go to next sprite state
			RTS					; return


CODE_039FEF:		STZ !1602,X				; clear graphics frame to use
			LDA !1540,x				;\ if already lunging,
			BEQ CODE_03A002				;/ branch
			DEC A					;\ if not yet time to lunge,
			BNE CODE_03A038				;/ branch
			LDA #$25				;\ sound effect
			STA $1DF9|!Base2				;/ 
			JSR CODE_03A045
CODE_03A002:		JSL $018022				;\ update sprite position
			JSL $01801A				;/
			LDA !RAM_FrameCounter			;\ every 0x100th frame, skip y speed increasing?
			AND #$00				; | how odd...
			BNE CODE_03A012				;/ perhaps this was #$01 or #$03 earlier, to make the y speed increase slower?
			INC !RAM_SpriteSpeedY,x			; increase sprite y speed
CODE_03A012:		LDA !RAM_SpriteSpeedY,x			;\ if sprite y speed is negative or less than 0x20:
			CMP #$20				; |
			BMI CODE_03A038				;/ branch
			JSR CODE_03A045
			STZ !RAM_SpriteState,x			; return to first sprite state
			LDA !151C,X				;\ reset sprite position to its original values
			STA !RAM_SpriteXHi,x			; |
			LDA !1528,x				; |
			STA !RAM_SpriteXLo,x			; |
			LDA !1534,x				; |
			STA !RAM_SpriteYHi,x			; |
			LDA !1594,x				; |
			STA !RAM_SpriteYLo,x			;/
			LDA #$40				;\ set time until next sprite state change
			STA !1540,x				;/
CODE_03A038:		LDA !RAM_SpriteSpeedY,x			;\ if sprite y speed less than 06 in either direction (at the top of its lunge),
			CLC					; |
			ADC #$06				; |
			CMP #$0C				; |
			BCS Return03A044			;/ return
			INC !1602,x				; set graphics frame to use
Return03A044:		RTS					; return

CODE_03A045:		LDA !RAM_SpriteYLo,x			;\ temporarily change y position of sprite
			PHA					; |
			SEC					; |
			SBC #$0C				; |
			STA !RAM_SpriteYLo,x			; |
			LDA !RAM_SpriteYHi,x			; |
			PHA					; |
			SBC #$00				; |
			STA !RAM_SpriteYHi,x			;/
			JSL $028528				; show lava splash
			PLA					;\ restore y position of sprite
			STA !RAM_SpriteYHi,x			; |
			PLA					; |
			STA !RAM_SpriteYLo,x			;/
			RTS					; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!Eye_Tile		= $A0


Sprite_Graphics:	%GetDrawInfo()
			LDA !RAM_SpriteState,x			;\ if sprite state == 0,
			BEQ CODE_03A038				;/ branch (skip graphics routine)
			CMP #$04				;\ if sprite state == 4,
			BEQ CODE_03A09D				;/ branch (full graphics routine)

			LDA #!Eye_Tile
			STA !OAM_Tile,y
			LDA $00
			STA !OAM_DispX,y
			LDA $01
			STA !OAM_DispY,Y
			LDA !15F6,x

			PHY
			LDY !RAM_SpriteDir,X
			BNE No_X_Flip
			EOR #$40
No_X_Flip:
			PLY
			ORA $64
			STA !OAM_Prop,Y

			LDY #$02				; \ 460 = 2 (all 16x16 tiles)
			LDA #$00				;  | A = (number of tiles drawn - 1)
			JSL $01B7B3				; / don't draw if offscreen
			RTS					; return


X_Offset:		db $F8,$08,$F8,$08,$18,$08,$F8,$08
			db $F8,$E8

Y_Offset:		db $F8,$F8,$08,$08,$08

BlarggTilemap:		db $CA,$A4,$C2,$C4,$A6,$CA,$A4,$C0
			db $C8,$A6

CODE_03A09D:		LDA !1602,x				;\ use graphics frame to determine initial tile table offset
			ASL					; |
			ASL					; |
			ADC !1602,x				; |
			STA $03					;/
			LDA !RAM_SpriteDir,x
			STA $02
			PHX					; preserve sprite index
			LDX #$04				; setup loop counter
CODE_03A0AF:		PHX					;\ preserve it in the stack,
			PHX					;/ twice
			LDA $01					;\ set y position of tile
			CLC					; |
			ADC Y_Offset,x				; |
			STA !OAM_DispY,y				;/
			LDA $02					;\ use sprite direction to determine offset for x offset table
			BNE CODE_03A0C3				; |
			TXA					; |
			CLC					; |
			ADC #$05				; |
			TAX					;/
CODE_03A0C3:		LDA $00					;\ set x position of tile
			CLC					; |
			ADC X_Offset,x				; |
			STA !OAM_DispX,y			;/
			PLA					; retrieve loop counter
			CLC					;\ add in initial tile table offset
			ADC $03					; |
			TAX					;/
			LDA BlarggTilemap,x			;\ set tile number
			STA !OAM_Tile,y				;/
			PHX					; preserve loop counter
			LDX $15E9|!Base2				; load sprite index
			LDA !15F6,x				; load sprite graphics properties
			PHY					; preserve OAM index
			LDY $02					;\ if sprite facing right,
			BNE No_X_Flip2				; |
			EOR #$40				;/ flip tile
No_X_Flip2:		PLY					; retrieve OAM index
			PLX					; retrieve loop counter
			ORA $64					; add in level properties
			STA !OAM_Prop,Y				; set tile properties
			PLX					; retrieve loop counter
			INY					;\ as we wrote a 16x16 tile to OAM, we need to increase the pointer by 4
			INY					; |
			INY					; |
			INY					;/
			DEX					; decrease loop counter
			BPL CODE_03A0AF				; if still tiles left to draw, go to start of loop
			PLX					; retrieve sprite index
			LDY #$02				; the tiles written were 16x16
			LDA #$04				; we wrote five tiles
			JSL $01B7B3
			RTS					; return
            