; Resets level on L+R or death.
;  Call this routine from within your level code.
;
; Arguments:
;  $0C - Value for $19B8 (lower 8 bits of level number)
;  $0D - Value for $19D8 (additional bits)


; Flags for how to reset:
!resetLR        =   1   ; Set to 0 to not reset on L+R
!resetDeath     =   1   ; Set to 0 to not reset on death

; How long to play play the death animation for before reloading. Max #$30
!timeToPlayDeathSFX     =   $1B

; Sound effect for resetting.
!resetSound     = $2A
!resetPort      = $1DFC


;-----------------------------------------------------------------------------------------------
!arg1 = $0C
!arg2 = $0D

!EXLEVEL = 0
if (((read1($0FF0B4)-'0')*100)+((read1($0FF0B4+2)-'0')*10)+(read1($0FF0B4+3)-'0')) > 253
	!EXLEVEL = 1
endif

LRReset:
if !resetLR
    LDA $17
    AND #$30
    CMP #$30
    BEQ .reloadLR       ; L+R pressed
endif
if !resetDeath
    LDA $71
    CMP #$09
    BNE .return         ; dying
    LDA $1496|!addr
    CMP #$30-!timeToPlayDeathSFX
    BCC .reload
endif
  .return
    RTL

if !resetLR
  .reloadLR
    LDA $1493|!addr ; don't allow L+R reset on level end
    ORA $13D4|!addr ; ...or game paused
    ORA $1B89|!addr ; ...or message box
    BNE .return
    JSL $00F614     ; kill mario
endif
  .reload
    LDA #!resetSound
    STA !resetPort|!addr
    
    STZ $1B93|!addr ; reload specified sublevel
if !EXLEVEL
	JSL $03BCDC|!bank
else
	LDA $5B
	AND #$01
	ASL 
	TAX 
	LDA $95,x
	TAX
endif
    LDA !arg1
    STA $19B8|!addr,x
    LDA !arg2
    STA $19D8|!addr,x
    LDA #$06
    STA $71
    STZ $88
    STZ $89
    
    STZ $1496|!addr ; clear death timer
    STZ $1493|!addr ; clear end level timer
    STZ $1497|!addr ; clear invulnerability timer
    
    REP #$20
    STZ $148B|!addr ; clear rng
    STZ $0FAE|!addr ; clear boo ring angles
    STZ $0FB0|!addr
    SEP #$20

    STZ $0DC1|!addr ; clear yoshi
    STZ $18E2|!addr
    STZ $19         ; clear powerup
    STZ $0DC2|!addr ; clear item box
    STZ $14AF|!addr ; clear on/off switch
    STZ $1432|!addr ; clear directional coin flag

    LDA $13BE|!addr ; clear item memory
    CMP #$03
    BCS .noTrack
    ASL
    TAX
    REP #$21
    LDA $00BFFF,x
    ADC #$19F8
    STA $00
    LDA #$0000
    LDY #$80
  .clearLoop
    STA ($00),y
    DEY
    DEY
    BPL .clearLoop
    SEP #$20
  .noTrack
    RTL