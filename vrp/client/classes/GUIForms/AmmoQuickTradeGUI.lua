-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AmmoQuickTradeGUI.lua
-- *  PURPOSE:     AmmoQuickTradeGUI Class
-- *
-- ****************************************************************************
AmmoQuickTradeGUI = inherit(GUIForm)
inherit(Singleton, AmmoQuickTradeGUI)

function AmmoQuickTradeGUI:constructor(player)
	if player == localPlayer then delete(self) end
	GUIWindow.updateGrid()			
	self.m_Width = grid("x", 16) 	
	self.m_Height = grid("y", 3) 	

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Munition/Schutzweste vergeben!", true, true, self)
	
	GUIGridRectangle:new(1, 1, 14, 2, Color.Grey, self.m_Window)
	self.m_Label = GUIGridLabel:new(1, 1, 14, 2, "50% der Munition", self.m_Window):setAlign("center", "top"):setColor(Color.Accent)
	self.m_LabelBot = GUIGridLabel:new(1, 1, 14, 2, "Aktuelle Waffe: %s", self.m_Window):setAlign("center", "bottom"):setColor(Color.Accent)
	self.m_AmmoAmount = GUIGridSlider:new(1, 1, 14, 2, self.m_Window):setRange(0, 100):setValue(50)
	self.m_AmmoAmount.onUpdate = bind(self.Event_onSliderChange, self)
	self.m_Element = player
	self.m_ButtonMunition = GUIGridIconButton:new(15, 1, FontAwesomeSymbols.Double_Right, self.m_Window):setTooltip("Aktuelle Munition vergeben!", "bottom")
	self.m_ButtonMunition.onLeftClick = 
	function() 
		QuestionBox:new(
		_("Möchtest du %s deiner Munition für deine aktuelle Waffe vergeben?", ("%s%%"):format(math.ceil(self.m_AmmoAmount:getInternalRelativeValue()*100))),
		function ()
			delete(self)
			triggerServerEvent("PlayerManager:onRequestQuickTrade", localPlayer, false, self.m_Element, self.m_AmmoAmount:getInternalRelativeValue())
		end,
		function ()

		end)	
	end
	self.m_ButtonArmor = GUIGridIconButton:new(15, 2, FontAwesomeSymbols.Shield, self.m_Window):setColor(Color.White):setBackgroundColor(Color.LightGrey):setTooltip("Schutzweste vergeben!", "bottom")
	self.m_ButtonArmor.onLeftClick = 
	function() 
		QuestionBox:new(
		_("Möchtest du %s deiner Schutzweste vergeben?", ("%s%%"):format(math.ceil(self.m_AmmoAmount:getInternalRelativeValue()*100))),
		function ()
			delete(self)
			triggerServerEvent("PlayerManager:onRequestQuickTrade", localPlayer, true, self.m_Element)
		end,
		function ()
				
		end)	
	end
	self.m_LabelBot:setText(("%d von %s"):format(math.floor(getPedTotalAmmo(localPlayer)*self.m_AmmoAmount:getInternalRelativeValue()), WEAPON_NAMES[localPlayer:getWeapon()]))
end

function AmmoQuickTradeGUI:Event_onSliderChange()
	self.m_Label:setText(("%s%% der Munition"):format(math.ceil(self.m_AmmoAmount:getInternalRelativeValue()*100)))
	self.m_LabelBot:setText(("%d von %s"):format(math.floor(getPedTotalAmmo(localPlayer)*self.m_AmmoAmount:getInternalRelativeValue()), WEAPON_NAMES[localPlayer:getWeapon()]))
end

function AmmoQuickTradeGUI:destructor()
	GUIForm.destructor(self)
end
