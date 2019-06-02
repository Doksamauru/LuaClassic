local hb = {}

function hb:load()
	registerSvPacket(0x14, 'bbb')
	hooks:create('onHeldBlockChange')
	getPlayerMT().getHeldBlock = function(player)
		return player.heldBlock or -1
	end
	getPlayerMT().holdThis = function(player, block, preventChange)
		if player:isSupported('heldBlock')then
			player:sendPacket(false, 0x14, block, (preventChange and 1)or 0)
		end
	end
end

return hb
