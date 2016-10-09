-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/ShootingRanch.lua
-- *  PURPOSE:     ShootingRanch singleton class
-- *
-- ****************************************************************************

ShootingRanch = inherit(Singleton)
addRemoteEvents{"ShootingRanch:onTargetHit", "ShootingRanch:Finish"}

ShootingRanch.Weapons = {
	[22] = {["Time"] = 120, ["Hit"] = 35, ["Price"] = 2000, ["Ammo"] = 90},
	[25] = {["Time"] = 120, ["Hit"] = 30, ["Price"] = 4000, ["Ammo"] = 90},
	[31] = {["Time"] = 60, ["Hit"] = 20, ["Price"] = 6000, ["Ammo"] = 500}
}

function ShootingRanch:constructor()
	self.m_WeaponSpheres = {
		[1] = createColSphere(-7186.60, -2463.6, 31.5, 2),
		[2] = createColSphere(-7186.60, -2455.5, 31.5, 2),
		[3] = createColSphere(-7186.60, -2474.8, 31.5, 2)
	}
	self:addTargets()

	addEventHandler("ShootingRanch:onTargetHit", root, bind(self.onTargetHit, self))
end

function ShootingRanch:startLession(player, weapon)
	if not weapon or not ShootingRanch.Weapons[weapon] then
		player:sendError(_("Unbekannte Waffe", player))
		return
	end
	local weaponData = ShootingRanch.Weapons[weapon]
	if player:getMoney() >= weaponData["Price"] then
		player:takeMoney(weaponData["Price"], "Schießstand")

		player:sendInfo(_("Treffe 25x eines der Bewegenden Ziele!", player))
		player:sendShortMessage(_("Schaffe die Prüfung in unter %d Sekunden mit einer Trefferquote von mind. %d Prozent!", player, weaponData["Time"], weaponData["Hit"]), _("Schießstand", player))

		if self:warpPlayerWaffenbox(player) == false then
			return
		end
		setElementData(player, "hits", 0)
		setElementData(player,"firstmuni", weaponData["Ammo"])

		takeAllWeapons(player)
		giveWeapon(player, weapon, weaponData["Ammo"], true)

		toggleAllControls(player,false)
		toggleControl(player,"fire",true)
		toggleControl(player,"aim_weapon",true)
	else
		player:sendError(_("Du hast nicht genug Geld dabei! (%d$)", player, costs))
	end
end

function ShootingRanch:warpPlayerWaffenbox(player)
	local freesphere = self:getFreeSphere()
	if isElement(freesphere) then
		player:setDimension(0)
		player:setInterior(0)
		player:setPosition(freesphere:getPosition())
		player:setRotation(0, 0, 270)
		setElementData(player, "isInShootingRange", true)
		setElementData(player, "shootingFrom", "sf")
		player:triggerEvent("startClientShootingRanch")
		return true
	else
		player:sendError(_("Keine freie Waffenbox! Bitte warte ein wenig!", player))
		player:setDimension(0)
		player:setInterior(6)
		player:setPosition(244.16,69.11,1003.64)
		return false
	end
end

function ShootingRanch:getFreeSphere()
	local players = {}
	for index, sphere in pairs(self.m_WeaponSpheres) do
		if isElement(sphere) then
			players = getElementsWithinColShape(sphere, "player")
			if #players == 0 then
				return sphere
			end
		end
	end
	return false
end

function ShootingRanch:calcTargetsSpeed(element, tY)
	local x, y, z = getElementPosition ( element )
	local distance = getDistanceBetweenPoints2D ( x, tY, x, y )

	local speed = distance*200

	return speed, x, z
end

function ShootingRanch:onTargetHit(object)
	if not isElement(object) then return false end
	if client ~= source then return false end
	if getElementData(object, "hitAble") == false then return false end
	setElementData(object, "hitAble", true)

	local times = getRealTime()
	local hits = getElementData(source, "hits")
	if hits==nil then hits = 0 end
	if hits==false then hits = 0 end
	hits = hits + 1

	if hits == 25 then
		local time = times.timestamp-getElementData(source, "sTime")
		--setElementData(source, "hits", 0)
		local totalammo2 = getPedTotalAmmo(source)
		local firstmuni = getElementData(source,"firstmuni")
		local acc = 25*100/(firstmuni-totalammo2)

		--endWaffenscheinPruefung(source,time,math.floor(acc))

		setElementData(source, "hits", hits)
	elseif(hits==1)then
		setElementData(source, "sTime", times.timestamp)
		setElementData(source, "hits", hits)
	else
		setElementData(source, "hits", hits)
	end

	object:stop()
	object:move(200, object:getPosition(), 90)
	setTimer(bind(self.reactivateTarget, self), 2000, 1, object)
	if isTimer(getElementData(object, "timer")) then killTimer(getElementData(object, "timer")) end
	setElementData(object, "hitAble", false)
end

function ShootingRanch:reactivateTarget(object)
	if not isElement(object) then return false end
	object:stop()
	object:move(200, object:getPosition(), -90)
	setTimer(bind(self.moveTargetOtherSide, self), 201, 1, object, math.random(0,1))
	setTimer(setElementData, 202, 1, object, "hitAble", true)
end

function ShootingRanch:moveTargetOtherSide(object, side)
	if not isElement(object) then return false end
	if side == 1 then
		local moveTime, x, z = self:calcTargetsSpeed(object, -2457)
		object:stop()
		object:move(moveTime, x, -2457, z)
		moveTime = moveTime - math.random(1,1000)
		if moveTime < 50 then moveTime = 50 end
		local timer = setTimer(bind(self.moveTargetOtherSide, self), moveTime, 1, object, 0)
		setElementData(object, "timer", timer)
	else
		local moveTime, x, z = self:calcTargetsSpeed(object, -2478)
		object:stop()
		object:move(moveTime, x, -2478, z)

		moveTime = moveTime - math.random(1,1000)
		if moveTime<50 then moveTime = 50 end
		local timer = setTimer(bind(self.moveTargetOtherSide, self), moveTime, 1, object, 1)
		setElementData(object, "timer", timer)
	end
end

function ShootingRanch:addTargets()
	if self.m_Targets then
		self:killTargets()
	end
	self.m_Targets = {
		[1] = createObject(1585, -7163.3999023438, -2466.1000976562, 31.39999961853, 0, 0, 90),
		[2] = createObject(1585, -7180.7001953125, -2462.1999511719, 31.39999961853, 0, 0, 90),
		[3] = createObject(1585, -7169.8999023438, -2465.1000976562, 31.39999961853, 0, 0, 90),
		[4] = createObject(1585, -7176.8999023438, -2465.1000976562, 31.39999961853, 0, 0, 90),
		[5] = createObject(1585, -7165.7001953125, -2462.1999511719, 31.39999961853, 0, 0, 90),
		[6] = createObject(1585, -7170.3999023438, -2466.1000976562, 31.39999961853, 0, 0, 90),
	}
	for index, target in pairs(self.m_Targets) do
		self:moveTargetOtherSide(target, math.random(0,1))
		setElementData(target, "target", true)
		setElementData(target, "hitAble", true)
	end
end

function ShootingRanch:killTargets()
	for index, target in pairs(self.m_Targets) do
		local timer = getElementData(target, "timer")
		if isTimer(timer) then
			timer:destroy()
		end

		setElementData(target, "target", nil)
		setElementData(target, "hitAble", nil)
		target:destroy()
	end
end
