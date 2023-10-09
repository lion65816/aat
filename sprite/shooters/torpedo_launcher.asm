;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Torpedo Launcher disassembly, based on 1524's code, modified by Davros, optimized by
;; Blind Devil
;;
;; Description: A disassembly of SMW's sprite CA, which can spawn a configurable sprite.
;;
;; Note that spawned sprites other than Torpedo Teds won't behave properly - you will have
;; to workaround that, or modify sprite codes somehow to include a "being launched" behavior.
;;
;; Extra Bit options:
;; clear: spawn normal sprite
;; set: spawn custom sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Sprite to spawn
!NormSpr = $44
!CustSpr = $A0

;Other defines
!ShowArm = 1		;change this to 0 if you don't want it to display the arm.
!IgnorePlayer = 1	;change this to 0 if you don't want the launcher to spawn sprites when the player is near.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
                    print "INIT ",pc        
                    print "MAIN ",pc
                    PHB                     
                    PHK                     
                    PLB                     
                    JSR SPRITE_CODE_START   
                    PLB                     
                    RTL      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main torpedo ted launcher code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_CODE_START:
		LDA #$50		;if necessary, restore timer to 50

if !IgnorePlayer
		CLC			;clear carry - ignore mario
else
		SEC			;set carry - don't ignore mario
endif
		%ShooterMain()          ; \ check if time to shoot, return if not. (Y now contains new sprite index)
		BCS RETURN              ; /

		    LDA $1783|!Base2,x      ;load shooter extra bits
		    AND #$40                ;check if set
		    BNE SpawnCustom	    ;if set, spawn custom sprite.

                    LDA #$08                ; \ set sprite status for new sprite
                    STA !14C8,y             ; /
                    LDA #!NormSpr	    ; \ set sprite number for new sprite
                    STA !9E,y		    ; /
		    PHX
		    TYX
                    JSL $07F7D2|!BankB
		    PLX
		    BRA +		    ;branch ahead

SpawnCustom:
		    PHX
		    TYX
                    LDA #$01                ; \ set sprite status for new sprite
                    STA !14C8,x             ; /
                    LDA #!CustSpr	    ; \ set sprite number for new sprite
                    STA !7FAB9E,x	    ; /
                    JSL $07F7D2|!BankB	    ;  | ...and loads in new values for the 6 main sprite tables
                    JSL $0187A7|!BankB
                    LDA #$88                ; \ mark as initialized
                    STA !7FAB10,x           ; /
		    PLX

+
                    LDA $179B|!Base2,x      ; \ set x position for new sprite
                    STA !E4,y		    ;  |
                    LDA $17A3|!Base2,x	    ;  |
                    STA !14E0,y		    ; /
                    LDA $178B|!Base2,x	    ; \ set y position for new sprite
                    STA !D8,y		    ;  |
                    LDA $1793|!Base2,x	    ;  |
                    STA !14D4,y             ; /
                    PHX                     ; \ before: X must have index of sprite being generated
                    TYX                     ;  | routine clears *all* old sprite values...

                    %SubHorzPos()	    ;  |
                    TYA                     ;  |
                    STA !157C,x             ;  |

                    LDA #$30                ;  |
                    STA !1540,x             ;  |
                    PLX                     ;  |

if !ShowArm
		    JSR SUB_HAND
endif

RETURN:
		    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display hand for torpedo ted launcher
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if !ShowArm
SUB_HAND:           LDY #$07                ; \ find a free slot to display effect
FINDFREE:           LDA $170B|!Base2,y      ;  |
                    BEQ FOUNDONE            ;  |
                    DEY                     ;  |
                    BPL FINDFREE            ;  |
                    RTS                     ; / return if no slots open

FOUNDONE:           LDA #$08                ; \ set effect graphic to hand graphic
                    STA $170B|!Base2,y      ; /
                    LDA $179B|!Base2,x      ; \
                    CLC                     ;  |
                    ADC #$08                ;  |
                    STA $171F|!Base2,y      ;  |
                    LDA $17A3|!Base2,x      ;  |
                    ADC #$00                ;  |
                    STA $1733|!Base2,y      ;  |
                    LDA $178B|!Base2,x      ;  |
                    SEC                     ;  |
                    SBC #$09                ;  |
                    STA $1715|!Base2,y      ;  |
                    LDA $1793|!Base2,x      ;  |
                    SBC #$00                ;  |
                    STA $1729|!Base2,y      ;  |
                    LDA #$90                ;  |
                    STA $176F|!Base2,y      ;  |
		    LDA #$00		    ;  |
                    STA $1747|!Base2,y      ; /
                    RTS                     ; return
endif