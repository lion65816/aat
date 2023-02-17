; Example code. Makes Mario crazy.

init:
    JSR NuRando
    LDA $00
    AND #$01
    PHY
    TAY
    LDA Music,y
    STA $1DFB|!addr 
    PLY
    RTL
    
Music:
    db $8C,$8D
    
;below code by wiiqwertyuiop

NuRando:
  REP #$20
  TSC
  CMP #$3700
  BCS .SA1
; If you know you will be coming here from the SNES side, you can make Accumulator 16-bit, and then jump here to save some time
  LDA $2137		;\ PPU registers
  LDA $213C   ;/
  BRA +
.SA1
; Same thing here if you know you will be coming from the SA-1 side
  LDA $2302
+
  ADC $13
  ADC $00   ; 36
  ADC $14
  XBA
  STA $00
  SEP #$20
  RTS
