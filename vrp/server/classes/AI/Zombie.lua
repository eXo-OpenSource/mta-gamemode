Zombie = inherit(Object)

addRemoteEvents{"onZombieHit", "onZombieSpawn", "onZombieWasted", "onZombieIdle", "onZombieAttack", "doZombieWasted" ,"onZombieBigColHit"}

function Zombie:constructor(pos, model, dim, int)
	-- Ped halt
	self.ped = createPed(model, pos)
	assert(isElement(self.ped))
	setElementDimension(self.ped, dim or 0)
	setElementInterior(self.ped, int or 0)
	setElementData(self.ped, "zombie", true)

	self.m_SeeCheck = true
	-- Variablen
	do
		self.target = nil
		self.attacking = false
		self.state = "waiting"
	--	self.object = self

		-- Col Shapes
		-- Um dem Zombie werden 2 Colshapes erstellt, ein mit kleinem Radius und ein mit Grossem.
		-- Dies dient zum Sprinten/Erkennen.

		self.bigcol = createColSphere(pos, 100)
		self.smallcol = createColSphere(pos, 5)
		setElementDimension(self.bigcol, dim or 0)
		setElementInterior(self.bigcol, int or 0)
		setElementDimension(self.smallcol, dim or 0)
		setElementInterior(self.smallcol, int or 0)

		attachElements(self.bigcol, self.ped)
		attachElements(self.smallcol, self.ped)

		-- Datas --
	--	setElementData(self.ped, "object", self)
		-- Event handler -


		addEventHandler("onColShapeHit", self.bigcol, function(target) self:CheckIfZombieCanSee(target) end) -- self:SprintToPlayer(target)
		addEventHandler("onColShapeHit", self.smallcol, function(target) self:RunToPlayer(target) end)

		addEventHandler("onColShapeLeave", self.bigcol, function(target) self:CancelSprint(target) end)
		addEventHandler("onColShapeLeave", self.smallcol, function(target) self:SprintToPlayer(target) end)

		addEventHandler("onPedWasted", self.ped, function(ammo, killer) self:destructor(killer) end)


		addEventHandler("onZombieHit", self.ped, function(who)
			self.target = who;
			self:RunToPlayer(who)
		end)

		addEventHandler("onZombieBigColHit", self.ped, function(who, bool) self:ReplyZombieCanSee(who, bool) end) -- Ob er den sehen kann
	end

	self:SetZombieIdle(true)

	triggerEvent("onZombieSpawn", self.ped, self) -- // --


	setElementData(self.ped, "object", self);
	return self
end

function Zombie:destructor(killer)
	-- Destroy Colshapes
	if isElement(self.smallcol) then self.smallcol:destroy() end
	if isElement(self.bigcol) then self.bigcol:destroy() end

	-- Destroy Timers
	if(isTimer(self.updateRunTimer)) then
		killTimer(self.updateRunTimer)
	end
	if(isTimer(self.idleTimer)) then
		killTimer(self.idleTimer)
	end
	triggerEvent("onZombieWasted", self.ped, self, killer) -- // --
	setTimer(function() if(isElement(self.ped)) then destroyElement(self.ped) self = nil end end, 5*60*1000, 1)
end

function Zombie:disableSeeCheck()
	self.m_SeeCheck = false
end

function Zombie:NewIdlePos()
	if(self.state == "waiting") then
		local ped = self.ped
		setPedRotation(ped, math.random(0, 360)) -- Yay :D
		setPedAnimation(ped, "ped", "WALK_fatold", 2500, true, true, true)

		for index, player in pairs(getElementsWithinColShape(self.bigcol, "player")) do
			self:CheckIfZombieCanSee(player)
		end

		if(math.random(0, 2) == 1) then

		end
	end
end

function Zombie:SetZombieIdle(bool)
	if(bool) then
		if(self.state == "waiting") then
			if(isTimer(self.idleTimer)) then
				killTimer(self.idleTimer)
			end
			self.idleTimer = setTimer(function() self:NewIdlePos() end, math.random(9000, 11000), 0)
			self:NewIdlePos()
			triggerEvent("onZombieIdle", self.ped, self) -- // --
		end
	else
		if(self.state ~= "waiting") then
			if(isTimer(self.idleTimer)) then
				killTimer(self.idleTimer)
			end
		end
	end
end

function Zombie:UpdateSprint()
	if not(isElement(self.target)) then
		killTimer(self.updateRunTimer)
		self:SetZombieIdle(true)
		self.state = "waiting"
	end

		if(self.state == "sprinting") and (getElementData(self.ped, "jumping") ~= true) then
			local x1, y1, z1 = getElementPosition(self.ped)
			local x2, y2, z2 = getElementPosition(self.target)
			local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
			rot = rot-90
			setPedRotation(self.ped, rot)
			setPedAnimation(self.ped, "ped", "sprint_panic", 0, true, true, true)
		elseif(self.state == "running")and (getElementData(self.ped, "jumping") ~= true) then
			local x1, y1, z1 = getElementPosition(self.ped)
			local x2, y2, z2 = getElementPosition(self.target)
			local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
			rot = rot-90
			setPedRotation(self.ped, rot)
			setPedAnimation(self.ped, "ped", "JOG_maleA", 0, true, true, true)

			local dis = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
			if(dis < 2) then
				-- attack
				setPedAnimation(self.ped)
				self.attacking = true
				triggerClientEvent(getRootElement(), "onZombieAttack", getRootElement(), self.ped, true, self.target)
			else
				if(self.attacking == true) then
					self.attacking = false
					triggerClientEvent(getRootElement(), "onZombieAttack", getRootElement(), self.ped, false, self.target)
				end
			end
		end
		-- // Jump Digens // --
		local x1, y1, z1 = getElementPosition(self.ped)
		local x2, y2, z2 = getElementPosition(self.target)


		triggerClientEvent(getRootElement(), "onZombieWall", getRootElement(), self.ped, self.target)
end

function Zombie:RunToPlayer(target2)
	if(isElement(target2)) and (getElementType(target2) == "player") and (target2 == self.target) then
		if(isTimer(self.updateRunTimer)) then
			killTimer(self.updateRunTimer)
		end
		self.state = "running"
		self:SetZombieIdle(false)
		self.target = target2

		setElementData(self.ped, "target", self.target2);

		local x1, y1, z1 = getElementPosition(self.ped)
		local x2, y2, z2 = getElementPosition(self.target)
		local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
		rot = rot-90
		setPedRotation(self.ped, rot)
		setPedAnimation(self.ped, "ped", "JOG_maleA", 0, true, true, true)

		self.updateRunTimer = setTimer(function() self:UpdateSprint() end, 500, 0)
	end
end

function Zombie:SprintToPlayer(target2)
	if(isElement(target2)) and (getElementType(target2) == "player") and (self.state ~= "sprinting") then
		if(isTimer(self.updateRunTimer)) then
			killTimer(self.updateRunTimer)
		end
		self.state = "sprinting"
		self.target = target2
		self:SetZombieIdle(false)

		setElementData(self.ped, "target", self.target);

		local x1, y1, z1 = getElementPosition(self.ped)
		local x2, y2, z2 = getElementPosition(self.target)
		local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
		rot = rot-90
		setPedRotation(self.ped, rot)
		setPedAnimation(self.ped, "ped", "sprint_panic", 0, true, true, true)

		self.updateRunTimer = setTimer(function() self:UpdateSprint() end, 500, 0)
		triggerEvent("onZombieAttack", self.ped, self, target2)
	end
end

function Zombie:CancelSprint(target2)
	if(self.target == target2) then
		if(isTimer(self.updateRunTimer)) then
			killTimer(self.updateRunTimer)
		end
		self.state = "waiting"
		self:SetZombieIdle(true)
		self.target = nil;

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
			triggerClientEvent(attacker, "doZombieCanSeeCheck", attacker, self.ped);
		end
	else
		self:SprintToPlayer(attacker)
	end
end

function Zombie.Wasted(zombie)
	killPed(zombie, source)
end

addEventHandler("doZombieWasted", getRootElement(), Zombie.Wasted)
