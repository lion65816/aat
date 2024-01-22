;=========================================================
; Print overworld map names as sprite tiles.
;=========================================================

!NumTiles = $12		;> 18 8x8 tiles
!TileOrigin = $C65F	;> Reference coordinate (YYXX)
!TileProp = $3000	;> High byte contains the YXPPCCCT

;=================================
; Main routine
;=================================

main:
	LDX $0DB3|!addr
	LDA $1F11|!addr,x
	CMP #$01 : BNE + : JMP .print4
+	CMP #$02 : BNE + : JMP .print5
+	CMP #$03 : BNE + : JMP .print6
+	CMP #$04 : BNE + : JMP .print7
+	CMP #$05 : BNE + : JMP .print8
+	CMP #$06 : BNE + : JMP .print9
+	JMP .print1

.erase
	LDA.b #blank     : STA $00
	LDA.b #blank>>8  : STA $01
	LDA.b #blank>>16 : STA $02
	JMP .next
.print1
	LDA.b #text1     : STA $00
	LDA.b #text1>>8  : STA $01
	LDA.b #text1>>16 : STA $02
	JMP .next
.print2
	LDA.b #text2     : STA $00
	LDA.b #text2>>8  : STA $01
	LDA.b #text2>>16 : STA $02
	JMP .next
.print3
	LDA.b #text3     : STA $00
	LDA.b #text3>>8  : STA $01
	LDA.b #text3>>16 : STA $02
	JMP .next
.print4
	LDA.b #text4     : STA $00
	LDA.b #text4>>8  : STA $01
	LDA.b #text4>>16 : STA $02
	JMP .next
.print5
	LDA.b #text5     : STA $00
	LDA.b #text5>>8  : STA $01
	LDA.b #text5>>16 : STA $02
	JMP .next
.print6
	LDA.b #text6     : STA $00
	LDA.b #text6>>8  : STA $01
	LDA.b #text6>>16 : STA $02
	JMP .next
.print7
	LDA.b #text7     : STA $00
	LDA.b #text7>>8  : STA $01
	LDA.b #text7>>16 : STA $02
	JMP .next
.print8
	LDA.b #text8     : STA $00
	LDA.b #text8>>8  : STA $01
	LDA.b #text8>>16 : STA $02
	JMP .next
.print9
	LDA.b #text9     : STA $00
	LDA.b #text9>>8  : STA $01
	LDA.b #text9>>16 : STA $02
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

	INX #4							;\ Move to next slot and loop
	DEY #2							;|
	BPL -							;/

	; OAM extra bits
	LDX $3102						;> Bit table index (16-bit pointer to the OAM attribute buffer)
	LDY.w #$0000+(!NumTiles)/2-1	;> Loop index (assumes even number of tiles)
	;LDA.w #$0202					;> Big (16x16) for both tiles
	LDA.w #$0000					;> Small (8x8) for both tiles
-
	STA $400000,x					;> Store to both

	INX #2							;\ Loop to set the remaining OAM extra bits.
	DEY								;|
	BPL -							;/

	PLB
	RTS

;=================================
; Dynamically generate tile coords
;=================================

TileYX:
!counter #= !NumTiles
!tempcoordinate #= !TileOrigin
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
; Map name data
;=================================

blank:
	dw !BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL

text1:
	dw !F_,!o_,!o_,!d_,!__,!D_,!e_,!s_,!e_,!r_,!t_,!__,!I_,!s_,!l_,!a_,!n_,!d_

text2:
	dw !BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!H_,!e_,!a_,!v_,!e_,!n_

text3:
	dw !BL,!BL,!BL,!BL,!O_,!n_,!e_,!__,!L_,!a_,!s_,!t_,!__,!T_,!h_,!i_,!n_,!g_

text4:
	dw !BL,!R_,!e_,!s_,!o_,!r_,!t_,!__,!C_,!i_,!t_,!y_,!__,!B_,!a_,!n_,!f_,!f_

text5:
	dw !BL,!BL,!BL,!BL,!T_,!h_,!e_,!__,!F_,!i_,!s_,!h_,!m_,!a_,!r_,!k_,!e_,!t_

text6:
	dw !BL,!BL,!BL,!BL,!T_,!h_,!e_,!__,!L_,!o_,!s_,!t_,!__,!W_,!o_,!o_,!d_,!s_

text7:
	dw !BL,!BL,!BL,!BL,!BL,!N_,!E_,!G_,!A_,!T_,!I_,!V_,!E_,!__,!Z_,!O_,!N_,!E_

text8:
	dw !BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!D_,!e_,!__,!P_,!i_,!j_,!p_

text9:
	dw !BL,!BL,!BL,!BL,!BL,!P_,!i_,!e_,!d_,!m_,!o_,!n_,!t_,!__,!H_,!i_,!l_,!l_
