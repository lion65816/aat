;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SMB2 Birdo, by mikeyk (optimized by Blind Devil)
;;
;; Description: This Birdo acts similar to the one of SMB2. It must be hit by 3 eggs
;; in order to be defeated. Hitpoints are customizable.
;; 
;; Uses first extra bit: YES
;; If the first extra bit is clear, Birdo will spit the custom sprite defined in !Spawn1.
;; Use this for a birdo that only shoots eggs or only shoots fire.
;; If the first extra bit is set, Birdo will randomly throw the custom sprites defined in
;; !Spawn1 and !Spawn2. Use this for a Birdo that shoots both fire and eggs.			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tilemap defines
!HeadNorm = $8E
!HeadSpit = $CE
!HeadHurt1 = $E0
!HeadHurt2 = $E2
!Body1 = $AE
!Body2 = $EE
!Bow1 = $C2		;16x16
!Bow2 = $BD		;8x8

;Orb tilemap (if set to spawn)
!OrbTile = $AB

;Orb palette/properties
!OrbProp = $07		;palette/properties, YXPPCCCT format

;Spawned sprites:
!Spawn1 = $42		;always spawned
!Spawn2 = $BD		;randomly spawned (only when extra bit is set)

;Spit intervals:
Intervals:
db $40,$40,$90		;amount of frames before spitting sprites

;Hitpoints
!HP = $03		;amount of HP Birdo has.

;Sound effects
!SpitSFX = $20
!SpitPort = $1DF9
!HurtSFX = $28
!HurtPort = $1DFC

;Other defines
!EndLevelOrb = 0	;if 1, boss will spawn an orb after being defeated.
!Music = $0B		;song to play during level end.
!SpitOrbSFX = $10
!SpitOrbPort = $1DF9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
                    %SubHorzPos()
                    TYA
                    STA !157C,x
                    
                    TXA
                    AND #$03
                    ASL #5
                    STA !163E,x
                    CLC
                    ADC #$22
                    STA !1504,x

		    STZ !1510,x
                    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
		    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR START_CODE	    ;  |
                    PLB                     ;  |
                    RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:            db $00,$F8,$00,$08     ;rest at bottom, moving up, rest at top, moving down
TIME_IN_POS:        db $50,$20,$50,$20     ;moving up, rest at top, moving down, rest at bottom

RETURN:             RTS

START_CODE:
if !EndLevelOrb
		    LDA !7FAB28,x
		    AND #$80
		    BEQ +
		    JMP OrbCode		;out of bounds
+
endif
	            %SubHorzPos()	    ; \ always face mario
                    TYA                     ;  | 
                    STA !157C,x             ; /

	JSR ProcessCachedHit

                    JSR SUB_GFX             ; draw gfx
                    LDA !14C8,x             ; \ if status != 8...
if !EndLevelOrb
		    CMP #$02		    ;check if starkilled
		    BNE +
		    JMP SpawnOrb
+
endif
                    CMP #$08                ;  }   ... not (killed with spin jump [4] or star[2])
                    BNE RETURN              ; /    ... return
                    LDA $9D                 ; \ if sprites locked...
                    BNE RETURN              ; /    ... return

		    LDA #$03
                    %SubOffScreen()         ; only process while on screen
                    INC !1570,x             ; increment number of frames has been on screen

	LDA !C2,x
	BEQ NormalState
Stunned:
        LDA !1570,x             ; \ calculate which frame to show:
        LSR #3                  ;  | 
        AND #$01                ;  | update every 16 cycles if normal
	CLC
	ADC #$03
        STA !1602,x             ; / write frame to show

	LDA !1564,x		; If Birdo has been hit, set the stunned image
	BEQ ResumeNormalLife

	INC !1540,x
	STZ !B6,x
	JMP Shared
	
ResumeNormalLife:	
	STZ !C2,x
	
NormalState:
	LDA !1504,x
	BEQ DoneDec
	DEC !1504,x

DoneDec:
		    LDA !151C,x
                    AND #$01
                    BEQ LABEL3
                    LDA !1570,x             ; \ calculate which frame to show:
                    LSR #3                  ;  | 
                    AND #$01                ;  | update every 16 cycles if normal
LABEL3:             STA !1602,x             ; / write frame to show

                    LDA !1504,x             ; \ if time until spit >= $10
                    CMP #$10                ;  |   just go to normal walking code
                    BCS JUMP_BIRDO          ; /
                    LDA #$02                ; we're about to spit, so...
                    STA !1602,x             ; open birdo's mouth
                    INC !1540,x             ; we didn't move birdo this frame, so we don't want a decrement
                    INC !163E,x
                    STZ !B6,x               ; stop birdo from moving
                    LDA !1504,x             ; \ throw hammer if it's time
                    BNE NO_RESET            ;  |

		    LDA !1510,x
		    TAY
                    LDA Intervals,y
                    STA !1504,x

		    LDA !1510,x
		    CMP #$02
		    BCC NoResetIndex
		    STZ !1510,x
		    BRA NO_RESET
NoResetIndex:
		    INC !1510,x

NO_RESET:           CMP #$05
                    BNE NO_THROW
                    JSR SUB_THROW		; /
NO_THROW:           BRA APPLY_SPEED         ;

JUMP_BIRDO:         LDA !163E,x
                    CMP #$28                ;  |   just go to normal walking code
                    BCS WALK_BIRDO          ; /
                    INC !1540,x             ; we didn't move birdo this frame, so we don't want a decrement
                    STZ !B6,x               ; stop birdo from moving
                    LDA !163E,x
                    CMP #$20
                    BNE NO_JUMP2
                    LDA #$D8                ; \  y speed
                    STA !AA,x               ; /
                    BRA APPLY_SPEED
NO_JUMP2:           CMP #$00
                    BNE NO_JUMP
                    LDA #$FF
                    STA !163E,x
NO_JUMP:            BRA APPLY_SPEED         ;

WALK_BIRDO:         LDA !151C,x             ;
                    AND #$03
                    TAY                     ;
                    LDA !1540,x             ;
                    BEQ CHANGE_SPEED        ;
                    LDA X_SPEED,y           ; | set y speed
                    STA !B6,x               ; /
                    BRA APPLY_SPEED
                    
CHANGE_SPEED:       LDA TIME_IN_POS,y       ;A:0001 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZCHC:0654 VC:057 00 FL:24235
                    STA !1540,x             ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0686 VC:057 00 FL:24235
                    INC !151C,x
                    
APPLY_SPEED:        LDA !1588,x             ; \ if is touching the side of an object...
                    AND #$03                ;  |
                    BEQ DONT_CHANGE_DIR     ;  |
                    INC !151C,x             ; /

DONT_CHANGE_DIR:
	JSR SpriteInteract

Shared:
	JSL $01802A|!BankB      ; update position based on speed values
        JSL $01A7DC|!BankB      ; check for mario/contact
	BCC Return2

	JSR MarioInteract

Return2:	
        RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


MarioInteract:	
	%SubVertPos()           ; \
        LDA $0E                 ;  | if mario isn't above sprite, and there's vertical contact...
        CMP #$DB                ;  |     ... sprite wins
        BPL SpriteWins          ; /
        LDA $7D                 ; \ if mario speed is upward, return
        BMI Return1  

RideSprite:	
	LDA #$01                ; \ set "on sprite" flag
        STA $1471|!Base2        ; /
        LDA #$06                ; Disable interactions for a few frames
        STA !154C,x             
        STZ $7D                 ; Y speed = 0
        LDA #$D6                ; \
        LDY $187A|!Base2        ;  | mario's y position += E1 or D1 depending if on yoshi
        BEQ NO_YOSHI            ;  |
        LDA #$C6                ;  |
NO_YOSHI:
	CLC                     ;  |
        ADC !D8,x               ;  |
        STA $96                 ;  |
        LDA !14D4,x             ;  |
        ADC #$FF                ;  |
        STA $97                 ; /
        LDY #$00                ; \ 
        LDA $1491|!Base2        ;  | $1491 == 01 or FF, depending on direction
        BPL LABEL9              ;  | set mario's new x position
        DEY                     ;  |
LABEL9:
	CLC                     ;  |
        ADC $94                 ;  |
        STA $94                 ;  |
        TYA                     ;  |
        ADC $95                 ;  |
        STA $95                 ; /
        RTS                     	

SpriteWins:
	LDA !154C,x             ; \ if disable interaction set...
        ORA !15D0,x             ;  |   ...or sprite being eaten...
        BNE Return1             ; /   ...return
        LDA $1490|!Base2        ; Branch if Mario has a star
	BNE MarioHasStar

	JSL $00F5B7|!BankB	
Return1:
	RTS

MarioHasStar:
	LDA #$01		; Set stunned state
	STA !C2,x
	INC !1540,x

	%Star()

if !EndLevelOrb
	JSR SpawnOrb	;call label as subroutine if starkilled
endif

	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
KILLED_X_SPEED:
	db $F0,$10
	
SpriteInteract:
	ldy #!SprSize-1
InteractLoop:	
	lda !14C8,y
	cmp #$09
	bcs ProcessSprite
NextSprite:	
	dey
	bpl InteractLoop
	rts

ProcessSprite:
	PHX                       
        TYX                       
        JSL $03B6E5|!BankB  
        PLX                       
        JSL $03B69F|!BankB  
        JSL $03B72B|!BankB
	bcc NextSprite

	PHX
	TYX
	
	JSL $01AB72|!BankB

	lda !14C8,x
	CMP #$0A
	BEQ NoKill
	
	LDA #$02		; Kill thrown sprite
	STA !14C8,x
	
	LDA #$D0       		; Set killed Y speed
        STA !AA,x
	
	LDY #$00		; Set killed X speed
	LDA !B6,x
	BPL SetSpeed
	INY

SetSpeed:	
	LDA KILLED_X_SPEED,y
	STA !B6,x

NoKill:	
	PLX

HandleBirdoHit:	
	LDA #!HurtSFX           ; Play sound effect 
        STA !HurtPort|!Base2

	LDA #$01		; Set stunned state
	STA !C2,x
	
	LDA #$20		; Set stunned timer
	STA !1564,x

	inc !1534,x		;Increase hit counter and 
	lda !1534,x		;Check if Birdo's been hit X times
	cmp #!HP
	bcc Return3

	LDA #$02		; Kill Birdo
	STA !14C8,x
	LDA #$D0		; Set killed Y speed
        STA !AA,x
	TYA			; Set killed X speed
	EOR #$01
	TAY
	LDA KILLED_X_SPEED,y
	STA !B6,x

	LDA #$03
        STA !1602,x             ;write frame to show

if !EndLevelOrb
SpawnOrb:
		LDA !1528,x
		BNE ReadyToSpawn

		LDA #$0C
		STA !15AC,x
		INC !1528,x
		RTS

ReadyToSpawn:
		LDA !15AC,x
		CMP #$04
		BNE Return3

		JSR SubThrow2
		STZ !15AC,x
endif

Return3:
	RTS


ProcessCachedHit:
	LDA !1534,x
	BPL Return3
	AND #$7F
	STA !1534,x
	BRA HandleBirdoHit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spawn sprite routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetXYOffsets:
		LDA !157C,x
		TAY
		LDA X_OFFSET,y
		STA $00

		LDA #$F2
		STA $01
		RTS

if !EndLevelOrb
SubThrow2:
		JSR GetXYOffsets

		LDA OrbXSpeeds,y
		STA $02

		LDA #$D8
		STA $03

		LDA !7FAB9E,x		;load its own sprite number
		SEC
		%SpawnSprite()
		CPY #$FF
		BEQ no

		LDA #$08
		STA !14C8,y

		PHX
		TYX
		LDA !7FAB28,x
		ORA #$80
		STA !7FAB28,x		;set sprite to look like an orb
		PLX

		LDA !167A,y
		ORA #$02		;make it immune to cape/fire/bouncing blocks
		STA !167A,y

		LDA !1662,y
		AND #$C0		;set clipping value to $00
		STA !1662,y

		LDA #!SpitOrbSFX
		STA !SpitOrbPort|!Base2
no:
		RTS

OrbXSpeeds:	    db $08,$F8
endif

X_OFFSET:           db $06,$FA
                    
SUB_THROW:
		JSR GetXYOffsets

		STZ $02
		STZ $03

		LDA !7FAB10,x
		AND #$04
		BEQ ThrowEgg

		JSL $01ACF9|!BankB		;get a random number
		AND #$40			;preserve bit 6
		BEQ ThrowEgg

		LDA #!Spawn2
		BRA Spawn

ThrowEgg:
		LDA #!Spawn1
Spawn:
		SEC
		%SpawnSprite()
		CPY #$FF
		BEQ RETURN67

		LDA #!SpitSFX
		STA !SpitPort|!Base2
RETURN67:
		RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main orb routine (includes stuff copied from Davros' Goal Sphere)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OrbCode:
                    JSR SUB_GFX             ; draw gfx

                    LDA !14C8,x             ; \ if status != 8...
                    CMP #$08                ;  }   ... not (killed with spin jump [4] or star[2])
                    BNE RETURN9             ; /    ... return
                    LDA $9D                 ; \ if sprites locked...
                    BNE RETURN9             ; /    ... return

                    LDA !1588,x             ; \ if on the ground, reset the turn counter
                    AND #$04                ;  |
                    BEQ IN_AIR              ; /

                    LDA #$10                ; \ y speed = 10
                    STA !AA,x               ; /
		    STZ !B6,x		    ;x speed = 0

IN_AIR:             JSL $01802A|!BankB      ; update position based on speed values

                    JSL $01A7DC|!BankB      ; check for Mario/sprite contact (carry set = contact)
                    BCC RETURN9             ; return if no contact

		    STZ !14C8,x             ; erase the sprite

		    STZ $72		    ;clear player is in the air flag. freezes him in level end.

                    LDA #$FF                ; \ set normal exit
                    STA $1493|!Base2        ; /
                    STA $0DDA|!Base2        ; set music

		    DEC $13C6|!Base2	    ;prevent player from doing the level end march.

		    LDA #!Music             ; \ music to play during level end
                    STA $1DFB|!Base2        ; /

RETURN9:
		    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:            db !HeadNorm,!Body1,!HeadNorm,!Body2,!HeadSpit,!Body1
	            db !HeadHurt2,!Body1,!HeadHurt1,!Body1

VERT_DISP:          db $F0,$00,$F0,$00,$F0,$00
	            db $F0,$00,$F0,$00

PROPERTIES:         db $40,$00             ;yxppccct format
  
SUB_GFX:            %GetDrawInfo()          ; after: Y = index to sprite tile map ($300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder

if !EndLevelOrb
		    LDA !7FAB28,x
		    AND #$80
		    BEQ +
		    JMP DrawOrb
+
endif
                    LDA !1602,x             ; \
                    ASL                     ;  | $03 = index to frame start (frame to show * 2 tile per frame)
                    STA $03                 ; /
                    LDA !157C,x             ; \ $02 = sprite direction
                    STA $02                 ; /
                    PHX                     ; push sprite index

	JSR DrawBow

                    LDX #$01                ; loop counter = (number of tiles per frame) - 1
LOOP_START:         PHX                     ; push current tile number
                    TXA                     ; \ X = index to horizontal displacement
                    ORA $03                 ; / get index of tile (index to first tile of frame + current tile number)
FACING_LEFT:        TAX                     ; \ 
                    
                    LDA $00                 ; \ tile x position = sprite x location ($00)
	CLC
	ADC #$08
	STA $0300|!Base2,y		    ; /
                    
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


	TYA			; Set tile size
        LSR #2
        TAX
        LDA #$02
        STA $0460|!Base2,x
	
                    PLX                     ; \ pull, X = current tile of the frame we're drawing
                    INY                     ;  | increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ;  |    ...so increment 4 times
                    DEX                     ;  | go to next tile of frame and loop
                    BPL LOOP_START          ; / 

                    PLX                     ; pull, X = sprite index
                    LDY #$FF                ; \ 02, because we didn't write to 460 yet
                    LDA #$02                ;  | A = number of tiles drawn - 1
OAMEnd:
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return

BowDispX:
	db $FD,$02,$FB,$0C
BowDispY:
	db $E8,$F1
Tilemap2:
	db !Bow1,!Bow2
	
DrawBow:
	PHY
	TYA
	CLC
	ADC #$08
	TAY

	PHX
	
	LDA !C2,x
	PHA
	ASL
	ORA $02
	TAX
	LDA BowDispX,x
	CLC
	ADC #$08
	ADC $00
	STA $0300|!Base2,y

	PLX
	LDA $01
	CLC
	ADC BowDispY,x
	STA $0301|!Base2,y

	LDA Tilemap2,x
	STA $0302|!Base2,y

	LDA #$03
	LDX $02
	BNE NoFlipStunnedBow
	ORA #$40
NoFlipStunnedBow:
	ORA $64
	STA $0303|!Base2,y

	PLX
	TYA
        LSR #2
	PHA
        LDA !C2,x
	EOR #$01
	ASL
	PLX
        STA $0460|!Base2,x
	PLY
	RTS

if !EndLevelOrb
DrawOrb:
		    REP #$20
                    LDA $00                 ; \ tile x/y position
                    STA $0300|!Base2,y      ; /
		    SEP #$20
                    
                    LDA #!OrbTile           ; \ store tile
                    STA $0302|!Base2,y      ; / 
                    
                    LDA #!OrbProp           ; get palette/properties
                    ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

                    LDY #$02                ; \ (460 &= 2) 16x16 tiles maintained
                    LDA #$00                ;  | A = number of tiles drawn - 1
                    JMP OAMEnd		    ; /
endif