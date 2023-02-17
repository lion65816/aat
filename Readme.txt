----------
Level 122
----------

Instructions:
- Insert all the included "Level" and "uberasm" files.
- Fix the palette for the Demo blocks in Level 1D0 (copy palette row 8 to row 7).
- Uncheck "Level has been passed" in the Overworld Editor.
- Remove from UberASM list:
1D6	DeathWarp_1D6.asm
- Add secondary exit #28 (if not already saved with level)
- Change Message 123-2 (uncheck Auto Space):
If you get stuck, 
press SELECT to   
retry.            
                  
-Unknown caller   

Changelog:
- Modified DeathWarp.asm to make the player lose Yoshi when falling into lava or a pit.
- Made the Furba gap only one tile wide.
- Redesigned the end of Level 1D0 a bit (using a P-Switch in addition to a star).
- Changed the layout in Level 1D6.
- Prevented Demo's death tiles from overwriting the respawn tile at the second midpoint, avoiding a potential softlock.
- Fixed some cutoff with Demo's head if Demo dies on top of a Demo block.
- Added Primitive Retry for when the player presses Select.
- Changed Message 123-2 slightly.
