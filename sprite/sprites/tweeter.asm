;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tweeter, by mikeyk (optimized by Blind Devil)
;;
;; Description: A Tweeter that bounces while walking.
;;
;; Note: When rideable, clipping tables values should be: 03 0A FE 0E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Uses first extra bit: YES
;; clear: regular Tweeter (16x16)
;; set: giant Tweeter (32x32)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra Property Byte 1
;;    bit 0 - move fast
;;    bit 2 - follow mario
;;    bit 4 - enable spin killing (if rideable)
;;    bit 5 - can be carried (if rideable)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tilemap tables
Tilemap:
db $A4,$A4		;frame 1, frame 2

TilemapGiant:
db $80,$82,$A0,$A2	;top-left, top-right, bottom-left, bottom-right (frame 1)
db $80,$82,$A0,$A2	;top-left, top-right, bottom-left, bottom-right (frame 2)

;Sprite speeds
SpeedX:
db $08,$F8		;right, left (slow)
db $0C,$F4		;right, left (fast)

Y_SPEED:
db $E8,$E8,$E8,$D8		;bounce heights

;Giant sprite clipping
!GiantClipping = $16		;clipping used for giant sprite, when extra bit is set

;Other defines
!CarryableGiant = 0		;if 1, giant Tweeter can be carried. Otherwise, not.
!SpinkillableGiant = 1		;if 1, giant Tweeter can be spinkilled (if behavior is on through extra property 1). Otherwise, not.
!GiantIsFaster = 1		;if 1, giant Tweeter will move at a faster speed (same as its extra prop 1 speed)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
		    LDA !167A,x
		    STA !1528,x

	LDA !7FAB10,x		;load sprite extra bits
	AND #$04		;check if first extra bit is set
	BEQ +			;if not, don't change clipping.

	LDA !1662,x		;load second tweaker byte
	AND #$C0		;preserve properties and clear clipping value
	ORA #!GiantClipping	;add new clipping value
	STA !1662,x		;store result back.
		
+
                    %SubHorzPos()
                    TYA
                    STA !157C,x
                    RTL                 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "MAIN ",pc
        PHB                  
        PHK                  
        PLB
        JSR SpriteMainSub    
        PLB                  
        RTL
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RETURN:
	            RTS

SpriteMainSub:	
		    JSR SUB_GFX             ; graphics routine
                    LDA !14C8,x             ; \ 
                    CMP #$08                ;  | if status != 8, return
                    BNE RETURN              ; /
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /

		    LDA #$00
		    %SubOffScreen()

	INC !1570,x
	
	LDY !157C,x             ; Set x speed based on direction

if !GiantIsFaster
	LDA !7FAB10,x
	AND #$04
	BNE GigaFast
endif

	LDA !7FAB28,x
	AND #$01
	BEQ NoFastSpeed		; Increase speed if bit 0 is set
GigaFast:
	INY #2

NoFastSpeed:
        LDA SpeedX,y           
        STA !B6,x
	
	JSR MaybeFaceMario

	LDA !1528,x
	STA !167A,x
                    LDA !1588,x             ; \ if sprite is in contact with an object...
                    AND #$03                ;  |
                    BEQ NO_OBJ_CONTACT      ;  |
                    LDA !157C,x             ;  | flip the direction status
                    EOR #$01                ;  |
                    STA !157C,x             ; /
NO_OBJ_CONTACT:
                    LDA !1588,x             ; if on the ground, reset the turn counter
                    AND #$04
                    BEQ IN_AIR

                    LDA !151C,x
                    INC A
                    AND #$03
                    STA !151C,x
                    TAY
                    LDA Y_SPEED,y           
                    STA !AA,x               
                    
IN_AIR:             JSL $01802A|!BankB      ; update position based on speed values
 
DONE_WITH_SPEED:    JSL $018032|!BankB      ; interact with sprites
                    JSL $01A7DC|!BankB      ; check for mario/sprite contact (carry set = contact)
                    BCC RETURN              ; return if no contact

                    %SubVertPos()	    ; 
                    LDA $0E                 ; \ if mario isn't above sprite, and there's vertical contact...
                    CMP #$E6                ;  |     ... sprite wins
                    BMI +          ; /
		    JMP SpriteWins		;O.B.
+
                    LDA $7D                 ; \if mario speed is upward, return
                    BMI RETURN              ; /

if !SpinkillableGiant == 0
		LDA !7FAB10,x
		AND #$04
		BNE SPIN_KILL_DISABLED
endif

                    LDA !7FAB28,x
                    AND #$10
                    BEQ SPIN_KILL_DISABLED
                    LDA $140D|!Base2            ; \ if mario is spin jumping, goto SPIN_KILL
                    BEQ SPIN_KILL_DISABLED	; /
		    JMP SpinKill		;O.B.

SPIN_KILL_DISABLED:
	LDA $187A|!Base2
	BNE RideSprite
	LDA !7FAB28,x
	AND #$20
	BEQ RideSprite

if !CarryableGiant == 0
		LDA !7FAB10,x
		AND #$04
		BNE RideSprite
endif

	BIT $16		        ; Don't pick up sprite if not pressing button
        BVC RideSprite
	LDA #$0B		; Sprite status = Carried
	STA !14C8,x
	LDA #$FF		; Set time until recovery
	STA !1540,x
	RTS
	
RideSprite:	
	LDA !7FAB10,x
	AND #$04
	BEQ +

	LDA #$D6
	STA !1534,x
	LDA #$C6
	STA !1FD6,x
	BRA DoneIndexing

+
	LDA #$E1
	STA !1534,x
	LDA #$D1
	STA !1FD6,x

DoneIndexing:
	LDA #$01                ; \ set "on sprite" flag
        STA $1471|!Base2        ; /
        LDA #$06                ; Disable interactions for a few frames
        STA !154C,x             
        STZ $7D                 ; Y speed = 0
        LDA !1534,x             ; \
        LDY $187A|!Base2        ;  | mario's y position += E1 or D1 depending if on yoshi
        BEQ NO_YOSHI            ;  |
        LDA !1FD6,x             ;  |
NO_YOSHI:
	CLC                     ;  |
        ADC !D8,x               ;  |
        STA $96                 ;  |
        LDA !14D4,x             ;  |
        ADC #$FF                ;  |
        STA $97                 ; /
        LDY #$00                ; \ 
        LDA $1491|!Base2        ;  | $1491 == 01 or FF, depending on direction
        BPL LABEL9              ;  | set mario's new x position
        DEY                     ;  |
LABEL9:
	CLC                     ;  |
        ADC $94                 ;  |
        STA $94                 ;  |
        TYA                     ;  |
        ADC $95                 ;  |
        STA $95                 ; /
        RTS                     

SpriteWins:
	LDA !154C,x             ; \ if disable interaction set...
        ORA !15D0,x             ;  |   ...or sprite being eaten...
        BNE Return1             ; /   ...return
        LDA $1490|!Base2        ; Branch if Mario has a star
        BNE MarioHasStar        
        JSL $00F5B7|!BankB	
Return1:
	RTS                    

SpinKill:
	JSR SUB_STOMP_PTS       ; give mario points
	LDA #$F8	        ; Set Mario Y speed
	STA $7D
        JSL $01AB99|!BankB	; display contact graphic
        LDA #$04                ; \ status = 4 (being killed by spin jump)
        STA !14C8,x             ; /   
        LDA #$1F                ; \ set spin jump animation timer
        STA !1540,x             ; /
        JSL $07FC3B|!BankB
        LDA #$08                ; \ play sound effect
        STA $1DF9|!Base2        ; /
        RTS                     ; return

MarioHasStar:
		%Star()
		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:
	%GetDrawInfo()

		    STZ $05		    ;reset scratch RAM. it'll hold Y-flip value if stunned.
		    STZ $06		    ;reset scratch RAM. it'll hold number of tiles drawn.

	LDA !157C,x             ; $02 = direction
        STA $02

        LDA !14C8,x
	STA $04

	CMP #$09
	BCS Stunned
        CMP #$02
	BNE NotKilled

	STZ $03			;set killed frame
        LDA #$80
        STA $05
	BRA DrawSprite

Stunned:
        LDA #$80
        STA $05

NotKilled:
        LDA $14                 ;Set walking frame based on frame counter
        LSR #2
	PHA

	LDA !1540,x
	BEQ slow
	CMP #$40
	BCC +
slow:
	PLA
	LSR
	BRA ++
+
	PLA
++
        CLC
        ADC $15E9|!Base2
        AND #$01
        STA $03

DrawSprite:
		    PHX			    ;preserve sprite index

		LDA !7FAB10,x
		AND #$04
		BNE DrawGiant

		    REP #$20
	            LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300|!Base2,y      ; /
		    SEP #$20

                    LDA !15F6,x             ; tile properties yxppccct, format
                    LDX $02                 ; \ if direction == 0...
                    BNE NO_FLIP             ;  |
                    ORA #$40                ; /    ...flip tile
NO_FLIP:	    ORA $05		    ; add Y flip if stunned
	            ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

                    LDX $03                 ; \ store tile
                    LDA Tilemap,x           ;  |
                    STA $0302|!Base2,y      ; /

		    INC $06		    ;increment RAM, a tile was drawn

FinishOAM:
                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ $0460 = 2 (all 16x16 tiles)
                    LDA $06                 ;  | A = (number of tiles drawn - 1)
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return

XDisp:
db $F8,$08,$F8,$08,$F8		;last value for when X-flipped

YDisp:
db $F1,$F1,$01,$01,$F1,$F1	;last two values for when Y-flipped

DrawGiant:
		    LDA $03
		    ASL #2
		    STA $03		    ;animation index = 0, 4 or 8

		    LDX #$03
GFXLoop:
		    PHX			    ;preserve loop count

		    LDA $02		    ;load sprite direction from scratch RAM
		    BNE FaceLeft	    ;if facing left, don't mess with index.

		    INX			    ;increment X by one, get correct index for table

FaceLeft:
	            LDA $00                 ; \ tile x position = sprite x location ($00)
		    CLC
		    ADC XDisp,x
                    STA $0300|!Base2,y      ; /


		    PLX			    ;restore loop count
		    PHX			    ;and preserve loop count again

		    LDA $04		    ;load sprite status from scratch RAM
		    CMP #$02
		    BEQ Upsidedown
		    CMP #09
		    BCC NotUpsidedown

Upsidedown:
		    INX #2		    ;increment X twice, get correct index for table

NotUpsidedown:
	            LDA $01                 ; \ tile y position = sprite y location ($01)
		    CLC
		    ADC YDisp,x
                    STA $0301|!Base2,y      ; /

		    PLX			    ;restore loop count
		    PHX			    ;and preserve loop count again

		    TXA
		    CLC
                    ADC $03                 ;add animation index to X
		    TAX

                    LDA TilemapGiant,x      ; \ store tile
                    STA $0302|!Base2,y      ; /

		    LDX $15E9|!Base2	    ;get processed sprite index
                    LDA !15F6,x             ; tile properties yxppccct, format
                    LDX $02                 ; \ if direction == 0...
                    BNE NO_FLIP2            ;  |
                    ORA #$40                ; /    ...flip tile
NO_FLIP2:	    ORA $05		    ; add Y flip if stunned
	            ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

		    PLX			    ;restore loop count

		    INC $06		    ;increment RAM, a tile was drawn

		    INY #4
		    DEX
		    BPL GFXLoop
                    BRA FinishOAM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
MaybeFaceMario:
	LDA !7FAB28,x	; Face Mario if bit 2 is set
	AND #$04
	BEQ Return4	
	LDA !1570,x
	AND #$7F
	BNE Return4
	LDA !157C,x
	PHA
	
	%SubHorzPos()         	; Face Mario
        TYA                       
	STA !157C,X
	
	PLA
	CMP !157C,x
	BEQ Return4
	LDA #$08
	STA !15AC,x
Return4:
	RTS                    
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routines below can be shared by all sprites.  they are ripped from original
; SMW and poorly documented
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; points routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STAR_SOUNDS:        db $00,$13,$14,$15,$16,$17,$18,$19

SUB_STOMP_PTS:      PHY                     ; 
                    LDA $1697|!Base2        ; \
                    CLC                     ;  | 
                    ADC !1626,x             ; / some enemies give higher pts/1ups quicker??
                    INC $1697|!Base2        ; increase consecutive enemies stomped
                    TAY                     ;
                    INY                     ;
                    CPY #$08                ; \ if consecutive enemies stomped >= 8 ...
                    BCS NO_SOUND            ; /    ... don't play sound 
                    LDA STAR_SOUNDS,y       ; \ play sound effect
                    STA $1DF9|!Base2        ; /   
NO_SOUND:           TYA                     ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET            ;  |
                    LDA #$08                ; /
NO_RESET:           JSL $02ACE5|!BankB      ; give mario points
                    PLY                     ;
                    RTS                     ; return