-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/CylinderShader.lua
-- *  PURPOSE:     Cylinder shader class 
-- *
-- ****************************************************************************
CylinderShader = inherit(Object)

function CylinderShader:constructor()
	self.m_CylinderShader = dxCreateShader("files/shader/cylinder.fx")
	self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

	self.m_Update = bind(self.update, self)
	addEventHandler("onClientPreRender", root, self.m_Update)
end


function CylinderShader:update()
	if self.m_CylinderShader and self.m_ScreenSource then
		self.m_ScreenSource:update()
		self.m_CylinderShader:setValue("ScreenTexture", self.m_ScreenSource)
		dxDrawImage(0, 0, screenWidth, screenHeight, self.m_CylinderShader)
	end
end

function CylinderShader:destructor()
	if self.m_CylinderShader then
		destroyElement(self.m_CylinderShader)
	end
	if self.m_ScreenSource then
		destroyElement(self.m_ScreenSource)
	end
	removeEventHandler("onClientPreRender", root, self.m_Update)
	self.m_Update = nil
end
