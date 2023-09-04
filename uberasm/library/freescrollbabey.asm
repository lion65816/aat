init:
	LDA #$01		;\ Free RAM flag to set free vertical scroll.
	STA $140B|!addr		;/ See flagfreescroll.asm patch.
	RTL
