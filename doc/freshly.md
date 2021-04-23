# Freshly Programming Reference

## Rendering

cls( color ) -> void
camera( x = 0, y = x )
rect( l, t, r, b, color = white, thickness = 1 ) -> void
rectfill( l, t, r, b, color = white ) -> void
arc( x, y, radius = 1, arcLength = 90, rotation = 0, color = white, lineThickness = 1, segments = 24 ) -> void
arcfill( x, y, radius = 1, arcLength = 90, rotation = 0, color = white, segments = 24 ) -> void
circ( x, y, radius, color = white, lineThickness = 1, segments = 24 )
circfill( x, y, radius, color = white, segments = 24 )
line( x0, y0, x1, y1, color = white, lineThickness = 1, capType = 'butt' ['butt'|'square'|'round'] )
print( string = "", x = default, y = default, color = white, font = 0 [max: 4], scale = 1, noNewLine = false )
spr( index, x, y, wid = 1, hgt = 1, flipX = false, flipY = false, color = white )
sspr( sx, sy, sw, sh = sw, x, y, wid = sx, hgt = sy, flipX = false, flipY = false, color = white )
fget( index, mask ) -> 0 (unimplemented)
fset( index, flag, value ) -> void (unimplemented)

## Virtual Cathode Screen

screen_size( wid, hgt = wid )
screen_wid() -> int
screen_hgt() -> int
filter_mode( mode: string ['Nearest', 'Bilinear', 'Trilinear' ] ) -> void
barrel( distortion = 0 ) -> void
bloom( intensity = 0 [0, 100], contrast = 0 [-1,1], brightness = 0, [1,10] ) -> void
burn_in( amount = 0 [0,1] ) -> void
chromatic_aberration( aberration = 0 [-100,100] ) -> void
noise( amount, rescan_r = 0, rescan_g = rescan_r, rescan_b = rescan_g, rescan_a = 1 ) -> void
saturation( sat ) -> void
color_multiplied( r, g = r, b = g, a = 1 ) -> void
bevel( intensity )

## Sound

sfx( name, gain = 1.0 ) -> void
music( name, gain = 1.0 ) -> void

## Input

touchx() -> val or -1
touchy() -> val or -1
touchupx() -> val or -1
touchupy() -> val or -1
btn( button, player ) -> boolean
btnp( button, player ) -> boolean
key( key ) -> boolean
keydown( key ) -> boolean
keyup( key ) -> boolean

# Maps

map( cel_x, cel_y, sx, sy, cel_w = 1, cel_h = cel_w, layer = 0 )
mapdraw = map
mget( x, y ) -> int
mset( x, y, v ) -> void

## Math

vec( x, y ) -> (x, y)

## System

sprite_size( wid, hgt = wid ) -> void
text_scale( scale = 1.0 ) -> void
text_line_hgt( scale = 1.0f ) -> void
time() -> double
_debug_trace( string ) -> void
rect_collision_adjustment(  leftA, topA, rightA, botA,
                            leftB, topB, rightB, botB,
                            relVelX, relVelY ) -> 
    (   colliding: bool,
        normalX,
        normalY,
        hitAxis [0|1],
        adjustmentDistance
     )
execute( string ) -> void