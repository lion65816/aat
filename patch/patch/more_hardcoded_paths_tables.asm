; X/Y position and submap of the pipe tile in the CI2 hardcoded path.
; It will be used for the $FF level in the levels table (instead of checking for the level number).
ci2_pipe_x_pos:     dw $0078
ci2_pipe_y_pos:     dw $0058
ci2_pipe_submap:    dw $03

; List of levels that have hardcoded paths ($FF = CI2 pipe).
; Use the level() function since level numbers are kinda weird in SMW.
levels:
.00:		db level($015),level($103)
.01:		db level($103),level($11A)
.02:		db level($103),level($01E)
.03:    	db level($01E),$FF
.04:   	db level($01E),level($130)
.05:    	db level($11A),level($10E)
.06:		db level($10E),level($130)
.07:		db level($130),level($115)
.08:		db level($115),level($134)
.09:		db level($134),level($135)
.0A:		db level($135),level($00D)
.0B:		db level($00D),level($024)
.0C:
.0D:
.0E:
.0F:

; Direction Mario has to press to move for each level in the paths.
directions:
.00:		db !Up,!Right
.01:		db !Left,!Right
.02:		db !Down,!Right
.03:		db !Up,!Right 
.04:		db !Left,!Right
.05:		db !Left,!Right
.06:		db !Left,!Up
.07:		db !Left,!Down
.08:		db !Right,!Left
.09:		db !Right,!Left
.0A:		db !Right,!Left
.0B:		db !Right,!Up
.0C:
.0D:
.0E:
.0F:

; List of layer 1 tiles between the level tiles (including the destination level tile!).
paths:
.00_1: 	db $3F,$3F,$3F,$20,$1A,$15,$66
.00_2: 	db $15,$1A,$20,$3F,$3F,$3F,$68
.01_1: 	db $04,$164
.01_2: 	db $04,$66
.02_1: 	db $10,$0F,$09,$05,$69
.02_2: 	db $05,$09,$0F,$10,$66
.03_1: 	db $1A,$15,$82				
.03_2:	db $15,$1A,$69
.04_1: 	db $07,$11,$05,$16,$1F,$17,$169
.04_2: 	db $17,$1F,$16,$05,$11,$07,$69
.05_1:	db $04,$04,$156
.05_2:	db $04,$04,$164
.06_1:	db $03,$0A,$12,$10,$169
.06_2:	db $10,$12,$0A,$03,$156
.07_1:	db $16,$19,$1E,$3F,$68
.07_2:	db $3F,$1E,$19,$16,$169
.08_1:	db $51,$08,$11,$07,$03,$66
.08_2:	db $03,$07,$11,$08,$51,$68
.09_1:	db $04,$04,$04,$04,$66
.09_2:	db $04,$04,$04,$04,$66
.0A_1:	db $04,$04,$04,$5D
.0A_2:	db $04,$04,$04,$66
.0B_1:	db $15,$1A,$20,$3F,$3F,$3F,$2A,$6A
.0B_2:	db $2A,$3F,$3F,$3F,$20,$1A,$15,$5D
.0C_1:
.0C_2:
.0D_1:
.0D_2:
.0E_1:
.0E_2:
.0F_1:
.0F_2:

; This overrides Mario's animation on the corresponding tile in the path.
; 0 = don't override, 1 = force swimming, 2 = force climbing
animation:
.00_1:  	db 2,2,2,1,1,1,1
.00_2:  	db 1,1,1,2,2,2,0
.01_1:  	db 1,1
.01_2:  	db 1,1
.02_1:  	db 1,1,1,1,1
.02_2:  	db 1,1,1,1,1
.03_1:  	db 1,1,1
.03_2:  	db 1,1,1
.04_1:  	db 1,1,1,1,1,1,1 
.04_2:  	db 1,1,1,1,1,1,1 
.05_1:	db 1,1,1
.05_2:	db 1,1,1
.06_1:	db 1,1,1,1,1
.06_2:	db 1,1,1,1,1
.07_1:	db 1,1,1,2,0
.07_2:	db 2,1,1,1,1
.08_1:	db 0,0,1,1,1,1
.08_2:	db 1,1,1,0,0,0
.09_1:	db 1,1,0,0,0
.09_2:	db 0,0,1,1,1
.0A_1:	db 0,0,1,1
.0A_2:	db 1,0,0,0
.0B_1:	db 1,1,1,2,2,2,0,0
.0B_2:	db 0,2,2,2,1,1,1,1
.0C_1:
.0C_2:
.0D_1:
.0D_2:
.0E_1:
.0E_2:
.0F_1:
.0F_2:

; These are offsets for the paths in the above tables.
; You only need to deal with this if you want to add even more paths.
offsets:
.0:     %offsets(00) 
.1:     %offsets(01) 
.2:     %offsets(02)
.3:     %offsets(03)
.4:     %offsets(04)
.5:     %offsets(05)
.6:     %offsets(06)
.7:     %offsets(07)
.8:     %offsets(08)
.9:     %offsets(09)
.A:     %offsets(0A)
.B:     %offsets(0B)
.C:     %offsets(0C)
.D:     %offsets(0D)
.E:     %offsets(0E)
.F:     %offsets(0F)
