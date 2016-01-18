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
	
	self.m_RankNames = RANK
	
	addCommandHandler("admins", bind(self.onlineList, self))
	addCommandHandler("a", bind(self.chat, self))
	addCommandHandler("o", bind(self.ochat, self))
	outputDebugString("Admin loaded")
end

function Admin:destructor()
	removeCommandHandler("admins", bind(self.onlineList, self))
	removeCommandHandler("a", bind(self.chat, self))
	removeCommandHandler("o", bind(self.ochat, self))
end

function Admin:addAdmin(player,rank)
	outputDebugString("Added Admin "..player:getName())
	self.m_OnlineAdmins[player] = rank
end

function Admin:removeAdmin(player)
	self.m_OnlineAdmins[player] = nil
end

function Admin:chat(player,cmd,...)
	if player:getRank() > 0 then
		local msg = table.concat( {...}, " " )
		local rankName = self.m_RankNames[player:getRank()]
		for key, value in pairs(self.m_OnlineAdmins) do
			outputChatBox(("[%s %s]: %s"):format(_(rankName, player), player:getName(), msg), key, 255, 255, 0)
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:ochat(player,cmd,...)
	if player:getRank() > 2 then
		local rankName = self.m_RankNames[player:getRank()]
		local msg = table.concat( {...}, " " )
		outputChatBox(("[%s %s]: %s"):format(_(rankName, player), player:getName(), msg), root, 50, 200, 255)
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