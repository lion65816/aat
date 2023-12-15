; This file is inserted to the beginning of patch.asm during its final compilation.
; This undoes hijacks done by other music insertion tools.
; It does NOT erase the data inserted by those tools; the program itself does that.

;lorom
if read1($00FFD5) == $23			; \
	!UsingSA1 = 1				; | Check if this ROM uses the SA-1 patch.
	if read1($00FFD7) == $0D
		fullsa1rom
	else
		sa1rom
	endif	
else						; |
	!UsingSA1 = 0				; / 
	fastrom
endif

if read1($008055) == $5C

print "Unnofficial Addmusic 4.05 data detected.  Undoing ASM hijacks..."

org $008055
	db $9C, $00, $01, $9C, $09, $01

org $00807C
	db $A0, $00, $00, $A9, $AA, $BB

org $00808D
	db $B7, $00, $C8, $EB, $A9, $00, $80, $0B, $EB, $B7, $00, $C8, $EB

org $0080B4
	db $C2, $20, $B7, $00, $C8, $C8, $AA, $B7, $00, $C8, $C8, $8D, $42, $21, $E2, $20

org $0080E9
	db $00, $8D, $00, $00, $A9, $80, $8D, $01, $00, $A9, $0E

org $0096C3
	db $20, $0E, $81, $A9, $01, $8D, $FB, $1D	
	
org $009702
	db $20, $34, $81
	
org $00973B
	db $29, $BF, $8D, $DA, $0D, $9C, $AE, $0D, $9C, $AF, $0D
	
org $00A162
	db $91, $8D, $04
	
org $00A64F
	db $22,$49,$85,$90,$EA
	
org $00A64F	
	db $09, $40, $8D, $DA, $0D

org $048DDA 
	db $D0, $03, $82, $55, $00

org $049AA5
	db $9D, $11, $1F, $29, $FF, $00

org $05855F
	db $D0
	
endif


if read1($05D8E6) == $22
print "Sample Tool data detected. Undoing ASM hijacks..."

org $00800A
	db $9C, $40, $21, $9C, $41, $21

org $00A0B9
	db $9C, $DA, $0D, $AE, $B3, $0D

org $05D8E6
	db $A9, $00, $00, $E2, $20
	
endif
;lorom

!FreeROM		= $0E8000		; DO NOT TOUCH THESE, otherwise the program won't be able to determine where the data in your ROM is stored!
;!Data			= $0E8000		; Data+$0000 = Table of music data pointers 300 bytes long. 
						; 	The first few entries are bogus because they're global songs uploaded with the SPC engine.
						; Data+$0300 = Table of sample data pointers 300 bytes long.
						; Data+$0600 = Table of sample loop pointers (relative to $0000; modified in-game).
						; Note that the first few bytes of !Data are meta bytes, so it's actually something like !Data+$0308
						
;if read1($00FFD5) == $23			; \
;	!UsingSA1 = 1				; | Check if this ROM uses the SA-1 patch.	
;else						; |
;	!UsingSA1 = 0				; / 
;endif


if !UsingSA1
	;sa1rom
	!SA1Addr1 = $3000
	!SA1Addr2 = $6000
else
	;fastrom
	!SA1Addr1 = $0000
	!SA1Addr2 = $0000
endif






!Version = $00

!SampleGroupPtrsLoc	= $008000

!FreeRAM		= $7FB000
!CurrentSong		= !FreeRAM+$00
!NoUploadSamples	= !FreeRAM+$01
!SongPositionLow	= !FreeRAM+$04
!SongPositionHigh	= !FreeRAM+$05
!SPCOutput1		= !SongPositionLow
!SPCOutput2		= !SongPositionHigh
!SPCOutput3		= !FreeRAM+$06
!SPCOutput4		= !FreeRAM+$07
;!MusicBackup		= !FreeRAM+$08
!SampleCount		= !FreeRAM+$09
!SRCNTableBuffer	= !FreeRAM+$0A

; FREERAM requires anywhere between 2 to potentially 1032 bytes of unused RAM (though somewhere in the range of, say, 100 is much more likely).
; Normally you shouldn't need to change this.
;
; Format:
; FREERAM+$0000: Current song being played.
; FREERAM+$0001: Flag.  If set, sample data will not be transferred when switching songs.
; FREERAM+$0002: ARAM/DSP Address lo byte (see below).
; FREERAM+$0003: ARAM/DSP Address hi byte
; FREERAM+$0004: Value to write to ARAM/DSP
; FREERAM+$0005: Current song position in ticks.
; FREERAM+$0006: Hi byte of above.
; FREERAM+$0007: Echo buffer location.  Recommended that you don't touch this unless necessary.  It's modified every time sample upload occurs, and referenced every time music upload occurs.
; FREERAM+$0008: Number of samples in current song (between 0 and 255)
; FREERAM+$0009: Used as a buffer for the sample pointer/loop table.  Could be up to 1024 bytes long, but this is unlikely (4 bytes per sample; do the math).

; 1DFB: Use this to request a song to play (more or less default behavior).
; 1DDA: Song to play once star/P-switch runs out.  If $FF, don't restore.

; Special status byte details:


; To write to ARAM: Set FREERAM+$02 and FREERAM+$03 to the address, and FREERAM+$04 to the value to write.  Note that the address cannot be $FFxx.  
; To write to the S-DSP: Set FREERAM+$02 to the address, FREERAM+$03 to #$FF, and FREERAM+$04 to the value to write.



; BE VERY CAREFUL WHEN CHANGING THIS FILE.  To be perfectly blunt, the parsing the program
; uses to find certain things is as dead simple as it gets, so if you change any labels or 
; defines and the program can no longer find them, Bad Things (TM) may happen.  Best to 
; leave this file alone unless absolutely necessary.

!GlobalMusicCount = #$09	; Changed automatically

!SFX1DF9Reg = 	$2140
!SpecialReg = 	$2141
!MusicReg = 	$2142
!SFX1DFCReg = 	$2143	


!SFX1DF9Mir = 	$1DF9|!SA1Addr2
!SpecialMir = 	$1DFA|!SA1Addr2
!MusicMir = 	$1DFB|!SA1Addr2
!SFX1DFCMir = 	$1DFC|!SA1Addr2

!MusicBackup = $0DDA|!SA1Addr2


!DefARAMRet = $0434	; This is the address that the SPC will jump to after uploading a block of data normally.
!ExpARAMRet = $17C8	; This is the address that the SPC will jump to after uploading a block of data that precedes another block of data (used when uploading multiple blocks).
!TabARAMRet = $1832	; This is the address that the SPC will jump to after uploading samples.  It changes the sample table address to its correct location in ARAM.
			; All of these are changed automatically.
!SongCount = $BA	; How many songs exist.  Used by the fading routine; changed automatically.

incsrc "tweaks.asm"			
			
			
org $0E8000		; Clear out what parts of bank E we can (Lunar Magic install some hacks there).
rep $7100 : db $55
org $0F8000		; Clear out what parts of bank F we can (Lunar Magic install some more hacks there).
rep $7051 : db $55
	
org $8075
	JML MainLabel

org !FreeROM
db "@AMK"			; Program name
db !Version
dl SampleGroupPtrs		; Position of the sample group pointers.
dl MusicPtrs			; Position of music and sample pointers.
db $00, $00, $00, $00, $00	; Reserve some space for meta data.
db $00, $00, $00, $00		;
db $00, $00, $00, $00		;
db $00, $00, $00, $00		;
db $00, $00, $00, $00		;

MainLabel:
	STZ $10
	
	JSL moved_main

	JML $00806B		; Return.  TODO: Detect if the ROM is using the Wait Replace patch.

moved_main:
	PHY
	PHX
	PHP
	PHB
	PHK
	PLB
	SEP #$30
	JSR HandleSpecialSongs
	REP #$20
	LDA !SFX1DF9Reg
	STA !SPCOutput1
	LDA !MusicReg
	STA !SPCOutput3
	SEP #$20

	LDA !SpecialMir
	STA !SpecialReg
	LDA !SFX1DF9Mir
	STA !SFX1DF9Reg
	LDA !SFX1DFCMir
	STA !SFX1DFCReg
	STZ !SFX1DF9Mir
	STZ !SpecialMir
	STZ !SFX1DFCMir
	LDA !MusicMir
	BEQ NoMusic
	CMP !CurrentSong
	BNE ChangeMusic

End:	
	CLI
	PLB
	PLP
	PLX
	PLY
	RTL


	JML $00806B		; Return.  TODO: Detect if the ROM is using the Wait Replace patch.

NoMusic:
	LDA #$00
	STA !NoUploadSamples
	BRA End
	
Fade:
	STA !MusicReg
	;STA !CurrentSong
	BRA End

PlayDirect:
;	PHA
;	STA !MusicReg
;	LDA !CurrentSong
;	STA !MusicBackup
;	PLA
;	STA !CurrentSong
;	BRA End

;	STA !MusicReg
;	PHA
;	LDA !CurrentSong
;	CMP !GlobalMusicCount+1
;	BCC +
;	STA !MusicBackup
;+
;	PLA
;	STA !CurrentSong
;	BRA End

	STA !MusicReg
	STA !CurrentSong
	BRA End

	
ChangeMusic:
	LDA $187A|!SA1Addr2		; \ 
	BEQ +
	LDA #$FF
+
	SEC
	SBC #$FD
	STA !SpecialMir
	
	;STA $7FFFFF
	
;	LDA !MusicMir
;	CMP !PSwitch
;	BEQ .doExtraChecks
;	CMP !Starman
;	BEQ .doExtraChecks
;	BRA .okay
;	
;.doExtraChecks			; We can't allow the p-switch or starman songs to play during the level clear themes.
	LDA !CurrentSong
	CMP !StageClear
	BEQ LevelEndMusicChange
	CMP !IrisOut
	BEQ LevelEndMusicChange
	CMP !Keyhole
	BEQ LevelEndMusicChange
	CMP !BossClear		;;; this one too
	BNE Okay
	
LevelEndMusicChange:
	LDA !MusicMir
	CMP !IrisOut
	BEQ Okay
	CMP !SwitchPalace	;;; bonus game fix
	BEQ Okay
	CMP !Miss		;;; sure why not
	BEQ Okay
	CMP !RescueEgg
	BEQ Okay		; Yep
	CMP !StaffRoll	; Added credits check
	BEQ Okay
	LDA $0100|!SA1Addr2		
	CMP #$10			
	BCC Okay
	;;; LDA !CurrentSong	;;; this is why we got here in first place, seems redundant
	;;; CMP !StageClear
	;;; BEQ EndWithCancel
	;;; CMP !IrisOut
	;;; BEQ EndWithCancel
EndWithCancel:
	STZ !MusicMir
	BRA End
	
Okay:
	LDA !MusicMir			; \ Global songs require no uploads.
	CMP !GlobalMusicCount+1		; |
	BCC PlayDirect			; /
	

	CMP #$FF			; \ #$FF is fade.
	BEQ Fade			; /
	
	LDA !CurrentSong		; \ 
	CMP !PSwitch			; |
	BEQ +				; |
	CMP !Starman			; |
	BNE ++				; | Don't upload samples if we're coming back from the pswitch or starman musics.
	;;;BRA ++			; |
+					; |
	LDA $0100|!SA1Addr2		; | \
	CMP #$12+1			; | | But if we're coming back from the p-switch or starman musics AND we're loading a new level, then we might need to reload the song as well.
	BCC ++				; | / ;;; can't be bad to allow everything below
	LDA !MusicMir			; |
	STA !CurrentSong		; |
	STA !MusicBackup		; |
	JMP SPCNormal			; |
++					; /
	LDA !MusicMir
	STA !CurrentSong
	STA !MusicBackup
	STA $0DDA|!SA1Addr2
	
;	LDA $0100|!SA1Addr2
;	CMP #$0F
;	BCC .forceMusicToPlay
;	LDA !CurrentSong
;	CMP !StageClear
;	BEQ EndWithCancel
;	CMP !IrisOut
;	BEQ EndWithCancel
;.forceMusicToPlay



;	LDA !MusicMir
;	CMP !MusicBackup
;	BNE +
;	STA !CurrentSong
;	JMP SkipSPCNormal
;+
;	LDA #$00
;	STA !MusicBackup
;+	LDA !MusicMir		;
;	STA !CurrentSong
;
;+++


	LDA !MusicMir
	CMP #!SongCount
	BCC +
	LDA #$FF
	JMP Fade
+
;	REP #$30
;	LDA !MusicMir		; If the selected music is invalid,
;	AND #$00FF		; then fade out.  This is to mimic #$80 being the value to fade out
;	STA $00			; since that's used a lot (while any negative value would work).
;	ASL			; Of course, this won't work correctly if the user has more than #$80 songs,
;	CLC			; But they'd have issues anyway.  Might as well try to avoid complications
;	ADC $00			; when it's possible.
;	INC
;	INC
;	TAX
;	SEP #$20
;	LDA MusicPtrs,x
;	SEP #$30
;	INC			; \ If the bank byte is 0 or FF, then this music is invalid.
;	CMP #$02		; /
;	BCS +
;	LDA #$FF
;	JMP Fade
;+


	

	LDA #$FF		; Send this as early as possible
	STA $2141		;
	
	SEI
	
	STZ $4200		; Disable NMI.  While NMI no longer messes with the audio ports,
				; interrupts at the wrong time during this delicate routine are bad.
	
	REP #$30		; $108055
	;LDA #$0000
	;SEP #$20
	LDA !MusicMir
	;REP #$30
	AND #$00FF
	STA $00
	ASL			;\
	CLC			;| Multiply by 3.
	ADC $00			;/
	TAX			; To index
	SEP #$20		; the music
	LDA MusicPtrs,x		; table data.
	STA $00
	INX
	LDA MusicPtrs,x
	STA $01
	INX
	LDA MusicPtrs,x
	STA $02
	
	REP #$10
	LDX #!DefARAMRet
	LDA !NoUploadSamples
	BNE +
	LDX #!ExpARAMRet
+	STX $03
	SEP #$10
	JSL UploadSPCData
	
	
	;STZ $2140		; $1080a1
	;STZ $2142
	;STZ $2143
	
	LDA !NoUploadSamples
	BEQ +
	NOP #3			; Missing waiting cycles after UploadSPCData added
	JMP SPCNormal
+
	
	REP #$20
	
	LDY #$02		; \
	LDA [$00]		; | 
	STA $09			; |
	LDA [$00],y		; | This puts the location of the ARAM sample table into $09.
	CLC			; |
	ADC $09			; |
	XBA : XBA		; | Test the low byte of the accumulator
	BEQ NoAdd		; |
	CLC			; | The low byte of the sample table must be 0.
	ADC #$0100		; |
	AND #$FF00		; |
NoAdd:	STA $09			; /
	

	SEP #$20
	
					
	LDA.b #SampleGroupPtrs		; [$0D] is the pointer to this song's sample group.
	STA $0D				; Sample groups contain the number of samples in their first byte
	LDA.b #SampleGroupPtrs>>8	; Then the sample numbers themselves after that.
	STA $0E
	LDA.b #SampleGroupPtrs>>16
	STA $0F
	
	LDA !MusicMir			; \
	REP #$30			; |
	AND #$00FF			; |
	ASL				; | Index the table by the music number
	TAY				; |
	LDA [$0D],y			; /
	STA $0D				; The sample groups are stored in the same bank as the table.
	SEP #$30
	
	LDA [$0D]			; Get the number of samples
	STA !SampleCount
	
	STA $0B				; $0A is used as a copy because CPX $XXXXXX doesn't exist.
	STZ $0C				; Zero out $0B because we'll be in 16-bit mode for a while.
	
	REP #$20
	AND #$00FF
	ASL
	ASL
	CLC
	ADC $09				; $09 contains the location of the ARAM SRCN table (positions and loop positions).
	STA $07				; $07 contains where each sample should go in ARAM.
	
	REP #$30
	LDX #$0000			; Clear out x and y.
	LDY #$0000
	DEC $0D				; Needed because we INC $0D twice.
	
.loop
	CPX $0B				; 108100
	BEQ NoMoreSamples
	PHX				; We use x for indexing as well; push it.
	
	
	TXA				; \
	ASL				; |
	ASL				; | Get index for the SRCN buffer table
	TAX				; | and save it in Y.
	TAY				; |
	INY : INY			; /
	
	LDA $07
	STA !SRCNTableBuffer,x
			
	INC $0D				; $0D is the current position in the table.
	INC $0D				;
	
	LDA [$0D]			; Get the next sample
	STA $00
	
					; A contains the sample number

	ASL				; \ A contains the sample loop position table index
	TAX				; | X contains the sample loop position table index
	LDA SampleLoopPtrs,x		; | A contains this sample's loop position
	CLC				; |
	ADC $07				; | A contains this sample's loop position relative to its position in ARAM. 
	TYX				; | Copy y (the SRCN buffer table index) to x.
	STA !SRCNTableBuffer,x		; / Store the loop position to the SRCN table buffer.

	
	LDA $00				; \
	ASL				; |
	CLC				; | Multiply by 3 to index the sample table data.
	ADC $00				; |
	TAX				; /
	
	;SEP #$10			
	LDA SamplePtrs,x
	STA $00
	INX
	INX

	SEP #$20
	LDA SamplePtrs,x
	STA $02
	
	REP #$20
	LDA #!ExpARAMRet
	STA $03
	LDA [$00]
	STA $05
	BEQ .empty			; If the sample's position in the ROM is 0 (which is invalid), skip it; it's empty.
	INC $00
	INC $00
	SEP #$30
	JSL UploadSPCDataDynamic
.empty
	REP #$30			; 10814f
	LDA $07
	CLC
	ADC $05
	STA $07
	PLX
	INX
	BRA .loop
NoMoreSamples:
					; $108166
	
	LDA $09				; \ $09 is the address of the ARAM SRCN table.
	STA $07				; |
	LDA $0B				; |
	ASL				; |
	ASL				; |
	STA $05				; |
	LDA #!TabARAMRet		; | Jump in ARAM to the DIR set routine.
	STA $03				; |
	LDA.w #!SRCNTableBuffer		; |
	STA $00				; | Upload the ARAM SRCN table.
	SEP #$20			; |
	LDA.b #!SRCNTableBuffer>>16	; |
	STA $02				; |
	JSL UploadSPCDataDynamic	; /
	
	NOP #11				; Needed to waste time. 10817b
					; On ZSNES it works with only 4 NOPs because...ZSNES.
					
	REP #$20
	LDA #!DefARAMRet
	STA $2142
	SEP #$20
	LDA $08
	STA $2141
	LDA #$CC
	STA $2140
	LDA $08
-	CMP $2141			; Wait for the SPC to echo the value back before continuing.
	BNE -
	JMP SkipSPCNormal
	
					; Time to get the SPC out of its loop.
					
	REP #$20			; \ 108173
	STZ $09				; | Size = 0 (jump to location instead of upload data).
	LDA #!DefARAMRet		; | 
	STA $0B				; | Location = #!DefARAMRet
	LDA #$0009|!SA1Addr1		; | 
	STA $00				; | 
	SEP #$30			; | 
if !UsingSA1				; |
	LDA #$7E			; | 
else					; |
	LDA #$00			; |
endif					; |
	STA $02				; | 
	JSL UploadSPCData		; /
	
	NOP #8				; Needed to waste time.
					; On ZSNES it works with only 4 NOPs because...ZSNES.
SPCNormal:				
	SEP #$30
	
	LDA #$00
	STA !NoUploadSamples

SkipSPCNormal:
	LDA !GlobalMusicCount+1
	
;NoUpload:
	STA !MusicReg
	
	LDA #$81
	STA $4200
	JMP End
	
HandleSpecialSongs:
	LDA $0100|!SA1Addr2
	CMP #$0F
	BEQ +
	LDA !MusicMir
	CMP !Miss
	BEQ +
	CMP !GameOver
	BEQ +
	CMP !StageClear		;;; more checks here should help
	BEQ ++
	CMP !IrisOut
	BEQ ++
	CMP !BossClear
	BEQ ++
	CMP !Keyhole
	BEQ ++
	LDA $14AD|!SA1Addr2
	ORA $14AE|!SA1Addr2
	ORA $190C|!SA1Addr2
	BNE .powMusic
	LDA $1490|!SA1Addr2
	CMP #$1E
	BCS .starMusic
	BEQ .restoreFromStarMusic
++
	RTS
	
+
	STZ $14AD|!SA1Addr2
	STZ $14AE|!SA1Addr2
	STZ $190C|!SA1Addr2
	STZ $1490|!SA1Addr2
	RTS
	
.powMusic
	LDA $1490|!SA1Addr2		; If both P-switch and starman music should be playing
	BNE .starMusic			;;; just play the star music
	LDA !PSwitch
	STA !MusicMir
+
	RTS
	
.starMusic
	LDA !Starman
	STA !MusicMir
+
	RTS
	
.restoreFromStarMusic
	LDA !MusicBackup
	STA !MusicMir
+
	RTS
	
pushpc

incsrc "SongSampleList.asm"


			; This file is internally combined with patch.asm, which needs to be assembled by itself at first to determine its size.
			; This contains mostly replacements to existing SMW code.  I HIGHLY recommend not changing anything unless absolutely necessary.


			
			


org $008079
UploadSPCData:				; This is an ever-so-slightly modified version of SMW's SPC upload routine.			
					; ENTRY CONDITIONS:
					; $00: \
					; $01: | Address of the block to upload
					; $02: /
					; $03: \ Position in ARAM to jump to upon completion
					; $04: / 
					; $05: \ Clobbered.  Unused on entry; will be the size of the transferred data when finished.
					; $06: / 
					; You can jump here at any time to upload data to the SPC.



		PHP			; Using PHP and PLP here feels like overkill...
		REP #$30		; Make A 16-bit
		LDY #$0000		;
		LDA #$BBAA		;\ Wait until SPC700 is ready to recive data
-		CMP $2140		;|
		BNE -			;/
		SEP #$20		; Make A 8-bit
		LDA #$CC		; Load byte to start transfer routine
		PHA			; Push A
		REP #$20		; Make A 16-bit
		LDA [$00],Y		; Load music data length
		STA $05
		INY			;\ Get ready to load the address
		INY			;/
		TAX			; Put the length in X
		LDA [$00],Y		; Load the address
		INY			;\ Get ready to load the data
		INY			;/
Entry2:		STA $2142		; Store the address to APU I/O ports 2 and 3 (SPC700's)
		SEP #$20		; Make A (8 bit)
		CPX #$0001		; Compare the previous address to 1 (if 0000, the carry flag will not be set and therfore the code will end)
		LDA #$00		;\ Clear A
		ROL			;| Puts carry into A
		STA $2141		;/ End the block transfer
		ADC #$7F		; Set the overflow flag if carry flag is set (Length is over 0000)
		PLA			;\ Take out A
		STA $2140		;| Store it into APU I/O port 0. Wait until they are equal (SPC700 has caught up)
-		CMP $2140		;|
		BNE -			;/
		BVS UploadData		; If the length was 0000, then finish the routine. Otherwise, upload the data.
		PLP
		RTL
		
Finished:	;print pc
		REP #$20		; $80B6
		LDA $03
		STA $2142
		LDA $05
		INC
		AND #$00FF
		STA $2140
		SEP #$20
-		CMP $2140
		BNE -
		PLP			; Return the processor's state back to normal
		RTL			; Return

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UploadData:	LDA [$00],Y		;\ Load the byte of data
		INY			;| (Ensure that the address is shifted properly)
		XBA			;|
		LDA #$00		;| Load the counter (00)
		BRA StoreByte		;/
GetNextByte:	XBA			;\ Load the byte of data
		LDA [$00],Y		;/
		INY			; Shift the used location appropriately
		XBA			; Make sure the byte of data is put into APU I/O port 1
-		CMP $2140		;\ Wait for $2140 to equal the counter (SPC700 has caught up)
		BNE -			;/
		INC A			; Increase the counter
StoreByte:	REP #$20		;\Make A 16-bit to input the byte of data into APU I/O port 1 and the counter into APU I/O port 0
		STA $2140		;|
		SEP #$20		;/Make A 8-bit
		DEX			;\ Repeat this until you have covered the whole block
		BNE GetNextByte		;/
-		CMP $2140		; Then make sure that APU I/O port 0 is the same as X
		BNE -			;
-		ADC #$03		;\ Increase the counter by 03 unless it would become 00, in which case, add another 03 to prevent the transfer from ending
		BEQ -			;/
		BRA Finished		;$8140
		;print pc
		

	
	
;org $008135
UploadSPCDataDynamic:			; $00: \
					; $01: | Address of the block to upload
					; $02: /
					; $03: \ Position in ARAM to jump to upon completion
					; $04: /
					; $05: \ Size of the data to upload (this address is NOT clobbered)
					; $06: / 
					; $07: \ Address in ARAM to upload to (recommended to increment it by ($05) when you finish to upload consecutive data)
					; $08: /
					
					; This is an alternate version of the upload routine.
					; Call this if it is impossible to determine ahead of
					; time where data will go.  This routine is used to
					; upload samples by default, but it can upload anything.
					
	PHP			;
	REP #$30		; Make A 16-bit
	LDY #$0000		;
	LDA #$BBAA		;\ Wait until SPC700 is ready to recive data
-	CMP $2140		;|
	BNE -			;/
	SEP #$20		; Make A 8-bit
	LDA #$CC		; Load byte to start transfer routine
	

		
		
	PHA
	REP #$20
	LDA $05
	TAX			; Put the length in x
	LDA $07			; Load the address
	JMP Entry2		; New entry point.
				; No RTL needed.

		
!SPCProgramLocation = $0F8000		; DO NOT TOUCH
		
UploadSPCEngine:
		REP #$20
		LDA.w #!SPCProgramLocation	;\ 0E8000 is used for most music data, etc.
		STA $00				;| ($00-$02 are later used by an LDA [$00],y)
		LDA #$0400
		STA $03
		SEP #$20
		LDA.b #!SPCProgramLocation>>16	;| 
		STA $02				;/  
		
		JSL UploadSPCData		;
		REP #$20
		LDA #$0000
		STA !FreeRAM+0
		STA !FreeRAM+2
		STA !FreeRAM+4
		STA !FreeRAM+6
		STA !FreeRAM+8
		STA !FreeRAM+10
		SEP #$20
		RTS                     	;
		;print pc

		!upram = $00
!idbyte = $03	
!xorstorage = $04
!spcjump = $05


;SPCUploadFast:
;					; ENTRY CONDITIONS:
;					; Sent #$FF to $2141
;					; $00: \
;					; $01: | Address of the block to upload
;					; $02: /
;					; $03: \ Position in ARAM to jump to upon completion
;					; $04: /
;					; $05: \ Size of the data to upload
;					; $06: / 
;					; $07: \ Address in ARAM to upload to (recommended to increment it by ($05) when you finish to upload consecutive data)
;					; $08: /
;					
;	REP #$30
;	LDA #$BBAA		; \ Wait until SPC700 is ready to recive data
;-	CMP $2140		; |
;	BNE -			; /
;	LDA $05			; \
;	STA $2140		; | Send the length and address of upload.
;	LDA $07			; |	
;	STA $2142		; /
;	LDA $00			; \
;	STA !upram		; |
;	SEP #$20		; | Set the address properly.
;	LDA $02			; |
;	STA !upram+2		; /
;	LDX $05			; \ Put the size into X
;	DEX			; /
;	LDA #$03		; \
;	STA !idbyte		; / 
	
	
	
;	.loop
;	REP #$20		; \
;	LDA [!upram],x		; | Get the next two bytes
;	STA $2141		; | Send them
;	STA !xorstorage		; / Store them
;	DEX			; \
;	DEX			; |
;	SEP #$20		; |
;	LDA [!upram],x		; | Get the next byte, send it, store it.
;	STA $2140		; |
;	STA !xorstorage		; /
;	DEX			;
;	BMI .noMoreData		; If X has become negative, then we've either sent just enough or to much.  Change the number of bytes to store and quit.
;	
;	LDA !idbyte		; \ Flip the second highest bit of the idbyte
;	EOR #$40		; | Just enough to make it "different" from the last.
;	STA $2143		; | Note that the lowest 2 bits are used to determine how many bytes to write, so we can't just INC $2143 or something.
;	STA !idbyte		; /
;	
;	LDA !xorstorage		; \
;	EOR !xorstorage+1	; | Get the xor of the data sent.
;	EOR !xorstorage+2	; /
;	
;	PHA			;
;	LDA !idbyte		;
;-	CMP $2143		; \ Wait for the SPC to echo back the id we sent.
;	BNE -			; / This tells us it's ready for more data.
;	PLA			; \
;	CMP $2140		; / The SPC will have eor'd the data we sent it together.  If it doesn't match, something's gone wrong.
;	BEQ .loop
;	
;	JMP EmergencyRestart	; > The data was wrong.  We need to restart the transfer.
;	
;.noMoreData			; We've sent either too many or just enough bytes.
;	TXA			; \
;	EOR #$FF		; | Get the number of bytes to send
;	INC			; /
;	ORA #$80		; > Highest bit indicates end of transfer.
;	STA $2123		; > Store
;	
;	LDA !xorstorage		; \
;	EOR !xorstorage+1	; | Get the xor of the data sent.
;	EOR !xorstorage+2	; /
;	PHA			;
;	LDA !idbyte		;
;-	CMP $2143		; \ Wait for the SPC to echo back the id we sent.
;	BNE -			; / This tells us it's ready for more data.
;	PLA			; \
;	CMP $2140		; / The SPC will have eor'd the data we sent it together.  If it doesn't match, something's gone wrong.
;	BEQ .transferOver
;	
;	JMP EmergencyRestart	; > The data was wrong.  We need to restart the transfer.	
;	
;.transferOver	
;	RTL
	
;EmergencyRestart:
;	LDA #$83
;	STA $2143
;	LDA #$FF
;	STA $2141
;	JMP SPCUploadFast

org $008052
	JSR UploadSPCEngine	


pullpc

MusicPtrs: 
dl $000000, $000000, $000000, $000000, $000000, $000000, $000000, $000000, $000000, $000000, music0A+8, music0B+8, music0C+8, music0D+8, music0E+8, music0F+8
dl music10+8, music11+8, music12+8, music13+8, music14+8, music15+8, music16+8, music17+8, music18+8, music19+8, music1A+8, music1B+8, music1C+8, music1D+8, music1E+8, music1F+8
dl music20+8, music21+8, music22+8, music23+8, music24+8, music25+8, music26+8, music27+8, music28+8, music29+8, music2A+8, music2B+8, music2C+8, music2D+8, music2E+8, music2F+8
dl music30+8, music31+8, music32+8, music33+8, music34+8, music35+8, music36+8, music37+8, music38+8, music39+8, music3A+8, music3B+8, music3C+8, music3D+8, music3E+8, music3F+8
dl music40+8, music41+8, music42+8, music43+8, music44+8, music45+8, music46+8, music47+8, music48+8, music49+8, music4A+8, music4B+8, music4C+8, music4D+8, music4E+8, music4F+8
dl music50+8, music51+8, music52+8, music53+8, music54+8, music55+8, music56+8, music57+8, music58+8, music59+8, music5A+8, music5B+8, music5C+8, music5D+8, music5E+8, music5F+8
dl music60+8, music61+8, music62+8, music63+8, music64+8, music65+8, music66+8, music67+8, music68+8, music69+8, music6A+8, music6B+8, music6C+8, music6D+8, music6E+8, music6F+8
dl music70+8, music71+8, music72+8, music73+8, music74+8, music75+8, music76+8, music77+8, music78+8, music79+8, music7A+8, music7B+8, music7C+8, music7D+8, music7E+8, music7F+8
dl music80+8, music81+8, music82+8, music83+8, music84+8, music85+8, music86+8, music87+8, music88+8, music89+8, music8A+8, music8B+8, music8C+8, music8D+8, music8E+8, music8F+8
dl music90+8, music91+8, music92+8, music93+8, music94+8, music95+8, music96+8, music97+8, music98+8, music99+8, music9A+8, music9B+8, music9C+8, music9D+8, music9E+8, music9F+8
dl musicA0+8, musicA1+8, musicA2+8, musicA3+8, musicA4+8, musicA5+8, musicA6+8, musicA7+8, musicA8+8, musicA9+8, musicAA+8, musicAB+8, musicAC+8, musicAD+8, musicAE+8, musicAF+8
dl musicB0+8, musicB1+8, musicB2+8, musicB3+8, musicB4+8, musicB5+8, musicB6+8, musicB7+8, musicB8+8, musicB9+8
dl $FFFFFF


SamplePtrs:
dl brr00+8, brr01+8, brr02+8, brr03+8, brr04+8, brr05+8, brr06+8, brr07+8, brr08+8, brr09+8, brr0A+8, brr0B+8, brr0C+8, brr0D+8, brr0E+8, brr0F+8
dl brr10+8, brr11+8, brr12+8, brr13+8, brr14+8, brr15+8, brr16+8, brr17+8, brr18+8, brr19+8, brr1A+8, brr1B+8, brr1C+8, brr1D+8, brr1E+8, brr1F+8
dl brr20+8, brr21+8, brr22+8, brr23+8, brr24+8, brr25+8, brr26+8, brr27+8, brr28+8, brr29+8, brr2A+8, brr2B+8, brr2C+8, brr2D+8, brr2E+8, brr2F+8
dl brr30+8, brr31+8, brr32+8, brr33+8, brr34+8, brr35+8, brr36+8, brr37+8, brr38+8, brr39+8, brr3A+8, brr3B+8, brr3C+8, brr3D+8, brr3E+8, brr3F+8
dl brr40+8, brr41+8, brr42+8, brr43+8, brr44+8, brr45+8, brr46+8, brr47+8, brr48+8, brr49+8, brr4A+8, brr4B+8, brr4C+8, brr4D+8, brr4E+8, brr4F+8
dl brr50+8, brr51+8, brr52+8, brr53+8, brr54+8, brr55+8, brr56+8, brr57+8, brr58+8, brr59+8, brr5A+8, brr5B+8, brr5C+8, brr5D+8, brr5E+8, brr5F+8
dl brr60+8, brr61+8, brr62+8, brr63+8, brr64+8, brr65+8, brr66+8, brr67+8, brr68+8, brr69+8, brr6A+8, brr6B+8, brr6C+8, brr6D+8, brr6E+8, brr6F+8
dl brr70+8, brr71+8, brr72+8, brr73+8, brr74+8, brr75+8, brr76+8, brr77+8, brr78+8, brr79+8, brr7A+8, brr7B+8, brr7C+8, brr7D+8, brr7E+8, brr7F+8
dl brr80+8, brr81+8, brr82+8, brr83+8, brr84+8, brr85+8, brr86+8, brr87+8, brr88+8, brr89+8, brr8A+8, brr8B+8, brr8C+8, brr8D+8, brr8E+8, brr8F+8
dl brr90+8, brr91+8, brr92+8, brr93+8, brr94+8, brr95+8, brr96+8, brr97+8, brr98+8, brr99+8, brr9A+8, brr9B+8, brr9C+8, brr9D+8, brr9E+8, brr9F+8
dl brrA0+8, brrA1+8, brrA2+8, brrA3+8, brrA4+8, brrA5+8, brrA6+8, brrA7+8, brrA8+8, brrA9+8, brrAA+8, brrAB+8, brrAC+8, brrAD+8, brrAE+8, brrAF+8
dl brrB0+8, brrB1+8, brrB2+8, brrB3+8, brrB4+8, brrB5+8, brrB6+8, brrB7+8, brrB8+8, brrB9+8, brrBA+8, brrBB+8, brrBC+8, brrBD+8, brrBE+8, brrBF+8
dl brrC0+8, brrC1+8, brrC2+8, brrC3+8, brrC4+8, brrC5+8, brrC6+8, brrC7+8, brrC8+8, brrC9+8, brrCA+8, brrCB+8, brrCC+8, brrCD+8, brrCE+8, brrCF+8
dl brrD0+8, brrD1+8, brrD2+8, brrD3+8, brrD4+8, brrD5+8, brrD6+8, brrD7+8, brrD8+8, brrD9+8, brrDA+8, brrDB+8, brrDC+8, brrDD+8, brrDE+8, brrDF+8
dl brrE0+8, brrE1+8, brrE2+8, brrE3+8, brrE4+8, brrE5+8, brrE6+8, brrE7+8, brrE8+8, brrE9+8, brrEA+8, brrEB+8, brrEC+8, brrED+8, brrEE+8, brrEF+8
dl brrF0+8, brrF1+8, brrF2+8, brrF3+8, brrF4+8, brrF5+8, brrF6+8, brrF7+8, brrF8+8, brrF9+8, brrFA+8, brrFB+8, brrFC+8, brrFD+8, brrFE+8, brrFF+8
dl brr100+8, brr101+8, brr102+8, brr103+8, brr104+8, brr105+8, brr106+8, brr107+8, brr108+8, brr109+8, brr10A+8, brr10B+8, brr10C+8, brr10D+8, brr10E+8, brr10F+8
dl brr110+8, brr111+8, brr112+8, brr113+8, brr114+8, brr115+8, brr116+8, brr117+8, brr118+8, brr119+8, brr11A+8, brr11B+8, brr11C+8, brr11D+8, brr11E+8, brr11F+8
dl brr120+8, brr121+8, brr122+8, brr123+8, brr124+8, brr125+8, brr126+8, brr127+8, brr128+8, brr129+8, brr12A+8, brr12B+8, brr12C+8, brr12D+8, brr12E+8, brr12F+8
dl brr130+8, brr131+8, brr132+8, brr133+8, brr134+8, brr135+8, brr136+8, brr137+8, brr138+8, brr139+8, brr13A+8, brr13B+8, brr13C+8, brr13D+8, brr13E+8, brr13F+8
dl brr140+8, brr141+8, brr142+8, brr143+8, brr144+8, brr145+8, brr146+8, brr147+8, brr148+8, brr149+8, brr14A+8, brr14B+8, brr14C+8, brr14D+8, brr14E+8, brr14F+8
dl brr150+8, brr151+8, brr152+8, brr153+8, brr154+8, brr155+8, brr156+8, brr157+8, brr158+8, brr159+8, brr15A+8, brr15B+8, brr15C+8, brr15D+8, brr15E+8, brr15F+8
dl brr160+8, brr161+8, brr162+8, brr163+8, brr164+8, brr165+8, brr166+8, brr167+8, brr168+8, brr169+8, brr16A+8, brr16B+8, brr16C+8, brr16D+8, brr16E+8, brr16F+8
dl brr170+8, brr171+8, brr172+8, brr173+8, brr174+8, brr175+8, brr176+8, brr177+8, brr178+8, brr179+8, brr17A+8, brr17B+8, brr17C+8, brr17D+8, brr17E+8, brr17F+8
dl brr180+8, brr181+8, brr182+8, brr183+8, brr184+8, brr185+8, brr186+8, brr187+8, brr188+8, brr189+8, brr18A+8, brr18B+8, brr18C+8, brr18D+8, brr18E+8, brr18F+8
dl brr190+8, brr191+8, brr192+8, brr193+8, brr194+8, brr195+8, brr196+8, brr197+8, brr198+8, brr199+8, brr19A+8, brr19B+8, brr19C+8, brr19D+8, brr19E+8, brr19F+8
dl brr1A0+8, brr1A1+8, brr1A2+8, brr1A3+8, brr1A4+8, brr1A5+8, brr1A6+8, brr1A7+8, brr1A8+8, brr1A9+8, brr1AA+8, brr1AB+8, brr1AC+8, brr1AD+8, brr1AE+8, brr1AF+8
dl brr1B0+8, brr1B1+8, brr1B2+8, brr1B3+8, brr1B4+8, brr1B5+8, brr1B6+8, brr1B7+8, brr1B8+8, brr1B9+8, brr1BA+8, brr1BB+8, brr1BC+8, brr1BD+8, brr1BE+8, brr1BF+8
dl brr1C0+8, brr1C1+8, brr1C2+8, brr1C3+8, brr1C4+8, brr1C5+8, brr1C6+8, brr1C7+8, brr1C8+8, brr1C9+8, brr1CA+8, brr1CB+8, brr1CC+8, brr1CD+8, brr1CE+8, brr1CF+8
dl brr1D0+8, brr1D1+8, brr1D2+8, brr1D3+8, brr1D4+8, brr1D5+8, brr1D6+8, brr1D7+8, brr1D8+8, brr1D9+8, brr1DA+8, brr1DB+8, brr1DC+8, brr1DD+8, brr1DE+8, brr1DF+8
dl brr1E0+8, brr1E1+8, brr1E2+8, brr1E3+8, brr1E4+8, brr1E5+8, brr1E6+8, brr1E7+8, brr1E8+8, brr1E9+8, brr1EA+8, brr1EB+8, brr1EC+8, brr1ED+8, brr1EE+8, brr1EF+8
dl brr1F0+8, brr1F1+8, brr1F2+8, brr1F3+8, brr1F4+8, brr1F5+8, brr1F6+8, brr1F7+8, brr1F8+8, brr1F9+8, brr1FA+8, brr1FB+8, brr1FC+8, brr1FD+8, brr1FE+8, brr1FF+8
dl brr200+8, brr201+8, brr202+8, brr203+8, brr204+8, brr205+8, brr206+8, brr207+8, brr208+8, brr209+8, brr20A+8, brr20B+8, brr20C+8, brr20D+8, brr20E+8, brr20F+8
dl brr210+8, brr211+8, brr212+8, brr213+8, brr214+8, brr215+8, brr216+8, brr217+8, brr218+8, brr219+8, brr21A+8, brr21B+8, brr21C+8, brr21D+8, brr21E+8, brr21F+8
dl brr220+8, brr221+8, brr222+8, brr223+8, brr224+8, brr225+8, brr226+8, brr227+8, brr228+8, brr229+8, brr22A+8, brr22B+8, brr22C+8, brr22D+8, brr22E+8, brr22F+8
dl brr230+8, brr231+8, brr232+8, brr233+8, brr234+8, brr235+8, brr236+8, brr237+8, brr238+8, brr239+8, brr23A+8, brr23B+8, brr23C+8, brr23D+8, brr23E+8, brr23F+8
dl brr240+8, brr241+8, brr242+8, brr243+8, brr244+8, brr245+8, brr246+8, brr247+8, brr248+8, brr249+8, brr24A+8, brr24B+8, brr24C+8, brr24D+8, brr24E+8, brr24F+8
dl brr250+8, brr251+8, brr252+8, brr253+8, brr254+8, brr255+8, brr256+8, brr257+8, brr258+8, brr259+8, brr25A+8, brr25B+8, brr25C+8, brr25D+8, brr25E+8, brr25F+8
dl brr260+8, brr261+8, brr262+8, brr263+8, brr264+8, brr265+8, brr266+8, brr267+8, brr268+8, brr269+8, brr26A+8, brr26B+8, brr26C+8, brr26D+8, brr26E+8, brr26F+8
dl brr270+8, brr271+8, brr272+8, brr273+8, brr274+8, brr275+8, brr276+8, brr277+8, brr278+8, brr279+8, brr27A+8, brr27B+8, brr27C+8, brr27D+8, brr27E+8, brr27F+8
dl brr280+8, brr281+8, brr282+8, brr283+8, brr284+8, brr285+8, brr286+8, brr287+8, brr288+8, brr289+8, brr28A+8, brr28B+8, brr28C+8, brr28D+8, brr28E+8, brr28F+8
dl brr290+8, brr291+8, brr292+8, brr293+8, brr294+8, brr295+8, brr296+8, brr297+8, brr298+8, brr299+8, brr29A+8, brr29B+8, brr29C+8, brr29D+8, brr29E+8, brr29F+8
dl brr2A0+8, brr2A1+8, brr2A2+8, brr2A3+8, brr2A4+8, brr2A5+8, brr2A6+8, brr2A7+8, brr2A8+8, brr2A9+8, brr2AA+8, brr2AB+8, brr2AC+8, brr2AD+8, brr2AE+8, brr2AF+8
dl brr2B0+8, brr2B1+8, brr2B2+8, brr2B3+8, brr2B4+8, brr2B5+8, brr2B6+8, brr2B7+8, brr2B8+8, brr2B9+8, brr2BA+8, brr2BB+8, brr2BC+8, brr2BD+8, brr2BE+8, brr2BF+8
dl brr2C0+8, brr2C1+8, brr2C2+8, brr2C3+8, brr2C4+8, brr2C5+8, brr2C6+8, brr2C7+8, brr2C8+8, brr2C9+8, brr2CA+8, brr2CB+8, brr2CC+8, brr2CD+8, brr2CE+8, brr2CF+8
dl brr2D0+8, brr2D1+8, brr2D2+8, brr2D3+8, brr2D4+8, brr2D5+8, brr2D6+8, brr2D7+8, brr2D8+8, brr2D9+8, brr2DA+8, brr2DB+8, brr2DC+8, brr2DD+8, brr2DE+8, brr2DF+8
dl brr2E0+8, brr2E1+8, brr2E2+8, brr2E3+8, brr2E4+8, brr2E5+8, brr2E6+8, brr2E7+8, brr2E8+8, brr2E9+8, brr2EA+8, brr2EB+8, brr2EC+8, brr2ED+8, brr2EE+8, brr2EF+8
dl brr2F0+8, brr2F1+8, brr2F2+8, brr2F3+8, brr2F4+8, brr2F5+8, brr2F6+8, brr2F7+8, brr2F8+8, brr2F9+8, brr2FA+8, brr2FB+8, brr2FC+8, brr2FD+8, brr2FE+8, brr2FF+8
dl brr300+8, brr301+8, brr302+8, brr303+8, brr304+8, brr305+8, brr306+8, brr307+8, brr308+8, brr309+8, brr30A+8, brr30B+8, brr30C+8, brr30D+8, brr30E+8, brr30F+8
dl brr310+8, brr311+8, brr312+8, brr313+8, brr314+8, brr315+8, brr316+8, brr317+8, brr318+8, brr319+8, brr31A+8, brr31B+8, brr31C+8, brr31D+8, brr31E+8, brr31F+8
dl brr320+8, brr321+8, brr322+8, brr323+8, brr324+8, brr325+8, brr326+8, brr327+8, brr328+8, brr329+8, brr32A+8
dl $FFFFFF


SampleLoopPtrs:
dw $0024, $0024, $00EA, $0129, $0024, $0129, $0000, $0627, $0024, $0C2A, $0000, $0000, $0024, $029A, $0A71, $0000
dw $0000, $0510, $0000, $0000, $0000, $0009, $0009, $006C, $0099, $0009, $0000, $0360, $0009, $0453, $0000, $0009
dw $057C, $0000, $0000, $0774, $04D1, $0B91, $089D, $0894, $0000, $0000, $125A, $0639, $0009, $0786, $0144, $0000
dw $01D4, $0000, $06A5, $0492, $08CA, $0693, $0693, $0AF8, $04B6, $0C21, $057C, $04BF, $0171, $04BF, $0441, $06E4
dw $02F4, $0AF8, $02D0, $0321, $06A5, $03F9, $001B, $0384, $0465, $1EC3, $15F9, $102C, $0009, $0048, $23AF, $09CF
dw $0000, $0000, $0000, $0B49, $01E6, $08D3, $0000, $0000, $0870, $0009, $0546, $001B, $08EE, $02D9, $001B, $0936
dw $0D26, $001B, $001B, $001B, $0CA8, $05A9, $04FE, $077D, $0759, $040B, $0000, $0000, $06A5, $05E8, $08CA, $0870
dw $027F, $01CB, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0519, $0000, $04EC, $0225
dw $07E0, $0000, $06AE, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $001B, $07BC, $001B, $0642, $0573, $0DEC, $0000, $0000
dw $0000, $0000, $05D6, $044A, $0276, $0000, $0000, $0000, $0318, $09F3, $0036, $0036, $001B, $001B, $001B, $04FE
dw $0786, $0480, $038D, $0630, $0711, $038D, $038D, $022E, $093F, $019E, $07F2, $07E9, $038D, $038D, $0009, $060C
dw $0693, $0AD4, $0FE4, $0D38, $1638, $02FD, $0000, $03F9, $001B, $07E0, $0A8C, $0E2B, $0000, $001B, $0000, $01D4
dw $068A, $034E, $00B4, $001B, $0510, $0099, $0036, $001B, $01B0, $0000, $0000, $0414, $06C0, $04EC, $085E, $07B3
dw $0BE2, $0BD9, $0009, $1059, $11C1, $1050, $0009, $0201, $001B, $0000, $0000, $0000, $065D, $09C6, $044A, $0117
dw $0201, $0735, $0000, $0000, $0000, $0321, $0000, $0171, $0000, $054F, $0009, $04FE, $02BE, $02AC, $0000, $0000
dw $0000, $0000, $0000, $0000, $001B, $0090, $0036, $0264, $0000, $0000, $0000, $0000, $0A4D, $0000, $0000, $0009
dw $0000, $0357, $152A, $1E06, $001B, $1A5E, $0252, $049B, $09D8, $040B, $0000, $02BE, $001B, $003F, $0000, $0000
dw $0000, $0000, $0489, $001B, $0453, $0402, $0693, $0E2B, $0144, $02EB, $0BF4, $0B88, $0000, $039F, $06FF, $0A9E
dw $001B, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $069C, $0639, $02AC
dw $002D, $0E85, $0561, $05B2, $01CB, $0000, $03F9, $0000, $0024, $0000, $001B, $1194, $003F, $06B7, $04D1, $0F5D
dw $084C, $0A83, $0000, $0000, $0000, $0000, $02B5, $0240, $0000, $0000, $0012, $09F3, $001B, $001B, $001B, $09FC
dw $0666, $05A9, $0489, $0AE6, $0B91, $0D2F, $010E, $0A83, $0009, $0009, $0000, $0000, $0000, $001B, $0009, $0000
dw $0000, $0831, $0264, $0948, $001B, $1290, $0855, $085E, $0009, $0000, $0000, $0000, $0009, $0009, $0384, $0558
dw $046E, $06D2, $0252, $020A, $06A5, $03C3, $0465, $0087, $040B, $0585, $05DF, $0519, $0693, $0009, $0867, $00EA
dw $0A71, $10B3, $03E7, $0000, $0000, $0000, $0000, $0000, $0000, $0009, $06DB, $0522, $049B, $0573, $02C7, $0000
dw $0237, $001B, $00D8, $0036, $001B, $022E, $001B, $013B, $018C, $002D, $05C4, $0867, $0438, $0894, $001B, $001B
dw $001B, $0009, $00F3, $0C69, $0384, $0087, $0288, $003F, $0B49, $0201, $00AB, $08CA, $1008, $001B, $0C4E, $01CB
dw $001B, $001B, $001B, $001B, $049B, $00AB, $00FC, $0000, $0183, $02F4, $065D, $0000, $0000, $0252, $0489, $04DA
dw $0318, $044A, $1194, $0000, $0000, $0024, $001B, $001B, $0048, $0000, $0000, $0000, $003F, $0000, $057C, $0201
dw $0009, $0195, $0144, $05F1, $02EB, $1275, $0009, $0000, $0000, $0384, $0000, $0000, $0489, $0000, $018C, $0264
dw $0087, $0012, $066F, $05DF, $05A0, $0225, $0264, $03F0, $0000, $06D2, $0681, $0000, $0276, $0AD4, $2652, $1974
dw $1A5E, $0384, $00E1, $018C, $0000, $0000, $0000, $058E, $1413, $081F, $0000, $0000, $0000, $0000, $0000, $0000
dw $0000, $0B91, $0288, $06ED, $0009, $001B, $0009, $01B9, $001B, $0009, $0099, $0000, $0000, $0000, $0000, $0000
dw $0000, $00CF, $00CF, $00CF, $0000, $0000, $05D6, $061E, $0666, $0492, $0000, $0723, $0000, $01C2, $026D, $0369
dw $0465, $0000, $0000, $1B3F, $0009, $0009, $03C3, $06D2, $08E5, $071A, $0E19, $0276, $0396, $0012, $0012, $0012
dw $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012
dw $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012
dw $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012
dw $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0012, $0C60, $02D9, $02D9
dw $0117, $0171, $0099, $00E1, $001B, $001B, $001B, $0711, $001B, $001B, $001B, $001B, $001B, $015F, $02D0, $00EA
dw $0171, $001B, $01CB, $0252, $0357, $045C, $0F5D, $10BC, $04C8, $0009, $05FA, $0000, $01C2, $07AA, $0009, $03B1
dw $0762, $01CB, $00EA, $04E3, $02AC, $02AC, $038D, $02AC, $046E, $02B5, $0048, $0000, $0000, $0000, $002D, $0000
dw $0036, $0075, $0ADD, $B013, $0225, $14C7, $001B, $0D2F, $0FE4, $07F2, $0333, $057C, $0012, $001B, $0012, $001B
dw $0AD4, $0693, $05C4, $0024, $0723, $0000, $0000, $038D, $0009, $0708, $04A4, $0441, $03F9, $03DE, $0477, $0000
dw $0000, $069C, $0009, $0009, $0000, $0000, $0000, $0000, $0000, $0000, $084C, $0681, $001B, $0012, $0009, $0654
dw $0492, $0000, $077D, $0BBE, $0D80, $0009, $001B, $018C, $0120, $0009, $0000, $010E, $0099, $02F4, $06ED, $039F
dw $0000, $0009, $0414, $0441, $0426, $05D6, $0000, $0000, $0000, $002D, $001B, $0012, $0000, $071A, $0000, $066F
dw $0000, $0000, $0105, $00B4, $0000, $0453, $0000, $0000, $014D, $0318, $05DF, $015F, $0009, $0000, $081F, $001B
dw $0396, $08F7, $0BD9, $0000, $0000, $0DBF, $0000, $0000, $0009, $0099, $002D, $0426, $005A, $0291, $04A4, $04F5
dw $0678, $045C, $0597, $0000, $0024, $0036, $005A, $00BD, $0048, $0075, $01F8

org $80ABF1
music0A: incbin "bin/music0A.bin"
org $80B0E2
music0B: incbin "bin/music0B.bin"
org $80A6AD
music0C: incbin "bin/music0C.bin"
org $80B704
music0D: incbin "bin/music0D.bin"
org $80BB7B
music0E: incbin "bin/music0E.bin"
org $80C079
music0F: incbin "bin/music0F.bin"
org $80C20B
music10: incbin "bin/music10.bin"
org $80C57A
music11: incbin "bin/music11.bin"
org $808128
music12: incbin "bin/music12.bin"
org $80CC9C
music13: incbin "bin/music13.bin"
org $80CF15
music14: incbin "bin/music14.bin"
org $80CFB6
music15: incbin "bin/music15.bin"
org $80DC4B
music16: incbin "bin/music16.bin"
org $80DD59
music17: incbin "bin/music17.bin"
org $80DE8C
music18: incbin "bin/music18.bin"
org $80DFC8
music19: incbin "bin/music19.bin"
org $80E1AA
music1A: incbin "bin/music1A.bin"
org $80E2E2
music1B: incbin "bin/music1B.bin"
org $80E43F
music1C: incbin "bin/music1C.bin"
org $80E553
music1D: incbin "bin/music1D.bin"
org $80ED7D
music1E: incbin "bin/music1E.bin"
org $80EDBE
music1F: incbin "bin/music1F.bin"
org $80F145
music20: incbin "bin/music20.bin"
org $80F4CC
music21: incbin "bin/music21.bin"
org $80F7E5
music22: incbin "bin/music22.bin"
org $80F906
music23: incbin "bin/music23.bin"
org $80FA23
music24: incbin "bin/music24.bin"
org $80FC97
music25: incbin "bin/music25.bin"
org $80815C
music26: incbin "bin/music26.bin"
org $80FE12
music27: incbin "bin/music27.bin"
org $80AB2B
music28: incbin "bin/music28.bin"
org $81EE00
music29: incbin "bin/music29.bin"
org $81F4A1
music2A: incbin "bin/music2A.bin"
org $828000
music2B: incbin "bin/music2B.bin"
org $828C24
music2C: incbin "bin/music2C.bin"
org $829484
music2D: incbin "bin/music2D.bin"
org $829DF4
music2E: incbin "bin/music2E.bin"
org $82ABE8
music2F: incbin "bin/music2F.bin"
org $81F8E2
music30: incbin "bin/music30.bin"
org $82B6A7
music31: incbin "bin/music31.bin"
org $82C3A3
music32: incbin "bin/music32.bin"
org $82CA4F
music33: incbin "bin/music33.bin"
org $82D477
music34: incbin "bin/music34.bin"
org $82E0E4
music35: incbin "bin/music35.bin"
org $82EE87
music36: incbin "bin/music36.bin"
org $838000
music37: incbin "bin/music37.bin"
org $82F2CF
music38: incbin "bin/music38.bin"
org $8391CC
music39: incbin "bin/music39.bin"
org $839D46
music3A: incbin "bin/music3A.bin"
org $82FA41
music3B: incbin "bin/music3B.bin"
org $83A6C7
music3C: incbin "bin/music3C.bin"
org $83ADFA
music3D: incbin "bin/music3D.bin"
org $83BAFD
music3E: incbin "bin/music3E.bin"
org $83C22E
music3F: incbin "bin/music3F.bin"
org $83CB08
music40: incbin "bin/music40.bin"
org $83D4E9
music41: incbin "bin/music41.bin"
org $83DA46
music42: incbin "bin/music42.bin"
org $83E13C
music43: incbin "bin/music43.bin"
org $83EE88
music44: incbin "bin/music44.bin"
org $848000
music45: incbin "bin/music45.bin"
org $848641
music46: incbin "bin/music46.bin"
org $84988F
music47: incbin "bin/music47.bin"
org $849ECF
music48: incbin "bin/music48.bin"
org $84A7C4
music49: incbin "bin/music49.bin"
org $84B6FB
music4A: incbin "bin/music4A.bin"
org $84BDB4
music4B: incbin "bin/music4B.bin"
org $84C2AD
music4C: incbin "bin/music4C.bin"
org $81FC68
music4D: incbin "bin/music4D.bin"
org $84CBC7
music4E: incbin "bin/music4E.bin"
org $83FB88
music4F: incbin "bin/music4F.bin"
org $84D6F3
music50: incbin "bin/music50.bin"
org $84E228
music51: incbin "bin/music51.bin"
org $84EBAD
music52: incbin "bin/music52.bin"
org $84FAE1
music53: incbin "bin/music53.bin"
org $858000
music54: incbin "bin/music54.bin"
org $8585B0
music55: incbin "bin/music55.bin"
org $858C52
music56: incbin "bin/music56.bin"
org $859707
music57: incbin "bin/music57.bin"
org $85A1F6
music58: incbin "bin/music58.bin"
org $85A77B
music59: incbin "bin/music59.bin"
org $85ABBE
music5A: incbin "bin/music5A.bin"
org $85B667
music5B: incbin "bin/music5B.bin"
org $85C9D8
music5C: incbin "bin/music5C.bin"
org $85CC62
music5D: incbin "bin/music5D.bin"
org $85CF05
music5E: incbin "bin/music5E.bin"
org $85D50B
music5F: incbin "bin/music5F.bin"
org $84FE59
music60: incbin "bin/music60.bin"
org $85DDD2
music61: incbin "bin/music61.bin"
org $85E490
music62: incbin "bin/music62.bin"
org $85EB72
music63: incbin "bin/music63.bin"
org $80FF67
music64: incbin "bin/music64.bin"
org $85F4D3
music65: incbin "bin/music65.bin"
org $85F7D3
music66: incbin "bin/music66.bin"
org $868000
music67: incbin "bin/music67.bin"
org $868985
music68: incbin "bin/music68.bin"
org $869996
music69: incbin "bin/music69.bin"
org $869B98
music6A: incbin "bin/music6A.bin"
org $86A481
music6B: incbin "bin/music6B.bin"
org $86AEC5
music6C: incbin "bin/music6C.bin"
org $86B53A
music6D: incbin "bin/music6D.bin"
org $86BA9A
music6E: incbin "bin/music6E.bin"
org $86C365
music6F: incbin "bin/music6F.bin"
org $86C73E
music70: incbin "bin/music70.bin"
org $86CAB7
music71: incbin "bin/music71.bin"
org $86D52B
music72: incbin "bin/music72.bin"
org $86DFBF
music73: incbin "bin/music73.bin"
org $86F06F
music74: incbin "bin/music74.bin"
org $878000
music75: incbin "bin/music75.bin"
org $878D50
music76: incbin "bin/music76.bin"
org $879936
music77: incbin "bin/music77.bin"
org $86F550
music78: incbin "bin/music78.bin"
org $87AF98
music79: incbin "bin/music79.bin"
org $87B9EB
music7A: incbin "bin/music7A.bin"
org $87C391
music7B: incbin "bin/music7B.bin"
org $81FEC2
music7C: incbin "bin/music7C.bin"
org $86FB5F
music7D: incbin "bin/music7D.bin"
org $87CC1E
music7E: incbin "bin/music7E.bin"
org $87D9AB
music7F: incbin "bin/music7F.bin"
org $85FE10
music80: incbin "bin/music80.bin"
org $82FEA9
music81: incbin "bin/music81.bin"
org $87E3C5
music82: incbin "bin/music82.bin"
org $87F626
music83: incbin "bin/music83.bin"
org $888000
music84: incbin "bin/music84.bin"
org $86FEE6
music85: incbin "bin/music85.bin"
org $888D7B
music86: incbin "bin/music86.bin"
org $87F7F3
music87: incbin "bin/music87.bin"
org $889E98
music88: incbin "bin/music88.bin"
org $88A980
music89: incbin "bin/music89.bin"
org $88C032
music8A: incbin "bin/music8A.bin"
org $88C92E
music8B: incbin "bin/music8B.bin"
org $88CBF2
music8C: incbin "bin/music8C.bin"
org $88E2FE
music8D: incbin "bin/music8D.bin"
org $88E7FD
music8E: incbin "bin/music8E.bin"
org $88F63F
music8F: incbin "bin/music8F.bin"
org $898000
music90: incbin "bin/music90.bin"
org $898686
music91: incbin "bin/music91.bin"
org $898F38
music92: incbin "bin/music92.bin"
org $87FD88
music93: incbin "bin/music93.bin"
org $899515
music94: incbin "bin/music94.bin"
org $8997F6
music95: incbin "bin/music95.bin"
org $899C37
music96: incbin "bin/music96.bin"
org $89C3E4
music97: incbin "bin/music97.bin"
org $89CB65
music98: incbin "bin/music98.bin"
org $89D84A
music99: incbin "bin/music99.bin"
org $89EA88
music9A: incbin "bin/music9A.bin"
org $87FE59
music9B: incbin "bin/music9B.bin"
org $81FF3C
music9C: incbin "bin/music9C.bin"
org $89F0BD
music9D: incbin "bin/music9D.bin"
org $8A8000
music9E: incbin "bin/music9E.bin"
org $8A8FA6
music9F: incbin "bin/music9F.bin"
org $88FDFF
musicA0: incbin "bin/musicA0.bin"
org $8A9806
musicA1: incbin "bin/musicA1.bin"
org $8AA2EC
musicA2: incbin "bin/musicA2.bin"
org $8AABEE
musicA3: incbin "bin/musicA3.bin"
org $8AAF7F
musicA4: incbin "bin/musicA4.bin"
org $8AB35C
musicA5: incbin "bin/musicA5.bin"
org $8AB4BB
musicA6: incbin "bin/musicA6.bin"
org $8AC026
musicA7: incbin "bin/musicA7.bin"
org $8ACB69
musicA8: incbin "bin/musicA8.bin"
org $8ACD6F
musicA9: incbin "bin/musicA9.bin"
org $8ADEAF
musicAA: incbin "bin/musicAA.bin"
org $8B8000
musicAB: incbin "bin/musicAB.bin"
org $8B84F7
musicAC: incbin "bin/musicAC.bin"
org $8BA55B
musicAD: incbin "bin/musicAD.bin"
org $8BB230
musicAE: incbin "bin/musicAE.bin"
org $8BB889
musicAF: incbin "bin/musicAF.bin"
org $8BBD97
musicB0: incbin "bin/musicB0.bin"
org $8BD150
musicB1: incbin "bin/musicB1.bin"
org $8AFBB0
musicB2: incbin "bin/musicB2.bin"
org $8BDB90
musicB3: incbin "bin/musicB3.bin"
org $8BE781
musicB4: incbin "bin/musicB4.bin"
org $8C8000
musicB5: incbin "bin/musicB5.bin"
org $8C892C
musicB6: incbin "bin/musicB6.bin"
org $8AFD22
musicB7: incbin "bin/musicB7.bin"
org $8BFB90
musicB8: incbin "bin/musicB8.bin"
org $8CA759
musicB9: incbin "bin/musicB9.bin"


org $82FF7B
brr00: incbin "bin/brr00.bin"
org $83FFA8
brr01: incbin "bin/brr01.bin"
org $89FEA2
brr02: incbin "bin/brr02.bin"
org $8AFE96
brr03: incbin "bin/brr03.bin"
org $87FF3C
brr04: incbin "bin/brr04.bin"
org $8BFD0A
brr05: incbin "bin/brr05.bin"
org $8CC860
brr06: incbin "bin/brr06.bin"
org $8CCCE0
brr07: incbin "bin/brr07.bin"
org $87FF8D
brr08: incbin "bin/brr08.bin"
org $8CD358
brr09: incbin "bin/brr09.bin"
org $8CDFAF
brr0A: incbin "bin/brr0A.bin"
org $8CF23F
brr0B: incbin "bin/brr0B.bin"
org $8BFF53
brr0C: incbin "bin/brr0C.bin"
org $8CF8ED
brr0D: incbin "bin/brr0D.bin"
org $8D8000
brr0E: incbin "bin/brr0E.bin"
org $8CFBD8
brr0F: incbin "bin/brr0F.bin"
org $8D8A9E
brr10: incbin "bin/brr10.bin"
org $8D9395
brr11: incbin "bin/brr11.bin"
org $8D9911
brr12: incbin "bin/brr12.bin"
org $8DA27D
brr13: incbin "bin/brr13.bin"
org $80FFB1
brr14: incbin "bin/brr14.bin"
org $88FFC6
brr15: incbin "bin/brr15.bin"
org $89FFB9
brr16: incbin "bin/brr16.bin"
org $8CFE69
brr17: incbin "bin/brr17.bin"
org $8CFF02
brr18: incbin "bin/brr18.bin"
org $8BFFA4
brr19: incbin "bin/brr19.bin"
org $8DB42C
brr1A: incbin "bin/brr1A.bin"
org $8DB6A2
brr1B: incbin "bin/brr1B.bin"
org $8CFFC8
brr1C: incbin "bin/brr1C.bin"
org $8DBA53
brr1D: incbin "bin/brr1D.bin"
org $8DBF00
brr1E: incbin "bin/brr1E.bin"
org $8DC27B
brr1F: incbin "bin/brr1F.bin"
org $8DC2B1
brr20: incbin "bin/brr20.bin"
org $8DC85A
brr21: incbin "bin/brr21.bin"
org $8DCCA4
brr22: incbin "bin/brr22.bin"
org $8DD2A7
brr23: incbin "bin/brr23.bin"
org $8DDA75
brr24: incbin "bin/brr24.bin"
org $8DE039
brr25: incbin "bin/brr25.bin"
org $8E8000
brr26: incbin "bin/brr26.bin"
org $8E893F
brr27: incbin "bin/brr27.bin"
org $8E9EA8
brr28: incbin "bin/brr28.bin"
org $8EAC55
brr29: incbin "bin/brr29.bin"
org $8EB8B5
brr2A: incbin "bin/brr2A.bin"
org $8DF72E
brr2B: incbin "bin/brr2B.bin"
org $8DFDAF
brr2C: incbin "bin/brr2C.bin"
org $8EE5FD
brr2D: incbin "bin/brr2D.bin"
org $8EEDB0
brr2E: incbin "bin/brr2E.bin"
org $8EEF45
brr2F: incbin "bin/brr2F.bin"
org $8EF077
brr30: incbin "bin/brr30.bin"
org $8EF2B7
brr31: incbin "bin/brr31.bin"
org $8F8000
brr32: incbin "bin/brr32.bin"
org $8F9F80
brr33: incbin "bin/brr33.bin"
org $8FA499
brr34: incbin "bin/brr34.bin"
org $8FAD75
brr35: incbin "bin/brr35.bin"
org $8FB41A
brr36: incbin "bin/brr36.bin"
org $8FBABF
brr37: incbin "bin/brr37.bin"
org $8FC5C9
brr38: incbin "bin/brr38.bin"
org $8FCAB5
brr39: incbin "bin/brr39.bin"
org $8FD781
brr3A: incbin "bin/brr3A.bin"
org $8FDD0F
brr3B: incbin "bin/brr3B.bin"
org $8EFC1A
brr3C: incbin "bin/brr3C.bin"
org $8FE23A
brr3D: incbin "bin/brr3D.bin"
org $8FE75C
brr3E: incbin "bin/brr3E.bin"
org $8FEC36
brr3F: incbin "bin/brr3F.bin"
org $908000
brr40: incbin "bin/brr40.bin"
org $8FF32C
brr41: incbin "bin/brr41.bin"
org $908F81
brr42: incbin "bin/brr42.bin"
org $9092B4
brr43: incbin "bin/brr43.bin"
org $9098FF
brr44: incbin "bin/brr44.bin"
org $90ACEE
brr45: incbin "bin/brr45.bin"
org $90B19B
brr46: incbin "bin/brr46.bin"
org $90B9CC
brr47: incbin "bin/brr47.bin"
org $90BD62
brr48: incbin "bin/brr48.bin"
org $90C1D9
brr49: incbin "bin/brr49.bin"
org $90E0AE
brr4A: incbin "bin/brr4A.bin"
org $918000
brr4B: incbin "bin/brr4B.bin"
org $90FBD2
brr4C: incbin "bin/brr4C.bin"
org $919533
brr4D: incbin "bin/brr4D.bin"
org $919EF0
brr4E: incbin "bin/brr4E.bin"
org $91C5A5
brr4F: incbin "bin/brr4F.bin"
org $91D42A
brr50: incbin "bin/brr50.bin"
org $91D970
brr51: incbin "bin/brr51.bin"
org $91E7A4
brr52: incbin "bin/brr52.bin"
org $91EC99
brr53: incbin "bin/brr53.bin"
org $928000
brr54: incbin "bin/brr54.bin"
org $929BAB
brr55: incbin "bin/brr55.bin"
org $91F833
brr56: incbin "bin/brr56.bin"
org $92A6F4
brr57: incbin "bin/brr57.bin"
org $92B663
brr58: incbin "bin/brr58.bin"
org $92C35C
brr59: incbin "bin/brr59.bin"
org $92CC2F
brr5A: incbin "bin/brr5A.bin"
org $8DFED8
brr5B: incbin "bin/brr5B.bin"
org $92D229
brr5C: incbin "bin/brr5C.bin"
org $92DEB6
brr5D: incbin "bin/brr5D.bin"
org $92E1B3
brr5E: incbin "bin/brr5E.bin"
org $92EF0F
brr5F: incbin "bin/brr5F.bin"
org $938000
brr60: incbin "bin/brr60.bin"
org $8DFF20
brr61: incbin "bin/brr61.bin"
org $8DFF68
brr62: incbin "bin/brr62.bin"
org $8EFDB8
brr63: incbin "bin/brr63.bin"
org $939BEA
brr64: incbin "bin/brr64.bin"
org $93A9B2
brr65: incbin "bin/brr65.bin"
org $93B79E
brr66: incbin "bin/brr66.bin"
org $93C3E3
brr67: incbin "bin/brr67.bin"
org $93D352
brr68: incbin "bin/brr68.bin"
org $93DB44
brr69: incbin "bin/brr69.bin"
org $93DF61
brr6A: incbin "bin/brr6A.bin"
org $93E9DB
brr6B: incbin "bin/brr6B.bin"
org $948000
brr6C: incbin "bin/brr6C.bin"
org $93F71C
brr6D: incbin "bin/brr6D.bin"
org $949CDD
brr6E: incbin "bin/brr6E.bin"
org $94A5B9
brr6F: incbin "bin/brr6F.bin"
org $92FD16
brr70: incbin "bin/brr70.bin"
org $91FDCA
brr71: incbin "bin/brr71.bin"
org $8EFE24
brr72: incbin "bin/brr72.bin"
org $94AE8C
brr73: incbin "bin/brr73.bin"
org $8DFFB0
brr74: incbin "bin/brr74.bin"
org $8FFE36
brr75: incbin "bin/brr75.bin"
org $8FFE75
brr76: incbin "bin/brr76.bin"
org $8FFEB4
brr77: incbin "bin/brr77.bin"
org $8FFEF3
brr78: incbin "bin/brr78.bin"
org $94B2A0
brr79: incbin "bin/brr79.bin"
org $94B99F
brr7A: incbin "bin/brr7A.bin"
org $80FFC3
brr7B: incbin "bin/brr7B.bin"
org $94C35C
brr7C: incbin "bin/brr7C.bin"
org $94CA5B
brr7D: incbin "bin/brr7D.bin"
org $94D028
brr7E: incbin "bin/brr7E.bin"
org $94D52F
brr7F: incbin "bin/brr7F.bin"
org $94D886
brr80: incbin "bin/brr80.bin"
org $8FFF32
brr81: incbin "bin/brr81.bin"
org $94E444
brr82: incbin "bin/brr82.bin"
org $82FFCC
brr83: incbin "bin/brr83.bin"
org $8EFFCB
brr84: incbin "bin/brr84.bin"
org $8FFF71
brr85: incbin "bin/brr85.bin"
org $8FFF9E
brr86: incbin "bin/brr86.bin"
org $8FFFCB
brr87: incbin "bin/brr87.bin"
org $90FF0E
brr88: incbin "bin/brr88.bin"
org $90FF3B
brr89: incbin "bin/brr89.bin"
org $90FF68
brr8A: incbin "bin/brr8A.bin"
org $90FF95
brr8B: incbin "bin/brr8B.bin"
org $92FFB0
brr8C: incbin "bin/brr8C.bin"
org $93FDF7
brr8D: incbin "bin/brr8D.bin"
org $93FE36
brr8E: incbin "bin/brr8E.bin"
org $93FE75
brr8F: incbin "bin/brr8F.bin"
org $93FEB4
brr90: incbin "bin/brr90.bin"
org $93FEF3
brr91: incbin "bin/brr91.bin"
org $93FF32
brr92: incbin "bin/brr92.bin"
org $93FF71
brr93: incbin "bin/brr93.bin"
org $93FFB0
brr94: incbin "bin/brr94.bin"
org $94EB1F
brr95: incbin "bin/brr95.bin"
org $94EB5E
brr96: incbin "bin/brr96.bin"
org $94EB9D
brr97: incbin "bin/brr97.bin"
org $94EBDC
brr98: incbin "bin/brr98.bin"
org $94EC2D
brr99: incbin "bin/brr99.bin"
org $958000
brr9A: incbin "bin/brr9A.bin"
org $94F833
brr9B: incbin "bin/brr9B.bin"
org $959D37
brr9C: incbin "bin/brr9C.bin"
org $95A2F2
brr9D: incbin "bin/brr9D.bin"
org $95B15C
brr9E: incbin "bin/brr9E.bin"
org $95B7D4
brr9F: incbin "bin/brr9F.bin"
org $95C083
brrA0: incbin "bin/brrA0.bin"
org $95CAEB
brrA1: incbin "bin/brrA1.bin"
org $95CD07
brrA2: incbin "bin/brrA2.bin"
org $95D4F0
brrA3: incbin "bin/brrA3.bin"
org $95D994
brrA4: incbin "bin/brrA4.bin"
org $95DE2F
brrA5: incbin "bin/brrA5.bin"
org $95E23A
brrA6: incbin "bin/brrA6.bin"
org $95EDB9
brrA7: incbin "bin/brrA7.bin"
org $95EFBA
brrA8: incbin "bin/brrA8.bin"
org $95F33E
brrA9: incbin "bin/brrA9.bin"
org $95FF20
brrAA: incbin "bin/brrAA.bin"
org $95FF83
brrAB: incbin "bin/brrAB.bin"
org $968000
brrAC: incbin "bin/brrAC.bin"
org $968E7C
brrAD: incbin "bin/brrAD.bin"
org $968ECD
brrAE: incbin "bin/brrAE.bin"
org $969A8B
brrAF: incbin "bin/brrAF.bin"
org $969FD1
brrB0: incbin "bin/brrB0.bin"
org $96A7E7
brrB1: incbin "bin/brrB1.bin"
org $96AD1B
brrB2: incbin "bin/brrB2.bin"
org $96BA77
brrB3: incbin "bin/brrB3.bin"
org $96C1BE
brrB4: incbin "bin/brrB4.bin"
org $96CAA3
brrB5: incbin "bin/brrB5.bin"
org $96D2D4
brrB6: incbin "bin/brrB6.bin"
org $96DD8D
brrB7: incbin "bin/brrB7.bin"
org $96E552
brrB8: incbin "bin/brrB8.bin"
org $96F3BC
brrB9: incbin "bin/brrB9.bin"
org $978000
brrBA: incbin "bin/brrBA.bin"
org $97883A
brrBB: incbin "bin/brrBB.bin"
org $9793B9
brrBC: incbin "bin/brrBC.bin"
org $979D37
brrBD: incbin "bin/brrBD.bin"
org $90FFC2
brrBE: incbin "bin/brrBE.bin"
org $97A6A3
brrBF: incbin "bin/brrBF.bin"
org $97ACEE
brrC0: incbin "bin/brrC0.bin"
org $97B6B4
brrC1: incbin "bin/brrC1.bin"
org $97C422
brrC2: incbin "bin/brrC2.bin"
org $988000
brrC3: incbin "bin/brrC3.bin"
org $98938C
brrC4: incbin "bin/brrC4.bin"
org $97EFD5
brrC5: incbin "bin/brrC5.bin"
org $97F87B
brrC6: incbin "bin/brrC6.bin"
org $98B19B
brrC7: incbin "bin/brrC7.bin"
org $98B717
brrC8: incbin "bin/brrC8.bin"
org $98D9D3
brrC9: incbin "bin/brrC9.bin"
org $98E981
brrCA: incbin "bin/brrCA.bin"
org $998000
brrCB: incbin "bin/brrCB.bin"
org $98F56C
brrCC: incbin "bin/brrCC.bin"
org $96FC6B
brrCD: incbin "bin/brrCD.bin"
org $99941C
brrCE: incbin "bin/brrCE.bin"
org $96FD3A
brrCF: incbin "bin/brrCF.bin"
org $999950
brrD0: incbin "bin/brrD0.bin"
org $999FEC
brrD1: incbin "bin/brrD1.bin"
org $97FE87
brrD2: incbin "bin/brrD2.bin"
org $96FF20
brrD3: incbin "bin/brrD3.bin"
org $99A38B
brrD4: incbin "bin/brrD4.bin"
org $98FD70
brrD5: incbin "bin/brrD5.bin"
org $96FF68
brrD6: incbin "bin/brrD6.bin"
org $99A8C8
brrD7: incbin "bin/brrD7.bin"
org $98FE24
brrD8: incbin "bin/brrD8.bin"
org $99AAD2
brrD9: incbin "bin/brrD9.bin"
org $99AC0D
brrDA: incbin "bin/brrDA.bin"
org $99AD63
brrDB: incbin "bin/brrDB.bin"
org $99B3DB
brrDC: incbin "bin/brrDC.bin"
org $99BF1B
brrDD: incbin "bin/brrDD.bin"
org $99C6A1
brrDE: incbin "bin/brrDE.bin"
org $99D6CD
brrDF: incbin "bin/brrDF.bin"
org $99E324
brrE0: incbin "bin/brrE0.bin"
org $9A8000
brrE1: incbin "bin/brrE1.bin"
org $9A901A
brrE2: incbin "bin/brrE2.bin"
org $9AA544
brrE3: incbin "bin/brrE3.bin"
org $9AB7F8
brrE4: incbin "bin/brrE4.bin"
org $9AD1E1
brrE5: incbin "bin/brrE5.bin"
org $96FFB9
brrE6: incbin "bin/brrE6.bin"
org $9AEEEB
brrE7: incbin "bin/brrE7.bin"
org $99F617
brrE8: incbin "bin/brrE8.bin"
org $9B8000
brrE9: incbin "bin/brrE9.bin"
org $9B88DC
brrEA: incbin "bin/brrEA.bin"
org $9B9626
brrEB: incbin "bin/brrEB.bin"
org $9BA022
brrEC: incbin "bin/brrEC.bin"
org $9BA70F
brrED: incbin "bin/brrED.bin"
org $9BBAA4
brrEE: incbin "bin/brrEE.bin"
org $99FBC0
brrEF: incbin "bin/brrEF.bin"
org $9BBF24
brrF0: incbin "bin/brrF0.bin"
org $9BCBC3
brrF1: incbin "bin/brrF1.bin"
org $9BD3D9
brrF2: incbin "bin/brrF2.bin"
org $9BDBEF
brrF3: incbin "bin/brrF3.bin"
org $99FCFB
brrF4: incbin "bin/brrF4.bin"
org $9AFB8A
brrF5: incbin "bin/brrF5.bin"
org $9BE684
brrF6: incbin "bin/brrF6.bin"
org $9BF860
brrF7: incbin "bin/brrF7.bin"
org $9C8000
brrF8: incbin "bin/brrF8.bin"
org $9BFA10
brrF9: incbin "bin/brrF9.bin"
org $9C8AA7
brrFA: incbin "bin/brrFA.bin"
org $9C939E
brrFB: incbin "bin/brrFB.bin"
org $9C9A04
brrFC: incbin "bin/brrFC.bin"
org $9CA007
brrFD: incbin "bin/brrFD.bin"
org $9CAC04
brrFE: incbin "bin/brrFE.bin"
org $99FEA2
brrFF: incbin "bin/brrFF.bin"
org $9CB0C3
brr100: incbin "bin/brr100.bin"
org $9CB273
brr101: incbin "bin/brr101.bin"
org $9CB8A3
brr102: incbin "bin/brr102.bin"
org $9CBA53
brr103: incbin "bin/brr103.bin"
org $9CC095
brr104: incbin "bin/brr104.bin"
org $9CC10A
brr105: incbin "bin/brr105.bin"
org $9CCC26
brr106: incbin "bin/brr106.bin"
org $9CD4C3
brr107: incbin "bin/brr107.bin"
org $9CDBB9
brr108: incbin "bin/brr108.bin"
org $9CDD57
brr109: incbin "bin/brr109.bin"
org $9CDF46
brr10A: incbin "bin/brr10A.bin"
org $9D8000
brr10B: incbin "bin/brr10B.bin"
org $9D96A4
brr10C: incbin "bin/brr10C.bin"
org $9CF5EA
brr10D: incbin "bin/brr10D.bin"
org $9CF902
brr10E: incbin "bin/brr10E.bin"
org $9DA41B
brr10F: incbin "bin/brr10F.bin"
org $9DAB08
brr110: incbin "bin/brr110.bin"
org $9DB2F1
brr111: incbin "bin/brr111.bin"
org $9DC27B
brr112: incbin "bin/brr112.bin"
org $9DD7DB
brr113: incbin "bin/brr113.bin"
org $9E8000
brr114: incbin "bin/brr114.bin"
org $9E9D37
brr115: incbin "bin/brr115.bin"
org $9DF713
brr116: incbin "bin/brr116.bin"
org $9EB7A7
brr117: incbin "bin/brr117.bin"
org $9EC1C7
brr118: incbin "bin/brr118.bin"
org $9DF992
brr119: incbin "bin/brr119.bin"
org $9ECBD5
brr11A: incbin "bin/brr11A.bin"
org $9ED39A
brr11B: incbin "bin/brr11B.bin"
org $9ED6BB
brr11C: incbin "bin/brr11C.bin"
org $9CFECF
brr11D: incbin "bin/brr11D.bin"
org $9EE3BD
brr11E: incbin "bin/brr11E.bin"
org $9EEE88
brr11F: incbin "bin/brr11F.bin"
org $9F8000
brr120: incbin "bin/brr120.bin"
org $9F8AEF
brr121: incbin "bin/brr121.bin"
org $9F9F38
brr122: incbin "bin/brr122.bin"
org $97FF8C
brr123: incbin "bin/brr123.bin"
org $9FACCA
brr124: incbin "bin/brr124.bin"
org $9FC7EE
brr125: incbin "bin/brr125.bin"
org $9FCCBF
brr126: incbin "bin/brr126.bin"
org $9FD40F
brr127: incbin "bin/brr127.bin"
org $9DFDD3
brr128: incbin "bin/brr128.bin"
org $9FE24C
brr129: incbin "bin/brr129.bin"
org $9FE564
brr12A: incbin "bin/brr12A.bin"
org $A08000
brr12B: incbin "bin/brr12B.bin"
org $A08BEB
brr12C: incbin "bin/brr12C.bin"
org $9FF71C
brr12D: incbin "bin/brr12D.bin"
org $A097CD
brr12E: incbin "bin/brr12E.bin"
org $A09EF9
brr12F: incbin "bin/brr12F.bin"
org $A0AA81
brr130: incbin "bin/brr130.bin"
org $9FFAE8
brr131: incbin "bin/brr131.bin"
org $A0B34B
brr132: incbin "bin/brr132.bin"
org $9FFC86
brr133: incbin "bin/brr133.bin"
org $9DFF3B
brr134: incbin "bin/brr134.bin"
org $A0B729
brr135: incbin "bin/brr135.bin"
org $A0BFBD
brr136: incbin "bin/brr136.bin"
org $A0CABE
brr137: incbin "bin/brr137.bin"
org $A0CCD1
brr138: incbin "bin/brr138.bin"
org $A0D553
brr139: incbin "bin/brr139.bin"
org $A0DC01
brr13A: incbin "bin/brr13A.bin"
org $A0E030
brr13B: incbin "bin/brr13B.bin"
org $A0E468
brr13C: incbin "bin/brr13C.bin"
org $A0ECB4
brr13D: incbin "bin/brr13D.bin"
org $A0F386
brr13E: incbin "bin/brr13E.bin"
org $A0FAA9
brr13F: incbin "bin/brr13F.bin"
org $A18000
brr140: incbin "bin/brr140.bin"
org $A18E61
brr141: incbin "bin/brr141.bin"
org $A1A9BB
brr142: incbin "bin/brr142.bin"
org $A1C36E
brr143: incbin "bin/brr143.bin"
org $A1D4BA
brr144: incbin "bin/brr144.bin"
org $A1DDF9
brr145: incbin "bin/brr145.bin"
org $A1E903
brr146: incbin "bin/brr146.bin"
org $A1F2C9
brr147: incbin "bin/brr147.bin"
org $A28000
brr148: incbin "bin/brr148.bin"
org $A287F2
brr149: incbin "bin/brr149.bin"
org $A1F9FE
brr14A: incbin "bin/brr14A.bin"
org $A2EB0D
brr14B: incbin "bin/brr14B.bin"
org $9EFF4D
brr14C: incbin "bin/brr14C.bin"
org $A38000
brr14D: incbin "bin/brr14D.bin"
org $A386C9
brr14E: incbin "bin/brr14E.bin"
org $A38C72
brr14F: incbin "bin/brr14F.bin"
org $A39BE1
brr150: incbin "bin/brr150.bin"
org $A3A4BD
brr151: incbin "bin/brr151.bin"
org $A3AFBE
brr152: incbin "bin/brr152.bin"
org $A3B43E
brr153: incbin "bin/brr153.bin"
org $A1FCA1
brr154: incbin "bin/brr154.bin"
org $A3B9BA
brr155: incbin "bin/brr155.bin"
org $A2FCB3
brr156: incbin "bin/brr156.bin"
org $A3BDC5
brr157: incbin "bin/brr157.bin"
org $A3C083
brr158: incbin "bin/brr158.bin"
org $A3D8AA
brr159: incbin "bin/brr159.bin"
org $A48000
brr15A: incbin "bin/brr15A.bin"
org $A3E4EF
brr15B: incbin "bin/brr15B.bin"
org $9BFFA7
brr15C: incbin "bin/brr15C.bin"
org $9FFF83
brr15D: incbin "bin/brr15D.bin"
org $9DFFB0
brr15E: incbin "bin/brr15E.bin"
org $A3EEFD
brr15F: incbin "bin/brr15F.bin"
org $A4A42D
brr160: incbin "bin/brr160.bin"
org $A4AAC9
brr161: incbin "bin/brr161.bin"
org $A4B084
brr162: incbin "bin/brr162.bin"
org $A4B51F
brr163: incbin "bin/brr163.bin"
org $A4C017
brr164: incbin "bin/brr164.bin"
org $A4CBBA
brr165: incbin "bin/brr165.bin"
org $A4D8FB
brr166: incbin "bin/brr166.bin"
org $A4DC25
brr167: incbin "bin/brr167.bin"
org $A4E70B
brr168: incbin "bin/brr168.bin"
org $A58000
brr169: incbin "bin/brr169.bin"
org $A4F683
brr16A: incbin "bin/brr16A.bin"
org $A3FD0D
brr16B: incbin "bin/brr16B.bin"
org $A593DD
brr16C: incbin "bin/brr16C.bin"
org $A0FDF7
brr16D: incbin "bin/brr16D.bin"
org $A0FE36
brr16E: incbin "bin/brr16E.bin"
org $A59CEF
brr16F: incbin "bin/brr16F.bin"
org $A5A7F9
brr170: incbin "bin/brr170.bin"
org $A5B651
brr171: incbin "bin/brr171.bin"
org $A5BFA2
brr172: incbin "bin/brr172.bin"
org $A5C99E
brr173: incbin "bin/brr173.bin"
org $A5DE80
brr174: incbin "bin/brr174.bin"
org $A5E6A8
brr175: incbin "bin/brr175.bin"
org $A68000
brr176: incbin "bin/brr176.bin"
org $A68A29
brr177: incbin "bin/brr177.bin"
org $A6946D
brr178: incbin "bin/brr178.bin"
org $A69866
brr179: incbin "bin/brr179.bin"
org $A6A46C
brr17A: incbin "bin/brr17A.bin"
org $A6BC4B
brr17B: incbin "bin/brr17B.bin"
org $8BFFDA
brr17C: incbin "bin/brr17C.bin"
org $91FFCB
brr17D: incbin "bin/brr17D.bin"
org $A6C3F5
brr17E: incbin "bin/brr17E.bin"
org $A6CF86
brr17F: incbin "bin/brr17F.bin"
org $A6E59A
brr180: incbin "bin/brr180.bin"
org $A6EA1A
brr181: incbin "bin/brr181.bin"
org $A6F45E
brr182: incbin "bin/brr182.bin"
org $A6F6C2
brr183: incbin "bin/brr183.bin"
org $A78000
brr184: incbin "bin/brr184.bin"
org $A787AA
brr185: incbin "bin/brr185.bin"
org $A797FA
brr186: incbin "bin/brr186.bin"
org $A0FE75
brr187: incbin "bin/brr187.bin"
org $A6FAB2
brr188: incbin "bin/brr188.bin"
org $A7A94F
brr189: incbin "bin/brr189.bin"
org $A7AEE6
brr18A: incbin "bin/brr18A.bin"
org $A7B4D7
brr18B: incbin "bin/brr18B.bin"
org $A7BA02
brr18C: incbin "bin/brr18C.bin"
org $A7C0C2
brr18D: incbin "bin/brr18D.bin"
org $A7CC38
brr18E: incbin "bin/brr18E.bin"
org $A7D4F9
brr18F: incbin "bin/brr18F.bin"
org $A7DC1C
brr190: incbin "bin/brr190.bin"
org $A7E726
brr191: incbin "bin/brr191.bin"
org $A88000
brr192: incbin "bin/brr192.bin"
org $A7F896
brr193: incbin "bin/brr193.bin"
org $A88AB0
brr194: incbin "bin/brr194.bin"
org $A8915E
brr195: incbin "bin/brr195.bin"
org $A89815
brr196: incbin "bin/brr196.bin"
org $A89EBA
brr197: incbin "bin/brr197.bin"
org $A8A568
brr198: incbin "bin/brr198.bin"
org $A8AC0D
brr199: incbin "bin/brr199.bin"
org $A8B2B2
brr19A: incbin "bin/brr19A.bin"
org $A8BAEC
brr19B: incbin "bin/brr19B.bin"
org $A8C4DF
brr19C: incbin "bin/brr19C.bin"
org $A8CDC4
brr19D: incbin "bin/brr19D.bin"
org $A8DC6D
brr19E: incbin "bin/brr19E.bin"
org $A8E63C
brr19F: incbin "bin/brr19F.bin"
org $A8E9B7
brr1A0: incbin "bin/brr1A0.bin"
org $A0FF29
brr1A1: incbin "bin/brr1A1.bin"
org $A4FED8
brr1A2: incbin "bin/brr1A2.bin"
org $A0FF7A
brr1A3: incbin "bin/brr1A3.bin"
org $A3FF71
brr1A4: incbin "bin/brr1A4.bin"
org $A8EC24
brr1A5: incbin "bin/brr1A5.bin"
org $A8EEEB
brr1A6: incbin "bin/brr1A6.bin"
org $A8F51B
brr1A7: incbin "bin/brr1A7.bin"
org $A8F683
brr1A8: incbin "bin/brr1A8.bin"
org $A5FF29
brr1A9: incbin "bin/brr1A9.bin"
org $A8F845
brr1AA: incbin "bin/brr1AA.bin"
org $A98000
brr1AB: incbin "bin/brr1AB.bin"
org $A98879
brr1AC: incbin "bin/brr1AC.bin"
org $A98CC3
brr1AD: incbin "bin/brr1AD.bin"
org $A99569
brr1AE: incbin "bin/brr1AE.bin"
org $A9CC26
brr1AF: incbin "bin/brr1AF.bin"
org $A9D3BE
brr1B0: incbin "bin/brr1B0.bin"
org $AA8000
brr1B1: incbin "bin/brr1B1.bin"
org $AAC608
brr1B2: incbin "bin/brr1B2.bin"
org $A9E186
brr1B3: incbin "bin/brr1B3.bin"
org $A9EE01
brr1B4: incbin "bin/brr1B4.bin"
org $A6FECF
brr1B5: incbin "bin/brr1B5.bin"
org $A9F197
brr1B6: incbin "bin/brr1B6.bin"
org $A5FF83
brr1B7: incbin "bin/brr1B7.bin"
org $AAEDCB
brr1B8: incbin "bin/brr1B8.bin"
org $A9F89F
brr1B9: incbin "bin/brr1B9.bin"
org $A8FE1B
brr1BA: incbin "bin/brr1BA.bin"
org $AB8000
brr1BB: incbin "bin/brr1BB.bin"
org $AB88DC
brr1BC: incbin "bin/brr1BC.bin"
org $AB9CB9
brr1BD: incbin "bin/brr1BD.bin"
org $ABBCD2
brr1BE: incbin "bin/brr1BE.bin"
org $A9FAF1
brr1BF: incbin "bin/brr1BF.bin"
org $ABC932
brr1C0: incbin "bin/brr1C0.bin"
org $ABDAA2
brr1C1: incbin "bin/brr1C1.bin"
org $A2FFB9
brr1C2: incbin "bin/brr1C2.bin"
org $A7FF95
brr1C3: incbin "bin/brr1C3.bin"
org $ABF146
brr1C4: incbin "bin/brr1C4.bin"
org $AC8000
brr1C5: incbin "bin/brr1C5.bin"
org $A9FDF7
brr1C6: incbin "bin/brr1C6.bin"
org $AC8F81
brr1C7: incbin "bin/brr1C7.bin"
org $AAF94A
brr1C8: incbin "bin/brr1C8.bin"
org $AAFB0C
brr1C9: incbin "bin/brr1C9.bin"
org $AC99B3
brr1CA: incbin "bin/brr1CA.bin"
org $ACA59E
brr1CB: incbin "bin/brr1CB.bin"
org $ACB3FF
brr1CC: incbin "bin/brr1CC.bin"
org $ACB87F
brr1CD: incbin "bin/brr1CD.bin"
org $ACBB07
brr1CE: incbin "bin/brr1CE.bin"
org $ACC0E6
brr1CF: incbin "bin/brr1CF.bin"
org $ACC887
brr1D0: incbin "bin/brr1D0.bin"
org $ACCC02
brr1D1: incbin "bin/brr1D1.bin"
org $ACD1A2
brr1D2: incbin "bin/brr1D2.bin"
org $ACE348
brr1D3: incbin "bin/brr1D3.bin"
org $ACE8D6
brr1D4: incbin "bin/brr1D4.bin"
org $ACF0FE
brr1D5: incbin "bin/brr1D5.bin"
org $A8FEF3
brr1D6: incbin "bin/brr1D6.bin"
org $AAFE2D
brr1D7: incbin "bin/brr1D7.bin"
org $A8FF68
brr1D8: incbin "bin/brr1D8.bin"
org $ACF5BD
brr1D9: incbin "bin/brr1D9.bin"
org $AD8000
brr1DA: incbin "bin/brr1DA.bin"
org $AD8225
brr1DB: incbin "bin/brr1DB.bin"
org $A9FF0E
brr1DC: incbin "bin/brr1DC.bin"
org $AD8DE3
brr1DD: incbin "bin/brr1DD.bin"
org $AD9C5F
brr1DE: incbin "bin/brr1DE.bin"
org $ADAA9C
brr1DF: incbin "bin/brr1DF.bin"
org $A9FF71
brr1E0: incbin "bin/brr1E0.bin"
org $ADB141
brr1E1: incbin "bin/brr1E1.bin"
org $ADBA26
brr1E2: incbin "bin/brr1E2.bin"
org $ADC164
brr1E3: incbin "bin/brr1E3.bin"
org $ADD6B2
brr1E4: incbin "bin/brr1E4.bin"
org $ADDCBE
brr1E5: incbin "bin/brr1E5.bin"
org $ADEF69
brr1E6: incbin "bin/brr1E6.bin"
org $AE8000
brr1E7: incbin "bin/brr1E7.bin"
org $AE8453
brr1E8: incbin "bin/brr1E8.bin"
org $AE8C06
brr1E9: incbin "bin/brr1E9.bin"
org $AAFF20
brr1EA: incbin "bin/brr1EA.bin"
org $AE9287
brr1EB: incbin "bin/brr1EB.bin"
org $AE965C
brr1EC: incbin "bin/brr1EC.bin"
org $AE9CEF
brr1ED: incbin "bin/brr1ED.bin"
org $ACFE3F
brr1EE: incbin "bin/brr1EE.bin"
org $ADFCE9
brr1EF: incbin "bin/brr1EF.bin"
org $ABFEAB
brr1F0: incbin "bin/brr1F0.bin"
org $99FFC2
brr1F1: incbin "bin/brr1F1.bin"
org $AEA3F7
brr1F2: incbin "bin/brr1F2.bin"
org $AEAA93
brr1F3: incbin "bin/brr1F3.bin"
org $AEB141
brr1F4: incbin "bin/brr1F4.bin"
org $AEB77A
brr1F5: incbin "bin/brr1F5.bin"
org $AEBA02
brr1F6: incbin "bin/brr1F6.bin"
org $AEC005
brr1F7: incbin "bin/brr1F7.bin"
org $AEC7F7
brr1F8: incbin "bin/brr1F8.bin"
org $AECAD0
brr1F9: incbin "bin/brr1F9.bin"
org $AED1E1
brr1FA: incbin "bin/brr1FA.bin"
org $AED8A1
brr1FB: incbin "bin/brr1FB.bin"
org $AEE4D4
brr1FC: incbin "bin/brr1FC.bin"
org $AEE7AD
brr1FD: incbin "bin/brr1FD.bin"
org $AF8000
brr1FE: incbin "bin/brr1FE.bin"
org $AFA664
brr1FF: incbin "bin/brr1FF.bin"
org $AFBFEA
brr200: incbin "bin/brr200.bin"
org $AEF31A
brr201: incbin "bin/brr201.bin"
org $AFDA5A
brr202: incbin "bin/brr202.bin"
org $B08000
brr203: incbin "bin/brr203.bin"
org $AFF26F
brr204: incbin "bin/brr204.bin"
org $AEF8E7
brr205: incbin "bin/brr205.bin"
org $B0960B
brr206: incbin "bin/brr206.bin"
org $B09B51
brr207: incbin "bin/brr207.bin"
org $B0A1AE
brr208: incbin "bin/brr208.bin"
org $B0CE30
brr209: incbin "bin/brr209.bin"
org $ABFF71
brr20A: incbin "bin/brr20A.bin"
org $ADFF5F
brr20B: incbin "bin/brr20B.bin"
org $B0E432
brr20C: incbin "bin/brr20C.bin"
org $B0EC5A
brr20D: incbin "bin/brr20D.bin"
org $B0EEA3
brr20E: incbin "bin/brr20E.bin"
org $B18000
brr20F: incbin "bin/brr20F.bin"
org $B18DB6
brr210: incbin "bin/brr210.bin"
org $B196BF
brr211: incbin "bin/brr211.bin"
org $B0FC50
brr212: incbin "bin/brr212.bin"
org $B1A262
brr213: incbin "bin/brr213.bin"
org $B1B00F
brr214: incbin "bin/brr214.bin"
org $AAFFA7
brr215: incbin "bin/brr215.bin"
org $ADFFB9
brr216: incbin "bin/brr216.bin"
org $B1CE27
brr217: incbin "bin/brr217.bin"
org $AEFDE5
brr218: incbin "bin/brr218.bin"
org $B1D079
brr219: incbin "bin/brr219.bin"
org $AEFE51
brr21A: incbin "bin/brr21A.bin"
org $B1DDC3
brr21B: incbin "bin/brr21B.bin"
org $B1E300
brr21C: incbin "bin/brr21C.bin"
org $B1E83D
brr21D: incbin "bin/brr21D.bin"
org $B1ED7A
brr21E: incbin "bin/brr21E.bin"
org $B1F869
brr21F: incbin "bin/brr21F.bin"
org $B28000
brr220: incbin "bin/brr220.bin"
org $B1FDA6
brr221: incbin "bin/brr221.bin"
org $B299B3
brr222: incbin "bin/brr222.bin"
org $B29B51
brr223: incbin "bin/brr223.bin"
org $B29CEF
brr224: incbin "bin/brr224.bin"
org $B2A5CB
brr225: incbin "bin/brr225.bin"
org $B2C338
brr226: incbin "bin/brr226.bin"
org $B2CE03
brr227: incbin "bin/brr227.bin"
org $B2D8CE
brr228: incbin "bin/brr228.bin"
org $B2E399
brr229: incbin "bin/brr229.bin"
org $B2EF60
brr22A: incbin "bin/brr22A.bin"
org $B2F38F
brr22B: incbin "bin/brr22B.bin"
org $B2FB1E
brr22C: incbin "bin/brr22C.bin"
org $B2FD5E
brr22D: incbin "bin/brr22D.bin"
org $B38000
brr22E: incbin "bin/brr22E.bin"
org $B39008
brr22F: incbin "bin/brr22F.bin"
org $B3940A
brr230: incbin "bin/brr230.bin"
org $B398ED
brr231: incbin "bin/brr231.bin"
org $B3A2E0
brr232: incbin "bin/brr232.bin"
org $B3ADF3
brr233: incbin "bin/brr233.bin"
org $B48000
brr234: incbin "bin/brr234.bin"
org $B58000
brr235: incbin "bin/brr235.bin"
org $B3C944
brr236: incbin "bin/brr236.bin"
org $B3CD19
brr237: incbin "bin/brr237.bin"
org $B3E741
brr238: incbin "bin/brr238.bin"
org $B3F065
brr239: incbin "bin/brr239.bin"
org $B4D3EB
brr23A: incbin "bin/brr23A.bin"
org $B4E216
brr23B: incbin "bin/brr23B.bin"
org $B3F89F
brr23C: incbin "bin/brr23C.bin"
org $AEFF8C
brr23D: incbin "bin/brr23D.bin"
org $AFFF56
brr23E: incbin "bin/brr23E.bin"
org $B0FF05
brr23F: incbin "bin/brr23F.bin"
org $B0FF71
brr240: incbin "bin/brr240.bin"
org $B1FF44
brr241: incbin "bin/brr241.bin"
org $B2FF44
brr242: incbin "bin/brr242.bin"
org $B3FC59
brr243: incbin "bin/brr243.bin"
org $B3FCC5
brr244: incbin "bin/brr244.bin"
org $B3FD31
brr245: incbin "bin/brr245.bin"
org $B3FD9D
brr246: incbin "bin/brr246.bin"
org $B3FE09
brr247: incbin "bin/brr247.bin"
org $B3FE75
brr248: incbin "bin/brr248.bin"
org $B3FEE1
brr249: incbin "bin/brr249.bin"
org $B3FF4D
brr24A: incbin "bin/brr24A.bin"
org $B4EEE2
brr24B: incbin "bin/brr24B.bin"
org $B4EF4E
brr24C: incbin "bin/brr24C.bin"
org $B4EFBA
brr24D: incbin "bin/brr24D.bin"
org $B4F026
brr24E: incbin "bin/brr24E.bin"
org $B4F092
brr24F: incbin "bin/brr24F.bin"
org $B4F0FE
brr250: incbin "bin/brr250.bin"
org $B4F16A
brr251: incbin "bin/brr251.bin"
org $B4F1D6
brr252: incbin "bin/brr252.bin"
org $B4F242
brr253: incbin "bin/brr253.bin"
org $B4F2AE
brr254: incbin "bin/brr254.bin"
org $B4F31A
brr255: incbin "bin/brr255.bin"
org $B4F386
brr256: incbin "bin/brr256.bin"
org $B4F3F2
brr257: incbin "bin/brr257.bin"
org $B4F45E
brr258: incbin "bin/brr258.bin"
org $B4F4CA
brr259: incbin "bin/brr259.bin"
org $B4F536
brr25A: incbin "bin/brr25A.bin"
org $B4F5A2
brr25B: incbin "bin/brr25B.bin"
org $B4F60E
brr25C: incbin "bin/brr25C.bin"
org $B4F67A
brr25D: incbin "bin/brr25D.bin"
org $B4F6E6
brr25E: incbin "bin/brr25E.bin"
org $B4F752
brr25F: incbin "bin/brr25F.bin"
org $B4F7BE
brr260: incbin "bin/brr260.bin"
org $B4F82A
brr261: incbin "bin/brr261.bin"
org $B4F896
brr262: incbin "bin/brr262.bin"
org $B4F902
brr263: incbin "bin/brr263.bin"
org $B4F96E
brr264: incbin "bin/brr264.bin"
org $B4F9DA
brr265: incbin "bin/brr265.bin"
org $B4FA46
brr266: incbin "bin/brr266.bin"
org $B4FAB2
brr267: incbin "bin/brr267.bin"
org $B4FB1E
brr268: incbin "bin/brr268.bin"
org $B4FB8A
brr269: incbin "bin/brr269.bin"
org $B4FBF6
brr26A: incbin "bin/brr26A.bin"
org $B4FC62
brr26B: incbin "bin/brr26B.bin"
org $B4FCCE
brr26C: incbin "bin/brr26C.bin"
org $B4FD3A
brr26D: incbin "bin/brr26D.bin"
org $B4FDA6
brr26E: incbin "bin/brr26E.bin"
org $B4FE12
brr26F: incbin "bin/brr26F.bin"
org $B4FE7E
brr270: incbin "bin/brr270.bin"
org $B4FEEA
brr271: incbin "bin/brr271.bin"
org $B4FF56
brr272: incbin "bin/brr272.bin"
org $B5D3EB
brr273: incbin "bin/brr273.bin"
org $B5D457
brr274: incbin "bin/brr274.bin"
org $B5D4C3
brr275: incbin "bin/brr275.bin"
org $B5D52F
brr276: incbin "bin/brr276.bin"
org $B5D59B
brr277: incbin "bin/brr277.bin"
org $B5D607
brr278: incbin "bin/brr278.bin"
org $B5D673
brr279: incbin "bin/brr279.bin"
org $B5D6DF
brr27A: incbin "bin/brr27A.bin"
org $B5D74B
brr27B: incbin "bin/brr27B.bin"
org $B5D7B7
brr27C: incbin "bin/brr27C.bin"
org $B5D823
brr27D: incbin "bin/brr27D.bin"
org $B5E51C
brr27E: incbin "bin/brr27E.bin"
org $B5E819
brr27F: incbin "bin/brr27F.bin"
org $B5EB31
brr280: incbin "bin/brr280.bin"
org $B5EC75
brr281: incbin "bin/brr281.bin"
org $B5EE0A
brr282: incbin "bin/brr282.bin"
org $B5EEBE
brr283: incbin "bin/brr283.bin"
org $B5EFBA
brr284: incbin "bin/brr284.bin"
org $B5F053
brr285: incbin "bin/brr285.bin"
org $B5F32C
brr286: incbin "bin/brr286.bin"
org $B68000
brr287: incbin "bin/brr287.bin"
org $B5F37D
brr288: incbin "bin/brr288.bin"
org $B5F7D0
brr289: incbin "bin/brr289.bin"
org $B5FBF6
brr28A: incbin "bin/brr28A.bin"
org $B68C96
brr28B: incbin "bin/brr28B.bin"
org $B68FF6
brr28C: incbin "bin/brr28C.bin"
org $B692EA
brr28D: incbin "bin/brr28D.bin"
org $B69722
brr28E: incbin "bin/brr28E.bin"
org $B69DA3
brr28F: incbin "bin/brr28F.bin"
org $B6A010
brr290: incbin "bin/brr290.bin"
org $B6A544
brr291: incbin "bin/brr291.bin"
org $B6A9FA
brr292: incbin "bin/brr292.bin"
org $B6B03C
brr293: incbin "bin/brr293.bin"
org $B6B543
brr294: incbin "bin/brr294.bin"
org $B6C44F
brr295: incbin "bin/brr295.bin"
org $B6C90E
brr296: incbin "bin/brr296.bin"
org $B6D87D
brr297: incbin "bin/brr297.bin"
org $B6F872
brr298: incbin "bin/brr298.bin"
org $B78000
brr299: incbin "bin/brr299.bin"
org $B788B8
brr29A: incbin "bin/brr29A.bin"
org $B79719
brr29B: incbin "bin/brr29B.bin"
org $B7A985
brr29C: incbin "bin/brr29C.bin"
org $B7ACB8
brr29D: incbin "bin/brr29D.bin"
org $B7B4FB
brr29E: incbin "bin/brr29E.bin"
org $B7CEF6
brr29F: incbin "bin/brr29F.bin"
org $B7D388
brr2A0: incbin "bin/brr2A0.bin"
org $B7DBCB
brr2A1: incbin "bin/brr2A1.bin"
org $B7E363
brr2A2: incbin "bin/brr2A2.bin"
org $B7EA98
brr2A3: incbin "bin/brr2A3.bin"
org $B7F1C4
brr2A4: incbin "bin/brr2A4.bin"
org $B88000
brr2A5: incbin "bin/brr2A5.bin"
org $B88D65
brr2A6: incbin "bin/brr2A6.bin"
org $B896D1
brr2A7: incbin "bin/brr2A7.bin"
org $B8A343
brr2A8: incbin "bin/brr2A8.bin"
org $B8A961
brr2A9: incbin "bin/brr2A9.bin"
org $B7FE24
brr2AA: incbin "bin/brr2AA.bin"
org $B6FF83
brr2AB: incbin "bin/brr2AB.bin"
org $B7FEA2
brr2AC: incbin "bin/brr2AC.bin"
org $B7FEFC
brr2AD: incbin "bin/brr2AD.bin"
org $B8ACE5
brr2AE: incbin "bin/brr2AE.bin"
org $B7FF56
brr2AF: incbin "bin/brr2AF.bin"
org $B8ADCF
brr2B0: incbin "bin/brr2B0.bin"
org $B8AE29
brr2B1: incbin "bin/brr2B1.bin"
org $B8B006
brr2B2: incbin "bin/brr2B2.bin"
org $B8BB34
brr2B3: incbin "bin/brr2B3.bin"
org $B8CF3E
brr2B4: incbin "bin/brr2B4.bin"
org $B8D17E
brr2B5: incbin "bin/brr2B5.bin"
org $B8E702
brr2B6: incbin "bin/brr2B6.bin"
org $B8E76E
brr2B7: incbin "bin/brr2B7.bin"
org $B98000
brr2B8: incbin "bin/brr2B8.bin"
org $B8F4AF
brr2B9: incbin "bin/brr2B9.bin"
org $B98FF6
brr2BA: incbin "bin/brr2BA.bin"
org $B9937A
brr2BB: incbin "bin/brr2BB.bin"
org $B99959
brr2BC: incbin "bin/brr2BC.bin"
org $B8FCB3
brr2BD: incbin "bin/brr2BD.bin"
org $B99DD9
brr2BE: incbin "bin/brr2BE.bin"
org $B8FE09
brr2BF: incbin "bin/brr2BF.bin"
org $B9AB35
brr2C0: incbin "bin/brr2C0.bin"
org $B9B61B
brr2C1: incbin "bin/brr2C1.bin"
org $B9BCC0
brr2C2: incbin "bin/brr2C2.bin"
org $B8FE5A
brr2C3: incbin "bin/brr2C3.bin"
org $B9C338
brr2C4: incbin "bin/brr2C4.bin"
org $B9CB72
brr2C5: incbin "bin/brr2C5.bin"
org $B9DE9B
brr2C6: incbin "bin/brr2C6.bin"
org $B9E2CA
brr2C7: incbin "bin/brr2C7.bin"
org $B9E789
brr2C8: incbin "bin/brr2C8.bin"
org $B9F479
brr2C9: incbin "bin/brr2C9.bin"
org $BA8000
brr2CA: incbin "bin/brr2CA.bin"
org $BA8BE2
brr2CB: incbin "bin/brr2CB.bin"
org $BA978E
brr2CC: incbin "bin/brr2CC.bin"
org $BAA250
brr2CD: incbin "bin/brr2CD.bin"
org $BAABCE
brr2CE: incbin "bin/brr2CE.bin"
org $BAB5A6
brr2CF: incbin "bin/brr2CF.bin"
org $B8FEAB
brr2D0: incbin "bin/brr2D0.bin"
org $BABA4A
brr2D1: incbin "bin/brr2D1.bin"
org $B9FC6B
brr2D2: incbin "bin/brr2D2.bin"
org $BAC1BE
brr2D3: incbin "bin/brr2D3.bin"
org $BACEF6
brr2D4: incbin "bin/brr2D4.bin"
org $B9FE75
brr2D5: incbin "bin/brr2D5.bin"
org $BAD71E
brr2D6: incbin "bin/brr2D6.bin"
org $BADB20
brr2D7: incbin "bin/brr2D7.bin"
org $BADF73
brr2D8: incbin "bin/brr2D8.bin"
org $BAE35A
brr2D9: incbin "bin/brr2D9.bin"
org $BAE72F
brr2DA: incbin "bin/brr2DA.bin"
org $BAF7EB
brr2DB: incbin "bin/brr2DB.bin"
org $B8FF3B
brr2DC: incbin "bin/brr2DC.bin"
org $BB8000
brr2DD: incbin "bin/brr2DD.bin"
org $BB8FE4
brr2DE: incbin "bin/brr2DE.bin"
org $BB9F14
brr2DF: incbin "bin/brr2DF.bin"
org $BBA61C
brr2E0: incbin "bin/brr2E0.bin"
org $BBAADB
brr2E1: incbin "bin/brr2E1.bin"
org $BBB77A
brr2E2: incbin "bin/brr2E2.bin"
org $BBC6E0
brr2E3: incbin "bin/brr2E3.bin"
org $BBDEBF
brr2E4: incbin "bin/brr2E4.bin"
org $BC8000
brr2E5: incbin "bin/brr2E5.bin"
org $BBF278
brr2E6: incbin "bin/brr2E6.bin"
org $BCA67F
brr2E7: incbin "bin/brr2E7.bin"
org $BBF455
brr2E8: incbin "bin/brr2E8.bin"
org $9AFFC2
brr2E9: incbin "bin/brr2E9.bin"
org $BBFB39
brr2EA: incbin "bin/brr2EA.bin"
org $BCD12D
brr2EB: incbin "bin/brr2EB.bin"
org $BCD8CE
brr2EC: incbin "bin/brr2EC.bin"
org $BCDF19
brr2ED: incbin "bin/brr2ED.bin"
org $BCE63C
brr2EE: incbin "bin/brr2EE.bin"
org $BCEF21
brr2EF: incbin "bin/brr2EF.bin"
org $BD8000
brr2F0: incbin "bin/brr2F0.bin"
org $BD8A05
brr2F1: incbin "bin/brr2F1.bin"
org $BD93CB
brr2F2: incbin "bin/brr2F2.bin"
org $BD9A9D
brr2F3: incbin "bin/brr2F3.bin"
org $BCF9FE
brr2F4: incbin "bin/brr2F4.bin"
org $BDA1C9
brr2F5: incbin "bin/brr2F5.bin"
org $BDA7CC
brr2F6: incbin "bin/brr2F6.bin"
org $BDAC82
brr2F7: incbin "bin/brr2F7.bin"
org $BDB2A0
brr2F8: incbin "bin/brr2F8.bin"
org $BAFF20
brr2F9: incbin "bin/brr2F9.bin"
org $BBFD5E
brr2FA: incbin "bin/brr2FA.bin"
org $B1FFB0
brr2FB: incbin "bin/brr2FB.bin"
org $BDC4FA
brr2FC: incbin "bin/brr2FC.bin"
org $BDCDDF
brr2FD: incbin "bin/brr2FD.bin"
org $BDDCE2
brr2FE: incbin "bin/brr2FE.bin"
org $BDE456
brr2FF: incbin "bin/brr2FF.bin"
org $BDF443
brr300: incbin "bin/brr300.bin"
org $BE8000
brr301: incbin "bin/brr301.bin"
org $BBFDC1
brr302: incbin "bin/brr302.bin"
org $BBFEF3
brr303: incbin "bin/brr303.bin"
org $BDF8C3
brr304: incbin "bin/brr304.bin"
org $BEA0A0
brr305: incbin "bin/brr305.bin"
org $BEA841
brr306: incbin "bin/brr306.bin"
org $BEADEA
brr307: incbin "bin/brr307.bin"
org $BEB0F9
brr308: incbin "bin/brr308.bin"
org $BEB6E1
brr309: incbin "bin/brr309.bin"
org $BEBD7D
brr30A: incbin "bin/brr30A.bin"
org $BEC6F2
brr30B: incbin "bin/brr30B.bin"
org $B2FFB0
brr30C: incbin "bin/brr30C.bin"
org $BECFFB
brr30D: incbin "bin/brr30D.bin"
org $BED541
brr30E: incbin "bin/brr30E.bin"
org $BEE0D2
brr30F: incbin "bin/brr30F.bin"
org $BEF161
brr310: incbin "bin/brr310.bin"
org $BEF52D
brr311: incbin "bin/brr311.bin"
org $BF8000
brr312: incbin "bin/brr312.bin"
org $BF8D2F
brr313: incbin "bin/brr313.bin"
org $BF9A79
brr314: incbin "bin/brr314.bin"
org $BFA127
brr315: incbin "bin/brr315.bin"
org $BFB699
brr316: incbin "bin/brr316.bin"
org $BFC2C3
brr317: incbin "bin/brr317.bin"
org $BFD7B7
brr318: incbin "bin/brr318.bin"
org $BDFD79
brr319: incbin "bin/brr319.bin"
org $BCFEFC
brr31A: incbin "bin/brr31A.bin"
org $BFE0AE
brr31B: incbin "bin/brr31B.bin"
org $BDFEB4
brr31C: incbin "bin/brr31C.bin"
org $BFE5BE
brr31D: incbin "bin/brr31D.bin"
org $D2F88B
brr31E: incbin "bin/brr31E.bin"
org $D77658
brr31F: incbin "bin/brr31F.bin"
org $E5459E
brr320: incbin "bin/brr320.bin"
org $E7F3B6
brr321: incbin "bin/brr321.bin"
org $E8EE7D
brr322: incbin "bin/brr322.bin"
org $C8F96B
brr323: incbin "bin/brr323.bin"
org $BCFF7A
brr324: incbin "bin/brr324.bin"
org $BDFF56
brr325: incbin "bin/brr325.bin"
org $BEFE5A
brr326: incbin "bin/brr326.bin"
org $BFFC35
brr327: incbin "bin/brr327.bin"
org $BFFD3A
brr328: incbin "bin/brr328.bin"
org $BFFDB8
brr329: incbin "bin/brr329.bin"
org $C5FD3F
brr32A: incbin "bin/brr32A.bin"


org !SPCProgramLocation
incbin "bin/main.bin"