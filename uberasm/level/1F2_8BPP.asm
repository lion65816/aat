;; REQUIRES the LC_LZ2 patch and Layer 3 ExGFX
;; You must save at least one level with an ExAnimation slot used. (you don't have to leave it that way)
;;              This is to allow using $7FC00A to stop the palette animation to color $64
;;              If you are still using LM1.65, then don't use color 64, you are limited to 255 colors.

;; If you are using LM1.65 or lower, you will also need to set this to !True


       !ExGFX01 = $0D50
       !ExGFX02 = $0D51
       !ExGFX03 = $0D52
       !ExGFX04 = $0D53
       !ExGFX05 = $0D54
       !ExGFX06 = $0D55
       !ExGFX07 = $007F
       !ExGFX08 = $007F
       !ExGFX09 = $007F
       !ExGFX10 = $007F
       !ExGFX11 = $007F
       !ExGFX12 = $007F
       !ExGFX13 = $007F
       !ExGFX14 = $007F
       !TilemapFile = $0D56
       !PaletteFile = $0D57

if !sa1
	!GFXBuffer = $410000
else
	!GFXBuffer = $7EAD00
endif


ExGFXFiles:
       dw !ExGFX01,!ExGFX02,!ExGFX03,!ExGFX04
       dw !ExGFX05,!ExGFX06,!ExGFX07,!ExGFX08
       dw !ExGFX09,!ExGFX10,!ExGFX11,!ExGFX12
       dw !ExGFX13,!ExGFX14,!TilemapFile

VRAMAddrs:
       dw $0000,$0800,$1000,$1800
       dw $2000,$2800,$3000,$3800
       dw $4000,$4800,$5000,$5800
       dw $6000,$6800,$7C00

init:
       LDA #$80
       STA $2115

       REP #$30

       LDY #$001C
-      LDA.w ExGFXFiles,y
       LDX.w VRAMAddrs,y
       JSR UploadGFXFile
       DEY #2
       BPL -

       LDA #!PaletteFile
       LDX #$0000
       JSR UploadPalette

       SEP #$30

       LDA #$FF
       STA $7FC00A        ; prevent color 64 overwrite

       ; fix higan
       STZ $2106          ; disable mosaic
       STZ $2133          ; hires mode, interleave, etc.
       STZ $210B          ; reset layer 1 chr address

       LDA #$03
       STA $2105
       STA $3E
       LDA #$7C
       STA $2107
       STZ $1A
       STZ $1B
	STZ $1462|!addr
	STZ $1463|!addr
       LDA #$FF
       STA $1C
       STA $1D
	STA $1464|!addr
	STA $1465|!addr
       LDA #$01
       STA $212C
       STZ $212D
       STZ $212E
       STZ $212F

       LDA #$20
       STA $2131
       STA $40

       STZ $2131
       STZ $40

	LDA #$01
	STA $13FB|!addr
	RTL

UploadGFXFile:
       PHY                         ; back up Y
       PHX                         ; back up X
       LDX #!GFXBuffer             ; \ GFX buffer low
       STX $00                     ; / and high byte
       SEP #$10
       LDX.b #!GFXBuffer>>16       ; \ GFX buffer
       STX $02                     ; / bank byte
       JSL $0FF900
       CMP #$0100
       BCS .Upload                 ; if success, then upload
       REP #$30
       PLX                         ; restore X
       PLY                         ; restore Y
       RTS

.Upload
       REP #$10                    ; 16-bit X/Y
       SEP #$20
       PLX                         ; \ restore X, X is the
       STX $2116                   ; / VRAM destination
       LDA #$01                    ; \ control
       STA $4300                   ; / register
       LDA #$18                    ; \ dma to
       STA $4301                   ; / [21]18
       LDX #!GFXBuffer             ; \
       STX $4302                   ;  | source
       LDA.b #!GFXBuffer>>16       ;  | of data
       STA $4304                   ; /
       LDX $8D                     ; \ size of decompressed
       STX $4305                   ; / GFX File
       LDA #$01                    ; \ start DMA
       STA $420B                   ; / transfer
       REP #$20                    ; 16-bit A
       PLY                         ; restore Y
       RTS

UploadPalette:
       PHY                         ; back up Y
       PHX                         ; back up X
       LDX #!GFXBuffer             ; \ GFX buffer low
       STX $00                     ; / and high byte
       SEP #$10
       LDX.b #!GFXBuffer>>16       ; \ GFX buffer
       STX $02                     ; / bank byte
       JSL $0FF900
       CMP #$0100
       BCS .Upload                 ; if success, then upload
       REP #$30
       PLX                         ; restore X
       PLY                         ; restore Y
       RTS

.Upload
       REP #$10                    ; 16-bit X/Y
       SEP #$20
       PLX                         ; \  restore X, X is the
       TXA                         ;  | 8-bit starting
       STA $2121                   ; /  color number
       LDA #$00                    ; \ control
       STA $4300                   ; / register
       LDA #$22                    ; \ dma to
       STA $4301                   ; / [21]22
       LDX #!GFXBuffer             ; \
       STX $4302                   ;  | source
       LDA.b #!GFXBuffer>>16       ;  | of data
       STA $4304                   ; /
       LDX $8D                     ; \ size of decompressed
       STX $4305                   ; / GFX File
       LDA #$01                    ; \ start DMA
       STA $420B                   ; / transfer
       REP #$20                    ; 16-bit A
       PLY                         ; restore Y
       RTS

main:
	;LDA #$01
	;STA $13FB|!addr
	RTL