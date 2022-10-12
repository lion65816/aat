;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mushroom Block (Sprite Portion)
;;
;; Description: When used in conjunction with the block, this kind of acts like the
;; Mushroom Block from SMB2.
;;
;; Uses first extra bit: NO
;;
;; PSI Ninja edit: Made several adjustments to handle multiple different sprites based on
;;                 the extra byte value (to help save global sprite slot space).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Map16 to generate
!Map16Num = $16			;> PSI Ninja edit: 8-bit Map16 page number for the block to generate.

;Free RAM addresses
!FreeRAM = $140B|!Base2		;\ PSI Ninja edit: Changed to FreeRAM that gets cleared on level load. Fixes a glitch where, if the player picks up a
				;| Mushroom Block on the same frame they get crushed by a Mushroom Block that is transforming from a sprite to a block,
				;/ they can't pick up anymore Mushroom Blocks when the level is loaded again.
!BlockSet = $140C|!Base2	;> FreeRAM flag to tell us once a block has been set by the player.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print "MAIN ",pc
        PHB              
        PHK              
        PLB
	CMP #$08
	BNE SkipMain
	JSR SpriteMainSub
	BRA Gfx
SkipMain:
	STZ !1570,x
	JSR ThrownSub
Gfx:	
	JSR SubGfx
	PLB
	print "INIT ",pc
        RTL
	

ThrownSub:
	LDY #!SprSize-1
LoopStart:
	LDA !14C8,Y		; Skip dead sprites
	CMP #$08
	BCC NextSprite
	LDA !1686,Y		; Skip sprites that don't interact with others
	AND #$08
	BNE NextSprite
	LDA !1564,Y
	BNE NextSprite
	JSR SprSprInteract
NextSprite:	
        DEY
	BPL LoopStart
	RTS

SprSprInteract:
	JSL $03B69F|!BankB
	PHX
	TYX
	JSL $03B6E5|!BankB
	PLX
	JSL $03B72B|!BankB
	BCC Return1
	LDA #$08
	STA !14C8,x
	PHX
	TYX

	LDA !7FAB28,x
	BPL KillSprite
	LDA !7FAB10,x
	AND #$08
	BNE IncreaseHits

KillSprite:	
        LDA #$02                ; Sprite status = disappear in cloud of smoke
        STA !14C8,x
	LDA #$D0
	STA !AA,X
	JSL $01AB6F|!BankB   
	LDA #$04                
	JSL $02ACE5|!BankB  
	PLX
Return1:		
	RTS

IncreaseHits:
	JSL $01AB72|!BankB

	LDA !1534,x
	ORA #$80
	STA !1534,x

	PLX
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_01E611:
	db $00,$01,$02,$02,$02,$01,$01,$00
        db $00

DATA_01E61A:
        db $1E,$1B,$18,$18,$18,$1A,$1C,$1D
        db $1E
	
SpriteMainSub:
LDA #$01		;check flag if sprite is active
STA !FreeRAM		;done this way, aware of long address possibility

	JSL $0190B2|!BankB
	LDY !15EA
	PHY			;\
	LDY !extra_byte_1,x	;| PSI Ninja edit: Load the sprite's graphics based on its extra byte value.
	DEY			;| The index into the data table is the extra byte value minus one.
	LDA Tilemap,y		;|
	PLY			;/
	STA $0302|!Base2,y
	LDA $9D			; \ If sprites locked, 
        BEQ NotLocked		;  |
        JMP ADDR_01E6F0		; / jump to end of routine to draw sprite
NotLocked:
	INC !1570,x
	LDA !1FD6,x
	CMP #$02
	BCS CrazyStuff
	LDA !1528,x
	BEQ NoCrazyStuff
CrazyStuff:
	STZ !1528,x
	STZ !1FD6,x
NoCrazyStuff:
	LDA #$03
	%SubOffScreen()
        JSL $01802A|!BankB	; Move sprite
	LDA !1588,x
	AND #$04
        BEQ NotOnGround
        JSR ADDR_0197D5		; Runs if on ground
	BRA CheckSide
NotOnGround:
	LDA #$08
	STA !163E,x
	JSR ThrownSub
CheckSide:	
	LDA !1588,x
        AND #$03
        BEQ NotTouchingSide
	LDA #$10
	STA !163E,x
        JSR SetSpriteTurning	; Runs if touching object side
        LDA !B6,X
        ASL
        PHP
        ROR !B6,X
        PLP
        ROR !B6,X
NotTouchingSide:	
	LDA !1588,x          
        AND #$08
        BEQ NotTouchingCeiling
        STZ !AA,X	      	; If touching celing, sprite Y Speed = 0
NotTouchingCeiling:	

	LDA !AA,X
	ORA !B6,X
	BNE NoChange

	JSL $03B664|!BankB    ; Return if Mario is in contact
	JSL $03B69F|!BankB  ; (otherwise will turn into a block and kill him)
	JSL $03B72B|!BankB
	BCS NoChange

	LDA !163E,x
	BNE NoChange
	
	JSR TurnToBlock
	RTS
SetBounce:
	LDA #$D0
	STA !AA,X
NoChange:	
	LDA !1540,X		; Load time to boost Mario
        BEQ ADDR_01E6B0	

        STZ $72
        LDA #$02
        STA $1471|!Base2
        LDA !1540,X
        CMP #$07
        STZ $1471|!Base2
        LDY #$B0
        LDA $17
        BPL ADDR_01E69A
        LDA #$01
        STA $140D|!Base2
        BRA ADDR_01E69E           

ADDR_01E69A:
        LDA $15
        BPL ADDR_01E6A7           
ADDR_01E69E:
        LDA #$0B
        STA $72
        LDY #$80
        STY $1406|!Base2               
ADDR_01E6A7:
ADDR_01E6AE:
        BRA ADDR_01E6F0           

ADDR_01E6B0:
	JSL $01A7DC|!BankB     ; Handle Mario/sprite contact
        BCC ADDR_01E6F0
        STZ !154C,X
        LDA !D8,X
        SEC
        SBC $96
        CLC
        ADC #$04
        CMP #$1C
        BCC ADDR_01E6CE
        BRA ADDR_01E6F0

ADDR_01E6CE:
	LDA !1588,x
	BNE ADDR_01E6E2
	LDA !1570,x
	CMP #$20
	BCC ADDR_01E6E2
	BIT $15
        BVC ADDR_01E6E2
        LDA $1470|!Base2        ; \ Branch if carrying an enemy...
        ORA $187A|!Base2        ;  | ...or if on Yoshi
        BNE ADDR_01E6E2         ; /
        LDA #$0B                ; \ Sprite status = carried
        STA !14C8,x             ; /
ADDR_01E6E2:
	JSR ADDR_01AB31

ADDR_01E6E7:
ADDR_01E6F0:
Return01E6F:
	RTS			; Return 

DATA_01E6FD:
	db $00,$02,$00
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TurnToBlock:
	STZ !14C8,x             ; destroy the sprite
        
        LDA !E4,x               ; \ setup block position
	CLC
	ADC #$08
	AND #$F0
        STA $9A                 ;  |
        LDA !14E0,x             ;  |
	ADC #$00
        STA $9B                 ;  |
	
        LDA !D8,x               ;  |
	CLC
	ADC #$08
	AND #$F0
        STA $98                 ;  |
        LDA !14D4,x             ;  |
	ADC #$00
        STA $99                 ; /

        PHP
	LDA #!Map16Num		;\
	XBA			;| PSI Ninja edit: Construct the 16-bit Map16 value of the block.
	LDA !extra_byte_1,x	;/
        REP #$30                ; \ change sprite to block 
        %ChangeMap16()          ; /
        PLP

	LDA #$00
	STA !FreeRAM		;done this way, aware of long address possibility
	LDA #$01		;\ PSI Ninja edit: Set the flag because the player just set down the block.
	STA !BlockSet		;/
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_01AB2D:
        db $01,$00,$FF,$FF

ADDR_01AB31:
	LDA !1FD6,x
	BNE NoPush
	STZ $7B
        %SubHorzPos()
        TYA
        ASL
        TAY
        REP #$20                  ; Accum (16 bit)
        LDA $94
        CLC
        ADC DATA_01AB2D,Y
        STA $94
        SEP #$20                  ; Accum (8 bit)
	LDA #$01
	STA !1FD6,x
	STA !1528,x
NoPush:	
	RTS                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SetSpriteTurning:
	LDA !15AC,X             ; \ Return if turning timer is set
        BNE Return0190B1        ; /
        LDA #$08                ; \ Set turning timer
        STA !15AC,X             ; / 
FlipSpriteDir:
	LDA !B6,X		; \ Invert speed
        EOR #$FF                ;  |
        INC A			;  |
        STA !B6,X		; /
        LDA !157C,X             ; \ Flip sprite direction
        EOR #$01                ;  |
        STA !157C,X             ; / 
Return0190B1:
	RTS                       ; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_0197AF:
        db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
        db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
        db $E8,$E8,$E8,$00,$00,$00,$00,$FE
        db $FC,$F8,$EC,$EC,$EC,$E8,!E4,$E0
        db $DC,$D8,$D4,$D0,$CC,$C8

ADDR_0197D5:
        LDA !B6,X
        PHP
        BPL ADDR_0197DD
        EOR #$FF		  ; \ Set A to -A
        INC A                     ; /  
ADDR_0197DD:
        LSR
        PLP
        BPL ADDR_0197E4
        EOR #$FF		  ; \ Set A to -A
        INC A                     ; /  
ADDR_0197E4:
        STA !B6,X
        LDA !AA,X
        PHA
        JSR SetSomeYSpeed
        PLA
        LSR #2
        TAY
        LDA !9E,X                 ; \ If Goomba, Y += #$13
        CMP #$0F		  ;  |
        BNE ADDR_0197FB           ;  |
        TYA                       ;  |
        CLC                       ;  |
        ADC #$13		  ;  |
        TAY                       ; / 
ADDR_0197FB:
        LDA DATA_0197AF,Y
        LDY !1588,x
        BMI Return019805
        STA !AA,X                 
Return019805:
	RTS       

SetSomeYSpeed:
	LDA !1588,x
        BMI ADDR_019A10
        LDA #$00                ; \ Sprite Y speed = #$00 or #$18
        LDY !15B8,X             ;  | Depending on 15B8,x ???
        BEQ ADDR_019A12		;  | 
ADDR_019A10:
        LDA #$18                ;  | 
ADDR_019A12:
        STA !AA,X		; / 
Return019A14:
	RTS			; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubGfx:
	%GetDrawInfo()       	

	LDA #$00		;\ PSI Ninja edit: Build the property byte (YXPPCCCT) for this sprite. Keep the original ExGFX orientation (YX = 00).
	ORA $64			;| Add in the priority bits (PP) as determined by the level (Source: https://www.smwcentral.net/?p=viewthread&t=88598).
	;ORA #$00		;| Add in the priority bits (PP = 11).
	ORA #$0B		;/ Add in the palette (CCC = 101) and graphics page (T = 1) bits.
	STA $0303|!Base2,Y
	STA $0307|!Base2,Y
	STA $030B|!Base2,Y
	STA $030F|!Base2,Y
	
        LDA $00
	STA $0300|!Base2,Y
	STA $0304|!Base2,Y
	STA $0308|!Base2,Y
	STA $030C|!Base2,Y

	LDA $01
	STA $0301|!Base2,Y
	STA $0305|!Base2,Y
	STA $0309|!Base2,Y
	STA $030D|!Base2,Y

	PHY			;\
	LDY !extra_byte_1,x	;| PSI Ninja edit: Load the sprite's graphics based on its extra byte value.
	DEY			;| The index into the data table is the extra byte value minus one.
	LDA Tilemap,y		;|
	PLY			;/
	STA $0302|!Base2,Y
	STA $0306|!Base2,Y	
	STA $030A|!Base2,Y
	STA $030E|!Base2,Y	

        LDY #$02		; We already wrote to $0460,Y
        LDA #$03                ; We wrote 5 tiles
        JSL $01B7B3|!BankB
        RTS

Tilemap:
	db $80,$82,$84,$86,$88,$8A,$8C,$8E	;> PSI Ninja edit: Locations of the graphics in the 8x8 tilemap. Used for YXPPCCCT.
