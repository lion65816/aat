;############################################;
;# Cluster Bullet                           #;
;# By MiniMawile303                         #;
;# Credit if used, do not claim as your own #;
;############################################;

;#####################;
;# Defines and Stuff #;
;#####################;

	!cluster_speed_y      = $1E52|!addr
	!cluster_speed_x      = $1E66|!addr
	!cluster_speed_y_frac = $1E7A|!addr
	!cluster_speed_x_frac = $1E8E|!addr
	
	!cluster_expire_timer = $0F4A|!addr
	!cluster_tile         = $0F72|!addr
	!cluster_props        = $0F86|!addr

;################;
;# Main Wrapper #;
;################;

print "MAIN ",pc
	PHB : PHK : PLB
	JSR SpriteCode
	PLB
	RTL

;################;
;# Main Routine #;
;################;

Offscreen:
	SEP #$20						; \ kill bullet sprite
	LDA #$00						; |
	STA !cluster_num,y				; |
	RTS								; /

SpriteCode:
	LDA !cluster_x_low,y			; \ store bullet position into scratch RAM
	STA $00							; |
	LDA !cluster_x_high,y			; |
	STA $01							; |
	LDA !cluster_y_low,y			; |
	STA $02							; |
	LDA !cluster_y_high,y			; |
	STA $03							; /
	
	REP #$20

	LDA $00							; \ handle the bullet going offscreen, x based
    SEC : SBC $1A					; |
	STA $00							; |
	BMI Offscreen					; |
    CMP #$00F8						; |
    BCC +							; |
    BRA Offscreen					; |
	+								; /
	
	LDA $02							; \ handle the bullet going offscreen, y based
    SEC : SBC $1C					; |
	STA $02							; |
	CMP #$FFF0						; |
    BCS +							; |
    CMP #$00F0						; |
    BCC +							; |
    BRA Offscreen					; |
	+								; /

	SEP #$20

	JSR Graphics
	
	LDY $15E9|!addr

	LDA $9D							; \ if sprites are locked, don't do things
	BNE .done						; /
	
	JSR Interaction					; \ process interaction
	BCS +							; | if carry set, then the player isn't touching the bullet
	PHY								; |
	JSL $00F5B7						; | hurt player
	PLY								; |
	+								; /
	
	JSR Speed

	LDA !cluster_expire_timer,y		; \ load the bullet expiration timer
	BEQ .done						; | if it's 0 then we don't care, just skip all this stuff
	DEC								; | decrement it
	STA !cluster_expire_timer,y		; | store it back
	BNE .done						; | and if it's not 0 then we're not ready to kill the bullet yet
	LDA #$00						; | if it's 0,
	STA !cluster_num,y				; / then kill the bullet

	.done
	RTS
	
Interaction:						; interaction routine adapted from the original game's code ($02FE71)
	LDA !cluster_x_low,y
	STA $00
	LDA !cluster_x_high,y
	STA $01

	REP #$20
	LDA $94
	SEC : SBC $00
	CLC : ADC #$000A
	SEP #$20

	CMP #$14
	BCS .noContact

	LDA #$14

	LDX $73
	BNE .notBig
	LDX $19
	BEQ .notBig

	LDA #$20
	
	.notBig
	
	STA $00
	
	LDA $96
	SEC : SBC !cluster_y_low,y
	CLC : ADC #$1C
	CMP $00	

	.noContact
	RTS
	
Speed:								; speed routine adapted from the original game's code ($02FF98 and $02FFA3)
	LDA !cluster_speed_y,y
	ASL #4
	CLC : ADC !cluster_speed_y_frac,y
	STA !cluster_speed_y_frac,y
	PHP
	LDA !cluster_speed_y,y
	LSR #4
	CMP #$08
	LDX #$00
	BCC +
	ORA #$F0
	DEX
	
	+
	PLP
	ADC !cluster_y_low,y
	STA !cluster_y_low,y
	TXA
	ADC !cluster_y_high,y
	STA !cluster_y_high,y
	
	LDA !cluster_speed_x,y
	ASL #4
	CLC : ADC !cluster_speed_x_frac,y
	STA !cluster_speed_x_frac,y
	PHP
	LDA !cluster_speed_x,y
	LSR #4
	CMP #$08
	LDX #$00
	BCC +
	ORA #$F0
	DEX
	
	+
	PLP
	ADC !cluster_x_low,y
	STA !cluster_x_low,y
	TXA
	ADC !cluster_x_high,y
	STA !cluster_x_high,y
	
	RTS

Graphics:
	LDY #$00
	JSR FindOAM							; rather than loading a fixed OAM slot based on sprite index, let's just find a free one
	
	LDA $00								; \ load screen position so the sprite can be drawn in the right spot
	STA $0200|!addr,y					; |
	LDA $02								; |
	STA $0201|!addr,y					; /
	
	PHY									; \ draw tile
	LDY $15E9|!addr						; |
	LDA !cluster_tile,y					; |
	PLY									; |
	STA $0202|!addr,y					; /
	
	PHY									; \ set props
	LDY $15E9|!addr						; |
	LDA !cluster_props,y				; |
	PLY									; |
	STA $0203|!addr,y					; /
	
	TYA
	LSR #2
	TAY
	
	LDA #$02							; \ set the size to 16x16
	STA $0420|!addr,y					; /
	
	RTS
	
FindOAM:
	LDA $0201|!addr,y					; \ load in OAM Y position
	CMP #$F0							; | if it's offscreen (empty)
	BEQ +								; | then we can use this as our index
	INY #4								; |
	BNE FindOAM							; | if we didn't loop from the entire $0200-$02FF area of OAM, then we can keep searching for empty slots
	LDY $15E9|!addr						; | restore cluster sprite index
	LDA #$00							; | since there's no available OAM slot (for some reason),
	STA !cluster_num,y					; | kill the sprite
	LDY #$00							; | and just use an index of 0 and hope nothing breaks
	+									; |
	RTS									; /