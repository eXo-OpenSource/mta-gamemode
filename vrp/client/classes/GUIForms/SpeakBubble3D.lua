SpeakBubble3D = inherit(GUIForm3D)
SpeakBubble3D.Map = {}

function SpeakBubble3D:constructor(element, text, description, rotPlus)
	addEventHandler("onElementDestroy", element, function () delete(self) end, false)

	local pos = element:getPosition()
	pos.z = pos.z + 1.5

	self.m_Text = text
	self.m_Description = description
	rotPlus = rotPlus or 0
	GUIForm3D.constructor(self, pos, element:getRotation()+Vector3(0,0,rotPlus), Vector2(1, 0.34), Vector2(200,70), 30)
	SpeakBubble3D.Map[element] = self
end

function SpeakBubble3D:onStreamIn(surface)
	GUIImage:new(0, 0, 200, 70, "files/images/Other/bubble.png", surface)
	GUILabel:new(8, 2, 200, 25, self.m_Text, surface):setColor(Color.LightBlue)
	GUILabel:new(8, 27, 200, 20, self.m_Description, surface)
end
