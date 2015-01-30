-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/LocalPlayer.lua
-- *  PURPOSE:     Local player class
-- *
-- ****************************************************************************
LocalPlayer = inherit(Player)
addEvent("retrieveInfo", true)

function LocalPlayer:constructor()
	self.m_Locale = "de"
	self.m_Job = false
	self.m_Rank = 0
	self.m_LoggedIn = false
	
	-- Since the local player exist only once, we can add the events here
	addEventHandler("retrieveInfo", root, bind(self.Event_retrieveInfo, self))
	
	addEventHandler("onClientPlayerWasted", localPlayer, bind(self.playerWasted, self))
end

function LocalPlayer:destructor()
end

-- Short getters
function LocalPlayer:getLocale()	return self.m_Locale 	end
function LocalPlayer:getJob()		return self.m_Job 		end

-- Short setters
function LocalPlayer:setLocale(locale)	self.m_Locale = locale 	end
function LocalPlayer:setJob(job)		self.m_Job = job		end


function LocalPlayer:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), r, g, b, true)
end

function LocalPlayer:getRank()
	return self.m_Rank
end

function LocalPlayer:isLoggedIn()
	return self.m_LoggedIn
end

function LocalPlayer:getPoints()
	return self:getPrivateSync("Points")
end

function Player:getWeaponLevel()
	return self:getPrivateSync("WeaponLevel") or 0
end

function Player:getVehicleLevel()
	return self:getPrivateSync("VehicleLevel") or 0
end

function Player:getSkinLevel()
	return self:getPrivateSync("SkinLevel") or 0
end

function Player:getJobLevel()
	return self:getPrivateSync("JobLevel") or 0
end

function LocalPlayer:playerWasted()
	setTimer(
		function()
			setCameraInterior(0)
			setCameraMatrix(1963.7, -1483.8, 101, 2038.2, -1408.4, 23)
		end, 2000, 1
	)
	setTimer(
		function()
			setCameraTarget(localPlayer)
			playSound("files/audio/Halleluja.mp3")
			local x, y, z = 2028, -1405, 110
			
			addEventHandler("onClientPreRender", root,
				function(deltaTime)
					z = z-0.005*deltaTime
					setElementPosition(localPlayer, x, y, z)
					setElementRotation(localPlayer, 0, 0, 225)
					if z <= 18 then
						removeEventHandler("onClientPreRender", root, debug.getinfo(1, "f").func)
					end
				end
			)
			
		end, 5000, 1
	)
end

-- Events
function LocalPlayer:Event_retrieveInfo(info)
	self.m_Rank = info.Rank
	self.m_LoggedIn = true
end
