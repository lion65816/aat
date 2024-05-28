;overworld counters

!yicoinpos_x	= $1E
!yicoinpos_y	= $04

!coinpos_x	= $03
!coinpos_y	= $1B

!scorepos_x	= $18
!scorepos_y	= $1B

; set to 1 to include
!include_yicoin = 1
!include_coin = 0
!include_score = 0

; best if you dont touch these
function get_vram(x, y, layer) = (layer|((((y&$20)<<6)|((x&$20)<<5)))|(((y&$1f)<<5)|(x&$1f)))

lorom
!addr = $0000
!ram = $7E0000
!bank = $800000

if read1($00FFD6) == $15
sa1rom
!addr = $6000
!ram = $700000
!bank = $000000
elseif read1($00FFD5) == $23
sa1rom
!addr = $6000
!ram = $400000
!bank = $000000
endif

if or(!include_yicoin, or(!include_coin,!include_score))

freecode
owcount:
LDA $0D9B|!addr
LSR : BNE +
JML $0081F2|!bank
+
LDA $0100|!addr
CMP #$0D : BEQ +
LDA $13D9|!addr
CMP #$05 : BEQ +
CMP #$08 : BEQ +
BRA ++
+
if !include_yicoin
JSR OWYICoin
endif
if !include_coin
JSR OWCoin
endif
if !include_score
JSR OWScore
endif
++
JML $008222|!bank

if !include_yicoin
OWYICoin:
LDY $0DD6|!addr
LDA $1F17|!addr,y
LSR #4 : STA $00
LDA $1F19|!addr,y
AND #$F0
ORA $00 : STA $00
LDA $1F1A|!addr,y
ASL : ORA $1F18|!addr,y
LDY $0DB3|!addr
LDX $1F11|!addr,y
BEQ +
CLC : ADC #$04
+
STA $01

REP #$10
LDX $00
LDA $00D000|!ram,x
STA $02
SEP #$10

LDA #$FE : STA $00	;no yoshi coin tile (Layer 3)
LDA #$38 : STA $01	;no yoshi coin property byte (YXPCCCTT = 00100100, CCC = 001 for palette 1)
;LDA #$FF : STA $00	;no yoshi coin tile (Layer 3)
;LDA #$28 : STA $01	;no yoshi coin property byte

PHB : PHK : PLB
LDX.b #.endtable-.table-1
-
LDA $02
CMP .table,x
BEQ +
DEX : BPL -
LSR #3
TAY
LDA #$8C : STA $00	;empty yoshi coin tile (Layer 3)
LDA #$38 : STA $01	;empty yoshi coin property byte (YXPCCCTT = 00100100, CCC = 001 for palette 1)
;LDA #$78 : STA $00	;empty yoshi coin tile (Layer 3)
;LDA #$39 : STA $01	;empty yoshi coin property byte
LDA $02
AND #$07
TAX
LDA $1F2F|!addr,y
AND $05B35B|!bank,x
BEQ +
LDA #$8D : STA $00	;complete yoshi coin tile (Layer 3)
LDA #$38 : STA $01	;complete yoshi coin property byte (YXPCCCTT = 00100100, CCC = 001 for palette 1)
;LDA #$8E : STA $00	;complete yoshi coin tile (Layer 3)
;LDA #$28 : STA $01	;complete yoshi coin property byte
+
PLB

REP #$20
LDX #$80 : STX $2115
LDA.w #get_vram(!yicoinpos_x, !yicoinpos_y, $5000) : STA $2116
LDA $00 : STA $2118
SEP #$20
RTS

.table			;these are translevels that don't have yoshi coins
;levels $00-$24
db $00,$01,$03,$04,$05,$08,$0A,$0C,$0D,$0E
db $15,$18,$1C,$1D,$1F
;levels $101-$13B (values listed are levelnum-$DC)
db $101-$DC,$105-$DC,$108-$DC,$10D-$DC,$114-$DC,$117-$DC,$11A-$DC,$11B-$DC
db $122-$DC,$127-$DC,$12D-$DC,$12E-$DC
db $130-$DC,$13B-$DC
.endtable
endif

if !include_coin
OWCoin:
LDA #$8E : STA $00		;coin tile
LDA #$28 : STA $01		;coin prop
LDA #$8F : STA $02		;coin X
LDA #$38 : STA $03		;coin X prop
LDA #$39 : STA $05 : STA $07	;coin number prop

LDX $0DB3|!addr
LDA $0DB6|!addr,x
LDX $0DB2|!addr
BNE +
LDA $0DBF|!addr
+
LDX #$00
-
CMP #$0A
BCC +
SBC #$0A
INX
BRA -
+
CLC : ADC #$22
STA $06
TXA
CLC : ADC #$22
CMP #$22
BNE +
LDX $06
LDA #$1F
STA $06
TXA
+
STA $04
REP #$20
LDX #$80 : STX $2115
LDA.w #get_vram(!coinpos_x, !coinpos_y, $5000) : STA $2116
LDX #$00 : LDY #$03
-
LDA $00,x : STA $2118
INX #2 : DEY : BPL -
SEP #$20
RTS
endif


if !include_score
OWScore:
LDA #$1F : STA $00 : STA $02 : STA $04 : STA $06 : STA $08 : STA $0A
LDA #$39 : STA $01 : STA $03 : STA $05 : STA $07 : STA $09 : STA $0B	;properties of score

LDX $0DB3|!addr : BEQ +
LDX #$03
+
LDA $0F34|!addr,x
STA $0C
LDA $0F35|!addr,x
STA $0D
LDA $0F36|!addr,x
STA $0E
STZ $0F

LDX #$00
LDY #$00

PHA : PHA : PHA : PHA
-
SEP #$20
STZ $00,x
--
REP #$20
LDA $0C
SEC : SBC $8FFC,y
STA $03,s
LDA $0E
SBC $8FFA,y
STA $01,s
BCC +
LDA $03,s
STA $0C
LDA $01,s
STA $0E
SEP #$20
INC $00,x
BRA --
+
INX #2
INY #4
CPY #$18
BNE -
SEP #$20
PLA : PLA : PLA : PLA

LDA $00
BNE +
LDA #$1F		;leading 0 becomes empty space
+
STA $00

LDX #$00
-
LDA $02,x
TAY
BNE +
LDA $00,x
CMP #$1F		;same here
BNE +
LDY #$1F		;"
+
TYA
STA $02,x
INX #2 : CPX #$0A : BCC -

LDX #$0A
-
LDA $00,x
CMP #$1F		;"
BEQ +
CLC : ADC #$22
+
STA $00,x
DEX #2 : BPL -

LDA #$22 : STA $0C	;end zero tile
LDA #$39 : STA $0D	;end zero prop

REP #$20
LDX #$80 : STX $2115
LDA.w #get_vram(!scorepos_x, !scorepos_y, $5000) : STA $2116
LDX #$00 : LDY #$06
-
LDA $00,x : STA $2118
INX #2 : DEY : BPL -
SEP #$20
RTS
endif

org $0081EC
autoclean JML owcount

else

autoclean read3($0081EC+1)
org $0081EC
LDA $0D9B|!addr
LSR

endif


