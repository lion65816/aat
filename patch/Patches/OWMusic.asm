;Multiple Main Map Tracks by smkdan (?)
;Adapted for asar and SA-1 by DiscoTheBat
;Updated by ASMagician Maks
;This patch allows you to have multiple songs play on the main Overworld map.
;It's very useful for those whose main maps contain more than one world theme.


;In vanilla, music is updated after the destination of an exit path is fully visible.
;With AMK it's better if it's done while the screen is black however.
;For vanilla behvaiour, set this to 1
!ChangeMusicAfterFade	= 0
;In vanilla, music remains silent after an earthquake event, until a submap transition happens.
;For vanilla behaviour, set this to 0
!ChangeMusicAfterEarthquake	= 1
;In vanilla, beating a boss in most levels causes the overworld to play no music.
;This only happens in vanilla when auto-walk after the event would load a new submap, this is to prevent previous map music from playing for a few seconds.
;To find exceptions to this rule, see $048D74.
;For vanilla behaviour, set this to 1
!SilenceAfterBoss	= 0
;In vanilla, beating Sunken Ghost Ship always plays silence on the overworld
;This also prevents the boss defeated flag from being cleared, leading to oddities with Yoshi and goal tapes.
;For vanilla behaviour, set this to $18
!SunkenGhostShipLvl	= $FF

!dp = $0000
!addr = $0000
!bank = $800000

if read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!bank = $000000
endif

;Has to be cleared at overworld load
!freeram	= $18E6|!addr



org $0483F7
	JSL EarthquakeMusicChange
	NOP

org $048DD8
dw !SunkenGhostShipLvl

org $048E2E
if !SilenceAfterBoss
	db $F0
else
	db $80
endif

org $048E40
	autoclean JSL InitialLoadMusic

org $04DBCF
	BRA +
	NOP #6
+
org $04DBF7
	autoclean JML TestMusicChange


if read1($0491E1) != $FF	;AMK check

org $04DBE0	;Skip the 2 player check
	db $80

;Code copied from tweaks.asm
org $049882	;Check what music to play after making sure camera is in bounds
JMP OWMusicHijack
org $049AC2	;This one only runs when loading camera position for a submap via exit path/star/pipe
JMP OWMusicHijack

org $04FFB1			;5 free bytes in bank 4
OWMusicHijack:
	SEP #$30
	JMP $DBD7
endif



freecode
InitialLoadMusic:
	BNE .submap
	JSR GetMusicIndex
	LDA.l MusicTBL,x
	BRA +
.submap
	TAX
	LDA.l $048D8A|!bank,x
+
	STA !freeram
if read1($048E44) == $EA
	STA $1DFB|!addr	;AMK gets rid of this opcode
endif
	RTL

TestMusicChange:
	LDA $13D9|!addr
	CMP #$07
	BEQ .ret
	CMP #$0A
	BNE .checksilence
	LDA $1DE8|!addr
	BEQ .ret
	CMP #$07
if !ChangeMusicAfterFade
	BNE .ret
else
	BNE +
endif
	STZ $1DE8|!addr
	LDA #$04
	STA $13D9|!addr
if !ChangeMusicAfterFade
	STZ $1B9E|!addr
	BRA .forcechange
else
	BRA .forcechange
+
	LDA $1B9E|!addr	;Only change music now if it's an exit path and not player switch
	STZ $1B9E|!addr
	BNE .forcechange
	BRA  .ret
endif
.checksilence
	LDA !freeram
	BEQ .ret
.forcechange
	DEX
	BPL .submap
	JSR GetMusicIndex
	LDA.l MusicTBL,x
	BRA +
.submap
	LDA.l $048D8A+1|!bank,x
+
	CMP !freeram
	BEQ .ret
	STA !freeram
	STA $1DFB|!addr
.ret
	JML $04DC01|!bank

EarthquakeMusicChange:
if !ChangeMusicAfterEarthquake
	LDA #$FF
	STA !freeram
else
	STZ !freeram
endif
	LDA $13D9|!addr
	CMP #$02
	RTL

;---
;OUT:
;X: music index for this position

GetMusicIndex:
	LDX $0DD6|!addr	;Get player OW to be on X
	LDA $1F21|!addr,x	;Thus we can easily set up variables without branches
	ASL #3
	AND #$F0
	PHA
	LDA $1F1F|!addr,x
	LSR
	ORA $01,s
	STA $01,s
	PLX
	RTS



	;Each byte corresponds to a 32x32 block on the main map.
	;Let's say, if you need to change music at address X:$28 Y:$C
	;You would check the table for the X28 mark and then the Y0C mark.
	;These X/Y stuff are 32x32 coordinates on LM's OW Editor, check it out
	;Don't forget to read the readme for more info!
MusicTBL:
if read1($0491E1) == $FF	;AMK check
  ;X00 X04 X08 X0C X10 X14 X18 X1C X20 X24 X28 X2C X30 X34 X38 X3C
  
db $C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C3,$C3,$C3,$C3,$C3,$C3	;Y00
db $C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C3,$C3,$C3,$C3,$C3,$C3	;Y00
db $C1,$C1,$C1,$C1,$C1,$C1,$C1,$C3,$C1,$C3,$C3,$C3,$C3,$C3,$C3,$C3	;Y08
db $C1,$C1,$C1,$C1,$C1,$C1,$C1,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3	;Y0C 
db $C2,$C2,$C2,$C2,$C2,$C2,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3	;Y10 
db $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C3,$C3,$C3,$C3,$C4,$C4,$C3,$C3,$C3	;Y14
db $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C4,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3	;Y18 
db $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C4,$C4,$C3,$C3,$C3,$C3,$C3,$C3,$C3	;Y1C 
db $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C3,$C3,$C3,$C3,$C3,$C3,$C3	;Y20 
db $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C3,$C3,$C3,$C3,$C3,$C4,$C4	;Y24 
db $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C3,$C3,$C3,$C3,$C3,$C4,$C4	;Y28
db $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C0,$C0,$C0,$C0,$C3,$C3,$C3,$C4,$C4	;Y2C 
db $C2,$C2,$C2,$C2,$C2,$C2,$C0,$C0,$C0,$C0,$C0,$C0,$C4,$C4,$C4,$C4	;Y30 
db $C2,$C2,$C2,$C2,$C2,$C2,$C0,$C0,$C0,$C0,$C0,$C0,$C4,$C4,$C4,$C4	;Y34 
db $C2,$C2,$C2,$C2,$C2,$C2,$C0,$C0,$C0,$C0,$C0,$C0,$C4,$C4,$C4,$C4	;Y38 
db $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C0,$C0,$C0,$C0,$C0,$C4,$C4,$C4,$C4	;Y3C
else	;This table is only used when AMK hasn't been yet used on the ROM
  ;X00 X04 X08 X0C X10 X14 X18 X1C X20 X24 X28 X2C X30 X34 X38 X3C
db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	;Y00
db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	;Y04
db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	;Y08
db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	;Y0C
db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	;Y10
db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	;Y14
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	;Y18
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	;Y1C
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	;Y20
db $03,$03,$03,$03,$03,$05,$05,$05,$03,$03,$03,$03,$03,$03,$03,$03	;Y24
db $03,$03,$03,$03,$03,$05,$05,$05,$03,$03,$03,$03,$03,$03,$03,$03	;Y28
db $03,$03,$03,$03,$03,$05,$05,$05,$05,$05,$03,$03,$03,$03,$03,$03	;Y2C
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	;Y30
db $04,$04,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	;Y34
db $04,$04,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	;Y38
db $04,$04,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	;Y3C
endif
