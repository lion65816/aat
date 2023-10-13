;=========================================================
; Print final castle room/author names as sprite tiles.
;=========================================================

!NumTiles = $40		;> 64 8x8 tiles: 32 on top, 32 on bottom
!TileOrigin = $D000	;> Reference coordinate (YYXX)
!TileProp = $3000	;> High byte contains the YXPPCCCT

;=================================
; Main routine
;=================================

main:
	LDA $1923|!addr : BNE + : JMP .erase
+	CMP #$01 : BNE + : JMP .print140
+	CMP #$02 : BNE + : JMP .print141
+	CMP #$03 : BNE + : JMP .print142
+	CMP #$04 : BNE + : JMP .print143
+	CMP #$05 : BNE + : JMP .print144
+	CMP #$06 : BNE + : JMP .print145
+	CMP #$07 : BNE + : JMP .print149
+	CMP #$08 : BNE + : JMP .print14A
+	CMP #$09 : BNE + : JMP .print14B
+	CMP #$0A : BNE + : JMP .print14C
+	CMP #$0B : BNE + : JMP .print14D
+	CMP #$0C : BNE + : JMP .print14F
+	CMP #$0D : BNE + : JMP .print150
+	CMP #$0E : BNE + : JMP .print151
+	CMP #$0F : BNE + : JMP .print0A4
+	CMP #$10 : BNE + : JMP .print146
+	CMP #$11 : BNE + : JMP .print14E
+	CMP #$12 : BNE + : JMP .print154
+	JMP .return

.erase
	LDA.b #blank     : STA $00
	LDA.b #blank>>8  : STA $01
	LDA.b #blank>>16 : STA $02
	JMP .next
.print140
	LDA.b #text140     : STA $00
	LDA.b #text140>>8  : STA $01
	LDA.b #text140>>16 : STA $02
	JMP .next
.print141
	LDA.b #text141     : STA $00
	LDA.b #text141>>8  : STA $01
	LDA.b #text141>>16 : STA $02
	JMP .next
.print142
	LDA.b #text142     : STA $00
	LDA.b #text142>>8  : STA $01
	LDA.b #text142>>16 : STA $02
	JMP .next
.print143
	LDA.b #text143     : STA $00
	LDA.b #text143>>8  : STA $01
	LDA.b #text143>>16 : STA $02
	JMP .next
.print144
	LDA.b #text144     : STA $00
	LDA.b #text144>>8  : STA $01
	LDA.b #text144>>16 : STA $02
	JMP .next
.print145
	LDA.b #text145     : STA $00
	LDA.b #text145>>8  : STA $01
	LDA.b #text145>>16 : STA $02
	JMP .next
.print149
	LDA.b #text149     : STA $00
	LDA.b #text149>>8  : STA $01
	LDA.b #text149>>16 : STA $02
	JMP .next
.print14A
	LDA.b #text14A     : STA $00
	LDA.b #text14A>>8  : STA $01
	LDA.b #text14A>>16 : STA $02
	JMP .next
.print14B
	LDA.b #text14B     : STA $00
	LDA.b #text14B>>8  : STA $01
	LDA.b #text14B>>16 : STA $02
	JMP .next
.print14C
	LDA.b #text14C     : STA $00
	LDA.b #text14C>>8  : STA $01
	LDA.b #text14C>>16 : STA $02
	JMP .next
.print14D
	LDA.b #text14D     : STA $00
	LDA.b #text14D>>8  : STA $01
	LDA.b #text14D>>16 : STA $02
	JMP .next
.print14F
	LDA.b #text14F     : STA $00
	LDA.b #text14F>>8  : STA $01
	LDA.b #text14F>>16 : STA $02
	JMP .next
.print150
	LDA.b #text150     : STA $00
	LDA.b #text150>>8  : STA $01
	LDA.b #text150>>16 : STA $02
	JMP .next
.print151
	LDA.b #text151     : STA $00
	LDA.b #text151>>8  : STA $01
	LDA.b #text151>>16 : STA $02
	JMP .next
.print0A4
	LDA.b #text0A4     : STA $00
	LDA.b #text0A4>>8  : STA $01
	LDA.b #text0A4>>16 : STA $02
	JMP .next
.print146
	LDA.b #text146     : STA $00
	LDA.b #text146>>8  : STA $01
	LDA.b #text146>>16 : STA $02
	JMP .next
.print14E
	LDA.b #text14E     : STA $00
	LDA.b #text14E>>8  : STA $01
	LDA.b #text14E>>16 : STA $02
	JMP .next
.print154
	LDA.b #text154     : STA $00
	LDA.b #text154>>8  : STA $01
	LDA.b #text154>>16 : STA $02
	JMP .next
.next
	; Use the MaxTile system to request OAM slots. Needs SA-1 v1.40.
	LDY.b #$00+(!NumTiles)	;> Input parameter for call to MaxTile.
	REP #$30				;> (As the index registers were 8-bit, this fills their high bytes with zeroes)
	LDA.w #$0000			;> Maximum priority. Input parameter for call to MaxTile.
	JSL $0084B0				;\ Request MaxTile slots (does not modify scratch ram at the time of writing).
							;| Returns 16-bit pointer to the OAM general buffer in $3100.
							;/ Returns 16-bit pointer to the OAM attribute buffer in $3102.
	BCC .return				;\ Carry clear: Failed to get OAM slots, abort.
							;/ ...should never happen, since this will be executed before sprites, but...
	JSR Draw
.return
	SEP #$30
	RTL

;=================================
; Draw sprite tiles (uses SP2)
;=================================

Draw:
	PHB
	PHK
	PLB

	; OAM table
	LDX $3100						;> Main index (16-bit pointer to the OAM general buffer)
	LDY.w #$0000+((!NumTiles-1)*2)	;> Loop index
-
	LDA TileYX,y					;\ Load base X and Y coordinates
	STA $400000,x					;/
				
	LDA [$00],y						;\ Get the appropriate tile.
	CLC								;|
	ADC #!TileProp					;|
	STA $400002,x					;/ Store to MaxTile

	INX #4							;\
	DEY #2							;| Move to next slot and loop
	BPL -							;/

	; OAM extra bits
	LDX $3102						;> Bit table index (16-bit pointer to the OAM attribute buffer)
	LDY.w #$0000+(!NumTiles)/2-1	;> Loop index (assumes even number of tiles)
	;LDA.w #$0202					;> Big (16x16) for both tiles
	LDA.w #$0000					;> Small (8x8) for both tiles
-
	STA $400000,x					;> Store to both

	INX #2							;\
	DEY								;| Loop to set the remaining OAM extra bits.
	BPL -							;/

	PLB
	RTS

;=================================
; Dynamically generate tile coords
;=================================

TileYX:
!counter #= !NumTiles
!tempcoordinate #= !TileOrigin
while !counter > !NumTiles/2
	dw !tempcoordinate
	!tempcoordinate #= !tempcoordinate+$0008
	!counter #= !counter-1
endif
!tempcoordinate #= !TileOrigin+$0800
while !counter > 0
	dw !tempcoordinate
	!tempcoordinate #= !tempcoordinate+$0008
	!counter #= !counter-1
endif

;=================================
; Defines to make it easier to
; format text. Assumes SP2.
;=================================

!A_ = $0080 : !B_ = $0081 : !C_ = $0082 : !D_ = $0083
!E_ = $0084 : !F_ = $0085 : !G_ = $0086 : !H_ = $0087
!I_ = $0088 : !J_ = $0089 : !K_ = $008A : !L_ = $008B
!M_ = $008C : !N_ = $008D : !O_ = $008E : !P_ = $008F
!Q_ = $0090 : !R_ = $0091 : !S_ = $0092 : !T_ = $0093
!U_ = $0094 : !V_ = $0095 : !W_ = $0096 : !X_ = $0097
!Y_ = $0098 : !Z_ = $0099

!a_ = $00C0 : !b_ = $00C1 : !c_ = $00C2 : !d_ = $00C3
!e_ = $00C4 : !f_ = $00C5 : !g_ = $00C6 : !h_ = $00C7
!i_ = $00C8 : !j_ = $00C9 : !k_ = $00CA : !l_ = $00CB
!m_ = $00CC : !n_ = $00CD : !o_ = $00CE : !p_ = $00CF
!q_ = $00D0 : !r_ = $00D1 : !s_ = $00D2 : !t_ = $00D3
!u_ = $00D4 : !v_ = $00D5 : !w_ = $00D6 : !x_ = $00D7
!y_ = $00D8 : !z_ = $00D9

!1_ = $00E4 : !2_ = $00E5

!EX = $009A	;> Exclamation point
!PD = $009B	;> Period
!DH = $009C	;> Dash
!CM = $009D	;> Comma
!QS = $009E	;> Question mark
!__ = $009F	;> Space
!OP = $00DB	;> Open parenthesis
!CP = $00DC	;> Close parenthesis
!QT = $00DD	;> Quotation mark
!BL = $00DF	;> Blank tile

;=================================
; Room and author name data
;=================================

blank:
	dw !BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL
	dw !BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL

text140:
	dw !__,!A_,!F_,!T_,!E_,!R_,!__,!T_,!H_,!A_,!T_,!__,!S_,!H_,!E_,!L_,!L_,!EX,!__,!V_,!o_,!l_,!PD,!2_,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!P_,!S_,!I_,!__,!N_,!i_,!n_,!j_,!a_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text141:
	dw !__,!D_,!a_,!n_,!m_,!a_,!k_,!u_,!__,!H_,!a_,!l_,!l_,!w_,!a_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!P_,!S_,!I_,!__,!N_,!i_,!n_,!j_,!a_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text142:
	dw !__,!A_,!__,!S_,!p_,!e_,!c_,!i_,!a_,!l_,!__,!P_,!o_,!p_,!s_,!i_,!c_,!l_,!e_,!__,!E_,!n_,!d_,!e_,!a_,!v_,!o_,!r_,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!B_,!i_,!g_,!__,!B_,!r_,!a_,!w_,!l_,!e_,!r_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text143:
	dw !__,!F_,!r_,!e_,!s_,!h_,!w_,!a_,!t_,!e_,!r_,!__,!A_,!q_,!u_,!a_,!r_,!i_,!u_,!m_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!N_,!i_,!t_,!r_,!o_,!g_,!e_,!n_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text144:
	dw !__,!P_,!r_,!o_,!t_,!o_,!t_,!y_,!p_,!e_,!__,!H_,!a_,!l_,!l_,!w_,!a_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!S_,!A_,!J_,!e_,!w_,!e_,!r_,!s_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text145:
	dw !__,!d_,!i_,!s_,!h_,!__,!d_,!i_,!s_,!h_,!__,!d_,!i_,!s_,!h_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!B_,!u_,!m_,!p_,!t_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text149:
	dw !__,!C_,!h_,!a_,!r_,!l_,!i_,!e_,!V_,!i_,!l_,!l_,!e_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!S_,!A_,!J_,!e_,!w_,!e_,!r_,!s_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14A:
	dw !__,!M_,!i_,!c_,!h_,!i_,!g_,!a_,!n_,!__,!L_,!e_,!f_,!t_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!S_,!A_,!J_,!e_,!w_,!e_,!r_,!s_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14B:
	dw !__,!s_,!h_,!o_,!p_,!p_,!i_,!n_,!g_,!__,!s_,!t_,!u_,!n_,!t_,!s_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!S_,!c_,!a_,!r_,!f_,!l_,!e_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14C:
	dw !__,!QT,!I_,!__,!s_,!o_,!l_,!v_,!e_,!d_,!__,!t_,!h_,!e_,!__,!p_,!u_,!z_,!z_,!l_,!e_,!QT,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!N_,!i_,!t_,!r_,!o_,!g_,!e_,!n_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14D:
	dw !__,!F_,!i_,!s_,!h_,!y_,!__,!G_,!a_,!r_,!d_,!e_,!n_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!B_,!i_,!g_,!__,!B_,!r_,!a_,!w_,!l_,!e_,!r_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14F:
	dw !__,!B_,!r_,!o_,!c_,!c_,!o_,!l_,!i_,!__,!Y_,!a_,!r_,!d_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!B_,!u_,!m_,!p_,!t_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text150:
	dw !__,!W_,!h_,!e_,!r_,!e_,!__,!t_,!h_,!e_,!__,!H_,!e_,!l_,!l_,!QS,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!L_,!o_,!r_,!d_,!__,!R_,!u_,!b_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text151:
	dw !__,!R_,!A_,!P_,!I_,!D_,!__,!A_,!D_,!V_,!A_,!N_,!C_,!E_,!M_,!E_,!N_,!T_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!H_,!e_,!r_,!a_,!g_,!a_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text0A4:
	dw !__,!C_,!h_,!o_,!o_,!s_,!e_,!__,!Y_,!o_,!u_,!r_,!__,!F_,!l_,!a_,!v_,!o_,!r_,!EX,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!L_,!u_,!c_,!k_,!w_,!a_,!i_,!v_,!e_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	
text146:
	dw !__,!T_,!h_,!e_,!__,!M_,!a_,!g_,!i_,!c_,!__,!S_,!t_,!a_,!i_,!r_,!w_,!e_,!l_,!l_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!D_,!J_,!__,!B_,!u_,!c_,!k_,!l_,!e_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	
text14E:
	dw !__,!R_,!u_,!n_,!n_,!i_,!n_,!g_,!__,!OP,!i_,!n_,!CP,!__,!H_,!e_,!l_,!l_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!d_,!a_,!v_,!i_,!d_,!v_,!a_,!m_,!a_,!2_,!1_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text154:
	dw !__,!T_,!h_,!e_,!y_,!__,!w_,!a_,!r_,!n_,!e_,!d_,!__,!y_,!o_,!u_,!PD,!PD,!PD,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	dw !__,!__,!__,!b_,!y_,!__,!C_,!a_,!t_,!a_,!b_,!o_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
