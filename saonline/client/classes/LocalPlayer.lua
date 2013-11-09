LocalPlayer = inherit(Player)

function LocalPlayer:constructor()

end

function LocalPlayer:destructor()

end

function LocalPlayer:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), r, g, b, true)
end
