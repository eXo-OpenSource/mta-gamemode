Collector = inherit(Object)

function Collector:constructor(auto_check, check_rate)
	if auto_check then
		self.m_Pulse = TimedPulse:new(check_rate)
		self.m_Pulse:registerHandler(bind(Collector.collect, self))
	else
		self.m_Pulse = false
		outputDebugString("AUTO_CHECK IS DISABLED!", 2)
	end

	self.m_Data = {}
	self.m_WaitTime = 30*60*1000
	self.m_LastFPSCheck = 0
	self.m_LastSend = getTickCount()
	self.m_VRPWrapper = function() return false end
	addEventHandler("onClientRender", root, bind(Collector.check, self))

	local vrp = Resource.getFromName("vrp")
	if vrp then
		if vrp:getState() == "running" then
			self.m_VRPWrapper = function(...)
				if vrp and vrp:getState() == "running" then
					return call(vrp, "exportWrapper", ...)
				else
					return {result = false, status = "resource not running, call failed"}
				end
			end
		end
	end
end

function Collector:destructor()
	if self.m_Pulse then
		delete(self.m_Pulse)
	end
end

function Collector:check()
	if getCurrentFPS() <= Main.m_Config.min_fps and (getTickCount() - self.m_LastFPSCheck) >= Main.m_Config.min_fps_wait then
		self.m_LastFPSCheck = getTickCount()
		self:collect()
	end
end

function Collector:collect()
	local time = getRealTime()
	local screenX, screenY = guiGetScreenSize()
	local x, y, z, dim, int = getElementPosition(localPlayer), getElementDimension(localPlayer), getElementInterior(localPlayer)
	local vx, vy, vz = getElementVelocity(localPlayer)
	table.insert(self.m_Data,
		{
			up_time          = getTickCount(),
			current_time     = ("%d:%d:%d-%d:%d:%d"):format(time.hour, time.minute, time.second, time.monthday, time.month, time.year + 1900), -- HH:MM:SS-DD:MM:YY
			current_fps      = getCurrentFPS(),
			position         = {
				x   = x,
				y   = y,
				z   = z,
				int = int,
				dim = dim,
				velocity = {
					vx = vx,
					vy = vy,
					vz = vz
				}
			},
			mods              = {},
			dx                = dxGetStatus(),
			screenSize        = {
				x = screenX,
				y = screenY
			},
			streamed_elements = {
				vehicles    = #getElementsByType("vehicle", true),
				players     = #getElementsByType("player", true),
				objects     = #getElementsByType("object", true),
				effects     = #getElementsByType("effect", true),
				lights      = #getElementsByType("light", true),
				shaders     = #getElementsByType("shader", true),
				textures    = #getElementsByType("texture", true),
				projectiles = #getElementsByType("projectile", true),
			},
			running_shader    = self.m_VRPWrapper("shaderStatus"),
			texture_mode      = self.m_VRPWrapper("textureMode"),
			loaded_textures   = self.m_VRPWrapper("textureStatus"),
			hud_mode		  = self.m_VRPWrapper("hudStatus"),
			radar_mode        = self.m_VRPWrapper("radarStatus"),
		}
	)

	if (getTickCount() - self.m_LastSend) >= Main.m_Config.check_rate then
		self:send()
	end
end

function Collector:send()
	if (getTickCount() - self.m_LastSend) >= Main.m_Config.check_rate then
		self.m_LastSend = getTickCount()
		triggerServerEvent("dataCollectionServer", root, self.m_Data)
	end
end
