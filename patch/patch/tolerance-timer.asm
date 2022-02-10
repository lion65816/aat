; ###########################
; #  Tolerance Timer Patch  #
; ###########################

if read1($00FFD5) == $23		; check if the rom is sa-1
	sa1rom
	!SA1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!bankA = $400000
else
	lorom
	!SA1 = 0
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!bankA = $7E0000
endif



!allow_late_jumps		?= 1		; Whether to allow late jumps
!allow_early_jumps		?= 1		; Whether to allow early jumps

!late_jump_num_frames		?= 3		; The number of frames after falling down in which a jump is still possible	(late jump) (1 frame = 16.666... ms or 1/60 s)
!early_jump_num_frames		?= 3		; Number of frames you can press the jump button before actually touching the ground to perform a jump (early jump)

; Free RAM
!late_jump_timer		?= $0F3A|!addr	; 1 byte, RAM to store late jump timer
!late_jump_last_x_speed 	?= $0F3B|!addr	; 1 byte, Mario's last X speed while he was still on the ground
!late_jump_last_dash_timer	?= $0F3C|!addr	; 1 byte, Mario's last dash timer while he was still on the ground
!early_jump_timer		?= $0F3D|!addr	; 1 byte, RAM to store early jump timer
!early_jump_last_button		?= $0F3E|!addr	; 1 byte, RAM to store the last button presses relevant for early jumps (A or B button)


math pri on
namespace tolerance_timer_

!allow_late_or_early_jumps = !allow_late_jumps|!allow_early_jumps





; ###########
; # Hijacks #
; ###########

; Code to execute when the game checks whether Mario can jump
if !allow_late_or_early_jumps == 1
org $00D5F2|!bank
	autoclean JML OnCheckJumpPossible
endif

; Code to execute when the player successfully jumps
if !allow_late_or_early_jumps == 1
org $00D63C|!bank
	autoclean JML OnJump
endif

; Code to execute when the game checks whether we're pressing any jump button
if !allow_early_jumps == 1
org $00D618|!bank
	autoclean JML OnCheckJumpButtonPressed
endif





; ###################
; # MAIN CODE START #
; ###################

freecode



; ##############################
; # Check Jump Possible Hijack #
; ##############################


; Hijacks the check that determines whether Mario can jump (so that we can potentially make him jump with a delay)

if !allow_late_or_early_jumps == 1
OnCheckJumpPossible:

.recover
	; If Mario isn't currently in the air in any form, jumping is possible, anyways, so don't check further
	LDA $72
	BEQ .canJump
.check
if !allow_late_jumps == 1
	; We're technically in the air by now, but check if a late jump is still possible
	LDA !late_jump_timer
	BEQ .cantJump
	DEC
	STA !late_jump_timer
	BRA .return
.cantJump
endif

if !allow_early_jumps == 1
	; We're currently in the air and no late jump is possible, so check if an early jump is possible instead
	LDA $16
	ORA $18
	BPL .noButtonPressed
.reset
	; We're pressing any jump button, so reset the early jump timer
	LDA #!early_jump_num_frames
	STA !early_jump_timer

	; Store $18, so that we will later know whether we pressed A or B
	LDA $18
	STA !early_jump_last_button
	BRA .dontStoreTimer

.noButtonPressed
	LDA !early_jump_timer
	SEC : SBC #$01	; Why does dec not modify the carry flag? Oh well...
	BCC .dontStoreTimer
.storeTimer
	STA !early_jump_timer
.dontStoreTimer
endif

	JML $00D5F6|!bank


.canJump
if !allow_late_jumps == 1
	LDA #!late_jump_num_frames
	STA !late_jump_timer
	LDA $7B
	STA !late_jump_last_x_speed
	LDA $13E4|!addr
	STA !late_jump_last_dash_timer
endif

.return
	JML $00D5F9|!bank
endif





; ###############
; # Jump Hijack #
; ###############

; Hijacks the routine that starts Mario's jump so that we can clear flags and process early jumps

if !allow_late_or_early_jumps == 1
OnJump:

if !allow_late_jumps == 1
	LDA $72
	BEQ .noLateJump
.lateJump

	; If we're in a late jump, restore x speed if it makes sense (because falling off ledges slows Mario down)
	LDA $15
	BIT #%00000010
	BEQ .notHoldingLeft
.holdingLeft

	; Player is currently holding left - check if stored speed was negative
	LDA !late_jump_last_x_speed
	BPL .dontRestoreXSpeed
.xSpeedNegative
	STA $7B
	LDA !late_jump_last_dash_timer
	STA $13E4|!addr
	BRA .dontRestoreXSpeed
.notHoldingLeft

	LDA $15
	BIT #%00000001
	BEQ .notHoldingRight
.holdingRight

	; Player is currently holding right - check if stored speed was positive
	LDA !late_jump_last_x_speed
	BMI .dontRestoreXSpeed
.xSpeedPositive
	STA $7B
	LDA !late_jump_last_dash_timer
	STA $13E4|!addr
.notHoldingRight
.dontRestoreXSpeed

.noLateJump
	LDA #$00
	STA !late_jump_timer

endif

.recover
	LDA $18
	BPL .ANotPressed

	; If A is being pressed during the current frame, we give it priority and don't check for early jumps to begin with
.APressed
if !allow_early_jumps == 1
	LDA #$00
	STA !early_jump_timer
endif
	JML $00D640|!bank


.ANotPressed
if !allow_early_jumps == 1
	LDA !early_jump_timer
	BEQ .noEarlyJump
.earlyJump
	LDA !early_jump_last_button
	BMI .APressed
	LDA #$00
	STA !early_jump_timer
.noEarlyJump
endif

.return
	JML $00D65E|!bank
endif





; ############################
; # Check Jump Button Hijack #
; ############################

; Hijacks the routine that checks if a jump button is pressed so that we can apply early jump logic

if !allow_early_jumps == 1
OnCheckJumpButtonPressed:
	LDA !early_jump_timer
	BEQ .noEarlyJump
.earlyJump
.checkCancelOnYoshi
	; Check if we're currently on Yoshi and pressing A, in which case early jump doesn't matter (and in fact, causes a minor glitch)
	LDA $187A|!addr
	BEQ .noCancel
.onYoshi
	LDA !early_jump_last_button
	BPL .noCancel
.cancel
	LDA #$00
	STA !early_jump_timer

.noCancel
	JML $00D630|!bank

.noEarlyJump
.recover
	LDA $16
	ORA $18

.return
	JML $00D61C|!bank
endif