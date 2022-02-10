;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SMB3 Lava Lotus, by Davros (optimized by Blind Devil)
;;
;; Description: A lava lotus from SMB3 that will throw volcano lotus fireballs or piranha 
;; fireballs depending on the extra bit.
;;
;; Uses first extra bit: YES
;; If the extra bit is clear, it will spit Volcano Lotus fireballs.
;; If the extra bit is set, it will spit Piranha Plant fireballs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tilemap defines:
!Mouth1 =	$88	;closed mouth, frame 1
!Mouth2 =	$AA	;closed mouth, frame 2
!Mouth3 =	$E6	;open mouth, spawning stuff
!Stem1 =	$A8	;stem frame 1
!Stem2 =	$E2	;stem frame 2
!Stem3 =	$E8	;stem frame 3, spawning stuff

!TimeToShow = $28	;time to display the object before it is thrown
!TimeTillThrow = $E8	;time to throw the extended object

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
                    STZ !1602,x             ; restore image

                    LDA !E4,x               ; \ set x position
                    CLC                     ;  |
                    ADC #$08                ;  |
                    STA !E4,x               ; /
                    DEC !D8,x               ; decrease x position (low byte)
                    LDA !D8,x               ; \
                    CMP #$FF                ;  |
                    BNE NO_DEC_HI_Y         ; /
                    DEC !14D4,x             ; decrease x position (high byte)
NO_DEC_HI_Y:        RTL                     ;

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

SPRITE_CODE_START:  JSR SUB_GFX		    ; graphics routine
                    LDA !14C8,x             ; \ 
                    CMP #$08                ;  | if status != 8, return
                    BNE RETURN              ; /
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /

		    LDA #$03
		    %SubOffScreen()

                    LDA $14                 ; \ make tilemap animated
                    LSR #3                  ;  |
                    CLC                     ;  |
                    ADC $15E9|!Base2        ;  |
                    AND #$01                ;  |
                    STA !1602,x             ; /      

                    LDA !1558,x             ; \ if time until throw < !TimeToShow
                    CMP #!TimeToShow        ;  |
                    BCS NO_THROW            ; / 
                    LDA $14                 ; \ make tilemap animated
                    LSR                     ;  |
                    CLC                     ;  |
                    ADC $15E9|!Base2        ;  |
                    AND #$01                ;  |
                    STA !1602,x  	    ; /
                    INC !1602,x             ; \ change image
                    INC !1602,x             ; /
                       
                    LDA !1558,x             ; \ throw the extended sprite if it's time
                    BNE NO_RESET            ;  |
                    LDA #!TimeTillThrow    ;  | set the timer
                    STA !1558,x		    ; /
NO_RESET:           CMP #$01                ; \ throw extended object if the timer is set
                    BNE NO_THROW            ; / about to tun out

                    JSR SUB_FIRE_THROW      ; Volcano Lotus Fireball routine
                    
NO_THROW:           JSL $018032|!BankB      ; interact with sprites
                    JSL $01802A|!BankB      ; update position based on speed values
                    JSL $01A7DC|!BankB      ; check for Mario/sprite contact (carry set = contact)
RETURN:             RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Volcano Lotus Fireball routine 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPD:
db $10,$F0,$06,$FA
Y_SPD:
db $EC,$E8

SUB_FIRE_THROW:
                    LDA !7FAB10,x	    ; \ throw piranha fireballs if the extra bit is set
                    AND #$04		    ;  |
                    BNE SUB_FIRE_THROW2	    ; /

		LDY #$03		;loop count (number of extended sprites to spawn, minus one)
extsprloop1:
		LDA #$04		;load X displacement
		STA $00			;store to scratch RAM.

		STZ $01			;no Y displacement.

		LDA X_SPD,y		;load X speed from table according to index
		STA $02			;store to scratch RAM.

		PHY			;preserve Y
		TYA			;transfer Y to A
		LSR			;divide by 2
		TAY			;transfer A to Y
		LDA Y_SPD,y		;load Y speed from table according to index
		STA $03			;store to scratch RAM.

		LDA #$0C		;load extended sprite number
		%SpawnExtended()	;call routine to spawn extended sprite.

		PLY			;restore Y
		DEY			;decrement Y by one
		BPL extsprloop1		;loop while value is positive.

		RTS			;return.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Piranha Fireball routine 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XSPD2:
db $12,$EE,$08,$F8
YSPD2:
db $CC,$C8

SUB_FIRE_THROW2:
		LDY #$03		;loop count (number of extended sprites to spawn, minus one)
extsprloop2:
		LDA #$04		;load X displacement
		STA $00			;store to scratch RAM.

		STZ $01			;no Y displacement.

		LDA XSPD2,y		;load X speed from table according to index
		STA $02			;store to scratch RAM.

		PHY			;preserve Y
		TYA			;transfer Y to A
		LSR			;divide by 2
		TAY			;transfer A to Y
		LDA YSPD2,y		;load Y speed from table according to index
		STA $03			;store to scratch RAM.

		LDA #$0B		;load extended sprite number
		%SpawnExtended()	;call routine to spawn extended sprite.

		PLY			;restore Y
		DEY			;decrement Y by one
		BPL extsprloop2		;loop while value is positive.

		RTS			;return.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;frame 1, frame 2 (4 bytes each)
TILEMAP:
db !Mouth1,!Mouth1,!Stem1,!Stem1
db !Mouth2,!Mouth2,!Stem2,!Stem2
db !Mouth3,!Mouth3,!Stem3,!Stem3
db !Mouth3,!Mouth3,!Stem3,!Stem3

HORZ_DISP:          db $FC,$04
VERT_DISP:          db $F0,$F0,$00,$00
PROPERTIES:         db $00,$40


SUB_GFX:            %GetDrawInfo()

                    LDA !1602,x             ; \
                    ASL #2                  ;  | $03 = index to frame start (frame to show * 2 tile per frame)
                    STA $03                 ; /
                    LDA !157C,x             ; \ $02 = sprite direction
                    STA $02                 ; /
                    PHX                     ; push sprite index

                    LDX #$03                ; loop counter = (number of tiles per frame) - 1
LOOP_START:         PHX                     ; push current tile number
                    TXA                     ; \ X = index to horizontal displacement
                    ORA $03                 ; / get index of tile (index to first tile of frame + current tile number)
		    TAX

		    PHX
		    TXA
		    AND #$01
		    TAX
                    LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
                    CLC                     ;  |
                    ADC HORZ_DISP,x         ;  |
                    STA $0300|!Base2,y      ; /
		    PLX

		    PHX
		    TXA
		    AND #$03
		    TAX
                    LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
                    CLC                     ;  | 
                    ADC VERT_DISP,x         ;  |
                    STA $0301|!Base2,y      ; /
		    PLX

                    LDA TILEMAP,x           ; \ store tilemap
                    STA $0302|!Base2,y      ; /

                    PHX                     ;
                    LDX $15E9|!Base2        ;
                    LDA !15F6,x             ; get palette info
                    PLX                     ;

                    PHX                     ;
		    PHA
		    TXA
		    AND #$01
		    TAX
		    PLA
                    ORA PROPERTIES,x        ; flip tile if necessary
                    PLX
                    ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

                    PLX                     ; \ pull, current tile
                    INY                     ;  | increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ;  |    ...so increment 4 times
                    DEX                     ;  | go to next tile of frame and loop
                    BPL LOOP_START          ; /

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$03                ;  | A = number of tiles drawn - 1
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return