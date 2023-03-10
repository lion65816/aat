;=======================================================
; Cheep Cheep Dolphin Thing
; By Erik557
;=======================================================
; Description: A cheep-cheep that follows a pattern
; similar to an original game dolphin.
; Uses first extra bit: YES
; When clear, the fish will act like a vertical dolphin.
; Else, it will act like an horizontal one.
;=======================================================

Tilemap:
       db $67,$69
XSpeeds:
       db $E8,$18

;=================================
; INIT and MAIN Wrappers
;=================================

print "MAIN ",pc
       PHB
       PHK
       PLB
       JSR CheepCheep
       PLB
print "INIT ",pc
       RTL

;========================
; Main routine
;========================

CheepCheep:
       JSR Graphics
       LDA !14C8,x
       CMP #$08
       BNE .return
       LDA $9D
       BNE .return
       LDY #$02
       %SubOffScreen()
       JSL $01801A
       JSL $018022
       LDA !AA,x
       BMI +
       CMP #$3F
       BCS .dontIncSpeed
+      INC !AA,x
.dontIncSpeed
       TXA
       EOR $13
       LSR
       BCC +
       JSL $019138
+      LDA !AA,x
       BMI .dontSetSpeed
       LDA !164A,x
       BEQ .dontSetSpeed
       LDA !AA,x
       BEQ .dontZeroSpeed
       SEC
       SBC #$08
       STA !AA,x
       BPL .dontZeroSpeed
       STZ !AA,x
.dontZeroSpeed
       LDA !7FAB10,x
       AND #$04
       BEQ .dontSetX
       LDA !AA,x
       BNE .dontSetSpeed
       LDA !C2,x
       AND #$01
       TAY
       LDA XSpeeds,y
       STA !B6,x
.dontSetX
       INC !C2,x
       LDA #$C0
       STA !AA,x
.dontSetSpeed
       LDA !C2,x
       AND #$01
       STA !157C,x
.interRet
       JSL $01A7DC
.return
       RTS

;========================
; Graphics routine
;========================

Graphics:
       %GetDrawInfo()
       LDA !157C,x
       STA $02
       REP #$20
       LDA $00
       STA $0300|!Base2,y
       SEP #$20
       LDA $14
       LSR #3
       AND #$01
       TAX
       LDA Tilemap,x
       STA $0302|!Base2,y
       LDX $02
       LDA Props,x
       LDX $15E9|!Base2
       ORA !15F6,x
       ORA $64
       STA $0303|!Base2,y
       LDY #$02
       TDC
       JSL $01B7B3
       RTS

Props:
       db $40,$00
	   