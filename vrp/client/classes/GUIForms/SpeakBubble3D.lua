
SpeakBubble3D = inherit(GUIForm3D)

function SpeakBubble3D:constructor(npc, text, description)
	local pos = npc:getPosition()
	pos.z = pos.z + 1.5

	self.m_Text = text
	self.m_Description = description

	GUIForm3D.constructor(self, pos, npc:getRotation(), Vector2(1, 0.34), Vector2(200,70), 30)
end

function SpeakBubble3D:onStreamIn(surface)
	GUIImage:new(0, 0, 200, 70, "files/images/Other/bubble.png", surface)
	GUILabel:new(5, 0, 200, 25, self.m_Text, surface):setColor(Color.Orange)
	GUILabel:new(5, 25, 200, 20, self.m_Description, surface):setColor(Color.Black)
end
