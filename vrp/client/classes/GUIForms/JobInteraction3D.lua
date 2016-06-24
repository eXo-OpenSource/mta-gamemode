
JobInteraction = inherit(GUIForm3D)

function JobInteraction:constructor(pos, rot, name)
	self.m_Name = name
	GUIForm3D.constructor(self, pos, rot, Vector2(1, 0.34), Vector2(200,70), 30)
end

function JobInteraction:onStreamIn(surface)
	GUIImage:new(0, 0, 200, 70, "files/images/Other/bubble.png", surface)
	GUILabel:new(5, 0, 200, 25, "Job: "..self.m_Name, surface):setColor(Color.Orange)
	GUILabel:new(5, 25, 200, 20, "Klicke mich an!", surface):setColor(Color.Black)
end
