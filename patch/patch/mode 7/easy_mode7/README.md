Easy Mode 7 Patch
=================

When you try to use Mode 7 in the original SMW, you can’t properly use its registers unless you store $C1 to $7E:0D9B to activate Bowser’s battle mode. The problem, in this case, is that part of the Mode 7 tilemap is reserved to Bowser and thus is always filled with undesired tiles which are impossible to get rid of.

The earlier version of this patch, entirely made by HuFlungDu, corrected this aspect but caused the Mode 7 image to act like Iggy/Larry’s platform and some sprite tiles to appear.

The version you can download here has been corrected with SA-1 compatibility and 2 tweaks to disable 1) Iggy/Larry’s platform rotation 2) Iggy/Larry’s animated lava sprite tiles.

ExE Boss’s Changes
------------------
- Full compatibility with all of the original game’s Mode 7 bosses
- Added a subroutine for uploading the Mode 7 GFX and tilemap to VRAM
- The Layer 3 status bar can now enabled by setting the Layer 3 absolute priority bit of $3E, this then works the same way as in the Koopaling/Reznor battles by using IRQ to change the background mode at scanline $24 ($26 with Super Status Bar).
