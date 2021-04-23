-- Ludum Dare 48

-- UTILITY

function lerp( a, b, alpha )
	return a + (b-a) * alpha
end

function randInRange( a, b )
	return lerp( a, b, math.random() )
end

function randInt( a, b )
	return math.floor( randInRange( a, b ))
end

function randomElement( tab )
	local n = #tab
	if n == 0 then return nil end

	return tab[ math.random( 1, #tab ) ]
end

function tableString( tab )
	local str = ''
	for key, value in pairs( tab ) do
		str = str .. key .. '=' .. value .. ', '
	end
	return str
end

function tableStringValues( tab )
	local str = ''
	for _, value in pairs( tab ) do
		str = str .. value .. ' '
	end
	return str
end

function stringify( o )
	if type( o ) == 'table' then
		return saveTable( o )
	elseif type( o ) == 'string' then
		return '"' .. o .. '"'
	elseif type( o ) == 'boolean' then
		return boolToString( o )
	elseif type( o ) == 'function' then
		return '<function>'
	else
		return '' .. o
	end
end

function tableFind( tab, element )
    for index, value in pairs(tab) do
        if value == element then
            return index
        end
	end
	return nil
end

function tableRemoveValue( tab, element )
	table.remove( tab, tableFind( tab, element ))
end

function tableCopy( t )
	local u = {}
	for k, v in pairs(t) do
		u[k] = v
	end
	return setmetatable(u, getmetatable(t))
end

function tableFilter( tab, fn )
	local result = {}
	for _, value in ipairs( tab ) do
		if fn( value ) then
			table.insert( result, value )
		end
	end
	return result
end

function boolToString( b )
	return b and 'true' or 'false'
end

local MUTE_SOUND = false

function sfxm( sound, gain )
	if not MUTE_SOUND then
		sfx( sound, gain )
	end
end

function musicm( sound, gain )
	if not MUTE_SOUND or #sound == 0 then
		music( sound, gain )
	end
end

local debugCircles = {}
local debugMessages = {}

function drawDebugCircles()
	for _, circle in ipairs( debugCircles ) do
		circ( circle[1].x, circle[1].y, 32 )
	end

	debugCircles = {}
end

function drawDebug()
	print( '', 0, 0 )

	-- print( tostring( mousex ) .. ',' .. tostring( mousey ) .. '::' .. tostring( placeableRoom ))
	-- print( tostring( world.focusX ) .. ',' .. tostring( world.focusY ))

	-- print( 'actors: ' .. tostring( #world.actors ), 0, 0 )

	for _,message in ipairs( debugMessages ) do
		print( message )
	end

	while #debugMessages > 10 do
		table.remove( debugMessages, 1 )
	end
end

function debugCircle( center, radius, color )
	table.insert( debugCircles, {center, radius, color })
end

function trace( message )
	table.insert( debugMessages, message )
end

function length( x, y )
	return math.sqrt( x * x + y * y )
end

function sign( x )
	return x < 0 and -1 or ( x > 0 and 1 or 0 )
end

function signNoZero( x )
	return x < 0 and -1 or 1
end

function clamp( x, minimum, maximum )
	return math.min( maximum, math.max( x, minimum ))
end

function proportion( x, a, b )
	return ( x - a ) / ( b - a )
end

function pctChance( percent )
	return randInRange( 0, 100 ) <= percent
end

function round( x, divisor )
	divisor = divisor or 1
	return ( x + 0.5 ) // divisor * divisor
end

-- TIME

local ticks = 0
function now()
	return ticks * 1 / 60.0
end

local realTicks = 0
function realNow()
	return realTicks * 1 / 60.0
end

-- Configuration

support_virtual_trackball( true )
text_scale( 1 )
filter_mode( "Nearest" )

screen_size( 220, 0 )

local WHITE = 0xFFE3E0F2
local YELLOW = 0xFFDBC762
local BRIGHT_RED = 0xFFC23324
local LIGHT_GRAY = 0xFFB0B8BF
local BRIGHT_BLUE = 0xFF0466c2


-- GLOBALS

local SPRITE_SHEET_PIXELS_X = 512
local PIXELS_PER_TILE = 16
local TILES_X = SPRITE_SHEET_PIXELS_X // PIXELS_PER_TILE

local ACTOR_DRAW_MARGIN = PIXELS_PER_TILE

sprite_size( PIXELS_PER_TILE )

local WORLD_SIZE_TILES = 32
local WORLD_SIZE_PIXELS = WORLD_SIZE_TILES * PIXELS_PER_TILE

function spriteIndex( x, y )
	return y * TILES_X + x
end

function worldToTile( x )
	return math.floor( x / PIXELS_PER_TILE )
end

local DEFAULT_CHROMATIC_ABERRATION = 0.4
local DEFAULT_BARREL = 0.2
local DEFAULT_BLOOM_INTENSITY = 0.1
local DEFAULT_BURN_IN = 0.1

local barrel_ = DEFAULT_BARREL
local bloom_intensity_ = DEFAULT_BLOOM_INTENSITY
local bloom_contrast_ = 10
local bloom_brightness_ = 1
local burn_in_ = DEFAULT_BURN_IN
local chromatic_aberration_ = DEFAULT_CHROMATIC_ABERRATION
local noise_ = 0.025
local rescan_ = 0.75
local saturation_ = 1
local color_multiplied_r = 1
local color_multiplied_g = 1
local color_multiplied_b = 1
local bevel_ = 0.20

local barrel_smoothed = barrel_
local bloom_intensity_smoothed = bloom_intensity_
local bloom_contrast_smoothed = bloom_contrast_
local bloom_brightness_smoothed = bloom_brightness_
local burn_in_smoothed = burn_in_
local chromatic_aberration_smoothed = chromatic_aberration_
local noise_smoothed = noise_
local rescan_smoothed = rescan_
local saturation_smoothed = saturation_
local color_multiplied_r_smoothed = color_multiplied_r
local color_multiplied_g_smoothed = color_multiplied_g
local color_multiplied_b_smoothed = color_multiplied_b
local bevel_smoothed = bevel_

local SCREEN_EFFECT_SMOOTH_FACTOR = 0.035

function updateScreenParams()
	barrel_smoothed = lerp( barrel_smoothed, barrel_, SCREEN_EFFECT_SMOOTH_FACTOR )
	bloom_intensity_smoothed = lerp( bloom_intensity_smoothed, bloom_intensity_, SCREEN_EFFECT_SMOOTH_FACTOR )
	bloom_contrast_smoothed = lerp( bloom_contrast_smoothed, bloom_contrast_, SCREEN_EFFECT_SMOOTH_FACTOR )
	bloom_brightness_smoothed = lerp( bloom_brightness_smoothed, bloom_brightness_, SCREEN_EFFECT_SMOOTH_FACTOR )
	burn_in_smoothed = lerp( burn_in_smoothed, burn_in_, SCREEN_EFFECT_SMOOTH_FACTOR )
	chromatic_aberration_smoothed =
		lerp( chromatic_aberration_smoothed, chromatic_aberration_, SCREEN_EFFECT_SMOOTH_FACTOR )
	noise_smoothed = lerp( noise_smoothed, noise_, SCREEN_EFFECT_SMOOTH_FACTOR )
	rescan_smoothed = lerp( rescan_smoothed, rescan_, SCREEN_EFFECT_SMOOTH_FACTOR )
	saturation_smoothed = lerp( saturation_smoothed, saturation_, SCREEN_EFFECT_SMOOTH_FACTOR )
	color_multiplied_r_smoothed = lerp( color_multiplied_r_smoothed, color_multiplied_r, SCREEN_EFFECT_SMOOTH_FACTOR )
	color_multiplied_g_smoothed = lerp( color_multiplied_g_smoothed, color_multiplied_g, SCREEN_EFFECT_SMOOTH_FACTOR )
	color_multiplied_b_smoothed = lerp( color_multiplied_b_smoothed, color_multiplied_b, SCREEN_EFFECT_SMOOTH_FACTOR )
	bevel_smoothed = lerp( bevel_smoothed, bevel_, SCREEN_EFFECT_SMOOTH_FACTOR )

	barrel( barrel_smoothed )
	bloom( bloom_intensity_smoothed, bloom_contrast_smoothed, bloom_brightness_smoothed )
	burn_in( burn_in_smoothed )
	chromatic_aberration( chromatic_aberration_smoothed )
	noise( noise_smoothed, rescan_smoothed )
	saturation( saturation_smoothed )
	color_multiplied( color_multiplied_r_smoothed, color_multiplied_g_smoothed, color_multiplied_b_smoothed )
	bevel( bevel_smoothed, 1 )
end

updateScreenParams()


-- Vector

--[[
Vector class ported/inspired from
Processing (http://processing.org)
]]--
local vec2 = {}

function vec2:new( x, y )

	if type( x ) == 'table' then
		y = x.y
		x = x.x
	end

	x = x or 0
	y = y or x

	local o = {
	x = x,
	y = y
	}

	self.__index = self
	return setmetatable(o, self)
end

function vec2:__add(v)
  return vec2:new( self.x + v.x, self.y + v.y )
end

function vec2:__sub(v)
	return vec2:new( self.x - v.x, self.y - v.y )
end

function vec2:__mul(v)
	if v == nil then
		trace( 'vec2:__mul called with nil operand.' )
		return
	end

	if type( v ) == 'number' then
		v = { x = v, y = v }
	end

	return vec2:new( self.x * v.x, self.y * v.y )
end

function vec2:__div(v)

	if type( v ) == 'number' then
		v = { x = v, y = v }
	end

	if v.x == nil or v.x == 0 then
		v.x = 1
	end

	if v.y == nil or v.y == 0 then
		v.y = 1
	end

	return vec2:new( self.x / v.x, self.y / v.y )
end

function vec2:length()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function vec2:lengthSquared()
  return self.x * self.x + self.y * self.y
end

function vec2:dist(v)
  local dx = self.x - v.x
  local dy = self.y - v.y

  return math.sqrt(dx * dx + dy * dy)
end

function vec2:dot(v)
  return self.x * v.x + self.y * v.y
end

function vec2:majorAxis()
	return math.abs( self.x ) > math.abs( self.y ) and 0 or 1
end

function vec2:snappedToMajorAxis()
	if self:majorAxis() == 0 then
		return vec2:new( signNoZero( self.x ), 0 )
	else
		return vec2:new( signNoZero( self.y ), 0 )
	end
end

function vec2:cardinalDirection() -- 0 = north, 1 = east...
	if self:majorAxis() == 0 then
		return self.x >= 0 and 1 or 3
	else
		return self.y >= 0 and 2 or 0
	end
end

function vec2:normal()
  local m = self:length()
  if m ~= 0 then
    return self / m
  else
	return self
  end
end

function vec2:limit(max)
  local m = self.lengthSquared()
  if m >= max * max then
    return self:normal() * max
  end
end

 function vec2:heading()
  local angle = math.atan2(-self.y, self.x)
  return -1 * angle
end

function vec2:rotate(theta)
  local tempx = self.x
  self.x = self.x * math.cos(theta) - self.y * math.sin(theta)
  self.y = tempx * math.sin(theta) + self.y * math.cos(theta)
end

function vec2:angle_between(v1, v2)
  if v1.x == 0 and v1.y then
    return 0
  end

  if v2.x == 0 and v2.y == 0 then
    return 0
  end

  local dot = v1.x * v2.x + v1.y * v2.y
  local v1mag = math.sqrt(v1.x * v1.x + v1.y * v1.y)
  local v2mag = math.sqrt(v2.x * v2.x + v2.y * v2.y)
  local amt = dot / (v1mag * v2mag)

  if amt <= -1 then
    return math.pi
  elseif amt >= 1 then
    return 0
  end

  return math.acos(amt)
end

function vec2:set(x, y)
	if type( x ) == 'table' then
		self.x = x.x
		self.y = x.y
	else
		self.x = x
		self.y = y ~= nil and y or x
	end
end

function vec2:equals(o)
  o = o or {}
  return self.x == o.x and self.y == o.y
end

function vec2:__tostring()
  return '(' .. string.format( "%.2f", self.x ) .. ', ' .. string.format( "%.2f", self.y ) .. ')'
end

function sheet_pixels_to_sprite( x, y )
	return ( y // PIXELS_PER_TILE ) * (SPRITE_SHEET_PIXELS_X//PIXELS_PER_TILE) + ( x // PIXELS_PER_TILE )
end

-- Objects

function rectsOverlap( rectA, rectB )
	return not (
			rectB.right < rectA.left
		or  rectB.left > rectA.right
		or  rectB.bottom < rectA.top
		or  rectB.top > rectA.bottom )
end

function rectOverlapsPoint( rect, pos )
	return rect.left <= pos.x and pos.x <= rect.right and rect.top <= pos.y and pos.y <= rect.bottom
end

function expandContractRect( rect, expansion )
	rect.left = rect.left - expansion
	rect.top = rect.top - expansion
	rect.right = rect.right + expansion
	rect.bottom = rect.bottom + expansion
	return rect
end

function headingToDirectionName( direction )
	if direction == 0 then return 'north'
	elseif direction == 1 then return 'east'
	elseif direction == 2 then return 'south'
	elseif direction == 3 then return 'west'
	else return nil end
end

function range( from, to, step )
	local arr = {}
	for i = from, to, step or 1 do
		table.insert( arr, i )
	end
	return arr
end

function floatTermsToColor( r, g, b )

	function term( x )
		return math.floor( x * 0xFF )
	end

	return 0xFF000000 | ( term( r ) << 16 ) | ( term( g ) << 8 ) | term( b )
end

function colorToFloatTerms( color )
	local r = ( color & 0x00FF0000 ) >> 16
	local g = ( color & 0x0000FF00 ) >> 8
	local b = ( color & 0x000000FF ) >> 0

	function term( x )
		return x / 0xFF
	end

	return term( r ), term( g ), term( b )
end

function colorLerp( a, b, alpha )
	local ar, ag, ab = colorToFloatTerms( a )
	local br, bg, bb = colorToFloatTerms( b )

	return floatTermsToColor( lerp( ar, br, alpha ), lerp( ag, bg, alpha ), lerp( ab, bb, alpha ) )
end

-- UPDATING!!!

function update()
	realTicks = realTicks + 1
end


-- DRAWING!!!

function printShadowed( text, x, y, color, font, shadowColor )
	print( text, x, y+1, shadowColor or 0xFF161C21, font )
	print( text, x, y, color, font )
end

function printOutlined( text, x, y, color, font, outlineColor )
	outlineColor = outlineColor or WHITE
	print( text, x+1, y  , outlineColor, font )
	print( text, x-1, y  , outlineColor, font )
	print( text, x  , y+1, outlineColor, font )
	print( text, x  , y-1, outlineColor, font )
	print( text, x, y, color, font )
end

function printRightAligned( text, x, y, color, font, printFn )
	( printFn or print )( text, x - #text * 8, y, color, font )
end

function printCentered( text, x, y, color, font, printFn )
	( printFn or print )( text, x - #text * 4, y, color, font )
end

function draw()
	cls( 0xff000040 )
	camera( 0, 0 )
	drawDebug()
end
