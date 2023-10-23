;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Cookie
;;by RealLink
;;
;;This sprite will roll along the ground, and shatter when Mario jumps on it.
;;It'll hurt mario when he touches its side.
;;It uses a custom palette for palette E.
;;
;;Uses first extra bit: NO
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    PRINT "INIT ",pc
                    %SubHorzPos()
                    TYA
                    STA !157C,x
                    RTL		

	                PRINT "MAIN ",pc	
                    PHB
                    PHK				
                    PLB				
                    JSR SPRITE_ROUTINE	
                    PLB
                    RTL     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPEED_TABLE:
            db $0C,$F4			    ; speeds (right, left)

SPRITE_ROUTINE:
                    JSR SUB_GFX
                    LDA !14C8,x             ; return if sprite status != 8
                    CMP #$08            	 
                    BNE RETURN           
                    LDA $9D			        ; return if sprites locked
                    BNE RETURN    
                    %SubOffScreen()     

                    LDA !1588,x             ; don't set speeds if not on the ground
                    AND #$04                ;
                    BEQ NOT_ON_GND          ; 
                    LDA #$10                ; y speed = 10
                    STA !AA,x               ;
                    LDY !157C,x             ; 
                    LDA SPEED_TABLE,y       ; x speed depends on direction
                    STA !B6,x               ; 
NOT_ON_GND:

                    LDA !1588,x             ; check if sprite is touching object side
                    AND #$03                ; 
                    BEQ DONT_CHANGE_DIR	  ; 
                    LDA !157C,x             ; 
                    EOR #$01                ; flip sprite direction
                    STA !157C,x             ;                     
DONT_CHANGE_DIR:

                    JSL $01802A|!BankB             ; update position based on speed values
                    JSL $018032|!BankB             ; interact with other sprites
                    JSL $01A7DC|!BankB             ; check for mario/sprite contact
                    BCC RETURN              ; (carry set = contact)

Break:
                    STZ !14C8,x 		  ; destroy the sprite

BLOCK_SETUP:
                    LDA !E4,x               ; \ setup block properties
                    STA $9A                 ;  |
                    LDA !14E0,x             ;  |
                    STA $9B                 ;  |
                    LDA !D8,x               ;  |
                    STA $98                 ;  |
                    LDA !14D4,x             ;  |
                    STA $99                 ; /

SHATTER_BLOCK:
                  PHB                     ; \ shatter block routine
		    	  LDA #$02                ;  |
		    	  PHA                     ;  |
		    	  PLB                     ;  |
		    	  LDA #$00                ;  |
		    	  JSL $028663|!BankB             ;  |
		    	  PLB                     ; /

                    RETURN:
                    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:
             db $88,$A0,$88,$A0
PROPERTIES:
             db $00,$00,$C0,$C0

SUB_GFX:
                %GetDrawInfo()       ; sets y = OAM offset
                LDA $14 		;load timer 
		LSR A			;insert some LSRs here for slower flipping 
		LSR A			;each one halves the frequency 
		LSR A
		AND #$03 		;timer modulus 1
                    STA $02                 ; / 
                    LDA $14                 ; \ 
                    LSR A                   ;  |
                    LSR A                   ;  |
                    LSR A                   ;  |
                    CLC                     ;  |
                    ADC $15E9|!addr               ;  |
                    AND #$01                ;  |
                    STA $03                 ;  | $03 = index to frame start (0 or 1)
                    PHX                     ; /
                    
                    LDA !14C8,x
                    CMP #$02
                    BNE LOOP_START_2
                    STZ $03
                    LDA !15F6,x
                    ORA #$80
                    STA !15F6,x

LOOP_START_2:
                    LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300|!addr,y             ; /

                    LDA $01                 ; \ tile y position = sprite y location ($01)
                    STA $0301|!addr,y             ; /


                    LDA !15F6,x             ; tile properties xyppccct, format
                    LDX $02                 ; \ if direction == 0...
                    ;BNE NO_FLIP             ;  |
                    ORA PROPERTIES,x                ; /    ...flip tile
NO_FLIP:
                    ORA $64                 ; add in tile priority of level
                    STA $0303|!addr,y             ; store tile properties

                    LDX $03                 ; \ store tile
                    LDA TILEMAP,x           ;  |
                    STA $0302|!addr,y             ; /

                    INY                     ; \ increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ; /    ...so increment 4 times


                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$00                ;  | A = (number of tiles drawn - 1)
                    JSL $01B7B3|!BankB             ; / don't draw if offscreen
                    RTS                     ; return