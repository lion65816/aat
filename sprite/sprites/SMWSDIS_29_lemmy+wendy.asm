;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite 29 - Koopa Kid (Lemmy and Wendy part)
; commented by yoshicookiezeus
;
; Uses extra bit: YES
; If the extra bit is clear, the sprite will behave as Lemmy, and if it's set, it will
; behave as Wendy.
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
			!RAM_CustSpriteNum	= !7FAB9E


			!Hitpoints		= $02	; change this value to however many hitpoints you want the boss to have -1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc
			LDA !RAM_ExtraBits,x		;\ $05 - Lemmy, $06 - Wendy
			AND #$04			; |
			LSR				; |
			LSR				; |
			ADC #$05			; |
			STA !RAM_SpriteState,x		;/
;			CMP #$05			;\ branch if not Lemmy or Wendy
;			BCC CODE_01CD4E			;/ useless now
			LDA #$78			;\ set initial sprite position
			STA !RAM_SpriteXLo,x		; |
			LDA #$40			; |
			STA !RAM_SpriteYLo,x		; |
			LDA #$01			; |
			STA !RAM_SpriteYHi,x		;/
			LDA #$80			;\ set time before appearing
			STA !1540,x			;/
			RTL				; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "MAIN ",pc
			PHB
			PHK
			PLB
			STZ !RAM_Tweaker1662,x
			JSR PipeKoopaKids
			PLB
			RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PipeKoopaKids:		JSR SpriteGraphics
			LDA !14C8,x			;\ if sprite status not normal,
			CMP #$08			; |
			BNE Return03CC37		;/ branch
			LDA !RAM_SpritesLocked		;\ if sprites locked,
			BNE Return03CC37		;/ branch
			LDA !151C,x			;\ call pointer for current action
			JSL $0086DF			;/

PipeKoopaPtrs:		dw CODE_03CC8A			; setting up positions, spawning dummies
			dw CODE_03CD21			; rising
			dw CODE_03CDC7			; out of pipe
			dw CODE_03CDEF			; retreating
			dw CODE_03CE0E			; stomped
			dw CODE_03CE5A			; falling
			dw CODE_03CE89			; sinking in lava

Return03CC37:		RTS				; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 0 - setting up positions, spawning dummies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_03CC38:		db $18,$38,$58,$78,$98,$B8,$D8,$78	; x positions to appear
DATA_03CC40:		db $40,$50,$50,$40,$30,$40,$50,$40	; y positions to appear, Lemmy

DATA_03CC48:		db $50,$4A,$50,$4A,$4A,$40,$4A,$48	;\ time to rise during next action
			db $4A					;/

DATA_03CC51:		db $02,$04,$06,$08,$0B,$0C,$0E,$10	;\ graphics frames
			db $13					;/

DATA_03CC5A:		db $00,$01,$02,$03,$04,$05,$06,$00	;\ indexes for x position table
			db $01,$02,$03,$04,$05,$06,$00,$01	; |
			db $02,$03,$04,$05,$06,$00,$01,$02	; |
			db $03,$04,$05,$06,$00,$01,$02,$03	; |
			db $04,$05,$06,$00,$01,$02,$03,$04	; |
			db $05,$06,$00,$01,$02,$03,$04,$05	;/

CODE_03CC8A:		LDA !1540,x			;\ if not time to appear,
			BNE Return03CCDF		;/ branch
			LDA !1570,x			;\ if not real Lemmy/Wendy (?),
			BNE CODE_03CC9D			;/ branch
			JSL $01ACF9			;\  get random number
			AND #$0F			; | between $00 and $0F
			STA !160E,x			;/  and store it

CODE_03CC9D:		LDA !160E,x			;\  use it to determine sprite x position
			ORA !1570,x			; | add dummy index to table index
			TAY				; |
			LDA DATA_03CC5A,y		; |
			TAY				; |
			LDA DATA_03CC38,y		; |
			STA !RAM_SpriteXLo,x		;/
			LDA !RAM_SpriteState,x		;\  set sprite y position
			CMP #$06			; |
			LDA DATA_03CC40,y		; |
			BCC CODE_03CCB8			; | branch if Lemmy
			LDA #$50			; | Wendy's y position is always the same
CODE_03CCB8:		STA !RAM_SpriteYLo,x		;/

			LDA #$08			;
			LDY !1570,x			;\ if not real Lemmy/Wendy,
			BNE CODE_03CCCC			;/ branch
			JSR CODE_03CCE2			; spawn dummies
			JSL $01ACF9			;\  get another random number
			LSR				; |
			LSR				; |
			AND #$07			; | between $00 and $07
CODE_03CCCC:		STA !1528,x			;/  and store it
			TAY				;\ use it to determine time to rise during next action
			LDA DATA_03CC48,y		; |
			STA !1540,x			;/
			INC !151C,x			; go to next action
			LDA DATA_03CC51,y		;\ determine graphics frame to use
			STA !1602,x			;/
Return03CCDF:		RTS				; return

DATA_03CCE0:		db $10,$20

CODE_03CCE2:		LDY #$01			;\ that's a different way to set up a loop...
			JSR CODE_03CCE8			;/ oh well, whatever works
			DEY				; decrease loop counter
CODE_03CCE8:		LDA #$08			;\ set sprite status for new sprite
			STA !14C8,y			;/ 
			LDA !RAM_CustSpriteNum,x	;\ set sprite number of new sprite (= same as this one)
			PHX				; |
			TYX				; |
			STA !RAM_CustSpriteNum,x	;/
			JSL $07F7D2			; initialize sprites
			JSL $0187A7			; get table values for custom sprite
			LDA #$88			;\ set extra bits
			STA !RAM_ExtraBits,x		;/
			PLX
			LDA DATA_03CCE0,y		;\ set dummy status
			STA !1570,y			;/
			LDA !RAM_SpriteState,x		;\ synchronize dummy with real sprite
			STA.w !RAM_SpriteState,y	; |
			LDA !160E,x			; |
			STA !160E,y			; |
			LDA !RAM_SpriteXLo,x		; |
			STA.w !RAM_SpriteXLo,y		; |
			LDA !RAM_SpriteXHi,x		; |
			STA !RAM_SpriteXHi,y		; |
			LDA !RAM_SpriteYLo,x		; |
			STA.w !RAM_SpriteYLo,y		; |
			LDA !RAM_SpriteYHi,x		; |
			STA !RAM_SpriteYHi,y		;/
			RTS				; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 1 - rising
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_03CD21:		LDA !1540,x			;\ if not time to go to next action,
			BNE CODE_03CD2E			;/ branch
			LDA #$40			;\ set time to wait at top of pipe
			STA !1540,x			;/
			INC !151C,x			; go to next action
CODE_03CD2E:		LDA #$F8			;\ set rising speed
			STA !RAM_SpriteSpeedY,x		;/
			JSL $01801A			; update sprite y position
Return03CD36:		RTS				; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 2 - out of pipe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_03CD37:		db $02,$02,$02,$02,$03,$03,$03,$03	;\  graphics frames
			db $03,$03,$03,$03,$02,$02,$02,$02	; |
			db $04,$04,$04,$04,$05,$05,$04,$05	; |
			db $05,$04,$05,$05,$04,$04,$04,$04	; |
			db $06,$06,$06,$06,$07,$07,$07,$07	; |
			db $07,$07,$07,$07,$06,$06,$06,$06	; |
			db $08,$08,$08,$08,$08,$09,$09,$08	; |
			db $08,$09,$09,$08,$08,$08,$08,$08	; |
			db $0B,$0B,$0B,$0B,$0B,$0A,$0B,$0A	; |
			db $0B,$0A,$0B,$0A,$0B,$0B,$0B,$0B	; |
			db $0C,$0C,$0C,$0C,$0D,$0C,$0D,$0C	; |
			db $0D,$0C,$0D,$0C,$0D,$0D,$0D,$0D	; |
			db $0E,$0E,$0E,$0E,$0E,$0F,$0E,$0F	; |
			db $0E,$0F,$0E,$0F,$0E,$0E,$0E,$0E	; |
			db $10,$10,$10,$10,$11,$12,$11,$10	; |
			db $11,$12,$11,$10,$11,$11,$11,$11	; |
			db $13,$13,$13,$13,$13,$13,$13,$13	; |
			db $13,$13,$13,$13,$13,$13,$13,$13	;/

CODE_03CDC7:		JSR CODE_03CEA7			; handle Mario interaction
			LDA !1540,x			;\ if not time to go to next action,
			BNE CODE_03CDDA			;/ branch
CODE_03CDCF:		LDA #$24			;\ set time to retreat
			STA !1540,x			;/
			LDA #$03			;\ go to next sprite state
			STA !151C,x			;/ (why no INC this time?)
Return03CDD9:		RTS				; return

CODE_03CDDA:		LSR				;\ determine graphics frame to use
			LSR				; |
			STA $00				; |
			LDA !1528,x			; |
			ASL				; |
			ASL				; |
			ASL				; |
			ASL				; |
			ORA $00				; |
			TAY				; |
			LDA DATA_03CD37,y		; |
			STA !1602,x			;/
			RTS				; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 3 - retreating
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_03CDEF:		LDA !1540,x			;\ if not time to go to next action,
			BNE CODE_03CE05			;/ branch
			LDA !1570,x			;\ if not dummy,
			BEQ CODE_03CDFD			;/ branch
			STZ !14C8,x			; erase sprite
			RTS				; return

CODE_03CDFD:		STZ !151C,x			; set action
			LDA #$30			;\ set time before appearing
			STA !1540,x			;/
CODE_03CE05:		LDA #$10			;\ set sprite y speed
			STA !RAM_SpriteSpeedY,x		;/
			JSL $01801A			; update sprite y position
			RTS				; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 4 - stomped
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_03CE0E:		LDA !1540,x 			;\ if not time to go to next action,
			BNE CODE_03CE2A			;/ branch
			INC !1534,x			; increase hitpoints counter
			LDA !1534,x			;\ if boss hasn't been hit enough times,
			DEC A				; |
			CMP #!Hitpoints			; |
			BNE CODE_03CDCF			;/ branch
			LDA #$05			;\ set action (falling)
			STA !151C,x			;/
			STZ !RAM_SpriteSpeedY,x		; clear sprite y speed
			LDA #$23			;\ play sound effect
			STA $1DF9|!Base2			;/
			RTS				; return

CODE_03CE2A:		LDY !1570,x			;\ if dummy,
			BNE CODE_03CE42			;/ branch
CODE_03CE2F:		CMP #$24			;\ ~
			BNE CODE_03CE38			;/
			LDY #$29			;\ play sound effect
			STY $1DFC|!Base2			;/
CODE_03CE38:		LDA !RAM_FrameCounterB		;\ determine graphics frame
			LSR				; |
			LSR				; |
			AND #$01			; |
			STA !1602,x			;/
			RTS				; return

CODE_03CE42:		CMP #$10			;\ ~
			BNE CODE_03CE4B			;/
			LDY #$2A			;\ play sound effect
			STY $1DFC|!Base2			;/
CODE_03CE4B:		LSR				;\ determine graphics frame
			LSR				; |
			LSR				; |
			TAY				; |
			LDA DATA_03CE56,y		; |
			STA !1602,x			;/
			RTS				; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 5 - falling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_03CE56:		db $16,$16,$15,$14

CODE_03CE5A:		JSL $01801A			; update y posigion
			LDA !RAM_SpriteSpeedY,x		;\ if sprite not at max y speed,
			CMP #$40			; |
			BPL CODE_03CE69			;/ branch
			CLC				;\ increase y speed
			ADC #$03			; |
			STA !RAM_SpriteSpeedY,x		;/
CODE_03CE69:		LDA !RAM_SpriteYHi,x		;\ if sprite on top subscreen,
			BEQ CODE_03CE87			;/ branch
			LDA !RAM_SpriteYLo,x		;\ if sprite at certain position on current subscreen (i.e. has hit the lava),
			CMP #$85			; |
			BCC CODE_03CE87			;/ branch
			LDA #$06			;\ set action (sinking in lava)
			STA !151C,x			;/
			LDA #$80			;\ set time to sink
			STA !1540,x			;/
			LDA #$20			;\ play sound effect
			STA $1DFC|!Base2			;/
			JSL $028528			; spawn lava splash
CODE_03CE87:		BRA CODE_03CE2F			; branch

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; state 6 - sinking in lava
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_03CE89:		LDA !1540,x			;\ if not yet time to end level,
			BNE CODE_03CE9E			;/ branch
			STZ !14C8,x			; erase sprite
			INC $13C6|!Base2			; make Mario freeze on level end, enable boss sequence cutscene
			LDA #$FF			;\ set level end timer
			STA $1493|!Base2			;/
			;LDA #$0B			;\ set music
			LDA #$03			;\ PSI Ninja edit: Change to the victory fanfare.
			STA $1DFB|!Base2			;/

CODE_03CE9E:		LDA #$04			;\ set sprite y speed
			STA !RAM_SpriteSpeedY,x		;/
			JSL $01801A			; update sprite y position
			RTS				; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mario interaction routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_03CEA7:		JSL $01A7DC			;\ interact with Mario
			BCC Return03CEF1		;/ if no contact, branch
			LDA !RAM_MarioSpeedY		;\ if Mario is moving upwards,
			CMP #$10			; |
			BMI CODE_03CEED			;/  branch
			JSL $01AB99			; display contact graphic
			LDA #$02			;\ give Mario 400 points
			JSL $02ACE5			;/
			JSL $01AA33			; boost Mario upwards
			LDA #$02			;\ play sound effect
			STA $1DF9|!Base2			;/
			LDA !1570,x			;\ if the stomped sprite was a dummy,
			BNE CODE_03CEDB			;/ branch
			LDA #$28			;\ play sound effect
			STA $1DFC|!Base2			;/
			LDA !1534,x			;\ if boss hasn't been hit enough times,
			CMP #!Hitpoints			; |
			BNE CODE_03CEDB			;/ branch
			JSL KillMostSprites		; erase other sprites
CODE_03CEDB:		LDA #$04			;\ set action (stomped)
			STA !151C,x			;/
			LDA #$50			;\ set time before next action
			LDY !1570,x			; |
			BEQ CODE_03CEE9			; | $50 for real sprite,
			LDA #$1F			; | $1F for (9)
CODE_03CEE9:		STA !1540,x			;/
Return03CEEC:		RTS				; return

CODE_03CEED:		JSL $00F5B7			; hurt Mario
Return03CEF1:		RTS				; return

KillMostSprites:	LDY #$09			; setup loop
CODE_03A6CA:		LDA !14C8,y			;\ if sprite non-existent,
			BEQ CODE_03A6EC			;/ branch
			LDA.w !RAM_SpriteNum,y		;
			CMP #$A9			;\ if sprite is Reznor,
			BEQ CODE_03A6EC			;/ branch
			CMP #$29			;\ if sprite is Koopa Kid,
			BEQ CODE_03A6EC			;/ branch
			CMP #$A0			;\ if sprite is Bowser,
			BEQ CODE_03A6EC			;/ branch
			CMP #$C5			;\ if sprite is Big Boo Boss,
			BEQ CODE_03A6EC			;/ branch
			LDA !RAM_CustSpriteNum,x	;\ if custom sprite is same number as this one (i.e. one of the dummies),
			PHX				; |
			TYX				; |
			CMP !RAM_CustSpriteNum,x	; |
			BEQ CODE_Extra			;/ branch
			LDA #$04			;\ set sprite status (killed by spinjump)
			STA !14C8,y			;/
			LDA #$1F			;\ set time to show smoke cloud
			STA !1540,y			;/
CODE_Extra:		PLX
CODE_03A6EC:		DEY				; decrease sprite index
			BPL CODE_03A6CA			; if still sprites left to check, branch
			RTL				; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_03CEF2:		db $F8,$08,$F8,$08,$00,$00,$F8,$08	;\ tile x positions (Lemmy)
			db $F8,$08,$00,$00,$F8,$00,$00,$00	; |
			db $00,$00,$FB,$00,$FB,$03,$00,$00	; |
			db $F8,$08,$00,$00,$08,$00,$F8,$08	; |
			db $00,$00,$00,$00,$F8,$00,$00,$00	; |
			db $00,$00,$F8,$00,$08,$00,$00,$00	; |
			db $F8,$08,$00,$06,$00,$00,$F8,$08	; |
			db $00,$02,$00,$00,$F8,$08,$00,$04	; |
			db $00,$08,$F8,$08,$00,$00,$08,$00	; |
			db $F8,$08,$00,$00,$00,$00,$F8,$08	; |
			db $00,$00,$00,$00,$F8,$08,$00,$00	; |
			db $08,$00,$F8,$08,$00,$00,$08,$00	; |
			db $F8,$08,$00,$00,$00,$00,$F8,$08	; |
			db $00,$00,$00,$00,$F8,$08,$00,$00	; |
			db $00,$00,$F8,$08,$00,$00,$08,$00	; |
			db $F8,$08,$00,$00,$00,$00,$F8,$08	; |
			db $00,$00,$00,$00,$F8,$08,$00,$00	; |
			db $00,$00				;/

DATA_03CF7C:		db $F8,$08,$F8,$08,$00,$00,$F8,$08	;\ tile x positions (Wendy)
			db $F8,$08,$00,$00,$F8,$00,$08,$00	; |
			db $00,$00,$FB,$00,$FB,$03,$00,$00	; |
			db $F8,$08,$00,$00,$08,$00,$F8,$08	; |
			db $00,$00,$00,$00,$F8,$00,$08,$00	; |
			db $00,$00,$F8,$00,$08,$00,$00,$00	; |
			db $F8,$08,$00,$06,$00,$08,$F8,$08	; |
			db $00,$02,$00,$08,$F8,$08,$00,$04	; |
			db $00,$08,$F8,$08,$00,$00,$08,$00	; |
			db $F8,$08,$00,$00,$00,$00,$F8,$08	; |
			db $00,$00,$00,$00,$F8,$08,$00,$00	; |
			db $08,$00,$F8,$08,$00,$00,$08,$00	; |
			db $F8,$08,$00,$00,$00,$00,$F8,$08	; |
			db $00,$00,$00,$00,$F8,$08,$00,$00	; |
			db $00,$00,$F8,$08,$00,$00,$08,$00	; |
			db $F8,$08,$00,$00,$00,$00,$F8,$08	; |
			db $00,$00,$00,$00,$F8,$08,$00,$00	; |
			db $00,$00				;/

DATA_03D006:		db $04,$04,$14,$14,$00,$00,$04,$04	;\ tile y positions (Lemmy)
			db $14,$14,$00,$00,$00,$08,$F8,$00	; |
			db $00,$00,$00,$08,$F8,$F8,$00,$00	; |
			db $05,$05,$00,$F8,$F8,$00,$05,$05	; |
			db $00,$00,$00,$00,$00,$08,$F8,$00	; |
			db $00,$00,$00,$08,$00,$00,$00,$00	; |
			db $05,$05,$00,$F8,$00,$00,$05,$05	; |
			db $00,$F8,$00,$00,$05,$05,$00,$0F	; |
			db $F8,$F8,$05,$05,$00,$F8,$F8,$00	; |
			db $00,$00,$00,$00,$00,$00,$00,$00	; |
			db $00,$00,$00,$00,$05,$05,$00,$F8	; |
			db $F8,$00,$05,$05,$00,$F8,$F8,$00	; |
			db $04,$04,$02,$00,$00,$00,$04,$04	; |
			db $01,$00,$00,$00,$04,$04,$00,$00	; |
			db $00,$00,$05,$05,$00,$F8,$F8,$00	; |
			db $05,$05,$00,$00,$00,$00,$05,$05	; |
			db $03,$00,$00,$00,$05,$05,$04,$00	; |
			db $00,$00				;/

DATA_03D090:		db $04,$04,$14,$14,$00,$00,$04,$04	;\ tile y positions (Wendy)
			db $14,$14,$00,$00,$00,$08,$00,$00	; |
			db $00,$00,$00,$08,$F8,$F8,$00,$00	; |
			db $05,$05,$00,$F8,$F8,$00,$05,$05	; |
			db $00,$00,$00,$00,$00,$08,$00,$00	; |
			db $00,$00,$00,$08,$08,$00,$00,$00	; |
			db $05,$05,$00,$F8,$F8,$00,$05,$05	; |
			db $00,$F8,$F8,$00,$05,$05,$00,$0F	; |
			db $F8,$F8,$05,$05,$00,$F8,$F8,$00	; |
			db $00,$00,$00,$00,$00,$00,$00,$00	; |
			db $00,$00,$00,$00,$05,$05,$00,$F8	; |
			db $F8,$00,$05,$05,$00,$F8,$F8,$00	; |
			db $04,$04,$02,$00,$00,$00,$04,$04	; |
			db $01,$00,$00,$00,$04,$04,$00,$00	; |
			db $00,$00,$05,$05,$00,$F8,$F8,$00	; |
			db $05,$05,$00,$00,$00,$00,$05,$05	; |
			db $03,$00,$00,$00,$05,$05,$04,$00	; |
			db $00,$00				;/

DATA_03D11A:		db $20,$20,$26,$26,$08,$00,$2E,$2E	;\ tile numbers (Lemmy)
			db $24,$24,$08,$00,$00,$28,$02,$00	; |
			db $00,$00,$04,$28,$12,$12,$00,$00	; |
			db $22,$22,$04,$12,$12,$00,$20,$20	; |
			db $08,$00,$00,$00,$00,$28,$02,$00	; |
			db $00,$00,$0A,$28,$13,$00,$00,$00	; |
			db $20,$20,$0C,$02,$00,$00,$20,$20	; |
			db $0C,$02,$00,$00,$22,$22,$06,$03	; |
			db $12,$12,$20,$20,$06,$12,$12,$00	; |
			db $2A,$2A,$00,$00,$00,$00,$2C,$2C	; |
			db $00,$00,$00,$00,$20,$20,$06,$12	; |
			db $12,$00,$20,$20,$06,$12,$12,$00	; |
			db $22,$22,$08,$00,$00,$00,$20,$20	; |
			db $08,$00,$00,$00,$2E,$2E,$08,$00	; |
			db $00,$00,$4E,$4E,$60,$43,$43,$00	; |
			db $4E,$4E,$64,$00,$00,$00,$62,$62	; |
			db $64,$00,$00,$00,$62,$62,$64,$00	; |
			db $00,$00				;/

DATA_03D1A4:		db $20,$20,$26,$26,$48,$00,$2E,$2E	;\ tile numbers (Wendy)
			db $24,$24,$48,$00,$40,$28,$42,$00	; |
			db $00,$00,$44,$28,$52,$52,$00,$00	; |
			db $22,$22,$44,$52,$52,$00,$20,$20	; |
			db $48,$00,$00,$00,$40,$28,$42,$00	; |
			db $00,$00,$4A,$28,$53,$00,$00,$00	; |
			db $20,$20,$4C,$1E,$1F,$00,$20,$20	; |
			db $4C,$1F,$1E,$00,$22,$22,$44,$03	; |
			db $52,$52,$20,$20,$44,$52,$52,$00	; |
			db $2A,$2A,$00,$00,$00,$00,$2C,$2C	; |
			db $00,$00,$00,$00,$20,$20,$46,$52	; |
			db $52,$00,$20,$20,$46,$52,$52,$00	; |
			db $22,$22,$48,$00,$00,$00,$20,$20	; |
			db $48,$00,$00,$00,$2E,$2E,$48,$00	; |
			db $00,$00,$4E,$4E,$66,$68,$68,$00	; |
			db $4E,$4E,$6A,$00,$00,$00,$62,$62	; |
			db $6A,$00,$00,$00,$62,$62,$6A,$00	; |
			db $00,$00				;/

LemmyGfxProp:		db $05,$45,$05,$45,$05,$00,$05,$45	;\ tile properties (Lemmy)
			db $05,$45,$05,$00,$05,$05,$05,$00	; |
			db $00,$00,$05,$05,$05,$45,$00,$00	; |
			db $05,$45,$05,$05,$45,$00,$05,$45	; |
			db $05,$00,$00,$00,$05,$05,$05,$00	; |
			db $00,$00,$05,$05,$05,$00,$00,$00	; |
			db $05,$45,$05,$05,$00,$00,$05,$45	; |
			db $45,$45,$00,$00,$05,$45,$05,$05	; |
			db $05,$45,$05,$45,$45,$05,$45,$00	; |
			db $05,$45,$00,$00,$00,$00,$05,$45	; |
			db $00,$00,$00,$00,$05,$45,$45,$05	; |
			db $45,$00,$05,$45,$05,$05,$45,$00	; |
			db $05,$45,$05,$00,$00,$00,$05,$45	; |
			db $05,$00,$00,$00,$05,$45,$05,$00	; |
			db $00,$00,$07,$47,$07,$07,$47,$00	; |
			db $07,$47,$07,$00,$00,$00,$07,$47	; |
			db $07,$00,$00,$00,$07,$47,$07,$00	; |
			db $00,$00				;/

WendyGfxProp:		db $09,$49,$09,$49,$09,$00,$09,$49	;\ tile properties (Wendy)
			db $09,$49,$09,$00,$09,$09,$09,$00	; |
			db $00,$00,$09,$09,$09,$49,$00,$00	; |
			db $09,$49,$09,$09,$49,$00,$09,$49	; |
			db $09,$00,$00,$00,$09,$09,$09,$00	; |
			db $00,$00,$09,$09,$09,$00,$00,$00	; |
			db $09,$49,$09,$09,$09,$00,$09,$49	; |
			db $49,$49,$49,$00,$09,$49,$09,$09	; |
			db $09,$49,$09,$49,$49,$09,$49,$00	; |
			db $09,$49,$00,$00,$00,$00,$09,$49	; |
			db $00,$00,$00,$00,$09,$49,$49,$09	; |
			db $49,$00,$09,$49,$09,$09,$49,$00	; |
			db $09,$49,$09,$00,$00,$00,$09,$49	; |
			db $09,$00,$00,$00,$09,$49,$09,$00	; |
			db $00,$00,$05,$45,$05,$05,$45,$00	; |
			db $05,$45,$05,$00,$00,$00,$05,$45	; |
			db $05,$00,$00,$00,$05,$45,$05,$00	; |
			db $00,$00				;/

DATA_03D342:		db $02,$02,$02,$02,$02,$04,$02,$02	;\ tile sizes (Lemmy)
			db $02,$02,$02,$04,$02,$02,$00,$04	; |
			db $04,$04,$02,$02,$00,$00,$04,$04	; |
			db $02,$02,$02,$00,$00,$04,$02,$02	; |
			db $02,$04,$04,$04,$02,$02,$00,$04	; |
			db $04,$04,$02,$02,$00,$04,$04,$04	; |
			db $02,$02,$02,$00,$04,$04,$02,$02	; |
			db $02,$00,$04,$04,$02,$02,$02,$00	; |
			db $00,$00,$02,$02,$02,$00,$00,$04	; |
			db $02,$02,$04,$04,$04,$04,$02,$02	; |
			db $04,$04,$04,$04,$02,$02,$02,$00	; |
			db $00,$04,$02,$02,$02,$00,$00,$04	; |
			db $02,$02,$02,$04,$04,$04,$02,$02	; |
			db $02,$04,$04,$04,$02,$02,$02,$04	; |
			db $04,$04,$02,$02,$02,$00,$00,$04	; |
			db $02,$02,$02,$04,$04,$04,$02,$02	; |
			db $02,$04,$04,$04,$02,$02,$02,$04	; |
			db $04,$04				;/

DATA_03D3CC:		db $02,$02,$02,$02,$02,$04,$02,$02	;\ tile sizes (Wendy)
			db $02,$02,$02,$04,$02,$02,$00,$04	; |
			db $04,$04,$02,$02,$00,$00,$04,$04	; |
			db $02,$02,$02,$00,$00,$04,$02,$02	; |
			db $02,$04,$04,$04,$02,$02,$00,$04	; |
			db $04,$04,$02,$02,$00,$04,$04,$04	; |
			db $02,$02,$02,$00,$00,$04,$02,$02	; |
			db $02,$00,$00,$04,$02,$02,$02,$00	; |
			db $00,$00,$02,$02,$02,$00,$00,$04	; |
			db $02,$02,$04,$04,$04,$04,$02,$02	; |
			db $04,$04,$04,$04,$02,$02,$02,$00	; |
			db $00,$04,$02,$02,$02,$00,$00,$04	; |
			db $02,$02,$02,$04,$04,$04,$02,$02	; |
			db $02,$04,$04,$04,$02,$02,$02,$04	; |
			db $04,$04,$02,$02,$02,$00,$00,$04	; |
			db $02,$02,$02,$04,$04,$04,$02,$02	; |
			db $02,$04,$04,$04,$02,$02,$02,$04	; |
			db $04,$04				;/

DATA_03D456:		db $04,$04,$02,$03,$04,$02,$02,$02	;\ number of tiles to draw for each graphics frame (Lemmy)
			db $03,$03,$05,$04,$01,$01,$04,$04	; |
			db $02,$02,$02,$04,$02,$02,$02		;/

DATA_03D46D:		db $04,$04,$02,$03,$04,$02,$02,$02	;\ number of tiles to draw for each graphics frame (Wendy)
			db $04,$04,$05,$04,$01,$01,$04,$04	; |
			db $02,$02,$02,$04,$02,$02,$02		;/

SpriteGraphics:		%GetDrawInfo()
			LDA !1602,x			;\  get tile table index
			ASL				; | (graphics frame * 6
			ASL				; |
			ADC !1602,x			; |
			ADC !1602,x			; |
			STA $02				;/
			LDA !RAM_SpriteState,x		;\ if Wendy,
			CMP #$06			; |
			BEQ CODE_03D4DF			;/ branch

			PHX				; preserve sprite index

			LDA !1602,x			;\ determine number of tiles to draw
			TAX				; |
			LDA DATA_03D456,x		; |
			TAX				;/

CODE_03D4A3:		PHX				; preserve loop counter

			TXA				;\ set tile x position
			CLC				; |
			ADC $02				; |
			TAX				; |
			LDA $00				; |
			CLC				; |
			ADC DATA_03CEF2,x		; |
			STA !OAM_DispX,y		;/

			LDA $01				;\ set tile y position
			CLC				; |
			ADC DATA_03D006,x		; |
			STA !OAM_DispY,y		;/

			LDA DATA_03D11A,x		;\ set tile number
			STA !OAM_Tile,y			;/

			LDA LemmyGfxProp,x		;\ set tile properties
			ORA #$10			; |
			STA !OAM_Prop,y			;/

			PHY				; preserve OAM index
			TYA				;\ set tile size
			LSR				; |
			LSR				; |
			TAY				; |
			LDA DATA_03D342,x		; |
			STA !OAM_TileSize,y		;/
			PLY				; retrieve OAM index

			INY				;\ increase OAM index by four, so that the next tile can be drawn
			INY				; |
			INY				; |
			INY				;/

			PLX				; retrieve loop counter
			DEX				; decrease loop counter
			BPL CODE_03D4A3			; if more tiles left to draw, branch

CODE_03D4DD:		PLX				; retrieve sprite index
			
			RTS				; return

CODE_03D4DF:		PHX				; preserve sprite index

			LDA !1602,x			;\ determine number of tiles to draw
			TAX				; |
			LDA DATA_03D46D,x		; |
			TAX				;/

CODE_03D4E8:		PHX				; preserve loop counter

			TXA				;\ set tile x position
			CLC				; |
			ADC $02				; |
			TAX				; |
			LDA $00				; |
			CLC				; |
			ADC DATA_03CF7C,x		; |
			STA !OAM_DispX,y		;/

			LDA $01				;\ set tile y position
			CLC				; |
			ADC DATA_03D090,x		; |
			STA !OAM_DispY,y		;/

			LDA DATA_03D1A4,x		;\ set tile number
			STA !OAM_Tile,y			;/

			LDA WendyGfxProp,x		;\ set tile properties
			ORA #$10			; |
			STA !OAM_Prop,y			;/

			PHY				; preserve OAM index
			TYA				;\ set tile size
			LSR				; |
			LSR				; |
			TAY				; |
			LDA DATA_03D3CC,x		; |
			STA !OAM_TileSize,y		;/
			PLY				; retrieve OAM index

			INY				;\ increase OAM index by four, so that the next tile can be drawn
			INY				; |
			INY				; |
			INY				;/

			PLX				; retrieve loop counter
			DEX				; decrease loop counter
			BPL CODE_03D4E8			; if more tiles left to draw, branch

			BRA CODE_03D4DD			; branch
