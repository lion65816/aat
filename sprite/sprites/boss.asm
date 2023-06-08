;=================================================================
; And Another Thing Boss
; by Koba
;
; Other AAT devs, please do not touch this or I'll tear your limbs apart
;=================================================================

;=================
; Define
;=================

;=================
; Macros
;=================
	
;=================
; Init / Main
;=================

print "INIT ", pc
	STZ !State,x				; Start Phase 1.
	
	RTL
	
print "MAIN ", pc
	PHB : PHK
	PLB
	JSR Start
	PLB
	RTL
	
;=================
; Sprite Routines
;=================

Return:
	RTS

Start:
	JSR SubGFX                      ; Run GFX Routine.
	
	LDA !14C8,x						; \
	CMP #$08						; | End code if sprite status != alive
	BNE Return						; /
	LDA $9D							; \ Halt code if sprites locked.
	BNE Return						; /
	
	LDA #$00						; \ Draw from range (x) to (y)
	%SubOffScreen()					; /

	; LDA !State,x				; \ Jump to phase routine depending on status flag.
	; ASL : TAX						; | ASL multiplies value in flag by 2,
	; JSR (Status,x)					; / as the labels are two bytes long (words).

	RTS

; Status:
    
;========================
; Wait -> Fire routine
;========================
	
;==================
; Hitbox/Clipping routine
;==================
	
;==================
; Graphics routine
;==================