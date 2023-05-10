; Example code. Makes Mario neurodivergent.

main:
; Check if the game is paused or frozen due to animation and such.
	LDA $9D
    BNE Ret
; Check for the block's flag.
; Copypasting from the block, 7C is also used on HP system, be careful!
    LDA $7C             ;Not compatible with levels that use HP
    BEQ Ret             ;Timer counts down to zero, not into negatives
    DEC $7C             ;Decrement timer
    BNE Ret             ;Only modify jump speed the frame after jumping
; Check for the A and B input.
    LDA $15
    BPL Ret
; Add $1E (30) to the upwards Y speed.
; Note: The upwards Y speed goes from 80 to FF, which are essentially the negatives in this scenario.
; To put it short, it's the same as going ((0~127) - 30) repeatedly.
    LDA $7D
    CLC
    ADC #$1E
    STA $7D
; Reset flag.
Ret:
    RTL
