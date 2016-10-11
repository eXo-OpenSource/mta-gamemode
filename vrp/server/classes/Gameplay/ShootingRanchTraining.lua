-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/ShootingRanchTraining.lua
-- *  PURPOSE:     ShootingRanch Training class
-- *
-- ****************************************************************************

ShootingRanchTraining = inherit(Object)

function ShootingRanchTraining:constructor(player, level)
	if ShootingRanch.Trainings[level] then
		player:takeMoney(WEAPON_LEVEL[level]["costs"], "Schießstand")

		local data = ShootingRanch.Trainings[level]

		takeAllWeapons(player)
		giveWeapon(player, data["Weapon"], data["Ammo"], true)

		self.m_Player = player
		self.m_TargetLevel = level
		self.m_Time = data["Time"]
		self.m_TargetHits = data["Hits"]
		self.m_TargetAccuracy = data["Accuracy"]
		self.m_StartMuni = data["Ammo"]
		self.m_Hits = 0

		setElementData(player, "ShootingRanch:Hits", 0)

		if ShootingRanch:getSingleton():warpPlayerWaffenbox(player) == false then
			return
		end
		toggleAllControls(player,false)
		toggleControl(player,"fire",true)
		toggleControl(player,"aim_weapon",true)
		player:triggerEvent("startClientShootingRanch")

		player:sendInfo(_("Treffe %dx eines der Bewegenden Ziele!", player, self.m_TargetHits))
		player:sendShortMessage(_("Schaffe die Prüfung in unter %d Sekunden mit einer Trefferquote von mind. %d Prozent!", player, self.m_Time, self.m_TargetAccuracy), _("Schießstand", player))

	else
		player:sendError("Invalid Training Data")
	end
end

function ShootingRanchTraining:destructor()
	self.m_Player:setInterior(6)
	self.m_Player:setDimension(0)
	self.m_Player:setPosition(245.20, 69.44, 1003.64)
	removeElementData(self.m_Player, "ShootingRanch:Data")
	self.m_Player:triggerEvent("stopClientShootingRanch")
	toggleAllControls(self.m_Player, true)
	if isTimer(self.m_Timer) then killTimer(self.m_Timer) end
end

function ShootingRanchTraining:onTargetHit()
	self.m_Hits = self.m_Hits + 1

	if not self.m_StartTime then
		self.m_StartTime = getRealTime().timestamp
		self.m_Timer = setTimer(bind(self.finish, self), self.m_Time*1000, 1, false)
	end

	self:updateClient()

	if self.m_Hits >= self.m_TargetHits then
		self:finish(true)
	end
end

function ShootingRanchTraining:updateClient()
	local data = {
		["StartTime"] = self.m_StartTime,
		["Hits"] = self.m_Hits,
		["StartMuni"] = self.m_StartMuni,
		["Time"] = self.m_Time,
		["TargetHits"] = self.m_TargetHits,
		["TargetAccuracy"] = self.m_TargetAccuracy
	}
	setElementData(self.m_Player, "ShootingRanch:Data", data)
end

function ShootingRanchTraining:finish(successHits)
	if successHits then
		local time = getRealTime().timestamp - self.m_StartTime
		local acc = self.m_Hits*100/(self.m_StartMuni - self.m_Player:getTotalAmmo())
		if acc >= self.m_TargetAccuracy then
			self.m_Player:sendInfo(_("Sehr gut! Du hast bestanden! Dein Waffenlevel wurde erhöht!", self.m_Player))
			self.m_Player:setWeaponLevel(self.m_TargetLevel)
			delete(self)
		end
	else
		self.m_Player:sendError(_("Die Zeit ist abgelaufen! Du hast nicht bestanden!", self.m_Player))
		delete(self)
	end
end
