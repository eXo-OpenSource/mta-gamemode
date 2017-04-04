-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Achievement.lua
-- *  PURPOSE:     Class for Achievements
-- *
-- ****************************************************************************

Achievement = inherit(Singleton)

function Achievement:constructor ()
	self.ms_Achievements = {}

	addRemoteEvents{"Achievement.sendAchievements", "Achievement.onPlayerReceiveAchievement"}
	addEventHandler("Achievement.sendAchievements", root, bind(self.Event_onReceiveAchievements, self))
	addEventHandler("Achievement.onPlayerReceiveAchievement", root, bind(self.Event_onPlayerReceiveAchievement, self))

	triggerServerEvent("Achievement.onAchievementRequest", root)
end

function Achievement:giveAchievement (player, id)
	if self.ms_Achievements[id] ~= nil then
		triggerServerEvent("Achievement.onPlayerReceiveAchievement", root, player, id)
	end
end

function Achievement:getAchievements()
	return self.ms_Achievements
end

function Achievement:Event_onReceiveAchievements (arg)
	self.ms_Achievements = arg
end

function Achievement:Event_onPlayerReceiveAchievement (id)
	local instance = AchievementBox:new(utf8.escape(_(self.ms_Achievements[id]["name"])), self.ms_Achievements[id]["exp"])
	playSound("files/audio/achievement.mp3")
end
