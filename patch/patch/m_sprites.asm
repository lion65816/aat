lorom
!bank = $800000
!addr = $0000

if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
	!addr = $6000
endif

; see the "rates" table at the bottom to change which moles/hammer rates to use for each level

; waiting times for the monty moles
!mole_wait_fast = $20
!mole_wait_slow = $68

; hammer frequencies (smaller values = faster rates)
!hammer_wait_fast = $0F
!hammer_wait_slow = $1F

org $01E2F3
	autoclean JML mole_hijack
	
org $01E2FB
	db !mole_wait_slow
	
org $01E301
	db !mole_wait_fast
	
org $02DA67
	db !hammer_wait_fast,!hammer_wait_slow
	
org $02DA79
	autoclean JML hammer_hijack
	
; change to bne because medic said so
org $02DA8F
	db $D0

freecode

mole_hijack:
	PHX
	LDX $13BF|!addr
	LDA.l rates,x
	AND #$01
	PLX
	JML $01E2F9|!bank
	
hammer_hijack:
	PHX
	LDX $13BF|!addr
	LDA.l rates,x
	LSR
	AND #$01
	PLX
	JML $02DA7F|!bank

; VALID VALUES:
; $00 for fast moles + hammers
; $01 for slow moles, but fast hammers
; $02 for slow hammers, but fast moles
; $03 for slow moles + hammers
rates:
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 000-007
	db $02,$02,$02,$02,$02,$02,$00,$02	; levels 008-00F
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 010-017
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 018-01F
	db $02,$02,$02,$02,$02			; levels 020-024

	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 101-108
	db $03,$02,$02,$02,$02,$02,$02,$02	; levels 109-110
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 111-118
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 119-120
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 121-128
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 129-130
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 131-138
	db $02,$02,$02				; levels 139-13B
