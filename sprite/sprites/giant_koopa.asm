;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Giant Koopa, by mikeyk. Updated and modified by RussianMan.
;;
;; Description:
;; It's a giant green + red Koopas from SMB3. Also contains blue + yellow versions. 
;; 
;; All Giant versions acts similar to original koopas e.g. Yellow koopa will moves faste, follows player and etc.
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra Property Byte 1
;;    Bit 0 - Move fast	
;;    Bit 1 - Stay on ledges
;;    Bit 2 - Follow Mario
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!followTimer    =   $7F
    ; How often to poll for Mario's position in Mario-following Koopas.
    ; Valid values are 00, 01, 03, 07, 0F, 1F, 3F, 7F, and FF. Higher is less often.

X_SPEED:	
	db $08,$F8,$0C,$F4	; Right, left, fast right (when extra propert byte 1 bit 1 is set), fast left.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        Print "INIT ",pc
    	JSL $01ACF9|!BankB      ; \ Set random initial animation timer.
    	STA !1570,x         	; /
        %SubHorzPos()		; \ Initially face mario
        TYA			; |
        STA !157C,x		; /
	INC !151C,x		; To prevent Koopas thet stay on ledges from changing their direction twice
        RTL			; INITIALIZATION SUCCEDED. SPRITE SPAWNED.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        Print "MAIN ",pc
        PHB			;
        PHK			;
        PLB			;
	;;         LDA !14C8,x	; We like commenting stuff
	CMP #$07		;
	BEQ InMouth		;
	PHA			; Acts like Buzzy Beetle if not in mouth
	LDA #$11		; Not truth tho, it's still giant koopa.
	STA !9E,x		;
	PLA			;
	CMP #$08		;
	BNE InShell		;
        JSR SUB_GFX1		;
        JSR CODE_START		;
        PLB			;
        RTL			;
	
InMouth:
	LDA !extra_bits,x	;
	AND #$04		;
	BEQ DontGiveShellPower	; If extra bit is set, give powers
;	LDA !extra_prop_2,x	; When on yoshi
;	AND #$02		;
;	STA $141E|!Base2	;
	LDA #$04		; Acts like a Koopa shell if in mouth
	STA !9E,x		;
DontGiveShellPower:		;
	PLB			; Or not. It depends.
        RTL
	
InShell:
	CMP #$04		;
	BEQ DontHandle		;
	CMP #$06		;
	BEQ DontHandle		;
        JSR ShellGfx		; It's a shell.
DontHandle:			;
	PLB			;
        RTL			;
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RETURN:
	RTS			;

CODE_START:
	LDA $9D                 ; \ if sprites locked, return
	BNE RETURN              ; /
	
	%SubOffScreen()		;

	LDA !extra_prop_1,x     ; \Stay on ledges if bit is set
	AND #$02                ; |bit 1 to be specific
	BEQ NO_CHANGE 		; /
	LDA !1588,x             ; run the subroutine if the sprite is in the air...
	ORA !151C,x             ; ...and not already turning
	BNE NO_CHANGE           ;
	JSR SUB_CHANGE_DIR      ;
        LDA #$01                ; set that we're already turning
	STA !151C,x             ;

NO_CHANGE:
	INC !1570,x
	LDA !1588,x             ; if on the ground, reset the turn counter
        AND #$04		;
        BEQ DontFollow		;
        STZ !151C,x		;
        STZ !AA,x		;

OnGround:
	LDA !extra_prop_1,x	; \
	AND #$04		; | Follow Mario if set to
	BEQ DontFollow		; |
    	LDA !1570,X             ; |
    	AND #!followTimer       ; |
    	BNE DontFollow          ; | Follow Mario if set to do so.
    	LDA !157C,x             ; | Don't turn if not time to or already facing Mario.
    	%SubHorzPos()		; | Face Mario
    	TYA			; |
    	STA !157C,X		; /

DontFollow:
        LDY !157C,x             ; \ set x speed based on direction
	LDA !extra_prop_1,x	; | And depending on extra property
	AND #$01		; | First byte set = move faster
	BEQ NotFast		; |
	INY			; |
	INY			; /
NotFast:
        LDA X_SPEED,y           
        STA !B6,x               

        LDA !1588,x		;
        AND #$04		;
        PHA			;
        JSL $01802A|!BankB      ; update position based on speed values
        JSL $018032|!BankB      ; interact with other sprites
        LDA !1588,x		;
        AND #$04		;
        BEQ IN_AIR		;
        STZ !AA,x		;
        PLA			;
        BRA ON_GROUND           ;
IN_AIR:
	PLA			;
        BEQ WAS_IN_AIR		;
        LDA #$0A		;
        STA !1540,x             ; Don't do weird stuff in the air.
WAS_IN_AIR:			;
	LDA !1540,x		;
        BEQ ON_GROUND		;
        STZ !AA,x		;               
ON_GROUND:
        LDA !1588,x             ; \ if sprite is in contact with an object...
        AND #$03                ; |
        BEQ DONT_UPDATE         ; |
        LDA !157C,x             ; | flip the direction status
        EOR #$01                ; |
        STA !157C,x             ; /

DONT_UPDATE:
	JSL $01A7DC|!BankB      ; Interact with Mario
	RTS                     ; return

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_CHANGE_DIR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_CHANGE_DIR:
        LDA !B6,x		;  
        EOR #$FF   		;
        INC A      		;
        STA !B6,x  		;
        LDA !157C,x		;
        EOR #$01   		;
        STA !157C,x		;
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
	ASL A			;
	ASL A			;
        STA $02			;                 

        LDA $14                 ;\ $03 = index to frame start (0 or 4)
        LSR A                   ; |
        LSR A                   ; |
        LSR A                   ; |
        CLC                     ; |
        ADC $15E9|!Base2        ; |
        AND #$01                ; |
        ASL A                   ; |
        ASL A                   ; |
        STA $03                 ;/  

        PHX            		;         

        LDX #$03                ; run loop 4 times, cuz 4 tiles per frame
LOOP_START:
	PHX                     ; \ push, current tile
        LDA $01                 ; |
        CLC                     ; | tile y position = sprite y location ($01) + tile displacement
        ADC VERT_DISP,x         ; |
        STA $0301|!Base2,y      ; /

	PHX			;
        TXA         		;
        CLC         		;
        ADC $03     		;
        TAX         		;
	
        LDA TILEMAP,x           ; \ store tile
        STA $0302|!Base2,y      ; /

	PLA			;
        CLC 			;
	ADC $02			; To not mess up with sprite's tilemap when go other direction, we need to do this.
	TAX			; Add to index (or whatever)
	
        LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
        CLC                     ; |
        ADC HORIZ_DISP,x        ; |
        STA $0300|!Base2,y      ; /
	
        LDX $15E9|!Base2        ;
        LDA !15F6,x             ; get palette info
        ORA $0F
        ORA $64                 ; add in tile priority of level
        STA $0303|!Base2,y      ; store tile properties

        PLX                     ; \ pull, current tile
	INY #4			; |
        DEX                     ; | go to next tile of frame and loop
        BPL LOOP_START		; /

        PLX                     ; pull, X = sprite index

        LDY #$02                ; \ we've already set 460 so use FF
        LDA #$03                ; | A = number of tiles drawn - 1
        JSL $01B7B3|!BankB      ; / don't draw if offscreen
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
	%GetDrawInfo()		;

	STZ $03			;
	LDA !1540,x		;
	CMP #$30		;
	BCS NoShake		;
	AND #$01		;
	STA $03			;
NoShake:	

	STZ $02			;
	LDA !15F6,x		;
	AND #$80		;
	BNE NoVertFlip		;
	LDA #$04		;
	STA $02			;
NoVertFlip:	
	
        PHX     		;                

        LDX #$03                ; run loop 4 times, cuz 4 tiles per frame
LOOP_START2:
	PHX                     ; push, current tile

        LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
        CLC                     ;  |
        ADC HORIZ_DISP2,x       ;  |
	ADC $03                 ;  | Add in shake if necessary
        STA $0300|!Base2,y      ; /

	PHX			;
	TXA			;
	CLC			;
	ADC $02			;
	TAX			;
        LDA $01                 ; \
        CLC                     ;  | tile y position = sprite y location ($01) + tile displacement
        ADC VERT_DISP2,x        ;  |
        STA $0301|!Base2,y      ; /
	PLX
	
        LDA TILEMAP2,x          ; \ store tile
        STA $0302|!Base2,y      ; /

        LDX $15E9|!Base2        ;
        LDA !15F6,x             ; get palette info
        ORA $64                 ; add in tile priority of level
        STA $0303|!Base2,y      ; store tile properties

        PLX                     ; \ pull, current tile
	INY #4
        DEX                     ; | go to next tile of frame and loop
        BPL LOOP_START2

        PLX                     ; pull, X = sprite index
        LDY #$02                ; \ Tiles are 16x16
        LDA #$03                ; | A = number of tiles drawn - 1
        JSL $01B7B3|!BankB      ; / don't draw if offscreen
        RTS                     ; return