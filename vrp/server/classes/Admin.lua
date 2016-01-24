-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/House.lua
-- *  PURPOSE:     Serverside admin class
-- *
-- ****************************************************************************

AdminSystem	= inherit(Object)

function AdminSystem:constructor( ) 
	self.m_CMD_show = bind(self.openAdminMenu, self)
	addCommandHandler("adminmenu", self.m_CMD_show)
end

function AdminSystem:openAdminMenu( player ) 
	player:triggerEvent("showAdminMenu")
end


AdminSystem:new( )