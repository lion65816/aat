;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spiny, by Davros (optimized by Blind Devil)
;;
;; Uses first extra bit: YES
;;
;; clear: regular spiny
;; set: faces the player when falling (SMB1 behavior)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra Property Byte 1
;;
;; bit 0: move faster
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:
db $80,$82		;frame 1, frame 2

X_SPEED:
db $08,$F8,$0C,$F4	;right (slow), left (slow), right (fast), left (fast)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite initialization JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
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
            
                    print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR START_SPRITE_CODE   ;  |
                    PLB                     ;  |
                    RTL                     ; /
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite sprite code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START_SPRITE_CODE:  JSR SUB_GFX             ; draw sprite gfx
                    LDA !14C8,x             ; \ if sprite status != 8...
                    CMP #$08                ;  }   ... not (killed with spin jump [4] or star[2])
                    BNE RETURN              ; /    ... return
                    LDA $9D                 ; \ if sprites locked...
                    BNE RETURN              ; /    ... return

		    LDA #$00
		    %SubOffScreen()

                    LDA !1588,x             ; \ if sprite is in contact with an object...
                    AND #$03                ;  |
                    BEQ NO_OBJ_CONTACT      ;  |
                    LDA !157C,x             ;  | flip the direction status
                    EOR #$01                ;  |
                    STA !157C,x             ; /

NO_OBJ_CONTACT:     LDA !1588,x             ; \ if the sprite is in the air...
                    BNE FALLING             ; /

		    LDA !7FAB10,x	    ; \
		    AND #$04		    ;  | if extra bit isn't set, don't face mario when he's near
		    BEQ FALLING		    ; /

		    %SubHorzPos()	    ; horizontal Mario/sprite check routine
		    LDA $0E                 ; \ if Mario is near the sprite...
		    CLC                     ;  |
		    ADC #$40                ;  |
		    CMP #$80                ;  |
		    BCS FALLING             ; / ...return if he isn't near

                    %SubHorzPos()	    ; \ face Mario
                    TYA                     ;  | 
                    STA !157C,x             ; /

FALLING:            LDA !1588,x             ; \ if on the ground now...
                    AND #04                 ;  |
                    BEQ IN_AIR              ; /
                    LDA #$10                ; \ y speed = 10
                    STA !AA,x               ; /
                    
SET_SPEED:          LDY !157C,x             ; set x speed based on direction
                    LDA !7FAB28,x	    ; \ move faster if the extra bit is set
                    AND #$01                ;  |
                    BEQ SET_X_SPEED         ; /
	            INY                     ; \ increase speed values
	            INY                     ; /
SET_X_SPEED:        LDA X_SPEED,y           ; \ set x speed
                    STA !B6,x               ; /

IN_AIR:             JSL $01802A|!BankB      ; update position based on speed values
                    JSL $018032|!BankB      ; interact with other sprites               
                    JSL $01A7DC|!BankB      ; check for Mario/sprite contact

RETURN:             RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:            %GetDrawInfo()          ; sets y = OAM offset
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
                    BNE NotDead

                    STZ $03		    ;reset index

                    LDA !15F6,x		    ; \
                    ORA #$80		    ;  | set Y flip
                    STA !15F6,x		    ; /

NotDead:	    REP #$20
		    LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300|!Base2,y      ; /
		    SEP #$20

                    LDA !15F6,x             ; tile properties yxppccct, format
                    LDX $02                 ; \ if direction == 0...
                    BNE NO_FLIP             ;  |
                    ORA #$40                ; /    ...flip tile
NO_FLIP:            ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

                    LDX $03                 ; \ store tile
                    LDA TILEMAP,x           ;  |
                    STA $0302|!Base2,y      ; /

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$00                ;  | A = (number of tiles drawn - 1)
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return