;ruleset to use for fire flower and feather filters
;	0 = a filtered fire flower or feather will always be given back.
;	1 = if the mushroom the filtered item has been turned into gets lost, the item will be lost as well.

!ruleset = 1

;freeram to use. make sure nothing else in your hack uses this!
;note that it must not get cleared on level load or overworld load.

!FilterRAM = $13C8|!addr

;ram format for nerds: %f--iiipp
;f = the "fingerprint" bit, which is only used in ruleset 1 to check whether the current filter is a small-only filter, thus skipping the ruleset checks.
;iii = stored item box item ($0DC2 format), pp = stored powerup ($19 format).