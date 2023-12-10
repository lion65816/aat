incsrc "../FlagMemoryDefines/Defines.asm"

load:
	;Transfer group-128 to $7FC060
	JSL MBCM16WriteGroup128To7FC060_LoadFlagTableToCM16
	;[...]
	RTL
;main:
;	;Display key counter on the HUD (during the level at play)
;	LDY #$00					;>$xx is what key counter to use, as an index from !Freeram_KeyCounter.
;	JSL MBCM16DisplayKeyCounter_DisplayHud
;	;[...]
;	RTL
;init:
;	;Display key counter on the HUD (during screen fading into the level)
;	LDY #$00					;>$xx is what key counter to use, as an index from !Freeram_KeyCounter.
;	JSL MBCM16DisplayKeyCounter_DisplayHud
;	;[...]
;	RTL