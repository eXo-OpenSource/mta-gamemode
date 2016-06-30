Townhall = inherit(Singleton)

function Townhall:constructor()
	self.m_Peds = {}
	self.m_OnClickFunc = bind(self.Event_OnPedClick, self)

	-- Job Info
	local jobInfoPed = Ped.create(12, Vector3(1819.6, -1272.9, 120.3))
	jobInfoPed:setRotation(Vector3(0, 0, 212.004))
	jobInfoPed.Name = _"Stadthalle: Jobs"
	jobInfoPed.Description = _"Für mehr Infos klicke mich an!"
	jobInfoPed.Type = 1
	self.m_Peds[#self.m_Peds + 1] = jobInfoPed

	-- Activities
	local activitiesInfoPed = Ped.create(9, Vector3(1824, -1271.5, 120.3))
	activitiesInfoPed:setRotation(Vector3(0, 0, 182.754))
	activitiesInfoPed.Name = _"Stadthalle: Aktivitäten"
	activitiesInfoPed.Description = _"Für mehr Infos klicke mich an!"
	activitiesInfoPed.Type = 2
	self.m_Peds[#self.m_Peds + 1] = activitiesInfoPed

	-- Groups
	local groupInfoPed = Ped.create(9, Vector3(1828.3, -1271.6, 120.3))
	groupInfoPed:setRotation(Vector3(0, 0, 182.754))
	groupInfoPed.Name = _"Stadthalle: Gangs"
	groupInfoPed.Description = _"Für mehr Infos klicke mich an!"
	groupInfoPed.Type = 3
	self.m_Peds[#self.m_Peds + 1] = groupInfoPed

	-- Items
	local itemInfoPed = Ped.create(9, Vector3(1832.8, -1273.5, 120.3))
	itemInfoPed:setRotation(Vector3(0, 0, 132.754))
	itemInfoPed.Name = _"Stadthalle: Inventar/Items"
	itemInfoPed.Description = _"Für mehr Infos klicke mich an!"
	itemInfoPed.Type = 4
	self.m_Peds[#self.m_Peds + 1] = itemInfoPed

	-- Initialize
	self:initalizePeds()
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
	ShortMessage:new("Clicked-Ped: "..ped.Type)
end

--[[
<ped id="ped (1)" dimension="0" model="12" interior="0" rotZ="212.004" alpha="255" posX="1819.6" posY="-1272.9" posZ="120.3" rotX="0" rotY="0"></ped>
<ped id="ped (2)" dimension="0" model="9" interior="0" rotZ="182.754" alpha="255" posX="1824" posY="-1271.5" posZ="120.3" rotX="0" rotY="0"></ped>
<ped id="ped (3)" dimension="0" model="150" interior="0" rotZ="182.754" alpha="255" posX="1828.3" posY="-1271.6" posZ="120.3" rotX="0" rotY="0"></ped>
<ped id="ped (4)" dimension="0" model="219" interior="0" rotZ="132.754" alpha="255" posX="1832.8" posY="-1273.5" posZ="120.3" rotX="0" rotY="0"></ped>
]]
