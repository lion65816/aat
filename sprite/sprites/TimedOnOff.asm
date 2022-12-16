; --------------------- ;
;  Timed ON/OFF Switch  ;
;      by JamesD28      ;
; --------------------- ;

; Extra byte 1: Timer before the switch reverts back.

; Extra byte 2: Behaviours. Format: !---mmmm
	; !: If set, the switch will display a "!" symbol shortly before reverting.
	; m: Multiplier for extra byte 1, up to 16x. Also affects how long the "!" symbol shows for if enabled.

; --------------------- ;

print "MAIN ",pc

PHB
PHK
PLB
JSR OnOffMain
PLB
RTL

OnOffMain:

JSR Graphics

LDA !1540,x
BNE +
LDA !C2,x
BEQ +
STZ !C2,x
LDA $14AF|!addr
EOR #$01
STA $14AF|!addr
LDA #$0B
STA $1DF9|!addr
+

LDA !extra_byte_2,x
BEQ +
LDA !1540,x
BEQ +
LDA !1510,x
BEQ ++
INC !1540,x
DEC !1510,x
BRA +
++
LDA !extra_byte_2,x
AND #$0F
STA !1510,x
+

LDA !1558,x
BNE .Return
LDA !9E,x
PHA
LDA #$B9
STA !9E,x
LDA !14D4,x
PHA
LDA !D8,x
PHA
SEC
SBC #$01
STA !D8,x
LDA !14D4,x
SBC #$00
STA !14D4,x
JSL $01B44F|!BankB
PLA
STA !D8,x
PLA
STA !14D4,x
PLA
STA !9E,x
LDA !C2,x
BEQ +
LDA !1540,x
BNE +
LDA #$0B
STA $1DF9|!addr
LDA !extra_byte_1,x
STA !1540,x
LDA $14AF|!addr
EOR #$01
STA $14AF|!addr
+

.Return
RTS

; --------------------- ;

Graphics:

%GetDrawInfo()

LDA !1558,x
STA $02
LDA !1540,x
STA $03
LDA !extra_byte_2,x
PHP

LDA $00
STA $0300|!addr,y
LDA !1558,x
TAX
LDA $01
SEC
SBC .BounceOffsets,x
STA $0301|!addr,y

LDA $02
BEQ +
LDA #$48
BRA ++
+
LDX $14AF|!addr
LDA.w .SwitchStatus,x
++
STA $0302|!addr,y

LDA #$0F
ORA $64
STA $0303|!addr,y

STZ $04
PLP
BPL +
LDA $03
BEQ +
CMP #$30
BCS +
LDA #$01
STA $04
PHY
TYA
LSR #2
TAY
LDA #$02
STA $0460|!addr,y
PLY

INY #4
LDA $00
CLC
ADC #$04
STA $0300|!addr,y

LDA $01
SEC
SBC #$0C
STA $0301|!addr,y

LDA #$1D
STA $0302|!addr,y

LDA #$08
ORA $64
STA $0303|!addr,y

PHY
TYA
LSR #2
TAY
LDA #$00
STA $0460|!addr,y
PLY
+

LDY #$02
LDA #$00
LDA $04
BEQ +
LDY #$FF
LDA #$01
+
LDX $15E9|!addr
JSL $01B7B3|!BankB

RTS

.SwitchStatus
db $08,$6D

.BounceOffsets
db $01,$02,$03,$04,$05,$06,$07,$08
db $09,$07,$06,$05,$04,$03,$02,$01