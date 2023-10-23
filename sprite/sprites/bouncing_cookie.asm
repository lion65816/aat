;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Bouncing Cookie
;;by RealLink
;;
;;This sprite will bounce along the ground, and shatter when Mario jumps on it.
;;It'll hurt mario when he touches its side.
;;It uses a custom palette for palette E.
;;
;;Uses first extra bit: NO
;;
;;The bouncing code was taken from the bouncing cannonball sprite by Davros.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    PRINT "INIT ",pc
                    %SubHorzPos()        ;face mario initially
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

X_SPEED:
    	db $0C,$F4			    ; speeds (right, left)
Y_SPEED:
             db $C5,$C5,$C5,$C5

SPRITE_ROUTINE:
                    JSR SUB_GFX
                    LDA !14C8,x             ; \ 
                    CMP #$08                ;  | if status != 8, return
                    BNE RETURN              ; /
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /

                    LDA #$03
                    %SubOffScreen()
                    
                    LDA !1588,x             ; \ if sprite is in contact with an object...
                    AND #$03                ;  |
                    BEQ NO_OBJ_CONTACT      ;  |
                    LDA !157C,x             ;  | flip the direction status
                    EOR #$01                ;  |
                    STA !157C,x             ; /
                    LDA !B6,x 
                    EOR #$FF
                    INC A
                    STA !B6,x 
NO_OBJ_CONTACT:
                    LDA !1588,x             ; if on the ground, reset the turn counter
                    AND #$04
                    BEQ IN_AIR

                    LDA !1528,x
                    INC A
                    AND #$03
                    STA !1528,x
                    TAY
                    LDA Y_SPEED,y           
                    STA !AA,x               
                    
                    LDY !157C,x             ; \ set x speed based on direction
                    LDA X_SPEED,y           ;  |
                    STA !B6,x               ; /
                                        
IN_AIR:
                    JSL $01802A|!BankB             ; update position based on speed values
                    JSL $018032|!BankB             ; interact with other sprites
                    JSL $01A7DC|!BankB        ; check for mario/sprite contact
                    BCC RETURN              ; (carry set = contact)

Break:
                    STZ $14C8,x 		  ; destroy the sprite

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
		    	  JSL $028663|!BankB           ;  |
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
		AND #$03 		;
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
                    JSL $01B7B3|!BankB         ; / don't draw if offscreen
                    RTS                     ; return