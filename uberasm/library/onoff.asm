;=========================
; Ultimate Controller-Based Switch
; by Mathos
;
; This code allows you to easily
; setup one or more player-controlled
; switches with very flexible code.
;
; To setup one, simply copy-paste
; a define group, an initializer and
; a handler, and replace the keyword
; that precedes all names.
;=========================

!GuardFlag = $5C           ; Free RAM (1 byte), not reset on level load

; All input triggers are first frame only
; Buttons ==> byetUDLRaxlr----
; b = B only
; y = X or Y
; e = select
; t = Start
; U = up
; D = down
; L = left
; R = right
; a = A
; x = X
; l = L
; r = R
; - = null/unused

!SWCode           = 1                   ; Code status (0 = off, 1 = on)                                 ; \ SW defines
!SWDefault        = $00                 ; Default status value                                          ; |
!SWChanged        = $FF                 ; Changed status value                                          ; |
!SWButtons        = %0000000010000000   ; Trigger buttons                                               ; |
!SWLogic          = 0                   ; Required button use (0 = AND, 1 = OR)                         ; |
!SWOnlyOnFloor    = 0                  ; Restrict use to when standing on ground (0 = off, 1 = on)     ; |
!SWSFXNum         = $0B                 ; SFX number to play (put #$00 to disable)                      ; |
!SWSFXBnk         = $1DF9|!addr         ; SFX bank ($1FD9/$1DFB/$1DFC)                                  ; |
!SWAllocator      = %10000000           ; Bit to use in guard flag                                      ; |
!SWAddress        = $14AF|!addr         ; Address to store to                                           ; /

;-------------------------------------------------------------------------------

init:
LDA #$00
STA $14AF|!addr

LDA $19
	BEQ +
	LDA #$01
	STA $19
+	LDA $0DC2|!addr
	BEQ +
	LDA #$01
	STA $0DC2|!addr
+	RTL

    if !SWCode              ; \ SW initializer
        LDA.b #!SWDefault   ; |
        STA !SWAddress      ; |
        LDA.b #!SWAllocator ; |
        TRB !GuardFlag      ; |
    endif                   ; /
    
    RTL

main:
    stz $1401|!addr
    stz $13FD|!addr

LDA $9D			;obviously don't do things when freeze flag is set
ORA $13D4|!addr		;or game is paused
BNE .Re			;

LDA $77				;hopefully no "frame perfect".
AND #$04
BEQ .change

.CheckInput
LDA $18			;if not pressing A
BPL .Re			;return

INC $140D|!addr		;make player spin

LDA #$B5		;set Y-speed
STA $7D			;

LDA #$04	;spinjump sound effect
STA $1DFC|!addr	;
.change:
    if !SWCode                  ; \ SW handler
        .SW_beg:                ; |
        if !SWOnlyOnFloor       ; |
            LDA $77            ; |
            AND #$04            ; |
            BEQ .SW_end         ; |
        endif                   ; |
        LDA $16                 ; |
        XBA                     ; |
        LDA $18                 ; |
        REP #$20                ; |
        AND.w #!SWButtons       ; |
        if !SWLogic             ; |
            BNE .SW_inputok     ; |
        else                    ; |
            CMP.w #!SWButtons   ; |
            BEQ .SW_inputok     ; |
        endif                   ; |
        SEP #$20                ; |
        BRA .SW_end             ; |
        .SW_inputok:            ; |
        SEP #$20                ; |
        if !SWSFXNum            ; |
            LDA.b #!SWSFXNum    ; |
            STA.w !SWSFXBnk     ; |
        endif                   ; |
        LDA !GuardFlag          ; |
        AND.b #!SWAllocator     ; |
        BEQ .SW_gochanged       ; |
        .SW_godefault:          ; |
        LDA.b #!SWAllocator     ; |
        TRB !GuardFlag          ; |
        LDA.b #!SWDefault       ; |
        STA !SWAddress          ; |
        BRA .SW_end             ; |
        .SW_gochanged:          ; |
        LDA.b #!SWAllocator     ; |
        TSB !GuardFlag          ; |
        LDA.b #!SWChanged       ; |
        STA !SWAddress          ; |
        .SW_end:                ; |
    endif                       ; /
    
    RTL

.Re:
RTL