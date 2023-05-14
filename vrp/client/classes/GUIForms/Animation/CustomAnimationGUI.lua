-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/CustomAnimationGUI.lua
-- *  PURPOSE:     Custom Animation GUI Form
-- *
-- ****************************************************************************
CustomAnimationGUI = inherit(GUIForm)
inherit(Singleton, CustomAnimationGUI)

function CustomAnimationGUI:constructor()
	GUIForm.constructor(self, screenWidth-270, screenHeight/2-500/2, 250, 500, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Custom Animationen", true, true, self)

	self.m_CustomAnimationList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-60, self.m_Window)
	self.m_CustomAnimationList:addColumn(_"Name", 1)
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, _"Doppelklick zum Ausführen", self.m_Window):setFont(VRPFont(self.m_Height*0.04)):setAlignY("center"):setColor(Color.Red)

    self.m_CustomAnimationList:addItem("Animationsfenster öffnen").onLeftDoubleClick = function () self.m_Window:close() AnimationGUI:new() end

    local item
    for groupIndex, group in pairs(CUSTOM_ANIMATION_GROUPS) do
        self.m_CustomAnimationList:addItemNoClick(_(group))
        for index, animation in pairs(CUSTOM_ANIMATIONS) do
            if animation["group"] == group then
                item = self.m_CustomAnimationList:addItem(_(("%s%s"):format(index:sub(1, 1):upper(), index:sub(2, #index))))
                item.Name = index
                item.onLeftDoubleClick = function () self:startAnimation() end
            end
        end
    end
end

function CustomAnimationGUI:startAnimation()
    local animation = self.m_CustomAnimationList:getSelectedItem().Name
    CustomAnimationManager:getSingleton():startAnimation(_, animation)
end
