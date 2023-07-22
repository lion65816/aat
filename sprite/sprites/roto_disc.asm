;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Roto Disc, by mikeyk
;; JackTheSpades - Asar, Sa-1 compatible and cleaned 
;; DigitalSine - Added Animation option, Spinjumpable option
;;				 Yosi Interaction & Extension field options
;;
;; Description: A circling sprite that flashes different colours and looks like a waffle.
;;
;; If you just want a vanilla roto disc like the original use the vanilla cfg file,
;; dont forget to keep the palette rotate define as 1.
;;
;; If you want to use the custom options and extension field use the custom cfg.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; HOW TO USE THE EXTRA BIT & EXTENSION BYTES
;;
;; \ Extra Bit - SET - Makes sprite travel clockwise.
;; /		     CLEAR - Makes sprite travel counter clockwise.
;;
;; \ Extra Byte 1 in LM will set the X radius of the circle the sprite will travel in.
;; | Extra Byte 2 in LM will set the Y radius of the circle the sprite will travel in.
;; / NOTE - If this are not equal to each other the sprite will move in an Ellipse..
;;
;; \ Extra Byte 3 in LM will set the speed of the sprites movement. 
;; / Non-Ridiculous range would be 00-0F.
;;
;; \ Extra Byte 4 in LM will set which half of the circle the sprite starts in.
;; | 00 - Bit Clear = Starts in bottom half of circle 
;; | 08	- Bit Set = Starts in top half of circle
;; |
;; | Values - 10,20,30,40,50,60,70,80,90,A0,B0,C0,D0,E0,F0
;; / Will start the sprite a different degrees around the semi circle respective to Bit3(08)
;;
;; EXAMPLE:
;; If you want the sprite to rotate clockwise, starting at 12'o'clock in 2 tile radius
;; in a perfect circle, but at a slowish speed. 
;; You would set Extra Bits to 3 in the sprite insertion dialog for clockwise rotation.
;; Then you set the Extension field too - 28 28 03 88
;; 28 for X radius and the next 28 for Y Radius. Theyre the same to make it a circle
;; 03 for a slow speed
;; Then 88 for position. 80 for the mid point of the semicircle 
;; and 08 to indicate the top half. 80+8==88
;;
;; Vanilla Roto Disc Values - 38 38 03 XX
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!AllowSpinjump = 0						; > Can you bounce on the sprite with a spinjump? Yes = 1 No = 0

!PaletteRotate = 1 						; > Should the palette rotate, 1 = Yes, 0 = No

!RotoDiscTile = $82						; \ If using vanilla cfg you can remap your tile here
										; / It wont affect you if using the custom cfg 

!Props = $21							; \ If not using palette roatate, add your tile properties
!Palette = $06							; / and your palette Values = $02,$04,$06,$08,$0A,$0C & $0E

Tilemap:
db $A4,$A6,$A4,$A6 						; > Graphics Tiles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite initialization JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

		LDA !extra_prop_1,x				; \ Find out which cfg is used
		AND #$02						; | By finding out if Bit Set
		BEQ .NotVanilla					; |	If not go check extra bytes
		LDA #$38						; | Else add default values.
		STA !187B,x						; |	
		STA !160E,x						; |
		LDA #$80						; |
		STA !1626,x						; | Speed is set later
		STZ !151C,x						; /
		RTL	

		.NotVanilla:				
		LDA !extra_byte_1,x				; \ X Radius
		STA !187B,x						; /

		LDA !extra_byte_2,x				; \ Y Radius
		STA !160E,x 					; /

		LDA !extra_byte_4,x             ; \ Set initial clock position
		AND #$F0						; | Mask lo nibble 
		STA !1626,x						; |
		LDA !extra_byte_4,x				; | 
		AND #$08						; | Check for bit 3 set
		BEQ +							; | If not zero assured
		LDA #$01						; | Else load 1 for high byte
+		STA !151C,x         			; /
		RTL
                    
                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            
print "MAIN ",pc                        
		PHB                     		; \
		PHK                     		;  | Sprite Wrapper
		PLB                     		;  |
		JSR START_SPRITE_CODE   		;  |
		PLB                     		;  |
		RTL                     		; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main sprite code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START_SPRITE_CODE:
		LDA $9D							; \ Dont Animate or add Speed if Locked
		BNE DoMath						; | But still be a nerd and do math
		%SubOffScreen()					; / Dont draw off screen
		
;; ==== Animation handler
		LDA $14							; \
		AND #$0F						; | Every F frames
		CMP #$0F						; |	
		BNE .NoUpdate					; |
		LDA !1602,x						; | Check what frame were on
		CMP #$03						; |
		BCS .Reset						; | If at end of table branch
		INC !1602,x						; | Else ++
		JMP .NoUpdate					; | Then go do speed stuff
		.Reset:							; |
		STZ !1602,x						; | Reset animation index
		.NoUpdate:						; /

;; ==== Get speed (Value to be added to the angle) in A
		LDA !extra_prop_1,x				; \ Check which cfg again
		AND #$02						; |
		BEQ .NotVanilla					; |
		LDA #$03						; | But this time so we can add speed
		JMP .Vanilla					; | Then jump the extra bytes
		.NotVanilla:					; |
		LDA !extra_byte_3,x				; | Get Speed byte
		.Vanilla:						; |
		STA $00							; | Stash it so we can do math on it
		LDA !extra_bits,x				; | Load sprites extra bits
		LDY $00							; |	Reload speed
		AND #$04						; | Check if extra bits set..
		BNE +							; | ..Branch if set
		LDA $00							; | Else Load speed in A
		EOR #$FF						; | Invert it for opposite directio
		JMP ++							; | It was either this or TAY, :)
+		TYA								; / If we didnt flip, get speed back from Y

;; ==== Make Y the "high byte" of the speed ($00 or $FF)
++		LDY #$00						; \ 
		CMP #$00						; |
		BPL +							; | Did speed end up Negative?
		DEY								; / If not make high byte FF

;; ==== Add to angle low and high byte
+		CLC	: ADC !1626,x				; \ Add Intial Lo Offset
		STA !1626,x						; | 
		TYA								; |	Reload FF to A	
		ADC !151C,x						; |	Add Initial Hi Offset
		AND #$01						; | Make sure its in 0 or 1
		STA !151C,x						; / 

DoMath:
;; ==== Save sprite position
		LDA !E4,x						; \  X Lo
		PHA								; | Preserve X/Y Pos to restore later
		LDA !14E0,x						; | X Hi
		PHA								; |
		LDA !D8,x						; | Y Lo
		PHA								; |
		LDA !14D4,x						; | Y Hi
		PHA								; /
					
;; ==== Input for Circle routines
		LDA !1626,x : STA $04 			; \ Load start pos Lo
		LDA !151C,x : STA $05 			; | and Hi
		LDA !187B,x : STA $06 			; / Load X Radius
		
		%CircleX()						; > X offset in $07-08

		LDA !160E,x : STA $06 			; > Reload scratch with Y Radius

		%CircleY()						; > Y offset in $09-0A
		
		LDA !E4,x						; \ Sprite X Lo Pos
		CLC : ADC $07					; | + Dissplacement
		STA !E4,x						; |
		LDA !14E0,x						; | Sprite X High Pos
		ADC $08							; | + Dissplacement
		STA !14E0,x						; /
		
		LDA !D8,x						; \ Sprite Y Lo Pos
		CLC : ADC $09					; | + Displacement
		STA !D8,x						; |
		LDA !14D4,x						; | Sprite Y Hi Pod
		ADC $0A							; | + Displacement
		STA !14D4,x						; /

		LDA $9D							; \ No point in checking interactions
		BNE RETURN_EXTRA				; / If sprites frozen

Interaction:
		JSL $01A7DC|!BankB         		; \ Check for Mario/sprite contact
		BCC RETURN_EXTRA        		; | (Carry set = Mario/sprite contact)
		LDA $1490|!Base2        		; | If Mario star timer
		BEQ No_star            			; | 
		%Star()							; | 
		JMP RETURN_EXTRA        		; / Return

No_star:
		LDA $1497|!Base2        		; \ if Mario is invincible...
		BNE RETURN_EXTRA           		; |   ... return
		If !AllowSpinjump
			LDA $140D|!Base2 			; \ If not spinning
			ORA $187A|!Base2        	; | Or on Yoshi?
			BEQ Hurt					; /

			STZ !154C,x             	; \ Always interact			
			LDA !D8,x               	; | SubVertPos
			SEC : SBC $96           	; | 
			CLC : ADC #$08          	; |
			LDY $187A|!Base2        	; | On Yoshi?
			BEQ NoSideBump         		; |
			SEC : SBC #$0F          	; | Lower height offset
			NoSideBump:            		; |
			CMP #$1F                	; | 
			BCC Hurt              		; / From Sides or Below

			LDY #$D0					; \ Small bounce speed
			LDA $15						; | Get inputs
			AND #$80					; | Are we holding jump
			BEQ NotBigBounce			; | If not store speed
			LDY #$A0					; | Else make it big jump
			NotBigBounce:				; |
			STY $7D						; | Mario Y speed
			STZ $00 : STZ $01			; | No Offsets for contact
			LDA #$0B : STA $02			; | Duration timer
			LDA #$02 					; | Contact GFX
			%SpawnSmoke()				; |
			BCS NoHurt					; | Dont play sound if not spawned
			LDA #$02 					; | Contact SFX	
			STA $1DF9|!Base2			; |
			JMP NoHurt					; /
		endif

		Hurt:
			LDA $187A|!Base2        	; \ On Yoshi?
			BEQ NoYosh1					; |
			JSR LoseYoshi				; |
			JMP NoHurt					; |
			NoYosh1:					; |
			JSL $00F5B7|!BankB         	; / If not hurt Mario
		NoHurt:

RETURN_EXTRA:
		JSR SUB_GFX						; > Go Draw

		LDA !14C8,x             		; \
		CMP #$08						; | If sprite is alive...
		BEQ .restore					; / .. Keep its original position for next cycle

;; ==== Clean stack
		PLA : PLA						; \ If its dead, original position is uneeded.
		PLA : PLA						; | Retrieve old values so we can..
		RTS								; / ..Return

.restore
;; ==== Restore sprite position.
		PLA     						; \ Pull Back originals in reverse order
		STA !14D4,x						; | Y Hi
		PLA        						; |	
		STA !D8,x  						; |	Y Lo
		PLA        						; |
		STA !14E0,x						; | X Hi
		PLA        						; |
		STA !E4,x						; | X Lo
		RTS								; / 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:

	LDA !1602,x 			; \ Get Current frame for index
	STA $05 				; / Stash it for later

	%GetDrawInfo()          ; \ Y = index to sprite tile map ($300)
							; | $00 = sprite x position relative to screen boarder 
							; / $01 = sprite y position relative to screen boarder  
			
	LDA $00                 ; \ Tile X position
	STA $0300|!Base2,y      ; /

	LDA $01                 ; \ Tile Y position
	STA $0301|!Base2,y      ; /

	LDA !extra_prop_1,x		; \ Find out which cfg is used
	AND #$02				; | By finding out if Bit Set
	BEQ .NotVanilla			; |	If not go check extra bytes
	LDA #!RotoDiscTile		; |
	JMP .Vanilla			; |
	.NotVanilla:			; |
	LDX $05					; | Load frame index
	LDA Tilemap,x			; |
	.Vanilla:
	STA $0302|!Base2,y      ; |
	LDX $15E9|!Base2        ; / Restore sprite index
		
	if !PaletteRotate		; \
		LDA $14				; |
		AND #$07			; |
		ASL A				; |
		ORA #$01			; |
	else					; |
		LDA #!Props			; |
		ORA #!Palette		; |
	endif					; /

	ORA $64                 ; \   
	STA $0303|!Base2,y      ; / Store tile properties                 

	LDY #$02                ; \ 16x16 tile
	LDA #$00                ; | A = number of tiles drawn - 1
	JSL $01B7B3|!BankB      ; / Don't draw if offscreen

	RTS                     ; > Return


LoseYoshi:
	LDX $18E2|!Base2		; Dissassembled routine
	DEX
	BMI +
	LDA #$10
	STA !163E,x
	LDA #$03
	STA $1DFA|!Base2
	LDA #$13
	STA $1DFC|!Base2
	LDA #$02
	STA !C2,x
	STZ $187A|!Base2
	STZ $0DC1|!Base2
	LDA #$C0
	STA $7D
	STZ $7B
	LDY !157C,x
	LDA RunAwaySpeed,y
	STA !B6,x
	STZ !1594,x
	STZ !151C,x
	STZ $18AE|!Base2
	LDA #$30
	STA $1497|!Base2
+   LDX $15E9|!Base2
	RTS
RunAwaySpeed:
db $10,$F0