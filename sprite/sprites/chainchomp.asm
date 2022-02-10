;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SMB3 Chain Chomp (v1.1)
; Coded by SMWEdit
;
; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!CHAINTILE = $85
		!OPENMOUTHTILE = $86
		!CLOSEDMOUTHTILE = $8A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!HOLDOUTTIME = $18	; time to hold position after dashing outwards

		!MAX_LINK_X = $0D
		!MAX_LINK_Y = $0E

		!MAX_TOTAL_X = $34
		!MAX_TOTAL_Y = $39

		!ACTSTATUS = !C2		; 0    - start dashing out
					; 1    - dashing out (checking for max)
					; 2    - reached max, stationary, waiting
					; 3    - falling
					; 4-11 - moving on ground, waiting for time to start another dash (different status means different motion)
		!GFXFLIP = !1504
		!FRAMECOUNTER = !1528
		!TIMER = !163E

        !Freerampos = $7F9A7B   ; RAM FOR SEGMENTS POSITION (DEFAULT USES WIGGLER'S)
        if !SA1
        !Freerampos = $418800
        endif
        
		!ORIGINXLO = !Freerampos+($2A*0)
		!ORIGINXHI = !Freerampos+($2A*1)
		!ORIGINYLO = !Freerampos+($2A*2)
		!ORIGINYHI = !Freerampos+($2A*3)

		!LINK1XLO = !Freerampos+($2A*4)
		!LINK2XLO = !Freerampos+($2A*5)
		!LINK3XLO = !Freerampos+($2A*6)
		!LINK4XLO = !Freerampos+($2A*7)

		!LINK1YLO = !Freerampos+($2A*8)
		!LINK2YLO = !Freerampos+($2A*9)
		!LINK3YLO = !Freerampos+($2A*10)
		!LINK4YLO = !Freerampos+($2A*11)
        
        

		!TMP1 = $00
		!TMP2 = $01
		!TMP3 = $02
		!TMP4 = $03

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		print "INIT ", pc
		LDA !D8,x		; \
		STA !ORIGINYLO,x		;  | set Y low
		STA !LINK1YLO,x		;  | byte for
		STA !LINK2YLO,x		;  | origin and
		STA !LINK3YLO,x		;  | start of links
		STA !LINK4YLO,x		; /
		LDA !E4,x		; \
		STA !ORIGINXLO,x		;  | set X low
		STA !LINK1XLO,x		;  | byte for
		STA !LINK2XLO,x		;  | origin and
		STA !LINK3XLO,x		;  | start of links
		STA !LINK4XLO,x		; /
		LDA !14D4,x		; \ set Y high
		STA !ORIGINYHI,x		; / byte for origin
		LDA !14E0,x		; \ set X high
		STA !ORIGINXHI,x		; / byte for origin
		RTL

		print "MAIN ", pc
		PHB
		PHK
		PLB
		JSR SPRITE_ROUTINE
		PLB
		RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAXLINKDISTX:	db !MAX_LINK_X,0-!MAX_LINK_X&$FF
MAXLINKDISTY:	db !MAX_LINK_Y,0-!MAX_LINK_Y&$FF

MAXTOTALDISTX:	db !MAX_TOTAL_X,0-!MAX_TOTAL_X&$FF
MAXTOTALDISTY:	db !MAX_TOTAL_Y,0-!MAX_TOTAL_Y&$FF

MAXHIBYTES:	db $00,$FF

FALLXSPEEDS:	db $F8,$08

XSPEEDS:		db $50,$50,$50,$50,$40,$30,$20,$1C
YSPEEDS:		db $E0,$D0,$C0,$B0,$B0,$B0,$B0,$B0

; ...

LENGTH:		db $39,$19,$23,$3D,$0D,$39,$41,$19
NEEDRETURN:	db $01,$00,$01,$01,$00,$01,$01,$01

SPEEDS:		dw ACTION1SPEED&$FFFF,ACTION2SPEED&$FFFF
		dw ACTION3SPEED&$FFFF,ACTION4SPEED&$FFFF
		dw ACTION5SPEED&$FFFF,ACTION6SPEED&$FFFF
		dw ACTION7SPEED&$FFFF,ACTION8SPEED&$FFFF

DIRS:		dw ACTION1DIR&$FFFF,ACTION2DIR&$FFFF
		dw ACTION3DIR&$FFFF,ACTION4DIR&$FFFF
		dw ACTION5DIR&$FFFF,ACTION6DIR&$FFFF
		dw ACTION7DIR&$FFFF,ACTION8DIR&$FFFF

BITES:		dw ACTION1BITE&$FFFF,ACTION2BITE&$FFFF
		dw ACTION3BITE&$FFFF,ACTION4BITE&$FFFF
		dw ACTION5BITE&$FFFF,ACTION6BITE&$FFFF
		dw ACTION7BITE&$FFFF,ACTION8BITE&$FFFF

ACTION1SPEED:	db $10
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0

ACTION1DIR:	db $00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01

ACTION1BITE:	db $01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02

ACTION2SPEED:	db $00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00

ACTION2DIR:	db $01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01

ACTION2BITE:	db $02
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02
; ACTION2BITE:
	db $01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01


ACTION3SPEED:	db $10,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0

ACTION3DIR:	db $00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01

ACTION3BITE:	db $01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02

ACTION4SPEED:	db $10,$00,$00,$00,$00
		db $00,$00,$00,$00,$10,$10,$10,$10
		db $10,$10,$10,$10,$10,$10,$10,$10
		db $10,$10,$10,$10,$10,$10,$10,$10
		db $10,$10,$10,$10,$10,$10,$10,$10
		db $10,$10,$10,$10,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0

ACTION4DIR:	db $00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01

ACTION4BITE:	db $01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02

ACTION5SPEED:	db $E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0

ACTION5DIR:	db $01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01

ACTION5BITE:	db $02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02

ACTION6SPEED:	db $10
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $10,$10,$10,$10,$10,$10,$10,$10
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0

ACTION6DIR:	db $00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01

ACTION6BITE:	db $01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02

ACTION7SPEED:	db $10
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $10,$10,$10,$10,$10,$10,$10,$10
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0

ACTION7DIR:	db $00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01

ACTION7BITE:	db $01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02

ACTION8SPEED:	db $10
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0

ACTION8DIR:	db $00
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01

ACTION8BITE:	db $01
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02

RETURN1:		RTS

SPRITE_ROUTINE:	JSR SUB_GFX
		LDA !14C8,x		; \
		CMP #$08		;  | don't process when not "normal" status
		BNE RETURN1		; /
		LDA $9D			; \ return if
		BNE RETURN1		; / sprites locked
		JSR OFFSCREENCHK	; custom offscreen checker, range of 0x100 pixels offscreen (the chomps kept vanishing without this)

		JSL $018022             ; Update X position without gravity
        	JSL $01801A             ; Update Y position without gravity
		JSL $01A7DC		; check for mario/sprite contact

		LDA !ACTSTATUS,x		; get status
		BEQ BEGINDASH		; go to "begin dash" if it's 0
		DEC			; next
		BEQ DASHING		; go to "dashing" if it's 1
		DEC			; next
		BEQ HOLDDASHJMP		; go to "holding dash" if it's 2
		DEC			; next
		BEQ FALLINGJMP		; go to "falling" if it's 3
		JMP MOVING		; go to "moving" if it's anything else

HOLDDASHJMP:	JMP HOLDDASH		; \ a branch to these
FALLINGJMP:	JMP FALLING		; / would be out of range

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BEGINDASH:
		JSR Suborzpoz	; \
		TYA			;  | face mario
		STA !157C,x		; /
		STA !GFXFLIP,x		; this flip will also be how the GFX is flipped

		JSR GETRANDOM		; get "random" number 0-7
		TAY			; ... -> Y
		LDA YSPEEDS,y		; \ Y speed from the
		STA !AA,x		; / table of Y speeds
		LDA XSPEEDS,y		; \
		LDY !157C,x		;  | set X speed
		BEQ SETXSPEED		;  | from the table
		EOR #$FF		;  | and flip if
		INC			;  | necessary
SETXSPEED:	STA !B6,x		; /

		INC !ACTSTATUS,x		; go to next action

		RTS

; ...

DASHING:
		INC !FRAMECOUNTER,x
		LDY #$00		; Y=0 means positive, could be changed later
		LDA !E4,x		; \  get distance
		SEC			;  | between position
		SBC !ORIGINXLO,x		; /  and origin
		BPL CHKXDIST		; if positive, skip negative code
		INY			; Y=1 (0+1) means negative, this is where it's changed
		EOR #$FF		; \ make negative
		INC			; / positive
CHKXDIST:	CMP #!MAX_TOTAL_X	; compare with maximum
		BCC XDISTOK		; skip next bit of code if the distance is within the maximum
		LDA MAXTOTALDISTX,y	; \
		CLC			;  | set position
		ADC !ORIGINXLO,x		;  | to maximum
		STA !E4,x		;  |
		LDA !ORIGINXHI,x		;  |
		ADC MAXHIBYTES,y	;  |
		STA !14E0,x		; /
		BRA ENDDASH		; branch to code for preparing for next status
XDISTOK:

		LDY #$00		; Y=0 means positive, could be changed later
		LDA !D8,x		; \  get distance
		SEC			;  | between position
		SBC !ORIGINYLO,x		; /  and origin
		BPL CHKYDIST		; if positive, skip negative code
		INY			; Y=1 (0+1) means negative, this is where it's changed
		EOR #$FF		; \ make negative
		INC			; / positive
CHKYDIST:	CMP #!MAX_TOTAL_Y	; compare with maximum
		BCC YDISTOK		; skip next bit of code if the distance is within the maximum
		LDA MAXTOTALDISTY,y	; \
		CLC			;  | set position
		ADC !ORIGINYLO,x		;  | to maximum
		STA !D8,x		;  |
		LDA !ORIGINYHI,x		;  |
		ADC MAXHIBYTES,y	;  |
		STA !14D4,x		; /
		BRA ENDDASH
YDISTOK:

		JSR MOVELINKS		; call custom subroutine to make links move

		RTS

ENDDASH:
		STZ !AA,x		; zero Y speed
		STZ !B6,x		; zero X speed
		INC !ACTSTATUS,x		; next status
		LDA #!HOLDOUTTIME	; \ set timer for
		STA !TIMER,x		; / holding dash
		JSR LINEUPLINKS		; call custom subroutine to line up the links
		RTS

; ...

HOLDDASH:
		INC !FRAMECOUNTER,x	; \
		INC !FRAMECOUNTER,x	;  | elapse 3/4 a frame
		INC !FRAMECOUNTER,x	; /
		LDA !TIMER,x		; \ if timer not expired, then
		BNE RETURNHOLD		; / don't go to next status
		INC !ACTSTATUS,x		; go to next status
RETURNHOLD:	RTS

; ...

FALLING:
		INC !FRAMECOUNTER,x	; \ elapse 1/2 a frame
		INC !FRAMECOUNTER,x	; /
		JSR Suborzpoz_H	; \
		TYA			;  | set GFX flip
		STA !GFXFLIP,x		; /

		JSR MOVELINKS		; call custom subroutine to make links move

		LDA !D8,x		; \  if Y is at or below origin
		CMP !ORIGINYLO,x		;  | (on ground), then this
		BPL ENDFALL		; /  is the end of falling

		INC !AA,x		; \ pseudo-gravity
		INC !AA,x		; /

		LDY !157C,x		; \  set slight
 		LDA FALLXSPEEDS,y	;  | X speed for
		STA !B6,x		; /  when falling

		RTS

ENDFALL:
		LDA #$F0		; \ set speed for the slight
		STA !AA,x		; / bounce when it lands
		LDA !ORIGINYLO,x		; \
		STA !D8,x		;  | set head at the Y
		LDA !ORIGINYHI,x		;  | position of the origin
		STA !14D4,x		; /
		INC !ACTSTATUS,x		; next status
		JSR GETRANDOM		; get "random" number
		PHA			; preserve "random" number
		CLC			; \ add to
		ADC !ACTSTATUS,x		; / status
		STA !ACTSTATUS,x		; set new status
		PLY			; pull "random" number to Y
		LDA LENGTH,y		; get timer length based on what action
		STA !TIMER,x		; set timer for movement
		RTS

; ...

MOVING:
		LDA !ACTSTATUS,x		; \
		SEC			;  | 4-11 are the indexes
		SBC #$04		;  | for movement type
		STA !TMP1		; /

		ASL			; \
		TAY			;  | frame
		LDA BITES,y		;  | rate is
		STA !TMP2		;  | determined
		LDA BITES+1,y		;  | by a
		STA !TMP3		;  | table
		LDY !TIMER,x		;  |
		LDA (!TMP2),y		;  |
		CLC			;  |
		ADC !FRAMECOUNTER,x	;  |
		STA !FRAMECOUNTER,x	; /

		LDA !157C,x		; \ 
		STA !TMP4		;  | get flip
		LDY !TIMER,x		;  | for motion
		BNE NO_OVERRIDE_DIR	;  |
		LDY !TMP1		;  |
		LDA NEEDRETURN,y	;  |
		BEQ NO_OVERRIDE_DIR	;  |
		LDY #$00		;  |
		LDA !E4,x		;  |
		CMP !ORIGINXLO,x		;  |
		LDA !14E0,x		;  |
		SBC !ORIGINXHI,x		;  |
		BMI SETNEWDIR		;  |
		INY			;  |
SETNEWDIR:	STY !TMP4		; /
NO_OVERRIDE_DIR:

		LDA !TMP1		; \
		ASL			;  | set X speed
		TAY			;  | based on
		LDA SPEEDS,y		;  | table and
		STA !TMP2		;  | flip set
		LDA SPEEDS+1,y		;  | in above
		STA !TMP3		;  | code
		LDY !TIMER,x		;  |
		LDA (!TMP2),y		;  |
		LDY !TMP4		;  |
		BEQ SETXSPEED2		;  |
		EOR #$FF		;  |
		INC			;  |
SETXSPEED2:	STA !B6,x		; /

		LDY !TMP1		; \  if this motion doesn't require a return
		LDA NEEDRETURN,y	;  | to the origin to start another dash,
		BEQ DIRFROMTABLE	; /  always get the GFX flip from table
		LDA !TIMER,x		; \ if the timer is expired,
		BEQ FACEORIGIN		; / then face the origin
DIRFROMTABLE:	TYA			; motion index is in Y, transfer to A
		ASL			; x2
		TAY			; back to Y
		LDA DIRS,y		; \
		STA !TMP2		;  | get GFX
		LDA DIRS+1,y		;  | flip from
		STA !TMP3		;  | table of
		LDY !TIMER,x		;  | directions
		LDA (!TMP2),y		; /
		EOR !157C,x		; flip if sprite direction is flipped
		STA !GFXFLIP,x		; set GFX flip
		BRA END_GFX_DIR		; branch over other GFX flip settings
FACEORIGIN:	JSR Suborzpoz_H	; \  set GFX flip
		TYA			;  | as facing
		STA !GFXFLIP,x		; /  towards origin
END_GFX_DIR:

		LDA !D8,x		; \  if Y is at or below origin
		CMP !ORIGINYLO,x		;  | (on ground), then there
		BPL ATGROUND		; /  should be no falling
		INC !AA,x		; \ pseudo-gravity
		INC !AA,x		; /
		BRA ENDGRAVITY		; skip ground code
ATGROUND:	STZ !AA,x		; zero Y speed
		LDA !ORIGINYLO,x		; \
		STA !D8,x		;  | set head at the Y
		LDA !ORIGINYHI,x		;  | position of the origin
		STA !14D4,x		; /
ENDGRAVITY:

		LDA !TIMER,x		; \ if the timer's expired,
		BNE NO_START_DASH	; / then don't start new dash
		LDY !TMP1		; \  if this movement doesn't
		LDA NEEDRETURN,y	;  | need to return to origin,
		BEQ BEGINNEWDASH	; /  then start a new dash
		LDA !E4,x		; \  if not at origin
		CMP !ORIGINXLO,x		;  | do not start a
		BNE NO_START_DASH	; /  new dash
BEGINNEWDASH:	STZ !ACTSTATUS,x		; status: start dash
		STZ !B6,x		; zero X speed
		STZ !AA,x		; zero Y speed
NO_START_DASH:

		JSR DROPLINKS		; call custom subroutine to make the links fall
		JSR MOVELINKS		; call custom subroutine to make links move

		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OFFSCREENCHK:	LDA $5B			; \  skip to vertical level
		AND #%00000001		;  | check if the level is
		BNE OFFSCREENCHKV	; /  a vertical level

OFFSCREENCHKH:	LDA !E4,x		; \
		CMP $1A			;  | horizontal
		STA !TMP1		;  | level check
		LDA !14E0,x		;  |
		SBC $1B			;  |
		BMI BEFORESCREENH	;  |
AFTERSCREENH:	CMP #$02		;  |
		BCS OFFSCREEN		;  |
		BRA NOTOFFSCREENH	;  |
BEFORESCREENH:	CMP #$FF		;  |
		BCC OFFSCREEN		; /
NOTOFFSCREENH:	RTS

OFFSCREENCHKV:	LDA !D8,x		; \
		CMP $1C			;  | vertical
		STA !TMP1		;  | level check
		LDA !14D4,x		;  |
		SBC $1D			;  |
		BMI BEFORESCREENV	;  |
AFTERSCREENV:	CMP #$01		;  |
		BCS OFFSCREEN		;  |
		BRA NOTOFFSCREENV	;  |
BEFORESCREENV:	CMP #$FF		;  |
		BCC OFFSCREEN		; /
NOTOFFSCREENV:	RTS

OFFSCREEN:	LDA #$00		; \  kill sprite,
		LDY !161A,x		;  | but allow
        PHX
        TYX
		STA !1938,x		;  | sprite to
        PLX
		STZ !14C8,x		; /  reload again
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GETRANDOM:	LDA $13			; frame counter so it's different for each frame
		ASL			; * 2
		CLC			; \ + sprite's frame counter
		ADC !FRAMECOUNTER,x	; /
		CLC			; \ + sprite index so it's different for each sprite
		ADC $15E9|!Base2		; /
		CLC			; \ + X position because it appears to prevent some repetition
		ADC !E4,x		; /
		CLC			; \ + Y position because it appears to prevent some repetition
		ADC !D8,x		; /
		CLC			; \ + Mario X position so it slightly changes dash patterns when he moves
		ADC $94			; /
		CLC			; \ + Timer frame counter to remove some more repetition
		ADC $0F30|!Base2		; /
		AND #%00000111		; wrap at 8
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DROPLINKS:	LDA !ORIGINYLO,x		; \
		CLC			;  | set max Y position
		ADC #$05		;  | for the links
		STA !TMP1		; /

DROPLINK1:	LDA !LINK1YLO,x		; \
		CLC			;  | Link 1
		ADC #$02		;  |
		STA !LINK1YLO,x		;  |
		LDA !LINK1YLO,x		;  |
		CMP !TMP1		;  |
		BMI DROPLINK2		;  |
		LDA !TMP1		;  |
		STA !LINK1YLO,x		; /

DROPLINK2:	LDA !LINK2YLO,x		; \
		CLC			;  | Link 2
		ADC #$02		;  |
		STA !LINK2YLO,x		;  |
		LDA !LINK2YLO,x		;  |
		CMP !TMP1		;  |
		BMI DROPLINK3		;  |
		LDA !TMP1		;  |
		STA !LINK2YLO,x		; /

DROPLINK3:	LDA !LINK3YLO,x		; \
		CLC			;  | Link 3
		ADC #$02		;  |
		STA !LINK3YLO,x		;  |
		LDA !LINK3YLO,x		;  |
		CMP !TMP1		;  |
		BMI DROPLINK4		;  |
		LDA !TMP1		;  |
		STA !LINK3YLO,x		; /

DROPLINK4:	LDA !LINK4YLO,x		; \
		CLC			;  | Link 4
		ADC #$02		;  |
		STA !LINK4YLO,x		;  |
		LDA !LINK4YLO,x		;  |
		CMP !TMP1		;  |
		BMI ENDLINKDROP		;  |
		LDA !TMP1		;  |
		STA !LINK4YLO,x		; /
		
ENDLINKDROP:	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LINEUPLINKS:	LDY #$00		; \
		LDA !E4,x		;  | set positive
		SEC			;  | X distance
		SBC !ORIGINXLO,x		;  |
		BPL SETXLINE		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
SETXLINE:	STA !TMP1		; /

		ASL			; \
		CLC			;  | Link 1 X
		ADC !TMP1		;  |
		LSR			;  | Math: DIST*3/4
		LSR			;  |
		CPY #$00		;  |
		BEQ SETL1XPOS		;  |
		EOR #$FF		;  |
		INC			;  |
SETL1XPOS:	CLC			;  |
		ADC !ORIGINXLO,x		;  |
		STA !LINK1XLO,x		; /

		LDA !TMP1		; \
		LSR			;  | Link 2 X
		CPY #$00		;  |
		BEQ SETL2XPOS		;  | Math: DIST/2 (DIST*2/4)
		EOR #$FF		;  |
		INC			;  |
SETL2XPOS:	CLC			;  |
		ADC !ORIGINXLO,x		;  |
		STA !LINK2XLO,x		; /

		LDA !TMP1		; \
		LSR			;  | Link 3 X
		LSR			;  |
		CPY #$00		;  | Math: DIST/4 (DIST*1/4)
		BEQ SETL3XPOS		;  |
		EOR #$FF		;  |
		INC			;  |
SETL3XPOS:	CLC			;  |
		ADC !ORIGINXLO,x		;  |
		STA !LINK3XLO,x		; /

		LDA !ORIGINXLO,x		; \ Link 4 X
		STA !LINK4XLO,x		; / X will always be 0 apart from origin

		LDY #$00		; \
		LDA !D8,x		;  | Set positive
		SEC			;  | Y distance
		SBC !ORIGINYLO,x		;  |
		BPL SETYLINE		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
SETYLINE:	STA !TMP1		; /

		ASL			; \
		ASL			;  | Link 1 Y
        if !SA1
        STA $2251
        STZ $2252
        LDA #$01				; \ Set Division Mode.
        STA $2250				; /
        REP #$20
        LDA #$0005
        STA $2253
        NOP     				; \ ... Wait 5 cycles!
        BRA $00 				; /
        SEP #$20
        LDA $2306
        else
		STA $4204		;  |
		STZ $4205		;  | Math: DIST*4/5
		LDA #$05		;  |
		STA $4206		;  |
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		LDA $4214		;  |
        endif
		CPY #$00		;  |
		BEQ SETL1YPOS		;  |
		EOR #$FF		;  |
		INC			;  |
SETL1YPOS:	CLC			;  |
		ADC !ORIGINYLO,x		;  |
		STA !LINK1YLO,x		; /

		LDA !TMP1		; \
		ASL			;  | Link 2 Y
		CLC			;  |
		ADC !TMP1		;  | Math: DIST*3/5
        if !SA1
        STA $2251
        STZ $2252
        LDA #$01				; \ Set Division Mode.
        STA $2250				; /
        REP #$20
        LDA #$0005
        STA $2253
        NOP     				; \ ... Wait 5 cycles!
        BRA $00 				; /
        SEP #$20
        LDA $2306
        else
		STA $4204		;  |
		STZ $4205		;  | Math: DIST*4/5
		LDA #$05		;  |
		STA $4206		;  |
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		LDA $4214		;  |
        endif
		CPY #$00		;  |
		BEQ SETL2YPOS		;  |
		EOR #$FF		;  |
		INC			;  |
SETL2YPOS:	CLC			;  |
		ADC !ORIGINYLO,x		;  |
		STA !LINK2YLO,x		; /

		LDA !TMP1		; \
		ASL			;  | Link 3 Y
        if !SA1
        STA $2251
        STZ $2252
        LDA #$01				; \ Set Division Mode.
        STA $2250				; /
        REP #$20
        LDA #$0005
        STA $2253
        NOP     				; \ ... Wait 5 cycles!
        BRA $00 				; /
        SEP #$20
        LDA $2306
        else
		STA $4204		;  |
		STZ $4205		;  | Math: DIST*4/5
		LDA #$05		;  |
		STA $4206		;  |
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		LDA $4214		;  |
        endif
		CPY #$00		;  |
		BEQ SETL3YPOS		;  |
		EOR #$FF		;  |
		INC			;  |
SETL3YPOS:	CLC			;  |
		ADC !ORIGINYLO,x		;  |
		STA !LINK3YLO,x		; /

		LDA !TMP1		; \
        if !SA1
        STA $2251
        STZ $2252
        LDA #$01				; \ Set Division Mode.
        STA $2250				; /
        REP #$20
        LDA #$0005
        STA $2253
        NOP     				; \ ... Wait 5 cycles!
        BRA $00 				; /
        SEP #$20
        LDA $2306
        else
		STA $4204		;  |
		STZ $4205		;  | Math: DIST*4/5
		LDA #$05		;  |
		STA $4206		;  |
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		LDA $4214		;  |
        endif
		CPY #$00		;  |
		BEQ SETL4YPOS		;  |
		EOR #$FF		;  |
		INC			;  |
SETL4YPOS:	CLC			;  |
		ADC !ORIGINYLO,x		;  |
		STA !LINK4YLO,x		; /

		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOVELINKS:
BEGINLINK1X:	LDY #$00		; \
		LDA !LINK1XLO,x		;  | check Link 1 X
		SEC			;  | vs. Head X
		SBC !E4,x		;  |
		BPL CHKLINK1X		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
CHKLINK1X:	CMP #!MAX_LINK_X		; /
		BCC BEGINLINK2X		; if in range, skip to next link X
		LDA MAXLINKDISTX,y	; \
		CLC			;  | set position
		ADC !E4,x		;  | to maximum
		STA !LINK1XLO,x		; /

BEGINLINK2X:	LDY #$00		; \
		LDA !LINK2XLO,x		;  | Check Link 2 X
		SEC			;  | vs. Link 1 X
		SBC !LINK1XLO,x		;  |
		BPL CHKLINK2X		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
CHKLINK2X:	CMP #!MAX_LINK_X		; /
		BCC BEGINLINK3X		; if in range, skip to next link X
		LDA MAXLINKDISTX,y	; \
		CLC			;  | set position
		ADC !LINK1XLO,x		;  | to maximum
		STA !LINK2XLO,x		; /

BEGINLINK3X:	LDY #$00		; \
		LDA !LINK3XLO,x		;  | Check Link 3 X
		SEC			;  | vs. Link 2 X
		SBC !LINK2XLO,x		;  |
		BPL CHKLINK3X		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
CHKLINK3X:	CMP #!MAX_LINK_X		; /
		BCC BEGINLINK4X		; if in range, skip to next link X
		LDA MAXLINKDISTX,y	; \
		CLC			;  | set position
		ADC !LINK2XLO,x		;  | to maximum
		STA !LINK3XLO,x		; /

BEGINLINK4X:	LDY #$00		; \
		LDA !LINK4XLO,x		;  | Check Link 4 X
		SEC			;  | vs. Link 3 X
		SBC !LINK3XLO,x		;  |
		BPL CHKLINK4X		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
CHKLINK4X:	CMP #!MAX_LINK_X		; /
		BCC BEGINLINK1Y		; if in range, skip to first link Y
		LDA MAXLINKDISTX,y	; \
		CLC			;  | set position
		ADC !LINK3XLO,x		;  | to maximum
		STA !LINK4XLO,x		; /

BEGINLINK1Y:	LDY #$00		; \
		LDA !LINK1YLO,x		;  | Check Link 1 Y
		SEC			;  | vs. Head Y
		SBC !D8,x		;  |
		BPL CHKLINK1Y		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
CHKLINK1Y:	CMP #!MAX_LINK_Y		; /
		BCC BEGINLINK2Y		; if in range, skip to next link Y
		LDA MAXLINKDISTY,y	; \
		CLC			;  | set position
		ADC !D8,x		;  | to maximum
		STA !LINK1YLO,x		; /

BEGINLINK2Y:	LDY #$00		; \
		LDA !LINK2YLO,x		;  | Check Link 2 Y
		SEC			;  | vs. Link 1 Y
		SBC !LINK1YLO,x		;  |
		BPL CHKLINK2Y		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
CHKLINK2Y:	CMP #!MAX_LINK_Y		; /
		BCC BEGINLINK3Y		; if in range, skip to next link Y
		LDA MAXLINKDISTY,y	; \
		CLC			;  | set position
		ADC !LINK1YLO,x		;  | to maximum
		STA !LINK2YLO,x		; /

BEGINLINK3Y:	LDY #$00		; \
		LDA !LINK3YLO,x		;  | Check Link 3 Y
		SEC			;  | vs. Link 2 Y
		SBC !LINK2YLO,x		;  |
		BPL CHKLINK3Y		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
CHKLINK3Y:	CMP #!MAX_LINK_Y		; /
		BCC BEGINLINK4Y		; if in range, skip to next link Y
		LDA MAXLINKDISTY,y	; \
		CLC			;  | set position
		ADC !LINK2YLO,x		;  | to maximum
		STA !LINK3YLO,x		; /

BEGINLINK4Y:	LDY #$00		; \
		LDA !LINK4YLO,x		;  | Check Link 4 Y
		SEC			;  | vs. Link 3 Y
		SBC !LINK3YLO,x		;  |
		BPL CHKLINK4Y		;  |
		INY			;  |
		EOR #$FF		;  |
		INC			;  |
CHKLINK4Y:	CMP #!MAX_LINK_Y		; /
		BCC ENDCHAINMOVE	; if in range, skip to end
		LDA MAXLINKDISTY,y	; \
		CLC			;  | set position
		ADC !LINK3YLO,x		;  | to maximum
		STA !LINK4YLO,x		; /

ENDCHAINMOVE:	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!GFXwowieTMP1 = $02
		!GFXwowieTMP2 = $03

TILES:		db !OPENMOUTHTILE,!CLOSEDMOUTHTILE

SUB_GFX:		%GetDrawInfo()
		LDA !GFXFLIP,x		; \ set head's
		STA !GFXwowieTMP1		; / X flip
		STZ !GFXwowieTMP2		; default: not dying
		LDA !14C8,x		; \
		CMP #$03		;  | skip next code if not dying
		BCS HEADGFX		; /
		INC !GFXwowieTMP2		; set death mode
		STZ !FRAMECOUNTER,x	; always have open mouth
HEADGFX:	LDA $00			; \ Head X
		STA $0300|!Base2,y		; / position
		LDA $01			; \ Head Y
		STA $0301|!Base2,y		; / position
		LDA !FRAMECOUNTER,x	; \
		LSR			;  | switch tile
		LSR			;  | every 8 frames
		LSR			;  | in sprite's
		AND #%00000001		;  | framecounter
		PHY			;  |
		TAY			;  |
		LDA TILES,y		;  |
		PLY			;  |
		STA $0302|!Base2,y		; /
		LDA !15F6,x		; get sprite palette info
		PHX			; \
		LDX !GFXwowieTMP1		;  | Flip X if
		BEQ NO_FLIP_1		;  | chomp is
		ORA #%01000000		;  | set to
NO_FLIP_1:	;PLX			; /
		;PHX			; \
		LDX !GFXwowieTMP2		;  | Then flip X
		BEQ NO_FLIP_2		;  | and Y if chain
		EOR #%11000000		;  | chomp is dying
NO_FLIP_2:	PLX			; /
		ORA $64                 ; add in priority bits
		STA $0303|!Base2,y             ; set properties
		PHX			; \
		TYA			;  | Set tile
		LSR			;  | as 16x16
		LSR			;  |
		TAX			;  |
		LDA #$02		;  | -> #$02 means 16x16
		STA $0460|!Base2,x		;  |
		PLX			; /
		INY			; \
		INY			;  | Next OAM
		INY			;  | Index
		INY			; /
		LDA !GFXwowieTMP2		; \ If not dying, then
		BEQ CHAINGFX		; / go to chain GFX
		LDY #$FF		; #$FF means the tile sizes were set when the tiles were drawn
		LDA #$00		; This means we drew one tile
		JSL $01B7B3		; don't draw if offscreen
		RTS			; early return
CHAINGFX:	LDA $00			; get X position
		CLC			; \
		ADC !LINK1XLO,x		;  | add Link 1 X position
		SEC			;  | relative to the head
		SBC !E4,x		; /
		CLC			; \ add 4 because
		ADC #$04		; / it's an 8x8
		STA $0300|!Base2,y		; set X position
		LDA $01			; get Y position
		CLC			; \
		ADC !LINK1YLO,x		;  | add Link 2 X position
		SEC			;  | relative to the head
		SBC !D8,x		; /
		CLC			; \ add 4 because
		ADC #$04		; / it's an 8x8
		STA $0301|!Base2,y		; set Y position
		LDA #!CHAINTILE		; \ set
		STA $0302|!Base2,y		; / tile
		LDA !15F6,x		; get sprite palette info
		ORA $64                 ; add in priority bits
		STA $0303|!Base2,y             ; set properties
		PHX			; \
		TYA			;  | Set tile
		LSR			;  | as 8x8
		LSR			;  |
		TAX			;  |
		LDA #$00		;  | -> #$00 means 8x8
		STA $0460|!Base2,x		;  |
		PLX			; /
		INY			; \
		INY			;  | Next OAM
		INY			;  | Index
		INY			; /
		LDA $00			; get X position
		CLC			; \
		ADC !LINK2XLO,x		;  | add Link 1 X position
		SEC			;  | relative to the head
		SBC !E4,x		; /
		CLC			; \ add 4 because
		ADC #$04		; / it's an 8x8
		STA $0300|!Base2,y		; set X position
		LDA $01			; get Y position
		CLC			; \
		ADC !LINK2YLO,x		;  | add Link 2 X position
		SEC			;  | relative to the head
		SBC !D8,x		; /
		CLC			; \ add 4 because
		ADC #$04		; / it's an 8x8
		STA $0301|!Base2,y		; set Y position
		LDA #!CHAINTILE		; \ set
		STA $0302|!Base2,y		; / tile
		LDA !15F6,x		; get sprite palette info
		ORA $64                 ; add in priority bits
		STA $0303|!Base2,y             ; set properties
		PHX			; \
		TYA			;  | Set tile
		LSR			;  | as 8x8
		LSR			;  |
		TAX			;  |
		LDA #$00		;  | -> #$00 means 8x8
		STA $0460|!Base2,x		;  |
		PLX			; /
		INY			; \
		INY			;  | Next OAM
		INY			;  | Index
		INY			; /
		LDA $00			; get X position
		CLC			; \
		ADC !LINK3XLO,x		;  | add Link 1 X position
		SEC			;  | relative to the head
		SBC !E4,x		; /
		CLC			; \ add 4 because
		ADC #$04		; / it's an 8x8
		STA $0300|!Base2,y		; set X position
		LDA $01			; get Y position
		CLC			; \
		ADC !LINK3YLO,x		;  | add Link 2 X position
		SEC			;  | relative to the head
		SBC !D8,x		; /
		CLC			; \ add 4 because
		ADC #$04		; / it's an 8x8
		STA $0301|!Base2,y		; set Y position
		LDA #!CHAINTILE		; \ set
		STA $0302|!Base2,y		; / tile
		LDA !15F6,x		; get sprite palette info
		ORA $64                 ; add in priority bits
		STA $0303|!Base2,y             ; set properties
		PHX			; \
		TYA			;  | Set tile
		LSR			;  | as 8x8
		LSR			;  |
		TAX			;  |
		LDA #$00		;  | -> #$00 means 8x8
		STA $0460|!Base2,x		;  |
		PLX			; /
		INY			; \
		INY			;  | Next OAM
		INY			;  | Index
		INY			; /
		LDA $00			; get X position
		CLC			; \
		ADC !LINK4XLO,x		;  | add Link 1 X position
		SEC			;  | relative to the head
		SBC !E4,x		; /
		CLC			; \ add 4 because
		ADC #$04		; / it's an 8x8
		STA $0300|!Base2,y		; set X position
		LDA $01			; get Y position
		CLC			; \
		ADC !LINK4YLO,x		;  | add Link 2 X position
		SEC			;  | relative to the head
		SBC !D8,x		; /
		CLC			; \ add 4 because
		ADC #$04		; / it's an 8x8
		STA $0301|!Base2,y		; set Y position
		LDA #!CHAINTILE		; \ set
		STA $0302|!Base2,y		; / tile
		LDA !15F6,x		; get sprite palette info
		ORA $64                 ; add in priority bits
		STA $0303|!Base2,y             ; set properties
		PHX			; \
		TYA			;  | Set tile
		LSR			;  | as 8x8
		LSR			;  |
		TAX			;  |
		LDA #$00		;  | -> #$00 means 8x8
		STA $0460|!Base2,x		;  |
		PLX			; /
		LDY #$FF		; #$FF means the tile sizes were set when the tiles were drawn
		LDA #$04		; This means we drew 5 tiles
		JSL $01B7B3		; don't draw if offscreen
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Suborzpoz
; This is a modification of the normal Suborzpoz routine to check the chain chomp origin
; instead of its current position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Suborzpoz:	LDY #$00
		LDA $94
		SEC
		SBC !ORIGINXLO,x
		;STA $0F
		LDA $95
		SBC !ORIGINXHI,x
		BPL .SPR_L16
		INY
.SPR_L16:		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Suborzpoz_H
; This checks the head's position vs. the origin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Suborzpoz_H:	LDY #$00
		LDA !ORIGINXLO,x
		SEC
		SBC !E4,x
		;STA $0F
		LDA !ORIGINXHI,x
		SBC !14E0,x
		BPL .SPR_L16
		INY
.SPR_L16:		RTS

