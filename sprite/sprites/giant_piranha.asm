;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Green Giant Piranha Plant, based on mikeyk's Giant Piranha Plant code, further changed 
;; by Davros.
;;
;; Description: A piranha plant, only bigger.
;;
;; Uses first extra bit: YES
;; It will be upsidedown if the first extra bit is set.
;;
;; Extra Property Byte 1
;; Bit 1 - Ignores Mario.
;; Bit 2 - Sideways Piranha
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; giant piranha -  initialization JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	print "INIT ",pc
	LDA !7FAB10,x		; \
	AND #$04			; | Saving extra byte as $04 instead of $01... for table accessing purposes	
	STA !1510,x			; / 
	LDA !7FAB28,x
	AND #$02
	BNE SidewaysInit
	DEC !D8,x
	LDA !D8,x
	CMP #$FF
	BNE +
	DEC !14D4,x
+	RTL

SidewaysInit:
	LDA !1510,x
	BNE .Right
	INC !E4,x
	INC !E4,x
	BRA +
.Right
	DEC !E4,x
	DEC !E4,x
+	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; giant piranha -  main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR CodeStart
	PLB
	RTL
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; giant piranha main routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Yspeeds:	db $00,$F0,$00,$10
			db $00,$10,$00,$F0

TimeInPos:	db $20,$30,$20,$30
			db $22,$30,$22,$30

CodeStart:
	LDA !C2,x					;\ Don't draw the piranha while in its 'invisible' state
	BEQ Invisible				;/
	LDA $64						;\ 
	PHA							; | Preserve Property Byte so the piranha can mess with it - see RAM Map
	LDA !15D0,x					; | If the piranha is being eaten...
	BNE .DrawSprite				; | ... just draw the sprite
	LDA #$10					; | Set piranha priority property directly to $64...
	STA $64						; | ... when active and not being eaten
.DrawSprite						; |
	JSR SpriteGFX				; | Draw the sprite...
	PLA							; |	... then restore The Property Byte.
	STA $64						;/
Invisible:
	LDA #$03					;\
	%SubOffScreen()				; | Handle off-screen situation
	LDA $9D						; | Return if sprites locked
	BNE Return					; |
	LDA !1594,x					; | Do not interact with sprites and player if piranha is 'invisible'
	BNE DoNotInteract			; | $01803A combines $018032 and $01A7DC, thus saving space here
	JSL $01803A|!BankB			;/
DoNotInteract:
	LDA !C2,x					;\
	AND #$03					; | Get the piranha's state as an index...
	ORA !1510,x					; | ... and set the extra bit previously saved in it,
	TAY							; | so the proper speeds for the upsidedown or right sideways piranha are loaded
	LDA !1540,x					; | If timer hits zero...
	BEQ ChangeState				; | ... change piranha's state
	LDA !7FAB28,x				; |
	AND #$02					; | If sideways, update X speed instead
	BNE Sideways				; |
	LDA Yspeeds,y				; | 
	STA !AA,x					; | Load piranha's speed and update Y with no gravity
	JSL $01801A|!BankB			;/
	BRA Return
Sideways:
	LDA Yspeeds,y
	STA !B6,x
	JSL $018022|!BankB
Return:
	RTS
ChangeState:
	LDA !C2,x					;\
	AND #$03					; | Gets index to timers into scratch RAM instead of Y,
	STA $00						; | because of SubHorzPosCurrentFrame
	BNE .Active					; | States different than 0 are for active piranha, so branch
	LDA !7FAB28,x				; | Makes piranhas always rise ignoring the player...
	AND #$01					; | ...
	BNE .Active					; | ... if bit 1 of Extra Property 1 is set  
	JSR SubHorzPosCurrentFrame	; | Call a modified SubHorzPos routine
	LDA $0F						; |
	CLC							; |
	ADC #$1E					; |
	TAY							; | If Mario is near the sprite, this will clear the carry flag...
	LDA #$01					; | ... so it will be forced to be in its 'invisible' state
	STA !1594,x					; |
	CPY #$3C					; |
	BCC .End					; |
.Active							; |
	STZ !1594,x					; |
	LDA !7FAB28,x				; |
	AND #$02					; | Adjust index based on Extra Property
	ASL							; |
	TSB $00						; |
	LDY $00						; | Get index from $00...
	LDA TimeInPos,y				; | ... and set the timer accordingly
	STA !1540,x					; |
	LDA !C2,x					; | Last but not least, change state.
	INC : AND #$03				; |
	STA !C2,x					; |
.End							;/
	RTS	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SubHorzPosCurrentFrame: like SubHorzPos, but uses $D1-$D2 instead of $94-$95
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SubHorzPosCurrentFrame:
	LDY #$00                ;A:8505 X:0009 Y:0005 D:0000 DB:01 S:01ED P:envMXdizcHC:0464 VC:058 00 FL:138
	LDA $D1                 ;A:8505 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0480 VC:058 00 FL:138
	SEC                     ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0504 VC:058 00 FL:138
	SBC !E4,x               ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZCHC:0518 VC:058 00 FL:138
	STA $0F                 ;A:8550 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdizcHC:0548 VC:058 00 FL:138
	LDA $D2                 ;A:8550 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdizcHC:0572 VC:058 00 FL:138
	SBC !14E0,x             ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0596 VC:058 00 FL:138
	BPL .EndRoutine         ;A:85FF X:0009 Y:0000 D:0000 DB:01 S:01ED P:eNvMXdizcHC:0628 VC:058 00 FL:138
	INY                     ;A:85FF X:0009 Y:0000 D:0000 DB:01 S:01ED P:eNvMXdizcHC:0644 VC:058 00 FL:138
.EndRoutine
	RTS  
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; giant piranha graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HDisp:
	db $FC,$04,$FC,$04,$FC,$04,$FC,$04	; Piranha Up
	db $FC,$04,$FC,$04,$FC,$04,$FC,$04	; Piranha Down
	db $00,$00,$10,$10,$00,$00,$10,$10	; Piranha Left
	db $10,$10,$00,$00,$10,$10,$00,$00	; Piranha Right (the same for tables below)
	
VDisp:
	db $F0,$F0,$00,$00,$F0,$F0,$00,$00
	db $F0,$F0,$00,$00,$F0,$F0,$00,$00
	db $FC,$04,$FC,$04,$FC,$04,$FC,$04
	db $FC,$04,$FC,$04,$FC,$04,$FC,$04
	
Tilemap:
	db $A4,$A4,$C4,$C4,$C6,$C6,$E6,$E6
	db $E6,$E6,$C6,$C6,$C4,$C4,$A4,$A4
	db $A0,$A0,$A2,$A2,$C0,$C0,$C2,$C2
	db $A0,$A0,$A2,$A2,$C0,$C0,$C2,$C2
	
Properties:
	db $00,$40,$00,$40,$00,$40,$00,$40
	db $80,$C0,$80,$C0,$80,$C0,$80,$C0
	db $00,$80,$00,$80,$00,$80,$00,$80
	db $40,$C0,$40,$C0,$40,$C0,$40,$C0
	
SpriteGFX:
	%GetDrawInfo()
	
	LDA $14				;\
	LSR #3				; |
	CLC					; |
	ADC $15E9|!Base2	; | $03: index to frame start (0 or 4)
	AND #$01			; |
	ASL #2				; |
	STA $03				;/
	
	LDA !1510,x			; Get $00 or $04 from Extra Bit...
	ASL					; ... now, $00 or $08, ...
	TSB $03				; ... and just TSB it to $03 (now $00, $04, $08 or $0C) - handling upsidedown piranha too!
	
	LDA !7FAB28,x		; Get second extra priority bit and shift it...
	AND #$02			; ... so it becomes the right index for sideway graphics - now $03 could be...
	ASL #3				; ... $00, $04, $08, $0C, $10, $14, $18 or $1C.
	TSB $03				; ... TSB really makes the day easier here.
	
	PHX					; Preserve sprite index
	LDX #$03			; We will draw four tiles

.GFXLoop
	PHX					;\
	TXA					; | Preserve current tile...
	CLC					; | ... so we can use it and $03...
	ADC $03				; | ... as an index
	TAX					;/
	
	LDA $00				;\
	CLC					; | Piranha's Horizontal Displacement
	ADC HDisp,x			; |
	STA $0300|!Base2,y	;/
	
	LDA $01				;\
	CLC					; | Piranha's Vertical Displacement
	ADC VDisp,x			; |
	STA $0301|!Base2,y	;/
	
	LDA Tilemap,x		;\ Piranha's Tilemap
	STA $0302|!Base2,y	;/
	
	PHX					;\
	LDX $15E9|!Base2	; |
	LDA !15F6,x			; |
	PLX					; | Piranha's properties
	ORA Properties,x	; |
	ORA $64				; |
	STA $0303|!Base2,y	;/
	
	PLX					; Restore current tile
	INY #4				; Increase OAM Index (16x16 tiles)
	DEX					; Go to next tile
	BPL .GFXLoop		;
	
	PLX					; Restore Sprite Index
	LDY #$02			; We drew 16x16 tiles...
	LDA #$03			; ... 4 of them.
	JSL $01B7B3|!BankB	; Finish OAM write.			
	RTS					; End GFX code.