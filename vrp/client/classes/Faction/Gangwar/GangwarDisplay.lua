-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     Gangwar HUD
-- *
-- ****************************************************************************

GangwarDisplay = inherit(Object)

local w,h = guiGetScreenSize()

function GangwarDisplay:constructor( fac1, fac2, pPart) 
	self.m_Faction1 = fac1
	self.m_Faction2 = fac2 
	self.m_Participants = pPart
	
	self.m_BindRender = bind( self.render,self)
	addEventHandler("onClientRender",root,self.m_BindRender)
end

function GangwarDisplay:render() 
	self:rend_Display()
end

function GangwarDisplay:rend_Display( )
	
end

function GangwarDisplay:destructor()
	removeEventHandler("onClientRender",root,self.m_BindRender) 
end