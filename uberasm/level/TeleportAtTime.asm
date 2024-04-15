; teleport_on_no_time.asm
;
; this code will teleport the player to the specified level
;	when the timer hits a certain value (default is 001)
;	(000 will work, but it'll also kill the player)
;
; note: this is subject to what I believe is a bug in Vanilla, and hopefully
;       not a bug with the code. When teleported from the original level, if
;		you get a midway in this new level and then die, reentering the level
;		from the overworld will bring you to the midway point of the original
;		level instead of the new level.
;
; 		Example: 
;			- teleport from level 105 -> 103
;			- get midway of 103
;			- die, reenter from overworld
;			- midway collected flag will be set in 105
;		this could probably be fixed with custom midway points, but idk


; defines
!level		= $0103	; the level we'll teleport to
!secondary	= 0		; is it a secondary exit? 0 = false, 1 = true
!water		= 0		; if secondary exit, water level? 0 = false, 1 = true

!time_high  = $00	; the hundreds place of the time value to teleport at
!time_mid	= $00	; the tens place of the time value to teleport at
!time_low	= $01	; the ones place of the time value to teleport at

load:
	JSL NoStatus_load
RTL

main:
	LDA #%00111111 : STA $00
	LDA #%10110000 : STA $01
	JSL DisableButton_main
	; check timer value
	LDA $0F31|!addr
	CMP #!time_high
	BNE return
	LDA $0F32|!addr
	CMP #!time_mid
	BNE return
	LDA $0F33|!addr
	CMP #!time_low
	BNE return

	stz $88             ;\
	stz $89             ;| Activate teleport.
	lda #$06            ;|
	sta $71             ;/
	;lda #$00
	;sta $7FB000
	;sta $1DFB|!addr	
	return:
	RTL
