io.stdout:setvbuf('no')
require('lng')

do
	local function vermismatch()
		print(CON_LJVER)
		os.exit(1)
	end

	if not (jit and jit.version)then
		vermismatch()
	elseif jit.version_num == 20000 then
		local ver = jit.version
		local beta = ver:match('.+%-beta(%d+)')
		beta = tonumber(beta)
		if beta and beta < 11 then
			vermismatch()
		end
	elseif jit.version_num < 20000 then
		vermismatch()
	end
end

if os.getenv('DEBUG')then
	local path = os.getenv('DEBUG')
	path = path or'../mobdebug.lua'
	loadfile(path)().start()
end

require('utils')
require('commands')
START_TIME = gettime()

function onPlayerAuth(player, name, key)
	player:setUID(key)
	if not player:setName(name)then
		return false, KICK_NAMETAKEN
	end
	player:saveRead()
	return true
end

function prePlayerFirstSpawn(player)
	local wMsg = config:get('welcomeMessage')
	if wMsg and #wMsg > 0 then
		for line in wMsg:gmatch("[^\r\n]+") do
			if #line > 0 then
	    	player:sendMessage(line)
			end
		end
	end
	local msg = printf(MESG_CONN, player)
	newChatMessage('&e' .. msg)
end

function onPlayerDestroy(player)
	if not player.silentKick then
		local msg = printf(MESG_DISCONN, player, player:getLeaveReason())
		newChatMessage('&e' .. msg)
	end

	if player:isHandshaked()then
		player:saveWrite()
	end
end

function onPlayerChatMessage(player, message)
	local starts = message:sub(1, 1)
	if not message:startsWith('#', '>', '/')then
		message = message:gsub('%%(%x)', '&%1')
	end
	local prefix = ''
	if #player.prefix > 0 then
		prefix = ('[%s&f] '):format(player.prefix)
	end
	if starts == '!'then message = message:sub(2)end
	local formattedMessage = ('%s&3%s&f: %s'):format(prefix, player, message)
	log.chat(formattedMessage)

	if starts == '#'then
		if player:checkPermission('server.luaexec')then
			local code = message:sub(2)
			code = code:gsub('^=', 'return ')
			local chunk, err = loadstring(code)
			if chunk then
				world = getWorld(player)
				self = player
				local ret = {pcall(chunk)}
				self = nil
				world = nil
				for i = 2, #ret do
					ret[i] = tostring(ret[i])
				end
				if ret[1]then
					if #ret > 1 then
						return (MESG_EXECRET):format(table.concat(ret, ', ', 2))
					else
						return MESG_EXEC
					end
				else
					return (MESG_ERROR):format(ret[2])
				end
			else
				return (MESG_ERROR):format(err)
			end
		else
			return err
		end
	elseif starts == '/'then
		local args = message:split(' ')
		if #args > 0 then
			local cmd = table.remove(args, 1):sub(2)
			cmd = cmd:lower()
			local cmf = commands[cmd]
			if cmf then
				if player:checkPermission('commands.' .. cmd)then
					local succ, rtval = pcall(cmf, false, player, args)
					if not succ then
						player:sendMessage((IE_MSG):format(IE_LE))
						log.error('Command', cmd, 'got error:', rtval)
						return
					end
					if rtval == false then
						local str = _G['CU_' .. cmd:upper()]
						if str then
							player:sendMessage((CON_USE):format(str))
						end
					else
						if rtval == nil then return end
						player:sendMessage(rtval)
					end
				end
			else
				player:sendMessage(MESG_UNKNOWNCMD)
			end
		end
	elseif starts == '>'then
		local wname = message:sub(2)
		wname = wname:lower()
		local succ, msg = player:changeWorld(wname)
		if not succ then
			if msg == 0 then
				player:sendMessage(WORLD_NE)
			end
		end
	elseif starts == '@'then
		local name, message = message:match('^@(.-)%s(.+)')
		if name and #name > 0 then
			local target = getPlayerByName(name)
			if target == player then
				player:sendMessage(CMD_WHISPERSELF)
				return
			end
			if target then
				target:sendMessage((CMD_WHISPER):format(player, message))
			else
				player:sendMessage(MESG_PLAYERNF)
			end
		end
	elseif starts == '!'then -- Message to global chat
		newChatMessage('&2G&f ' .. formattedMessage)
	else -- Message to local chat
		newLocalChatMessage(player, formattedMessage)
	end
end

local httpPattern = '^get%s+(.+)%s+http/%d%.%d$'

function wsDoHandshake()
	for cl, data in pairs(wsHandshake)do
		local status = checkSock(cl)

		if status == 'closed'then
			wsHandshake[cl] = nil
		end

		if data.state == 'testws'then
			local hdr = receiveString(cl, 3, MSG_PEEK)
			if hdr then
				if hdr:lower() == 'get'then
					data.state = 'initial'
				else
					wsHandshake[cl] = nil
					createPlayer(cl, data.ip, false)
				end
			end
		end

		if data.state == 'initial'then
			local req = receiveLine(cl)
			if req then
				req = req:lower()
				if req:find(httpPattern)then
					data.state = 'headers'
				end
			end
			if data.state ~= 'headers'then
				data.state = 'badrequest'
				data.emsg = 'Not a GET request'
			end
		end

		if data.state == 'headers'then
			local ln = receiveLine(cl)
			if ln == ''then
				data.state = 'genresp'
			elseif ln then
				local k, v = ln:match('(.+)%s*:%s*(.+)')
				if k then
					k = k:lower()
					data.headers[k] = v
				else
					data.state = 'badrequest'
					data.emsg = 'Invalid header'
				end
			end
		end

		if data.state == 'genresp'then
			local hdr = data.headers
			local wskey = hdr['sec-websocket-key']
			local wsver = hdr['sec-websocket-version']
			local conn = hdr['connection']
			local upgrd = hdr['upgrade']

			if upgrd and wskey and conn and
			upgrd:lower() == 'websocket'and
			conn:lower():find('upgrade')and
			tonumber(wsver) == 13 then
				wskey = wskey .. WSGUID
				wskey = b64enc(sha1(wskey))
				local response =
				('HTTP/1.1 101 Switching Protocols\r\n' ..
				'Upgrade: websocket\r\nConnection: Upgrade\r\n' ..
				'Sec-WebSocket-Protocol: ClassiCube\r\n' ..
				'Sec-WebSocket-Accept: %s\r\n\r\n'):format(wskey)
				sendMesg(cl, response)
				wsHandshake[cl] = nil
				createPlayer(cl, data.ip, true)
			else
				data.state = 'badrequest'
			end
		end

		if data.state == 'badrequest'then
			local msg = data.emsg or MESG_NOTWSCONN
			local response =
			('HTTP/1.1 400 Bad request\r\n' ..
			'Content-Type: text/plain; charset=utf-8\r\n' ..
			'Content-Length: %d\r\n\r\nBad request: %s')
			:format(#msg + 13, msg)
			sendMesg(cl, response)
			closeSock(cl)
			wsHandshake[cl] = nil
		end
	end
end

function createPlayer(cl, ip, isWS)
	if not onConnectionAttempt or not onConnectionAttempt(ip)then
		local player = newPlayer(cl)
		player.isWS = isWS
		player.ip = ip

		local nid = findFreeID(player)
		if nid >= 0 then
			player:init(nid)
		else
			player:kick(KICK_SFULL)
		end
		hooks:call('onPlayerCreate', player)
	else
		local rawPacket = generatePacket(0x0e, KICK_CONNREJ)
		if isWS then
			sendMesg(cl, encodeWsFrame(rawPacket, 0x02))
		else
			sendMesg(cl, rawPacket)
		end
	end
end

function handleConsoleCommand(cmd)
	if cmd:sub(1,1) == '#'then
		local code = cmd:sub(2)
		code = code:gsub('^=', 'return ')

		local chunk, err = loadstring(code)
		if chunk then
			local ret = {pcall(chunk)}
			for i=2, #ret do
				ret[i] = tostring(ret[i])
			end
			if ret[1]then
				log.info(table.concat(ret, ', ', 2))
			else
				log.error((MESG_ERROR):format(ret[2]))
			end
		else
			log.error((MESG_ERROR):format(err))
		end
	else
		local args = cmd:split('%s')
		cmd = table.remove(args, 1)
		if not cmd then return end
		local argstr = table.concat(args,' ')
		cmd = cmd:lower()

		local cmf = commands[cmd]
		if cmf then
			local succ, rtval = pcall(cmf, true, nil, args)
			if not succ then
				log.error('Command', cmd, 'got error:', rtval)
				return
			end
			if rtval == false then
				local str = _G['CU_' .. cmd:upper()]
				if str then
					log.info((CON_USE):format(str))
				end
			else
				if rtval == nil then return end
				log.info(rtval)
			end
		else
			log.error(MESG_UNKNOWNCMD)
		end
	end
end

function acceptClients()
	local cl, ip = acceptClient(server)
	if not cl then return end
	if wsHandshake then
		wsHandshake[cl] = {
			state = 'testws',
			headers = {},
			ip = ip
		}
		return
	end
	createPlayer(cl, ip, false)
end

function serviceMessages()
	playersForEach(function(player)
		player:serviceMessages()
	end)
end

function init()
	local loglvl = tonumber(os.getenv('LOGLEVEL'))
	if loglvl then
		log.setLevel(loglvl)
	end
	log.info(CON_START)
	players, IDS = {}, {}
	worlds = {}

	permissions:parse()
	config:parse()
	cpe:init()

	uwa = config:get('unloadWorldAfter')
	local ip = config:get('serverIp')
	local port = config:get('serverPort')
	server = assert(bindSock(ip, port))

	if config:get('acceptWebsocket')then
		wsHandshake = {}
		wsLoad()
	else
		wsLoad = nil
	end

	_GAMEMODE = config:get('serverGamemode')
	if _GAMEMODE and #_GAMEMODE > 0 and _GAMEMODE ~= 'none'then
		log.info('Loading gamemode', mode)
		local chunk, err = loadfile('gamemodes/' .. _GAMEMODE .. '.lua')
		if chunk then
			initGamemode = chunk()
		else
			log.fatal('Gamemode loading error:', err)
		end
	end

	log.info('Loading banlist')
	loadBanList()

	log.info(CON_WLOAD)
	local sdlist = config:get('levelSeeds')
	local wlist = config:get('levelNames')
	local tlist = config:get('levelTypes')
	local slist = config:get('levelSizes')

	for num, wn in pairs(wlist)do
		wn = wn:lower()
		local world
		local lvlh = io.open('worlds/' .. wn .. '.map', 'rb')
		if lvlh then
			world = newWorld(lvlh, wn)
		else
			local gtype = tlist[num]or'default'
			local dims = slist[num]or{256, 256, 256}
			world = newWorld()
			world:setName(wn)
			if world:createWorld({dimensions = newVector(unpack(dims))})then
				regenerateWorld(world, gtype, sdlist[num]or os.time())
			end
		end
		if world and world.isWorld then
			worlds[wn] = world
			world.emptyfrom = CTIME
			if num == 1 then
				worlds['default'] = world
			end
		end
	end
	if not getWorld('default')then
		log.fatal(CON_WLOADERR)
	end

	log.info((CON_BINDSUCC):format(ip, port))
	cmdh = initCmdHandler(handleConsoleCommand)
	log.info(CON_HELP)
	CTIME = gettime()
	return true
end

succ, err = xpcall(function()
	while not _STOP do
		ETIME = CTIME
		CTIME = gettime()

		if not INITED then
			if init()then
				if initGamemode then
					initGamemode()
					log.info('Gamemode:', _GAMEMODE)
					initGamemode = nil
				end
				hooks:call('onInitDone')
				INITED = true
			end
		end
		if ETIME then
			dt = CTIME - ETIME
			dt = math.min(.1, dt)
			hooks:call('onUpdate', dt)
			timer.Update(dt)
			if uwa > 0 then
				for _, world in pairs(worlds)do
					if world.emptyfrom then
						if CTIME - world.emptyfrom > uwa then
							world:unload()
							world.emptyfrom = nil
						end
					end
				end
			end
			if onUpdate then
				onUpdate(dt)
			end
		end

		acceptClients()
		serviceMessages()

		if wsHandshake then
			wsDoHandshake()
		end

		if cmdh then
			cmdh()
		end

		NextUpdate = CTIME + 0.02
		if NextUpdate > gettime() then
			sleep((NextUpdate - gettime())*1000)
		end
	end
end, debug.traceback)

ecode = 0

if INITED then
	playersForEach(function(ply)
		if _STOP == 'restart'then
			ply:kick(KICK_SVRST)
		else
			ply:kick((not succ and KICK_SVERR)or KICK_SVSTOP)
		end
	end)

	if config:save()and permissions:save()then
		log.info(CON_SAVESUCC)
	else
		log.error(CON_SAVEERR)
	end

	log.info(CON_WSAVE)
	for wname, world in pairs(worlds)do
		if wname ~= 'default'then
			if world:save()then
				log.debug('World', wname, 'saved')
			else
				log.error(wname, 'saving error')
			end
		end
	end
end

if server then closeSock(server)end
cleanupSock()
saveBanList()

if not succ then
	err = tostring(err)
	if not err:find('interrupted')then
		print(err)
		ecode = 1
	end
end

if _STOP == 'restart'then
	ecode = 2
else
	log.info(CON_SVSTOP)
end

os.exit(ecode)
