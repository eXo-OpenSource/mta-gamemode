-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AnimationGUI.lua
-- *  PURPOSE:     Animation GUI Class
-- *
-- ****************************************************************************
AnimationGUI = inherit(GUIForm)
inherit(Singleton, AnimationGUI)

function AnimationGUI:constructor()
	GUIForm.constructor(self, screenWidth-270, screenHeight/2-500/2, 250, 500, true, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Animationen", true, true, self)

	self.m_AnimationList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-70, self)
	self.m_AnimationList:addColumn(_"Name", 1)
	self.m_StartAnimation = GUIButton:new(5, self.m_Height-35, self.m_Width-10, 30, "Animation ausführen", self):setBackgroundColor(Color.Green)
	self.m_StartAnimation.onLeftClick = function() self:startAnimation() end

	local item
	for groupIndex, group in pairs(ANIMATION_GROUPS) do
		self.m_AnimationList:addItemNoClick(_(group))
		for index, animation in pairs(ANIMATIONS) do
			if animation["group"] == group then
				item = self.m_AnimationList:addItem(_(index))
				item.Name = index
				item.onLeftDoubleClick = function () self:startAnimation() end
			end
		end
	end
end

function AnimationGUI:startAnimation()
	triggerServerEvent("startAnimation", localPlayer, self.m_AnimationList:getSelectedItem().Name)
end
