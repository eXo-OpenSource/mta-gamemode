-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Admin.lua
-- *  PURPOSE:     Admin class
-- *
-- ****************************************************************************
Admin = inherit(Singleton)

function Admin:constructor()
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
	outputDebugString("Admin loaded")
end

function Admin:destructor()

end

function Admin:addAdmin(player,rank)
	outputDebugString("Added Admin "..player:getName())
	self.m_OnlineAdmins[player] = rank
end

function Admin:getRank(player)
	return self.m_OnlineAdmins[player]
end

function Admin:removeAdmin(player)
	self.m_OnlineAdmins[player] = nil
end

function Admin:chat(player,cmd,...)
	if self:getRank(player) > 0 then
		local msg = table.concat( {...}, " " )
		for key, value in pairs(self.m_OnlineAdmins) do
			outputChatBox("[ "..self.m_RankNames[value].." "..player:getName().." ]: "..msg,key,255,255,0)
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:ochat(player,cmd,...)
	if self:getRank(player) > 2 then
		local rankName = self.m_RankNames[self:getRank(player)]
		local msg = table.concat( {...}, " " )
		outputChatBox("[ "..rankName.." "..player:getName().." ]: "..msg,getRootElement(),50,200,255)
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:onlineList(player)
	
		outputChatBox("Folgende Teammitglieder sind derzeit online:",player,50,200,255)
		for key, value in pairs(self.m_OnlineAdmins) do
			outputChatBox(self.m_RankNames[value].." "..key:getName(),player,255,255,255)
		end

end