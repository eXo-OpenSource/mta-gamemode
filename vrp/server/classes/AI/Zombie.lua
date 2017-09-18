Zombie = inherit(Object)

addRemoteEvents{"onZombieHit", "onZombieSpawn", "onZombieWasted", "onZombieIdle", "onZombieAttack", "doZombieWasted" ,"onZombieBigColHit"}

function Zombie:constructor(pos, model, dim, int)
	-- Ped halt
	self.m_Ped = createPed(model, pos)
	assert(isElement(self.m_Ped))
	setElementDimension(self.m_Ped, dim or 0)
	setElementInterior(self.m_Ped, int or 0)
	setElementData(self.m_Ped, "zombie", true)

	self.m_SeeCheck = true
	-- Variablen
	do
		self.m_target = nil
		self.m_attacking = false
		self.m_state = "waiting"
	--	self.object = self

		-- Col Shapes
		-- Um dem Zombie werden 2 Colshapes erstellt, ein mit kleinem Radius und ein mit Grossem.
		-- Dies dient zum Sprinten/Erkennen.

		self.m_bigcol = createColSphere(pos, 100)
		self.m_smallcol = createColSphere(pos, 5)
		setElementDimension(self.m_bigcol, dim or 0)
		setElementInterior(self.m_bigcol, int or 0)
		setElementDimension(self.m_smallcol, dim or 0)
		setElementInterior(self.m_smallcol, int or 0)

		attachElements(self.m_bigcol, self.m_Ped)
		attachElements(self.m_smallcol, self.m_Ped)

		-- Event handler -


		addEventHandler("onColShapeHit", self.m_bigcol, function(target) self:CheckIfZombieCanSee(target) end) -- self:SprintToPlayer(target)
		addEventHandler("onColShapeHit", self.m_smallcol, function(target) self:RunToPlayer(target) end)

		addEventHandler("onColShapeLeave", self.m_bigcol, function(target) self:CancelSprint(target) end)
		addEventHandler("onColShapeLeave", self.m_smallcol, function(target) self:SprintToPlayer(target) end)

		addEventHandler("onPedWasted", self.m_Ped, function(ammo, killer) self:onWasted(killer) end)


		addEventHandler("onZombieHit", self.m_Ped, function(who)
			self.m_target = who;
			self:RunToPlayer(who)
		end)

		addEventHandler("onZombieBigColHit", self.m_Ped, function(who, bool) self:ReplyZombieCanSee(who, bool) end) -- Ob er den sehen kann
	end

	self:SetZombieIdle(true)

	triggerEvent("onZombieSpawn", self.m_Ped, self) -- // --

	return self
end

function Zombie:destructor()
	-- Destroy Colshapes
	if isElement(self.m_smallcol) then self.m_smallcol:destroy() end
	if isElement(self.m_bigcol) then self.m_bigcol:destroy() end

	-- Destroy Timers
	if(isTimer(self.m_updateRunTimer)) then
		killTimer(self.m_updateRunTimer)
	end
	if(isTimer(self.m_idleTimer)) then
		killTimer(self.m_idleTimer)
	end

	if isElement(self.m_Ped) then self.m_Ped:destroy() end
end

function Zombie:onWasted(killer)
	if killer then
		triggerEvent("onZombieWasted", self.m_Ped, self, killer)
		setTimer(
			function()
				delete(self)
			end,
		30*1000, 1)
	else
		delete(self)
	end
end


function Zombie:disableSeeCheck()
	self.m_SeeCheck = false
end

function Zombie:NewIdlePos()
	if(self.m_state == "waiting") then
		local ped = self.m_Ped
		setPedRotation(ped, math.random(0, 360)) -- Yay :D
		setPedAnimation(ped, "ped", "WALK_fatold", 2500, true, true, true)

		for index, player in pairs(getElementsWithinColShape(self.m_bigcol, "player")) do
			self:CheckIfZombieCanSee(player)
		end

		if(math.random(0, 2) == 1) then

		end
	end
end

function Zombie:SetZombieIdle(bool)
	if(bool) then
		if(self.m_state == "waiting") then
			if(isTimer(self.m_idleTimer)) then
				killTimer(self.m_idleTimer)
			end
			self.m_idleTimer = setTimer(function() self:NewIdlePos() end, math.random(9000, 11000), 0)
			self:NewIdlePos()
			triggerEvent("onZombieIdle", self.m_Ped, self) -- // --
		end
	else
		if(self.m_state ~= "waiting") then
			if(isTimer(self.m_idleTimer)) then
				killTimer(self.m_idleTimer)
			end
		end
	end
end

function Zombie:UpdateSprint()
	if not isElement(self.m_target) or not isElement(self.m_Ped) then
		killTimer(self.m_updateRunTimer)
		self:SetZombieIdle(true)
		self.m_state = "waiting"
	end

		if(self.m_state == "sprinting") and (getElementData(self.m_Ped, "jumping") ~= true) then
			local x1, y1, z1 = getElementPosition(self.m_Ped)
			local x2, y2, z2 = getElementPosition(self.m_target)
			local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
			rot = rot-90
			setPedRotation(self.m_Ped, rot)
			setPedAnimation(self.m_Ped, "ped", "sprint_panic", 0, true, true, true)
		elseif(self.m_state == "running")and (getElementData(self.m_Ped, "jumping") ~= true) then
			local x1, y1, z1 = getElementPosition(self.m_Ped)
			local x2, y2, z2 = getElementPosition(self.m_target)
			local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
			rot = rot-90
			setPedRotation(self.m_Ped, rot)
			setPedAnimation(self.m_Ped, "ped", "JOG_maleA", 0, true, true, true)

			local dis = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
			if(dis < 2) then
				-- attack
				setPedAnimation(self.m_Ped)
				self.m_attacking = true
				triggerClientEvent(getRootElement(), "onZombieAttack", getRootElement(), self.m_Ped, true, self.m_target)
			else
				if(self.m_attacking == true) then
					self.m_attacking = false
					triggerClientEvent(getRootElement(), "onZombieAttack", getRootElement(), self.m_Ped, false, self.m_target)
				end
			end
		end
		-- // Jump Digens // --
		local x1, y1, z1 = getElementPosition(self.m_Ped)
		local x2, y2, z2 = getElementPosition(self.m_target)


		triggerClientEvent(getRootElement(), "onZombieWall", getRootElement(), self.m_Ped, self.m_target)
end

function Zombie:RunToPlayer(target2)
	if(isElement(target2)) and (getElementType(target2) == "player") and (target2 == self.m_target) then
		if(isTimer(self.m_updateRunTimer)) then
			killTimer(self.m_updateRunTimer)
		end
		self.m_state = "running"
		self:SetZombieIdle(false)
		self.m_target = target2

		setElementData(self.m_Ped, "target", self.m_target2);

		local x1, y1, z1 = getElementPosition(self.m_Ped)
		local x2, y2, z2 = getElementPosition(self.m_target)
		local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
		rot = rot-90
		setPedRotation(self.m_Ped, rot)
		setPedAnimation(self.m_Ped, "ped", "JOG_maleA", 0, true, true, true)

		self.m_updateRunTimer = setTimer(function() self:UpdateSprint() end, 500, 0)
	end
end

function Zombie:SprintToPlayer(target2)
	if(isElement(target2)) and (getElementType(target2) == "player") and (self.m_state ~= "sprinting") then
		if(isTimer(self.m_updateRunTimer)) then
			killTimer(self.m_updateRunTimer)
		end
		self.m_state = "sprinting"
		self.m_target = target2
		self:SetZombieIdle(false)

		setElementData(self.m_Ped, "target", self.m_target);

		local x1, y1, z1 = getElementPosition(self.m_Ped)
		local x2, y2, z2 = getElementPosition(self.m_target)
		local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
		rot = rot-90
		setPedRotation(self.m_Ped, rot)
		setPedAnimation(self.m_Ped, "ped", "sprint_panic", 0, true, true, true)

		self.m_updateRunTimer = setTimer(function() self:UpdateSprint() end, 500, 0)
		triggerEvent("onZombieAttack", self.m_Ped, self, target2)
	end
end

function Zombie:CancelSprint(target2)
	if(self.m_target == target2) then
		if(isTimer(self.m_updateRunTimer)) then
			killTimer(self.m_updateRunTimer)
		end
		self.m_state = "waiting"
		self:SetZombieIdle(true)
		self.m_target = nil;

		self:NewIdlePos()
	end
end

function Zombie:ReplyZombieCanSee(player, bool)
	if(bool == true) then
		self:SprintToPlayer(player);
	end
end

function Zombie:CheckIfZombieCanSee(attacker)
	if self.m_SeeCheck == true then
		if(getElementType(attacker) == "vehicle") then
			if(getVehicleOccupant(attacker)) then
				self:ReplyZombieCanSee(getVehicleOccupant(attacker), true);
			end
		elseif(getElementType(attacker) == "player") then
			triggerClientEvent(attacker, "doZombieCanSeeCheck", attacker, self.m_Ped);
		end
	else
		self:SprintToPlayer(attacker)
	end
end

function Zombie.Wasted(zombie)
	killPed(zombie, source)
end

addEventHandler("doZombieWasted", getRootElement(), Zombie.Wasted)
