-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Factions/Actions/Fire.lua
-- *  PURPOSE:     Fire class (client)
-- *
-- ****************************************************************************
Fire = inherit(Singleton)

local FIRE_EFFECTS = {"fire", "fire_med", "fire_large",}

function Fire:constructor()
	self.m_Fires = {}

	self.m_SetOnFireFunc = bind(self.setOnFire, self)
	self.m_OnPedDamageFunc = bind(self.onPedDamage, self)

	addRemoteEvents{"createFire", "destroyFire"}
	addEventHandler("createFire", root, bind(self.createFire, self))
	addEventHandler("destroyFire", root, bind(self.destroyFire, self))

	triggerServerEvent("receiveFires", localPlayer)

	addEventHandler("onClientPedHitByWaterCannon", root, bind(self.handlePedWaterCannon, self))
end

function Fire:createFire()
	local ped = source
	local pos = ped.position
	local size = math.random(1,3)
	self.m_Fires[ped] = {}
	self.m_Fires[ped].Size = size
	self.m_Fires[ped].Effect = createEffect(FIRE_EFFECTS[size], pos.x, pos.y, pos.z-1, -90, 0, 0, 20*size)
	self.m_Fires[ped].Colshape = createColSphere(pos, size/4)
	setElementCollidableWith (ped, localPlayer, false)
	for index,vehicle in ipairs(getElementsByType("vehicle")) do
		setElementCollidableWith(vehicle, ped, false)
	end
	addEventHandler("onClientPedDamage", ped, self.m_OnPedDamageFunc)
	addEventHandler("onClientColShapeHit", self.m_Fires[ped].Colshape, self.m_SetOnFireFunc)
end

function Fire:setOnFire(hitElement, dim)
	if not dim then return end
	if hitElement:getType() == "player" then
		hitElement:setOnFire(true)
	elseif hitElement:getType() == "vehicle" then
		hitElement:setHealth(hitElement.health - 150)
	end
end

function Fire:onPedDamage(attacker, weapon)
	if self.m_Fires[source] then
		if weapon == 42 then -- extinguisher
			self:smoke(source)
			if getElementHealth(source) <= (100-10*self.m_Fires[source].Size) and attacker == localPlayer then
				triggerServerEvent("requestFireDeletion", localPlayer, source)
			end
		else
			cancelEvent()
		end
	end
end

function Fire:smoke(ped)
		local playerPos	= localPlayer.position
		local firePos = ped.position
		if getDistanceBetweenPoints3D(playerPos, firePos) < 100 then
			if self.m_Fires[ped] and not self.m_Fires[ped].Smoke or getTickCount()-self.m_Fires[ped].Smoke > 1000 then
				local effect = createEffect("tank_fire", firePos)
				setEffectSpeed(effect, 0.5)
				self.m_Fires[ped].Smoke = getTickCount()
			end
		end
end

function Fire:handlePedWaterCannon(ped)
	cancelEvent()
	if self.m_Fires[ped] then
		if getElementModel(source) == 407 then -- fire truck
			self:smoke(ped)
			if math.random(1, 5) == 1 and getVehicleController(source) == localPlayer then
				triggerServerEvent("requestFireDeletion", localPlayer, ped)
			end
		end
	end
end

function Fire:destroyFire(ped)
	if self.m_Fires[ped] then
		if isElement(self.m_Fires[ped].Effect) then destroyElement(self.m_Fires[ped].Effect) end
		if isElement(self.m_Fires[ped].Colshape) then destroyElement(self.m_Fires[ped].Colshape) end
		self.m_Fires[ped] = nil
		return true
	end
	return false
end
