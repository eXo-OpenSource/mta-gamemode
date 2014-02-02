CharacterCreationGUI = inherit(Singleton)
inherit(GUIForm, CharacterCreationGUI)

function CharacterCreationGUI:constructor()	
	local sw, sh = guiGetScreenSize()
	GUIForm.constructor(self, 0, 0, sw, sh)
	
		
	self:bind("arrow_l", bind(CharacterCreationGUI.left, self))
	self:bind("arrow_r", bind(CharacterCreationGUI.right, self))
	self:bind("arrow_d", bind(CharacterCreationGUI.down, self))
	self:bind("arrow_u", bind(CharacterCreationGUI.up, self))
	
	local skins = {
		19, 19, 19, 19 -- supported skins
	}
	
	self.m_Peds = {}
	for k, id in pairs(skins) do
		self.m_Peds[#self.m_Peds+1] = createPed(id, 2058-#skins+k-1, 1462, 11)
		setElementRotation(self.m_Peds[#self.m_Peds], 0, 0, 180)
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
				targetpos = { 2057.33-#self.m_Peds+id, 1458.67, 12.24-lv*0.3 };
				targetlookat = { 2057.28-#self.m_Peds+id, 1459.62, 11.95-lv*0.3 };
				duration = 500;
			};
		}
	})
	self.m_Cutscene:play()
	self.m_Cutscene.onFinish = function(self) self:delete() end
end


























