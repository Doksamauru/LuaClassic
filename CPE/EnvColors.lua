local ec = {
	global = true
}

EC_SKY     = 0
EC_CLOUD   = 1
EC_FOG     = 2
EC_AMBIENT = 3
EC_DIFFUSE = 4

time_presets = {
	dawn = {
		[EC_DIFFUSE] = {65,50,50},
		[EC_AMBIENT] = {40,50,40},
		[EC_FOG] = {60,47,40},
		[EC_CLOUD] = {60,47,40},
		[EC_SKY] = {91,43,18},
	},
	night = {
		[EC_DIFFUSE] = {85,85,85},
		[EC_AMBIENT] = {40,40,40},
		[EC_FOG] = {40,40,40},
		[EC_CLOUD] = {40,40,40},
		[EC_SKY] = {40,40,40}
	},
	day = {
		[EC_DIFFUSE] = {255,255,255},
		[EC_AMBIENT] = {255,255,255},
		[EC_FOG] = {240,240,240},
		[EC_CLOUD] = {253,253,253},
		[EC_SKY] = {153,204,255}
	}
}

local function updateEnvColorsFor(player, typ, r, g, b)
	if player:isSupported('EnvColors')then
		player:sendPacket(false, 0x19, typ, r or-1, g or-1, b or-1)
	end
end

local function getClrs(world)
	world = getWorld(world)
	local clr = world.data.colors
	if not clr then
		clr = {}
		world.data.colors = clr
	end
	return clr
end

function ec:load()
	registerSvPacket(0x19,'>Bbhhh')
end

function ec:setFor(player, typ, r, g, b)
	updateEnvColorsFor(player, typ, r, g, b)
end

function ec:prePlayerSpawn(player)
	local colors = getClrs(player.worldName)
	for i=0,4 do
		local typ = tostring(i)
		local color = colors[typ]
		if color then
			updateEnvColorsFor(player, tonumber(typ), unpack(color))
		else
			updateEnvColorsFor(player, tonumber(typ))
		end
	end
end

function ec:set(world, typ, r, g, b)
	getClrs(world)[tostring(typ)] = {r,g,b}
	playersForEach(function(player)
		if player:isInWorld(world)then
			updateEnvColorsFor(player, typ, r, g, b)
		end
	end)
end

return ec
