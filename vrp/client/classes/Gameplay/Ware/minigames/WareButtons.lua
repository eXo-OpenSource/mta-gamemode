-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplayer/Ware/minigames/WareButtons.lua
-- *  PURPOSE:     WareButtons
-- *
-- ****************************************************************************
WareButtons = inherit(Singleton)

addRemoteEvents{"setWareButtonsListenerOn","setWareButtonsListenerOff"}
function WareButtons:constructor()
	addEventHandler("setWareButtonsListenerOn", localPlayer, bind(self.Event_ListenerOn,self))
	addEventHandler("setWareButtonsListenerOff", localPlayer, bind(self.Event_ListenerOff,self))
end

function WareButtons:Event_ListenerOn(amount)
	self.m_Form = WareButtonsForm:new(amount)
	showCursor(true)
end

function WareButtons:Event_ListenerOff()
	if self.m_Form then delete(self.m_Form) end
	showCursor(false)
end

WareButtonsForm = inherit(GUIForm)
inherit(Singleton, WareButtonsForm)

function WareButtonsForm:constructor(amount)
	GUIForm.constructor(self, 0, 0, screenWidth, screenHeight*0.6, false)
	showCursor(true)
	self.m_Buttons = {}
	for i=1, amount do
		self.m_Buttons[i] = GUIButton:new(math.random(0, self.m_Width-300), math.random(0, self.m_Height-30), 300, 30, _("Button %d", i), self)
		self.m_Buttons[i].onLeftClick = function()
			delete(self.m_Buttons[i])
			triggerServerEvent("Ware:clientButtonPress", localPlayer, i)
		end
	end
end
