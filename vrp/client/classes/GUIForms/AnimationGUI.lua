-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AnimationGUI.lua
-- *  PURPOSE:     Animation GUI Class
-- *
-- ****************************************************************************
AnimationGUI = inherit(GUIForm)
inherit(Singleton, AnimationGUI)
addRemoteEvents{"onClientAnimationStop"}

function AnimationGUI:constructor()
	GUIForm.constructor(self, screenWidth-270, screenHeight/2-500/2, 250, 500, true, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Animationen", true, true, self)

	self.m_AnimationList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-60, self)
	self.m_AnimationList:addColumn(_"Name", 1)
	--self.m_StartAnimation = GUIButton:new(5, self.m_Height-35, self.m_Width-10, 30, "Animation ausführen", self):setBackgroundColor(Color.Green)
	--self.m_StartAnimation.onLeftClick = function() self:startAnimation() end
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, "↕", self.m_Window):setAlignX("right")
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, _"Doppelklick zum Ausführen", self.m_Window):setFont(VRPFont(self.m_Height*0.04)):setAlignY("center"):setColor(Color.Red)

	local item
	for groupIndex, group in pairs(ANIMATION_GROUPS) do
		self.m_AnimationList:addItemNoClick(_(group))
		for index, animation in pairs(ANIMATIONS) do
			if animation["group"] == group then
				item = self.m_AnimationList:addItem(_(("%s%s"):format(index:sub(1, 1):upper(), index:sub(2, #index))))
				item.Name = index
				item.onLeftDoubleClick = function () self:startAnimation() end
			end
		end
	end

	-- Events
	self.m_InfoMessage = false
	addEventHandler("onClientAnimationStop", root, bind(self.onAnimationStop, self))
end

function AnimationGUI:startAnimation()
	if localPlayer:getData("isTasered") then return end
	if localPlayer.vehicle then return end
	if localPlayer:isOnFire() then return end
	
	if ANIMATIONS[self.m_AnimationList:getSelectedItem().Name] then
		if not self.m_InfoMessage then
			self.m_InfoMessage = ShortMessage:new(_"Benutze 'Leertaste' zum Beenden der Animation!", -1)
		end
		local animation = self.m_AnimationList:getSelectedItem().Name
		triggerServerEvent("startAnimation", localPlayer, animation)
		for i, v in ipairs(Element.getAllByType("object", root, true)) do -- to short the loop use only streamedin objects
			if v:getModel() == 656 and math.abs((localPlayer.position - v.position).length) <= 2 then
				if animation == "Tanz Chill" then
					localPlayer:giveAchievement(43)
					return
				end
			end
		end
		for i, v in ipairs(Element.getAllByType("ped", root, true)) do
			if v:getData("BeggarId") ~= nil and math.abs((localPlayer.position - v.position).length) <= 1 then
				if animation == "Wichsen" then
					localPlayer:giveAchievement(57)
					return
				end
			end
		end
	end
end

function AnimationGUI:onAnimationStop()
	if self.m_InfoMessage then
		delete(self.m_InfoMessage)
	end
end
