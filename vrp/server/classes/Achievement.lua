-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Achievement.lua
-- *  PURPOSE:     Class for Achievements
-- *
-- ****************************************************************************
Achievement = inherit(Singleton)

Achievement.Client = {
	[10] = true, -- Traumland
	[26] = true, -- Hartzer
	[43] = true, -- Baumtänzer
	[49] = true, -- Le Easteregg
	[57] = true, -- Onanieren auf Obdachlosen
	[72] = true, -- JSON Placeholder
	[77] = true, -- Doge
	[79] = true, -- Scream
	[82] = true, -- German Lua Style
	[84] = true, -- Mausrad Overheating
	[85] = true, -- Mausrad Destroyer
	[86] = true, -- Tardis
	--[87] = true, -- April Fools 2k17
	[92] = true, -- Ramme ein Osterei
}

function Achievement:constructor()
	local row = sql:queryFetch("SELECT * FROM ??_achievements WHERE enabled = 1;", sql:getPrefix())
	if not row then
		delete(Achievement)
		return false;
	end

	self.ms_Achievements = {}
	for i, v in ipairs(row) do
		self.ms_Achievements[v.id] = v;
	end

	addRemoteEvents{"Achievement.onAchievementRequest", "Achievement.onPlayerReceiveAchievement"}
	addEventHandler("Achievement.onAchievementRequest", root, bind(self.Event_onRequestAchievements, self))
	addEventHandler("Achievement.onPlayerReceiveAchievement", root, bind(self.Event_onPlayerReceiveAchievement, self))
end

function Achievement:giveAchievement(player, id)
	if self.ms_Achievements[id] ~= nil then
		if not player:isLoggedIn() then return end
		if not player:getAchievementStatus(id) then
			player:setAchievementStatus(id, true)
			player:givePoints(self.ms_Achievements[id]["exp"])

			if player:isActive() then
				player:triggerEvent("Achievement.onPlayerReceiveAchievement", id)
			end
		end
	else
		outputDebug("Missing Achievement in Database. ID: "..id)
		return false
	end
end

function Achievement:Event_onRequestAchievements()
	client:triggerEvent("Achievement.sendAchievements", self.ms_Achievements)
end

function Achievement:Event_onPlayerReceiveAchievement(player, id)
	if Achievement.Client[id] then
		self:giveAchievement(player, id)
	end
end

-- Custom Achievements
Achievements = {}
Achievements.events = {}

Achievements["PewPew"] = function(player) --Achievement ID: 98
	if not player:getAchievementStatus(98) then
		player:giveAchievement(98)
		player:triggerEvent("renderPewPewAchievement")
	end
end

Achievements.events["onPlayerWasted"] = function (_, attacker, weapon) -- Achievement ID: 3, 39
	if attacker and getElementType(attacker) == "player" and attacker ~= source then
		if attacker:getRank() == RANK.Developer then
			source:giveAchievement(3)
		--elseif (attacker:getName() == "Revelse") and (weapon >= 0 and weapon <= 7 and weapon ~= 4) then
		--	source:giveAchievement(39)
		end
	end
end

addEventHandler("onPlayerWasted", root, Achievements.events["onPlayerWasted"])
