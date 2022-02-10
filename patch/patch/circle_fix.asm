lorom
!addr = $0000
if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
endif

org $00CA9F
	NOP #2
	autoclean JSL hack1
org $00CACF
	autoclean JSL hack2
	NOP #3
	CPY.w #$01C0


freecode


hack1:
	CPX #$01C0
	BCS +
		STA.w $04A0|!addr,x
		STZ.w $04A1|!addr,x
	+
	RTL
hack2:
	BCS +
		LDA.b #$00
	+
	CPX #$01C0
	BCS +
		STA.w $04A0|!addr,x	
	+
	RTL;