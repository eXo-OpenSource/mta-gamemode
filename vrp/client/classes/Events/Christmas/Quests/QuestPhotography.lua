QuestPhotography = inherit(Object)

function QuestPhotography:constructor()
	self.m_TakePhoto = bind(self.onTakePhoto, self)
	addEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_TakePhoto)
end

function QuestPhotography:destructor()
	removeEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_TakePhoto)
end

function QuestPhotography:onTakePhoto(weapon)
	if source == localPlayer and weapon == 43 then
		local players = self:getElementsInPhotograph("player")
		local peds = self:getElementsInPhotograph("ped")
		triggerServerEvent("questPhotograpyTakePhoto", localPlayer, players, peds)
	end

end

function QuestPhotography:getElementsInPhotograph(elementType)
	local elements = {}
	local muzzlePos = Vector3(getPedWeaponMuzzlePosition(localPlayer))

	for _, v in pairs(getElementsByType(elementType, root, true)) do
		if v ~= localPlayer and isElementOnScreen(v) then
			local _, _, _, _, hit = processLineOfSight(muzzlePos, v:getPosition()) -- Check if there is a collision between the "camera viewpoint" and the player
			if hit == v then
				table.insert(elements, v)
			end
		end
	end

	return elements
end
