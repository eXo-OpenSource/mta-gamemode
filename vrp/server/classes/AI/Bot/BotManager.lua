
BotManager = inherit(Singleton)

function BotManager:constructor()
	self.m_NPCs = {}
	self.m_LastInsertId = 0
	setTimer(function()
		self:update()
	end, 50, 0)

end


function BotManager:update()
	for index, bot in pairs(self.m_NPCs) do
		bot:update()
	end
end

function BotManager:deleteNPC(id)
	if id then
		if self.m_NPCs[id] then
			self.m_NPCs[id]:destroy()
			self.m_NPCs[id] = nil
		end
	end
end

function BotManager:addNPC(skinId, pos, rot, followTarget)
	if skinId and pos then
		local npcSettings = {}
		npcSettings.skinID = skinId
		npcSettings.pos = pos
		npcSettings.rot = rot or Vector3(0, 0, math.random(0, 360))
		npcSettings.life = 1000
		npcSettings.followTarget = followTarget
		self.m_LastInsertId = self.m_LastInsertId + 1
		npcSettings.id = self.m_LastInsertId
		self.m_NPCs[npcSettings.id] = Bot:new(npcSettings)
		return self.m_NPCs[npcSettings.id]
	end
end
