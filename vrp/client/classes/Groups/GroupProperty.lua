-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Player/GroupProperty.lua
-- *  PURPOSE:     GroupProperty
-- *
-- ****************************************************************************
GroupProperty = inherit( Singleton )
local w,h = guiGetScreenSize()
local width = w*0.18
local height = h*0.12
local sx = 0
local sy = h*0.5-height/2
local fontHeight = dxGetFontHeight(1,"default-bold")
addRemoteEvents{"showGroupEntrance", "hideGroupEntrance","createGroupBlip","destroyGroupBlip","addPickupToGroupStream","groupEntryMessage"}
function GroupProperty:constructor( )
	self.m_BlipProperties = {}
	self.m_BlipProperties2 = {}
	self.m_MarkerProperties = {}
	self.m_StreamCheckPickups = {}
	addEventHandler("createGroupBlip", localPlayer, bind( GroupProperty.createBlips, self) )
	addEventHandler("destroyGroupBlip", localPlayer, bind( GroupProperty.destroyBlips, self) )


	addEventHandler("addPickupToGroupStream", localPlayer, bind( GroupProperty.addPickupToStream, self) )
	addEventHandler("groupEntryMessage",localPlayer,bind(GroupProperty.showEntryMessage,self))

end

function GroupProperty:addPickupToStream( pickup, id )
	self.m_StreamCheckPickups[pickup] = id
	addEventHandler("onClientElementStreamIn",pickup,bind(GroupProperty.requestImmoPanel,self))
	addEventHandler("onClientElementStreamOut",pickup,bind(GroupProperty.requestImmoPanelClose,self))
	if isElementStreamedIn( pickup ) then
		self:requestImmoPanel( pickup )
	end
end

function GroupProperty:requestImmoPanel( pickup )
	if not source then source = pickup end
	if self.m_StreamCheckPickups[source] then
		localPlayer:setData("insideGroupInterior",true) -- setData not syncing
		triggerServerEvent("requestImmoPanel",localPlayer,self.m_StreamCheckPickups[source])
	end
end

function GroupProperty:requestImmoPanelClose( )
	localPlayer:setData("insideGroupInterior",false, true)
	GroupPropertyGUI.disable()
end


--triggerServerEvent("GroupPropertyClientInput", localPlayer)

function GroupProperty:createBlips( x, y, z, id, groupType)
	self.m_BlipProperties[id] =  Blip:new("House.png", x, y, 500, groupType == "Firma" and {50, 200, 255} or {178, 35, 33})
	self.m_BlipProperties[id]:setDisplayText(groupType == "Firma" and "Firmensitz" or "Gangversteck")
	self.m_BlipProperties[id]:setZ(z)
end

function GroupProperty:destroyBlips( id )
	if self.m_BlipProperties[id] then
		delete(self.m_BlipProperties[id])
	end

end

function GroupProperty:showEntryMessage( text )
	if not self.m_MessageDisplayed then
		self.m_Message = GroupPropertyEntryMessageGUI:new(text)
		self.m_MessageDisplayed = true
	end
end

function GroupProperty:destroyMessage()
	if self.m_Message then
		delete(self.m_Message)
		self.m_MessageDisplayed = false
	end
end

GroupPropertyEntryMessageGUI = inherit(GUIForm)
inherit(Singleton, GroupPropertyEntryMessageGUI)

function GroupPropertyEntryMessageGUI:constructor(text)
	GUIForm.constructor(self, 0,0,w*0.9,h*0.9)
	self.m_Message = GUILabel:new( 0,0,w*0.9,h*0.9, text, self):setAlignX("right"):setAlignY("bottom"):setFont(RageFont(h*0.1))
	showCursor(false)
	Animation.FadeAlpha:new(self.m_Message, 1000, 0, 255)
	setTimer(function()
		delete(self)
	end, 2500, 1)
end
