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

		if ShootingRanch:getSingleton():warpPlayerWaffenbox(player) == false then
			return
		end

		local data = ShootingRanch.Trainings[level]
		self.m_BankAccount = BankServer.get("gameplay.shooting_ranch")
		player:createStorage()

		giveWeapon(player, data["Weapon"], data["Ammo"], true)
		player:triggerEvent("disableDamage", true)
		player:transferMoney(self.m_BankAccount, WEAPON_LEVEL[level]["costs"], "Schießstand", "Gameplay", "ShootingRanch")

		self.m_Player = player
		self.m_TargetLevel = level
		self.m_Time = data["Time"]
		self.m_TargetHits = data["Hits"]
		self.m_TargetAccuracy = data["Accuracy"]
		self.m_StartMuni = data["Ammo"]
		self.m_Hits = 0

		setElementData(player, "ShootingRanch:Hits", 0)

		toggleAllControls(player,false, true, false)
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
	self.m_Player:triggerEvent("stopClientShootingRanch")

	local data = self:updateClient()
	self.m_Player:triggerEvent("showShootingRanchResult", data, self.m_Success, self.m_Player:getTotalAmmo())

	setElementDimension(self.m_Player,0)
	self.m_Player:setPosition(1561.429, -1675.023, 16.195)
	self.m_Player:restoreStorage()
	removeElementData(self.m_Player, "ShootingRanch:Data")
	toggleAllControls(self.m_Player, true, true, false)
	if isTimer(self.m_Timer) then killTimer(self.m_Timer) end
	self.m_Player:triggerEvent("disableDamage", false)
end

function ShootingRanchTraining:onTargetHit(player)
	if not self.m_Player == player then end
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
	return data
end

function ShootingRanchTraining:finish(successHits)
	if successHits then
		self.m_Success = false
		local time = getRealTime().timestamp - self.m_StartTime
		local acc = self.m_Hits*100/(self.m_StartMuni - self.m_Player:getTotalAmmo())
		if acc >= self.m_TargetAccuracy then
			self.m_Player:sendInfo(_("Sehr gut! Du hast bestanden! Dein Waffenlevel wurde erhöht!", self.m_Player))
			self.m_Player:setWeaponLevel(self.m_TargetLevel)
			self.m_Success = true
			delete(self)
		else
			self.m_Player:sendError(_("Ohje! Du hast nicht genug getroffen! Versuche besser zu zielen!", self.m_Player))
			delete(self)
		end
	else
		self.m_Player:sendError(_("Die Zeit ist abgelaufen! Du hast nicht bestanden!", self.m_Player))
		delete(self)
	end
end
