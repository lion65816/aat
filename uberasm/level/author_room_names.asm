;;;;;;;;;;;;;;;;;;;;
; Print the room and author names to Layer 3 when Demo touches a door.
; Uses free RAM address: $1923|!addr
; Source: https://www.smwcentral.net/?p=viewthread&t=93207
;;;;;;;;;;;;;;;;;;;;

main:
	LDY #$00		;> Counter for how many tiles written
	LDA $7F837B		;\ Get current stripe index
	TAX			;/
-
	LDA $1923|!addr
	BEQ .erase
	CMP #$01 : BEQ .print140
	CMP #$02 : BEQ .print141
	CMP #$03 : BEQ .print142
	CMP #$04 : BEQ .print143
	CMP #$05 : BEQ .print144
	CMP #$06 : BEQ .print145
	CMP #$07 : BEQ .print149
	CMP #$08 : BEQ .print14A
	CMP #$09 : BEQ .print14B
	CMP #$0A : BEQ .print14C
	CMP #$0B : BEQ .print14D
	CMP #$0C : BEQ .print14F
	CMP #$0D : BEQ .print150
	CMP #$0E : BEQ .print151
	CMP #$0F : BEQ .print0A4
	CMP #$10 : BEQ .print146
	CMP #$11 : BEQ .print14E
	CMP #$12 : BEQ .print154
	BRA .exit

.erase
	LDA blank,y : BRA .next
.print140
	LDA text140,y : BRA .next
.print141
	LDA text141,y : BRA .next
.print142
	LDA text142,y : BRA .next
.print143
	LDA text143,y : BRA .next
.print144
	LDA text144,y : BRA .next
.print145
	LDA text145,y : BRA .next
.print149
	LDA text149,y : BRA .next
.print14A
	LDA text14A,y : BRA .next
.print14B
	LDA text14B,y : BRA .next
.print14C
	LDA text14C,y : BRA .next
.print14D
	LDA text14D,y : BRA .next
.print14F
	LDA text14F,y : BRA .next
.print150
	LDA text150,y : BRA .next
.print151
	LDA text151,y : BRA .next
.print0A4
	LDA text0A4,y : BRA .next
.print146
	LDA text146,y : BRA .next
.print14E
	LDA text14E,y : BRA .next
.print154
	LDA text154,y : BRA .next

.next
	STA $7F837D,x
	INX			;\ Increment indices
	INY			;/
	CPY #$74		;\
	BPL +			;| If not at the end of the table,
	JMP -			;/ then repeat
+
	LDA #$FF		;> Otherwise, write $FF as the ending byte
	STA $7F837D,x
	TXA			;\ Store stripe end index
	STA $7F837B		;/
.exit
	RTL

;;;;;;;;;;;;;;;;;;;;
; Defines for printing the Layer 3 text.
; Tile numbers are based on GFX2A.
;;;;;;;;;;;;;;;;;;;;

!props = $39	; YXPCCCTT (0011 1001) (white letters on black BG)

!A_ = $00,!props : !B_ = $01,!props : !C_ = $02,!props : !D_ = $03,!props
!E_ = $04,!props : !F_ = $05,!props : !G_ = $06,!props : !H_ = $07,!props
!I_ = $08,!props : !J_ = $09,!props : !K_ = $0A,!props : !L_ = $0B,!props
!M_ = $0C,!props : !N_ = $0D,!props : !O_ = $0E,!props : !P_ = $0F,!props
!Q_ = $10,!props : !R_ = $11,!props : !S_ = $12,!props : !T_ = $13,!props
!U_ = $14,!props : !V_ = $15,!props : !W_ = $16,!props : !X_ = $17,!props
!Y_ = $18,!props : !Z_ = $19,!props

!a_ = $40,!props : !b_ = $41,!props : !c_ = $42,!props : !d_ = $43,!props
!e_ = $44,!props : !f_ = $45,!props : !g_ = $46,!props : !h_ = $47,!props
!i_ = $48,!props : !j_ = $49,!props : !k_ = $4A,!props : !l_ = $4B,!props
!m_ = $4C,!props : !n_ = $4D,!props : !o_ = $4E,!props : !p_ = $4F,!props
!q_ = $50,!props : !r_ = $51,!props : !s_ = $52,!props : !t_ = $53,!props
!u_ = $54,!props : !v_ = $55,!props : !w_ = $56,!props : !x_ = $57,!props
!y_ = $58,!props : !z_ = $59,!props

!1_ = $64,!props : !2_ = $65,!props

!EX = $1A,!props	;> Exclamation point
!PD = $1B,!props	;> Period
!DH = $1C,!props	;> Dash
!CM = $1D,!props	;> Comma
!QS = $1E,!props	;> Question mark
!__ = $1F,!props	;> Space
!OP = $5B,!props	;> Open parenthesis
!CP = $5C,!props	;> Close parenthesis
!QT = $5D,!props	;> Quotation mark
!BL = $5F,!props	;> Blank tile

;> Stripe Image Formatter tool: https://jsfiddle.net/ankougo/vgkb8f3m/
blank:
	db $5A,$80,$00,$35
	db !BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL
	db $5A,$A0,$00,$35
	db !BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL,!BL

text140:
	db $5A,$80,$00,$35
	db !A_,!F_,!T_,!E_,!R_,!__,!T_,!H_,!A_,!T_,!__,!S_,!H_,!E_,!L_,!L_,!EX,!__,!V_,!o_,!l_,!PD,!2_,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!P_,!S_,!I_,!__,!N_,!i_,!n_,!j_,!a_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text141:
	db $5A,$80,$00,$35
	db !D_,!a_,!n_,!m_,!a_,!k_,!u_,!__,!H_,!a_,!l_,!l_,!w_,!a_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!P_,!S_,!I_,!__,!N_,!i_,!n_,!j_,!a_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text142:
	db $5A,$80,$00,$35
	db !A_,!__,!S_,!p_,!e_,!c_,!i_,!a_,!l_,!__,!P_,!o_,!p_,!s_,!i_,!c_,!l_,!e_,!__,!E_,!n_,!d_,!e_,!a_,!v_,!o_,!r_
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!B_,!i_,!g_,!__,!B_,!r_,!a_,!w_,!l_,!e_,!r_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text143:
	db $5A,$80,$00,$35
	db !F_,!r_,!e_,!s_,!h_,!w_,!a_,!t_,!e_,!r_,!__,!A_,!q_,!u_,!a_,!r_,!i_,!u_,!m_,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!N_,!i_,!t_,!r_,!o_,!g_,!e_,!n_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text144:
	db $5A,$80,$00,$35
	db !P_,!r_,!o_,!t_,!o_,!t_,!y_,!p_,!e_,!__,!H_,!a_,!l_,!l_,!w_,!a_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!S_,!A_,!J_,!e_,!w_,!e_,!r_,!s_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text145:
	db $5A,$80,$00,$35
	db !d_,!i_,!s_,!h_,!__,!d_,!i_,!s_,!h_,!__,!d_,!i_,!s_,!h_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!B_,!u_,!m_,!p_,!t_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text149:
	db $5A,$80,$00,$35
	db !C_,!h_,!a_,!r_,!l_,!i_,!e_,!V_,!i_,!l_,!l_,!e_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!S_,!A_,!J_,!e_,!w_,!e_,!r_,!s_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14A:
	db $5A,$80,$00,$35
	db !M_,!i_,!c_,!h_,!i_,!g_,!a_,!n_,!__,!L_,!e_,!f_,!t_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!S_,!A_,!J_,!e_,!w_,!e_,!r_,!s_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14B:
	db $5A,$80,$00,$35
	db !s_,!h_,!o_,!p_,!p_,!i_,!n_,!g_,!__,!s_,!t_,!u_,!n_,!t_,!s_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!S_,!c_,!a_,!r_,!f_,!l_,!e_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14C:
	db $5A,$80,$00,$35
	db !QT,!I_,!__,!s_,!o_,!l_,!v_,!e_,!d_,!__,!t_,!h_,!e_,!__,!p_,!u_,!z_,!z_,!l_,!e_,!QT,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!N_,!i_,!t_,!r_,!o_,!g_,!e_,!n_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14D:
	db $5A,$80,$00,$35
	db !F_,!i_,!s_,!h_,!y_,!__,!G_,!a_,!r_,!d_,!e_,!n_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!B_,!i_,!g_,!__,!B_,!r_,!a_,!w_,!l_,!e_,!r_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text14F:
	db $5A,$80,$00,$35
	db !B_,!r_,!o_,!c_,!c_,!o_,!l_,!i_,!__,!Y_,!a_,!r_,!d_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!B_,!u_,!m_,!p_,!t_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text150:
	db $5A,$80,$00,$35
	db !W_,!h_,!e_,!r_,!e_,!__,!t_,!h_,!e_,!__,!H_,!e_,!l_,!l_,!QS,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!L_,!o_,!r_,!d_,!__,!R_,!u_,!b_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text151:
	db $5A,$80,$00,$35
	db !R_,!A_,!P_,!I_,!D_,!__,!A_,!D_,!V_,!A_,!N_,!C_,!E_,!M_,!E_,!N_,!T_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!H_,!e_,!r_,!a_,!g_,!a_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text0A4:
	db $5A,$80,$00,$35
	db !C_,!h_,!o_,!o_,!s_,!e_,!__,!Y_,!o_,!u_,!r_,!__,!F_,!l_,!a_,!v_,!o_,!r_,!EX,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!L_,!u_,!c_,!k_,!w_,!a_,!i_,!v_,!e_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	
text146:
	db $5A,$80,$00,$35
	db !T_,!h_,!e_,!__,!M_,!a_,!g_,!i_,!c_,!__,!S_,!t_,!a_,!i_,!r_,!w_,!e_,!l_,!l_,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!D_,!J_,!__,!B_,!u_,!c_,!k_,!l_,!e_,!y_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	
text14E:
	db $5A,$80,$00,$35
	db !R_,!u_,!n_,!n_,!i_,!n_,!g_,!__,!OP,!i_,!n_,!CP,!__,!H_,!e_,!l_,!l_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!d_,!a_,!v_,!i_,!d_,!v_,!a_,!m_,!a_,!2_,!1_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

text154:
	db $5A,$80,$00,$35
	db !T_,!h_,!e_,!y_,!__,!w_,!a_,!r_,!n_,!e_,!d_,!__,!y_,!o_,!u_,!PD,!PD,!PD,!__,!__,!__,!__,!__,!__,!__,!__,!__
	db $5A,$A0,$00,$35
	db !b_,!y_,!__,!C_,!a_,!t_,!a_,!b_,!o_,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__

;template:
;	db $5A,$80,$00,$35
;	db !__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
;	db $5A,$A0,$00,$35
;	db !__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__,!__
