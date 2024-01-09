;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  
;;	Uses Extra Bit: NO
;;	
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Flaming Baseball uses sprite number right after this

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
		STZ !1504,x

		LDA !7FAB9E,x
		STA $00
		PHX
		LDX #!SprSize-1
CheckAgain:	

		LDA !7FAB9E,x
		CMP $00
		BNE ItsNot

		LDA !7FAB10,x
		AND #$08
		BEQ ItsNot

		LDA !1504,x
		BEQ ItsNot
		LDA !14C8,x
		BEQ ItsNot

		PLX
		STZ !14C8,x
		RTL
		
ItsNot:		
		DEX
		BPL CheckAgain

		PLX

		RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB                     ; \
PHK                     ;  | The same old
PLB                     ; /
LDA !1504,x
BEQ PowerUpCode
JSR MainCode            ;  Jump to sprite code
BRA MainDone

PowerUpCode:
JSR PowerUpBat
MainDone:
PLB                     ; Yep
RTL                     ; Return1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PowerUpBat:
LDA #$01
%SubOffScreen()
JSR SUB_GFX_ITEM

JSL $01802A|!bank

JSL $03B69F|!bank
JSL $03B664|!bank

JSL $03B72B|!bank

BCC NotPower

LDA #$01
STA !1504,x

LDA #$0C
STA $1DF9|!addr

NotPower:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainCode:

LDA $71
CMP #$09
BNE +
STZ !14C8,x
RTS
+

LDA $9D
BEQ HurrayHey

LDA $14A6|!addr
BNE Spinning2
JSR SUB_GFX_BACK
RTS

Spinning2:
JSR SUB_GFX_SWING
RTS

HurrayHey:

LDA $14A6|!addr
BNE Spinning

LDA $16
AND #$40
BNE StartSpinning

LDA $D2
STA !14E0,x
LDA $D1
STA !E4,x
LDA $D4
STA !14D4,x
LDA $D3
STA !D8,x
JSR SUB_GFX_BACK

RTS

StartSpinning:

LDA #$10
STA $14A6|!addr
LDA #$04
STA $1DFC|!addr

Spinning:
LDA.l $005000
LDA $76
AND #$01
BNE BatRight

REP #$30
LDA $D1
SEC
SBC.w #$0020
SEP #$30
STA !E4,x
XBA
STA !14E0,x
BRA BatHit

BatRight:

REP #$30
LDA $D1
CLC
ADC.w #$0010
SEP #$30
STA !E4,x
XBA
STA !14E0,x


BatHit:

REP #$30
LDA $D3
ADC.w #$000C
SEP #$30
STA !D8,x
XBA
STA !14D4,x

JSR SUB_GFX_SWING

JSR HitEnemy
JSR BaseballHit

RTS


;;;;;;;;;;;;;;;;;;;;;;;;;

HitEnemy:

JSL $03B69F|!bank ; get clipping

PHX
LDX #!SprSize-1

XLoop:
LDA !14C8,x
CMP #$08
BCC NoContact
LDA !167A,x
AND #$02
BNE NoContact

JSL $03B6E5|!bank

JSL $03B72B|!bank
BCC NoContact
JSR HitHit

NoContact:
DEX
BPL XLoop
PLX
RTS


HitHit:

LDA !9E,x

CMP #$04
BCC NotAKoopa
CMP #$0C
BCS NotAKoopa
BRA AKoopa

NotAKoopa:
CMP #$0F
BEQ AGoomba
;CMP #$10
;BEQ AWingGoomba

LDA #$02
STA !14C8,x
BRA Launch

;AWingGoomba:

;JSR MakeAGoomba
;BRA Launch

AGoomba:
LDA #$80
STA !1540,x
LDA #$09
STA !14C8,x

;BRA Launch

AKoopa:
LDA #$0A
STA !14C8,x
Launch:

LDA #$08
JSL $02ACEF|!bank
LDA #$25
STA $1DFC|!addr
LDA #$15
STA $1DF9|!addr

LDA $76
BNE GoRight

LDA #$D0
STA !B6,x
BRA GoUp

GoRight:

LDA #$30
STA !B6,x

GoUp:

LDA #$C0
STA !AA,x

JSL $01802A|!bank

DoneBatting:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BaseballHit:
JSL $03B6E5|!bank

PHX
LDX #$09

YLoop:
LDA $170B|!addr,x
CMP #$0D
BEQ FireFireBall
CMP #$05
BNE NoBalls

FireFireBall:
JSR EXTENDED_CLIPPING
JSL $03B72B|!bank
BCC NoBalls
JSR HitTheBall

NoBalls:
DEX
BPL YLoop

PLX
RTS



HitTheBall:

LDA #$25
STA $1DFC|!addr
LDA #$15
STA $1DF9|!addr

STZ $170B|!addr,x
JSR HOME_RUN


RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
; HOME_RUN
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HOME_RUN:

		    JSL $02A9DE|!bank     ; \ get an index to an unused sprite slot, return if all slots full
                    BMI Label0            ; / after: Y has index of sprite being generated

                    LDA #$01                ; \ set sprite status for new sprite
                    STA !14C8,y             ; /


                    PHX
			LDX $15E9|!addr
			LDA !7FAB9E,x
			INC
		    TYX
                    STA !7FAB9E,x
                    PLX

                    LDA $171F|!addr,x	 ; \ set x position for new sprite
                    STA !E4,y

                    LDA $1733|!addr,x       ;  |
                    STA !14E0,y             ; /

                    LDA $1715|!addr,x      ; \ set y position for new sprite
                    STA !D8,y             ;  |
                    LDA $1729|!addr,x       ;  |
                    STA !14D4,y             ; /

                    PHX                     ; \ before: X must have index of sprite being generated
                    TYX                     ;  | routine clears *all* old sprite values...
                    JSL $07F7D2|!bank       ;  | ...and loads in new values for the 6 main sprite tables
                    JSL $0187A7|!bank       ;  get table values for custom sprite
		    LDA #$08
                    STA !7FAB10,x

		LDA $76
		BNE ExtGoRight

		LDA #$C0
		STA !B6,x
		BRA DoneDone2

		ExtGoRight:

		LDA #$40
		STA !B6,x
DoneDone2:
		PLX
	Label0:
		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; EXTENDED_CLIPPING
;
; Routine taken from the disassembly.
; Get extended sprite clipping.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!RAM_ExSpriteNum = $170B|!addr
!RAM_ExSpriteXLo = $171F|!addr
!RAM_ExSpriteXHi = $1733|!addr
!RAM_ExSpriteYLo = $1715|!addr
!RAM_ExSpriteYHi = $1729|!addr

ADDR_02A4E7:			  db $03,$03

DATA_02A4E9:                      db $03,$03,$04,$03,$04,$00,$00,$00
                                  db $04,$03

DATA_02A4F3:                      db $03,$03,$03,$03,$04,$03,$04,$00
                                  db $00,$00,$02,$03

DATA_02A4FF:                      db $03,$03,$01,$01,$08,$01,$08,$00
                                  db $00,$0F,$08,$01

DATA_02A50B:                      db $01,$01,$01,$01,$08,$01,$08,$00
                                  db $00,$0F,$0C,$01,$01,$01

EXTENDED_CLIPPING:
	LDY !RAM_ExSpriteNum,X   
	LDA !RAM_ExSpriteXLo,X   
	CLC                       
	ADC ADDR_02A4E7,Y       
	STA $04                   
	LDA !RAM_ExSpriteXHi,X   
	ADC #$00                
	STA $0A                   
	LDA DATA_02A4FF,Y       
	STA $06                   
	LDA !RAM_ExSpriteYLo,X   
	CLC                       
	ADC DATA_02A4F3,Y       
	STA $05                   
	LDA !RAM_ExSpriteYHi,X   
	ADC #$00                
	STA $0B                   
	LDA DATA_02A50B,Y       
	STA $07                   
	RTS                       ; Return 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERIC GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SUB_GFX_SWING:				       ; after: Y = index to sprite OAM ($6300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  
	%GetDrawInfo()


                   
XC:                 


		    LDA $76
		    AND #$01
		    BEQ BattingRight ; (It's actually to the left)

		    LDA $00                 ; set x position of the tile
		    CLC
		    ADC #$0C
                    STA $0300|!addr,y

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
		    ORA #$40	
                    STA $0303|!addr,y             ; set properties

		    BRA BattingDraw

	BattingRight: ; (actually to the left)
		    LDA $00                 ; set x position of the tile
		    CLC
		    ADC #$04
                    STA $0300|!addr,y
                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
                    STA $0303|!addr,y             ; set properties

	BattingDraw:

                    LDA $01                 ; set y position of the tile
                    STA $0301|!addr,y

                    LDA #$00
                    STA $0302|!addr,y

		    INY
		    INY
		    INY
		    INY

		    LDA $76
		    AND #$01
		    BEQ BattingRight2

		    LDA $00                 ; set x position of the tile
		    SEC
		    SBC #$04
                    STA $0300|!addr,y

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
		    ORA #$40
                    STA $0303|!addr,y             ; set properties

		    BRA BattingDraw2

	BattingRight2:
		    LDA $00                 ; set x position of the tile
		    CLC
           	    ADC #$14
                    STA $0300|!addr,y

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
                    STA $0303|!addr,y             ; set properties

	BattingDraw2:

                    LDA $01                 ; set y position of the tile
                    STA $0301|!addr,y
	
                    LDA #$02
                    STA $0302|!addr,y

                    LDY #$02                ; #$02 means the tiles are 16x16
                    LDA #$01                ; This means we drew one tile
                    JSL $01B7B3|!bank
                    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX_BACK:
		    %GetDrawInfo()

		    LDA $76
		    AND #$01
		    BEQ BattingRight3

		    LDA $00                 ; set x position of the tile
		    CLC
		    ADC #$02
                    STA $0300|!addr,y

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
		    ORA #$40	
                    STA $0303|!addr,y             ; set properties

		    BRA BattingDraw3

	BattingRight3:
		    LDA $00                 ; set x position of the tile
		    SEC
		    SBC #$02
                    STA $0300|!addr,y
                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
                    STA $0303|!addr,y             ; set properties

	BattingDraw3:

                    LDA $01                 ; set y position of the tile
		    CLC
	            ADC #$06
                    STA $0301|!addr,y

                    LDA #$08
                    STA $0302|!addr,y

                    LDY #$02                ; #$02 means the tiles are 16x16
                    LDA #$01                ; This means we drew one tile
                    JSL $01B7B3|!bank

		    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SUB_GFX_ITEM:
		    %GetDrawInfo()

		    LDA $00                 ; set x position of the tile
                    STA $0300|!addr,y

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 
                    STA $0303|!addr,y             ; set properties

                    LDA $01                 ; set y position of the tile
                    STA $0301|!addr,y

                    LDA #$08
                    STA $0302|!addr,y

                    LDY #$02                ; #$02 means the tiles are 16x16
                    LDA #$01                ; This means we drew one tile
                    JSL $01B7B3|!bank

		    RTS
