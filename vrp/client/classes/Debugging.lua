-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Debugging.lua
-- *  PURPOSE:     Debugging class
-- *
-- ****************************************************************************
GUI_DEBUG = false

if DEBUG then
	local CEF_DEBUG = false

	Debugging = inherit(Singleton)

	function Debugging:constructor()
		setDevelopmentMode(true)
		addCommandHandler("dcrun", bind(Debugging.runString, self))
		addCommandHandler("dcreload", bind(Debugging.reloadClass, self))
		addCommandHandler("gp", bind(Debugging.getpos, self))
		addCommandHandler("sp", bind(Debugging.setpos, self))
		addCommandHandler("gui_debug", bind(Debugging.gui_debug, self))
		addCommandHandler("cef_debug", bind(Debugging.cef_debug, self))

		bindKey("lshift", "down",
			function()
				if localPlayer:getRank() >= RANK.Moderator then
					local vehicle = getPedOccupiedVehicle(localPlayer)
					if vehicle then
						local vx, vy, vz = getElementVelocity(vehicle)
						setElementVelocity(vehicle, vx, vy, 0.3)
					end
				end
			end
		)
		bindKey("lalt", "down",
			function()
				if localPlayer:getRank() >= RANK.Moderator then
					local vehicle = getPedOccupiedVehicle(localPlayer)
					if vehicle then
						local vx, vy, vz = getElementVelocity(vehicle)
						setElementVelocity(vehicle, vx*1.5, vy*1.5, vz)
					end
				end
			end
		)
		bindKey("f5", "down",
			function()
				if MapGUI:isInstantiated() then
					delete(MapGUI:getSingleton())
				else
					MapGUI:getSingleton(function(posX, posY) self:setpos("", posX, posY, 20) end)
				end
			end
		)
	end

	function Debugging:runString(cmd, ...)
		if localPlayer:getRank() >= RANK.Administrator then
			local codeString = table.concat({...}, " ")
			runString(codeString, root, player)
		end
	end

	function Debugging:reloadClass(cmd, file)
		if not fileExists(file) then
			outputChatBox("file does not exist")
		else
			outputChatBox("reloading " .. file)
			local fh = fileOpen(file)
			local data = fileRead(fh, fileGetSize(fh))
			fileClose(fh)
			local fn, err = loadstring(data)
			if not fn then
				outputChatBox("Error Compiling "..err)
				return
			end
			status, err = pcall(fn)
			if not status then
				outputChatBox("Error Launching "..err)
				return
			end
			outputChatBox("Successfully reloaded")
		end
	end

	function Debugging:getpos(cmd)
		outputChatBox(("Position: %.2f, %.2f, %.2f"):format(getElementPosition(getPedOccupiedVehicle(localPlayer) or localPlayer)))
	end

	function Debugging:setpos(cmd, x, y, z)
		local x, y, z = x, y, z
		if not x then
			x, y, z = getElementPosition(getPedOccupiedVehicle(localPlayer) or localPlayer)
			z = z + 1
		end
		outputChatBox(("Setting Position: %.2f, %.2f, %.2f"):format(x, y, z))
		setElementPosition(getPedOccupiedVehicle(localPlayer) or localPlayer, x, y, z)
	end

	function Debugging:gui_debug()
		GUI_DEBUG = not GUI_DEBUG
	end

	function Debugging:cef_debug()
		CEF_DEBUG = not CEF_DEBUG
		setDevelopmentMode(true, CEF_DEBUG)
	end
end
