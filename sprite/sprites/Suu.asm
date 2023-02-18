;suu (SML) by smkdan (optimized by Blind Devil)
;GFX from andy_k_250

;I lifted some of the code from the Rex since it's stomping behaviour can be applied here

!ShouldSquish = 0       ; Set to 0 if you want the sprite to die immediately like a normal SMW sprite.

;Tilemap defines:
TILEMAP:	db $DD,$DE,$ED,$EE	;living frame
		db $E4,$E4,$E4,$E4	;squished

;falling speed
!FallSpd = $20

;climb speed
!ClimbSpd = $10

;drop range
!DropRange = $20

!SquishTime = $40		;time for Suu to stay squished before falling off

;some ram
;1504: 	seperate frame index
;1570:	state
;	00: living and still
;	01: living and dropping
;	02: living and stationary at bottom
;	03: living and climbing back up
;	04: squished
;	05: dieing
;1602:	general timer for above states
;151C:	low byte original Ypos
;1558:	high byte original Ypos

print "INIT ",pc
	LDA !D8,x	;save lowbyte Ypos
	STA !151C,x
	LDA !14D4,x	;save highbyte Ypos
	STA !1558,x
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL

Return_I:
	RTS

Run:
	LDA #$00
	%SubOffScreen()
	JSR GFX			;draw sprite

	LDA !14C8,x
	CMP #$08          	 
	BNE Return_I           
	LDA $9D			;locked sprites?
	BNE Return_I
	LDA !15D0,x		;yoshi eating?
	BNE Return_I

;figure out what to do according to state
	LDA !1570,x		;load state
	BEQ DoLiveStill		;00
	DEC A
	BEQ DoLiveDropping	;01
	DEC A
	BEQ DoLiveClimb		;02
	DEC A
	BEQ DoSquish		;04
	JMP DoDieing		;05

EORTBL:	db $00,$FF

DoLiveStill:
	STZ !1504,x		;normal frame
	%SubHorzPos()		;which side is Mario on?
	LDA $0E
	EOR EORTBL,y		;invert as needed
	CMP #!DropRange		;compare to range
	BCC EnterLiveDropping
	
	JMP Interaction

EnterLiveDropping:
	LDA #$01		;set new status
	STA !1570,x
	JMP Interaction

DoLiveDropping:
	LDA !1588,x		;test ground
	AND #$04
	BNE EnterLiveClimb

	LDA $14			;framecounter
	LSR
	AND #$01
	STA !157C,x		;change direction constantly
	
	STZ !1504,x		;normal frame
	LDA #!FallSpd		;set Yspeed
	STA !AA,x
	JSL $01802A|!BankB	;regular speed update
	
	JMP Interaction

EnterLiveClimb:
	LDA #$02		;set climbing status
	STA !1570,x
	JMP Interaction

DoLiveClimb:
	LDA $14			;frame counter
	LSR #2
	AND #$01
	STA !157C,x		;change direction constantly, at slower rate

	STZ !1504,x		;normal frame
	LDA #!ClimbSpd		;set climbing speed
	EOR #$FF		;two's complement
	INC A
	STA !AA,x
	JSL $01802A|!BankB	;regular speed update

	LDA !D8,x		;now check if relative Ypos is positive/negative compared to the original
	SEC
	SBC !151C,x		;sub low
	XBA
	LDA !14D4,x
	SEC
	SBC !1558,x		;sub high
	XBA
	BMI EnterLiveStill	;if negative, stop climbing
	JMP Interaction

DoSquish:
	LDA #$01	;set squish frame
	STA !1504,x
	LDA !167A,x		;load fourth tweaker byte
	ORA #$02		;set bit to make it immune to cape/fire/bricks
	STA !167A,x		;store result back.
	LDA !166E,x		;load third tweaker byte
	ORA #$20		;set bit to make it not interact to cape spins (immune =/= interactable)
	STA !166E,x		;store result back.
	LDA !1686,x		;load fifth tweaker byte
	ORA #$01		;set bit to make it inedible by Yoshi
	STA !1686,x		;store result back.

    if !ShouldSquish == 1
        LDA !1588,x		;don't touch counter if not on ground
        BIT #$04
        BNE OnGround
        JSL $01802A|!BankB	;regular speed update
        RTS			;no interaction if not on ground
    else
        JMP EnterDieing
    endif

EnterLiveStill:
	STZ !1570,x		;just this will do the task
	JMP Interaction

OnGround:
	DEC !1602,x		;decrement timer
	BEQ EnterDieing
	RTS			;wait until it's time to die

EnterDieing:
	LDA #$FF		;erase sprite permanetley
	STA !161A,x

	LDA #$04		;enter dieing status
	STA !1570,x
	LDA !1686,x		;load 1686 tweaker byte
	ORA #$80		;don't interact wiht objects
	STA !1686,x

	LDA #$E0		;rise a bit with new yspeed
	STA !AA,x
	LDA #$10		;new xspeed
	STA !B6,x

DoDieing:
	JSL $01802A|!BankB	;regular speed update
	RTS			;dieing does nothing at all really

Interaction:
	JSL $01A7DC|!BankB	;mario interact
	BCC NO_CONTACT          ; (carry set = mario/rex contact)
	LDA $1490|!Base2        ; \ if mario star timer > 0 ...
	BNE HAS_STAR            ; /    ... goto HAS_STAR
	LDA !154C,x             ; \ if rex invincibility timer > 0 ...
	BNE NO_CONTACT          ; /    ... goto NO_CONTACT
	LDA $7D                 ; \  if mario's y speed < 10 ...
	CMP #$10                ;  }   ... rex will hurt mario
	BMI REX_WINS            ; /    

MARIO_WINS:
	JSR SUB_STOMP_PTS       ; give mario points
	JSL $01AA33|!BankB      ; set mario speed
	JSL $01AB99|!BankB      ; display contact graphic
	LDA $140D|!Base2        ; \  if mario is spin jumping...
	ORA $187A|!Base2        ;  }    ... or on yoshi ...
	BNE SPIN_KILL           ; /     ... goto SPIN_KILL

;set state to squished
	LDA #$03
	STA !1570,x		;new status
	if !ShouldSquish == 1
        LDA #!SquishTime
        STA !1602,x		;squish time
        RTS                     ; return 
    else
        JMP DoSquish
    endif

REX_WINS:
	LDA $1497|!Base2        ; \ if mario is invincible...
	ORA $187A|!Base2        ;  }  ... or mario on yoshi...
	BNE NO_CONTACT          ; /   ... return
	%SubHorzPos()           ; \  set new rex direction
	TYA                     ;  }  
	STA !157C,x             ; /
	JSL $00F5B7|!BankB      ; hurt mario
	RTS

SPIN_KILL:
	LDA #$04                ; \ rex status = 4 (being killed by spin jump)
	STA !14C8,x             ; /   
	LDA #$1F                ; \ set spin jump animation timer
	STA !1540,x             ; /
	JSL $07FC3B|!BankB      ; show star animation
	LDA #$08                ; \ play sound effect
	STA $1DF9|!Base2        ; /

NO_CONTACT:
	RTS                     ; return

STAR_SOUNDS:        db $00,$13,$14,$15,$16,$17,$18,$19
KILLED_X_SPEED:     db $F0,$10

HAS_STAR:
	%Star()
	RTS                     ; final return

SUB_STOMP_PTS:      PHY                     ; 
                    LDA $1697|!Base2        ; \
                    CLC                     ;  } 
                    ADC !1626,x             ; / some enemies give higher pts/1ups quicker??
                    INC $1697|!Base2        ; increase consecutive enemies stomped
                    TAY                     ;
                    INY                     ;
                    CPY #$08                ; \ if consecutive enemies stomped >= 8 ...
                    BCS NO_SOUND            ; /    ... don't play sound 
                    LDA STAR_SOUNDS,y             ; \ play sound effect
                    STA $1DF9|!Base2        ; /   
NO_SOUND:           TYA                     ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET            ;  |
                    LDA #$08                ; /
NO_RESET:           JSL $02ACE5|!BankB      ; give mario points
                    PLY                     ;
                    RTS                     ; return

;=====

PROP:		db $00,$00,$00,$00
		db $00,$40,$00,$40

XDISP:		db $00,$08,$00,$08
		db $00,$08,$00,$08

YDISP:		db $00,$00,$08,$08
		db $10,$10,$10,$10
	
GFX:
	%GetDrawInfo()
	LDA !157C,x	;$03ection...
	STA $03

	LDA !15F6,x	;properties...
	STA $04

	LDA $03		;test direction
	BNE NoFlip
	LDA #$40
	TSB $04		;set flip bit

NoFlip:
	LDA !1570,x	;test dieing state
	CMP #$04
	BNE NotDieing	;don't yflip if not dieing

	LDA #$80
	TSB $04		;set the v bit

NotDieing:
	LDA !1504,x	;load frame index
	ASL #2		;x4
	STA $09		;and into frame index

	LDX #$00	;reset loop index

OAM_Loop:
	PHX			;preserve loop index
	LDX $09			;load frame index

	LDA $03			;test direction
	BEQ FlipX

	LDA $00
	CLC
	ADC XDISP,x		;xpos
	SEC
	SBC #$04		;compensate
	STA $0300|!Base2,y
	BRA DoY

FlipX:
	LDA $00
	SEC
	SBC XDISP,x		;xpos flip
	CLC
	ADC #$04		;compensate
	STA $0300|!Base2,y

DoY:
	LDA $04			;test flip
	BIT #$80
	BNE FlipY
	
	LDA $01
	CLC
	ADC YDISP,x		;ypos
	BRA DoCHR

FlipY:
	LDA $01			;this is only done when squished
	CLC
	ADC #$10
DoCHR:
	STA $0301|!Base2,y

	LDA TILEMAP,x		;chr
	STA $0302|!Base2,y

	LDA $04			;properties from RAM
	EOR PROP,x		;read properties table
	ORA $64
	STA $0303|!Base2,y

	INY			;next tile
	INY
	INY
	INY

	INC $09		;advance frame index
	PLX		;restore loop index

	INX		;advance loop
	CPX #$04	;4 tiles
	BNE OAM_Loop

	LDX $15E9|!Base2	;restore sprite index
	LDY #$02		;16x16 tiles
        LDA #$03        	;4 tiles
        JSL $01B7B3|!BankB	;reserve
	RTS