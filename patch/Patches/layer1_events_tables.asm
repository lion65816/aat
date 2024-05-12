; Layer 1 Events tables
; Note: don't patch this file, only patch "layer1_events.asm"!
;
; Usage: %step(num,x,y,tile)
; - num = step number in the event (as displayed in LM)
; - x,y = x,y position of the tile (as displayed in LM when in L1 editing mode)
; - tile = layer 1 tile number (as displayed in LM 16x16 tile selector)
;          (note: you can also use tiles $0C0-$1FF)
; You can also add more than 1 entry for the same event (for different steps)

.00:
.01:    
.02:    
.03:    
.04:    
.05:    
.06:    
.07:
.08:    
.09:    
.0A:    
.0B:    %step($01,$01,$0B,$13F)
	%step($02,$01,$0A,$13F)
.0C:    
.0D:    
.0E:    
.0F:    
.10:    %step($04,$0B,$09,$13F)
	%step($05,$0B,$0A,$13F)
	%step($06,$0B,$0B,$13F)
	%step($07,$0B,$0C,$140)
.11:    
.12:    %step($10,$08,$3A,$090)
.13:    
.14:    
.15:    
.16:    
.17:    
.18:    
.19:    
.1A:    
.1B:    
.1C:    
.1D:    
.1E:    
.1F:    
.20:    
.21:    
.22:    
.23:    
.24:    
.25:    
.26:    
.27:    
.28:    
.29:    
.2A:    
.2B:    
.2C:    %step($00,$12,$0A,$004)
.2D:    
.2E:    %step($00,$1C,$1D,$01E)
.2F:    
.30:    
.31:    
.32:    
.33:    
.34:    %step($00,$1B,$1C,$004)
.35:    %step($00,$1E,$01,$02C)
.36:    
.37:    
.38:    
.39:    
.3A:    
.3B:    
.3C:    
.3D:    
.3E:    
.3F:    
.40:    
.41:    
.42:    
.43:    %step($00,$08,$23,$1A9)
.44:    
.45:    
.46:    
.47:    
.48:    
.49:    
.4A:    
.4B:    
.4C:    
.4D:    %step($00,$01,$32,$03C)
.4E:    %step($00,$03,$31,$1A3)
.4F:    %step($00,$03,$31,$1A3)
.50:    
.51:    
.52:    %step($00,$01,$2F,$0BD)
.53:    
.54:    
.55:    
.56:    
.57:    %step($00,$05,$31,$1A4)
	%step($03,$09,$32,$16A)
.58:    %step($00,$05,$31,$1A4)
.59:    
.5A:    
.5B:    
.5C:    
.5D:    
.5E:    
.5F:    
.60:    
.61:    
.62:    
.63:    
.64:    
.65:    
.66:    
.67:    %step($00,$13,$24,$1B0)
.68:    
.69:    
.6A:    
.6B:    
.6C:    
.6D:    
.6E:    
.6F:    
.70:    %step($05,$0F,$17,$0B5)
.71:    %step($04,$12,$16,$166)
.72:    
.73:    
.74:    
.75:    
.76:    
.77:    
