;Locus of Control
;Lord Ruby

;SA-1

;;Defines
;Direct page address for the jump ability timer.
!timer = $58

;;Code
load:
    JSL MinStatus_load
RTL

init:
    LDA #$C3 : STA !timer   ;Initialize timer to one second of no jumping.
RTL

main:
    ;If I want to add more code, like HDMA or something, do it before the timer code.

    ;Jump ability timer
    LDA !timer         ;o:nz;Timer checks:
    BMI NoJump         ;i:n ;Negative, jumping is disabled.
    BEQ RollNegative   ;i: z;Zero, disable jump and reset timer.
    DEC : STA !timer        ;Else, just decrement timer.
RTL

RollNegative:
    JSL $01ACF9 : LDA $748D         ;Get random number ($148D).
    EOR $94     : ADC $14           ;Add random-ish noise (X position and timer).
    ORA #$80    : AND #%11101111    ;Restrict to roughly -2 to -0.25 seconds (with gaps).
    STA !timer                      ;Store timer.
RTL

NoJump:
    INC                         ;o:z;Increment timer.
    BNE +                       ;i:z;If not zero, skip to storing it and disabling jump.
    ;Roll a positive number.
    JSL $01ACF9 : LDA $748D         ;Get random number ($148D).
    EOR $94     : ADC $14           ;Add random-ish noise (X position and timer).
    LSR         : ORA #%00100000    ;Restrict to roughly 0.5-1 or 1.5-2 seconds.
+   STA !timer                      ;Store timer.

    ;Disable jump. Note that this only disables "newly pressed" status, not held.
    LDA #$80 : TRB $16 : TRB $18    ;Disable the highest bit (B, A, respectively).
RTL


