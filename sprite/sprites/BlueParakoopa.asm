;=============================================================
; Blue Parakoopa
; Description: A parakoopa that flies on a circular style.
;
; Uses first extra bit: YES
; If the extra bit is clear, the sprite will rotate clockwise,
; and if it's set, it will rotate counterclockwise.
;=============================================================
; By Erik557
; Based on Alcaro's works, though I used none of his code.
;=============================================================

       !Radius = $20        ; radius of the circle

;=================================
; INIT and MAIN Wrappers
;=================================
; $C2	xlow	those 4 tables will be used to preserve location
; $1504	xhigh
; $1510	ylow
; $160E	yhigh
print "INIT ",pc
       JSL $01ACF9          ;\ Get starting frame
       STA !1570,x          ;/
       %SubHorzPos()      ;\
       TYA                  ; | Face player
       STA !157C,x          ;/

       LDA #!Radius         ;\ set ball n' chain radius
       STA !1594,x          ;/
       STZ !151C,x          ;\ $151C is the high byte
       STZ !1FD6,x          ;/ $1FD6 is the low byte
	LDA #$FF
       	STA !C2,x
       	STA !1504,x
       	STA !1510,x
       	STA !160E,x
RTL

print "MAIN ",pc
       PHB : PHK : PLB      ; set data bank
       JSR Override
       LDA !14C8,x
       CMP #$07
       BEQ YoshiSwallow
       JSR BlueParatroopa   ; Main Routine
       PLB                  ; restore
RTL

;========================
; Main routine
;========================
Override:
	LDY #$01	; number of states to override -1
	LDA !14C8,x
-
	CMP .states,y
	BEQ .override
	DEY
	BPL -
	LDA !7FAB34,x
	AND #$7F
	STA !7FAB34,x
	RTS
.states			; statuses to override (including 08)
	db $07,$08
.override
	LDA !7FAB34,x
	ORA #$80
	STA !7FAB34,x
	RTS
YoshiSwallow:
	LDA #$06
           STA !9E,x
	JSL $07F7D2
	LDA #$07
           STA !14C8,x
	PLB
	RTL
DrawGFX:                    ;\ Draw the sprite
       PHB                  ; |\
       LDA #$01             ; | | set data bank to 01
       PHA                  ; | |
       PLB                  ; |/
       PHK                  ; |\
       PEA.w .drawn-1       ; | | jsl to 018bc3
       PEA.w $0180CA-1      ; | |
       JML $018BC3          ; |/
.drawn                      ;/
       PLB                  ; restore data bank
       RTS                  ; return

BlueParatroopa:
       LDA #$00
       %SubOffScreen()
       LDA $9D
       BNE .LockedSprites

.NotTurning
       INC !1570,x          ;\
       LDA !1570,x          ; |
       LSR #3               ; | set animation frame
       AND #$01             ; |
       STA !1602,x          ;/

       LDA $14
       AND #$01
       BNE .LockedSprites

       LDA !7FAB10,x        ;\ use extra bits to determine direction of rotation
       LDY #$04             ; | (original uses sprite x position)
       AND #$04             ; |
       BNE .CounterClock    ; |
       LDY #$FC             ; |
.CounterClock               ; |
       TYA                  ; |
       LDY #$00             ; |
       CMP #$00             ; |
       BPL +                ; |
       DEY                  ;/
+      CLC                  ;\ update angle depending on direction of rotation
       ADC !1FD6,x          ; | $1602,x is used to store the low byte of the ball n' chain angle
       STA !1FD6,x          ; |
       TYA                  ; |
       ADC !151C,x          ; | and $151C,x for the high byte
       AND #$01             ; |
       STA !151C,x          ; |
.LockedSprites
       LDA !151C,x          ; |
       STA $01              ; | $00-$01 = ball n' chain angle
       LDA !1FD6,x          ; |
       STA $00              ;/

       REP #$30             ; set 16-bit mode for accumulator and registers

       LDA $00              ;\ $02-$03 = ball n' chain angle + 90 degrees
       CLC                  ; |
       ADC #$0080           ; |
       AND #$01FF           ; |
       STA $02              ;/

       LDA $00              ;\ $04-$05 = cosines of ball n' chain angle
       AND #$00FF           ; |
       ASL                  ; |
       TAX                  ; |
       LDA $07F7DB,x        ; | this is SMW's trigonometry table
       STA $04              ;/

       LDA $02              ;\ $06-$07 = cosines of ball n' chain angle + 90 degrees = sines for ball n' chain angle
       AND #$00FF           ; |
       ASL                  ; |
       TAX                  ; |
       LDA $07F7DB,x        ; |
       STA $06              ;/

       SEP #$30             ; set 8-bit mode for accumulator and registers

       LDX $15E9|!Base2            ; get sprite index
       PHA
       XBA
       BEQ .NotFlip

       LDA !15AC,x          ;\ don't turn is this is already set
       BNE .NotFlip         ;/
       LDA #$08             
       STA !15AC,x
       LDA !157C,x
       EOR #$01
       STA !157C,x

.NotFlip
       if !SA1
       STZ $2250
       endif
       PLA
       LDA $04              ;\ multiply the cosine...
       if !SA1
       STA $2251
       STZ $2252
       else
       STA $4202
       endif
       LDA !1594,x          ; | 
       LDY $05              ; |\ if $05 is 1, no need to do the multiplication
       BNE .NoMultCos       ; |/
       if !SA1
       STA $2253
       STZ $2254
       NOP : BRA $00
       ASL $2306
       LDA $2307
       else
       STA $4203            ; | ...with radius of circle ($1594,x)
       NOP #4
       ASL $4216
       LDA $4217
       endif
       ADC #$00       
.NoMultCos
       LSR $01              ;\ if the high byte of the angle was set...
       BCC .NotInvertCos    ; |
       EOR #$FF             ; | ...then invert the cosine
       INC                  ;/
.NotInvertCos
       STA $04
       if !SA1
       STZ $2250
       endif
       LDA $06              ;\ multiply the sine...
       if !SA1
       STA $2251
       STZ $2252
       else
       STA $4202
       endif
       LDA !1594,x          ; |
       LDY $07              ; |\ if $07 is 1, no need to do the multiplication
       BNE .NoMultSin       ; |/
       if !SA1
       STA $2253
       STZ $2254
       NOP : BRA $00
       ASL $2306
       LDA $2307
       else
       STA $4203            ; | ...with radius of circle ($1594,x)
       NOP #4
       ASL $4216
       LDA $4217
       endif
       ADC #$00       
.NoMultSin
       LSR $03              ;\ if the high byte of the angle was set...
       BCC .NotInvertSin    ; |
       EOR #$FF             ; | ...then invert the sine
       INC                  ;/            
.NotInvertSin
       STA $06              

	LDA !15D0,x	; Am I being eaten?
	BEQ .NotEaten
	JSR DrawGFX          ; GFX routine
	RTS
.NotEaten

;;;START CIRCLE
	; at first, primary will hold center, and seconary will hold #$FF.
	; but after then, primary will hold tangential, and secondary will hold center.
	; here will assign the primary = secondary;
; $E4 = $C2	xlow	those 4 tables will be used to preserve location
; $14E0 = $1504	xhigh
; $D8 = $1510	ylow
; $14D4 $160E	yhigh
	LDA !C2,x
	AND !1504,x
	AND !1510,x
	AND !160E,x
	CMP #$FF
	BEQ .DontUseSecondary

	LDA !1504,x          ;\ Primary location will hold center.
	STA !14E0,x                 ; |
	LDA !C2,x            ; |
	STA !E4,x                 ; |
	LDA !160E,x          ; |
	STA !14D4,x                 ; |
	LDA !1510,x             ; |
	STA !D8,x                ;/
	BRA .StartCircle
.DontUseSecondary
       LDA !14E0,x          ;\  Now Secondary location will hold center.
       STA !1504,x                 ; |
       LDA !E4,x            ; |
       STA !C2,x                 ; |
       LDA !14D4,x          ; |
       STA !160E,x                 ; |
       LDA !D8,x            ; |
       STA !1510,x                 ;/
.StartCircle
       STZ $00              ;\
       LDA $04              ; |   x offset low byte
       BPL +                ; |
       DEC $00              ; |
+      CLC                  ; |
       ADC !E4,x            ; | + x position of rotation center low byte
       STA !E4,x            ;/  = sprite x position low byte

       PHP                  ;\
       PHA                  ; |
       SEC                  ; |
       SBC !1534,x          ; |
       STA !1528,x          ; |
       PLA                  ; |
       STA !1534,x          ; |
       PLP                  ;/

       LDA !14E0,x          ;\    x position of rotation center high byte
       ADC $00              ; | + adjustment for screen boundaries
       STA !14E0,x          ;/  = x position of sprite high byte

       STZ $01              ;\
       LDA $06              ; |   y offset low byte
       BPL +                ; |
       DEC $01              ; |
+      CLC                  ; |
       ADC !D8,x            ; | + y position of rotation center low byte
       STA !D8,x            ;/  = sprite y position low byte

       LDA !14D4,x          ;\    y position of center of rotation high byte
       ADC $01              ; | + adjustment for screen boundaries
       STA !14D4,x          ;/  = sprite y position high byte

       JSR DrawGFX          ; GFX routine
       JSL $018032          ; interact with sprites

       JSL $01A7DC          ;\
       BCS .Int             ; | interact with mario
-      JMP .ReturnInteract  ;/ if not in contact, return

.Int
       LDA $9D
       ORA !154C,x
       BNE -

       LDA $1490|!Base2
       BEQ +
       JMP .Star

+      JSR CapeCollision    ;\  im pretty sure this isn't needed
	BNE .Cape            ;/  but im leaving it just to not break shit

       LDA #$14
       STA $01
       LDA $05
       SEC
       SBC $01
       ROL $00
       CMP $D3
       PHP
       LSR $00
       LDA $0B
       SBC #$00
       PLP
       SBC $D4
       BPL +
       JMP .PreHurt

+      LDA $7D
       BPL +
       LDA $1697|!Base2
       BNE +
       JMP .PreHurt
+      JSL $01AB99
       JSR GivePoints

       LDA $140D|!Base2
       ORA $187A|!Base2
       BEQ +
       JMP .SpinKill

+      JSL $01AA33
       LDA #$06
       STA !9E,x
       LDA !15F6,x
       AND #$0E
       STA $0D
       JSL $07F7D2
       LDA !15F6,x
       AND #$F1
       ORA $0D
       STA !15F6,x
       STZ !AA,x
       RTS

.Cape
       LDA $0E
       CMP #$35
       BEQ +
       JSL $01AB6F

+      LDA #$00
       JSL $02ACE5
       LDA #$09
       STA !14C8,x
       ASL !15F6,x
       SEC
       ROR !15F6,x
       LDA #$06
       STA !9E,x
       JSL $07F7D2

       LDA #$FF
       STA !1540,x
       STZ !1558,x
       LDA #$C0
       LDY $0E
       BEQ +
       LDA #$B0
       CPY #$02
       BNE +
       LDA #$C0
+      STA !AA,x

       %SubHorzPos()
       LDA StunSpeeds,y
       STA !B6,x
       TYA
       EOR #$01
       STA !157C,x
       BRA .ReturnInteract

.PreHurt
       LDA $13ED|!Base2
       BNE .Star
       LDA $187A|!Base2
       BNE .ReturnInteract
       JSL $00F5B7
       LDX $15E9|!Base2
       %SubHorzPos()
       TYA
       STA !157C,x
       RTS

.SpinKill
       LDA #$04
       STA !14C8,x
       LDA #$08
       STA $1DF9|!Base2
       JSL $07FC3B
       LDA #$F8
       STA $7D
       STA !154C,x
	LDA $187A|!addr
	BEQ +
	JSL $01AA33|!bank
+
.ReturnInteract
       LDX $15E9|!Base2
       RTS                  ; return
;;; END CIRCLE
.Star
       JSL $01AB6F
       INC $18D2|!Base2
       LDA $18D2|!Base2
       CMP #$08
       BCC +
       LDA #$08
       STA $18D2|!Base2
+      JSL $02ACE5
       LDY $18D2|!Base2
       CPY #$08
       BCS +
       LDA KillSFX,y
       STA $1DF9|!Base2
+      LDA #$02
       STA !14C8,x
       LDA #$D0
       STA !AA,x
       %SubHorzPos()
       LDA KillSpeeds,y
       STA !B6,x
       LDA #$04
       STA !9E,x
       RTS

KillSFX:
       db $00,$13,$14,$15,$16,$17,$18,$19
KillSpeeds:
       db $F0,$10
StunSpeeds:
       db $F8,$08

;==================
  CapeCollision:
;==================

       LDA $13E8|!Base2
       BEQ .NoContact
       LDA !15D0,x
       ORA !1FE2,x
       BNE .NoContact
       LDA !1632,x
       PHY
       LDY $74
       BEQ +
       EOR #$01
+      PLY
       EOR $13F9|!Base2
       BNE .NoContact
       JSL $03B69F
       LDA $13E9|!Base2
       SEC
       SBC #$02
       STA $00
       LDA $13EA|!Base2
       SBC #$00
       STA $08
       LDA #$14
       STA $02
       LDA $13EB|!Base2
       STA $01
       LDA $13EC|!Base2
       STA $09
       LDA #$10
       STA $03
       JSL $03B72B
       BCC .NoContact
       LDA #$01
.NoContact
       LDA #$00
       RTS

GivePoints:
       PHY
       LDA $1697|!Base2
       CLC
       ADC !1626,X
       INC $1697|!Base2
       TAY
       INY
       CPY #$08
       BCS +
       LDA KillSFX,y
       STA $1DF9|!Base2
+      TYA
       CMP #$08
       BCC +
       LDA #$08
+      JSL $02ACE5
       PLY
       RTS

