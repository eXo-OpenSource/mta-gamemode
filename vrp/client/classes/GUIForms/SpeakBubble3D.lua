
SpeakBubble3D = inherit(GUIForm3D)

function SpeakBubble3D:constructor(npc, text, description, rotPlus)
	addEventHandler("onElementDestroy", npc, function () delete(self) end)

	local pos = npc:getPosition()
	pos.z = pos.z + 1.5

	self.m_Text = text
	self.m_Description = description
	rotPlus = rotPlus or 0
	GUIForm3D.constructor(self, pos, npc:getRotation()+Vector3(0,0,rotPlus), Vector2(1, 0.34), Vector2(200,70), 30)
end

function SpeakBubble3D:onStreamIn(surface)
	GUIImage:new(0, 0, 200, 70, "files/images/Other/bubble.png", surface)
	GUILabel:new(8, 2, 200, 25, self.m_Text, surface):setColor(Color.LightBlue)
	GUILabel:new(8, 27, 200, 20, self.m_Description, surface)
end
