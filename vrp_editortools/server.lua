---------------------------------------
-- Section: Garbage place tool
---------------------------------------
local file = false
local cache = {}

addEventHandler("onResourceStart", resourceRoot,
	function()
		if fileExists("garbage.txt") then
			file = fileOpen("garbage.txt")
		else
			file = fileCreate("garbage.txt")
		end
		
		-- Seek to the end
		--fileSetPos(file, fileGetSize(file))
	end
)

addEvent("garbageAdd", true)
addEventHandler("garbageAdd", root,
	function(x, y, z)
		local object = createObject(2670, x, y, z)
		local blip = createBlip(x, y, z, 0, 1)
		cache[#cache + 1] = {x, y, z, object, blip}
	end
)

addCommandHandler("savegarbage",
	function(player)
		for k, v in pairs(cache) do
			local x, y, z = unpack(v)
			fileWrite(file, string.format("{%.2f, %.2f, %.2f},\n", x, y, z))
		end
		fileFlush(file)
		outputChatBox("Saved!", player, 255, 255, 0)
	end
)

addCommandHandler("dellast",
	function(player)
		local lastIndex = #cache
		if lastIndex > 0 then
			local last = cache[lastIndex]
			cache[lastIndex] = nil
			destroyElement(last[4])
			destroyElement(last[5])
		end
	end
)


---------------------------------------
-- Section: Ped place tool
---------------------------------------
local shopPeds = {}

function ShopPed_Key(player)
	local x, y, z = getElementPosition(player)
	local rx, ry, rz = getElementRotation(player)
	local ped = createPed(getElementModel(player), x, y, z, rz)
	setElementInterior(ped, getElementInterior(player))
	setElementDimension(ped, getElementDimension(player))
	setElementCollisionsEnabled(ped, false)
	shopPeds[#shopPeds + 1] = ped
end
for k, v in pairs(getElementsByType("player")) do
	bindKey(v, "f3", "down", ShopPed_Key)
end
addEventHandler("onPlayerJoin", root,
	function()
		bindKey(source, "f3", "down", ShopPed_Key)
	end
)

addCommandHandler("savepeds",
	function()
		local file
		if fileExists("peds.txt") then
			file = fileOpen("peds.txt")
		else
			file = fileCreate("peds.txt")
		end
	
		for k, ped in pairs(shopPeds) do
			local x, y, z = getElementPosition(ped)
			local rx, ry, rz = getElementRotation(ped)
			fileWrite(file, string.format("{%d, %.2f, %.2f, %.2f, %.1f, %d, %d},\n", getElementModel(ped), x, y, z, rz, getElementInterior(ped), getElementDimension(ped)))
		end
		
		outputChatBox("Shop peds were saved!", root, 255, 255, 0)
	end
)

addCommandHandler("delped",
	function()
		local ped = shopPeds[#shopPeds]
		shopPeds[#shopPeds] = nil
		destroyElement(ped)
	end
)
