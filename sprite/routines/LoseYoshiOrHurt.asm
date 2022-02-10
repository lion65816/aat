;LoseYoshi_Or_Hurt
;by Isikoro
;
					LDA $1490|!Base2
					ORA $1497|!Base2
					BNE .Return
					PHX
					LDY #!SprSize-1
.Loops:				LDA !9E,y
					CMP #$35 : BEQ .LoseYoshi
					DEY : BPL .Loops
					PLX
.Return:			RTL
					
.LoseYoshi:			TYX
					LDA #$10 : STA !163E,x
					LDA #$03 : STA $1DFA|!Base2
					LDA #$13 : STA $1DFC|!Base2
					LDA #$02 : STA !C2,x
					STZ $187A|!Base2
					LDA #$C0 : STA $7D
					STZ $7B
					LDY #$E8
					LDA $D1
					SEC : SBC !E4,x
					LDA $D2
					SBC !14E0,x
					BPL +
					LDY #$18
					+
					TYA
					STA !B6,x
					STZ !1594,x
					STZ !151C,x
					STZ $18AE|!Base2
					STZ $0DC1|!Base2
					LDA #$30 : STA $1497|!Base2
					LDA !D8,x
					SEC : SBC #$04
					STA $96 : STA $D3
					LDA !14D4,x
					SBC #$00
					STA $97 : STA $D4
					PLX
					RTL