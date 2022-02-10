;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Giant Para Koopa, by mirumo
;;
;; Description: A giant paratroopa from SMB3. This sprite will turn to a Giant Koopa when stomped
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra Property Byte 1
;;    Bit 0 - Move fast
;;    Bit 1 - Stay on ledges
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!SPRITE_TO_GEN = $2C ;sprite number of giant koopa

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "INIT ", pc
        PHY
        %SubHorzPos()
        TYA
        STA !157C,x
        PLY
        LDA !1588,x
        ORA #$04
        STA !1588,x
        RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "MAIN ", pc
        PHB
        PHK
        PLB
	;;         LDA $14C8,x
	CMP #$07
	BEQ InMouth
	PHA			; Acts like Buzzy Beetle if not in mouth
	LDA #$11
	STA !9E,x
	PLA
	CMP #$08
	BNE InShell
        JSR SUB_GFX1
        JSR CODE_START
        PLB
        RTL

InMouth:
	LDA !7FAB10,x
	AND #04
	BEQ DontGiveShellPower
	LDA !7FAB34,x
	AND #$02
	STA $141E|!Base2
	LDA #$04		; Acts like a Koopa shell if in mouth
	STA !9E,x
DontGiveShellPower:
	PLB
        RTL

InShell:
	CMP #$04
	BEQ DontHandle
	CMP #$06
	BEQ DontHandle
        JSR ShellGfx
DontHandle:
	PLB
        RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:
	db $08,$F8,$0C,$F4
Y_SPEED:             db $B8,$B8,$B8,$B8
KILLED_X_SPEED:      db $F0,$10
RETURN3:
	RTS
CODE_START:            JSR SPRITE_GRAPHICS

	LDA $9D                 ; \ if sprites locked, return
	BNE RETURN3             ; /

	JSR SUB_OFF_SCREEN_X0   ; handle off screen situation

	LDA !7FAB28,x      ; Stay on ledges if bit is set
	AND #$02                ;
	BEQ NO_CHANGE
	LDA !1588,x             ; run the subroutine if the sprite is in the air...
	ORA !151C,x             ; ...and not already turning
	BNE NO_CHANGE           ;
	JSR SUB_CHANGE_DIR      ;
        LDA #$01                ; set that we're already turning
	STA !151C,x             ;

NO_CHANGE:
	LDA !1588,x             ; if on the ground, reset the turn counter
        AND #$04
        BEQ FALLING
        STZ !151C,x
        STZ !AA,x
FALLING:

        LDY !157C,x             ; \ set x speed based on direction
	LDA !7FAB28,x
	AND #$01
	BEQ NotFast
	INY
	INY
NotFast:        LDA X_SPEED,y
                STA !B6,x

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
IN_AIR: JSL $01802A|!BankB             ; update position based on speed values

WAS_IN_AIR:
	LDA !1540,x
        BEQ ON_GROUND
        STZ !AA,x
ON_GROUND:
        LDA !1588,x             ; \ if sprite is in contact with an object...
        AND #$03                ; |
        BEQ DONT_UPDATE         ; |
        LDA !157C,x             ; | flip the direction status
        EOR #$01                ; |
        STA !157C,x             ; /

DONT_UPDATE:
		    JSL $018032|!BankB             ; interact with other sprites
        	    JSL $01A7DC|!BankB             ; check for mario/sprite contact

 		    BCC RETURN1           ; (carry set = contact)
                    LDA $1490|!Base2               ; \ if mario star timer > 0 ...
                    BNE HAS_STAR            ; /    ... goto HAS_STAR
                    LDA $7D                 ; \  if mario's y speed < 10 ...
                    CMP #$10                ;  }   ... sprite will hurt mario
                    BMI GOOB_WINS           ; /

MARIO_WINS:
	            JSR SUB_STOMP_PTS       ; give mario points
	            JSR SUB_SPAWN_SPRITE
                    JSL $01AB99|!BankB
		    LDA $15
       	    	    PHA
       		    ORA #$C0
       		    STA $15
        	    JSL $01AA33|!BankB
		    PLA
		    STA $15
RETURN1:             RTS                     ; return

GOOB_WINS:           LDA $1497|!Base2               ; \ if mario is invincible...
                    ORA $187A|!Base2               ;  }  ... or mario on yoshi...
                    ORA !15D0,x             ; |   ...or sprite being eaten...
                    BNE RETURN2             ; /   ... return
                    %SubHorzPos()         ; \  set new sprite direction
                    TYA                     ;  }
                    STA !157C,x             ; /
                    JSL $00F5B7|!BankB             ; hurt mario
RETURN2:             RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spin and star kill (still part of above routine)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STAR_SOUNDS:         db $00,$13,$14,$15,$16,$17,$18,$19

SPIN_KILL:           LDA #$04                ; \ status = 4 (being killed by spin jump)
                    STA !14C8,x             ; /
                    LDA #$1F                ; \ set spin jump animation timer
                    STA !1540,x             ; /
                    JSL $07FC3B|!BankB             ; show star animation
                    LDA #$08                ; \ play sound effect
                    STA $1DF9|!Base2               ; /
                    RTS                     ; return
HAS_STAR:            LDA #$02                ; \ status = 2 (being killed by star)
                    STA !14C8,x             ; /
                    LDA #$D0                ; \ set y speed
                    STA !AA,x               ; /
                    %SubHorzPos()        ; get new direction
                    LDA KILLED_X_SPEED,y    ; \ set x speed based on direction
                    STA !B6,x               ; /
                    INC $18D2|!Base2               ; increment number consecutive enemies killed
                    LDA $18D2|!Base2               ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET2           ;  |
                    LDA #$08                ;  |
                    STA $18D2|!Base2               ; /
NO_RESET2:           JSL $02ACE5|!BankB             ; give mario points
                    LDY $18D2|!Base2               ; \
                    CPY #$08                ;  | if consecutive enemies stomped < 8 ...
                    BCS NO_SOUND2           ;  |
                    LDA STAR_SOUNDS,y       ;  |    ... play sound effect
                    STA $1DF9|!Base2               ; /
NO_SOUND2:           RTS                     ; final return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; points routine - unknown
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_STOMP_PTS:       PHY                     ;
                    LDA $1697|!Base2               ; \
                    CLC                     ;  }
                    ADC !1626,x             ; / some enemies give higher pts/1ups quicker??
                    INC $1697|!Base2               ; increase consecutive enemies stomped
                    TAY                     ;
                    INY                     ;
                    CPY #$08                ; \ if consecutive enemies stomped >= 8 ...
                    BCS NO_SOUND            ; /    ... don't play sound
                    LDA #$02
                    STA $1DF9|!Base2
NO_SOUND:            TYA                     ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET6            ;  |
                    LDA #$08                ; /
NO_RESET6:           JSL $02ACE5|!BankB             ; give mario points
                    PLY                     ;
                    RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SUB_SPAWN_SPRITE:    JSL $07F78B|!BankB
		    LDA #$08
                    STA !14C8,x
	            LDA #!SPRITE_TO_GEN
                    STA !7FAB9E,x
		    LDA !15F6,x
		    AND #$0E
		    STA $0F
		    LDA #$0B
		    STA !166E,x
		    LDA !15F6,x
		    AND #$F1
		    ORA #$0B
		    STA !15F6,x
		    STZ !AA,x
		    INC !151C,x
RETURN4:             RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_CHANGE_DIR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_CHANGE_DIR:      LDA !B6,x
                    EOR #$FF
                    INC A
                    STA !B6,x
                    LDA !157C,x
                    EOR #$01
                    STA !157C,x
                    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VERT_DISP:
	db $F0,$F0,$00,$00
TILEMAP:
	db $23,$24,$43,$44
	db $26,$24,$46,$47
HORIZ_DISP:
	db $04,$FC,$04,$FC
	db $FC,$04,$FC,$04
PROPERTIES:
	db $40,$00

SUB_GFX1:
	%GetDrawInfo()
	TYA
	STA !1504,x

	PHX
	LDA !157C,x
	TAX
	LDA PROPERTIES,x
	STA $0F
	PLX

        LDA !157C,x             ; $02 = direction * 4
	ASL #2
        STA $02

        LDA $14                 ;\ $03 = index to frame start (0 or 4)
        LSR #3
        CLC                     ; |
        ADC $15E9|!Base2               ; |
        AND #$01                ; |
        ASL #2
        STA $03                 ;/

        PHX

        LDX #$04                ; run loop 4 times, cuz 4 tiles per frame
LOOP_START:
	PHX                     ; push, current tile

        LDA $01                 ; |
        CLC                     ; | tile y position = sprite y location ($01) + tile displacement
        ADC VERT_DISP,x         ; |
        STA $0301|!Base2,y             ; /

	PHX
        TXA
        CLC
        ADC $03
        TAX

        LDA TILEMAP,x           ; \ store tile
        STA $0302|!Base2,y             ; /

	PLA
        CLC
	ADC $02
	TAX

        LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
        CLC                     ; |
        ADC HORIZ_DISP,x        ; |
        STA $0300|!Base2,y             ; /

        LDX $15E9|!Base2               ;
        LDA !15F6,x             ; get palette info
        ORA $0F
        ORA $64                 ; add in tile priority of level
        STA $0303|!Base2,y             ; store tile properties

        PLX                     ; \ pull, current tile
        INY                     ; | increase index to sprite tile map ($300)...
        INY                     ; |    ...we wrote 1 16x16 tile...
        INY                     ; |    ...sprite OAM is 8x8...
        INY                     ; |    ...so increment 4 times
        DEX                     ; | go to next tile of frame and loop
        BPL LOOP_START

        PLX                     ; pull, X = sprite index

        LDY #$02               ; \ we've already set 460 so use FF
        LDA #$04                ; | A = number of tiles drawn - 1
        JSL $01B7B3|!BankB             ; / don't draw if offscreen
        RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VERT_DISP3:
	db $F5,$F5
TILEMAP3:
	db $06,$0A,$06,$0A
	db $0A,$06,$0A,$06
HORIZ_DISP3:
	db $F6,$0C,$F6,$0A
	db $0A,$F6,$0A,$F6
PROPERTIES3:
	db $40,$00

SPRITE_GRAPHICS:
	%GetDrawInfo()
	TYA
	STA !1504,x

	PHX
	LDA !157C,x
	TAX
	LDA PROPERTIES3,x
	STA $0F
	PLX

        LDA !157C,x             ; $02 = direction * 4
	ASL #2
        STA $02

        LDA $14                 ;\ $03 = index to frame start (0 or 4)
        LSR #3
        CLC                     ; |
        ADC $15E9|!Base2               ; |
        AND #$01                ; |
        ASL #2
        STA $03                 ;/

        PHX

        LDX #$00                ; run loop 4 times, cuz 4 tiles per frame
LOOP_START3:
	PHX                     ; push, current tile

        LDA $01                 ; |
        CLC                     ; | tile y position = sprite y location ($01) + tile displacement
        ADC VERT_DISP3,x         ; |
        STA $0301|!Base2,y             ; /

	PHX
        TXA
        CLC
        ADC $03
        TAX

        LDA TILEMAP3,x           ; \ store tile
        STA $0302|!Base2,y             ; /

	PLA
        CLC
	ADC $02
	TAX

        LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
        CLC                     ; |
        ADC HORIZ_DISP3,x        ; |
        STA $0300|!Base2,y             ; /


        LDX $15E9|!Base2               ;
        LDA #$03             ; get palette info
        ORA $0F
        ORA $64                 ; add in tile priority of level
        STA $0303|!Base2,y             ; store tile properties

        PLX                     ; \ pull, current tile
        INY                     ; | increase index to sprite tile map ($300)...
        INY                     ; |    ...we wrote 1 16x16 tile...
        INY                     ; |    ...sprite OAM is 8x8...
        INY                     ; |    ...so increment 4 times
        DEX                     ; | go to next tile of frame and loop
        BPL LOOP_START3

        PLX                     ; pull, X = sprite index

        LDY #$02               ; \ we've already set 460 so use FF
        LDA #$04                ; | A = number of tiles drawn - 1
        JSL $01B7B3|!BankB             ; / don't draw if offscreen
        RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shell graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HORIZ_DISP2:
	db $FC,$05,$FC,$05
VERT_DISP2:
	db $02,$02,$FA,$FA
        db $F8,$F8,$00,$00
TILEMAP2:
	db $30,$31,$40,$41

ShellGfx:
	%GetDrawInfo()

	STZ $03
	LDA !1540,x
	CMP #$30
	BCS NoShake
	AND #$01
	STA $03
NoShake:

	STZ $02
	LDA !15F6,x
	AND #$80
	BNE NoVertFlip
	LDA #$04
	STA $02
NoVertFlip:

        PHX

        LDX #$03                ; run loop 4 times, cuz 4 tiles per frame
LOOP_START2:
	PHX                     ; push, current tile

        LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
        CLC                     ;  |
        ADC HORIZ_DISP2,x       ;  |
	ADC $03                 ;  | Add in shake if necessary
        STA $0300|!Base2,y             ; /

	PHX
	TXA
	CLC
	ADC $02
	TAX
        LDA $01                 ; \
        CLC                     ;  | tile y position = sprite y location ($01) + tile displacement
        ADC VERT_DISP2,x        ;  |
        STA $0301|!Base2,y             ; /
	PLX

        LDA TILEMAP2,x          ; \ store tile
        STA $0302|!Base2,y             ; /

        LDX $15E9|!Base2               ;
        LDA !15F6,x             ; get palette info
        ORA $64                 ; add in tile priority of level
        STA $0303|!Base2,y             ; store tile properties

        PLX                     ; \ pull, current tile
        INY                     ; | increase index to sprite tile map ($300)...
        INY                     ; |    ...we wrote 4 bytes...
        INY                     ; |    ...so increment 4 times
        INY                     ; |
        DEX                     ; | go to next tile of frame and loop
        BPL LOOP_START2

        PLX                     ; pull, X = sprite index
        LDY #$02                ; \ Tiles are 16x16
        LDA #$03                ; | A = number of tiles drawn - 1
        JSL $01B7B3|!BankB             ; / don't draw if offscreen
        RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $B85D - off screen processing code - shared
; sprites enter at different points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $03B83B

TABLE3:              db $40,$B0
TABLE6:              db $01,$FF
TABLE4:              db $30,$C0,$A0,$80,$A0,$40,$60,$B0
TABLE5:              db $01,$FF,$01,$FF,$01,$00,$01,$FF

SUB_OFF_SCREEN_X0:   LDA #$06                ; \ entry point of routine determines value of $03
STORE_03:            STA $03                 ;  |
                    BRA START_SUB           ;  |
SUB_OFF_SCREEN_HB:   STZ $03                 ; /

START_SUB:           JSR SUB_IS_OFF_SCREEN   ; \ if sprite is not off screen, return
                    BEQ RETURN_2            ; /
                    LDA $5B                 ; \  goto VERTICAL_LEVEL if vertical level
                    AND #$01                ;  |
                    BNE VERTICAL_LEVEL      ; /
                    LDA !D8,x               ; \
                    CLC                     ;  |
                    ADC #$50                ;  | if the sprite has gone off the bottom of the level...
                    LDA !14D4,x             ;  | (if adding 0x50 to the sprite y position would make the high byte >= 2)
                    ADC #$00                ;  |
                    CMP #$02                ;  |
                    BPL ERASE_SPRITE        ; /    ...erase the sprite
                    LDA !167A,x             ; \ if "process offscreen" flag is set, return
                    AND #$04                ;  |
                    BNE RETURN_2            ; /
                    LDA $13                 ; \
                    AND #$01                ;  |
                    ORA $03                 ;  |
                    STA $01                 ;  |
                    TAY                     ; /
                    LDA $1A                 ;x boundry ;A:0101 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0256 VC:090 00 FL:16953
                    CLC                     ;A:0100 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0280 VC:090 00 FL:16953
                    ADC TABLE4,y            ;A:0100 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0294 VC:090 00 FL:16953
                    ROL $00                 ;A:01C0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0326 VC:090 00 FL:16953
                    CMP !E4,x               ;x pos ;A:01C0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0364 VC:090 00 FL:16953
                    PHP                     ;A:01C0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0394 VC:090 00 FL:16953
                    LDA $1B                 ;x boundry hi ;A:01C0 X:0006 Y:0001 D:0000 DB:03 S:01EC P:eNvMXdizCHC:0416 VC:090 00 FL:16953
                    LSR $00                 ;A:0100 X:0006 Y:0001 D:0000 DB:03 S:01EC P:envMXdiZCHC:0440 VC:090 00 FL:16953
                    ADC TABLE5,y            ;A:0100 X:0006 Y:0001 D:0000 DB:03 S:01EC P:envMXdizcHC:0478 VC:090 00 FL:16953
                    PLP                     ;A:01FF X:0006 Y:0001 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0510 VC:090 00 FL:16953
                    SBC !14E0,x             ;x pos high ;A:01FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0538 VC:090 00 FL:16953
                    STA $00                 ;A:01FE X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0570 VC:090 00 FL:16953
                    LSR $01                 ;A:01FE X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0594 VC:090 00 FL:16953
                    BCC LABEL20             ;A:01FE X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZCHC:0632 VC:090 00 FL:16953
                    EOR #$80                ;A:01FE X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZCHC:0648 VC:090 00 FL:16953
                    STA $00                 ;A:017E X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0664 VC:090 00 FL:16953
LABEL20:             LDA $00                 ;A:017E X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0688 VC:090 00 FL:16953
                    BPL RETURN_2            ;A:017E X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0712 VC:090 00 FL:16953
ERASE_SPRITE:        LDA !14C8,x             ; \ if sprite status < 8, permanently erase sprite
                    CMP #$08                ;  |
                    BCC KILL_SPRITE         ; /
                    LDY !161A,x             ;A:FF08 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZCHC:0140 VC:071 00 FL:21152
                    CPY #$FF                ;A:FF08 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0172 VC:071 00 FL:21152
                    BEQ KILL_SPRITE         ;A:FF08 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0188 VC:071 00 FL:21152
                    LDA #$00                ; \ mark sprite to come back    A:FF08 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0204 VC:071 00 FL:21152
                    PHX
                    TYX
                    STA !1938,x             ; /                             A:FF00 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0220 VC:071 00 FL:21152
                    PLX
KILL_SPRITE:         STZ !14C8,x             ; erase sprite
RETURN_2:            RTS                     ; return

VERTICAL_LEVEL:      LDA !167A,x             ; \ if "process offscreen" flag is set, return
                    AND #$04                ;  |
                    BNE RETURN_2            ; /
                    LDA $13                 ; \ only handle every other frame??
                    LSR A                   ;  |
                    BCS RETURN_2            ; /
                    AND #$01                ;A:0227 X:0006 Y:00EC D:0000 DB:03 S:01ED P:envMXdizcHC:0228 VC:112 00 FL:1142
                    STA $01                 ;A:0201 X:0006 Y:00EC D:0000 DB:03 S:01ED P:envMXdizcHC:0244 VC:112 00 FL:1142
                    TAY                     ;A:0201 X:0006 Y:00EC D:0000 DB:03 S:01ED P:envMXdizcHC:0268 VC:112 00 FL:1142
                    LDA $1C                 ;A:0201 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0282 VC:112 00 FL:1142
                    CLC                     ;A:02BD X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0306 VC:112 00 FL:1142
                    ADC TABLE3,y            ;A:02BD X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0320 VC:112 00 FL:1142
                    ROL $00                 ;A:026D X:0006 Y:0001 D:0000 DB:03 S:01ED P:enVMXdizCHC:0352 VC:112 00 FL:1142
                    CMP !D8,x               ;A:026D X:0006 Y:0001 D:0000 DB:03 S:01ED P:enVMXdizCHC:0390 VC:112 00 FL:1142
                    PHP                     ;A:026D X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNVMXdizcHC:0420 VC:112 00 FL:1142
                    LDA $1D             ;A:026D X:0006 Y:0001 D:0000 DB:03 S:01EC P:eNVMXdizcHC:0442 VC:112 00 FL:1142
                    LSR $00                 ;A:0200 X:0006 Y:0001 D:0000 DB:03 S:01EC P:enVMXdiZcHC:0474 VC:112 00 FL:1142
                    ADC TABLE6,y            ;A:0200 X:0006 Y:0001 D:0000 DB:03 S:01EC P:enVMXdizCHC:0512 VC:112 00 FL:1142
                    PLP                     ;A:0200 X:0006 Y:0001 D:0000 DB:03 S:01EC P:envMXdiZCHC:0544 VC:112 00 FL:1142
                    SBC !14D4,x             ;A:0200 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNVMXdizcHC:0572 VC:112 00 FL:1142
                    STA $00                 ;A:02FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0604 VC:112 00 FL:1142
                    LDY $01                 ;A:02FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0628 VC:112 00 FL:1142
                    BEQ LABEL22             ;A:02FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0652 VC:112 00 FL:1142
                    EOR #$80                ;A:02FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0668 VC:112 00 FL:1142
                    STA $00                 ;A:027F X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0684 VC:112 00 FL:1142
LABEL22:             LDA $00                 ;A:027F X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0708 VC:112 00 FL:1142
                    BPL RETURN_2            ;A:027F X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0732 VC:112 00 FL:1142
                    BMI ERASE_SPRITE        ;A:0280 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0170 VC:064 00 FL:1195

SUB_IS_OFF_SCREEN:   LDA !15A0,x             ; \ if sprite is on screen, accumulator = 0
                    ORA !186C,x             ;  |
                    RTS                     ; / return

NOP