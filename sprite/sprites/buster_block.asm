;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SMB3 Buster Beetle's Block
; Coded by SMWEdit
;
; Uses first extra bit: NO
;
; NOTE: use this sprite in conjunction w/ buster beetle, don't just insert it into a level, it will glitch
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
    LDA #$0A            ; \ make it an
    STA !14C8,x         ; / activated shell
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    JSR SpriteCode
    PLB
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Dying:
    LDA #$53                ; \ dies like
    STA !9E,x               ; / a throwblock
    RTS

SpriteCode:
    JSR Graphics
    LDA !14C8,x             ; \  Return if
    CMP #$02                ;  | sprite status
    BEQ Dying               ;  | is < 8, or
    CMP #$08                ;  | branch to death
    BCC Return              ; /  handler if Dying
    LDA $9D                 ; \ Return if
    BNE Return              ; / sprites locked
    LDA #$00
    %SubOffScreen()         ; only process sprite while on screen

    LDA #$0A                ; \ make it an
    STA !14C8,x             ; / activated shell

    LDA !1588,x             ; \  if not hitting
    AND #%00000011          ;  | wall, then skip
    BEQ Return              ; /  this next code
    LDA #$02                ; \ make sprite
    STA !14C8,x             ; / start Dying
Return:
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Graphics:
    %GetDrawInfo()
    LDA #$F0                    ; \ kill that annoying tile used
    STA $0309|!Base2,y          ; / for original shell tilemaps
    LDA $00                     ; \ Xpos
    STA $0300|!Base2,y          ; /
    LDA $01                     ; \ Ypos
    STA $0301|!Base2,y          ; /
    LDA #$40                    ; \ tile
    STA $0302|!Base2,y          ; / number
    LDA $13                     ; \ 
    AND #%00000111              ;  | cycle through palettes
    ASL A                       ; /
    ORA $64                     ; add in priority bits
    STA $0303|!Base2,y          ; set properties
    LDY #$02                    ; #$02 means the tiles are 16x16
    LDA #$00                    ; #$00 means one tile drawn
    JSL $01B7B3|!BankB          ; don't draw if offscreen, set tile size
    RTS
