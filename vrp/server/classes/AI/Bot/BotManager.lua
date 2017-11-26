
BotManager = inherit(Singleton)

function BotManager:constructor()
	self.m_NPCs = {}
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
	if (id) then
		if (self.m_NPCs[id]) then
			self.m_NPCs[id]:delete()
			self.m_NPCs[id] = nil
		end
	end
end

function BotManager:addNPC(pos, rot)
	if pos then
		local npcSettings = {}
		npcSettings.skinID = 0
		npcSettings.pos = pos
		npcSettings.rot = rot or Vector3(0, 0, math.random(0, 360))
		npcSettings.life = 1000

		npcSettings.id = #self.m_NPCs+1

		if (not self.m_NPCs[npcSettings.id]) then
			self.m_NPCs[npcSettings.id] = Bot:new(npcSettings)
		end
	end
end
