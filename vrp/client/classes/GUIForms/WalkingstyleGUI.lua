-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/WalkingstyleGUI.lua
-- *  PURPOSE:     Walkingstyle GUI Class
-- *
-- ****************************************************************************

WalkingstyleGUI = inherit(GUIForm)
inherit(Singleton, WalkingstyleGUI)

function WalkingstyleGUI:constructor()
	GUIForm.constructor(self, screenWidth-270, screenHeight/2-500/2, 250, 500, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Laufstile", true, true, self)

	self.m_WalkingstyleList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-60, self.m_Window)
	self.m_WalkingstyleList:addColumn(_"Name", 1)
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, "↕", self.m_Window):setAlignX("right")
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, _"Doppelklick zum Ausführen", self.m_Window):setFont(VRPFont(self.m_Height*0.04)):setAlignY("center"):setColor(Color.Red)

    self.m_WalkingstyleList:addItem("Animationsfenster öffnen").onLeftDoubleClick = function () self.m_Window:close() AnimationGUI:new() end

	local item
	for groupIndex, group in pairs(WALKINGSTYLE_GROUPS) do
		self.m_WalkingstyleList:addItemNoClick(_(group))
		for index, walkingstyle in pairs(WALKINGSTYLES) do
			if walkingstyle["group"] == group then
				item = self.m_WalkingstyleList:addItem(_(("%s%s"):format(index:sub(1, 1):upper(), index:sub(2, #index))))
				item.Name = index
				item.onLeftDoubleClick = function () self:changeWalkingstyle() end
			end
		end
	end
end

function WalkingstyleGUI:changeWalkingstyle()
	if localPlayer:getPrivateSync("AlcoholLevel") == 0 then
	    if WALKINGSTYLES[self.m_WalkingstyleList:getSelectedItem().Name] then
		    ShortMessage:new(_"Laufstil geändert!")
            triggerServerEvent("changeWalkingstyle", localPlayer, self.m_WalkingstyleList:getSelectedItem().Name)
        end
	end
end