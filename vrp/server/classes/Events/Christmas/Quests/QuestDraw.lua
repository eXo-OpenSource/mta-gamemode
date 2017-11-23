QuestDraw = inherit(Quest)

QuestDraw.Targets = {
	[4] = "SantaClaus",
	[10] = "SnowMan"
}

function QuestDraw:constructor(id)
	Quest.constructor(self, id)

	self.m_Target = QuestPhotography.Targets[id]
end

function QuestDraw:destructor(id)
	Quest.destructor(self)
end

