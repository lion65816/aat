;;;;;;;;;;;;
; Free RAM ;
;;;;;;;;;;;;

!RespawnX = $1923|!addr		;\ 2 bytes each
!RespawnY = $1926|!addr		;/

;;;;;;;;
; Code ;
;;;;;;;;

db $42				; or db $37
JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody	; when using db $37

BodyInside:
HeadInside:
	REP #$20
	LDA #$0570
	STA !RespawnX
	LDA #$00D0
	STA !RespawnY
	SEP #$20

;WallFeet:			; when using db $37
;WallBody:

Mario:
	RTL

print "Sets a new respawn point at the first midway in level 1D0."
