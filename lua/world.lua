local function gBufSize(x,y,z)
	return x*y*z+4
end

local function packTo(file, fmt, ...)
	local data = struct.pack(fmt, ...)
	return file:write(data)
end

local function unpackFrom(file, fmt)
	local sz = struct.size(fmt)
	local data = file:read(sz)
	return struct.unpack(fmt, data)
end

local world_mt = {
	__tostring = function(self)
		return self:getName()
	end,

	createWorld = function(self,data)
		local dim = data.dimensions
		local sz = gBufSize(unpack(dim))
		if sz>1533634564 then
			log.error(WORLD_TOOBIGDIM)
			return false, WORLD_TOOBIGDIM
		end
		data.spawnpoint = data.spawnpoint or{0,0,0}
		data.spawnpointeye = data.spawnpointeye or{0,0}
		self.size = sz
		self.ldata = ffi.new('uchar[?]', sz)
		local szint = ffi.new('int[1]', bswap(sz-4))
		ffi.copy(self.ldata, szint, 4)
		self.data = data
		return true
	end,
	save = function(self)
		if not self.ldata then return true end
		local pt = 'worlds/'+self.wname+'.map'
		local wh = assert(io.open(pt, 'wb'))
		wh:write('LCW\0')
		for k, v in pairs(self.data)do
			if k == 'dimensions'then
				packTo(wh, '>bHHH', 0, unpack(v))
			elseif k == 'spawnpoint'then
				packTo(wh, '>bfff', 1, unpack(v))
			elseif k == 'spawnpointeye'then
				packTo(wh, '>bff', 2, unpack(v))
			elseif k == 'isNether'then
				packTo(wh, '>bb', 3, (v and 1)or 0)
			elseif k == 'colors'then
				for id, c in pairs(v)do
					packTo(wh, 'bbbbb', 4, id, c.r, c.g, c.b)
				end
			elseif k == 'map_aspects'then
				for id, val in pairs(v)do
					packTo(wh, '>bbI', 5, id, val)
				end
			elseif k == 'weather'then
				packTo(wh, '>bb', 6, v)
			elseif k == 'readonly'then
				packTo(wh, '>bb', 7, (v and 1)or 0)
			elseif k == 'portals'then
				for id, val in pairs(v)do
					local p1x, p1y, p1z = unpack(val.pt1)
					local p2x, p2y, p2z = unpack(val.pt2)
					packTo(wh, '>bHHHHHHH', 8, p1x, p1y, p1z,
					p2x, p2y, p2z, #val.tpTo)
					wh:write(val.tpTo)
				end
			elseif k == 'texPack'then
				if #v > 0 and #v < 65 then
					wh:write(string.char(9, #v))
					wh:write(v)
				else
					log.warn(WORLD_TPSTRLEN)
				end
			elseif k == 'wscripts'then
				for name, script in pairs(v)do
					local slen = math.min(#script.body, 65535)
					local nlen = math.min(#name, 255)
					if slen > 0 and nlen > 0 then
						packTo(wh, '>bBH', 10, nlen, slen)
						wh:write(name)
						wh:write(script.body)
					else
						log.warn(WORLD_SCRSVERR)
					end
				end
			else
				log.warn(WORLD_MAPOPT%k)
			end
		end
		wh:write('\255')
		local gStatus, gErr = gz.compress(self.ldata, self.size, 4, function(out, stream)
			local chunksz = 1024-stream.avail_out
			C.fwrite(out, 1, chunksz, wh)
			if C.ferror(wh)~=0 then
				log.error(WORLD_WRITEFAIL)
				gz.defEnd(stream)
			end
		end)
		wh:close()
		return gStatus, gErr
	end,
	unload = function(self)
		if self.players>0 or self.unloadLocked then return false end
		self:save()
		self.ldata = nil
		collectgarbage()
		return true
	end,
	triggerLoad = function(self)
		if not self.ldata then
			local wh = assert(io.open(self:getPath(), 'rb'))
			if self:readLevelInfo(wh)then
				self:readGZIPData(wh)
				wh:close()
				return true
			else
				return false
			end
		end
		return false
	end,

	getDimensions = function(self)
		return unpack(self.data.dimensions)
	end,
	getOffset = function(self,x,y,z)
		if not self.ldata then return false end
		local dx, dy, dz = self:getDimensions()
		local offset = math.floor(z*dx+y*(dx*dz)+x+4)
		local fs = ffi.sizeof(self.ldata)
		offset = math.max(math.min(offset, fs), 4)
		return offset
	end,
	getBlock = function(self,x,y,z)
		if not self.ldata then return false end
		return self.ldata[self:getOffset(x,y,z)]
	end,
	getAddr = function(self)
		return getAddr(self.ldata)
	end,
	getSize = function(self)
		return self.size
	end,
	getPath = function(self)
		local name = self:getName()
		return 'worlds/'+name+'.map'
	end,
	getName = function(self)
		return self.wname
	end,
	getData = function(self,key)
		return self.data[key]
	end,

	setBlock = function(self,x,y,z,id)
		if not self.ldata then return false end
		if self:isInReadOnly()then return false end
		local offset = self:getOffset(x,y,z)
		self.ldata[offset] = id
	end,
	setSpawn = function(self,x,y,z,ay,ap)
		if not x or not y or not z then return false end
		ay, ap = ay or 0, ap or 0
		local sp = self:getData('spawnpoint')
		local eye = self:getData('spawnpointeye')

		sp[1] = x sp[2] = y sp[3] = z
		eye[1] = ay eye[2] = ap
		return true
	end,
	setName = function(self,name)
		if type(name)~='string' then return false end
		self.wname = name
		return true
	end,
	setData = function(self,key,val)
		if not self.data then return false end
		self.data[key] = val
		return val
	end,
	setDataInv = function(self,key)
		return self:setData(key, not self:getData(key))
	end,
	setReadOnly = function(self,b)
		self:setData('readonly', b)
		return true
	end,
	toggleReadOnly = function(self)
		self:setDataInv('readonly')
		return self.data.readonly
	end,

	isInReadOnly = function(self)
		return self.data.readonly
	end,

	fillBlocks = function(self,x1,y1,z1,x2,y2,z2,id)
		if self:isInReadOnly()then return false end
		x1,y1,z1,x2,y2,z2 = makeNormalCube(x1,y1,z1,x2,y2,z2)
		local buf = ''
		for x=x2,x1-1 do
			for y=y2,y1-1 do
				for z=z2,z1-1 do
					self:setBlock(x,y,z,id)
					buf = buf .. generatePacket(0x06,x,y,z,id)
				end
			end
		end
		playersForEach(function(player)
			if player:isInWorld(self)then
				player:sendNetMesg(buf)
			end
		end)
	end,

	readGZIPData = function(self, wh)
		local ptr = self.ldata
		return gz.decompress(wh, function(out,stream)
			local chunksz = 1024-stream.avail_out
			ffi.copy(ptr, out, chunksz)
			ptr = ptr + chunksz
		end)
	end,
	readLevelInfo = function(self, wh)
		if wh:read(4) == 'LCW\0'then
			self.data = {}
			while true do
				local id = wh:read(1)

				if id == '\0'then
					local dx, dy, dz = unpackFrom(wh, '>HHH')
					local sz = gBufSize(dx, dy, dz)
					self.data.dimensions = {dx, dy, dz}
					self.ldata = ffi.new('char[?]', sz)
					self.size = sz
				elseif id == '\1'then
					local sx, sy, sz = unpackFrom(wh, '>fff')
					self.data.spawnpoint = {sx, sy, sz}
				elseif id == '\2'then
					local ay, ap = unpackFrom(wh, '>ff')
					self.data.spawnpointeye = {ay, ap}
				elseif id == '\3'then
					self.data.isNether = wh:read(1)=='\1'
				elseif id == '\4'then
					local ct, r, g, b = unpackFrom(wh, 'BBBB')
					self.data.colors = self.data.colors or{}
					self.data.colors[ct] = newColor(r,g,b)
				elseif id == '\5'then
					local ct, val = unpackFrom(wh, '>bI')
					self.data.map_aspects = self.data.map_aspects or{}
					self.data.map_aspects[ct] = val
				elseif id == '\6'then
					self.data.weather = wh:read(1):byte()
				elseif id == '\7'then
					self.data.readonly = wh:read(1)=='\1'
				elseif id == '\8'then
					self.data.portals = self.data.portals or{}
					local p1x, p1y, p1z,
					p2x, p2y, p2z, strsz = unpackFrom(wh, '>HHHHHHH')
					table.insert(self.data.portals,{
						pt1 = {p1x, p1y, p1z},
						pt2 = {p2x, p2y, p2z},
						tpTo = wh:read(strsz)
					})
				elseif id == '\9'then
					local len = wh:read(1):byte()
					self.data.texPack = wh:read(len)
				elseif id == '\10'then
					local nl, sl = unpackFrom(wh, '>BH')
					self.data.wscripts = self.data.wscripts or{}
					local name = wh:read(nl)
					local sl = wh:read(sl)
					local sctbl = {
						body = sl
					}
					self.data.wscripts[name] = sctbl
					self:executeScript(name)
				elseif id == '\255'then
					break
				else
					io.write(WORLD_CORRUPT)
					return false
				end
			end
			return true
		end
		return false
	end,

	addScript = function(self, name, body)
		if type(name)~='string' or #name>255 then return false end
		if type(body)~='string' or #body>65535 then return false end
		self.data.wscripts = self.data.wscripts or{}
		self.data.wscripts[name] = {
			body = body
		}
		return true
	end,
	addScriptFile = function(self, name, filename)
		if type(name)~='string' or #name>255 then return false end
		if type(filename)~='string' then return false end
		local f = io.open(filename, 'rb')
		if not f then return false end
		local body = f:read(65535)
		f:close()
		self.data.wscripts = self.data.wscripts or{}
		self.data.wscripts[name] = {
			body = body
		}
		return true
	end,
	removeScript = function(self, name)
		if not self.data.wscripts then return false end
		self.data.wscripts[name] = nil
		return true
	end,
	executeScript = function(self, name)
		if not self.data.wscripts then return false end
		local sctbl = self.data.wscripts[name]
		if not sctbl then return false end

		if config:get('world-scripts', false)then
			local scret, succ
			local chunk, err = loadstring(sctbl.body, name)
			if not chunk then
				sctbl.succ = false
				sctbl.ret = err
			else
				succ, scret = pcall(chunk, self)
			end
			sctbl.ret = scret
			sctbl.succ = succ
			return true
		end
		return false
	end,
	scriptStatus = function(self, name)
		if not self.data.wscripts then return false end
		local sc = self.data.wscripts[name]
		if not sc then return false end
		return sc.succ, sc.ret
	end,

	isWorld = true,
	players = 0
}
world_mt.__index = world_mt

function getWorldMT()
	return world_mt
end

function getWorld(w)
	local t = type(w)
	if t == 'table'then
		if w.isWorld then
			return w
		elseif w.isPlayer then
			return worlds[w.worldName]
		end
	elseif t == 'string'then
		w = w:lower()
		return worlds[w]
	end
end

function loadWorld(wname)
	if worlds[wname]then return true end
	local lvlh = io.open('worlds/'+wname+'.map', 'rb')
	if not lvlh then return false end
	local status, world = pcall(newWorld,lvlh,wname)
	if status then
		worlds[wname] = world
		return true
	end
	return false, world
end

function unloadWorld(wname)
	local world = getWorld(wname)
	if world == worlds['default']then
		return false
	end

	if world then
		playersForEach(function(player)
			if player:isInWorld(wname)then
				player:changeWorld('default')
			end
		end)
		world:save()
		world.buf = nil
		worlds[wname] = nil
		collectgarbage()
		return true
	end
	return false
end

function createWorld(wname, dims, gen, seed)
	if world[wname]then return false end
	local data = {dimensions=dims}
	local tmpWorld = newWorld()
	if tmpWorld:createWorld(data)then
		tmpWorld:setName(wname)
		worlds[wname] = tmpWorld
		return regenerateWorld(wname, gen, seed)
	else
		return false
	end
end

function openGenerator(name)
	local chunk, err = loadfile('generators/'+name+'.lua')
	if chunk then
		local status, ret = pcall(chunk)
		return status and ret, ret
	end
	return false, err
end

function regenerateWorld(world, gentype, seed)
	world = getWorld(world)
	if not world then return false, WORLD_NE end
	if world:isInReadOnly()then return false, WORLD_RO end
	local gen, err = openGenerator(gentype)
	if not gen then
		return false, err
	else
		if type(gen)=='function'then
			world.data.colors = nil
			world.data.map_aspects = nil
			world.data.texPack = nil
			playersForEach(function(player)
				if player:isInWorld(world)then
					player:despawn()
				end
			end)
			ffi.fill(world.ldata+4, world.size)
			seed = seed or CTIME
			local t = socket.gettime()
			local succ, err = pcall(gen, world, seed)
			if not succ then
				log.error(err)
				return false, err
			end
			local e = socket.gettime()
			playersForEach(function(player)
				if player:isInWorld(world)then
					player.handshakeStage2 = true
				end
			end)
			return true, e-t
		end
	end
	return false, IE_UE
end

function newWorld(wh, wn)
	local world =
	setmetatable({data={}}, world_mt)

	if wh and wn then
		if world:readLevelInfo(wh)then
			world:setName(wn)
			if not world:readGZIPData(wh)then
				wh:close()
				return false
			end
			wh:close()
		else
			return false
		end
	end

	return world
end
