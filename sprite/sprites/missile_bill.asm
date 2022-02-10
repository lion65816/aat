;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Missile Bill, based on mikeyk's code, further changed by Davros
;; (optimized by Blind Devil).
;;
;; Description: A Bullet Bill that will follow Mario.
;;
;; Uses first extra bit: YES
;; If the first extra bit is set, the bullet will make an unlimited amount of turns. If 
;; it is not set, the bullet will just make a single turn.
;;
;; Extra Property Byte 1:
;; bit 0 - will be a vertical bullet.
;; bit 1 - will be immune to normal stomps (a.k.a "frost")
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    !HBulletTile = $A6
                    !VBulletTile = $A4
                    !SlowdownTime = $18
                    !TimeTilChange = $38

PROPERTIES:         db $02,$08             ; horizontal bullet gfx page/palettes (grey, red)
PROP2:              db $03,$09             ; vertical bullet gfx page/palettes (grey, red)

SPEED_TABLE:        db $20,$E0,$10,$F0     ; speed of sprite, right, left

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
                    PHY                     ; \ face Mario horizontally

		    LDA !7FAB28,x	;load extra property byte 1
		    AND #$01		;check if bit is set
		    BNE IsVertical	;if yes, branch.

                    %SubHorzPos()           ;  |
		    BRA +

IsVertical:
		    %SubVertPos()
+
                    TYA                     ;  |
                    STA !157C,x             ;  |
                    PLY                     ; /
                    STZ !1558,x             ; restore timer
                    RTL
                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR START_SPRITE_CODE   ;  |
                    PLB                     ;  |
                    RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


RETURN:             RTS                     ; return    
START_SPRITE_CODE:  JSR SUB_GFX             ; draw sprite gfx
                    LDA !14C8,x             ; \ if sprite status != 8...
                    CMP #$08                ;  }   
                    BNE RETURN              ; /    ... return
                    LDA $9D                 ; \ if sprites locked...
                    BNE RETURN              ; /    ... return

		    LDA #$03
                    %SubOffScreen()         ; only process sprite while on screen
                    INC !1570,x             ; increment number of frames sprite has been on screen

                    LDA !157C,x             ; \ transfer direction         
                    TAY                     ; /
                    LDA !1558,x             ; \ if the slow down timer is set, 
                    BNE SLOW_DOWN           ; / then slow down the sprite
                    LDA !1540,x             ; \ also slow down the sprite if its about
                    BEQ SET_SPEED           ;  | to change direction.
                    CMP #!SlowdownTime      ;  | ( 0 < timer < !SlowdownTime )
                    BCS SET_SPEED           ; /
SLOW_DOWN:          INY                     ; \ increment index to use slower speeds
                    INY                     ; /

SET_SPEED:
		    LDA !7FAB28,x	;load extra property byte 1
		    AND #$01		;check if bit is set
		    BNE StoreVert	;if yes, branch.

		    LDA SPEED_TABLE,y     ; \ set the x speed
                    STA !B6,x             ; / 
                    STZ !AA,x               ; no y speed
		    BRA +

StoreVert:          LDA SPEED_TABLE,y     ; \ set the y speed
                    STA !AA,x             ; / 
                    STZ !B6,x             ; no x speed

+
                    JSL $01802A|!BankB    ; update position based on speed values
                    LDA !7FAB10,x           ; \ make unlimited turns if the extra bit is set...
                    AND #$04                ;  |
                    BNE DONT_CHECK_TURNS    ; /
                    LDA !C2,x               ; \ skip the check if the missile has already turned
                    BNE CHECK_TIMER         ; / 
DONT_CHECK_TURNS:   LDA !1540,x             ; \ skip the position check if the direction change 
                    BNE CHECK_TIMER         ; / is already scheduled

		    LDA !7FAB28,x	;load extra property byte 1
		    AND #$01		;check if bit is set
		    BNE CheckVertPos	;if yes, branch.

                    %SubHorzPos()           ; \ see if the sprite should change direction
                    TYA                     ;  |  based on Mario's position to it
		    BRA +

CheckVertPos:
                    %SubVertPos()           ; \ see if the sprite should change direction
                    TYA                     ;  |  based on Mario's position to it
+
                    CMP !157C,x             ;  |
                    BEQ CHECK_TIMER         ; /
                    LDA #!TimeTilChange     ; \ set timer until change direction
                    STA !1540,x             ; /

CHECK_TIMER:        LDA !1540,x             ; \ check if its time to change directions
                    CMP #$01                ;  | ($1540 about to expire)
                    BNE CONTACT             ; /
                    LDA !157C,x             ; \ change direction
                    EOR #$01                ;  |
                    STA !157C,x             ; /
                    LDA #!SlowdownTime      ; \ set time to slow down sprite
                    STA !1558,x             ; /
                    INC !C2,x               ; increment turn count

CONTACT:            LDA !7FAB28,x
		    AND #$02
		    BNE Frost

                    JSL $01A7DC|!BankB      ; check for Mario/sprite contact
                    RTS                     ; return 

Frost:              LDA $140D|!Base2        ; \ if Mario is spin jumping...
                    BNE SPIN_JUMP           ; /
                    LDA #$01                ; \ set spin jump flag so mario bounces off flag
                    STA $140D|!Base2        ; /
                    JSL $01A7DC|!BankB      ; check for Mario/sprite contact
                    STZ $140D|!Base2        ; reset spin jump flag
                    RTS                     ; return

SPIN_JUMP:          LDA !1656,x             ; \ 
                    PHA                     ;  |
                    ORA #$10                ;  | allow Mario to kill sprite
                    STA !1656,x             ;  |
                    JSL $01A7DC|!BankB      ;  | check for Mario/sprite contact
                    PLA                     ;  |
                    STA !1656,x             ; /
                    RTS                     ; return 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SUB_GFX:            %GetDrawInfo()

                    LDA !1570,x             ; \ calculate which frame to show
                    LSR                     ;  | based on how long sprite's been alive
                    AND #$01                ;  | 
                    STA $03                 ; /
                  
                    LDA !14C8,x             ; \ if the sprite has been defeated...
                    CMP #$02                ;  |
                    BEQ PUSH_INDEX          ; /

                    LDA !157C,x             ; \ $02 = sprite direction
                    PHY                     ; /
                    LDY $1540,x             ; \ check timer... 
                    BEQ NOT_TURNING         ;  |
                    CPY #!SlowdownTime      ;  | 
                    BCS NOT_TURNING         ;  |
                    EOR #$01                ; / ...in order to flip direction
NOT_TURNING:        PLY                     ; \
                    STA $02                 ; /

PUSH_INDEX:         PHX                     ; push sprite index
                    REP #$20
                    LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300|!Base2,y      ; /
                    SEP #$20

		    LDA !7FAB28,x	;load extra property byte 1
		    AND #$01		;check if bit is set
		    BNE ThisCheckAgain	;if yes, branch.

                    LDA #!HBulletTile        ; \ set tile
                    STA $0302|!Base2,y      ; / 
        
                    LDA $13                 ; \ calculate which frame to show
                    LSR #2                  ;  |
                    PHX                     ;  |
                    AND #$01                ;  | number of palettes
                    TAX                     ;  |
                    LDA PROPERTIES,x        ;  | set flashing palettes
                    PLX                     ; /

                    LDX $02                 ; \
                    BNE NO_FLIP_TILE        ;  |
                    ORA #$40                ;  | put in sprite direction
		    BRA NO_FLIP_TILE

ThisCheckAgain:
                    LDA #!VBulletTile        ; \ set tile
                    STA $0302|!Base2,y      ; / 
        
                    LDA $13                 ; \ calculate which frame to show
                    LSR #2                  ;  |
                    PHX                     ;  |
                    AND #$01                ;  | number of palettes
                    TAX                     ;  |
                    LDA PROP2,x             ;  | set flashing palettes
                    PLX                     ; /

                    LDX $02                 ; \
                    BNE NO_FLIP_TILE        ;  |
                    ORA #$80                ;  | put in sprite direction	

NO_FLIP_TILE:       ORA $64                 ;  | put in level properties
                    STA $0303|!Base2,y      ; / store tile properties
		    PLX

                    LDY #$02                ; \ 02, because 16x16 tiles
                    LDA #$00                ;  | A = number of tiles drawn - 1
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return