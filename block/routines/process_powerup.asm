;===============================================================================
; PROCESS POWERUP
;===============================================================================

; Process Powerup (or 1-up) block as if it were a sprite.
; If there is collision with the player, this routine spwans the score sprite.
; Input A (8-bit): Score sprite number.
; Output C: 1 if there is collision, 0 otherwise.


;-------------------------------------------------------------------------------
; Setup
;-------------------------------------------------------------------------------

    XBA                             ;> Preserve score sprite number


;-------------------------------------------------------------------------------
; Collision
;-------------------------------------------------------------------------------

    ; Player clippling
    JSL $03B664

    ; "Sprite" clipping
    LDA $9A : AND #$F0              ;\
    CLC : ADC #$02 : STA $04        ;| X position
    LDA $9B : ADC #$00 : STA $0A    ;/
    LDA $98 : AND #$F0              ;\
    CLC : ADC #$03 : STA $05        ;| Y position
    LDA $99 : ADC #$00 : STA $0B    ;/
    LDA #$0C : STA $06              ;> Width
    LDA #$0A : STA $07              ;> Height

    ; Check collision
    JSL $03B72B|!bank : BCS ?+      ;> If no collision
    RTL                             ;> Then return


;-------------------------------------------------------------------------------
; Spawn Score Sprite
;-------------------------------------------------------------------------------

    ; Find free slot
?+  LDX #$05                        ;> X = score sprite slot
-   LDA $16E1|!addr,x               ;\ If slot is free
    BEQ ?+                          ;| Then return with X as the available index
    DEX : BPL -                     ;/ Else loop until no more available slots

    ; No free slot, replace oldest
    DEC $18F7|!addr                 ;> Index to replace the oldest score sprite
    BPL ?++                         ;\ If index is negative
    LDA #$05 : STA $18F7|!addr      ;/ Then reset the index count
?++ LDX $18F7|!addr                 ;> Use the index count

    ; Instantiate score sprite
?+  XBA : STA $16E1|!addr,x         ;> Set score sprite number
    LDA #$30 : STA $16FF|!addr,x    ;> Set score sprite speed


;-------------------------------------------------------------------------------
; Position Score Sprite
;-------------------------------------------------------------------------------

    LDA $9A : AND #$F0              ;\
    STA $16ED|!addr,x               ;| X position
    LDA $9B : STA $16F3|!addr,x	    ;/
    LDA $98 : AND #$F0              ;\
    SEC : SBC #$08                  ;| Y position (low byte)
    STA $16E7|!addr,x               ;/
    XBA : LDA $99                   ;\
    SBC #$00                        ;| Y position (high byte)
    STA $16F9|!addr,x : XBA         ;/

    SEC : SBC $1C                   ;\ If not past the top of the screen
    CMP #$F0 : BCC ?+               ;/ Then don't move it downwards

    LDA $16E7|!addr,x               ;\
    ADC #$10                        ;| Move score sprite downwards if it's
    STA $16E7|!addr,x               ;| offscreen vertically
    LDA $16F9|!addr,x               ;| (note that we don't reset the carry flag
    ADC #$00                        ;| before the first addition on purpose)
    STA $16F9|!addr,x               ;/

?+  SEC : RTL                       ;> Return, marking collision happened
