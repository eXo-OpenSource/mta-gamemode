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

	addRemoteEvents{"receiveFires", "adminFireRequestData", "adminToggleFire", "adminCreateFire", "adminEditFire", "adminDeleteFire"}
	addEventHandler("receiveFires", root, bind(self.receiveFires, self))
	addEventHandler("adminFireRequestData", root, bind(self.Event_adminRequestData, self))
	addEventHandler("adminToggleFire", root, bind(self.Event_toggleFire, self))
	addEventHandler("adminCreateFire", root, bind(self.Event_createFire, self))
	addEventHandler("adminEditFire", root, bind(self.Event_editFire, self))
	addEventHandler("adminDeleteFire", root, bind(self.Event_deleteFire, self))
end

function FireManager:loadFirePlaces()
	local result = sql:queryFetch("SELECT * FROM ??_fires", sql:getPrefix())
	for i, row in pairs(result) do
		self.m_Fires[row.Id] = {
			["name"] = row.Name,
			["message"] = row.Message,
			["position"] = Vector3(row.PosX, row.PosY, row.PosZ),
			["positionTbl"] = {row.PosX, row.PosY, row.PosZ},
			["width"] = row.Width,
			["height"] = row.Height,
			["creator"] = row.Creator,
			["enabled"] = row.Enabled == 1 and true or false,
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
	--//TODO
	self:startFire(rnd)
end

function FireManager:startFire(id)
	if self.m_CurrentFire then self:stopCurrentFire() end
	local fireTable = self.m_Fires[id]
	self.m_CurrentFire = FireRoot:new(fireTable["position"].x, fireTable["position"].y, fireTable["width"] or 20, fireTable["height"] or 20)
	self.m_CurrentFire.m_Id = id
	self.m_CurrentFire.Blip = Blip:new("Fire.png", fireTable["position"].x, fireTable["position"].y, root, 400)
	self.m_CurrentFire.Blip:setOptionalColor(BLIP_COLOR_CONSTANTS.Orange)
	self.m_CurrentFire.Blip:setDisplayText("Verkehrsbehinderung")

	local posName = getZoneName(fireTable["position"]).."/"..getZoneName(fireTable["position"], true)
	PlayerManager:getSingleton():breakingNews(fireTable["message"], posName)
	FactionRescue:getSingleton():sendWarning(fireTable["message"], "Brand-Meldung", true, fireTable["position"], posName)
	FactionState:getSingleton():sendWarning(fireTable["message"], "Absperrung erforderlich", false, fireTable["position"], posName)
end

function FireManager:getCurrentFire()
	return self.m_CurrentFire
end

function FireManager:stopCurrentFire()
	outputDebug("stopping current fire")
	delete(self.m_CurrentFire.Blip)
	delete(self.m_CurrentFire)
	self.m_CurrentFire = nil
end

function FireManager:receiveFires()
	if self.m_CurrentFire then
		self.m_CurrentFire:syncFires(client)
	end
end

--Admin / Dev methods

function FireManager:Event_adminRequestData()
	if client:getRank() < ADMIN_RANK_PERMISSION["fireMenu"] then
		client:sendError(_("Du darfst diese Funktion nicht nutzen!", client))
		return
	end
	self:sendAdminFireData(client)
end

function FireManager:sendAdminFireData(player)
	player:triggerEvent("adminFireReceiveData", self.m_Fires, self.m_CurrentFire and self.m_CurrentFire.m_Id)
end

function FireManager:Event_toggleFire(id)
	if client:getRank() < ADMIN_RANK_PERMISSION["fireMenu"] then
		client:sendError(_("Du darfst diese Funktion nicht nutzen!", client))
		return
	end
	if self:getCurrentFire() then
		if self:getCurrentFire().m_Id == id then
			self:stopCurrentFire()
		else 
			self:startFire(id)
		end
	else
		self:startFire(id)
	end
	self:sendAdminFireData(client)
end

function FireManager:Event_createFire()
	if client:getRank() < ADMIN_RANK_PERMISSION["fireMenu"] then
		client:sendError(_("Du darfst diese Funktion nicht nutzen!", client))
		return
	end
	self:sendAdminFireData(client)
end

function FireManager:Event_editFire(id, tblArgs)
	if client:getRank() < ADMIN_RANK_PERMISSION["fireMenu"] then
		client:sendError(_("Du darfst diese Funktion nicht nutzen!", client))
		return
	end
	--update db
	sql:queryExec("UPDATE ??_fires SET Name = ?, Message = ?, Enabled = ? WHERE Id = ?", sql:getPrefix(), 
		tostring(tblArgs.name) or "name failed to save",
		tostring(tblArgs.message) or "msg failed to save",
		tblArgs.enabled and 1 or 0,
		id
	)

	--update InGame fire cache 
	self.m_Fires[id]["name"] = tblArgs.name
	self.m_Fires[id]["message"] = tblArgs.message
	self.m_Fires[id]["enabled"] = tblArgs.enabled

	client:sendSuccess(_("Feuer %d gespeichert.", client, id))
	self:sendAdminFireData(client) -- resend data (update client UI)
end

function FireManager:Event_deleteFire()
	if client:getRank() < ADMIN_RANK_PERMISSION["fireMenu"] then
		client:sendError(_("Du darfst diese Funktion nicht nutzen!", client))
		return
	end
	self:sendAdminFireData(client)
end