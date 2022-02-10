;Wingless/Flying Goonie by edit1754 (optimized by Blind Devil)
;Extra bit: if clear, it'll be a wingless Goonie. If set, will be a flying, rideable one.

;Be sure to use No More Sprite Tile Limits patch and level mode setting 10 for best results.

;Tilemap defines:
!Head		= $86	;head tile (wingless/flying)
!Body1		= $8C	;body frame 1 (wingless/flying)
!Body2		= $88	;body frame 2 (wingless/flying)
!Body3		= $8A	;body frame 3 (wingless/flying)
!Body4		= $80	;body frame 4 (wingless)
!Body5		= $82	;body frame 5 (wingless)
!Body6		= $84	;body frame 6 (wingless)

!WingTop1	= $9E	;wing frame 1, top
!WingBottom1	= $AE	;wing frame 1, bottom
!WingTop2	= $A2	;wing frame 2, top
!WingBottom2	= $A0	;wing frame 2, bottom
!WingTop3	= $A4	;wing frame 3, top
!WingBottom3	= $AD	;wing frame 3, bottom
!Wing4		= $AA	;wing frame 4
!Wing5		= $AC	;wing frame 5
!WingTop6	= $A6	;wing frame 6, top
!WingBottom6	= $A8	;wing frame 6, bottom

FLYYSPEEDS:	db $F8,$00,$00,$00,$00,$F8,$F0,$F0,$F8,$10	;speeds for flying goonie

SpdTbl2:	db $20,$E0	;wingless goonie speeds

!GlideTime = $63
!FlyTime = $FF

STAGETIMERS:	db !GlideTime,!FlyTime	;glide down, fly up

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		print "INIT ",pc
		%SubHorzPos()		;face mario initially
		TYA
		STA !157C,x

		LDA !7FAB10,x
		AND #$04
		BEQ +

		LDA #!GlideTime
		STA !163E,x

		LDA !1686,x
		ORA #$80	;needed so flying goonie will never ineract with objects
		STA !1686,x
		LDA !1656,x
		AND #$E0	;needed so flying goonie will be properly rideable
		STA !1656,x
+
		RTL

		print "MAIN ",pc
		PHB
		PHK
		PLB
		JSR SPRITE_ROUTINE
		PLB
		RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RETURN1:	RTS
SPRITE_ROUTINE:
		LDA !7FAB10,x
		AND #$04
		BNE +
		JMP Wingless

+
		JSR SUB_GFX
		LDA !14C8,x		; \ return if sprite
		CMP #$08		; / status is not 8
		BNE RETURN1		; \  return if
		LDA $9D			;  | sprites
		BNE RETURN1		; /  are locked
		LDA !15D0,x		; \ return if
		BNE RETURN1		; / being eaten

		LDA #$00
		%SubOffScreen()

		LDA !1602,x		; \
		LSR #2			;  | set Y speedaccording to
		TAY			;  | flying frame
		LDA FLYYSPEEDS,y	;  |
		STA !AA,x		; /
		LDA #$F4		; \
		LDY !157C,x		;  | set X speed
		BNE NOFLIPXSPEED	;  | and flip if
		EOR #$FF		;  | going the
		INC A			;  | other way
NOFLIPXSPEED:	STA !B6,x		; /

		LDA !1602,x		; \
		CMP #$23		;  | go to next in
		BEQ RESETFLY		;  | indexes to
		INC !1602,x		;  | frame data
		BRA NORESETFLY		;  |
RESETFLY:	STZ !1602,x		; /
NORESETFLY:
		LDA !1528,x		; \
		CMP #$0B		;  | go to next in
		BEQ RESETHEAD		;  | indexes to
		INC !1528,x		;  | frame data
		BRA NORESETHEAD		;  |
RESETHEAD:	STZ !1528,x		; /
NORESETHEAD:

		LDA !1FD6,x		; \ store standing status prior
		STA $00			; / to this frame into scratch RAM
		JSR POSOFFSETSTART	; \  do everything to
		JSR MAKE_PLATFORM	;  | generate a
		JSR POSOFFSETEND	; /  "platform"

		LDA !1FD6,x		; \ don't execute following
		BEQ NOT_STANDING	; / code if not standing

		LDA $00			; \
		BNE WASSTANDINGLAST	;  | if first frame of standing,
		LDA #$18		;  | then start the weight timer
		STA !1540,x		; /

WASSTANDINGLAST:
		LDA !1602,x		; \
		CMP #$23		;  | go to next in
		BEQ RESETFLY2		;  | indexes to
		INC !1602,x		;  | frame data
		BRA NORESETFLY2		;  | (again)
RESETFLY2:	STZ !1602,x		; /
NORESETFLY2:
		LDA !1528,x		; \
		CMP #$0B		;  | go to next in
		BEQ RESETHEAD2		;  | indexes to
		INC !1528,x		;  | frame data
		BRA NORESETHEAD2	;  | (again)
RESETHEAD2:	STZ !1528,x		; /
NORESETHEAD2:
		LDA !AA,x		; \
		BPL YISPLUS		;  | get absolute
		EOR #$FF		;  | value of Y
		INC A			; /
YISPLUS:
		LSR			; \
		LDY !AA,x		;  | divide by
		BPL YISPLUS2		;  | 2 and then
		EOR #$FF		;  | make negative
		INC A			;  | if necessary
YISPLUS2:	STA !AA,x		; /

		LDA !AA,x		; \
		CLC			;  | generate weight effect
		ADC !1540,x		;  | when mario stands on it
		STA !AA,x		; /

		LDA !B6,x		; \
		BPL XISPLUS		;  | get absolute
		EOR #$FF		;  | value of X
		INC A			; /
XISPLUS:
		LSR			; \
		LDY !B6,x		;  | divide by
		BPL XISPLUS2		;  | 2 and then
		EOR #$FF		;  | make negative
		INC A			;  | if necessary
XISPLUS2:	STA !B6,x		; /

		LDA #$01		; \ set mode to
		STA !1504,x		; / flying up
		LDA #!FlyTime		; \ hold timer
		STA !163E,x		; / at start
		LDA !1602,x		; \
		CMP #$24		;  | if frame is gliding frame
		BCC ISOK		;  | then set frame to zero
		STZ !1602,x		; /
ISOK:

		LDA $77			; \
		AND #$08		;  | don't move upwards if
		BEQ NOT_STANDING	;  | mario is hitting ceiling
		STZ !AA,x		; /

NOT_STANDING:
		LDA !1504,x		; \
		BNE NO_GLIDE		;  | set frame to glide
		LDA #$24		;  | frame if gliding
		STA !1602,x		; /

NO_GLIDE:
		LDA !163E,x		; \
		BNE NO_CHG_MODE		;  | switch modes
		LDA !1504,x		;  | and set timer
		EOR #$01		;  | properly if
		STA !1504,x		;  | it's time
		LDY !1504,x		;  |
		LDA STAGETIMERS,y	;  |
		STA !163E,x		;  |
		STZ !1602,x		; /

NO_CHG_MODE:
		LDA !D8,x		; \
		PHA			;  | interact
		LDA !14D4,x		;  | with mario
		PHA			;  | and other
		LDA !D8,x		;  | sprites four
		CLC			;  | pixels lower
		ADC #$04		;  | than normal
		STA !D8,x		;  |
		LDA !14D4,x		;  |
		ADC #$00		;  |
		STA !14D4,x		;  |
		JSL $01A7DC|!BankB	;  |
		JSL $018032|!BankB	;  |
		PLA			;  |
		STA !14D4,x		;  |
		PLA			;  |
		STA !D8,x		; /
		JSL $018022|!BankB	; Update X position without gravity
        	JSL $01801A|!BankB	; Update Y position without gravity
		LDA !D8,x		; \
		STA $06			;  | store actual (non-shifted)
		LDA !14D4,x		;  | sprite Y to scratch RAM
		STA $07			; /
		LDY #$00		; \
		PHP			;  | check if
		REP #$20		;  | sprite is
		LDA $06			;  | too high
		CMP.w #$FFD0		;  |
		BPL POS_IS_OK		;  | if not, then
		LDY #$01		;  | don't execute
POS_IS_OK:	PLP			;  | following code
		CPY #$00		;  |
		BEQ RETURN		; /
		LDY !161A,x		; \ kill sprite, but allow
		PHX
		TYX
		LDA #$00
		STA !1938,x		;  | sprite to
		PLX
		STZ !14C8,x		; /  reload again

RETURN:		RTS

MAKE_PLATFORM:	LDA $187A|!Base2	; \ don't shift
		BEQ NOYOSHI		; / if not on Yoshi
		LDA $96			; \
		CLC			;  | offset Y
		ADC #$10		;  | by #$10
		STA $96			;  | again to
		LDA $97			;  | compensate
		ADC #$00		;  | for yoshi
		STA $97			; /
NOYOSHI:
		LDA !1534,x		; \
		STA $08			;  | store sprite's old
		LDA !1570,x		;  | X and Y positions
		STA $09			;  | into scratch
		LDA !1594,x		;  | RAM for use
		STA $0A			;  | in some of the
		LDA !1626,x		;  | following code
		STA $0B			; /
		LDA !E4,x		; \
		STA $04			;  | store sprite X
		LDA !14E0,x		;  | and Y position
		STA $05			;  | into scratch
		LDA !D8,x		;  | RAM for use
		STA $06			;  | in some of the
		LDA !14D4,x		;  | following code
		STA $07			; /
		LDA !E4,x		; \
		STA !1534,x		;  | store current position
		LDA !14E0,x		;  | to sprite tables for
		STA !1570,x		;  | use next time sprite
		LDA !D8,x		;  | routine is called.
		STA !1594,x		;  | It's used for moving mario
		LDA !14D4,x		;  | while he's standing on it
		STA !1626,x		; /
		LDA !1FD6,x		; \ check if mario was
		BEQ NOT_STANDING_LAST_FRAME	; / standing last frame
		LDA $77			; \  don't move mario if
		AND #$03		;  | he is hitting the side
		BNE NO_MOVE_MARIO	; /  of an object
		PHP			; \
		REP #$20		;  | move mario
		LDA $04			;  | with the
		SEC			;  | sprite
		SBC $08			;  |
		CLC			;  |
		ADC $94			;  |
		STA $94			;  | ... and also
		REP #$20		;  | move mario
		LDA $06			;  | with the bird
		SEC			;  | on the Y
		SBC $0A			;  | axis
		CLC			;  |
		ADC $96			;  |
		STA $96			;  |
		PLP			; /
NO_MOVE_MARIO:	STZ !1FD6,x		; zero this in case it won't be set this frame

NOT_STANDING_LAST_FRAME:
		LDA $7D			; \ don't stand on if
		BMI NO_STAND		; / mario not moving down
		PHP			; back up processor bits
		REP #$20		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA $06			; get sprite's Y position
		CLC			; \ offset to get minimum
		ADC.w #$FFE3		; / Y area for standing
		CMP $96			; compare with mario's Y position
		BCS NO_STAND_1		; don't execute next command if area is under mario 
		LDY #$01		; set Y register = 1
NO_STAND_1:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND		; / then don't stand
		PHP			; back up processor bits
		REP #$20		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA $06			; get sprite's Y position
		CLC			; \ offset to get maximum
		ADC.w #$FFE9		; / Y area for standing
		CMP $96			; compare with mario's Y position
		BCC NO_STAND_2		; don't execute next command if area is over mario
		LDY #$01		; set Y register = 1
NO_STAND_2:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND		; / then don't stand
		PHP			; back up processor bits
		REP #$20		; 16 bit A/math
		LDY #$00		; Y register = 0
		LDA $04			; get sprite's X position
		CLC			; \ offset to get minimum
		ADC.w #$FFF3		; / X area for standing
		BPL CMP1		; \ if area goes backward past
		LDA.w #$0000		; / level start then assume zero
CMP1:		CMP $94			; compare with mario's X position
		BCS NO_STAND_3		; don't execute next command if area is after mario
		LDY #$01		; set Y register = 1
NO_STAND_3:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND		; / then don't stand
		PHP			; back up processor bits
		REP #$20		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA $04			; get sprite's X position
		CLC			; \ offset to get maximum
		ADC.w #$000C		; / X area for standing
		BPL CMP2		; \ if X area goes backward past
		LDA.w #$0000		; / level start then assume zero
CMP2:		CMP $94			; compare with mario's X position
		BCC NO_STAND_4		; don't execute next command if area is before mario
		LDY #$01		; set Y register = 1
NO_STAND_4:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND		; / then don't stand
		PHP			; \
		REP #$20		;  | offset mario's
		LDA $06			;  | Y position so
		CLC			;  | that he is
		ADC.w #$FFE4		;  | standing at
		STA $96			;  | specified offset
		PLP			; /
		LDA #$01		; \ set standing
		STA $1471|!Base2	; / mode
		LDA #$01		; \ for the next frame, indicate mario
		STA !1FD6,x		; / was standing during this frame

NO_STAND:
		LDA $187A|!Base2	; \ don't shift
		BEQ NOYOSHI2		; / if not on Yoshi
		LDA $96			; \  reverse
		SEC			;  | offset Y
		SBC #$10		;  | by #$10
		STA $96			;  | again to
		LDA $97			;  | compensate
		SBC #$00		;  | for yoshi
		STA $97			; /
NOYOSHI2:
		RTS

;; This temporarily offsets mario's and the sprite's
;; Y positions so the lift doesn't have a glitch
;; when it's at the top of the level

POSOFFSETSTART:	LDA $96			; \
		CLC			;  | add specified
		ADC #$FF		;  | offset to
		STA $96			;  | mario
		LDA $97			;  |
		ADC #$00		;  |
		STA $97			; /
		LDA !D8,x		; \
		CLC			;  | add specified
		ADC #$FF		;  | offset to
		STA !D8,x		;  | sprite
		LDA !14D4,x		;  |
		ADC #$00		;  |
		STA !14D4,x		; /
		RTS
POSOFFSETEND:	LDA $96			; \
		SEC			;  | subtract
		SBC #$FF		;  | specified
		STA $96			;  | offset from
		LDA $97			;  | mario
		SBC #$00		;  |
		STA $97			; /
		LDA !D8,x		; \
		SEC			;  | subtract
		SBC #$FF		;  | specified
		STA !D8,x		;  | offset from
		LDA !14D4,x		;  | sprite
		SBC #$00		;  |
		STA !14D4,x		; /
		RTS

Wingless:	JSR SUB_GFX2		; \  return if 
		LDA !14C8,x		;  | sprite status
		CMP #$08		; /  is not 8
		BNE RETURNEH		; \  return if
		LDA $9D			;  | sprites
		BNE RETURNEH		; /  are locked

		LDA #$00
		%SubOffScreen()        

		LDY !157C,x		; \  move sprite
		LDA SpdTbl2,y		;  | depending on
		STA !B6,x		; /  its direction

		LDA !1588,x		; \
		AND #$03		;  | if the sprite
		BEQ DONTCHANGEDIR	;  | is hitting a
		LDA !157C,x		;  | wall, then flip
		EOR #$01		;  | its direction
		STA !157C,x		; /		 

DONTCHANGEDIR:
		LDA !1602,x		; \
		CMP #$05		;  | cycle through
		BEQ .RESETRUN		;  | WLSINDEXES to
		INC !1602,x		;  | frame data
		BRA .NORESETRUN		;  |
.RESETRUN	STZ !1602,x		; /

.NORESETRUN
		JSL $01802A|!BankB	; update position based on speed values
		JSL $018032|!BankB	; interact with other sprites
		JSL $01A7DC|!BankB	; check for mario/sprite contact       
RETURNEH:	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DIRWINGOFFSETS:	db $FD,$03

WINGINDEXES:	db $00,$00,$00,$00
		db $02,$02,$02,$02
		db $04,$04,$04,$04
		db $06,$06,$06,$06
		db $08,$08,$08,$08
		db $0A,$0A,$0A,$0A
		db $0C,$0C,$0C,$0C
		db $0E,$0E,$0E,$0E
		db $10,$10,$10,$10
		db $12

WCOUNT:		db $02,$02,$02,$01,$01,$02,$02,$01,$01,$02
WTILES:		dw WTILES1&$FFFF,WTILES2&$FFFF,WTILES3&$FFFF
		dw WTILES4&$FFFF,WTILES5&$FFFF,WTILES6&$FFFF
		dw WTILES7&$FFFF,WTILES8&$FFFF,WTILES9&$FFFF
		dw WTILES10&$FFFF
WXDISP:		dw WXDISP1&$FFFF,WXDISP2&$FFFF,WXDISP3&$FFFF
		dw WXDISP4&$FFFF,WXDISP5&$FFFF,WXDISP6&$FFFF
		dw WXDISP7&$FFFF,WXDISP8&$FFFF,WXDISP9&$FFFF
		dw WXDISP10&$FFFF
WYDISP:		dw WYDISP1&$FFFF,WYDISP2&$FFFF,WYDISP3&$FFFF
		dw WYDISP4&$FFFF,WYDISP5&$FFFF,WYDISP6&$FFFF
		dw WYDISP7&$FFFF,WYDISP8&$FFFF,WYDISP9&$FFFF
		dw WYDISP10&$FFFF
WSIZES:		dw WSIZES1&$FFFF,WSIZES2&$FFFF,WSIZES3&$FFFF
		dw WSIZES4&$FFFF,WSIZES5&$FFFF,WSIZES6&$FFFF
		dw WSIZES7&$FFFF,WSIZES8&$FFFF,WSIZES9&$FFFF
		dw WSIZES10&$FFFF
WPROPS:		dw WPROPS1&$FFFF,WPROPS2&$FFFF,WPROPS3&$FFFF
		dw WPROPS4&$FFFF,WPROPS5&$FFFF,WPROPS6&$FFFF
		dw WPROPS7&$FFFF,WPROPS8&$FFFF,WPROPS9&$FFFF
		dw WPROPS10&$FFFF

WTILES1:	db !WingTop1,!WingBottom1
WXDISP1:	db $09,$09
WYDISP1:	db $00,$F0
WSIZES1:	db $00,$02
WPROPS1:	db $80,$80

WTILES2:	db !WingTop2,!WingBottom2
WXDISP2:	db $08,$08
WYDISP2:	db $F7,$E7
WSIZES2:	db $02,$02
WPROPS2:	db $00,$00

WTILES3:	db !WingTop3,!WingBottom3
WXDISP3:	db $09,$0E
WYDISP3:	db $F6,$F1
WSIZES3:	db $02,$00
WPROPS3:	db $00,$00

WTILES4:	db !Wing4
WXDISP4:	db $0B
WYDISP4:	db $00
WSIZES4:	db $02
WPROPS4:	db $00

WTILES5:	db !Wing5
WXDISP5:	db $0A
WYDISP5:	db $08
WSIZES5:	db $02
WPROPS5:	db $00

WTILES6:	db !WingTop1,!WingBottom1
WXDISP6:	db $09,$09
WYDISP6:	db $08,$10
WSIZES6:	db $00,$02
WPROPS6:	db $00,$00

WTILES7:	db !WingTop3,!WingBottom3
WXDISP7:	db $09,$0E
WYDISP7:	db $0A,$17
WSIZES7:	db $02,$00
WPROPS7:	db $80,$80

WTILES8:	db !Wing4
WXDISP8:	db $0B
WYDISP8:	db $00
WSIZES8:	db $02
WPROPS8:	db $80

WTILES9:	db !Wing5
WXDISP9:	db $0A
WYDISP9:	db $F8
WSIZES9:	db $02
WPROPS9:	db $80

WTILES10:	db !WingTop6,!WingBottom6
WXDISP10:	db $0C,$1C
WYDISP10:	db $00,$00
WSIZES10:	db $02,$02
WPROPS10:	db $00,$00

HEADINDEXES:	db $00,$00,$00,$00
		db $02,$02,$02,$02
		db $04,$04,$04,$04

HTILES:		dw HTILES1&$FFFF,HTILES2&$FFFF,HTILES3&$FFFF
HXDISP:		dw HXDISP1&$FFFF,HXDISP2&$FFFF,HXDISP3&$FFFF
HYDISP:		dw HYDISP1&$FFFF,HYDISP2&$FFFF,HYDISP3&$FFFF

HTILES1:		db !Head,!Body1
HXDISP1:		db $F8,$08
HYDISP1:		db $00,$00

HTILES2:		db !Head,!Body2
HXDISP2:		db $F8,$08
HYDISP2:		db $00,$00

HTILES3:		db !Head,!Body3
HXDISP3:		db $F8,$08
HYDISP3:		db $00,$00

SUB_GFX:	%GetDrawInfo()		; get info to draw tiles
		STZ $09			; zero tiles drawn
		STZ $07			; next wing not flipped
		JSR DRAW_WING		; draw wing
		JSR DRAW_HEAD		; draw head/body
		INC $07			; next wing is flipped
		JSR DRAW_WING		; draw wing
		JSR SETTILES		; set tiles / don't draw offscreen
ENDSUB:		RTS

DRAW_WING:	LDA !157C,x		; \  actual flip of this
		EOR $07			;  | wing = sprite's flip
		STA $08			; /  flipped with wing's flip
		PHY			; \
		LDY !1602,x		;  | store index for
		LDA WINGINDEXES,y	;  | frame data to
		STA $06			;  | scratch RAM
		LSR			;  |
		TAY			;  | ... then set
		LDA WCOUNT,y		;  | number of tiles
		STA $0B			;  | for this wing
		PLY			; /
		PHX			; back up X
		LDX #$00		; load X with zero
TILELP:		CPX $0B			; end of loop?
		BNE NORETFRML		; \ if so,
		JMP RETFRML		; / then end
NORETFRML:	PHY			; \
		LDY $06			;  | get X
		LDA WXDISP,y		;  | offset
		STA $04			;  | for this

		PHY
		TYA
		INC A
		TAY
		LDA WXDISP,y		;  | tile and
		PLY

		STA $05			;  | flip it
		TXY			;  | if the
		LDA ($04),y		;  | wing is
		PHX			;  | flipped
		LDX $15E9|!Base2	;  |
		LDY $08			;  |
		BNE NO_FLIP_X		;  |
		EOR #$FF		;  |
		INC A			;  |
NO_FLIP_X:	LDY !157C,x		;  |
		CLC			;  |
		ADC DIRWINGOFFSETS,y	;  |
		PLX			;  |
		PLY			; /
		CLC			; \ add it to sprite's
		ADC $00			; / screen X offset
		STA $0300|!Base2,y	; set tile's X position
		PHY			; \
		LDY $06			;  | get Y
		LDA WYDISP,y		;  | offset
		STA $04			;  | for this

		PHY
		TYA
		INC A
		TAY
		LDA WYDISP,y		;  | tile and
		PLY

		STA $05			;  |
		TXY			;  |
		LDA ($04),y		;  |
		PLY			; /
		CLC			; \ add it to sprite's
		ADC $01			; / screen Y offset
		STA $0301|!Base2,y	; set tile's Y position
		PHY			; \
		LDY $06			;  | get
		LDA WTILES,y		;  | tile
		STA $04			;  | number

		PHY
		TYA
		INC A
		TAY
		LDA WTILES,y		;  | tile and
		PLY

		STA $05			;  |
		TXY			;  |
		LDA ($04),y		;  |
		PLY			; /
		STA $0302|!Base2,y	; set tile #
		PHY			; \
		LDY $06			;  | get
		LDA WSIZES,y		;  | tile
		STA $04			;  | size

		PHY
		TYA
		INC A
		TAY
		LDA WSIZES,y		;  | tile and
		PLY

		STA $05			;  |
		TXY			;  |
		LDA ($04),y		;  |
		PLY			; /
		PHX			; back up X
		PHA			; \
		TYA			;  | get index to extra tile
		LSR #2			;  | properties
		TAX			;  |
		PLA			; /
		STA $0460|!Base2,x	; set tile size
		PLX			; load backed up X
		CMP #$02		; \
		BEQ NO_ADD_8		;  | if flipped
		LDA $08			;  | and it is
		BNE NO_ADD_8		;  | 8x8, add
		LDA $0300|!Base2,y	;  | 8 to its
		CLC			;  | X position
		ADC #$08		;  |
		STA $0300|!Base2,y	; /
NO_ADD_8:	PHY			; \
		LDY $06			;  | get Y
		LDA WPROPS,y		;  | offset
		STA $04			;  | for this

		PHY
		TYA
		INC A
		TAY
		LDA WPROPS,y		;  | tile and
		PLY

		STA $05			;  |
		TXY			;  |
		LDA ($04),y		;  |
		PLY			; /
		STA $0A
		PHX			; back up X (index to tile data)
		LDX $15E9|!Base2	; load X with index to sprite
		LDA !15F6,x		; load palette info
		PHY			; \
		LDY $08			;  | flip the tile
		BNE NO_FLIP_X_2		;  | if the sprite
		ORA #$40		;  | is flipped
NO_FLIP_X_2:	PLY			; /
		PLX			; load backed up X
		ORA $0A
		ORA $64			; add in priority bits
		STA $0303|!Base2,y	; set extra info
		INY			; \
		INY			;  | index to next slot
		INY			;  |
		INY			; /
		INX			; next tile to draw
		INC $09			; another tile was drawn
		JMP TILELP		; loop
RETFRML:	PLX			; load backed up X
		RTS

DRAW_HEAD:	LDA !157C,x		; \ flip for the head/body is
		STA $08			; / the sprite's flip setting
		PHY			; \
		LDY !1528,x		;  | store index for
		LDA HEADINDEXES,y	;  | frame data to
		STA $06			;  | scratch RAM
		PLY			; /
		PHX			; back up X
		LDX #$00		; load X with zero
TILELP2:	CPX #$02		; end of loop?
		BNE NORETFRML2		; if so, then end
		JMP RETFRML2
NORETFRML2:	PHY			; \
		LDY $06			;  | get X
		LDA HXDISP,y		;  | offset
		STA $04			;  | for this

		PHY
		TYA
		INC A
		TAY
		LDA HXDISP,y		;  | tile and
		PLY

		STA $05			;  | flip it
		TXY			;  | if the
		LDA ($04),y		;  | wing is
		PHX			;  | flipped
		LDX $15E9|!Base2	;  |
		LDY $08			;  |
		BNE NO_FLIP_X_3		;  |
		EOR #$FF			;  |
		INC A			;  |
NO_FLIP_X_3:	PLX			;  |
		PLY			; /
		CLC			; \ add it to sprite's
		ADC $00			; / screen X offset
		STA $0300|!Base2,y	; set tile's X position
		PHY			; \
		LDY $06			;  | get Y
		LDA HYDISP,y		;  | offset
		STA $04			;  | for this

		PHY
		TYA
		INC A
		TAY
		LDA HYDISP,y		;  | tile and
		PLY

		STA $05			;  |
		TXY			;  |
		LDA ($04),y		;  |
		PLY			; /
		CLC			; \ add it to sprite's
		ADC $01			; / screen Y offset
		STA $0301|!Base2,y	; set tile's Y position
		PHY			; \
		LDY $06			;  | get
		LDA HTILES,y		;  | tile
		STA $04			;  | number

		PHY
		TYA
		INC A
		TAY
		LDA HTILES,y		;  | tile and
		PLY

		STA $05			;  |
		TXY			;  |
		LDA ($04),y		;  |
		PLY			; /
		STA $0302|!Base2,y	; set tile #
		PHX			; back up X
		TYA			; \  get index to extra tile 
		LSR #2			;  | properties
		TAX			; /
		LDA #$02		; #$02 means size = 16x16
		STA $0460|!Base2,x	; set tile size
		LDX $15E9|!Base2	; load X with index to sprite
		LDA !15F6,x		; load palette info
		PHY			; \
		LDY $08			;  | flip the tile
		BNE NO_FLIP_X_4		;  | if the sprite
		ORA #$40		;  | is flipped
NO_FLIP_X_4:	PLY			; /
		PLX			; load backed up X
		ORA $64			; add in priority bits
		STA $0303|!Base2,y	; set extra info
		INY			; \
		INY			;  | index to next slot
		INY			;  |
		INY			; /
		INX			; next tile to draw
		INC $09			; another tile was drawn
		JMP TILELP2		; loop
RETFRML2:	PLX			; load backed up X
		RTS

SETTILES:	LDA $09			; \ don't do it
		BEQ NODRAW		; / if no tiles
		LDY #$FF		; #$FF means don't define sizes here
		DEC A			; A = # tiles - 1
		JSL $01B7B3|!BankB	; don't draw if offscreen
NODRAW:		RTS

WLSINDEXES:	db $00,$00,$02,$02,$04,$04

WLSTILES:	dw WLSTILES1&$FFFF,WLSTILES2&$FFFF,WLSTILES3&$FFFF
WLSXDISP:	dw WLSXDISP1&$FFFF,WLSXDISP2&$FFFF,WLSXDISP3&$FFFF
WLSYDISP:	dw WLSYDISP1&$FFFF,WLSYDISP2&$FFFF,WLSYDISP3&$FFFF
WLSSIZES:	dw WLSSIZES1&$FFFF,WLSSIZES2&$FFFF,WLSSIZES3&$FFFF

WLSTILES1:	db !Head,!Body4,!Body2
WLSXDISP1:	db $F8,$03,$08
WLSYDISP1:	db $01,$09,$01
WLSSIZES1:	db $02,$02,$00

WLSTILES2:	db !Head,!Body5,!Body3
WLSXDISP2:	db $F8,$03,$08
WLSYDISP2:	db $00,$08,$00
WLSSIZES2:	db $02,$02,$00

WLSTILES3:	db !Head,!Body6,!Body1
WLSXDISP3:	db $F8,$03,$08
WLSYDISP3:	db $00,$08,$00
WLSSIZES3:	db $02,$02,$00

SUB_GFX2:	%GetDrawInfo()
		PHY			; \
		LDY !1602,x		;  | store index for
		LDA WLSINDEXES,y	;  | frame data to
		STA $06			;  | scratch RAM
		PLY			; /

		PHX			; back up X
		LDX #$00		; load X with zero
WLSLP:		CPX #$03		; end of loop?
		BNE NRETFRML		; if so, then end
		JMP RTFRML
NRETFRML:
		PHY			; \
		LDY $06			;  | get X
		LDA WLSXDISP,y		;  | offset
		STA $04			;  | for this
		LDA WLSXDISP+1,y	;  | tile and
		STA $05			;  | flip it
		TXY			;  | if the
		LDA ($04),y		;  | sprite is
		PHX			;  | flipped
		LDX $15E9|!Base2	;  |
		LDY !157C,x		;  |
		BNE NOFLIPX		;  |
		EOR #$FF		;  |
		INC A			;  |
NOFLIPX:	PLX			;  |
		PLY			; /
		CLC			; \ add it to sprite's
		ADC $00			; / screen X offset
		STA $0300|!Base2,y	; set tile's X position
		PHY			; \
		LDY $06			;  | get Y
		LDA WLSYDISP,y		;  | offset
		STA $04			;  | for this
		LDA WLSYDISP+1,y	;  | tile
		STA $05			;  |
		TXY			;  |
		LDA ($04),y		;  |
		PLY			; /
		CLC			; \ add it to sprite's
		ADC $01			; / screen Y offset
		STA $0301|!Base2,y	; set tile's Y position
		PHY			; \
		LDY $06			;  | get
		LDA WLSTILES,y		;  | tile
		STA $04			;  | number
		LDA WLSTILES+1,y	;  |
		STA $05			;  |
		TXY			;  |
		LDA ($04),y		;  |
		PLY			; /
		STA $0302|!Base2,y	; set tile #
		PHY			; \
		LDY $06			;  | get
		LDA WLSSIZES,y		;  | tile
		STA $04			;  | size
		LDA WLSSIZES+1,y	;  |
		STA $05			;  |
		TXY			;  |
		LDA ($04),y		;  |
		PLY			; /
		PHX			; back up X
		PHA			; \
		TYA			;  | get index to
		LSR #2			;  | extra tile properties
		TAX			;  |
		PLA			; /
		STA $0460|!Base2,x	; set tile size
		PLX			; load backed up X
		CMP #$02		; \
		BEQ NOADD_8		;  | if the
		PHX			;  | tile is
		LDX $15E9|!Base2	;  | flipped
		LDA !157C,x		;  | and it
		PLX			;  | is an 8x8
		CMP #$00		;  | then add
		BNE NOADD_8		;  | 8 to its
		LDA $0300|!Base2,y	;  | X position
		CLC			;  | to fix a
		ADC #$08		;  | glitch
		STA $0300|!Base2,y	; /
NOADD_8:
		PHX			; back up X (index to tile data)
		LDX $15E9|!Base2	; load X with index to sprite
		LDA !15F6,x		; load palette info
		PHY			; \
		LDY !157C,x		;  | flip the tile
		BNE NOFLIPX_2		;  | if the sprite
		ORA #$40		;  | is flipped
NOFLIPX_2:	PLY			; /
		PLX			; load backed up X
		ORA $64			; add in priority bits
		STA $0303|!Base2,y	; set extra info
		INY			; \
		INY			;  | index to next slot
		INY			;  |
		INY			; /
		INX			; next tile to draw
		JMP WLSLP		; loop
RTFRML:		PLX			; load backed up X

		LDY #$FF		; #$FF means don't define WLSSIZES here
		LDA #$02		; #$02 means 3 WLSTILES drawn
		JSL $01B7B3|!BankB	; don't draw if offscreen
		RTS