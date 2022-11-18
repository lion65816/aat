main:

LDA $71		;\ Check if Demo is in a "hurt" (flashing) state.
CMP #$01	;/
BNE .continue	;> If not, then go to the sprite-checking code.
JSL $00F606	;> Otherwise, instantly kill her.
RTL

.continue
    LDX.b #!sprite_slots-1
  - LDA !14C8,x
    BNE .ret
    DEX
    BPL -
    
    	LDA #$06				; \
	STA $71					; | Teleport the player via screen exit.
	STZ $88					; |
	STZ $89					; /
  .ret:
    RTL