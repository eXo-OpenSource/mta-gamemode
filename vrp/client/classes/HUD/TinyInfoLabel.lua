


TinyInfoLabel = inherit(Singleton)


function TinyInfoLabel:constructor()
	self.m_Label = guiCreateLabel(2, screenHeight-18, 1000, 18, "", false)
	guiSetAlpha(self.m_Label, 0.53)
	guiLabelSetHorizontalAlign(self.m_Label, "left")
end

function TinyInfoLabel:setText(text)
    guiSetText(self.m_Label, tostring(text))
end

function TinyInfoLabel:clearText()
    guiSetText(self.m_Label, "")
end
