-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MiamiSpawnGUI.lua
-- *  PURPOSE:     Artistic Miami Spawn GUI class
-- *
-- ****************************************************************************
MiamiSpawnGUI = inherit(GUIForm)


function MiamiSpawnGUI:constructor()
	addEventHandler("Event_StartScreen", localPlayer, bind( MiamiSpawnGUI.Event_InitScreen, self))
end

function MiamiSpawnGUI:Event_InitScreen()
	GUIForm.constructor(self, 0,0,screenWidth, screenHeight)
	fadeCamera(false,0.5,0,0,0)
	self.m_StartTick = getTickCount()
	self.m_EndTick = self.m_StartTick + 2000
	self.m_Duration = self.m_EndTick - self.m_StartTick 
	addEventHandler("onClientRender", root, bind( MiamiSpawnGUI._Render, self))
end

function MiamiSpawnGUI:_Render()
	local now = getTickCount()
	local elap = now - self.m_StartTick
	local prog = elap / self.m_Duration
	local height, height2, width = interpolateBetween( -1*screenHeight*0.1,screenHeight*1.1, 0, screenHeight*0.4,screenHeight*0.4,screenWidth*0.3, prog, "Linear")
	dxDrawText("CLOCK",0,height,screenWidth, screenHeight, tocolor(255, 255, 255, 255), 1, "default", "center", "top")
end

addCommandHandler("miami", function() 
	MiamiSpawnGUI:new():Event_InitScreen()
end)