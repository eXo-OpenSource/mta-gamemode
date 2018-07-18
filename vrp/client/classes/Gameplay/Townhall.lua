Townhall = inherit(Singleton)

function Townhall:constructor()
	self.m_Peds = {}
	self.m_OnClickFunc = bind(self.Event_OnPedClick, self)

	-- Job Info
	local jobInfoPed = Ped.create(12, Vector3(1819.6, -1272.9, 120.3))
	jobInfoPed:setRotation(Vector3(0, 0, 212.004))
	jobInfoPed.Name = _"Spielhilfe"
	jobInfoPed.Description = _"Für mehr Infos klicke mich an!"
	jobInfoPed.Type = 1
	jobInfoPed.Func = function() HelpGUI:new() end
	self.m_Peds[#self.m_Peds + 1] = jobInfoPed

	--[[ Activities
	local activitiesInfoPed = Ped.create(9, Vector3(1824, -1271.5, 120.3))
	activitiesInfoPed:setRotation(Vector3(0, 0, 182.754))
	activitiesInfoPed.Name = _"Stadthalle: Aktivitäten"
	activitiesInfoPed.Description = _"Für mehr Infos klicke mich an!"
	activitiesInfoPed.Type = 2
	self.m_Peds[#self.m_Peds + 1] = activitiesInfoPed
	]]
	-- Groups
	--// Group create ped
	local groupInfoPed = Ped.create(9, Vector3(1828.3, -1271.6, 120.3))
	groupInfoPed:setRotation(Vector3(0, 0, 182.754))
	groupInfoPed.Name = _"Private Firmen und Gangs"
	groupInfoPed.Description = _"Für mehr Infos klicke mich an!"
	groupInfoPed.Type = 3
	groupInfoPed.Func = function() GroupCreationGUI:new() end
	self.m_Peds[#self.m_Peds + 1] = groupInfoPed

	--// Group property ped
	local groupImmoPed = Ped.create(290, Vector3(1824.02, -1271.87, 120.26))
	groupImmoPed:setRotation(Vector3(0, 0, 182.754))
	groupImmoPed.Name = _"Firmen-/Gangimmobilien"
	groupImmoPed.Description = _"Für mehr Infos klicke mich an!"
	groupImmoPed.Type = 5
	groupImmoPed.Func = function()
		if localPlayer:getGroupName() ~= "" then
			GroupPropertyBuy:new()
		else ErrorBox:new(_"Du hast keine Firma/Gang!")
		end
	end
	self.m_Peds[#self.m_Peds + 1] = groupImmoPed
	-- Items
	local itemInfoPed = Ped.create(9, Vector3(1832.8, -1273.5, 120.3))
	itemInfoPed:setRotation(Vector3(0, 0, 132.754))
	itemInfoPed.Name = _"Ausweis / Kaufvertrag"
	itemInfoPed.Description = _"Für mehr Infos klicke mich an!"
	itemInfoPed.Type = 4
	itemInfoPed.Func = function() triggerServerEvent("shopOpenGUI", localPlayer, 50) end
	self.m_Peds[#self.m_Peds + 1] = itemInfoPed

	--// VEHICLE SPAWNER PEDS
	local itemSpawnerPed = Ped.create(171, Vector3(1806.72, -1293.27, 13.61))
	itemSpawnerPed:setRotation(Vector3(0, 0, 65))
	itemSpawnerPed.Name = _"Fahrzeugverleih"
	itemSpawnerPed.Description = _"Fahrzeug für 200$ ausleihen!"
	itemSpawnerPed.FuLnc = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed

	local itemSpawnerPed2 = Ped.create(171, Vector3(1509.99, -1749.29, 13.55))
	itemSpawnerPed2:setRotation(Vector3(0, 0, 97.13))
	itemSpawnerPed2.Name = _"Fahrzeugverleih"
	itemSpawnerPed2.Description = _"Fahrzeug für 200$ ausleihen!"
	itemSpawnerPed2.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed2


	--// WT PED AREA
	local itemSpawnerPed3 = Ped.create(287, Vector3(117.39, 1883.09, 17.88))
	itemSpawnerPed3:setRotation(Vector3(0, 0, 0))
	itemSpawnerPed3.Name = _"Ausrüstungsfahrzeug"
	itemSpawnerPed3.Description = _"Hier startet der Waffentruck!"
	itemSpawnerPed3.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed3


	--// WT PED SF
	local itemSpawnerPed4 = Ped.create(307, Vector3(-1869.94, 1422.34, 7.18))
	itemSpawnerPed4:setRotation(Vector3(0, 0, 220))
	itemSpawnerPed4.Name = _"Illegaler Waffentruck"
	itemSpawnerPed4.Description = _"Hier startet der Waffentruck!"
	itemSpawnerPed4.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed4


	--// VEHICLE SPAWNER RESCUE
	local itemSpawnerPed5 = Ped.create(171, Vector3(1180.90, -1331.90, 13.58))
	itemSpawnerPed5:setRotation(Vector3(0, 0, 270))
	itemSpawnerPed5.Name = _"Fahrzeugverleih"
	itemSpawnerPed5.Description = _"Fahrzeug für 200$ ausleihen!"
	itemSpawnerPed5.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed5

	--// RESCUE BASE HEAL PED

	local itemSpawnerPed6 = Ped.create(70, Vector3(1172.33, -1321.48, 15.40))
	itemSpawnerPed6:setRotation(Vector3(0, 0, 270))
	itemSpawnerPed6.Name = _"Erste Hilfe"
	itemSpawnerPed6.Description = _"Klicke mich für Heilung an!"
	itemSpawnerPed6.Func = function() triggerServerEvent("factionRescuePlayerHealBase", localPlayer) end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed6
	
	
	--// TOWN HALL JOB LIST 
	local itemSpawnerPed7 = Ped.create(70, Vector3(1814.72, -1276.14, 120.26))
	itemSpawnerPed7:setRotation(Vector3(0, 0, 180))
	itemSpawnerPed7.Name = _"Jobliste"
	itemSpawnerPed7.Description = _"Klicke hier für Informationen!"
	itemSpawnerPed7.Func = function() JobHelpGUI:new() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed7
	
	-- Initialize
	self:initalizePeds()

	local col = createColRectangle(1399.60, -1835.2, 1540.14-1399.60, 1835.2-1582.84) -- pershing square
	self.m_NoParkingZone = NoParkingZone:new(col)
end

function Townhall:destructor()
	for i, v in pairs(self.m_Peds) do
		if v.SpeakBubble then
			delete(v.SpeakBubble) -- would also happen automatically ^^
		end
		v:destroy()
	end
end

function Townhall:initalizePeds()
	for i, v in pairs(self.m_Peds) do
		setElementData(v, "clickable", true)
		v:setData("NPC:Immortal", true)
		v:setData("Townhall:onClick", function () self.m_OnClickFunc(v) end)
		v:setFrozen(true)
		v.SpeakBubble = SpeakBubble3D:new(v, v.Name, v.Description)
	end
end

function Townhall:Event_OnPedClick(ped)
	if ped.Func then
		ped.Func()
	else
		ShortMessage:new("Clicked-Ped: "..ped.Type)
		TownhallInfoGUI:getSingleton():openTab(ped.Type)
	end
end

--[[
<ped id="ped (1)" dimension="0" model="12" interior="0" rotZ="212.004" alpha="255" posX="1819.6" posY="-1272.9" posZ="120.3" rotX="0" rotY="0"></ped>
<ped id="ped (2)" dimension="0" model="9" interior="0" rotZ="182.754" alpha="255" posX="1824" posY="-1271.5" posZ="120.3" rotX="0" rotY="0"></ped>
<ped id="ped (3)" dimension="0" model="150" interior="0" rotZ="182.754" alpha="255" posX="1828.3" posY="-1271.6" posZ="120.3" rotX="0" rotY="0"></ped>
<ped id="ped (4)" dimension="0" model="219" interior="0" rotZ="132.754" alpha="255" posX="1832.8" posY="-1273.5" posZ="120.3" rotX="0" rotY="0"></ped>
]]
