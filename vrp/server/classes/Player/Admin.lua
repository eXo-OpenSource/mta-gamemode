-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Admin = inherit(AdminManager)

function Admin:constructor(player,rank)
	self.m_Player = player
	self.m_Rank = rank
	outputChatBox("Admin Funktionen geladen!",player,255,0,0)
end

function Admin:destructor()

end

