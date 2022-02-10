;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rocky Wrench, by Koyuki, based off of mikeyk's Venus Fire Trap
;; (optimized by Blind Devil)
;;
;; Uses first extra bit: YES
;; clear: spawn one wrench
;; set: spawn two wrenches
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Wrench type:
!BigWrench = 0		;if zero, the wrench will be small (Chuck baseball). if non-zero, it'll be big (Dry Bones bone).

;Tilemap defines:
!Aiming = $E2		;body frame 1
!Throwing = $E4		;body frame 2
!Wrench16x16 = $80	;16x16 tile - used if !BigWrench is non-zero
!Wrench8x8 = $AD	;8x8 tile - used if !BigWrench is equal zero

;Wrench page/palette/properties, YXPPCCCT format
!Wrench16Prop = $03	;used if !BigWrench is non-zero
!Wrench8Prop = $09	;used if !BigWrench is equal zero

Y_SPEED:		db $00,$F0,$00,$10     ;rest at bottom, moving up, rest at top, moving down
TIME_IN_POS:		db $20,$68,$20,$48     ;moving up, rest at top, moving down, rest at bottom

X_FIRE_SPEED:		db $12,$EE	;wrench speed (right, left)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; conditionals - don't modify
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if !BigWrench
	XDisp:
	db $FC,$04

	!YDisp = $F6
	!WrenchTile = !Wrench16x16
	!WrenchProp = !Wrench16Prop
	!WrenchSize = $02
	!Projectile = $06		;bone

	SpawnXOffset:
	db $05,$FB

	SpawnYOffset:
	db $FA,$EB
else
	XDisp:
	db $02,$06

	!YDisp = $FD
	!WrenchTile = !Wrench8x8
	!WrenchProp = !Wrench8Prop
	!WrenchSize = $00
	!Projectile = $0D		;baseball

	SpawnXOffset:
	db $09,$FB

	SpawnYOffset:
	db $06,$FB
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; venus fire trap -  initialization JSL
; align sprite to middle of pipe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
                    LDA !D8,x
                    CLC : ADC #$0E		;initial Y displacement
		    STA !D8,x
                    LDA !14D4,x
		    ADC #$00
                    STA !14D4,x
		    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; venus fire trap -  main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR VENUS_CODE_START    ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; venus fire trap main routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VENUS_CODE_START:
		    LDA !1594,x             ;A:8E76 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0918 VC:051 00 FL:24235
                    BNE LABEL24             ;A:8E00 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0950 VC:051 00 FL:24235
                    LDA $64                 ;A:8E00 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0966 VC:051 00 FL:24235
                    PHA                     ;A:8E20 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizcHC:0990 VC:051 00 FL:24235
                    LDA !15D0,x             ;A:8E20 X:0007 Y:0000 D:0000 DB:01 S:01F4 P:envMXdizcHC:1012 VC:051 00 FL:24235
                    BNE LABEL23             ;A:8E00 X:0007 Y:0000 D:0000 DB:01 S:01F4 P:envMXdiZcHC:1044 VC:051 00 FL:24235
                    LDA #$10                ;A:8E00 X:0007 Y:0000 D:0000 DB:01 S:01F4 P:envMXdiZcHC:1060 VC:051 00 FL:24235
                    STA $64                 ;A:8E10 X:0007 Y:0000 D:0000 DB:01 S:01F4 P:envMXdizcHC:1076 VC:051 00 FL:24235

LABEL23:            JSR SUB_GFX
                    PLA                     ;A:003B X:0007 Y:00EC D:0000 DB:01 S:01F4 P:envMXdizcHC:1152 VC:054 00 FL:24235
                    STA $64                 ;A:0020 X:0007 Y:00EC D:0000 DB:01 S:01F5 P:envMXdizcHC:1180 VC:054 00 FL:24235
LABEL24:            LDA #$03
		    %SubOffScreen()	    ; off screen routine
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN27            ; /
                    LDA !1594,x             ;A:0000 X:0007 Y:00EC D:0000 DB:01 S:01F5 P:envMXdiZcHC:0538 VC:055 00 FL:24235
                    BNE LABEL25             ;A:0000 X:0007 Y:00EC D:0000 DB:01 S:01F5 P:envMXdiZcHC:0570 VC:055 00 FL:24235
                    JSL $01803A|!BankB      ; 8FC1 wrapper - A:0000 X:0007 Y:00EC D:0000 DB:01 S:01F5 P:envMXdiZcHC:0586 VC:055 00 FL:24235 calls A40D then A7E4 

LABEL25:            JSR SUB_GET_X_DIFF      ; face mario horizontally
                    JSR SUB_GET_Y_DIFF      ; face mario vertically
                                        
                    LDA !C2,x               ;A:0001 X:0007 Y:0007 D:0000 DB:01 S:01F5 P:envMXdizcHC:1270 VC:056 00 FL:24235
                    AND #$03                ;A:0000 X:0007 Y:0007 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1300 VC:056 00 FL:24235
                    TAY                     ;A:0000 X:0007 Y:0007 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1316 VC:056 00 FL:24235
                    LDA !1540,x             ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1330 VC:056 00 FL:24235
                    BEQ LABEL28             ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1362 VC:056 00 FL:24235
                    PHY                     ; \ call routine to spit fire if out of pipe
                    CPY #$02                ;  |
                    BNE NO_FIRE             ;  |
                    JSR SUB_FIRE_THROW      ;  |
NO_FIRE:            PLY                     ; /
                    LDA Y_SPEED,y           ; \ set y speed
                    STA !AA,x               ; /
                    JSL $01801A|!BankB      ;update Y-pos based on speed - no gravity/object interaction
	            JSL $018032|!BankB	    ; Interact with other sprites
	            JSL $01A7DC|!BankB	    ;Interact with Mario
RETURN27:           RTS                     ;A:00FF X:0007 Y:00FF D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0488 VC:098 00 FL:24268

LABEL28:            LDA !C2,x               ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0016 VC:057 00 FL:24235
                    AND #$03                ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0046 VC:057 00 FL:24235
                    STA $00                 ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0062 VC:057 00 FL:24235
                    BNE LABEL29             ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0086 VC:057 00 FL:24235
                    %SubHorzPos()           ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0102 VC:057 00 FL:24235
                    LDA $0E                 ;A:00FF X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizcHC:0464 VC:057 00 FL:24235
                    CLC                     ;A:00B8 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0488 VC:057 00 FL:24235
                    ADC #$1B                ;A:00B8 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0502 VC:057 00 FL:24235
                    CMP #$37                ;A:00D3 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0518 VC:057 00 FL:24235
                    LDA #$01                ;A:00D3 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:eNvMXdizCHC:0534 VC:057 00 FL:24235
                    STA !1594,x             ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0550 VC:057 00 FL:24235
                    BCC LABEL30             ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0582 VC:057 00 FL:24235
LABEL29:            STZ !1594,x             ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0598 VC:057 00 FL:24235
                    LDY $00                 ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0630 VC:057 00 FL:24235
                    LDA TIME_IN_POS,y       ;A:0001 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZCHC:0654 VC:057 00 FL:24235
                    STA !1540,x             ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0686 VC:057 00 FL:24235
                    INC !C2,x               ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0718 VC:057 00 FL:24235
LABEL30:            RTS                     ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0762 VC:057 00 FL:24235

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:            db !Throwing,!Aiming
PROPERTIES:         db $40,$00

SUB_GFX:            %GetDrawInfo()          ; after: Y = index to sprite tile map ($300)
                                            ;      $00 = sprite x position relative to screen boarder
                                            ;      $01 = sprite y position relative to screen boarder

                    LDA !157C,x             ; \ $02 = sprite direction
                    AND #$01                ;  |
                    STA $02                 ; /

		    STZ $04		    ;this will hold number of tiles drawn

		LDA !15AC,x
		BNE NoWrench		;if timer is non-zero don't display wrench

		LDA !C2,x
		AND #$03
		BEQ NoWrench
		CMP #$03
		BEQ NoWrench

		PHX                     ;push sprite index
		LDA #$01
		STA $05			;body tile index is #$01

		JSR DrawWrench
		INY #4
		JSR DrawBody
		BRA OAMEnd

NoWrench:
		PHX                     ;push sprite index
		STZ $05			;body tile index is zero
		JSR DrawBody

OAMEnd:
                    PLX                     ; pull, X = sprite index
                    LDY #$FF                ; \ we wrote tile sizes manually
                    LDA $04                 ;  | A = number of tiles drawn...
		    DEC A		    ; ...minus one
                    JSL $01B7B3|!BankB      ;/ don't draw if offscreen
                    RTS                     ; return

DrawBody:
		    REP #$20
                    LDA $00
                    STA $0300|!Base2,y
                    SEP #$20

		    LDX $05
		    LDA TILEMAP,x
		    STA $0302|!Base2,y

                    LDX $02                 ; \
                    LDA PROPERTIES,x        ;  | get tile properties using sprite direction
                    LDX $15E9|!Base2        ;  |
                    ORA !15F6,x             ;  | get palette info
                    ORA $64                 ;  | put in level properties
                    STA $0303|!Base2,y      ; / store tile properties

                    TYA                     ; \ get index to sprite property map ($460)...
                    LSR #2                  ;  | we use the sprite OAM index and divide by 4 because of the tile size table
                    TAX                     ;  | 
                    LDA #$02                ;  | #$00 = 8x8, #$02 = 16x16
                    STA $0460|!Base2,x      ; /

		    INC $04		    ;a tile was drawn so increment address
		    RTS

DrawWrench:
		LDX $02
		LDA $00
		CLC
		ADC XDisp,x
		STA $0300|!Base2,y

		LDA $01
		CLC
		ADC #!YDisp
		STA $0301|!Base2,y

		LDA #!WrenchTile
		STA $0302|!Base2,y

		LDA PROPERTIES,x        ; \ get tile properties using sprite direction
		ORA #!WrenchProp	;  | get palette info
		ORA $64                 ;  | put in level properties
		STA $0303|!Base2,y      ; / store tile properties
		
                    TYA                     ; \ get index to sprite property map ($460)...
                    LSR #2                  ;  | we use the sprite OAM index and divide by 4 because of the tile size table
                    TAX                     ;  | 
                    LDA #!WrenchSize        ;  | #$00 = 8x8, #$02 = 16x16
                    STA $0460|!Base2,x      ; /

		INC $04				;a tile was drawn so increment address
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fire spit routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_FIRE_THROW:
                    LDA !7FAB10,x
                    AND #$04
                    BEQ ONE_SHOT

	            LDA !1540,x
                    CMP #$58
                    BEQ SPIT
                    CMP #$10
                    BEQ SPIT
		    BCS +
		    BRA RevPose

ONE_SHOT:           LDA !1540,x
                    CMP #$34
                    BEQ SPIT
		    BCS +
RevPose:
		    LDA #$04
		    STA !15AC,x
+
                    RTS

SPIT:
		    LDA !151C,x
		    TAY
		    LDA SpawnYOffset,y
		    STA $01

		    STZ $03

		    LDA !157C,x
		    AND #$01
		    TAY
		    LDA X_FIRE_SPEED,y
		    STA $02

		    LDA SpawnXOffset,y
		    STA $00

		    LDA #!Projectile
		    %SpawnExtended()

		    LDA #$18
		    STA !15AC,x
		    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; difference in y position
; sets 151C if mario is above plant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GET_Y_DIFF:     LDY #$00                ;A:25A1 X:0007 Y:0001 D:0000 DB:03 S:01EA P:envMXdizCHC:0130 VC:085 00 FL:924
                    LDA $D3                 ;A:25A1 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdiZCHC:0146 VC:085 00 FL:924
                    PHA
                    CLC                     ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0170 VC:085 00 FL:924
                    ADC #$10                ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0184 VC:085 00 FL:924
                    STA $D3                 ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0214 VC:085 00 FL:924
                    LDA $D4                 ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0238 VC:085 00 FL:924
                    PHA
                    ADC #$00                ;A:2501 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizcHC:0262 VC:085 00 FL:924
                    STA $D4                 ;A:2501 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizcHC:0262 VC:085 00 FL:924

                    LDA $D3                 ;A:25A1 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdiZCHC:0146 VC:085 00 FL:924
                    SEC                     ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0170 VC:085 00 FL:924
                    SBC !D8,x               ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0184 VC:085 00 FL:924
                    STA $0E                 ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0214 VC:085 00 FL:924
                    LDA $D4                 ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0238 VC:085 00 FL:924
                    SBC !14D4,x             ;A:2501 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizcHC:0262 VC:085 00 FL:924
                    BPL LABEL14             ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0294 VC:085 00 FL:924
                    INY                     ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0310 VC:085 00 FL:924
LABEL14:            TYA                     ;  | 
                    STA !151C,x 
                    
                    PLA
                    STA $D4
                    PLA
                    STA $D3
                    
                    RTS                     ;A:25FF X:0007 Y:0001 D:0000 DB:03 S:01EA P:envMXdizcHC:0324 VC:085 00 FL:924


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; difference in x position
; sets 157C to 00 through 03 depending on the relative position of mario to the plant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   

SUB_GET_X_DIFF:     LDY #$00                ;A:8505 X:0009 Y:0005 D:0000 DB:01 S:01ED P:envMXdizcHC:0464 VC:058 00 FL:138
                    LDA $D1                 ;A:8505 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0480 VC:058 00 FL:138
                    SEC                     ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0504 VC:058 00 FL:138
                    SBC !E4,x               ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZCHC:0518 VC:058 00 FL:138
                    STA $0E                 ;A:8550 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdizcHC:0548 VC:058 00 FL:138
                    LDA $D2                 ;A:8550 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdizcHC:0572 VC:058 00 FL:138
                    SBC !14E0,x             ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0596 VC:058 00 FL:138
                    BPL TO_RIGHT            ;A:85FF X:0009 Y:0000 D:0000 DB:01 S:01ED P:eNvMXdizcHC:0628 VC:058 00 FL:138
TO_LEFT:            INY                     ;A:85FF X:0009 Y:0000 D:0000 DB:01 S:01ED P:eNvMXdizcHC:0644 VC:058 00 FL:138
                    LDA $0E
                    CMP #$B0
                    BCS SET_VAL
                    INY
                    INY                 
                    BRA SET_VAL
TO_RIGHT:           LDA $0E
                    CMP #$50
                    BCC SET_VAL
                    INY
                    INY 
SET_VAL:            TYA
                    STA !157C,x
                    RTS                     ;A:85FF X:0009 Y:0001 D:0000 DB:01 S:01ED P:envMXdizcHC:0658 VC:058 00 FL:138