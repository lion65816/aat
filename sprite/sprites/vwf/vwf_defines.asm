include

if !sa1 == 1
    !VWF_VARS			= $40C800
    !VWF_HDMA			= $40C900
    !VWF_SCROLL			= $40CA00
    !VWF_DATA			= $40D000
    !VWF_GFX			= $40AD00
    !VWF_TOPIC_GFX		= $40B100
else
    !VWF_VARS			= $7EC800
    !VWF_HDMA			= $7EC900
    !VWF_SCROLL			= $7ECA00
    !VWF_DATA			= $7ED000
    !VWF_GFX			= $7EAD00
    !VWF_TOPIC_GFX		= $7EB100
endif

!RightArrowGFX		= $303C
!DownArrowGFX		= $303D

!CurrentLine		= !VWF_VARS+$02
!Xposition			= !VWF_VARS+$04
!FontColor			= !VWF_VARS+$06
!TermChars			= !VWF_VARS+$08		; the number of characters left until finishing rendering a term
!TermWidth			= !VWF_VARS+$0A
!LineDrawn			= !VWF_VARS+$0C		; the number of line drawn which will be incremented until this reaches 5
!Timer				= !VWF_VARS+$0E		; general purpose
!LeftPad			= !VWF_VARS+$10
!NewLeftPad			= !VWF_VARS+$12
!LineBroken			= !VWF_VARS+$14		; to erase an old line
!SelectMsg			= !VWF_VARS+$16		; for branch
!SkipPos			= !VWF_VARS+$18		; where the pointer jumps to when the player pressed the Start button
!Skipped			= !VWF_VARS+$1A

!Inner				= !VWF_VARS+$20
!ForcedScroll		= !VWF_VARS+$22
!ValidWidth			= !VWF_VARS+$24
!RightPad			= !VWF_VARS+$28

!SpaceWidth         = !VWF_VARS+$2A

!SavedPointer       = !VWF_VARS+$2C
!OffsetPointer      = !VWF_VARS+$2E
!NewPointer         = !VWF_VARS+$30

!ASMPointer         = !VWF_VARS+$32

!VWF_ASM_PTRS       = !VWF_VARS+$34
!AddMusicK_RAM      = $7FB000

!amk_main = read3($008076)
!amk_new_main = read3(!amk_main+$03)