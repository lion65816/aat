; X/Y position and submap of the pipe tile in the CI2 hardcoded path.
; It will be used for the $FF level in the levels table (instead of checking for the level number).
ci2_pipe_x_pos:     dw $0128
ci2_pipe_y_pos:     dw $0178
ci2_pipe_submap:    dw $00

; List of levels that have hardcoded paths ($FF = CI2 pipe).
; Use the level() function since level numbers are kinda weird in SMW.
levels:
.00:    db level($009),level($015)  ; DP1  <-> DP2
.01:    db level($023),level($01B)  ; CI3  <-> CF
.02:    db level($11F),level($120)  ; FoI2 <-> FoI4
.03:    db level($024),$FF          ; CI2  <-> Pipe
.04:    db level($10C),level($10D)  ; FD   <-> Star
.05:
.06:
.07:
.08:
.09:
.0A:
.0B:
.0C:
.0D:
.0E:
.0F:

; Direction Mario has to press to move for each level in the paths.
directions:
.00:    db !Down,!Left  ; DP2  <-> DP1
.01:    db !Left,!Right ; CI3  <-> CF
.02:    db !Right,!Left ; FoI4 <-> FoI2
.03:    db !Down,!Right ; CI2  <-> Pipe
.04:    db !Right,!Left ; Star <-> FD
.05:
.06:
.07:
.08:
.09:
.0A:
.0B:
.0C:
.0D:
.0E:
.0F:

; List of layer 1 tiles between the level tiles (including the destination level tile!).
paths:
.00_1:  db $10,$10,$1E,$19,$16,$66          ; DP2  -> DP1
.00_2:  db $16,$19,$1E,$10,$10,$66          ; DP1  -> DP2
.01_1:  db $04,$04,$04,$58                  ; CI3  -> CF
.01_2:  db $04,$04,$04,$66                  ; CF   -> CI3
.02_1:  db $04,$04,$04,$04,$04,$6A          ; FoI4 -> FoI2
.02_2:  db $04,$04,$04,$04,$04,$66          ; FoI2 -> FoI4
.03_1:  db $1E,$19,$06,$09,$0F,$20,$1A,$21  ; CI2  -> Pipe
        db $1A,$14,$19,$18,$1F,$17,$82
.03_2:  db $17,$1F,$18,$19,$14,$1A,$21,$1A  ; Pipe -> CI2
        db $20,$0F,$09,$06,$19,$1E,$66
.04_1:  db $04,$04,$58                      ; Star -> FD
.04_2:  db $04,$04,$5F                      ; FD   -> Star
.05_1:
.05_2:
.06_1:
.06_2:
.07_1:
.07_2:
.08_1:
.08_2:
.09_1:
.09_2:
.0A_1:
.0A_2:
.0B_1:
.0B_2:
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
.00_1:  db 0,0,0,0,0,0      ; DP2  -> DP1
.00_2:  db 0,0,0,0,0,0      ; DP1  -> DP2
.01_1:  db 0,0,0,0          ; CI3  -> CF
.01_2:  db 0,0,0,0          ; CF   -> CI3
.02_1:  db 0,0,0,0,0,0      ; FoI4 -> FoI2
.02_2:  db 0,0,0,0,0,0      ; FoI2 -> FoI4
.03_1:  db 0,0,0,0,0,0,0,0  ; CI2  -> Pipe
        db 0,0,0,0,0,0,0
.03_2:  db 0,0,0,0,0,0,0,0  ; Pipe -> CI2
        db 0,0,0,0,0,0,0
.04_1:  db 0,0,0            ; Star -> FD
.04_2:  db 0,0,0            ; FD   -> Star
.05_1:
.05_2:
.06_1:
.06_2:
.07_1:
.07_2:
.08_1:
.08_2:
.09_1:
.09_2:
.0A_1:
.0A_2:
.0B_1:
.0B_2:
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
.0:     %offsets(00)    ; DP1  <-> DP2
.1:     %offsets(01)    ; CI3  <-> CF
.2:     %offsets(02)    ; FoI2 <-> FoI4
.3:     %offsets(03)    ; CI2  <-> Pipe
.4:     %offsets(04)    ; FD   <-> Star
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
