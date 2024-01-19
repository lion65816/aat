;Makes sound when entering a level and using a pipe from the OW, plus allows you to change the SFX star roads use
;For reference regarding what sounds you can trigger, see: https://www.smwcentral.net/?p=viewthread&t=6665

HEADER
LOROM

!base = $0000

if read1($00ffd5) == $23
	sa1rom
	!base = $6000
endif

!SFX1 = $01		;Sound effect used when entering a Level
!Port1 = $1DFC		;Sound Bank used

!SFX2 = $04		;Sound effect used when using a Pipe
!Port2 = $1DF9		;Sound Bank used

!SFX3 =	$0D		;Sound effect used when using a Star Road
!Port3 = $1DF9		;Sound Bank used
	
;;;;;;;;;;;;;;;;;;;;;
;Hex Edits
;
;I know this is a relatively easy edit, but I wanted to include it
;in case someone wanted to mess with all of the tiles in one go
;;;;;;;;;;;;;;;;;;;;;

org $049170 
LDA.b #!SFX3 		
STA.w !Port3|!base 	

;;;;;;;;;;;;;;;;;;;;;
;Hijack Code
;;;;;;;;;;;;;;;;;;;;;

ORG $049195 
autoclean JML EnterPipe

ORG $0491E5 
autoclean JML EnterLevel

freedata ; this one doesn't change the data bank register, so it uses the RAM mirrors from another bank, so I might as well toss it into banks 40+

EnterPipe:		STA.w $0100|!base
			LDA.W $13C1|!base
			CMP.B #$82              ; If Mario/Luigi's not in a pipe...
			BNE NEXT		; Don't make Pipe sounds.
			CMP.B #$5B              ; If they ARE using one though...
			BNE PipeSFX		; Make the Pipe do a SFX.

PipeSFX:		LDA #!SFX2		
			STA.w !Port2|!base
NEXT:			JML $04F9A7

EnterLevel:		INC $0100|!base
			LDA #!SFX1
			STA.w !Port1|!base
			JML $04F8A5
End: