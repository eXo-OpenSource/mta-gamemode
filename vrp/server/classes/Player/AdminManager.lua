-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/AdminManager.lua
-- *  PURPOSE:     Admin manager class
-- *
-- ****************************************************************************
AdminManager = inherit(Singleton)

function AdminManager:constructor()
  self.m_Admins = {}
	addCommandHandler("a", bind(self.chat, self))
	outputDebugString("AdminManager loaded")
end

function AdminManager:destructor()

end

function AdminManager:addAdmin(player)
	outputDebugString("Added Admin "..player:getName())
	Admin:new(player,player:getRank())
	--self.m_Admins[player] = true
end

function AdminManager:removeAdmin(player)
	self.m_Admins[player] = nil
end

function AdminManager:chat(player,cmd,...)
	local msg = {...}
	for key, value in pairs(self.m_Admins) do
		outputChatBox("[ADMIN] "..player:getName()..": "..msg,value,255,255,0)
	end
end