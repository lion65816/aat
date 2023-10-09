;�m�R�m�R�G���[�g�΁@�悭��Ԃ��I
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; nokonoko init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    PRINT "INIT ",pc
                    PHY
                    JSR SUB_HORZ_POS
                    TYA
                    STA !157C,x

			LDA #$03     ;�`���W�X�^�ɂg�o����
			STA !151C,x  ;$151C,x��g�o�Ƃ���B

			STZ !C2,x  ;$C2,x����[�V�����ԍ��Ƃ���B
			STZ !1534,x  ;$1534,x����[�V�����J�E���^�Ƃ���B

            		LDA #$02     ;�`���W�X�^��2����
        		STA !1528,x  ;�t�@�C�A�ϐ��̃Z�b�g
                    PLY
                    RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; nokonoko main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    PRINT "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR CODE_START          ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; nokonoko main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;C2,x=���[�V�����ԍ�
;	0=��s�@1=���܂ꂽ���@2=�W�����v
;

KILLED_X_SPEED:      db $F0,$10

CODE_START:
		JSR SUB_OFF_SCREEN_HB   ;�X�v���C�g��ʊO�ŏ���

			LDA !C2,x   ;���[�V�����ԍ��`�F�b�N
			STA $05 ;5�ɒl��n���Ă���
			CMP #$01
            		BEQ MOTION1_GFX

			JMP SUB_GFX             ; graphics routine
			BRA GFX_ENDEND

MOTION1_GFX:		JMP SUB_GFX2	;���[�V����1�̂Ƃ��̕`��

			GFX_ENDEND:	;�`�您���



                    LDA !14C8,x             ; \
                    CMP #$08                ;  | if status != 8, RETURN
                    BNE RETURN              ; /
                    ;JSR SUB_OFF_SCREEN_X0   ; handle off screen situation



                    LDA $9D                 ; \ if sprites locked, RETURN
                    BNE RETURN              ; /
                  ;�������烁�C������
		LDA !C2,x   ;���[�V�����ԍ��`�F�b�N
		CMP #$01;1�͓��܂ꂽ��
            	BEQ MOTION_01
		CMP #$02;2�̓W�����v����
            	BEQ MOTION_02
		;����ȊO�̓��[�V�����O

		JMP SUB_MOTION_00

RETURN: RTS

MOTION_01: JMP SUB_MOTION_01
MOTION_02: JMP SUB_MOTION_02

	END_MOTION:

	            LDA !1588,x             ;A:0100 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZCHC:0276 VC:077 00 FL:623
                    AND #$04                ;A:0100 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZCHC:0308 VC:077 00 FL:623
                    PHA                     ;A:0100 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZCHC:0324 VC:077 00 FL:623

                    JSL $018032|!bank             ; interact with other sprites
                    LDA !1588,x             ;A:254B X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0684 VC:085 00 FL:623
                    AND #$04                ;A:2504 X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0716 VC:085 00 FL:623
                    BEQ IN_AIR              ;A:2504 X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0732 VC:085 00 FL:623
                    STZ !AA,x               ;A:2504 X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0748 VC:085 00 FL:623
                    PLA                     ;A:2504 X:0007 Y:0007 D:0000 DB:03 S:01EE P:envMXdizcHC:0778 VC:085 00 FL:623
                    BRA ON_GROUND           ;A:2500 X:0007 Y:0007 D:0000 DB:03 S:01EF P:envMXdiZcHC:0806 VC:085 00 FL:623
IN_AIR:              PLA                     ;A:2500 X:0007 Y:0006 D:0000 DB:03 S:01EB P:envMXdiZcHC:0316 VC:085 00 FL:4955
                    BEQ WAS_IN_AIR          ;A:2504 X:0007 Y:0006 D:0000 DB:03 S:01EC P:envMXdizcHC:0344 VC:085 00 FL:4955
                    LDA #$0A                ;A:2504 X:0007 Y:0006 D:0000 DB:03 S:01EC P:envMXdizcHC:0360 VC:085 00 FL:4955
                    STA !1540,x             ;A:25FF X:0007 Y:0006 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0376 VC:085 00 FL:4955
WAS_IN_AIR:          LDA !1540,x             ;A:25FF X:0007 Y:0006 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0408 VC:085 00 FL:4955
                    BEQ ON_GROUND           ;A:25FF X:0007 Y:0006 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0440 VC:085 00 FL:4955
                    STZ !AA,x               ;A:25FF X:0007 Y:0006 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0456 VC:085 00 FL:4955
ON_GROUND:
                    LDA !1588,x             ; \ if sprite is in contact with an object...
                    AND #$03                ; |
                    BEQ DONT_UPDATE         ; |
                    LDA !157C,x             ; | flip the direction status
                    EOR #$01                ; |
                    STA !157C,x             ; /


DONT_UPDATE:         JSL $01A7DC|!bank             ; check for mario/sprite contact
                    BCC RETURN_24           ; (carry set = contact)
                    LDA $1490|!addr               ; \ if mario star timer > 0 ...
                    BNE HAS_STAR            ; /    ... goto HAS_STAR
                    LDA $7D                 ; \  if mario's y speed < 10 ...
                    CMP #$10                ;  }   ... sprite will hurt mario
                    BMI NOKO_WINS           ; /

MARIO_WINS:          JSR SUB_STOMP_PTS       ; give mario points
                    JSL $01AA33|!bank             ; set mario speed
                    JSL $01AB99|!bank             ; display contact graphic
                    LDA $140D|!addr               ; \  if mario is spin jumping...
                    ORA $187A|!addr               ;  }    ... or on yoshi ...
                    BNE SPIN_KILL           ; /     ... goto SPIN_KILL
                    LDA #$20                ; \     ... time to show defeated sprite = $20
                    STA !1558,x             ; /
RETURN_24:           RTS                     ; RETURN

NOKO_WINS:           LDA $1497|!addr               ; \ if mario is invincible...
                    ORA $187A|!addr               ;  }  ... or mario on yoshi...
                    ORA !15D0,x             ; |   ...or sprite being eaten...
                    BNE RETURN2             ; /   ... RETURN
                    JSR SUB_GET_DIR         ; \  set new sprite direction
                    TYA                     ;  }
                    STA !157C,x             ; /
                    JSL $00F5B7|!bank             ; hurt mario
RETURN2:             RTS                     ; RETURN




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spin and star kill (still part of above routine)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STAR_SOUNDS:         db $00,$13,$14,$15,$16,$17,$18,$19

SPIN_KILL:

		LDA #$01
		STA !1632,x 		;�}���I�Ɣ������Ȃ�����

		STZ !B6,x ;�w���x�[��
		STZ !AA,x ;�x���x�[��
		STZ !1534,x  ;���[�V�����J�E���^������
		LDA #$01
		STA !C2,x	;���[�V�����ԍ���1������ʂ�

		JSR GET_DRAW_INFO
		JSL $01AB99|!bank

                    RTS                     ; RETURN
HAS_STAR:            LDA #$02                ; \ status = 2 (being killed by star)
                    STA !14C8,x             ; /
                    LDA #$D0                ; \ set y speed
                    STA !AA,x               ; /
                    JSR SUB_HORZ_POS        ; get new direction
                    LDA KILLED_X_SPEED,y    ; \ set x speed based on direction
                    STA !B6,x               ; /
                    INC $18D2|!addr               ; increment number consecutive enemies killed
                    LDA $18D2|!addr               ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET2           ;  |
                    LDA #$08                ;  |
                    STA $18D2|!addr               ; /
NO_RESET2:           JSL $02ACE5|!bank             ; give mario points
                    LDY $18D2|!addr               ; \
                    CPY #$08                ;  | if consecutive enemies stomped < 8 ...
                    BCS NO_SOUND2           ;  |
                    LDA STAR_SOUNDS,y       ;  |    ... play sound effect
                    STA $1DF9|!addr               ; /
NO_SOUND2:           RTS                     ; final RETURN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine �c�Q�^�C��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TILEMAP:		db $26,$46		; 1�t���[���ڂ̃^�C��
		        db $28,$48		; 2�t���[���ڂ̃^�C��
Y_OFFSET:		db $F0,$00		; ��̃^�C��.���̃^�C��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SUB_GFX:		JSR GET_DRAW_INFO		; Y���W�X�^ = OAM offset

		LDA !157C,x		; \ �X�v���C�g�̌�����$02�ɑ��
		STA $02			; /

		LDA $14			; \  �t���[���J�E���^��
		LSR A			;  | (1/2)
		LSR A			;  | (1/4)
		LSR A			;  | �v1/8�{
		AND #$01			;  | ����� $00 �� $01 �� $00 �� $01 �ƂȂ�J�E���^�ɂȂ�
		ASL A			;  | 2�{����� $00 �� $02 �� $00 �� $02 �ƂȂ�J�E���^�ɂȂ�
		STA $03			; /  �����$03�ɑ��

	LDA !14C8,x
	CMP #$08
	BEQ NON_ANIMATION
		STZ $03
	NON_ANIMATION:


		PHX			; ���[�v��X���W�X�^��g�p����̂ŁA�ی삷��
		LDX #$01			; ���[�v�� = �^�C����(2) - 1 = 1
LOOP_START:
		LDA $00			; \ X���W�͂���܂Œʂ�
		STA $0300|!addr,y		; /

		LDA Y_OFFSET,x		; \
		CLC			;  | �^�C���ʒu(�=00)��F0��00�𑫂���
		ADC $01			;  | �^�C���ʒu��F0��00�ɂȂ�܂���
		STA $0301|!addr,y		; /

		PHX
		TXA			; X �� A(�܂�C���f�N�X�ԍ���A�Ɏ����Ă���)
		CLC			; \ A�ɃJ�E���^�̕��𑫂��Ă����܂�
		ADC $03			; /
		TAX			; A �� X(�������l��߂�)
		LDA TILEMAP,x		; \ �^�C���}�b�v����
		STA $0302|!addr,y		; /
		PLX

		PHX
		LDX $15E9|!addr			; �X�v���C�g�̃C���f�N�X�ԍ��Ɋւ���RAM ���ꂪ�Ȃ��ƃp���b�g�Ȃǂ����������Ȃ�܂�
		LDA !15F6,x		; �p���b�g
		LDX $02			; \  ���̃X�v���C�g�̌�����Ăяo���܂�
		BNE NO_FLIP		;  | = 0(�E����)�łȂ��Ȃ�[NO_FLIP]�Ɉړ������܂�
		ORA #$40			;  | �������̏ꍇ�A�^�C������E���]�����܂�
NO_FLIP:		ORA $64			;  | �E�����Ȃ獶�E���]������ɂ��̂܂�$0303,y�ɑ�����܂�
		STA $0303|!addr,y		; /  �^�C����������
		PLX

		INY			; \
		INY			;  | ���[�v���Ƀ^�C����RAM�̃A�h���X�𑝂₷
		INY			;  |
		INY			; /
		DEX			; \ ���[�v�̏����ł��̋L�q�͕K�{�ł����
		BPL LOOP_START		; /
		PLX			; ���[�v���I�������̂ŃC���f�N�X�ԍ���߂��Ă�����

		LDY #$02			; �^�C���T�C�Y��16x16�œ���
		LDA #$01			; �^�C����(2) - 1 = 1
		JSL $01B7B3|!bank		; ��ʊO�ŕ`�ʂ��Ȃ�
		;RTS			; �I��
		JMP GFX_ENDEND



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine�@�P�^�C��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX2:             JSR GET_DRAW_INFO       ; sets y = OAM offset
                    LDA !157C,x             ; \ $02 = direction
                    STA $02                 ; /

                    LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300|!addr,y             ; /

                    LDA $01                 ; \ tile y position = sprite y location ($01)
                    STA $0301|!addr,y             ; /


                    LDA !15F6,x             ; tile properties xyppccct, format
                    PHX
                    LDX $02                 ; \ if direction == 0...
                    BNE NO_FLIP2             ;  |
                    ORA #$40                ; /    ...flip tile
NO_FLIP2:             ORA $64                 ; add in tile priority of level
                    STA $0303|!addr,y             ; store tile properties

                    LDA #$64                 ; \ store tile

                    STA $0302|!addr,y             ; /
                    PLX
                    INY                     ; \ increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ; /    ...so increment 4 times

                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$00                ;  | A = (number of tiles drawn - 1)
                    JSL $01B7B3|!bank             ; / don't draw if offscreen
                    ;RTS                     ; RETURN
		JMP GFX_ENDEND



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; points routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_STOMP_PTS:
		;���܂ꂽ�̂�


				LDA #$36		;���Ȃ炷
				STA $1DFC|!addr		;�`�b

				LDA #$01
				STA !1632,x 		;�}���I�Ɣ������Ȃ�����

				STZ !B6,x ;�w���x�[��
				STZ !AA,x ;�x���x�[��
				STZ !1534,x  ;���[�V�����J�E���^������


				DEC !151C,x ;�g�o����炷

				LDA #$01
				STA !C2,x	;���[�V�����ԍ���1������ʂ�

                    RTS                     ; RETURN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routines below can be shared by all sprites.  they are ripped from original
; SMW and poorly documented
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $B760 - graphics routine helper - shared
; sets off screen flags and sets index to OAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $03B75C

TABLE1:              db $0C,$1C
TABLE2:              db $01,$02

GET_DRAW_INFO:       STZ !186C,x             ; reset sprite offscreen flag, vertical
                    STZ !15A0,x             ; reset sprite offscreen flag, horizontal
                    LDA !E4,x               ; \
                    CMP $1A                 ;  | set horizontal offscreen if necessary
                    LDA !14E0,x             ;  |
                    SBC $1B                 ;  |
                    BEQ ON_SCREEN_X         ;  |
                    INC !15A0,x             ; /

ON_SCREEN_X:         LDA !14E0,x             ; \
                    XBA                     ;  |
                    LDA !E4,x               ;  |
                    REP #$20                ;  |
                    SEC                     ;  |
                    SBC $1A                 ;  | mark sprite INVALID if far enough off screen
                    CLC                     ;  |
                    ADC.w #$0040            ;  |
                    CMP.w #$0180            ;  |
                    SEP #$20                ;  |
                    ROL A                   ;  |
                    AND #$01                ;  |
                    STA !15C4,x             ; /
                    BNE INVALID             ;

                    LDY #$00                ; \ set up loop:
                    LDA !1662,x             ;  |
                    AND #$20                ;  | if not smushed (1662 & 0x20), go through loop twice
                    BEQ ON_SCREEN_LOOP      ;  | else, go through loop once
                    INY                     ; /
ON_SCREEN_LOOP:      LDA !D8,x               ; \
                    CLC                     ;  | set vertical offscreen if necessary
                    ADC TABLE1,y            ;  |
                    PHP                     ;  |
                    CMP $1C                 ;  | (vert screen boundry)
                    ROL $00                 ;  |
                    PLP                     ;  |
                    LDA !14D4,x             ;  |
                    ADC #$00                ;  |
                    LSR $00                 ;  |
                    SBC $1D                 ;  |
                    BEQ ON_SCREEN_Y         ;  |
                    LDA !186C,x             ;  | (vert offscreen)
                    ORA TABLE2,y            ;  |
                    STA !186C,x             ;  |
ON_SCREEN_Y:         DEY                     ;  |
                    BPL ON_SCREEN_LOOP      ; /

                    LDY !15EA,x             ; get offset to sprite OAM
                    LDA !E4,x               ; \
                    SEC                     ;  |
                    SBC $1A                 ;  | $00 = sprite x position relative to screen boarder
                    STA $00                 ; /
                    LDA !D8,x               ; \
                    SEC                     ;  |
                    SBC $1C                 ;  | $01 = sprite y position relative to screen boarder
                    STA $01                 ; /
                    RTS                     ; RETURN

INVALID:             PLA                     ; \ RETURN from *main gfx routine* subroutine...
                    PLA                     ;  |    ...(not just this subroutine)
                    RTS                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $B817 - horizontal mario/sprite check - shared
; Y = 1 if mario left of sprite??
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $03B817                ; Y = 1 if contact

SUB_GET_DIR:         LDY #$00                ;A:25D0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1020 VC:097 00 FL:31642
                    LDA $94                 ;A:25D0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZCHC:1036 VC:097 00 FL:31642
                    SEC                     ;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1060 VC:097 00 FL:31642
                    SBC !E4,x               ;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1074 VC:097 00 FL:31642
                    STA $0F                 ;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1104 VC:097 00 FL:31642
                    LDA $95                 ;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1128 VC:097 00 FL:31642
                    SBC !14E0,x             ;A:2500 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZcHC:1152 VC:097 00 FL:31642
                    BPL LABEL16             ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1184 VC:097 00 FL:31642
                    INY                     ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1200 VC:097 00 FL:31642
LABEL16:             RTS                     ;A:25FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:1214 VC:097 00 FL:31642

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $B829 - vertical mario/sprite position check - shared
; Y = 1 if mario below sprite??
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $03B829

SUB_VERT_POS:        LDY #$00               ;A:25A1 X:0007 Y:0001 D:0000 DB:03 S:01EA P:envMXdizCHC:0130 VC:085 00 FL:924
                    LDA $96                ;A:25A1 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdiZCHC:0146 VC:085 00 FL:924
                    SEC                    ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0170 VC:085 00 FL:924
                    SBC !D8,x              ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0184 VC:085 00 FL:924
                    STA $0F                ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0214 VC:085 00 FL:924
                    LDA $97                ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0238 VC:085 00 FL:924
                    SBC !14D4,x            ;A:2501 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizcHC:0262 VC:085 00 FL:924
                    BPL LABEL11            ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0294 VC:085 00 FL:924
                    INY                    ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0310 VC:085 00 FL:924
LABEL11:             RTS                    ;A:25FF X:0007 Y:0001 D:0000 DB:03 S:01EA P:envMXdizcHC:0324 VC:085 00 FL:924


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $B817 - horizontal mario/sprite check - shared
; Y = 1 if mario left of sprite??
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $03B817

SUB_HORZ_POS:        LDY #$00                ;A:25D0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1020 VC:097 00 FL:31642
                    LDA $94                 ;A:25D0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZCHC:1036 VC:097 00 FL:31642
                    SEC                     ;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1060 VC:097 00 FL:31642
                    SBC !E4,x               ;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1074 VC:097 00 FL:31642
                    STA $0F                 ;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1104 VC:097 00 FL:31642
                    LDA $95                 ;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1128 VC:097 00 FL:31642
                    SBC !14E0,x             ;A:2500 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZcHC:1152 VC:097 00 FL:31642
                    BPL LABEL16             ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1184 VC:097 00 FL:31642
                    INY                     ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1200 VC:097 00 FL:31642
LABEL16_TWO:             RTS                     ;A:25FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:1214 VC:097 00 FL:31642


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $B85D - off screen processing code - shared
; sprites enter at different points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $03B83B

TABLE3:              db $40,$B0
TABLE6:              db $01,$FF
TABLE4:              db $30,$C0,$A0,$80,$A0,$40,$60,$B0
TABLE5:              db $01,$FF,$01,$FF,$01,$00,$01,$FF

SUB_OFF_SCREEN_X0:   LDA #$06                ; \ entry point of routine determines value of $03
                    BRA STORE_03            ;  |
SUB_OFF_SCREEN_X1:   LDA #$04                ;  |
                    BRA STORE_03            ;  |
SUB_OFF_SCREEN_X2:   LDA #$02                ;  |
STORE_03:            STA $03                 ;  |
                    BRA START_SUB           ;  |
SUB_OFF_SCREEN_HB:   STZ $03                 ; /

START_SUB:           JSR SUB_IS_OFF_SCREEN   ; \ if sprite is not off screen, RETURN
                    BEQ RETURN_2            ; /
                    LDA $5B                 ; \  goto VERTICAL_LEVEL if vertical level
                    AND #$01                ;  |
                    BNE VERTICAL_LEVEL      ; /
                    LDA !D8,x               ; \
                    CLC                     ;  |
                    ADC #$50                ;  | if the sprite has gone off the bottom of the level...
                    LDA !14D4,x             ;  | (if adding 0x50 to the sprite y position would make the high byte >= 2)
                    ADC #$00                ;  |
                    CMP #$02                ;  |
                    BPL ERASE_SPRITE        ; /    ...erase the sprite
                    LDA !167A,x             ; \ if "process offscreen" flag is set, RETURN
                    AND #$04                ;  |
                    BNE RETURN_2            ; /
                    LDA $13                 ; \
                    AND #$01                ;  |
                    ORA $03                 ;  |
                    STA $01                 ;  |
                    TAY                     ; /
                    LDA $1A                 ;x boundry ;A:0101 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0256 VC:090 00 FL:16953
                    CLC                     ;A:0100 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0280 VC:090 00 FL:16953
                    ADC TABLE4,y            ;A:0100 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0294 VC:090 00 FL:16953
                    ROL $00                 ;A:01C0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0326 VC:090 00 FL:16953
                    CMP !E4,x               ;x pos ;A:01C0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0364 VC:090 00 FL:16953
                    PHP                     ;A:01C0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0394 VC:090 00 FL:16953
                    LDA $1B                 ;x boundry hi ;A:01C0 X:0006 Y:0001 D:0000 DB:03 S:01EC P:eNvMXdizCHC:0416 VC:090 00 FL:16953
                    LSR $00                 ;A:0100 X:0006 Y:0001 D:0000 DB:03 S:01EC P:envMXdiZCHC:0440 VC:090 00 FL:16953
                    ADC TABLE5,y            ;A:0100 X:0006 Y:0001 D:0000 DB:03 S:01EC P:envMXdizcHC:0478 VC:090 00 FL:16953
                    PLP                     ;A:01FF X:0006 Y:0001 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0510 VC:090 00 FL:16953
                    SBC !14E0,x             ;x pos high ;A:01FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0538 VC:090 00 FL:16953
                    STA $00                 ;A:01FE X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0570 VC:090 00 FL:16953
                    LSR $01                 ;A:01FE X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0594 VC:090 00 FL:16953
                    BCC LABEL20             ;A:01FE X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZCHC:0632 VC:090 00 FL:16953
                    EOR #$80                ;A:01FE X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZCHC:0648 VC:090 00 FL:16953
                    STA $00                 ;A:017E X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0664 VC:090 00 FL:16953
LABEL20:             LDA $00                 ;A:017E X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0688 VC:090 00 FL:16953
                    BPL RETURN_2            ;A:017E X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0712 VC:090 00 FL:16953
ERASE_SPRITE:        LDA !14C8,x             ; \ if sprite status < 8, permanently erase sprite
                    CMP #$08                ;  |
                    BCC KILL_SPRITE         ; /
                    LDY !161A,x             ;A:FF08 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZCHC:0140 VC:071 00 FL:21152
                    CPY #$FF                ;A:FF08 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0172 VC:071 00 FL:21152
                    BEQ KILL_SPRITE         ;A:FF08 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0188 VC:071 00 FL:21152
                    LDA #$00                ; \ mark sprite to come back    A:FF08 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0204 VC:071 00 FL:21152
                    ;STA !1938,y             ; /                             A:FF00 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0220 VC:071 00 FL:21152
                    PHX
                    TYX
                    STA !1938,x
                    PLX
KILL_SPRITE:         STZ !14C8,x             ; erase sprite
RETURN_2:            RTS                     ; RETURN

VERTICAL_LEVEL:      LDA !167A,x             ; \ if "process offscreen" flag is set, RETURN
                    AND #$04                ;  |
                    BNE RETURN_2            ; /
                    LDA $13                 ; \ only handle every other frame??
                    LSR A                   ;  |
                    BCS RETURN_2            ; /
                    AND #$01                ;A:0227 X:0006 Y:00EC D:0000 DB:03 S:01ED P:envMXdizcHC:0228 VC:112 00 FL:1142
                    STA $01                 ;A:0201 X:0006 Y:00EC D:0000 DB:03 S:01ED P:envMXdizcHC:0244 VC:112 00 FL:1142
                    TAY                     ;A:0201 X:0006 Y:00EC D:0000 DB:03 S:01ED P:envMXdizcHC:0268 VC:112 00 FL:1142
                    LDA $1C                 ;A:0201 X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0282 VC:112 00 FL:1142
                    CLC                     ;A:02BD X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0306 VC:112 00 FL:1142
                    ADC TABLE3,y            ;A:02BD X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0320 VC:112 00 FL:1142
                    ROL $00                 ;A:026D X:0006 Y:0001 D:0000 DB:03 S:01ED P:enVMXdizCHC:0352 VC:112 00 FL:1142
                    CMP !D8,x               ;A:026D X:0006 Y:0001 D:0000 DB:03 S:01ED P:enVMXdizCHC:0390 VC:112 00 FL:1142
                    PHP                     ;A:026D X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNVMXdizcHC:0420 VC:112 00 FL:1142
                    LDA.w $001D|!dp             ;A:026D X:0006 Y:0001 D:0000 DB:03 S:01EC P:eNVMXdizcHC:0442 VC:112 00 FL:1142
                    LSR $00                 ;A:0200 X:0006 Y:0001 D:0000 DB:03 S:01EC P:enVMXdiZcHC:0474 VC:112 00 FL:1142
                    ADC TABLE6,y            ;A:0200 X:0006 Y:0001 D:0000 DB:03 S:01EC P:enVMXdizCHC:0512 VC:112 00 FL:1142
                    PLP                     ;A:0200 X:0006 Y:0001 D:0000 DB:03 S:01EC P:envMXdiZCHC:0544 VC:112 00 FL:1142
                    SBC !14D4,x             ;A:0200 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNVMXdizcHC:0572 VC:112 00 FL:1142
                    STA $00                 ;A:02FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0604 VC:112 00 FL:1142
                    LDY $01                 ;A:02FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizcHC:0628 VC:112 00 FL:1142
                    BEQ LABEL22             ;A:02FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0652 VC:112 00 FL:1142
                    EOR #$80                ;A:02FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0668 VC:112 00 FL:1142
                    STA $00                 ;A:027F X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0684 VC:112 00 FL:1142
LABEL22:             LDA $00                 ;A:027F X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0708 VC:112 00 FL:1142
                    BPL RETURN_2            ;A:027F X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0732 VC:112 00 FL:1142
                    BMI ERASE_SPRITE        ;A:0280 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0170 VC:064 00 FL:1195

SUB_IS_OFF_SCREEN:   LDA !15A0,x             ; \ if sprite is on screen, accumulator = 0
                    ORA !186C,x             ;  |
                    RTS                     ; / RETURN

NOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���[�V�����ʂ̏���
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:             db $0C,$F4 ;��s���x�@�E�A��

SUB_MOTION_00:	;��s���[�V����

	LDY !157C,x             ; \ set x speed based on direction
	LDA X_SPEED,y           ;  |
	STA !B6,x               ; /
	JSL $01802A|!bank             ; update position based on speed values

	LDA !7FAB10,x
	AND #$04
	BNE EXTRABITS_M0
	;���ʂȏ��Q�łȂ��Ȃ�

		BRA RTN_M0
	EXTRABITS_M0:
	;���ʂȏ��R��
		;���������Ȃ����������
		LDA !1588,x
     		AND #$04
     		BNE NOT_TURN2
     		LDA !157C,x
     		EOR #$01
     		STA !157C,x
		NOT_TURN2:
	RTN_M0:

	LDA !1588,x ;�I�u�W�F�N�g�Ɛڂ��Ă���̂�
	AND #$04	;���n�����H
	BEQ NOT_GROUD_MOTION_0
		;���n������

		INC !1534,x ;���[�V�����J�E���^�𑝂₷
		LDA !1534,x   ;�J�E���^�`�F�b�N
		CMP #$40  ;���܂�܂�����
		BNE COUNT_00
			;���܂����Ƃ�
			STZ !1534,x  ;���[�V�����J�E���^������
			LDA #$02
			STA !C2,x	;���[�V�����ԍ���2������ʂ�
		COUNT_00:
	NOT_GROUD_MOTION_0:	;���n���ĂȂ�
JMP END_MOTION

SUB_MOTION_01:	;���܂ꂽ���[�V����

	LDA !1534,x	;�J�E���^�`�F�b�N
	CMP #$00	;�[�����H
	BNE MOTION_1_SET
		LDA !151C,x   ;HP�`�F�b�N
		CMP #$00  ;�O��
		BNE MOTION_1_SET
		LDA #$02
		STA !14C8,x
		LDA #$47		;���Ȃ炷
		STA $1DFC|!addr		;�|�R
	MOTION_1_SET:

	JSL $01802A|!bank ;���x��Q�l�ɍ��W�ړ�����

	LDA !1588,x ;�I�u�W�F�N�g�Ɛڂ��Ă���̂�
	AND #$04	;���n�����H
	BEQ NOT_GROUD_MOTION_1
		;���n������
		INC !1534,x ;���[�V�����J�E���^�𑝂₷
		LDA !1534,x   ;�J�E���^�`�F�b�N
		CMP #$20  ;����Ȃ����
		BNE COUNT_01
			;���܂����Ƃ�
			STZ !1632,x ;�}���I�Ɣ�������悤�߂�(�l��[����)
			STZ !B6,x ;�w���x�[��
			STZ !1534,x  ;���[�V�����J�E���^������
			LDA #$02
			STA !C2,x	;���[�V�����ԍ���2������ʂ�
		COUNT_01:
	NOT_GROUD_MOTION_1:	;���n���ĂȂ�

JMP END_MOTION

SUB_MOTION_02:	;�W�����v���[�V����
	LDA !1534,x	;�J�E���^�`�F�b�N
	CMP #$00	;�[�����H
	BNE MOTION_2_SET
		JSR SUB_HORZ_POS ;�}���I�̂ق������
		TYA
		STA !157C,x
		LDA #$C0
		STA !AA,x ;�x���x
	MOTION_2_SET:

	INC !1534,x ;���[�V�����J�E���^�𑝂₷

	LDY !157C,x             ; \ set x speed based on direction
	LDA X_SPEED,y           ;  |
	STA !B6,x               ; /
	JSL $01802A|!bank ;���x��Q�l�ɍ��W�ړ�����

	LDA !1588,x ;�I�u�W�F�N�g�Ɛڂ��Ă���̂�
	AND #$04	;���n�����H
	BEQ NOT_GROUD_MOTION_2
		;���n������
		STZ !B6,x ;�w���x�[��
		STZ !AA,x ;�x���x�[��
		JSR SUB_HORZ_POS ;�}���I�̂ق������
		TYA
		STA !157C,x

		STZ !1534,x  ;���[�V�����J�E���^������
		LDA #$00
		STA !C2,x	;���[�V�����ԍ���0������ʂ�
	NOT_GROUD_MOTION_2:	;���n���ĂȂ�


	LDA !1588,x ;�I�u�W�F�N�g�Ɛڂ��Ă���̂�
	AND #$08	;�V��ɓ��Ԃ����H
	BEQ NOT_TENJO_MOTION_2
		STZ !AA,x ;�x���x�[��
	NOT_TENJO_MOTION_2:	;���n���ĂȂ�

JMP END_MOTION


