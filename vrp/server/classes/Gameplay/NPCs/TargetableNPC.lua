-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/NPCs/TargetableNPC.lua
-- *  PURPOSE:     Targetable NPC class (peds in shops etc.)
-- *
-- ****************************************************************************
TargetableNPC = inherit(NPC)

function TargetableNPC:constructor(skinId, x, y, z, rotation)
	NPC.constructor(self, skinId, x, y, z, rotation)
	self:setFrozen(true)
	self.m_InTarget = false
	self.m_IsTargetAble = true
	self.m_TargettedBy = {}
	self.m_RefreshAttackersFunc = bind(self.refreshAttackers, self)
	self.m_Warning = "Du überfällst den Verkäufer in 5 Sekunden, wenn du weiter auf ihn zielst!"
	self:toggleWanteds(true)
end

function TargetableNPC:onInternalTargetted(playerBy)
	if not self.m_IsTargetAble then
		return false
	end

	if not NO_MUNITION_WEAPONS[playerBy:getWeapon()] and not THROWABLE_WEAPONS[playerBy:getWeapon()] then
		self.m_TargettedBy[playerBy] = true
	else
		return false
	end

	if not self.m_InTarget and self.onTargetted then -- the npc isn't been targetted
		playerBy:sendWarning(self.m_Warning)

		self:setAnimation("ped", "handsup", -1, false)
		self.m_InTarget = true
		self.m_TargettedBy[playerBy] = true
		local targetTimer = setTimer(function(playerBy)
			if isElement(playerBy) then -- if the player went offline
				if playerBy:getTarget() == self then
					self.m_StartingPlayer = playerBy
					self:onTargetted(playerBy)
					self.m_RefreshTimer = setTimer(self.m_RefreshAttackersFunc, 1000, 0)
				else
					self:setAnimation()
					self.m_InTarget = false
				end
			end
		end, 5000, 1, playerBy)
	end
end

function TargetableNPC:setTargetAble(state)
	self.m_IsTargetAble = state
	if self.m_InTarget then
		self:setAnimation()
	end
	self.m_InTarget = false
end

function TargetableNPC:refreshAttackers()
	if not self.m_IsTargetAble then
		return false
	end

	local count = 0
	for player in pairs(self.m_TargettedBy) do
		if player and isElement(player) and getElementType(player) == "player" and player:getTarget() == self then
			count = count + 1
		else
			self.m_TargettedBy[player] = nil
			return self:refreshAttackers() -- lazy way to do the loop again
		end
	end
	if count == 0 then
		-- disable targetting
		outputDebug("targetting finished")
		self.m_InTarget = false
		self:setAnimation()
		self.m_StartingPlayer = nil
		if isTimer(self.m_RefreshTimer) then killTimer(self.m_RefreshTimer) end
	else
		-- return amount of players targetting
		if self.onTargetRefresh then
			self.onTargetRefresh(count, self.m_StartingPlayer)
		end
		outputDebug("refreshed attackers: ", count)
		return count
	end
end

function TargetableNPC:getAttackers()
	return self.m_TargettedBy
end

addEventHandler("onPlayerTarget", root,
	function(targettedElement)
		if isElement(targettedElement) and getElementType(targettedElement) == "ped" and instanceof(targettedElement, TargetableNPC) then
			targettedElement:onInternalTargetted(source)
		end
	end
)
