;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Big Boo Boss, adapted by Davros (optimized by RussianMan and Blind Devil)
;;
;; Description: A Big Boo Boss from SMW.
;;
;; Uses first extra bit: YES
;; If the extra bit is set, it will set the secret exit. Otherwise it will end the level 
;; normally.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    !HIT_POINTS = $03        ; Big Boo Boss hit points

                    !TILE1 = $001F           ; Small door (or upper door part)
                    !TILE2 = $0020           ; Door Part tile
                    !TILE3 = $0130           ; Cement block tile

		    !Music = $05	     ; Music that plays after defeating boss. (AAT edit)

		    !BossHurts = 0	     ;0 = boss doesn't hurt. 1 = boss hurts when not stunned. 2 = boss always hurts.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    Print "INIT ",pc
                    PHY
                    %SubHorzPos()
                    TYA
                    STA !157C,x
                    PLY
                    RTL                 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    Print "MAIN ",pc                                    
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR SPRITE_CODE_START   ;  |
                    PLB                     ;  |
                    RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


X_SPEED:		    db $F0,$10
ACCEL_X:		    db $FF,$01

Y_SPEED:		    db $0C,$F4
ACCEL_Y:		    db $01,$FF

IMAGE_TABLE:	    	    db $01,$02,$01,$02


SPRITE_CODE_START:  JSR SUB_GFX             ; Big Boo Boss graphics routine
		    JSR SUB_TRANS_PALETTE   ; translucent palette routine

		    LDA !14C8,x             ; \ if the sprite is alive...
		    BNE STATUS              ; / ...don't set the goal

                    LDA !7FAB10,x           ; \ set secret exit if the extra bit is set
                    AND #$04                ;  |
                    BEQ GOAL                ; /
                   
SECRET_EXIT:         
                    ;INC $141C|!Base2        ; > set secret exit (BlindEdit: disassembly behavior - checks LM's Boss uses Secret Exit property to activate secret exit)

;modified Alcaro's Exit Adder code (effectively triggers the secret exit)
LDA $1DEA|!Base2	;Check which event would normally be activated
CLC			;\Add one
ADC #$01		;| (you can change this number to decide which event you want to activate, e.g.
			;/if you want this to be your second secret exit, you would change this to #$02)
STA $1DEA|!Base2	;tell the game that's the event you want to activate

GOAL:		    DEC $13C6|!Base2        ; prevent Mario from walking at the level end
		    LDA #$FF                ; \ set goal
		    STA $1493|!Base2        ; /
		    LDA #!Music             ; \ set ending music
		    STA $1DFB|!Base2        ; /
                    RTS                     ; return

STATUS:		    EOR #$08                ; > if status != 8, return
		    ORA $9D                 ; \ if sprites locked, return
		    BNE RETURN              ; /

if !BossHurts == 2
JSL $01A7DC|!BankB
endif

		    LDA !C2,x              
		    JSL $0086DF|!BankB	     ; Execute pointers, based on C2 value
		    dw CALC_FRAME
		    dw APPEAR
		    dw MOVEMENT
		    dw SET_HIT_POINTS
		    dw SET_TIMER
		    dw SET_FRAME
		    dw DEFEATED

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sprite state 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CALC_FRAME:	    LDA #$03                ; \ set image
		    STA !1602,x             ; /
		    INC !1570,x             ; increment number of frames sprite has been on screen
		    LDA !1570,x             ; \ calculate frame
		    CMP #$90                ;  |
		    BNE RETURN              ; /
		    LDA #$08                ; \ set timer
		    STA !1540,x             ; /
		    INC !C2,x               ; increase sprite state
RETURN:		    RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sprite state 1 - Invisible
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


APPEAR:		    LDA !1540,x             ; \ if the timer is set...
		    BNE RETURN              ; /
		    LDA #$08                ; \ set timer
		    STA !1540,x             ; /
		    INC $190B|!Base2        ; increase sprite movement/contact?
		    LDA $190B|!Base2        ; \ if the sprite movement/contact isn't set...
		    CMP #$02                ;  |
		    BNE NO_SOUND            ; /
		    LDY #$10                ; \ sound effect
		    STY $1DF9|!Base2        ; /
NO_SOUND:	    CMP #$07                ; \ if the sprite movement/contact isn't set...        
		    BNE RETURN2             ; /            
		    INC !C2,x               ; increase sprite state
		    LDA #$40                ; \ set timer
		    STA !1540,x             ; /
RETURN2:	    RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sprite state 5 - It's okay to put 5 after 1 aka turn invisible.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SET_FRAME:	    LDA !1540,x             ; \ if the timer is set...
		    BNE SET_IMAGE           ; /
		    STZ !C2,x               ; restore sprite state
		    LDA #$40                ; \ set frame
		    STA !1570,x             ; /
SET_IMAGE:	    LDA #$03                ; \ set image
		    STA !1602,x             ; /
		    BRA SET_TIME

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sprite state 2 - Move and maybe get hit by shell or something
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


MOVEMENT:
if !BossHurts == 1
JSL $01A7DC|!BankB
endif

		    STZ !1602,x             ; restore image
		    JSR SPRITE_INTERACT     ; sprite interact routine
SET_TIME:	    LDA !15AC,x             ; \ set timer
		    BNE DONT_FACE_MARIO     ; /

		    %SubHorzPos()           ; \ if direction has changed since last frame...
		    TYA                     ;  |
		    CMP !157C,x             ;  |
		    BEQ FRAME               ; /
		    LDA #$1F                ; \ ...set time to show turning graphic = 1F
		    STA !15AC,x             ;  |
DONT_FACE_MARIO:    CMP #$10                ;  |
		    BNE DONT_CHANGE_DIR     ; /

		    PHA
		    LDA !157C,x             ; \ flip direction
		    EOR #$01                ;  |
		    STA !157C,x             ; /
		    PLA
DONT_CHANGE_DIR:    LSR A
		    LSR A
		    LSR A
		    TAY
		    LDA IMAGE_TABLE,y       ; \ set image
		    STA !1602,x             ; /

FRAME:		    LDA $14                 ; \ calculate frame
		    AND #$07                ;  |
		    BNE FRAME2              ; /

		    LDA !151C,x             ; \ set state
		    AND #$01                ;  |
		    TAY                     ; /
		    LDA !B6,x               ; \ set x speed
		    CLC                     ;  |
		    ADC ACCEL_X,y           ;  | set acceleration
		    STA !B6,x               ;  |
		    CMP X_SPEED,y           ;  | compare x speed
		    BNE FRAME2              ; /
		    INC !151C,x             ; increase state

FRAME2:		    LDA $14                 ; \ calculate frame
		    AND #$07                ;  |
		    BNE UPDATE_POSITION     ; /

		    LDA !1528,x             ; \ set state
		    AND #$01                ;  |
		    TAY                     ; /
		    LDA !AA,x               ; \ set y speed
		    CLC                     ;  |
		    ADC ACCEL_Y,y           ;  | set acceleration
		    STA !AA,x               ;  |
		    CMP Y_SPEED,y           ;  | compare y speed
		    BNE UPDATE_POSITION     ; /
		    INC !1528,x             ; increase state

UPDATE_POSITION:    JSL $018022|!BankB      ; update position based on speed values (X)
		    JSL $01801A|!BankB      ; update position based on speed values (Y)
		    RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sprite state 3 - Got Hit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SET_HIT_POINTS:	    LDA !1540,x             ; \ if the timer is set...
		    BNE SET_PAL             ; /
		    INC !C2,x               ; increase sprite state
		    LDA #$08                ; \ set timer
		    STA !1540,x             ; /
		    ;JSL $07F78B|!BankB      ;
		    INC !1534,x             ; increment sprite hit counter
		    LDA !1534,x             ; \ if hit points are zero...
		    CMP #!HIT_POINTS        ;  |
		    BNE RETURN3             ; /
		    LDA #$06                ; \ set sprite state
		    STA !C2,x               ; /
		    JSL $03A6C8|!BankB      ; disappear every sprite on screen routine
RETURN3:	    RTS                     ; return

SET_PAL:	    AND #$0E                ; set timer value for the flashing palette
		    EOR !15F6,x             ; set flashing palette
		    STA !15F6,x             ; store sprite palette
		    LDA #$03                ; \ set image
		    STA !1602,x             ; /
		    RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sprite state 4 - flash
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SET_TIMER:	    LDA !1540,x             ; \ if the timer is set...
		    BNE RETURN4             ; /
		    LDA #$08                ; \ set timer
		    STA !1540,x             ; /
		    DEC $190B|!Base2        ; decrease sprite movement/contact?
		    BNE RETURN4             ; if movement isn't set, return
		    INC !C2,x               ; increase sprite state
		    LDA #$C0                ; \ set timer
		    STA !1540,x             ; /
RETURN4:	    RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sprite state 6 - DIE DIE BOSS DIE!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


DEFEATED:	    
		    LDA !extra_prop_1,x
		    BNE BlockSpawn
		    LDA #$02                ; \ status = 2 (being killed by star) 
		    STA !14C8,x             ; /
		    STZ !B6,x               ; no x speed
		    LDA #$D0                ; \ set y speed
		    STA !AA,x               ; /
		    LDA #$23                ; \ sound effect
		    STA $1DF9|!Base2        ; /
		    RTS                     ; return

Ypos:
db $00,$10,$20

BlockSpawn:
		    LDA #$10                ; \ sound effect
                    STA $1DF9|!Base2        ; /

                    STZ !14C8,x             ; destroy the sprite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;AAAA! I wish I knew better way todo this -RussianMan ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    LDA !E4,x               ; \ setup block properties
                    STA $9A                 ;  |
                    LDA !14E0,x             ;  |
                    STA $9B                 ;  |
                    LDA !D8,x               ;  |
                    STA $98                 ;  |
                    LDA !14D4,x             ;  |
                    STA $99                 ; /
                   
                    PHP
                    REP #$30                ; \ change sprite to block 
                    LDA.W #!TILE1           ;  |
                    %ChangeMap16()          ;  |
                    PLP                     ; /     

		    LDA !E4,x               ; \ setup block properties
		    STA $9A                 ;  |
		    LDA !14E0,x             ;  |
		    STA $9B                 ;  |
		    LDA !D8,x               ;  |
		    CLC                     ;  |
		    ADC #$10                ;  | set lower y position
		    STA $98                 ;  |
		    LDA !14D4,x             ;  |
		    ADC #$00                ;  |
		    STA $99                 ; /
               
                    PHP
                    REP #$30                ; \ change sprite to block 
                    LDA.W #!TILE2           ;  |
                    %ChangeMap16()          ;  |
                    PLP                     ; /

		    LDA !E4,x               ; \ setup block properties
		    STA $9A                 ;  |
		    LDA !14E0,x             ;  |
		    STA $9B                 ;  |
		    LDA !D8,x               ;  |
		    CLC                     ;  |
		    ADC #$20                ;  | set lower y position
		    STA $98                 ;  |
		    LDA !14D4,x             ;  |
		    ADC #$00                ;  |
		    STA $99                 ; /
               
                    PHP
                    REP #$30                ; \ change sprite to block 
                    LDA.W #!TILE3           ;  |
                    %ChangeMap16()          ;  |
                    PLP                     ; /
                    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sprite interact routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SPRITE_INTERACT:    LDY #!SprSize-1         ; 
LOOP:		    LDA !14C8,y             ; \ if the sprite status is..
		    CMP #$09                ;  | ...shell-like
		    BEQ PROCESS_SPRITE      ; /
		    CMP #$0A                ; \ ...throwned shell-like
		    BEQ PROCESS_SPRITE      ; /
NEXT_SPRITE:	    DEY                     ;
		    BPL LOOP                ; ...otherwise, loop
		    RTS                     ; return

PROCESS_SPRITE:	    PHX                     ; push x
		    TYX                     ; transfer x to y
		    JSL $03B6E5|!BankB      ; get sprite clipping B routine
		    PLX                     ; pull x
		    JSL $03B69F|!BankB      ; get sprite clipping A routine
		    JSL $03B72B|!BankB      ; check for contact routine
		    BCC NEXT_SPRITE         ;

		    LDA #$03                ; \ set sprite state
		    STA !C2,x               ; /
		    LDA #$40                ; \ set timer
		    STA !1540,x             ; /

		    PHX                     ; push x
		    TYX                     ; transfer x to y

		    STZ !14C8,x             ; destroy the sprite

BLOCK_SETUP:	    LDA !E4,x               ; \ setup block properties
                    STA $9A                 ;  |
                    LDA !14E0,x             ;  |
                    STA $9B                 ;  |
                    LDA !D8,x               ;  |
                    STA $98                 ;  |
                    LDA !14D4,x             ;  |
                    STA $99                 ; /

EXPLODING_BLOCK:    PHB                     ; \ set the exploding block routine
		    LDA #$02                ;  |
		    PHA                     ;  |
		    PLB                     ;  |
		    LDA #$FF                ;  | $FF = set flashing palette
		    JSL $028663|!BankB      ;  |
		    PLB                     ; /

		    PLX                     ; pull x
		    LDA #$28                ; \ sound effect
		    STA $1DFC|!Base2        ; /
		    RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; transluscent palette routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TRANS_PALETTE:	    db $FF,$7F,$63,$0C,$00,$00,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$03,$00
		    db $FF,$7F,$E7,$1C,$00,$00,$00,$1C,$00,$1C,$20,$1C,$81,$1C,$07,$00
		    db $FF,$7F,$6B,$2D,$00,$00,$00,$2C,$40,$2C,$A2,$2C,$05,$2D,$0B,$00
		    db $FF,$7F,$EF,$3D,$00,$00,$60,$3C,$C3,$3C,$26,$3D,$89,$3D,$0F,$00
		    db $FF,$7F,$73,$4E,$00,$00,$E4,$4C,$47,$4D,$AA,$4D,$0D,$4E,$13,$10
                    db $FF,$7F,$F7,$5E,$00,$00,$68,$5D,$CB,$5D,$2E,$5E,$91,$5E,$17,$20
		    db $FF,$7F,$7B,$6F,$00,$00,$EC,$6D,$4F,$6E,$B2,$6E,$15,$6F,$1B,$30
		    db $FF,$7F,$FF,$7F,$00,$00,$70,$7E,$D3,$7E,$36,$7F,$99,$7F,$1F,$40


SUB_TRANS_PALETTE:  LDY #$24
		    STY $40
		    LDA $190B|!Base2
		    CMP #$08
		    DEC A
		    BCS SUB_824A
		    LDY #$34
		    STY $40
		    INC A
SUB_824A:	    ASL A
		    ASL A
		    ASL A
		    ASL A
		    TAX
		    STZ $00
		    LDY $0681|!Base2
SET_PALETTE:	    LDA TRANS_PALETTE,x
		    STA $0684|!Base2,y
		    INY
		    INX
		    INC $00
		    LDA $00
		    CMP #$10
		    BNE SET_PALETTE
		    LDX $0681|!Base2
		    LDA #$10
		    STA $0682|!Base2,x
		    LDA #$F0
		    STA $0683|!Base2,x
		    STZ $0694|!Base2,x
		    TXA
		    CLC
		    ADC #$12
		    STA $0681|!Base2
		    LDX $15E9|!Base2
		    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TILEMAP:	db $EA,$EA,$E8,$80,$A0,$C0,$E0,$82,$A2,$C2,$E2,$84,$A4,$C4,$E4,$86	;\
		db $A6,$C6,$E6,$E8,$EA,$EA,$E8,$80,$A0,$C0,$E0,$82,$A2,$C2,$E2,$84	;| Snake Boo (Level 79)
		db $A4,$C4,$E4,$86,$A6,$C6,$E6,$E8,$EA,$EA,$E8,$80,$A0,$C0,$E0,$82	;| and Parrot Boo (Level 98)
		db $A2,$C2,$E2,$84,$A4,$C4,$E4,$86,$A6,$C6,$E6,$E8,$E8,$E8,$A1,$C1	;|
		db $80,$A0,$C0,$E0,$82,$A2,$C2,$E2,$84,$A4,$C4,$E4,$86,$A6,$C6,$E6	;/

PROPERTIES:	db $00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;\
		db $00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| Snake Boo (Level 79)
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00	;| and Parrot Boo (Level 98)
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00	;|
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;/

;TILEMAP:	db $C0,$E0,$E8,$80,$A0,$A0,$80,$82,$A2,$A2,$82,$84,$A4,$C4,$E4,$86	;\
;		db $A6,$C6,$E6,$E8,$C0,$E0,$E8,$80,$A0,$A0,$80,$82,$A2,$A2,$82,$84	;| Original
;		db $A4,$C4,$E4,$86,$A6,$C6,$E6,$E8,$C0,$E0,$E8,$80,$A0,$A0,$80,$82	;|
;		db $A2,$A2,$82,$84,$A4,$A4,$84,$86,$A6,$A6,$86,$E8,$E8,$E8,$C2,$E2	;|
;		db $80,$A0,$A0,$80,$82,$A2,$A2,$82,$84,$A4,$C4,$E4,$86,$A6,$C6,$E6	;/

;PROPERTIES:	db $00,$00,$40,$00,$00,$80,$80,$00,$00,$80,$80,$00,$00,$00,$00,$00	;\
;		db $00,$00,$00,$00,$00,$00,$40,$00,$00,$80,$80,$00,$00,$80,$80,$00	;| Original
;		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$80,$80,$00	;|
;		db $00,$80,$80,$00,$00,$80,$80,$00,$00,$80,$80,$00,$00,$40,$00,$00	;|
;		db $00,$00,$80,$80,$00,$00,$80,$80,$00,$00,$00,$00,$00,$00,$00,$00	;/

HORZ_DISP:	db $08,$08,$20,$00,$00,$00,$00,$10,$10,$10,$10,$20,$20,$20,$20,$30
		db $30,$30,$30,$FD,$0C,$0C,$27,$00,$00,$00,$00,$10,$10,$10,$10,$1F
		db $20,$20,$1F,$2E,$2E,$2C,$2C,$FB,$12,$12,$30,$00,$00,$00,$00,$10
		db $10,$10,$10,$1F,$20,$20,$1F,$2E,$2E,$2E,$2E,$F8,$11,$FF,$08,$08
		db $00,$00,$00,$00,$10,$10,$10,$10,$20,$20,$20,$20,$30,$30,$30,$30

VERT_DISP:	db $12,$22,$18,$00,$10,$20,$30,$00
		db $10,$20,$30,$00,$10,$20,$30,$00
		db $10,$20,$30,$18,$16,$16,$12,$22
		db $00,$10,$20,$30,$00,$10,$20,$30
		db $00,$10,$20,$30,$00,$10,$20,$30


SUB_GFX:	    %GetDrawInfo()          ; sets y = OAM offset
		    LDA !1602,x		    ; \ $06 = index to frame start
		    STA $06                 ; /
		    ASL A
		    ASL A
		    STA $03
		    ASL A
		    ASL A
		    ADC $03
		    STA $02
		    LDA !157C,x             ; \ $04 = direction
		    STA $04                 ; / 
		    LDA !15F6,x             ; \ $05 = palette  
		    STA $05                 ; / 

		    LDX #$00                ; loop counter = (number of tiles per frame) - 1
LOOP_START:	    PHX                     ; push current tile number

		    LDX $02
		    LDA TILEMAP,x           ; \ store tilemap
		    STA $0302|!Base2,y      ; /

		    LDA $04                 ; \
		    LSR A                   ;  |
		    LDA PROPERTIES,x        ;  | get tile properties using sprite direction
		    ORA $05                 ;  |
		    BCS NO_FLIP             ;  |
		    EOR #$40                ;  |   ...flip tile
NO_FLIP:	    ORA $64                 ;  | put in level properties
		    STA $0303|!Base2,y      ; / store tile properties

		    LDA HORZ_DISP,x         ; \ tile x position = sprite x location ($00)
		    BCS CLEAR               ;  |
		    EOR #$FF                ;  |
		    INC A                   ;  |
		    CLC                     ;  |
		    ADC #$28                ;  |
CLEAR:		    CLC                     ;  |
		    ADC $00                 ;  |
		    STA $0300|!Base2,y      ; /

		    PLX                     ; pull x
		    PHX                     ; push x

		    LDA $06                 ; \ if the graphics are set...
		    CMP #$03                ;  |
		    BCC SET_VERT_DISP       ; /
		    TXA
		    CLC
		    ADC #$14
		    TAX

SET_VERT_DISP:	    LDA $01                 ; \ tile y position = sprite y location ($01)
                    CLC                     ;  |
                    ADC VERT_DISP,x         ;  |
                    STA $0301|!Base2,y      ; /

                    PLX                     ; \ pull, X = current tile of the frame we're drawing
		    INY #4
		    INC $02                 ;  |
		    INX                     ;  |
		    CPX #$14                ;  |
		    BNE LOOP_START          ; / 

		    LDX $15E9|!Base2
		    LDA !1602,x             ; \ if the image is set...
		    CMP #$03                ;  |
		    BNE DRAW_TILES          ; /

		    LDA !1558,x             ; \ if the timer is set...
		    BEQ DRAW_TILES          ; /

		    LDY !15EA,x
		    LDA $0301|!Base2,y      ; \ tile y position = sprite y location ($01)
		    CLC                     ;  |
		    ADC #$05                ;  |
		    STA $0301|!Base2,y      ;  |
		    STA $0305|!Base2,y      ; /

DRAW_TILES:	    LDY #$02                ; \ 02, because we didn't write to 460 yet
                    LDA #$13                ;  | A = number of tiles drawn - 1
		    JSL $01B7B3|!BankB      ; / don't draw if offscreen
		    RTS                     ; return