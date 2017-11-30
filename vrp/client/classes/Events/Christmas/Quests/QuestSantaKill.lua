QuestSantaKill = inherit(Object)

function QuestSantaKill:constructor(questId, name, description, pos)
	self.m_PedWasted = bind(self.Event_onPedWasted, self)
	self.m_PedDamage = bind(self.Event_onPedDamage, self)
	self.m_QuestStart = bind(self.Event_onStartQuest, self)
	addEventHandler("onClientPedWasted", root, self.m_PedWasted)
	addEventHandler("onClientPedDamage", root, self.m_PedDamage)

	self:init(pos)
end

function QuestSantaKill:init(pos)
	if pos then
		self.m_SantaPeds = {}
		self.m_SantaAreas = {}
		local santaPos, x, y, z, rx, ry
		for i = 1, 3 do
			rx = math.random(1,200)
			ry = math.random(1,200)
			x,y,z = unpack(pos[math.random(1,#pos)])
			self.m_SantaAreas[#self.m_SantaAreas+1] = HUDRadar:getSingleton():addArea(x-rx, y, 200, 200, tocolor(200,50,0,255))
			self.m_SantaPeds[#self.m_SantaPeds+1] = createPed(41, x, y, z)
			self.m_SantaPeds[#self.m_SantaPeds].m_Area = self.m_SantaAreas[#self.m_SantaAreas]
			setElementData(self.m_SantaPeds[#self.m_SantaPeds], "Ped:fakeNameTag", "Unbekannter Mann")
			setPedAnimation(self.m_SantaPeds[#self.m_SantaPeds], "on_lookers", "lkaround_loop", -1,true, false, false)
			addEventHandler("onClientPedWasted", self.m_SantaPeds[#self.m_SantaPeds], self.m_PedWasted)
			addEventHandler("onClientPedDamage", self.m_SantaPeds[#self.m_SantaPeds], self.m_PedDamage)
		end
	end
	CustomModelManager:getSingleton():loadImportTXD("files/models/kobold.txd", 41)
	CustomModelManager:getSingleton():loadImportDFF("files/models/kobold.dff", 41)

end

function QuestSantaKill:destructor()
	if self.m_SantaPeds then
		for i = 1, #self.m_SantaPeds do
			if self.m_SantaPeds[i] and isElement(self.m_SantaPeds[i]) then
				destroyElement(self.m_SantaPeds[i])
				if self.m_SantaAreas[i] then
					HUDRadar:getSingleton():removeArea(self.m_SantaAreas[i])
				end
			end
		end
	end
	CustomModelManager:getSingleton():restoreModel(41)
end

function  QuestSantaKill:Event_onPedWasted(killer)
	if killer == localPlayer then
		triggerServerEvent("onQuestSantaKilled", localPlayer)
		if source.m_Area then
			HUDRadar:getSingleton():removeArea(source.m_Area)
		end
		destroyElement(source)
	end
end

function  QuestSantaKill:Event_onPedDamage(attacker)
	if attacker ~= localPlayer then
		cancelEvent()
	else
		setPedAnimation(source, "ped", "duck_cower", -1, true, false)
	end
end
