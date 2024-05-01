!freeram        = $18E6

!base1 = $0000
!base2 = $0000

if read1($00FFD5) == $23
sa1rom
!base1 = $3000
!base2 = $6000
endif

;Multiple Main Map Tracks by smkdan (?)
;Adapted for asar and SA-1 by DiscoTheBat
;This patch allows you to have multiple songs play on the main Overworld map.  
;It's very useful for those whose main maps contain more than one world theme.
;You probably shouldn't use this with AddMusic 4.05. It's better to use AddMusicK to ensure
;SNES compatibility.
;$04/DBFB 8D FB 1D    STA $1DFB  [$04:1DFB]

;once at load

org $048E38
	SEP #$30
	autoclean JML Music

org $04DBFB
	autoclean JML TestMusicChange

;every frame

org $048246
	autoclean JML MusicAll
	NOP

;*rats tag*
freecode
Music:
	LDY $0DB3|!base2	;Load Player's character on Index Y
	LDX $1F11|!base2,y	;main OW only for both characters
	BEQ .new
.old
	LDA.l $048D8A,x		;original music  
	BRA .return
.new
	JSR GetMusicIndex
	LDA.l MusicTBL,x
	STA !freeram|!base2	;used later on
.return
	STA $1DFB|!base2	; Store value from table to the music register.
	PLB
	RTL

;---
MusicAll:
	LDY $0DB3|!base2	;Load Player on Y
	LDA $1F11|!base2,y	;main map only
	BNE .submap
.mainmap
	JSR GetMusicIndex
	LDA.l MusicTBL,x
	CMP !freeram|!base2	;want to change?
	BEQ .return
.change
	STA $1DFB|!base2	;different track, so change it
	STA !freeram|!base2	;new music index stored for future checks
.return
	JML $048264

.submap
	LDA #$FF	;reset free RAM for next entry
	STA !freeram|!base2
	BRA .return

;---
TestMusicChange:
	CPX #$00	;main map does not have this applied
	BEQ .return
.submap
	STA $1DFB|!base2	;store original submap music
.return
	STZ $1B9E|!base2
	JML $04DC01

;---
;OUT:
;X: music index for this position

GetMusicIndex:
	LDX $0DD6|!base2	;Get player OW to be on X
	LDA $1F21|!base2,x	;Thus we can easily set up variables without branches
	ASL #3
	AND #$F0
	PHA
	LDA $1F1F|!base2,x
	LSR
	ORA $01,s
	STA $01,s
	PLX
	RTS

MusicTBL:	;Each byte corresponds to a 32x32 block on the main map.
	;Also, put instructions on the table to help users find their way on OW Map
	;Let's say, if you need to change music at address X:$28 Y:$C
	;You would check the table for the X28 mark and then the YC mark.
	;These X/Y stuff are 32x32 coordinates on LM's OW Editor, check it up
	;Don't forget to read the readme for more info!

  db $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C3, $C3, $C3, $C3, $C3, $C3 
  db $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C3, $C3, $C3, $C3, $C3, $C3 
  db $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C3, $C1, $C3, $C3, $C3, $C3, $C3, $C3, $C3 
  db $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C3, $C3, $C3, $C3, $C3, $C3, $C3, $C3, $C3 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C3, $C3, $C3, $C3, $C3, $C3, $C3, $C3, $C3, $C3 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C3, $C3, $C3, $C3, $C4, $C4, $C3, $C3, $C3 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C4, $C3, $C3, $C3, $C3, $C3, $C3, $C3, $C3 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C4, $C4, $C3, $C3, $C3, $C3, $C3, $C3, $C3 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C3, $C3, $C3, $C3, $C3, $C3, $C3 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C3, $C3, $C3, $C3, $C3, $C4, $C4 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C3, $C3, $C3, $C3, $C3, $C4, $C4 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C0, $C0, $C0, $C0, $C3, $C3, $C3, $C4, $C4 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C0, $C0, $C0, $C0, $C0, $C0, $C4, $C4, $C4, $C4 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C0, $C0, $C0, $C0, $C0, $C0, $C4, $C4, $C4, $C4 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C0, $C0, $C0, $C0, $C0, $C0, $C4, $C4, $C4, $C4 
  db $C2, $C2, $C2, $C2, $C2, $C2, $C2, $C0, $C0, $C0, $C0, $C0, $C4, $C4, $C4, $C4 