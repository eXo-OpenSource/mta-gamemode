-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Factions/Actions/FireManager.lua
-- *  PURPOSE:     Fire Manager class
-- *
-- ****************************************************************************
FireManager = inherit(Singleton)

local FIRE_TIME_MIN = 60 -- in seconds
local FIRE_TIME_MAX = 120 -- in seconds

local FIRE_MESSAGES = {
	[1] = "Der Los Santos Airport steht in Flammen! Position: %s",
	[2] = "Das Los Santos Police Departement steht in Flammen! Position: %s",
	[3] = "Ein Großbrand am Ammunation in Los Santos wurde gemeldet! Position: %s!",
	[4] = "Ein Wohnaus in %s brennt!",
	[5] = "Ein verheerender Brand beim Burger Shot North wurde gemeldet! Position: %s",
	[6] = "Der Überwachungsturm des Bademeisters am %s steht in Flammen!",
	[7] = "Mehrere Wohnwägen stehen in Flammen! Position %s",
	[8] = "Die Brandmeldeanlage eines 24/7 Shops meldet Feuer! Position: %s",
	[9] = "Die Palomino Creek - Bank steht in Flammen!",
	[10] = "Mehere Mülleimer stehen in Flammen! Position: %s"
}

function FireManager:constructor()
	local rnd = math.random(FIRE_TIME_MIN, FIRE_TIME_MAX)*1000
	self.m_StartFirePulse = TimedPulse:new(rnd)
	self.m_StartFirePulse:registerHandler()
	self.m_CurrentFire = nil
	self.m_Fires = {}

	self:loadFirePlaces()

	addRemoteEvents{"receiveFires"}
	addEventHandler("receiveFires", root, bind(self.receiveFires, self))

	--Developement:
	addCommandHandler("fire", bind(self.startRandomFire, self))
end

function FireManager:loadFirePlaces()
	for index, value in ipairs(FireMap) do
		self.m_Fires[index] = {
			["message"] = FIRE_MESSAGES[index],
			["position"] = value[1],
			["table"] = value
		}
	end
end

function FireManager:startRandomFire()
	--PlayerManager:getSingleton():breakingNews(_("!", player))
	local rnd = math.random(1, #self.m_Fires)
	self:startFire(rnd)
end

function FireManager:startFire(id)
	if self.m_CurrentFire then delete(self.m_CurrentFire) self.m_CurrentFire = nil end
	self.m_CurrentFire = Fire:new(self.m_Fires[id])
end

function FireManager:receiveFires()
	if self.m_CurrentFire then
		self.m_CurrentFire:syncFires(client)
	end
end
