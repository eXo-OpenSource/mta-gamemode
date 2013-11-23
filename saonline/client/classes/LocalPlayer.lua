LocalPlayer = inherit(Player)

function LocalPlayer:constructor()
	self.m_Locale = "en"
end

function LocalPlayer:destructor()

end

function LocalPlayer:getLocale()
	return self.m_Locale
end

function LocalPlayer:setLocale(locale)
	self.m_Locale = locale
end

function LocalPlayer:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), r, g, b, true)
end
