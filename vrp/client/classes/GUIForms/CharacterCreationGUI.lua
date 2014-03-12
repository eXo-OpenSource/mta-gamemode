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
19, 19, 19, 19 -- fixme: add different skins
}

function CharacterCreationGUI:constructor()	
	local sw, sh = guiGetScreenSize()
	GUIForm.constructor(self, 0, 0, sw, sh)
	self.m_Selector = GUIRectangle:new(sw/3*2, sh/5, sw/4, sh/2, tocolor(2, 17, 39, 255), self)
	GUILabel:new(0, 10, (sw/4), 10, "Aussehen", 1.5, self.m_Selector):setAlign("center", "top")	
		
	self:bind("arrow_l", bind(CharacterCreationGUI.left, self))
	self:bind("arrow_r", bind(CharacterCreationGUI.right, self))
	self:bind("arrow_d", bind(CharacterCreationGUI.down, self))
	self:bind("arrow_u", bind(CharacterCreationGUI.up, self))
	
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
	
	-- Levels:
	-- 1 = select char
	-- 2 = select option 1
	-- #options+1 = confirm
	self.m_CurrentLevel = 1;
	
	self.m_CurrentView = math.ceil(#skins/2)
	self:updateView()
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

function CharacterCreationGUI:right()
	if self.m_CurrentLevel == 1 then
		self.m_CurrentView = self.m_CurrentView+1
		if self.m_CurrentView > #self.m_Peds then
			self.m_CurrentView = 1
		end
		self:updateView()
	end
	if self.m_CurrentLevel >= 2 then
		local ped = self.m_Peds[self.m_CurrentView]
		local sdata = skindata[getElementModel(ped)]
		local cdata = sdata.color[self.m_CurrentLevel-1]
		
		ped.m_ColorScheme = ped.m_ColorScheme-1
		if ped.m_ColorScheme <= 0 then
			ped.m_ColorScheme = #cdata
		end
		
		local r, g, b = cdata[ped.m_ColorScheme][1], cdata[ped.m_ColorScheme][2], cdata[ped.m_ColorScheme][3]
		ped.m_Skin:setColor(self.m_CurrentLevel-1, r/255, g/255, b/255)
	end
end

function CharacterCreationGUI:left()
	if self.m_CurrentLevel == 1 then
		self.m_CurrentView = self.m_CurrentView-1
		if self.m_CurrentView <= 0 then
			self.m_CurrentView = #self.m_Peds
		end
		self:updateView()
	end
	if self.m_CurrentLevel >= 2 then
		local ped = self.m_Peds[self.m_CurrentView]
		local sdata = skindata[getElementModel(ped)]
		local cdata = sdata.color[self.m_CurrentLevel-1]
		
		ped.m_ColorScheme = ped.m_ColorScheme+1
		if ped.m_ColorScheme > #cdata then
			ped.m_ColorScheme = 1
		end
		
		local r, g, b = cdata[ped.m_ColorScheme][1], cdata[ped.m_ColorScheme][2], cdata[ped.m_ColorScheme][3]
		ped.m_Skin:setColor(self.m_CurrentLevel-1, r/255, g/255, b/255)
	end
end

function CharacterCreationGUI:down()
	self.m_CurrentLevel = self.m_CurrentLevel+1
	self:updateView()
end

function CharacterCreationGUI:up()
	if self.m_CurrentLevel == 1 then return end
	self.m_CurrentLevel = self.m_CurrentLevel-1
	self:updateView()
end

function CharacterCreationGUI:updateView()
	if self.m_Cutscene then 
		self.m_Cutscene:stop()
		delete(self.m_Cutscene)
	end
	local id = self.m_CurrentView
	local lv = self.m_CurrentLevel
	
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
				targetpos = { x, y, z-lv*0.3 };
				targetlookat = { xl, yl, zl-lv*0.3 };
				duration = 500;
			};
		}
	})
	
	self.m_Cutscene:play()
	self.m_Cutscene.onFinish = function(self) self:delete() end
end


























