-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupPropertyGUI.lua
-- *  PURPOSE:     GroupProperty GUI class
-- *
-- ****************************************************************************
GroupPropertyGUI = inherit(GUIForm)
inherit(Object, GroupPropertyGUI)
local cObject
addRemoteEvents{"setPropGUIActive"}
function GroupPropertyGUI:constructor( tObj ) 
	self.m_PropertyTable = tObj
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.5/2, screenWidth*0.4, screenHeight*0.5)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Immobilienpanel", true, true, self)
	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self.m_Window)
	local tabManage = self.m_TabPanel:addTab(_("Verwaltung"))
	self.m_TabManage = tabManage
	self.m_CreateButton = GUIButton:new(self.m_Width*0.25, self.m_Height*0.2, self.m_Width*0.5, self.m_Height*0.1, _"Auf-/Abschließen", tabManage):setBackgroundColor(Color.Orange)
	self.m_CreateButton = GUIButton:new(self.m_Width*0.25, self.m_Height*0.36, self.m_Width*0.5, self.m_Height*0.1, _"Eingangsnachricht", tabManage):setBackgroundColor(Color.Orange)
	self.m_CreateButton = GUIButton:new(self.m_Width*0.25, self.m_Height*0.36, self.m_Width*0.5, self.m_Height*0.1, _"Eingangsnachricht", tabManage):setBackgroundColor(Color.Orange)
	
	local tabAccess = self.m_TabPanel:addTab(_("Berechtigung"))
	self.m_TabAccess = tabAccess
	
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.05, self.m_Width*0.99, self.m_Height*0.14, _"Schlüssel-Berechtigung", tabAccess):setFont(VRPFont(self.m_Height*0.14))
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.2, self.m_Width*0.45, self.m_Height*0.1, _"Name des Spielers:", tabAccess)
	self.m_PlayerEdit = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.2, self.m_Width*0.5, self.m_Height*0.08, tabAccess)
	self.m_KeyAddButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.32, self.m_Width*0.5, self.m_Height*0.08, _"Vergeben", tabAccess):setBackgroundColor(Color.Green)
	self.m_KeyRemoveButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.42, self.m_Width*0.5, self.m_Height*0.08, _"Abnehmen", tabAccess):setBackgroundColor(Color.Red)
	self.m_KeyAddButton.onLeftClick = function() triggerServerEvent("KeyChangeAction",localPlayer, self.m_PlayerEdit:getDrawnText(),"add") end
	self.m_KeyRemoveButton.onLeftClick = function() triggerServerEvent("KeyChangeAction", localPlayer, self.m_PlayerEdit:getDrawnText(),"remove") end
	self.m_KeyGrid = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.32, self.m_Width*0.42, self.m_Height*0.5, tabAccess)
	self.m_KeyGrid:addColumn(_"Spieler mit Schlüssel", 1)
	
	
	local tabInfo = self.m_TabPanel:addTab(_("Information"))
	self.m_TabInfo = tabInfo
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.1, self.m_Width*0.65, self.m_Height*0.10, _"Information", tabInfo):setFont(VRPFont(self.m_Height*0.12))
	self.m_ForceCloseFunc = bind( GroupPropertyGUI.forceClose, self)
end

function GroupPropertyGUI:destructor()

end

function GroupPropertyGUI:forceClose() 
	delete( cObject )
end


addEventHandler("setPropGUIActive",localPlayer,function( tObj) 
	if not cObject then 
		cObject = GroupPropertyGUI:new( tObj )
		cObject:setVisible(false)
	else 
		unbindKey("f6","up",cObject.m_toggleFunc)
		cObject:delete()
	end
	cObject.m_toggleFunc = bind(GroupPropertyGUI.toggle,cObject)
	bindKey("f6","up",cObject.m_toggleFunc)
end
)

function GroupPropertyGUI:toggle( )
	self:setVisible(not self:isVisible())
end