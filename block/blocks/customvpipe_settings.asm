;don't insert this file! keep it in the blocks folder, and set up here the screen exits to take and
;condition to use (if applicable).

;SCREEN EXIT TO USE
;	this is NOT a level number, but a screen number! so if this is $00, the pipe you take you to the
;	exit set up in screen 00.

	!ScreenExit = $14

;USE A CONDITION?
;	0 = no, 1 = yes

	!Condition = 0

;CONDITION TO USE
;	browse smw central's ram map: https://www.smwcentral.net/?p=memorymap&m=smwram
;	you can get the ram value of the conditional flag you wish to use for this pipe.
;	here are some common examples of flags you may want to use:
;		$1420 = number of dragon coins collected in the current level.
;		$14AD = blue p-switch timer. if this is higher than zero, the blue p-switch is pressed.
;		$14AF = on/off switch flag. if this is higher than zero, the switch is off.
;		$1F2E = number of exits obtained.		

	!Flag = $14AD|!addr

;CONDITION VALUE
;	when the flag's value is EQUAL OR HIGHER than the this value, the pipe will use !ScreenExitCond
;	when it's LOWER than this value, this pipe uses !ScreenExit instead.
;	usage examples:
;		$01 with $14AD = this will use !ScreenExitCond whenever the blue p-switch is running.
;		$0A with $1F2E = this will use !ScreenExitCond after 10 exits have been obtained.
	
	!FlagValue = $01


;SCREEN EXIT TO USE WHEN CONDITION IS MET

	!ScreenExitCond = $01 