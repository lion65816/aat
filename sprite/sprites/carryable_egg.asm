;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Birdo's Egg, by mikeyk (optimized by Blind Devil)
;;
;; Description: The egg Birdo spits.
;: 
;; Note: When rideable, clipping tables values should be: 03 0A FE 0E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Uses first extra bit: NO
;;
;; Extra Property Byte 1
;;    bit 0 - enable spin killing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Tilemap = $8C

X_SPEED:
db $20,$E0		;right, left

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
                    %SubHorzPos()
                    TYA
                    STA !157C,x
                    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "MAIN ",pc
        PHB                     ; \
        PHK                     ;  | main sprite function, just calls local subroutine
        PLB                     ;  |
        JSR SPRITE_CODE_START   ;  |
        PLB                     ;  |
        RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RETURN:             RTS
SPRITE_CODE_START:  JSR SPRITE_GRAPHICS     ; graphics routine
                    LDA !14C8,x             ; \ 
                    CMP #$08                ;  | if status != 8, return
                    BNE RETURN              ; /

		    LDA #$03
		    %SubOffScreen()

                    LDY !157C,x             ; \ set x speed based on direction
                    LDA X_SPEED,y           ;  |
                    STA !B6,x               ; /
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /

                    STZ !AA,x
                    JSL $01802A|!BankB       ; update position based on speed values
         
                    LDA !1588,x             ; \ if sprite is in contact with an object...
                    AND #$03                ;  |
                    BEQ NO_CONTACT          ;  |
                    LDA !157C,x             ;  | flip the direction status
                    EOR #$01                ;  |
                    STA !157C,x             ; /
NO_CONTACT:         
                    JSL $01A7DC|!BankB      ; check for mario/sprite contact (carry set = contact)
                    BCC RETURN              ; return if no contact

                    %SubVertPos()           ; 
                    LDA $0E                 ; \ if mario isn't above sprite, and there's vertical contact...
                    CMP #$E6                ;  |     ... sprite wins
                    BPL SPRITE_WINS         ; /
                    LDA $7D                 ; \if mario speed is upward, return
                    BMI RETURN_24           ; /
                    LDA !7FAB28,x
                    AND #$10
                    BEQ SPIN_KILL_DISABLED  ;
                    LDA $140D|!Base2        ; \ if mario is spin jumping, goto SPIN_KILL
                    BNE SPIN_KILL           ; /
 
SPIN_KILL_DISABLED:
	LDA !1540,x
	BNE RETURN_24B

		LDA $187A|!Base2	; Don't pick up egg if on Yoshi
	        BNE NoCarry
		BIT $16		; Check if X/Y was just pushed
		BVC NoCarry
		LDA #$0B	; Set carried state
		STA !14C8,x
	        LDA !1686,x	; Allow egg to now interact with sprites
                AND #$F7
	        STA !1686,x
		LDA !167A,x	; Use default Mario interaction
		AND #$3F
		STA !167A,x	
		RTS		; We're all done!
NoCarry:
		    LDA #$01                ; \ set "on sprite" flag
                    STA $1471|!Base2        ; /
                    LDA #$06                ; \ set riding sprite
                    STA !154C,x             ; / 
                    STZ $7D                 ; y speed = 0
                    LDA #$E1                ; \
                    LDY $187A|!Base2        ;  | mario's y position += E1 or D1 depending if on yoshi
                    BEQ NO_YOSHI            ;  |
                    LDA #$D1                ;  |
NO_YOSHI:           CLC                     ;  |
                    ADC !D8,x               ;  |
                    STA $96                 ;  |
                    LDA !14D4,x             ;  |
                    ADC #$FF                ;  |
                    STA $97                 ; /
                    LDY #$00                ; \ 
                    LDA $77
                    AND #$03
                    BNE RETURN_24B
                    LDA $1491|!Base2        ;  | $1491 == 01 or FF, depending on direction
                    BPL LABEL9              ;  | set mario's new x position
                    DEY                     ;  |
LABEL9:             CLC                     ;  |
                    ADC $94                 ;  |
                    STA $94                 ;  |
                    TYA                     ;  |
                    ADC $95                 ;  |
                    STA $95                 ; /
RETURN_24B:         RTS                     ;

SPRITE_WINS:        LDA !154C,x             ; \ if riding sprite...
                    ORA !15D0,x             ;  |   ...or sprite being eaten...
                    BNE RETURN_24           ; /   ...return
                    LDA $1490|!Base2        ; \ if mario star timer > 0, goto HAS_STAR 
                    BNE HAS_STAR            ; / NOTE: branch to RETURN_24 to disable star killing                  
                    JSL $00F5B7|!BankB      ; hurt mario
RETURN_24:          RTS                     ; final return

SPIN_KILL:          JSR SUB_STOMP_PTS       ; give mario points
		    LDA #$F8
		    STA $7D
                    JSL $01AB99|!BankB      ; display contact graphic
                    LDA #$04                ; \ status = 4 (being killed by spin jump)
                    STA !14C8,x             ; /   
                    LDA #$1F                ; \ set spin jump animation timer
                    STA !1540,x             ; /
                    JSL $07FC3B|!BankB      ; show star animation
                    LDA #$08                ; \ play sound effect
                    STA $1DF9|!Base2        ; /
                    RTS                     ; return
HAS_STAR:
		    %Star()
		    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_GRAPHICS:    %GetDrawInfo()          ; sets y = OAM offset
                    LDA !157C,x             ; \ $02 = direction
                    STA $02                 ; / 
                    LDA $14                 ; \ 
                    LSR #3                  ;  |
                    CLC                     ;  |
                    ADC $15E9|!Base2        ;  |
                    AND #$01                ;  |
                    STA $03                 ;  | $03 = index to frame start (0 or 1)
                    PHX                     ; /
                    
                    LDA !14C8,x
                    CMP #$02
                    BEQ DoVertFlip
		    CMP #$09
		    BCS DoVertFlip
                    STZ $03
	            BRA LOOP_START_2
DoVertFlip:	
                    LDA !15F6,x
                    ORA #$80
                    STA !15F6,x

LOOP_START_2:
		    REP #$20
		    LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300|!Base2,y      ; /
		    SEP #$20

                    LDA !15F6,x             ; tile properties xyppccct, format
                    LDX $02                 ; \ if direction == 0...
                    BNE NO_FLIP             ;  |
                    ORA #$40                ; /    ...flip tile
NO_FLIP:            ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

                    LDX $03                 ; \ store tile
                    LDA #!Tilemap           ;  |
                    STA $0302|!Base2,y      ; /

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$00                ;  | A = (number of tiles drawn - 1)
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return

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