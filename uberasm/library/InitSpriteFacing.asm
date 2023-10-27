!FixBill = 1		; If set, the facing fix will apply to the Bullet Bill.
!FixSpikeTop = 1	; If set, the facing fix will apply to the Spike Top.

if !sa1
!dbr = $01
else
!dbr = $81
endif
; --------------------

init:

if !sa1

LDA.b #InitSpriteFacing			;/
STA $3180						;|
LDA.b #InitSpriteFacing>>8		;|
STA $3181						;| If the ROM uses SA-1, make the code actually run on the SA-1 chip.
LDA.b #InitSpriteFacing>>16		;|
STA $3182						;|
JSR $1E80						;\
RTL

InitSpriteFacing:

endif

LDX #!sprite_slots-1
.loop

LDA !9E,x		; Skip various sprites that shouldn't face Mario and/or don't use $157C to determine horizontal direction.
CMP #$29		; Skip Koopa Kids.
BEQ .next
CMP #$82		; Skip Bonus Game sprites.
BEQ .next
CMP #$A0		; Skip Bowser.
BEQ .next
CMP #$B1		; Skip creating/eating blocks.
BEQ .next
CMP #$B9		; Skip Info Box.
BEQ .next
CMP #$C1		; Skip flying grey turnblocks.
BEQ .next

LDY #$00		;/
LDA $94			;|
SEC				;|
SBC !E4,x		;|
LDA $95			;| Get which side of the sprite Mario is on.
SBC !14E0,x		;|
BPL +			;|
INY				;\
+

if !FixBill
LDA !9E,x		;/
CMP #$1C		;|
BNE .notbill	;|
TYA				;| Set the Bullet Bill's direction in $C2.
STA !C2,x		;|
BRA .next		;|
.notbill		;\
endif

if !FixSpikeTop
LDA !9E,x
CMP #$2E
BNE .notspiketop
PEA.w !dbr|(.next>>16<<8)		;/ Spike Top's facing routine does some funky stuff so let's just run it's init code again with a JSLtoRTS.
PLB								;|
PEA.w .next-1					;|
PEA.w $90B8						;|
JML $0183F5|!bank				;\ The Spike Top's init code starts with a JSR to SubHorzPos but we already did that, so let's skip that part of the routine.
.notspiketop
endif

TYA				;/
STA !157C,x		;\ For most sprites, $157C determines the direction the sprite is facing.

.next
DEX				;/
BPL .loop		;\ Loop through all sprite slots.
RTL