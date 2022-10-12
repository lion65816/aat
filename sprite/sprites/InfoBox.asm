;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Info Box Disassembly
; By Sonikku
; A disassembly of the Info Box used in SMW. It acts
; exactly the same as the original. Can be modified for
; other purposes, if needed.
;
; Uses Extra Bytes: Yes
;
; If using vanilla message:
;
; Extra byte 1: Level number of the message. For levels 101+, make sure to subtract the level number by $DC
;		(so 101 becomes 25, 102 becomes 26, etc).
;
; If using VWF messages:
;
; Extra byte 1: High byte of the message ID
;
; Extra byte 2: Low byte of the message ID
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Here's the stuff you are able to edit without too much 
; knowledge of ASM.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!VWFState = $702000

!SND_message_hit = $22		; Sound effect to play when message is hit
!BNK_message_hit = $1DFC	; Bank to use for sound effect to play when message is hit

!DEF_time_explode = $20		; How long until the message box explodes (Only affects the sprite when using "infobox_explode.cfg")

Tilemap: db $C0,$A6			; Tilemap
YPOS:	db $00,$04,$07,$08,$08,$07,$04,$00,$00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB
                    PHK
                    PLB
                    JSR SPRITE_ROUTINE
                    PLB
					print "INIT ",pc
                    RTL     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_ROUTINE:
	JSL $01B44F|!BankB ; Load invisible solid block routine.
	
	LDA #$03
	%SubOffScreen()
	
	;%GetDrawInfo()
	
	LDA !15AC,x
	BEQ +
	DEC
	BNE +
	LDA !1594,x
	STA $13BF|!Base2
+	LDA !1558,x	; If timer for sprite..
	CMP #$01	; isn't 1..
	BNE CODE_038D93 ; Set Y position.
	LDA #!SND_message_hit
	STA !BNK_message_hit|!Base2
	STZ !1558,x	; Restore timer.
	STZ !C2,x	; Make it so it can be hit again.
	LDA $13BF|!Base2
	STA !1594,x
	LDA !extra_prop_1,x
	AND #$02
	BEQ .vanilla
	LDA !VWFState
	BNE .shared
	INC
	STA !VWFState
	LDA !extra_byte_2,x
	STA !VWFState+1
	LDA !extra_byte_1,x
	STA !VWFState+2
	BRA .shared

.vanilla
	LDA !extra_byte_1,x
	BEQ .default
	STA $13BF|!Base2
	LDA #$03
	STA !15AC,x
.default
	LDA !E4,x	; Load X position..
	LSR		; ..
	LSR		; ..
	LSR		; ..
	LSR		; ..
	AND #$01	; And make the sprite..
	INC		; Display its message..
	STA $1426|!Base2	; Based on its X position.
.shared
	LDA #$03
	STA !15AC,x
	LDA #!DEF_time_explode+1
	STA !1540,x
CODE_038D93:
	LDA !1558,x	; I just took this code out of all.log.
	LSR		; I didn't bother commenting it..
	TAY		; Since I don't really have the patience to.
	LDA $1C		; This code wasn't really documented..
	PHA		; In all.log to begin with..
	CLC		; So I only know this code sets the Y position..
	ADC YPOS,y	; Of the tile..
	STA $1C		; When Mario hits this sprite..
	LDA $1D		; from the bottom..
	PHA		; ..
	ADC #$00	; ..
	STA $1D		; ..
	JSL $0190B2|!BankB	; Load generic graphics routine.
	LDY !15EA,x	; Load sprite OAM.
	%BEC(+)
	LDA $14		; Load sprite frame counter.
	LSR		; Add more lines of LSR..
	LSR		; to make sprite animate more slowly.
	ADC $15E9|!Base2	; And add for sprite index.
	LSR		; And another LSR here.
	AND #$01	; Load how many tiles to show.
	TAX		; Transfer accum. to X.
	LDA Tilemap,x
	BRA ++
+	LDA	Tilemap
++	STA $0302|!Base2,y	; And store it.
	LDX $15E9|!Base2
	PLA		; Pull A.
	STA $1D		; Store to Layer 1 Y position (High byte).
	PLA		; Pull A.
	STA $1C		; And store to Layer 1 Y position (Low byte).
	LDA !extra_prop_1,x
	AND #$01
	BEQ +
	LDA !1540,x
	DEC
	BNE +
	LDA #$0D		; \ turn sprite
	STA !9E,x		; / into bob-omb
	JSL $07F7D2|!BankB	; reset sprite tables
	LDA #$08		; \ sprite status:
	STA !14C8,x		; / normal
	LDA #$01		; \ make it
	STA !1534,x		; / explode
	LDA #$30		; \ set time for
	STA !1540,x		; / explosion
	LDA #$09		; \ play sound
	STA $1DFC|!Base2	; / effect
+	RTS		; Return.