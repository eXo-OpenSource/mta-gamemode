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
	
	self.m_RankNames = {
	[1] = "Ticket-Supporter",
	[2] = "Supporter",
	[3] = "Administrator",
	[4] = "stellv. Projektleiter",
	[5] = "Projektleiter"
	}
	
	addCommandHandler("admins", bind(self.onlineList, self))
	addCommandHandler("a", bind(self.chat, self))
	addCommandHandler("o", bind(self.ochat, self))
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
			outputChatBox("[ "..self.m_RankNames[value].." "..player:getName().." ]: "..msg,key,255,255,0)
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function AdminManager:ochat(player,cmd,...)
	if self:getRank(player) > 2 then
		local rankName = self.m_RankNames[self:getRank(player)]
		local msg = table.concat( {...}, " " )
		outputChatBox("[ "..rankName.." "..player:getName().." ]: "..msg,getRootElement(),50,200,255)
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function AdminManager:onlineList(player)
	
		outputChatBox("Folgende Teammitglieder sind derzeit online:",player,50,200,255)
		for key, value in pairs(self.m_OnlineAdmins) do
			outputChatBox(self.m_RankNames[value].." "..key:getName(),player,255,255,255)
		end

end