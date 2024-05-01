; Enable the Iggy/Larry battle fix
;
; WARNING! If you have previously installed versions 1.0 or earlier,
; You have to restore the Iggy/Larry platform and lava subroutines yourself
; or set this to 0, otherwise glitches, and possibly crashes, WILL occur.
!FixIggyLarry	= 1

; Mode 7 GFX DMA subroutine
; =========================
; Inputs:
;   A (8-bit):	Bank to upload data from
;   X (16-bit):	Address to upload from
;   Y (16-bit):	Type of data to upload:
;     - $0001:	Mode 7 GFX upload
;     - $0002:	Mode 7 Tilemap upload
;     - $0003:	Mode 7 interleaved GFX + Tilemap upload
; =========================
; Address pointing to freespace that will contain the JML to the actual
; subroutine location.
; Needs 4 bytes if in banks $00-$0F, otherwise needs 8 bytes for the RATS tag
; and 4 bytes for the actual JML (note that the value contained in this is the
; address of the JML and not of the RATS tag, so add 8 if in banks $10+).
; Set to 0 to disable
!UploadMode7gfxSubroutine	= $3FFFC0+8
