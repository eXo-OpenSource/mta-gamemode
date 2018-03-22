-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/NPC.lua
-- *  PURPOSE:     Shop NPC class (peds in shops)
-- *
-- ****************************************************************************
ShopNPC = inherit(NPC)

function ShopNPC:constructor(skinId, x, y, z, rotation)
	NPC.constructor(self, skinId, x, y, z, rotation)
	self:setFrozen(true)
	self.m_InTarget = false
	self.m_TargettedBy = {}
	self.m_RefreshAttackersFunc = bind(ShopNPC.refreshAttackers, self)

	self:toggleWanteds(true)
end

function ShopNPC:onInternalTargetted(playerBy)
	if playerBy:getWeapon() ~= 0 then
		self.m_TargettedBy[playerBy] = true
	else
		return false
	end
	if not self.m_InTarget and self.onTargetted then -- the npc isn't been targetted
		playerBy:sendWarning(_("Du überfällst den Verkäufer in 5 Sekunden, wenn du weiter auf ihn zielst!", playerBy))

		self:setAnimation("ped", "handsup", -1, false)
		self.m_InTarget = true
		self.m_TargettedBy[playerBy] = true
		local targetTimer = setTimer(function(playerBy)
			if playerBy:getTarget() == self then
				playerBy:sendInfo(_("Ziele mit deinen Komplizen weiter auf den Verkäufer, um immer mehr Geld zu bekommen!", playerBy))
				self.m_StartingPlayer = playerBy
				self:onTargetted(playerBy)
				self.m_RefreshTimer = setTimer(self.m_RefreshAttackersFunc, 1000, 0)
			else
				self.m_InTarget = false
			end
		end, 5000, 1, playerBy)
	end
end

function ShopNPC:refreshAttackers()
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

function ShopNPC:getAttackers()
	return self.m_TargettedBy
end

addEventHandler("onPlayerTarget", root,
function(targettedElement)
	if isElement(targettedElement) and getElementType(targettedElement) == "ped" and targettedElement.onInternalTargetted then
		targettedElement:onInternalTargetted(source)
		--[[if not targettedElement.m_InTarget and source:getWeapon() ~= 0 then
			targettedElement:setAnimation("ped", "handsup", -1, false)
			targettedElement.m_InTarget = true

			if targettedElement.onTargetted then
				source:sendWarning(_("Du überfällst den NPC in 5 Sekunden, wenn du weiter auf ihn zielst!", source))
				local targetTimer = setTimer(function(player)
					if player:getTarget() == targettedElement then
						targettedElement:onTargetted(player)
					end
				end, 5000, 1, source)
			end


			-- Block inTarget for a while | TODO: Optimize this
			setTimer(function(player)
				if not isElement(player) or getElementType(player) ~= "player" or player:getTarget() == false then
					targettedElement.m_InTarget = false
					targettedElement:setAnimation(nil)
					killTimer(sourceTimer)
					if targetTimer and isTimer(targetTimer) then
						killTimer(targetTimer)
					end
				end
			end, 3*1000, 0, source)

		end]]
	end
end
)
