load:
	JSL FilterYoshi_load
	RTL

init:
	;JSL FilterFireCape_init
	JSL freescrollbabey_init
	RTL

main:
	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main

	LDA $97			; mario y (high (next frame))
	BPL CEILING_RETURN	; if not negative, return
	LDY #$00		; load 0 in to Y 
	LDA $19			; powerup
	BEQ CEILING_2		; if small, check for ceiling height as small mario
	LDA $73			; same if ducking
	BNE CEILING_2		; 
	LDY #$01		; otherwise check as big
CEILING_2:
	LDA.w CEILING_TABLE,y	; if not yet above ceiling threshold...
	CMP $96			; mario y (low)
	BCC CEILING_RETURN	; return
	INC A			; 
	STA $96			; place mario on top of screen
	LDA $7D			; 
	EOR #$FF		; Flip mario y speed
	INC A			;
	CMP #$10		; cap downward speed at 10
	BCC CEILING_1		;
	LDA #$10
CEILING_1:
	STA $7D			; set speed

	LDA #$01		; play "hit head" sound effect
	STA $1DF9|!addr		;

CEILING_RETURN:
	RTL			; reutrn

CEILING_TABLE:
	db $E8,$F0		; how high above the screen mario can go for small and big mario
	RTL
