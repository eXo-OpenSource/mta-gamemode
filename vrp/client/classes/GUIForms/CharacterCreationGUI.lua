-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/CharacterCreationGUI.lua
-- *  PURPOSE:     Character Creation GUI
-- *
-- ****************************************************************************
CharacterCreationGUI = inherit(GUIForm)
inherit(Singleton, CharacterCreationGUI)

local CHARACTER_SELECTION_PED_POSITIONS = {
{217.46005249023, -98.559127807617, 1005.2578125, 120};
{217.46005249023, -98.559127807617, 1005.2578125, 120};
}

local CHARACTER_SELECTION_SKINS = {
19, 19, 19, 0 -- fixme: add different skins
}

function CharacterCreationGUI:constructor()
	local sw, sh = guiGetScreenSize()
	self.m_Options = {}
	GUIForm.constructor(self, sw/3*2, sh/5, sw/4, sh/2)
	self.m_Selector = GUIRectangle:new(0, sh*0.06, sw/4, sh/2-sh*0.06, tocolor(0, 0, 0, 128), self)
	self.m_LoginButton = GUIButton:new(0, 0, sw/4, sh*0.06, "Erstelle deinen Charakter", self):setBarEnabled(true)
	GUILabel:new(sw/4*0.05, sh/30*1, (sw/4), sh*0.01, "Dein Name", self.m_Selector):setAlign("left", "top"):setFont(VRPFont(sh*0.05))
	GUILabel:new(sw/4*0.5,  sh/30*1, sw/4*0.5-sw/4*0.05, sh*0.01, "sbx320", self.m_Selector):setAlign("right", "top"):setFont(VRPFont(sh*0.05))
	self.m_SkinLabel = GUILabel:new(sw/4*0.05, sh/30*2, (sw/4), sh*0.01, "Grundskin", self.m_Selector):setAlign("left", "top"):setFont(VRPFont(sh*0.05))
	self.m_SkinIdLabel = GUILabel:new(sw/4*0.5,  sh/30*2, sw/4*0.5-sw/4*0.05, sh*0.01, "19", self.m_Selector):setAlign("right", "top"):setFont(VRPFont(sh*0.05))

	self.m_PlayButton = GUIButton:new(sw/4*0.05, sh/2-sh*0.075, sw/4*0.9, sh*0.05, "Bestätigen", self):setBarEnabled(true)
	self.m_PlayButton.onLeftClick = function()
		local options = {}
		for k, v in pairs(self.m_Options) do
			options[k] = v.id
		end
		triggerServerEvent("finishedCharacterCreation", resourceRoot, tonumber(CHARACTER_SELECTION_SKINS[self.m_CurrentSkinIndex]), options)
		self:delete()

		setElementFrozen(localPlayer, false)
		toggleAllControls(true)
		setCameraTarget(localPlayer)
	end

	self:bind("enter", self.m_PlayButton.onLeftClick)
	self:bind("arrow_l", CharacterCreationGUI.previousSkin)
	self:bind("arrow_r", CharacterCreationGUI.nextSkin)
	self:bind("arrow_d", CharacterCreationGUI.nextOption)
	self:bind("arrow_u", CharacterCreationGUI.previousOption)

	self.m_CurrentLevel = 1;
	self.m_MarkerLevel = 1;

	local skins = CHARACTER_SELECTION_SKINS
	setElementPosition(localPlayer, 217.46005249023, -98.559127807617, 1005.2578125)
	setElementInterior(localPlayer, 15)
	setElementRotation(localPlayer, 0, 0, 120)

	localPlayer.m_Skin = Skin:new(localPlayer)
	localPlayer.m_Skin:enable()

	self.m_CurrentSkinIndex = 1
	self.m_CurrentSkin = CHARACTER_SELECTION_SKINS[self.m_CurrentSkinIndex]
	self:updateView()
	self:updatePed()

	toggleAllControls(false)
end

function CharacterCreationGUI:destructor()
	localPlayer.m_Skin:delete()
	GUIForm.destructor(self)
end

function CharacterCreationGUI:nextSkin()
	self.m_CurrentSkinIndex = self.m_CurrentSkinIndex+1
	if self.m_CurrentSkinIndex > #CHARACTER_SELECTION_SKINS then
		self.m_CurrentSkinIndex = 1
	end
	self.m_CurrentSkin = CHARACTER_SELECTION_SKINS[self.m_CurrentSkinIndex]
	self:updatePed()
end

function CharacterCreationGUI:previousSkin()
	self.m_CurrentSkinIndex = self.m_CurrentSkinIndex-1
	if self.m_CurrentSkinIndex <= 0 then
		self.m_CurrentSkinIndex = #CHARACTER_SELECTION_SKINS
	end
	self.m_CurrentSkin = CHARACTER_SELECTION_SKINS[self.m_CurrentSkinIndex]
	self:updatePed()
end

function CharacterCreationGUI:updatePed()
	setElementModel(localPlayer, self.m_CurrentSkin)
	localPlayer.m_Skin:refresh()

	self.m_SkinIdLabel:setText(tostring(self.m_CurrentSkin))
	for k, v in pairs(self.m_Options) do
		v.name:delete()
		v.id:delete()
	end
	self.m_Options = {}

	if not skindata[self.m_CurrentSkin] then return end

	local sw, sh = guiGetScreenSize()
	for k, v in ipairs(skindata[self.m_CurrentSkin]) do
		self.m_Options[#self.m_Options+1] = {}
		self.m_Options[#self.m_Options].name = GUILabel:new(sw/4*0.05, sh/30*(3+k), (sw/4), 10, v.name, self.m_Selector):setAlign("left", "top"):setFont(VRPFont(sh*0.05))
		self.m_Options[#self.m_Options].id = GUILabel:new(sw/4*0.5, sh/30*(3+k), sw/4*0.5-sw/4*0.05, 10, "1", self.m_Selector):setAlign("right", "top"):setFont(VRPFont(sh*0.05))	-- 1.5
	end
end

function CharacterCreationGUI:nextOption()
	if self.m_CurrentLevel+1 > #self.m_Options+1 then
		return
	end

	if self.m_CurrentLevel == 1 then
		self:unbind("arrow_l", CharacterCreationGUI.previousSkin)
		self:unbind("arrow_r", CharacterCreationGUI.nextSkin)
	else
		self:unbind("arrow_l", CharacterCreationGUI.previousDesign)
		self:unbind("arrow_r", CharacterCreationGUI.nextDesign)
	end

	self.m_CurrentLevel = self.m_CurrentLevel+1

	if self.m_CurrentLevel == 1 then
		self:bind("arrow_l", CharacterCreationGUI.previousSkin)
		self:bind("arrow_r", CharacterCreationGUI.nextSkin)
	else
		self:bind("arrow_l", CharacterCreationGUI.previousDesign)
		self:bind("arrow_r", CharacterCreationGUI.nextDesign)
	end


	self:updateView()
end

function CharacterCreationGUI:previousOption()
	if self.m_CurrentLevel == 1 then return end
	if self.m_CurrentLevel == 1 then
		self:unbind("arrow_l", CharacterCreationGUI.previousSkin)
		self:unbind("arrow_r", CharacterCreationGUI.nextSkin)
	else
		self:unbind("arrow_l", CharacterCreationGUI.previousDesign)
		self:unbind("arrow_r", CharacterCreationGUI.nextDesign)
	end

	self.m_CurrentLevel = self.m_CurrentLevel-1

	if self.m_CurrentLevel == 1 then
		self:bind("arrow_l", CharacterCreationGUI.previousSkin)
		self:bind("arrow_r", CharacterCreationGUI.nextSkin)
	else
		self:bind("arrow_l", CharacterCreationGUI.previousDesign)
		self:bind("arrow_r", CharacterCreationGUI.nextDesign)
	end
	self:updateView()
end

function CharacterCreationGUI:nextDesign()
	local skin = localPlayer.m_Skin
	local index = self.m_CurrentLevel -1
	outputDebug(index)
	local cs = skin:getColorScheme(index)
	local css = skin:getColorSchemes(index)
	cs = cs+1
	if cs > #css then cs = 1 end

	skin:setColorScheme(index, cs)

	self.m_Options[index].id:setText(tostring(cs))
end

function CharacterCreationGUI:previousDesign()
	local skin = localPlayer.m_Skin
	local index = self.m_CurrentLevel -1
	outputDebug(index)
	local cs = skin:getColorScheme(index)
	local css = skin:getColorSchemes(index)
	cs = cs-1
	if cs < 1 then cs = #css end

	skin:setColorScheme(index, cs)

	self.m_Options[index].id:setText(tostring(cs))
end

function CharacterCreationGUI:updateView()
	if self.m_MarkerLevel ~= self.m_CurrentLevel then
		local label = false
		if self.m_MarkerLevel == 1 then
			label = self.m_SkinLabel
		else
			label = self.m_Options[self.m_MarkerLevel-1].name
		end

		if label then
			label:setText(label:getText():sub(2):sub(1, -2))
		end
	end

	self.m_MarkerLevel = self.m_CurrentLevel

	local label = false
	if self.m_MarkerLevel == 1 then
		label = self.m_SkinLabel
	else
		label = self.m_Options[self.m_MarkerLevel-1].name
	end

	if label then
		label:setText("["..label:getText().."]")
	end

	setCameraMatrix(213.65600585938, -101.3125, 1006.4158935547, 214.46043395996, -100.73026275635, 1006.2979736328, 0, 70)
	setCameraInterior(15)
end
