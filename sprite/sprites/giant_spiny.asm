;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Giant Spiny, by mikeyk
;;
;; Description: SMW's spiky enemy in bigger size.
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
                    print "INIT ",pc
                    PHY
                    %SubHorzPos()
                    TYA
                    STA !157C,x
                    PLY
                    RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR CODE_START          ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:            db $08,$F8 
KILLED_X_SPEED:     db $F0,$10

CODE_START:         JSR SUB_GFX             ; graphics routine
                    LDA !14C8,x             ; \ 
                    CMP #$08                ;  | if status != 8, return
                    BNE RETURN              ; /
					LDA #$00
                    %SubOffScreen()         ; handle off screen situation

                    LDA $14                 ;\ 
                    LSR #3                  ; |
                    CLC                     ; |
                    ADC $15E9|!Base2        ; | Calculate which frame to show ($1602)
                    AND #$01                ; |
                    ASL #2                  ; |  
                    STA !1602,x             ;/

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
                    LDA !1588,x             ; | if sprite is in contact with an object...
                    AND #$03                ; |
                    BEQ DONT_UPDATE         ; |
                    LDA !157C,x             ; | flip the direction status
                    EOR #$01                ; |
                    STA !157C,x             ; /


DONT_UPDATE:        JSL $01A7DC|!BankB      ; check for mario/sprite contact
                    
RETURN2:            RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:            db $BB,$BC,$EB,$EC,$BB,$BC,$CB,$CC

HORIZ_DISP:         db $04,$FC,$04,$FC,$04,$FC,$04,$FC,$04

VERT_DISP:          db $F8,$F8,$00,$00,$F8,$F8,$00,$00

PROPERTIES:         db $40,$00              ;xyppccct format

SUB_GFX:            %GetDrawInfo()          ; after: Y = index to sprite tile map ($300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  
                   
                    LDA !1602,x
                    STA $03                 ; | $03 = index to frame start (0 or 4)

                    LDA !157C,x             ; \ $02 = sprite direction
                    STA $02                 ; /

	            PHX                     ; push sprite index
                    LDX #$03                ; loop counter = (number of tiles per frame) - 1

LOOP_START:         PHX                     ; push current tile number
                    TXA                     ; \ X = index to horizontal displacement
                    ORA $03                 ; / get index of tile (index to first tile of frame + current tile number)
                    TAX                     ; \ 
                    
		    PHX
                    TXA                     ; \ X = index to horizontal displacement
		    CLC
		    ADC $02
		    TAX
                    LDA $00                 ; \ tile x position = sprite x location ($00)
                    CLC                     ;  |
                    ADC HORIZ_DISP,x        ;  |
                    STA $0300|!Base2,y      ; /
		    PLX

                    LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
                    CLC                     ;  |
                    ADC VERT_DISP,x         ;  |
                    STA $0301|!Base2,y      ; /

                    LDA TILEMAP,x           ; \ store tile
                    STA $0302|!Base2,y      ; / 
        
                    LDX $02                 ; \
                    LDA PROPERTIES,x        ;  | get tile properties using sprite direction
                    LDX $15E9|!Base2        ;  |
                    ORA !15F6,x             ;  | get palette info
                    ORA $64                 ;  | put in level properties
                    STA $0303|!Base2,y      ; / store tile properties

                    PLX                     ; \ pull, X = current tile of the frame we're drawing
                    INY                     ;  | increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ;  |    ...so increment 4 times
                    DEX                     ;  | go to next tile of frame and loop
                    BPL LOOP_START          ; / 

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 02, because we didn't write to 460 yet
                    LDA #$03                ;  | A = number of tiles drawn - 1
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return