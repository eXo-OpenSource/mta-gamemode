CharacterCreationGUI = inherit(GUIForm)
inherit(Singleton, CharacterCreationGUI)

local CHARACTER_SELECTION_PED_POSITIONS = {
{1566.440918, -1374.292114, 190.789063, 273};
{1566.781006, -1370.144531, 190.789063, 273};
{1569.722046, -1365.911987, 190.783386, 245};
{1571.086182, -1362.996094, 190.789063, 245};
{1572.439697, -1360.476074, 190.789063, 245};
{1572.527222, -1356.963135, 190.789063, 276};
{1572.689819, -1354.394775, 190.789063, 276};
}

local CHARACTER_SELECTION_SKINS = {
19, 19, 19, 0 -- fixme: add different skins
}

function CharacterCreationGUI:constructor()	
	local sw, sh = guiGetScreenSize()
	self.m_Options = {}
	GUIForm.constructor(self, sw/3*2, sh/5, sw/4, sh/2)
	self.m_Selector = GUIRectangle:new(0, sh*0.06, sw/4, sh/2-sh*0.06, tocolor(0, 0, 0, 128), self)
	self.m_LoginButton 		= VRPButton:new(0, 0, sw/4, sh*0.06, "Erstelle deinen Charakter", true, self)
	GUILabel:new(sw/4*0.05, sh/30*1, (sw/4), 10, "Dein Name", 1.5, self.m_Selector):setAlign("left", "top")	
	GUILabel:new(sw/4*0.5,  sh/30*1, sw/4*0.5-sw/4*0.05, 10, "sbx320", 1.5, self.m_Selector):setAlign("right", "top")	
	GUILabel:new(sw/4*0.05, sh/30*2, (sw/4), 10, "Grundskin", 1.5, self.m_Selector):setAlign("left", "top")		
	self.m_SkinIdLabel = GUILabel:new(sw/4*0.5,  sh/30*2, sw/4*0.5-sw/4*0.05, 10, "19", 1.5, self.m_Selector):setAlign("right", "top")
	
	
	self:bind("arrow_l", CharacterCreationGUI.previousPed)
	self:bind("arrow_r", CharacterCreationGUI.nextPed)
	self:bind("arrow_d", CharacterCreationGUI.nextOption)
	self:bind("arrow_u", CharacterCreationGUI.previousOption)
	
	self.m_CurrentLevel = 1;
	
	local skins = CHARACTER_SELECTION_SKINS
	self.m_Peds = {}
	for k, id in pairs(skins) do
		local x, y, z, rz = unpack(CHARACTER_SELECTION_PED_POSITIONS[k])
		self.m_Peds[#self.m_Peds+1] = createPed(id, x, y, z)
		setElementRotation(self.m_Peds[#self.m_Peds], 0, 0, rz)
		self.m_Peds[#self.m_Peds].m_ColorScheme = 1
	end
	
	for k, v in pairs(self.m_Peds) do
		v.m_Skin = Skin:new(v)
		v.m_Skin:enable()
	end
	self.m_CurrentView = math.ceil(#skins/2)
	self.m_CurrentSkin = CHARACTER_SELECTION_SKINS[self.m_CurrentView]
	self:updateView()
	self:updatePed()
end

function CharacterCreationGUI:destructor()
	for k, v in pairs(self.m_Peds) do
		v.m_Skin:delete()
		destroyElement(v)
	end
	
	if self.m_Cutscene then
		self.m_Cutscene:delete()
	end
end

function CharacterCreationGUI:nextPed()
	self.m_CurrentView = self.m_CurrentView+1
	if self.m_CurrentView > #self.m_Peds then
		self.m_CurrentView = 1
	end
	self.m_CurrentSkin = CHARACTER_SELECTION_SKINS[self.m_CurrentView]
	self:updateView()
	self:updatePed()
end

function CharacterCreationGUI:previousPed()
	self.m_CurrentView = self.m_CurrentView-1
	if self.m_CurrentView <= 0 then
		self.m_CurrentView = #self.m_Peds
	end
	self.m_CurrentSkin = CHARACTER_SELECTION_SKINS[self.m_CurrentView]
	self:updateView()
	self:updatePed()
end

function CharacterCreationGUI:updatePed()
	self.m_SkinIdLabel:setText(tostring(self.m_CurrentSkin))
	for k, v in pairs(self.m_Options) do
		v:delete()
	end
	self.m_Options = {}
	
	if not skindata[self.m_CurrentSkin] then return end
	
	local sw, sh = guiGetScreenSize()
	for k, v in ipairs(skindata[self.m_CurrentSkin]) do
		self.m_Options[#self.m_Options+1] = GUILabel:new(sw/4*0.05, sh/30*(3+k), (sw/4), 10, v.name, 1.5, self.m_Selector):setAlign("left", "top")	
		self.m_Options[#self.m_Options+1] = GUILabel:new(sw/4*0.5, sh/30*(3+k), sw/4*0.5-sw/4*0.05, 10, "1", 1.5, self.m_Selector):setAlign("right", "top")	
	end
end

function CharacterCreationGUI:nextOption()
	if self.m_CurrentLevel == 1 then
		self:unbind("arrow_l", CharacterCreationGUI.previousPed)
		self:unbind("arrow_r", CharacterCreationGUI.nextPed)
	else
		self:unbind("arrow_l", CharacterCreationGUI.previousDesign)
		self:unbind("arrow_r", CharacterCreationGUI.nextDesign)
	end
	
	self.m_CurrentLevel = self.m_CurrentLevel+1
	
	if self.m_CurrentLevel == 1 then
		self:bind("arrow_l", CharacterCreationGUI.previousPed)
		self:bind("arrow_r", CharacterCreationGUI.nextPed)
	else
		self:bind("arrow_l", CharacterCreationGUI.previousDesign)
		self:bind("arrow_r", CharacterCreationGUI.nextDesign)
	end
	
	self:updateView()
end

function CharacterCreationGUI:previousOption()
	if self.m_CurrentLevel == 1 then return end
	if self.m_CurrentLevel == 1 then
		self:unbind("arrow_l", CharacterCreationGUI.previousPed)
		self:unbind("arrow_r", CharacterCreationGUI.nextPed)
	else
		self:unbind("arrow_l", CharacterCreationGUI.previousDesign)
		self:unbind("arrow_r", CharacterCreationGUI.nextDesign)
	end

	self.m_CurrentLevel = self.m_CurrentLevel-1
	
	if self.m_CurrentLevel == 1 then
		self:bind("arrow_l", CharacterCreationGUI.previousPed)
		self:bind("arrow_r", CharacterCreationGUI.nextPed)
	else
		self:bind("arrow_l", CharacterCreationGUI.previousDesign)
		self:bind("arrow_r", CharacterCreationGUI.nextDesign)
	end
	self:updateView()
end

function CharacterCreationGUI:nextDesign()
	local skin = self.m_Peds[self.m_CurrentView].m_Skin
	local index = self.m_CurrentLevel -1
	
	local cs = skin:getColorScheme(index)
	local css = skin:getColorSchemes(index)
	cs = cs+1
	if cs > #css then cs = 1 end
	
	skin:setColorScheme(index, cs)
	
	self.m_Options[index*2]:setText(tostring(cs))
end

function CharacterCreationGUI:previousDesign()
	local skin = self.m_Peds[self.m_CurrentView].m_Skin
	local index = self.m_CurrentLevel -1
	
	local cs = skin:getColorScheme(index)
	local css = skin:getColorSchemes(index)
	cs = cs-1
	if cs < 1 then cs = #css end
	
	skin:setColorScheme(index, cs)
	
	self.m_Options[index*2]:setText(tostring(cs))
end

function CharacterCreationGUI:updateView()
	if self.m_Cutscene then 
		self.m_Cutscene:stop()
		delete(self.m_Cutscene)
	end
	local id = self.m_CurrentView
	
	local xl, yl, zl, rz = unpack(CHARACTER_SELECTION_PED_POSITIONS[id])
	local x, y = getPointFromDistanceRotation(xl, yl, 3.75, -rz)
	local z = zl+0.5
	
	self.m_Cutscene = Cutscene:new(
	{
		name = "CharacterCreation";
		startscene = "CharacterCreation";
		debug = true;
		-- Scene 1 
		{
			uid = "CharacterCreation";
			letterbox = false;
			{
				action = "Camera.move";
				starttick = 0;
				targetpos = { x, y, z };
				targetlookat = { xl, yl, zl };
				duration = 500;
			};
		}
	})
	
	self.m_Cutscene:play()
	self.m_Cutscene.onFinish = function(self) self:delete() end
end


























