;===============================================================;
; Teleport on level end UberASM by KevinM                       ;
;                                                               ;
; This code will teleport the player when the level ends,       ;
; based on the current screen exit.                             ;
;                                                               ;
; It works for goal tapes, orbs, normal bosses and, thanks      ;
; to some magic, also mode 7 bosses like Reznor or Iggy.        ;
; In bosses that span multiple screens (including, for example, ;
; Ludwig) make sure the exit is set on all possible screens!    ;
; It also works for switch palaces, but the teleport will be    ;
; instantaneous even if using !TeleportType = 1.                ;
; It doesn't work for keyholes or inside the bonus game.        ;
;                                                               ;
; There's also an option to skip or not the bonus game, in case ;
; beating the current level gives you enough bonus coins.       ;
;===============================================================;

; 0 = teleport as soon as the level ends
; 1 = teleport only after the level end scorecard has ended
!TeleportType = 1

; 0 = if getting 100 bonus stars, you'll go to the bonus game and then to the overworld
; 1 = if getting 100 bonus stars, you'll be teleported anyway
!SkipBonusGame = 1

load:
	JSL NoStatus_load
RTL

init:
    ; Code adapted from $0583B8 and $0585FF
    lda $1925|!addr     ;\
    cmp #$09            ;|
    beq +               ;|
    cmp #$0B            ;| If not a special boss level mode, return.
    beq +               ;|
    cmp #$10            ;|
    beq +               ;|
    rtl                 ;/
+   rep #$30            ;\
    lda $010B|!addr     ;|
    asl                 ;|
    clc                 ;|
    adc $010B|!addr     ;|
    tax                 ;| Load layer 1 pointer in $65-$67
    lda.l $05E000,x     ;| (add 5 to skip the header)
    clc                 ;|
    adc #$0005          ;|
    sta $65             ;|
    lda.l $05E001,x     ;|
    adc #$0000          ;|
    sta $66             ;/
-   sep #$30            ;\
    ldy #$00            ;|
    lda [$65],y         ;|
    sta $0A             ;|
    iny                 ;|
    lda [$65],y         ;|
    sta $0B             ;|
    iny                 ;|
    lda [$65],y         ;|
    sta $59             ;|
    iny                 ;|
    tya                 ;| Load current object data.
    clc                 ;|
    adc $65             ;|
    sta $65             ;|
    lda $66             ;|
    adc #$00            ;|
    sta $66             ;|
    lda $0B             ;|
    lsr #4              ;|
    sta $5A             ;|
    lda $0A             ;|
    and #$60            ;|
    lsr                 ;|
    ora $5A             ;|
;   sta $5A             ;/
;   lda $5A             ;\ If not an extended object
    ora $59             ;| or extended object number is not $00 (screen exit)
    bne +               ;/ skip.
; Screen exit object code adapted and optimized from $0DA512
    lda $0A             ;\
    and #$1F            ;|
    tax                 ;| Store screen exit data.
    lda [$65]           ;|
    sta $19B8|!addr,x   ;|
    lda $0B             ;|\
    and #$0F            ;||
    sta $19D8|!addr,x   ;|| Use LM modified exit system.
    and #$02            ;||
    lsr                 ;||
    sta $1B93|!addr     ;//
    rep #$20            ;\
    inc $65             ;| Go to the next object.
    sep #$20            ;/
+   lda [$65]           ;\
    cmp #$FF            ;| If not finished loading, loop back.
    bne -               ;/
    rtl

main:
    JSL freezetimer_main
    LDA #%00100000 : STA $00
    LDA #%00000000 : STA $01
    JSL DisableButton_main
    lda $1434|!addr     ;\ If the level isn't ending, return.
    beq .return         ;/
if !TeleportType == 1
    cmp #$18            ;\ If it's too soon, return.
    bcs .return         ;/
endif
if !SkipBonusGame
    stz $1425|!addr     ; Cancel bonus game.
else
    lda $1425|!addr     ;\ If supposed to go to the bonus game, return.
    bne .return         ;/
endif
    stz $0DDA|!addr     ; Reset music backup so music plays on the next level.
    stz $13C6|!addr     ; Reset cutscene.
    stz $13D2|!addr     ; Reset pressed switch flag.
    lda #$50            ;\ Reset drumroll wait timer.
    stz $13D6|!addr     ;/
    stz $1424|!addr     ; Reset show bonus stars flag.
    stz $1433|!addr     ; Reset windowing scaling factor.
    stz $1492|!addr     ; Reset peace image timer.
    stz $1493|!addr     ; Reset the level end timer.
    stz $1494|!addr     ; Reset direction of color fading.
    stz $1495|!addr     ; Reset timer of color fading.
    stz $1B99|!addr     ; Reset goal march flag.
    stz $1434|!addr     ; Reset Keyhole
    stz $36             ;\
    stz $37             ;|
    lda #$20            ;| Reset mode 7 parameters.
    sta $38             ;|
    stz $39             ;/
    lda $13D9|!addr		;\
    cmp #$03			;| If march is still going, interrupt the drumroll.
    bcs +				;| (you won't get the remaining points and bonus stars)
    lda #$12			;|
    sta $1DFC|!addr		;/
+   stz $88             ;\
    stz $89             ;| Activate teleport.
    lda #$06            ;|
    sta $71             ;/
    lda #$00
    sta $7FB000
    sta $1DFB|!addr
.return
	rtl
