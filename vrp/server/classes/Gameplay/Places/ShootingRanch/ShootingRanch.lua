-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/ShootingRanch.lua
-- *  PURPOSE:     ShootingRanch singleton class
-- *
-- ****************************************************************************

ShootingRanch = inherit(Singleton)
addRemoteEvents{"ShootingRanch:onTargetHit", "ShootingRanch:onTimeUp"}

ShootingRanch.Map = {}

ShootingRanch.Trainings = {
	[1] = {["Weapon"] = 24, ["Time"] = 60, ["Hits"] = 10,  ["Accuracy"] = 20, ["Ammo"] = 90},
	[2] = {["Weapon"] = 24, ["Time"] = 60, ["Hits"] = 20, ["Accuracy"] = 40, ["Ammo"] = 90},
	[3] = {["Weapon"] = 24, ["Time"] = 60, ["Hits"] = 25, ["Accuracy"] = 60, ["Ammo"] = 90},
	[4] = {["Weapon"] = 25, ["Time"] = 60, ["Hits"] = 15, ["Accuracy"] = 40, ["Ammo"] = 90},
	[5] = {["Weapon"] = 25, ["Time"] = 60, ["Hits"] = 20, ["Accuracy"] = 50, ["Ammo"] = 90},
	[6] = {["Weapon"] = 25, ["Time"] = 60, ["Hits"] = 30, ["Accuracy"] = 70, ["Ammo"] = 90},
	[7] = {["Weapon"] = 31, ["Time"] = 60, ["Hits"] = 20,  ["Accuracy"] = 30, ["Ammo"] = 500},
	[8] = {["Weapon"] = 31, ["Time"] = 60, ["Hits"] = 30,  ["Accuracy"] = 40, ["Ammo"] = 500},
	[9] = {["Weapon"] = 31, ["Time"] = 60, ["Hits"] = 40,  ["Accuracy"] = 50, ["Ammo"] = 500},
	[10] = {["Weapon"] = 31, ["Time"] = 60, ["Hits"] = 50, ["Accuracy"] = 70, ["Ammo"] = 500}
}

function ShootingRanch:constructor()
	InteriorEnterExit:new(Vector3(-7188.08, -2488.68, 32.36), Vector3(252.13, 117.37, 1003), 0, 270, 10, 0, 0, 0):setCustomText("Ausgang", "Waffentraining")


	self.m_ShootingRanchMarker = createMarker(-7190.96, -2482.61, 31.4, "cylinder", 1, 0, 255, 0, 200)
	addEventHandler("onMarkerHit", self.m_ShootingRanchMarker, function(hitElement, dim)
		if hitElement:getType() == "player" and dim then
			hitElement:triggerEvent("openWeaponLevelGUI")
		end
	end)

	self.m_WeaponSpheres = {
		[1] = createColSphere(-7185.4, -2463.60, 31.5, 2),
		[2] = createColSphere(-7185.4, -2468.36, 31.5, 2),
		[3] = createColSphere(-7185.4, -2463.43, 31.5, 2)
	}
	--self:addTargets()

	self.m_Col = createColSphere(-7191.44, -2473.93, 32.36, 50)
	addEventHandler("onColShapeHit", self.m_Col, function(hitElement, dim)
		if dim and hitElement:getType() == "player" then
			hitElement:triggerEvent("toggleRadar", false)
			if not self.m_Targets then
				self:addTargets()
			end
		end
	end)

	addEventHandler("onColShapeLeave", self.m_Col, function(hitElement, dim)
		if dim and hitElement:getType() == "player" then
			hitElement:triggerEvent("toggleRadar", true)
			if #source:getElementsWithin("player") == 0 then
				if self.m_Targets then
					self:killTargets()
				end
			end
		end
	end)


	addEventHandler("ShootingRanch:onTargetHit", root, bind(self.onTargetHit, self))
	addEventHandler("ShootingRanch:onTimeUp", root, bind(self.onTimeUp, self))

end

function ShootingRanch:startTraining(player, level)
	ShootingRanch.Map[player] = ShootingRanchTraining:new(player, level)
end

function ShootingRanch:warpPlayerWaffenbox(player)
	local freesphere = self:getFreeSphere()
	if isElement(freesphere) then
		setElementDimension(player,0)
		setElementInterior(player,0)
		player:setPosition(freesphere:getPosition())
		player:setRotation(0, 0, 270, "default", true)
		return true
	else
		player:sendError(_("Keine freie Waffenbox! Bitte warte ein wenig!", player))
		--setElementDimension(player,0)
		--setElementInterior(player,6)
		--player:setPosition(244.16,69.11,1003.64)
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
	if getElementData(object, "hitAble") == false then return false end

	if ShootingRanch.Map[client] then
		object:stop()
		object:move(200, object:getPosition(), 90)
		setTimer(bind(self.reactivateTarget, self), 2000, 1, object)
		if isTimer(getElementData(object, "timer")) then killTimer(getElementData(object, "timer")) end
		setElementData(object, "hitAble", false)

		ShootingRanch.Map[client]:onTargetHit(client)
	else
		client:sendError("Invalid ShootingRanch Instance")
	end
end

function ShootingRanch:onTimeUp()
	if ShootingRanch.Map[client] then
		ShootingRanch.Map[client]:finish()
	else
		client:sendError("Invalid ShootingRanch Instance")
	end
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
	self.m_Targets = nil
end
