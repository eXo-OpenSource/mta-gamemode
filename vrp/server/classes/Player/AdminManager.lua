-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/AdminManager.lua
-- *  PURPOSE:     Admin manager class
-- *
-- ****************************************************************************
AdminManager = inherit(Singleton)

function AdminManager:constructor()
  self.m_OnlineAdmins = {}
	addCommandHandler("admins", bind(self.onlineList, self))
	addCommandHandler("a", bind(self.chat, self))
	outputDebugString("AdminManager loaded")
end

function AdminManager:destructor()

end

function AdminManager:addAdmin(player,rank)
	outputDebugString("Added Admin "..player:getName())
	self.m_OnlineAdmins[player] = rank
end

function AdminManager:getRank(player)
	return self.m_OnlineAdmins[player]
end

function AdminManager:removeAdmin(player)
	self.m_OnlineAdmins[player] = nil
end

function AdminManager:chat(player,cmd,...)
	if self:getRank(player) > 0 then
		local msg = table.concat( {...}, " " )
		for key, value in pairs(self.m_OnlineAdmins) do
			outputChatBox("[ADMIN] "..player:getName()..": "..msg,key,255,255,0)
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function AdminManager:onlineList(player)
	
		outputChatBox("Folgende Teammitglieder sind derzeit online:",player,50,200,255)
		for key, value in pairs(self.m_OnlineAdmins) do
			outputChatBox("Rang "..value..": "..key:getName(),player,255,255,255)
		end

end