;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Giant Goomba, by mikeyk
;;
;; Description: A large, squashable enemy.
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(Small config by Rykon-V73)Edit the GFX here:

!GGoomba_part_upper = $8A		;16x16 tile 
!GGoomba_part_lower = $8C		;16x16 tile
!GGoomba_moving_leg = $AB	; 8x8 tile for the leg that moves
!GGoomba_squished_tile1 = $AC	; 8x8 tile for squished tile nr. 1
!GGoomba_squished_tile2 = $AD	; 8x8 tile for squished tile nr. 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; goomba init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
                    print "INIT ",pc
                    PHY
                    %SubHorzPos()
                    TYA
                    STA !157C,x
                    PLY
                    RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; goomba main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR CODE_START          ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; goomba main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:            db $08,$F8 
KILLED_X_SPEED:     db $F0,$10

CODE_START:         JSR SUB_GFX             ; graphics routine
                    LDA !14C8,x             ; \ 
                    CMP #$08                ;  | if status != 8, return
                    BNE RETURN              ; /
					LDA #$00
                    %SubOffScreen()         ; handle off screen situation
                    LDY !157C,x             ; \ set x speed based on direction
                    LDA X_SPEED,y           ;  |
                    STA !B6,x               ; /
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /
                    LDA !1558,x             ; \ if sprite not defeated (timer to show remains > 0)...
                    BEQ ALIVE               ; /    ... goto ALIVE
                    STA !15D0,x             ; \ 
                    DEC                     ;  }   if sprite remains don't disappear next frame...
                    BNE RETURN              ; /    ... return
                    STZ !14C8,x             ; this is the last frame to show remains, so set sprite status = 0 (not alive)
RETURN:             RTS                     ; return                    
ALIVE:              LDA !1588,x             ;A:0100 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZCHC:0276 VC:077 00 FL:623
                    AND #$04                ;A:0100 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZCHC:0308 VC:077 00 FL:623
                    PHA                     ;A:0100 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZCHC:0324 VC:077 00 FL:623
                    JSL $01802A|!BankB      ; update position based on speed values
                    JSL $018032|!BankB      ; interact with other sprites
                    LDA !1588,x             ;A:254B X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0684 VC:085 00 FL:623
                    AND #$04                ;A:2504 X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0716 VC:085 00 FL:623
                    BEQ IN_AIR              ;A:2504 X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0732 VC:085 00 FL:623
                    STZ !AA,x               ;A:2504 X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0748 VC:085 00 FL:623
                    PLA                     ;A:2504 X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0778 VC:085 00 FL:623
                    BRA ON_GROUND           ;A:2500 X:0007 Y:0007 D:0000 DB:03 S:01EF P:envMXdiZcHC:0806 VC:085 00 FL:623
IN_AIR:             PLA                     ;A:2500 X:0007 Y:0006 D:0000 DB:03 S:01EB P:envMXdiZcHC:0316 VC:085 00 FL:4955
                    BEQ WAS_IN_AIR          ;A:2504 X:0007 Y:0006 D:0000 DB:03 S:01EC P:envMXdizcHC:0344 VC:085 00 FL:4955
                    LDA #$0A                ;A:2504 X:0007 Y:0006 D:0000 DB:03 S:01EC P:envMXdizcHC:0360 VC:085 00 FL:4955
                    STA !1540,x             ;A:25FF X:0007 Y:0006 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0376 VC:085 00 FL:4955
WAS_IN_AIR:         LDA !1540,x             ;A:25FF X:0007 Y:0006 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0408 VC:085 00 FL:4955
                    BEQ ON_GROUND           ;A:25FF X:0007 Y:0006 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0440 VC:085 00 FL:4955
                    STZ !AA,x               ;A:25FF X:0007 Y:0006 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0456 VC:085 00 FL:4955
ON_GROUND:          
                    LDA !1588,x             ; \ if sprite is in contact with an object...
                    AND #$03                ; |
                    BEQ DONT_UPDATE         ; |
                    LDA !157C,x             ; | flip the direction status
                    EOR #$01                ; |
                    STA !157C,x             ; /


DONT_UPDATE:        JSL $01A7DC|!BankB      ; check for mario/sprite contact
                    BCC RETURN_24           ; (carry set = contact)
                    LDA $1490|!Base2        ; \ if mario star timer > 0 ...
                    BNE HAS_STAR            ; /    ... goto HAS_STAR
                    LDA $7D                 ; \  if mario's y speed < 10 ...
                    CMP #$10                ;  }   ... sprite will hurt mario
                    BMI GOOB_WINS           ; /                       
                    
MARIO_WINS:         JSR SUB_STOMP_PTS       ; give mario points
                    JSL $01AA33|!BankB      ; set mario speed
                    JSL $01AB99|!BankB      ; display contact graphic
                    LDA $140D|!Base2        ; \  if mario is spin jumping...
                    ORA $187A|!Base2        ;  }    ... or on yoshi ...
                    BNE SPIN_KILL           ; /     ... goto SPIN_KILL
                    LDA #$20                ; \     ... time to show defeated sprite = $20
                    STA !1558,x             ; / 
		    LDA !1686,x		    ; \
		    ORA #$01		    ;  | make it inedible by Yoshi
		    STA !1686,x		    ; /
RETURN_24:          RTS                     ; return 

GOOB_WINS:          LDA $1497|!Base2        ; \ if mario is invincible...
                    ORA $187A|!Base2        ;  }  ... or mario on yoshi...
                    ORA !15D0,x             ; |   ...or sprite being eaten...
                    BNE RETURN2             ; /   ... return
                    %SubHorzPos()           ; \  set new sprite direction
                    TYA                     ;  }  
                    STA !157C,x             ; /
                    JSL $00F5B7|!BankB      ; hurt mario
RETURN2:            RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spin and star kill (still part of above routine)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPIN_KILL:          LDA #$04                ; \ status = 4 (being killed by spin jump)
                    STA !14C8,x             ; /   
                    LDA #$1F                ; \ set spin jump animation timer
                    STA !1540,x             ; /
                    JSL $07FC3B|!BankB      ; show star animation
                    LDA #$08                ; \ play sound effect
                    STA $1DF9|!Base2        ; /
                    RTS                     ; return
HAS_STAR:           %Star()
                    RTS                     ; final return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;frame 1, frame 2, squashed (4 bytes each)
TILE_SIZE:          db $02,$00,$00,$02,$02,$00,$00,$02,$00,$00,$00,$00
HORIZ_DISP:         db $04,$0C,$FC,$FC,$FC,$FC,$0C,$04,$04,$FC,$04,$0C
VERT_DISP:          db $F8,$08,$F8,$00,$F8,$08,$F8,$00,$08,$08,$08,$08
TILEMAP:            db !GGoomba_part_upper,!GGoomba_moving_leg,!GGoomba_part_upper,!GGoomba_part_lower,!GGoomba_part_upper,!GGoomba_moving_leg,!GGoomba_part_upper,!GGoomba_part_lower,!GGoomba_squished_tile2,!GGoomba_squished_tile1,!GGoomba_squished_tile2,!GGoomba_squished_tile1
PROPERTIES:         db $40,$00,$00,$00,$00,$40,$40,$40,$00,$00,$00,$40


SUB_GFX:            %GetDrawInfo()          ;A:87BF X:0007 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZCHC:1102 VC:066 00 FL:665
                    LDA !157C,x             ; \ $02 = direction
                    STA $02                 ; / 
                    
                    LDA $14                 ;\ 
                    LSR #3                  ; |
                    CLC                     ; |
                    ADC $15E9|!Base2        ; |
                    AND #$01                ; |
                    ASL #2                  ; |
                    STA $03                 ; | $03 = index to frame start (0 or 4)
                    PHX                     ; /

                    LDA !14C8,x
                    CMP #$02
                    BNE NO_STAR
                    STZ $03

NO_STAR:            LDA !1558,x             ; \ if time to show sprite remains > 0...
                    BEQ NOT_DEAD            ; |
                    LDA #$08                ; |  $03 = 8
                    STA $03                 ; /
                    STX $15E9|!Base2
NOT_DEAD:
                    
                    LDX #$03                ; run loop 4 times, cuz 4 tiles per frame
LOOP_START_2:       PHX                     ; push, current tile

                    TXA                     ; \ X = index of frame start + current tile
                    CLC                     ;  |
                    ADC $03                 ;  |
                    TAX                     ; /

                    PHY                     ; set tile to be 8x8 or 16x16
                    TYA                     ;
                    LSR #2                  ;
                    TAY                     ;
                    LDA TILE_SIZE,x         ; 
                    STA $0460|!Base2,y      ;
                    PLY                     ;
                    
                    LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
                    CLC                     ; |
                    ADC HORIZ_DISP,x        ; |
                    STA $0300|!Base2,y      ; /
                    
                    LDA $01                 ; |
                    CLC                     ; | tile y position = sprite y location ($01) + tile displacement
                    ADC VERT_DISP,x         ; |
                    STA $0301|!Base2,y      ; /

                    LDA TILEMAP,x           ; \ store tile
                    STA $0302|!Base2,y      ; /

                    PHX                     ;
                    LDX $15E9|!Base2        ;
                    LDA !15F6,x             ; get palette info
                    PLX                     ;
                    ORA PROPERTIES,x          ; flip tile if necessary
                    ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

                    PLX                     ; \ pull, current tile
                    INY                     ; | increase index to sprite tile map ($300)...
                    INY                     ; |    ...we wrote 1 16x16 tile...
                    INY                     ; |    ...sprite OAM is 8x8...
                    INY                     ; |    ...so increment 4 times
                    DEX                     ; | go to next tile of frame and loop
                    BPL LOOP_START_2        ; /

                    PLX                     ; pull, X = sprite index
                    LDY #$FF                ; \ we've already set 460 so use FF
                    LDA #$03                ; | A = number of tiles drawn - 1
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
                    BCS +	            ; /    ... don't play sound from table
                    LDA STAR_SOUNDS,y       ; \ play sound effect
		    BRA ++
+
		    LDA #$02		    ;sound effect for 8+ stomps
++
                    STA $1DF9|!Base2        ; /
          	    TYA                     ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET            ;  |
                    LDA #$08                ; /
NO_RESET:           JSL $02ACE5|!BankB      ; give mario points
                    PLY                     ;
                    RTS                     ; return