Customizable Firebar
by Isikoro

You can make various fire bars with this one.

You can make the following settings.


Extra Bits	:Initial rotation direction
　2 = Clockwise
　3 = Counterclockwise


Extra Byte 1
bit0-4	:　Number of fireballs + 1

bit5	:　Fireball size
　00 = Small（8x8）
　01 = Big（16x16）

bit6-7
If the pendulum movement flag is clear, ON / OFF interlocking flag
　00 = No ON/OFF interlocking.
　01 = The rotation direction is reversed by switching ON/OFF.
　10 = It will stop when it is ON.
　11 = It will stop when it is OFF.
If the pendulum movement flag is set, the direction of gravity with respect to the firebar
　00 = Bottom
　01 = Left
　10 = Top
　11 = Right


Extra Byte 2
bit0-6	:　Initial rotation speed

bit7	:　Direction to shift when appearing（Effective when Extra Prop is 01 or above）
　0 = Shifts to the right for vertical levels and down for horizontal levels.
　1 = Shifts to the left for vertical levels and up for horizontal levels.



Extra Byte 3
bit0-7	:　Initial angle（It shifts clockwise by the numerical value.）
　	:　00 = Horizontal right
	:　80 = Horizontal left


Extra Byte 4
bit0-6　:　Pendulum movement flag
　A pendulum exercise is performed with 01 or more.
　The larger the value, the faster the rotation speed increases and decreases.
　It cannot be used together with ON / OFF interlocking.

bit7	:　Layer 2 interlocking flag
　When set to 1, the center axis will be scrolled together with layer 2.
　The initial position is also shifted according to the position of layer 2.



Extra Prop 1
　If it is 01 or more, the position can be shifted according to the length when it appears.
　As soon as it appears, you can prevent the firebar from overlapping with the player and taking damage.

　There is a fire bar at the shift destination,
　and that fire bar's If "Extra Byte 1", "Extra Byte 3" and "Extra Bits"
　match the shift source, and !14C8,x = 08, Erase the shift source fire bar.

　If there are 7 8x8 fireballs, 
  shift 1 tile. After that, each time you add two, it will shift by one tile.
  If there are 4 16x16 fireballs, 
  each time you add one, it will shift by one tile.


