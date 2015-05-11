---------------------------------------
-- Section: Garbage place tool
---------------------------------------
local file = false
local cache = {}

addEventHandler("onResourceStart", resourceRoot,
	function()
		if fileExists("objects.txt") then
			file = fileOpen("objects.txt")
		else
			file = fileCreate("objects.txt")
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
