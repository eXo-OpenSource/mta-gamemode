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
		local players = self:getPlayersInPhotograph()
		if #players >= 10 then
			triggerServerEvent("questPhotograpyTakePhoto", localPlayer, players)
		end
		ShortMessage:new(_("Auf diesem Foto sind %d/10 Spieler!", #players))
	end

end

function QuestPhotography:getPlayersInPhotograph()
	local players = {}
	local nx, ny, nz = getPedWeaponMuzzlePosition(localPlayer)

	for _, v in ipairs(getElementsByType"player") do

                -- Determine whether the player is even on the screen, or the client is the player.
		if (v ~= localPlayer) and (isElementOnScreen(v)) then
			local veh = getPedOccupiedVehicle(v)
			local px, py, pz = getElementPosition(v)
			local _, _, _, _, hit = processLineOfSight(nx, ny, nz, px, py, pz) -- Check if there is a collision between the "camera viewpoint" and the player
			local continue = false

			if (hit == v) or (hit == veh) or (not veh) then -- If it collides with the player itself, the client or the players vehicle, continue to add player to the list.
				continue = true
			else -- This checks if the player's head is visible, but not the entire body
				local bx, by, bz = getPedBonePosition(v, 8) -- Get the head position of the player
				local _, _, _, _, hit = processLineOfSight(nx, ny, nz, px, py, pz) -- Check if there is a collision between the "camera viewpoint" and player head.

				if hit == v then
					continue = true
				end
			end

			if continue then
				table.insert(players, v)
			end
		end
	end

	return players
end
