-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Premium.lua
-- *  PURPOSE:     Premium class
-- *
-- ****************************************************************************
PremiumPlayer = inherit(Object)

function PremiumPlayer:constructor(player)
	self.m_Player = player
	self.m_Premium = false
	self.m_PremiumEvent = 0

	self:refresh()
end

function PremiumPlayer:refresh()
	local row = sqlPremium:queryFetchSingle("SELECT * FROM user WHERE UserId = ?", self.m_Player:getId())
	if row then
		self.m_PremiumUntil = row.premium_bis
		self.m_PremiumEvent = row.premium_easter
	else
		self.m_PremiumUntil = 0
	end

	if self.m_PremiumUntil > getRealTime().timestamp then
		self.m_Premium = true
		self.m_Player:setPublicSync("DeathTime", DEATH_TIME_PREMIUM)
		setTimer(function()
			self.m_Player:sendShortMessage(_([[
			Dein Premiumaccount ist gültig
			bis %s
			]], self.m_Player, getOpticalTimestamp(self.m_PremiumUntil)), _("Premium", self.m_Player), {50, 200, 255})
		end, 1500, 1)
	end

	self.m_Player:setPublicSync("Premium", self.m_Premium)
end

function PremiumPlayer:isPremium()
	return self.m_Premium
end

function PremiumPlayer:openVehicleList()
	local row = sqlPremium:queryFetch("SELECT * FROM premium_veh WHERE UserId = ? AND abgeholt = 0", self.m_Player:getId())
	local vehicles = {}
	if row and #row > 0 then
		for i, v in ipairs(row) do
			vehicles[v.ID] = v.Model
		end
		client:triggerEvent("vehicleTakeMarkerGUI", vehicles, "premiumTakeVehicle", "abholen")
	else
		self.m_Player:sendError("Keine Fahrzeuge zum Abholen bereit!")
	end
end

function PremiumPlayer:takeVehicle(model)
	local row = sqlPremium:queryFetchSingle("SELECT * FROM premium_veh WHERE UserId = ? AND Model = ? AND abgeholt = 0", self.m_Player:getId(), model)
	if row and row.ID then
		if #self.m_Player:getVehicles() < math.floor(MAX_VEHICLES_PER_LEVEL*self.m_Player:getVehicleLevel()) then
			sqlPremium:queryExec("UPDATE premium_veh SET abgeholt = 1, Timestamp_abgeholt = ? WHERE ID = ?;", getRealTime().timestamp, row.ID)
			local vehicle = VehicleManager:getSingleton():createNewVehicle(self.m_Player, VehicleTypes.Player, model, 1268.63, -2069.85, 59.49, 0, 0, 0, 1)
			if vehicle then
				warpPedIntoVehicle(self.m_Player, vehicle)
				self.m_Player:triggerEvent("vehicleBought")
				if row.Soundvan == 1 then
					vehicle.m_Tunings:saveTuning("Special", VehicleSpecial.Soundvan)
					vehicle.m_Tunings:applyTuning()
				end
			else
				self.m_Player:sendMessage(_("Fehler beim Erstellen des Fahrzeugs. Bitte benachrichtige einen Admin!", self.m_Player), 255, 0, 0)
			end
		else
			self.m_Player:sendError(_("Maximaler Fahrzeug-Slot erreicht!", self.m_Player))
		end
	else
		self.m_Player:sendError("Ungültiges Fahrzeug!")
	end
end

function PremiumPlayer:giveEventMonth()
	local seconds = 30*24*60*60

	if self:isPremium() then
		self.m_PremiumUntil = self.m_PremiumUntil + seconds
	else
		self.m_PremiumUntil = getRealTime().timestamp + seconds
	end

	sqlPremium:queryExec("UPDATE user SET premium_easter = ?, premium_bis = ?, premium = 1 WHERE UserId = ?;", self.m_PremiumEvent+1, self.m_PremiumUntil, self.m_Player:getId())
	self:refresh()
end
