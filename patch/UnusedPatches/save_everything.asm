!dp = $0000
!addr = $0000
!sa1 = 0
!gsu = 0
!bank = $800000

if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!gsu = 1
	!bank = $000000
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!sa1 = 1
	!bank = $000000
endif

org $009E1C|!bank
	STZ.w $13C9|!addr
	BRA +
org $009E54|!bank
+