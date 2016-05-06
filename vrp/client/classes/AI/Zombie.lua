Zombie = {}

Zombie.Jumping = {}
-- Functions --

function Zombie.Attack(zomb, bool, target)
	local s = setPedControlState(zomb, "fire", bool)
	setTimer(function()
		setPedControlState(zomb, "fire", false)
	end, 300, 1)
end

function Zombie.Wall(zomb, target)
	local x1, y1, z1 = getElementPosition(zomb)
	local x2, y2, z2 = getElementPosition(target)
	local hit, x3, y3, z3 = processLineOfSight(x1, y1, z1, x2, y2, z2, true, true, false, true, false)
	if(hit) and (Zombie.Jumping[zomb] ~= true) and (getDistanceBetweenPoints3D(x1, y1, z1, x3, y3, z3) < 2) then
		setPedAnimation(zomb)
		setPedControlState(zomb, "jump", true)

		if(getElementData(zomb, "target") == localPlayer) then
			setElementData(zomb, "jumping", true);
		end

		Zombie.Jumping[zomb] = true

		setTimer(function()
			setPedControlState(zomb, "jump", false)
			Zombie.Jumping[zomb] = false
			if(getElementData(zomb, "target") == localPlayer) then
				setElementData(zomb, "jumping", false);
			end
		end, 1500, 1)
	end
end

function Zombie.Damage(attacker, weapon, bodypart)
	if(getElementData(source, "zombie") == true) then
		if(attacker) then
			if(getElementType(attacker) == "player") then
				triggerServerEvent("onZombieHit", source, attacker)
			elseif(getElementType(attacker) == "vehicle") then
				if(getVehicleOccupant(attacker)) and (getElementType(getVehicleOccupant(attacker))) then
					triggerServerEvent("onZombieHit", source, getVehicleOccupant(attacker))
				end
			end
			if(bodypart == 9) then
				setPedHeadless(source, true)
			end
			if(attacker == localPlayer) then
				if bodypart == 9 then
					triggerServerEvent("doZombieWasted", localPlayer, source)
				end
			end
		end
	end
end

function Zombie.spawnPos(x, y, a)
	local z = getGroundPosition(x, y, 100)+0.5
	triggerServerEvent("doSpawnZombie", localPlayer, x, y, z, a)
end


function Zombie.seeCheck(zombie)
	setPedVoice(zombie, "PED_TYPE_DISABLED")

	local x1, y1, z1 = getElementPosition(localPlayer)
	local x2, y2, z2 = getElementPosition(zombie)
	local hit, x3, y3, z3 = processLineOfSight(x1, y1, z1, x2, y2, z2, true, true, false, true, false)

	if(hit) then -- Nope
		triggerServerEvent("onZombieBigColHit", zombie, localPlayer, false)

	else
		local angle = ( 360 - math.deg ( math.atan2 ( ( x1 - x2 ), ( y1-y2 ) ) ) ) % 360

		angle = angle-getPedRotation(zombie)

		if((angle < 100 and angle > 0) or (angle > -100 and angle < 0)) then

			triggerServerEvent("onZombieBigColHit", zombie, localPlayer, true)
		else
			triggerServerEvent("onZombieBigColHit", zombie, localPlayer, false)
		end
	end


end

-- Event Handler --
addRemoteEvents{"onZombieAttack", "onZombieSpawnPosGet", "onZombieWall", "doZombieCanSeeCheck"}

addEventHandler("onZombieAttack", localPlayer, Zombie.Attack)
addEventHandler("onZombieWall", localPlayer, Zombie.Wall)
addEventHandler("onClientPedDamage", getRootElement(), Zombie.Damage)
addEventHandler("onZombieSpawnPosGet", localPlayer, Zombie.spawnPos)
addEventHandler("doZombieCanSeeCheck", localPlayer, Zombie.seeCheck)
