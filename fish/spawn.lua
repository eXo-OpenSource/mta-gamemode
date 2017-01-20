local setPos = Vector3(60, 155, 0.8)
local oldPos

addEventHandler("onResourceStart", resourceRoot,
	function()
		for _, v in pairs(getElementsByType("player")) do
			oldPos = v.position
			spawnPlayer(v, setPos)
			fadeCamera (v, true)
			toggleAllControls(v, true)
			setCameraTarget (v, v)
		end
	end)

addEventHandler("onPlayerJoin", root,
	function()
		local v = source
		spawnPlayer(v, setPos)
		fadeCamera (v, true)
		setCameraTarget (v, v)
	end
)

addCommandHandler("b",
	function(player)
		if oldPos then
			player:setPosition(oldPos)
		end
	end
)
