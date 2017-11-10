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
		addCommandHandler("dcreload", bind(Debugging.reloadClass, self))
		addCommandHandler("gp", bind(Debugging.getpos, self))
		addCommandHandler("cammat", bind(Debugging.cameramatrix, self))
		addCommandHandler("sp", bind(Debugging.setpos, self))
		addCommandHandler("gui_debug", bind(Debugging.gui_debug, self))
		addCommandHandler("cef_debug", bind(Debugging.cef_debug, self))
		addCommandHandler("perf_debug", bind(Debugging.performance_debug, self))

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
		outputChatBox(("Rotation: %.2f, %.2f, %.2f"):format(getElementRotation(getPedOccupiedVehicle(localPlayer) or localPlayer)))
	end

	function Debugging:cameramatrix(cmd)
		local x1, y1, z1, x2, y2, z2 = getCameraMatrix()
		outputChatBox(("%.2f, %.2f, %.2f, %.2f, %.2f, %.2f"):format(x1, y1, z1, x2, y2, z2))
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

	function Debugging:performance_debug(cmd, arg)
		local arg = arg or ""
		if not self.m_PerformanceDebug then
			self.m_PerformanceSM = ShortMessage:new("loading...", "Performance Stats", Color.LightBlue, 6000)
			self.m_PerformanceTimer = setTimer(function()
				local tfinish = ("lua timing for filter '%s'"):format(arg)
				local __, f = getPerformanceStats("Lua timing", "d", arg)
				for i, data in ipairs(f) do
					if data[2] ~= "-" then
						tfinish = tfinish .. ("\n%s - %s (%s s)"):format(data[2], data[1], data[3])
					end
				end
				self.m_PerformanceSM:setText(tfinish)
				self.m_PerformanceSM:resetTimeout()
			
			end, 5000, 0)
		else
			killTimer(self.m_PerformanceTimer)
			self.m_PerformanceSM:delete()

		end
		self.m_PerformanceDebug = not self.m_PerformanceDebug
	end
end
