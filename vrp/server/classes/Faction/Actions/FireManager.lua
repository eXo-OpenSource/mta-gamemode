-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Factions/Actions/FireManager.lua
-- *  PURPOSE:     Fire Manager class
-- *
-- ****************************************************************************
FireManager = inherit(Singleton)

local FIRE_TIME_MIN = 45 -- in minutes
local FIRE_TIME_MAX = 90 -- in minutes

function FireManager:constructor()
	local rnd = math.random(FIRE_TIME_MIN, FIRE_TIME_MAX)*60*1000
	self.m_StartFirePulse = TimedPulse:new(rnd)
	self.m_StartFirePulse:registerHandler(bind(self.checkFire, self))
	self.m_CurrentFire = nil
	self.m_Fires = {}

	self:loadFirePlaces()

	addRemoteEvents{"receiveFires"}
	addEventHandler("receiveFires", root, bind(self.receiveFires, self))

	addCommandHandler("fire", bind(self.startRandomFire, self))
end

function FireManager:loadFirePlaces()
	local result = sql:queryFetch("SELECT * FROM ??_fires", sql:getPrefix())
	for i, row in pairs(result) do
		self.m_Fires[row.Id] = {
			["message"] = row.Message,
			["position"] = Vector3(row.PosX, row.PosY, row.PosZ),
			["width"] = row.Width,
			["height"] = row.Height
		}
	end
end

function FireManager:checkFire()
	if FactionRescue:getSingleton():countPlayers() >= 3 then
		self:startRandomFire()
	else
		--outputDebug("checkFire - Not enough Rescue Players on! ("..FactionRescue:getSingleton():countPlayers().."/3)")
	end
end

function FireManager:startRandomFire(source)
	if source and source:getRank() < RANK.Moderator then
		source:sendError(_("Du bist nicht berechtigt!", source))
		return
	end
	self:startFire(rnd)
end

function FireManager:startFire(id)
	if self.m_CurrentFire then delete(self.m_CurrentFire) self.m_CurrentFire = nil end
	local fireTable = self.m_Fires[id]
	self.m_CurrentFire = FireRoot:new(fireTable["position"].x, fireTable["position"].y, fireTable["width"] or 20, fireTable["height"] or 20)
	self.m_CurrentFire.Blip = Blip:new("Fire.png", fireTable["position"].x, fireTable["position"].y, root, 400)
	self.m_CurrentFire.Blip:setOptionalColor(BLIP_COLOR_CONSTANTS.Orange)
	self.m_CurrentFire.Blip:setDisplayText("Verkehrsbehinderung")

	local posName = getZoneName(fireTable["position"]).."/"..getZoneName(fireTable["position"], true)
	PlayerManager:getSingleton():breakingNews(fireTable["message"], posName)
	FactionRescue:getSingleton():sendWarning(fireTable["message"], "Brand-Meldung", true, fireTable["position"], posName)
	FactionState:getSingleton():sendWarning(fireTable["message"], "Absperrung erforderlich", false, fireTable["position"], posName)
end

function FireManager:receiveFires()
	if self.m_CurrentFire then
		self.m_CurrentFire:syncFires(client)
	end
end
