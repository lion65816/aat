; Block specific defines
!SoundEffect = $02			; Set to zero to play no sound effect
!APUPort = $1DFC|!addr		; Refer to the RAM Map or AMK for more information

!Map16 = $56E0				; The Map16 tile the block turns into (top left corner)

!shake_timer = $3E			; How long the ground is shaking

!item_memory_dependent = 0	; Makes the block stay collected
!invisible_block = 0		; Not solid, doesn't detect sprites, can only be hit from below
; 0 for false, 1 for true


; Placed there for technical reasons
incsrc question_block_base.asm


; Spawn specific defines
; Insert your defines here


; Code stuff
SpawnThing:
	; Insert your code here.
.Return:
RTS

print "A giant question mark block which contains nothing."
