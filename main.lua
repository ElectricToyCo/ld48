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

function degreesToRadians( deg )
	return deg / 180.0 * math.pi
end

function radiansToDegrees( rad )
	return rad / math.pi * 180.0
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

function wrap( x, minimum, maximum )
	local a = x - minimum
	local range = maximum - minimum
	return minimum + ( a - range * math.floor( a / range ))
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

function flash( hz, flashColor, baseColor, time, flashFunc )
	time = time or now()
	baseColor = baseColor == nil and 0xFF000000 or baseColor
	flashFunc = flashFunc or function( t )
		return 0.5 + 0.5 * math.cos( math.pi * t )
	end

	local normTime = wrap( time * hz, 0.0, 1.0 )
	return colorLerp( baseColor, flashColor, flashFunc( normTime ) )
end

function flashOnce( duration, flashColor, baseColor, time, flashFunc )
	time = time or now()
	baseColor = baseColor == nil and 0xFF000000 or baseColor
	flashFunc = flashFunc or function( t )
		return 0.5 + 0.5 * math.cos( math.pi * t )
	end

	local normTime = clamp( time / duration, 0.0, 1.0 )
	return colorLerp( baseColor, flashColor, flashFunc( normTime ) )
end

-- Configuration

text_scale( 1 )
filter_mode( "Nearest" )

-- screen_size( 480, 270 )
screen_size( 448, 252 )

-- GLOBALS

local WHITE = 0xFFFFFFFF
local YELLOW = 0xFFE8C170
local YELLOW_ORANGE = 0xFFDE9E41

local SPRITE_SHEET_PIXELS_X = 512
local PIXELS_PER_TILE = 16
local TILES_X = SPRITE_SHEET_PIXELS_X // PIXELS_PER_TILE

local ACTOR_DRAW_MARGIN = PIXELS_PER_TILE

sprite_size( PIXELS_PER_TILE )

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
local bevel_ = 0

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

function rectOverlapsRay( rect, rayOrig, rayDir )
	-- project corners of rect onto ray. If all one one side or other, no collision. Else yes.
	if rectOverlapsPoint( rect, rayOrig ) then
		return true
	end

	local rayTangent = vec2:new( rayDir )
	rayTangent:rotate( math.pi * 0.5 )

	function pointDirFromRay( x, y )
		local p = vec2:new( x, y ) - rayOrig
		return {
			forward = rayDir:dot( p ),
			side = rayTangent:dot( p )
		}
	end

	local signs = {
		pointDirFromRay( rect.left, rect.top ),
		pointDirFromRay( rect.right, rect.top ),
		pointDirFromRay( rect.right, rect.bottom ),
		pointDirFromRay( rect.left, rect.bottom )
	}

	local forward = signs[ 1 ].forward >= 0
	local side = signNoZero( signs[ 1 ].side )
	local isSplit = false
	for _, corner in ipairs( signs ) do
		if signNoZero( corner.side ) ~= side then isSplit = true end
		forward = forward or corner.forward >= 0
	end

	return forward and isSplit
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

function floatTermsToColor( r, g, b, a )

	function term( x )
		return math.floor( x * 0xFF )
	end

	return ( term( a ) << 24 ) | ( term( r ) << 16 ) | ( term( g ) << 8 ) | term( b )
end

function colorToFloatTerms( color )
	local a = ( color & 0xFF000000 ) >> 24
	local r = ( color & 0x00FF0000 ) >> 16
	local g = ( color & 0x0000FF00 ) >> 8
	local b = ( color & 0x000000FF ) >> 0

	function term( x )
		return x / 0xFF
	end

	return term( r ), term( g ), term( b ), term( a )
end

function colorLerp( a, b, alpha )
	local ar, ag, ab, aa = colorToFloatTerms( a )
	local br, bg, bb, ba = colorToFloatTerms( b )

	return floatTermsToColor( lerp( ar, br, alpha ), lerp( ag, bg, alpha ), lerp( ab, bb, alpha ), lerp( aa, ba, alpha ) )
end

-- Game systems

local VIEW_LEFT_OFFSET = 80
local GROUND_VIEW_OFFSET_Y = 180
local VIEW_LERP = 0.05

function playerInputWalkAutomatic(player)
	player.thrustX = 1
end

function playerInputInitial(player)
	playerInputWalkAutomatic(player)
end

function playerCleanupInitial(player)
	if player.x >= VIEW_LEFT_OFFSET - 6 then
		player.state = 'walking'
	end
end


function playerInputWalking(player)
	if btn( 0 ) then
		player.thrustX = player.thrustX - 1
	end
	if btn( 1 ) then
		player.thrustX = player.thrustX + 1
	end

	if btnp( 4 ) then
		if playerMayShoot() then
			playerEnterShootingState()
		elseif not playerHasAmmo() then
			world.flashAmmoStartTime = realNow()
			world.flashAmmoDuration = 0.15
			world.flashAmmoColor = YELLOW
			-- sfxm TODO
		end
	end

	if btnp( 5 ) then
		playerReload()
	end
end

local MIN_SHOOT_STATE_DURATION = 0.65

function playerIsShootingStillLocked()
	local time = playerDurationInState()
	return time ~= nil and time < MIN_SHOOT_STATE_DURATION
end

function playerInputShooting(player)

	if btn( 2 ) then
		player.aimAngleThrust = player.aimAngleThrust - 1
	end
	if btn( 3 ) then
		player.aimAngleThrust = player.aimAngleThrust + 1
	end

	if not btn( 4 ) and playerDurationInState() >= MIN_SHOOT_STATE_DURATION then
		playerShoot()
	end

	if btnp( 5 ) then		-- TODO minimum timeout
		playerCancelShootingState()
	end
end

function playerInputEnding(player)
	playerInputWalkAutomatic(player)
end


local PLAYER_DRAG = 0.35
local PLAYER_ACCEL_PER_THRUST = 0.75
local PLAYER_ANGLE_PER_THRUST = 0.75
local PLAYER_ANGLE_DRAG = 0.35
local PLAYER_ARM_OFFSET_X = 0
local PLAYER_ARM_OFFSET_Y = -20
local PLAYER_ARM_LENGTH = 15
local PLAYER_MAX_BULLET_THROW_LENGTH = 400

function playerShoulderPosition()
	return vec2:new( world.player.x + PLAYER_ARM_OFFSET_X, 0 + PLAYER_ARM_OFFSET_Y )
end

function playerArmNorm()
	local armNorm = vec2:new( 1.0, 0.0 )
	armNorm:rotate( degreesToRadians( world.player.aimAngle ))
	return armNorm
end

function playerGunTangent()
	local armNorm = playerArmNorm()
	armNorm:rotate( math.pi * 0.5 )
	return armNorm
end

function playerGunPos()
	local shoulderPosition = playerShoulderPosition()
	local armOffset = playerArmNorm() * PLAYER_ARM_LENGTH
	return shoulderPosition + armOffset
end

function playerFarBulletPos()
	local shoulderPosition = playerShoulderPosition()
	local farOffset = playerArmNorm() * PLAYER_MAX_BULLET_THROW_LENGTH
	return shoulderPosition + farOffset
end

local PLAYER_HEIGHT = 30
local PLAYER_WIDTH = 10
local MAX_PLAYER_HEALTH = 3


function playerBounds()
	return {
		left = world.player.x,
		top = -PLAYER_HEIGHT,
		right = world.player.x + PLAYER_WIDTH,
		bottom = 0
	}
end

function isCreatureOverlappingPlayer( creature )
	return rectsOverlap( creatureBounds( creature ), playerBounds() )
end

function playerDie()
	world.player.state = 'dead'
	world.player.stateStartTime = now()

	-- TODO
end

function playerTakeDamage( amount )
	if world.player.health > 0 then
		world.player.health = clamp( world.player.health - amount, 0, MAX_PLAYER_HEALTH )

		if world.player.health <= 0 then
			playerDie()
		end

		-- TODO sfxm()
		-- TODO flash
	end
end

function playerUpdateSimulation( player )

	player.velX = player.velX + player.thrustX * PLAYER_ACCEL_PER_THRUST
	player.velX = player.velX - ( player.velX * PLAYER_DRAG )
	player.x = player.x + player.velX

	if player.state ~= 'initial' then
		player.x = math.max( world.viewX + 6, player.x )
	end

	player.aimAngleVel = player.aimAngleVel + player.aimAngleThrust * PLAYER_ANGLE_PER_THRUST
	player.aimAngleVel = player.aimAngleVel - ( player.aimAngleVel * PLAYER_ANGLE_DRAG )
	player.aimAngle = player.aimAngle + player.aimAngleVel
	player.aimAngle = clamp( player.aimAngle, -90, 5 )
	
end

function isAmmoSpinning()
	return world.player.ammoSpinStartTime ~= nil
end

function playerInputDead( player )
	if now() > player.stateStartTime + 2.0 and ( btnp( 5 ) or btnp( 4 )) then
		createWorld()
	end
end

function playerUpdate( player )
	local stateInputFunctions = {
		initial  = playerInputInitial,
		walking  = playerInputWalking,
		shooting = playerInputShooting,
		ending   = playerInputEnding,
		dead     = playerInputDead,
	}

	local stateCleanupFunctions = {
		initial  = playerCleanupInitial,
	}

	local inputFunction = stateInputFunctions[ player.state ]

	player.thrustX = 0
	player.aimAngleThrust = 0
	inputFunction( player )

	playerUpdateSimulation( player )

	-- update ammo spin mechanics
	if world.player.ammoSpinStartTime ~= nil then
		local blurT = now() - world.player.ammoSpinStartTime
		if blurT >= world.player.ammoSpinDuration then
			world.player.ammoSpinStartTime = nil
			world.player.ammoSpinDuration = nil
		end
	end

	local cleanupFunction = stateCleanupFunctions[ player.state ]
	if cleanupFunction then
		cleanupFunction( player )
	end
end

local MAX_LOADED_BULLETS = 4

function playerReload()
	if not playerMayReload() then
		return
	end

	-- sfxm TODO
	world.player.numLoadedBullets = MAX_LOADED_BULLETS
	world.player.ammoSpinStartTime = now()
	world.player.ammoSpinDuration = 0.65
end

function playerDurationInState()
	if world.player.stateStartTime ~= nil then
		return now() - world.player.stateStartTime
	else
		return nil
	end
end

function playerEnterShootingState()
	if not playerMayShoot() then
		return
	end

	local player = world.player
	player.state = 'shooting'
	player.stateStartTime = now()

	-- sfxm TODO
end

function playerLeaveShootingState()
	world.player.state = 'walking'
	world.player.stateStartTime = now()
end

function creatureKill( creature )
	creature.state = 'dead'
	if creature.type.dead.sound ~= nil then
		sfxm( creature.type.dead.sound )
	end
end

function creatureTakeDamage( creature )
	if creature.state == 'active' or creature.state == 'attacking' or creature.state == 'fleeing' then
		creature.health = creature.health - 1
		if creature.health <= 0 then
			creatureKill( creature )
		end
	end
end

function checkingShootingCollision( player )
	local rayOrig = playerGunPos()
	local rayDir = playerArmNorm()

	for _, creature in ipairs( world.creatures ) do
		if creature.state == 'active' or creature.state == 'attacking' or creature.state == 'fleeing' then
			local bounds = creatureBounds( creature )
			if rectOverlapsRay( bounds, rayOrig, rayDir ) then
				creatureTakeDamage( creature )
			end
		end
	end
end

function playerActuallyShoot( player )
	
	world.player.numLoadedBullets = world.player.numLoadedBullets - 1

	world.player.firedStartTime = now()
	world.player.ammoSpinStartTime = now()
	world.player.ammoSpinDuration = 0.15

	world.flashAmmoStartTime = realNow()
	world.flashAmmoDuration = 0.65
	world.flashAmmoColor = 0xff404000

	checkingShootingCollision( player )

	-- sfxm TODO

	if world.player.numLoadedBullets == 0 then
		-- sfxm TODO
	end
end

function playerShoot()
	if world.player.state ~= 'shooting' then return end
	if playerMayShoot() then
		playerActuallyShoot( world.player )
	end
	playerLeaveShootingState()
end

function playerCancelShootingState()
	if world.player.state ~= 'shooting' then return end

	world.player.firedStartTime = nil
	playerLeaveShootingState()
end

function playerHasAmmo()
	return world.player.numLoadedBullets > 0
end

function playerMayShoot()
	return playerHasAmmo() and not isAmmoSpinning()
end

function playerMayReload()
	return not isAmmoSpinning() and world.player.numLoadedBullets < MAX_LOADED_BULLETS
end

function viewUpdate()
	-- TODO lerp
	world.viewX = lerp( world.viewX, math.max( world.viewX, world.player.x - VIEW_LEFT_OFFSET ), VIEW_LERP )
end

local CREATURE_TYPES = {
	wolf = {
		health = 2,
		size = { x = 64, y = 32 },
		spawn = {
			offset = vec2:new( 300, 0 ),
			radius = 0,
		},
		hint = {
			countMax = 2,
			offset = vec2:new( 0, -50 ),
			radius = 40,
			delay = { min = 2.0, max = 4.0 },
			sound = nil,
			anim = nil,
		},
		anims = {
			emerge = {},
			idle = {},
			move = {},
			attack = {},
		},
		emerging = {
			sound = nil,
			duration = 1.0,
		},
		active = {
			numStopsRange = { min = 2, max = 2 },
			movementScales = vec2:new( 50, 0 ),
			movementDuration = 1.5,
		},
		attacking = {
			sound = nil,
			movementDuration = 1.25,
			damage = 1,
		},
		dead = {
			sound = nil,
		}
	}
}

function createCreature( type, x )
	local creature = {
		type = type,
		state = 'dormant',
		pos = vec2:new( x, 0 ),
		numHints = randInt( 1, type.hint.countMax + 1 ),
		health = type.health or 1
	}

	creature.spawnPos = creature.pos + creature.type.spawn.offset + randVec( creature.type.spawn.radius )
	
	table.insert( world.creatures, creature )
	return creature
end

function randVec( radius )
	local v = vec2:new( radius, 0 )
	v:rotate( randInRange( 0, 2.0 * math.pi ))
	return v
end

function creatureStartHint( creature )
	creature.numHints = creature.numHints - 1

	if creature.type.hint.sound then
		sfxm( creature.type.hint.sound )
	end

	creature.anim = creature.type.hint.anim		-- nil fine

	creature.hintPos = creature.spawnPos + creature.type.hint.offset + randVec( creature.type.hint.radius )

	local delayRange = creature.type.hint.delay
	local delay = randInRange( delayRange.min, delayRange.max )
	creature.nextHintActionTime = now() + delay
end

function creatureUpdateDormant( creature )
	if world.player.x >= creature.pos.x then
		creature.state = 'hinting'
		creature.stateStartTime = now()
		creatureStartHint( creature )
	end
end

function creatureEmerge( creature )
	creature.state = 'emerging'
	creature.stateStartTime = now()

	creature.pos = creature.spawnPos
	creature.anim = creature.type.anims.emerging

	if creature.type.emerging.sound then
		sfxm( creature.type.emerging.sound )
	end
end

function creatureUpdateHinting( creature )
	if world.player.x >= creature.spawnPos.x - 200 then
		creatureEmerge( creature )
	else
		if now() >= creature.nextHintActionTime then
			if creature.numHints > 0 then
				-- hint again
				creatureStartHint( creature )
			else
				creatureEmerge( creature )
			end
		end
	end
end

function creatureUpdateEmerging( creature )
	if now() - creature.stateStartTime >= creature.type.emerging.duration then
		creature.state = 'active'
		creature.stateStartTime = now()
		creature.numStops = math.min( 1, randInt( creature.type.active.numStopsRange.min, creature.type.active.numStopsRange.max + 1 ))
		creatureMoveToNextStop( creature )
	end
end

function creatureMoveToNextStop( creature )
	local r = randVec( 1.0 )
	creature.stopLocation = creature.pos + r * creature.type.active.movementScales
	creature.startMovementTime = now()
	creature.movementDuration = creature.type.active.movementDuration

	creature.numStops = creature.numStops - 1
end

function creatureStartAttacking( creature )
	creature.state = 'attacking'
	creature.stateStartTime = now()

	creature.stopLocation = nil
	if creature.type.attacking.pickDestination ~= nil then
		creature.stopLocation = creature.type.attacking.pickDestination( creature )
	else
		creature.stopLocation = vec2:new( world.player.x - 50, 0 )
	end

	creature.startMovementTime = now()
	creature.movementDuration = creature.type.attacking.movementDuration
end

function creatureMoveTowardStop( creature )
	if creature.stopLocation == nil then return end
	creature.pos = lerp( creature.pos, creature.stopLocation, 0.05 )	-- TODO time-based, easing, spline
end

function creatureUpdateActive( creature )
	if creature.startMovementTime ~= nil and now() >= creature.startMovementTime + creature.movementDuration then
		if creature.numStops > 0 then
			creatureMoveToNextStop( creature )
		else
			creatureStartAttacking( creature )
		end
	else
		creatureMoveTowardStop( creature )
	end
end

function creatureUpdateAttacking( creature )
	creatureMoveTowardStop( creature )

	-- COLLISION
	if isCreatureOverlappingPlayer( creature ) then
		playerTakeDamage( creature.type.attacking.damage )
	end

	if creature.startMovementTime ~= nil and now() >= creature.startMovementTime + creature.movementDuration then
		creature.state = 'fleeing'
		creature.stopLocation = nil
	end
end

function creatureUpdateFleeing( creature )
	creature.pos.x = creature.pos.x - 1.5
	if creature.pos.x <= world.viewX - creature.type.size.x - 16 then
		tableRemoveValue( world.creatures, creature )
	end
end

function creatureBounds( creature )
	return {
		left = creature.pos.x,
		top = creature.pos.y - creature.type.size.y,
		right = creature.pos.x + creature.type.size.x,
		bottom = creature.pos.y
	}
end

function creatureDraw( creature )
	local stateFunctions = {
		dormant = nil,
		hinting = function()
			rectfill( creature.hintPos.x, creature.hintPos.y, creature.hintPos.x + 10, creature.hintPos.y + 10, 0xFFFFFF00 )
		end,
		emerging = function()
			local bounds = creatureBounds( creature )
			rectfill( bounds.left, bounds.top, bounds.right, bounds.bottom, 0xFFFF00FF )
		end,
		active =  function()
			local bounds = creatureBounds( creature )
			rectfill( bounds.left, bounds.top, bounds.right, bounds.bottom, 0xFFFF0000 )

			rectfill( creature.stopLocation.x, creature.stopLocation.y, creature.stopLocation.x + 4, creature.stopLocation.y + 4, 0xFF0000FF )
		end,
		attacking = function()
			local bounds = creatureBounds( creature )
			rectfill( bounds.left, bounds.top, bounds.right, bounds.bottom, 0xFF800000 )

			rectfill( creature.stopLocation.x, creature.stopLocation.y, creature.stopLocation.x + 4, creature.stopLocation.y + 4, 0xFF00FFFF )
		end,
		fleeing = function()
			local bounds = creatureBounds( creature )
			rectfill( bounds.left, bounds.top, bounds.right, bounds.bottom, 0x80808000 )
		end,
		dead = function()
			local bounds = creatureBounds( creature )
			rectfill( bounds.left, bounds.top, bounds.right, bounds.bottom, 0x80000000 )
		end
	}

	local func = stateFunctions[ creature.state ]
	if func ~= nil then
		func( creature )
	end
end

function creatureUpdateDead( creature )
	creature.pos.y = math.min( 0, creature.pos.y + 1 )
end

function creatureUpdate( creature )
	local stateFunctions = {
		dormant = creatureUpdateDormant,
		hinting = creatureUpdateHinting,
		emerging = creatureUpdateEmerging,
		active =  creatureUpdateActive,
		attacking = creatureUpdateAttacking,
		fleeing = creatureUpdateFleeing,
		dead = creatureUpdateDead
	}

	local func = stateFunctions[ creature.state ]
	if func ~= nil then
		func( creature )
	end
end

function updateCreatures()
	for _, creature in ipairs( world.creatures ) do
		creatureUpdate( creature )
	end
end

function drawCreatures()
	for _, creature in ipairs( world.creatures ) do
		creatureDraw( creature )
	end
end

function createWorld()
	world = {
		viewX = 0,
		creatures = {},
		player = {
			state = 'initial',
			x = -64,
			velX = 0,
			thrustX = 0,
			aimAngle = 0,
			aimAngleVel = 0,
			aimAngleThrust = 0,
			health = MAX_PLAYER_HEALTH - 1,		-- TODO
			numLoadedBullets = MAX_LOADED_BULLETS - 1,	-- TODO
		}
	}

	for i = 0, 12 do
		createCreature( CREATURE_TYPES.wolf, 100 + 300 * i )
	end
end

createWorld()

-- UPDATING!!!

function update()
	realTicks = realTicks + 1
	ticks = ticks + 1

	playerUpdate( world.player )
	updateCreatures()
	viewUpdate()
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

function playerDraw( player )
	rectfill( player.x, -PLAYER_HEIGHT, player.x + PLAYER_WIDTH, 0 )
end

function viewBounds()
	return {
		left = world.viewX,
		top = -GROUND_VIEW_OFFSET_Y,
		right = world.viewX + screen_wid(),
		bottom = -GROUND_VIEW_OFFSET_Y + screen_hgt(),
	}
end

local PIXELS_PER_FLOOR_TILE = PIXELS_PER_TILE * 8
function drawFloor()
	local worldSpaceViewBounds = viewBounds()
	
	-- quantize
	local tileLeft = math.floor( worldSpaceViewBounds.left // PIXELS_PER_FLOOR_TILE )
	local tileRigt = math.floor( worldSpaceViewBounds.right // PIXELS_PER_FLOOR_TILE )

	local floorSpriteUL = spriteIndex( 0, 16 )
	for x = tileLeft, tileRigt do
		spr( floorSpriteUL, x * PIXELS_PER_FLOOR_TILE, -36, 8, 8 )
	end
end

function drawRipplingLine( time, timeLengthScale, a, b, color, thickness, rippleFunc )
	time = time or realNow()
	timeLengthScale = timeLengthScale == nil and 10.0 or timeLengthScale

	rippleFunc = rippleFunc or function( t )
		local mt = t * math.pi * 2.0
		return math.sin( mt ) * math.sin( mt * 3 ) * math.sin( mt * 0.3 ) * math.sin( mt * 7 ) * 0.4
	end

	local delta = b - a
	local norm = delta:normal()
	local len = delta:length()


	function drawSegment( s, t )
		local u = a + norm * ( s * len )
		local v = a + norm * ( t * len )
		line( u.x, u.y, v.x, v.y, color, thickness )
	end

	local drawing = true
	local lastT = nil
	local t = 0.0
	while t < 1.0 do
		if drawing and lastT ~= nil then
			drawSegment( lastT, t )
		end

		local segmentLength = math.max( 0.05, math.abs( rippleFunc(( time + t ) * timeLengthScale )))

		lastT = t
		t = clamp( lastT + segmentLength, 0.0, 1.0 )
		drawing = not drawing
	end
end

function drawInWorldUI()

	function drawShootingGunLine()
		local gun = playerGunPos()
		local far = playerFarBulletPos()
		drawRipplingLine( 23 + realNow() * 0.15, 0.1, gun, far, colorLerp( YELLOW_ORANGE, 0, 0.75 ), 1 )
		drawRipplingLine( 10 + realNow() * 0.19, 0.13, gun, far, colorLerp( YELLOW, 0, 0.25 ), 0.5 )
	end

	function drawWalkingUI()
		if world.player.firedStartTime ~= nil then
			local thinColor = flashOnce( 1.2, WHITE, 0x00000000, playerDurationInState() )
			local thickColor = flashOnce( 0.65, 0xFFcccccc, 0x00000000, playerDurationInState() )
			local gun = playerGunPos()
			local far = playerFarBulletPos()
			line( gun.x, gun.y, far.x, far.y, thickColor, 2 )
			line( gun.x, gun.y, far.x, far.y, thinColor, 0.5 )
		end
	end

	function drawShootingUI()
		drawShootingGunLine()
	end

	local stateFunctions = {
		walking = drawWalkingUI,
		shooting = drawShootingUI,
	}

	local func = stateFunctions[ world.player.state ]
	if func ~= nil then func() end
end

function drawHUD()
	function drawControlHintArea()
		local ARROW_HINT_X = screen_wid() - 16 * 6
		local BUTTONS_TOP_Y = screen_hgt() - 64
		local BUTTON_LABELS_TOP_Y = BUTTONS_TOP_Y + 34
		local BUTTON_Z_HINT_X = 16 * 6
		local BUTTON_X_HINT_X = 16 * 12

		function drawAmmoDisplay()
			local ammoAdditive = world.flashAmmoStartTime ~= nil and flashOnce( world.flashAmmoDuration, world.flashAmmoColor, 0, realNow() - world.flashAmmoStartTime ) or 0

			local left = 8
			local top = 8

			local ammoSpinRads = 0;

			if world.player.ammoSpinStartTime ~= nil then
				local AMMO_SPIN_FRAMES_PER_SECOND = 16

				local ammoSpinT = now() - world.player.ammoSpinStartTime

				local blurFrames = {
					spriteIndex( 12, 20 ),
					spriteIndex( 16, 20 ),
					spriteIndex( 20, 20 ),
				}

				local frameIndex = math.floor( wrap( ammoSpinT * AMMO_SPIN_FRAMES_PER_SECOND, 0, ( #blurFrames )))
				local frame = blurFrames[ frameIndex + 1 ]

				local ammoSpinDegrees = frameIndex * -30.0 + 90 - 15
				ammoSpinRads = degreesToRadians( ammoSpinDegrees )

				spr( frame, left, top, 4, 4, false, false, WHITE, ammoAdditive )
			else
				spr( spriteIndex( 9, 28 ), left, top, 4, 4, false, false, WHITE, ammoAdditive )
			end
		
			local centerX = left + PIXELS_PER_TILE
			local centerY = top + PIXELS_PER_TILE
			local RADIANS_PER_BULLET = math.pi * 2 / ( MAX_LOADED_BULLETS )
			local SPOKE_LENGTH = 14

			for i = 0, world.player.numLoadedBullets - 1 do
				local spokeX = -math.sin( ammoSpinRads + i * RADIANS_PER_BULLET ) * SPOKE_LENGTH
				local spokeY = -math.cos( ammoSpinRads + i * RADIANS_PER_BULLET ) * SPOKE_LENGTH
				spr( spriteIndex( 9, 26 ), centerX + spokeX, centerY + spokeY, 2, 2, false, false, WHITE, ammoAdditive )
			end
		end

		function drawHealthDisplay()
			local right = screen_wid() - 48
			for i = 0, MAX_PLAYER_HEALTH - 1 do
				local spriteColor = i < world.player.health and 0xFF000000 or 0x80808080
				spr( spriteIndex( 9, 24 ), right - 32 * i, 8, 2, 2, false, false, WHITE, spriteColor )
			end
		end

		local playerStateDrawFunctions = {
			initial = function()
			end,
			walking = function()
				drawAmmoDisplay()
				drawHealthDisplay()
				local shootColor = playerMayShoot() and WHITE or 0xFF808080
				local reloadColor = playerMayReload() and WHITE or 0xFF808080

				spr( spriteIndex( 0, 29 ), 8, screen_hgt() - 40, 5, 1 ) -- MAIN LABEL
				spr( spriteIndex( 11, 24 ), ARROW_HINT_X, screen_hgt() - 56, 4, 2 ) -- ARROW KEYS
				spr( spriteIndex( 5, 24 ), BUTTON_Z_HINT_X, BUTTONS_TOP_Y, 2, 4, false, false, shootColor ) -- BUTTON Z
				spr( spriteIndex( 8, 20 ), BUTTON_Z_HINT_X + 32, BUTTON_LABELS_TOP_Y, 4, 1, false, false, shootColor ) -- BUTTON Z LABEL
				spr( spriteIndex( 7, 24 ), BUTTON_X_HINT_X, BUTTONS_TOP_Y, 2, 4, false, false, reloadColor ) -- BUTTON X
				spr( spriteIndex( 8, 23 ), BUTTON_X_HINT_X + 32, BUTTON_LABELS_TOP_Y, 4, 1, false, false, reloadColor ) -- BUTTON X LABEL
			end,
			shooting = function()
				-- Did the user release the shoot button too fast?
				local shootReleaseDelinquent = ( not btn( 4 )) and playerIsShootingStillLocked()
				local shootAdditive = shootReleaseDelinquent and flash( 4, WHITE, 0, playerDurationInState() ) or 0

				drawAmmoDisplay()
				drawHealthDisplay()
				spr( spriteIndex( 0, 30 ), 8, screen_hgt() - 40, 5, 1 ) -- MAIN LABEL
				spr( spriteIndex( 15, 24 ), ARROW_HINT_X, screen_hgt() - 56, 4, 3 ) -- ARROW KEYS
				spr( spriteIndex( 5, 28 ), BUTTON_Z_HINT_X, BUTTONS_TOP_Y, 2, 4, false, false, WHITE, shootAdditive ) -- BUTTON Z
				spr( spriteIndex( 8, 21 ), BUTTON_Z_HINT_X + 32, BUTTON_LABELS_TOP_Y, 4, 1, false, false, WHITE, shootAdditive ) -- BUTTON Z LABEL
				spr( spriteIndex( 7, 24 ), BUTTON_X_HINT_X, BUTTONS_TOP_Y, 2, 4 ) -- BUTTON X
				spr( spriteIndex( 8, 22 ), BUTTON_X_HINT_X + 32, BUTTON_LABELS_TOP_Y, 4, 1 ) -- BUTTON X LABEL
			end,
			ending = function()
				-- TODO
			end,
			dead = function()
				-- TODO
			end
		}
		playerStateDrawFunctions[ world.player.state ]()
	end

	drawControlHintArea()
end

function draw()
	cls( 0xff000040 )

	-- Draw world
	camera( world.viewX, -GROUND_VIEW_OFFSET_Y )
	drawFloor()
	playerDraw( world.player )
	drawCreatures()

	-- Draw UI
	drawInWorldUI()

	camera( 0, 0 )
	drawHUD()

	-- DEBUG
	camera( -8, 0 )
	drawDebug()
end
