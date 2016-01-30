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
	self.m_BindRender = bind( self.render,self)
	addEventHandler("onClientRender",root,self.m_BindRender)
end

function GangwarDisplay:render() 
	self:rend_Display()
end

function GangwarDisplay:rend_Display( )
	dxDrawRectangle(w*0.5,h*0.5,w*0.1,w*0.1,tocolor(255,255,255,120))
end

function GangwarDisplay:destructor()
	removeEventHandler("onClientRender",root,self.m_BindRender) 
end