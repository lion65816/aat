;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Missile Bill shooter
;
;Uses first extra bit: YES
;Clear	: single turn
;Set	: unlimited turns
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!MISSILE_BILL_NUM	= $27	;change this to the missile bill number you want this to shoot.

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
; main bullet bill shooter code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Return:		RTS
SPRITE_CODE_START:

		LDA #$60 : SEC          ; \ if necessary, restore timer to 60 and don't ignore Mario next to shooter
		%ShooterMain()          ; | check if time to shoot, return if not. (Y now contains new sprite index)
		BCS Return              ; /

Shoot:
			LDA #$09
			STA $1DFC|!Base2
			LDA #$01
			STA.w !14C8,y
			LDA $179B|!Base2,x
			STA.w !E4,y
			LDA $17A3|!Base2,x
			STA.w !14E0,y
			LDA $178B|!Base2,x
			SEC
			SBC #$01
			STA.w !D8,y
			LDA $1793|!Base2,x
			SBC #$00
			STA.w !14D4,y
			PHX
			TYX
			LDA #!MISSILE_BILL_NUM
			STA !7FAB9E,x
			JSL $07F7D2|!BankB
			JSL $0187A7|!BankB
			PLX

			LDA $1783|!Base2,x
			AND #$40
			BEQ NOT_EXTRA
			LDA #$04

NOT_EXTRA:		ORA #$08
			PHX
			TYX
			STA !7FAB10,x
			STZ $00
			LDA $94
			CMP !E4,x
			LDA $95
			SBC !14E0,x
			BPL CODE_END
			INC $00
CODE_END:		PLX

		JSR Smoke_spawn
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display smoke effect bullet bill shooter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
Smoke:
.y_off:	db $00,$00,$00,$00,$FA,$04,$04,$FA
.x_off:	db $00,$00,$00,$00,$04,$04,$FA,$FA	  

.spawn
		PHX                     ;
		LDA !C2,y               ; \ Get index for smoke sprite offset.
		TAX                     ; | 
		LDA .x_off,x : STA $00  ; | x offset
		LDA .y_off,x : STA $01  ; | y offset
		LDA #$1B : STA $02      ; | smoke timer
		LDA #$01                ; | smoke sprite
		TYX                     ; | cheating*
		%SpawnSmoke()           ; / ~SPAWNING~
		PLX
		RTS
		
;*cheating because the SmokeSprite routine is actually intended for sprites, not shooters.
;however, since we just spawned a sprite (which's index is in Y) we can just take it's index
;and put it into x