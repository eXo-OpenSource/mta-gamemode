EasterEgg = inherit(Singleton)

function EasterEgg:constructor()
	-- Scream EasterEgg (Rescue base)
	EasterEgg.Scream:new()

	-- Doge EasterEgg
	self.m_DogeQRFrame = createObject(2257, 1102.8000488281, -841.70001220703, 108.19999694824, 345, 0, 7.25);
	setElementData(self.m_DogeQRFrame, "clickable", true)
	setElementData(self.m_DogeQRFrame, "qr_doge", true)
	self.m_DogeString  =
	[[
		░░░░░░░░░▄░░░░░░░░░░░░░░▄░░░░ wow
		░░░░░░░░▌▒█░░░░░░░░░░░▄▀▒▌░░░
		░░░░░░░░▌▒▒█░░░░░░░░▄▀▒▒▒▐░░░ such eXo (iLife :P)
		░░░░░░░▐▄▀▒▒▀▀▀▀▄▄▄▀▒▒▒▒▒▐░░░
		░░░░░▄▄▀▒░▒▒▒▒▒▒▒▒▒█▒▒▄█▒▐░░░
		░░░▄▀▒▒▒░░░▒▒▒░░░▒▒▒▀██▀▒▌░░░
		░░▐▒▒▒▄▄▒▒▒▒░░░▒▒▒▒▒▒▒▀▄▒▒▌░░ so MTA
		░░▌░░▌█▀▒▒▒▒▒▄▀█▄▒▒▒▒▒▒▒█▒▐░░
		░▐░░░▒▒▒▒▒▒▒▒▌██▀▒▒░░░▒▒▒▀▄▌░
		░▌░▒▄██▄▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒▌░
		▀▒▀▐▄█▄█▌▄░▀▒▒░░░░░░░░░░▒▒▒▐░ much driving
		▐▒▒▐▀▐▀▒░▄▄▒▄▒▒▒▒▒▒░▒░▒░▒▒▒▒▌
		▐▒▒▒▀▀▄▄▒▒▒▄▒▒▒▒▒▒▒▒░▒░▒░▒▒▐░
		░▌▒▒▒▒▒▒▀▀▀▒▒▒▒▒▒░▒░▒░▒░▒▒▒▌░
		░▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒░▒░▒▒▄▒▒▐░░
		░░▀▄▒▒▒▒▒▒▒▒▒▒▒░▒░▒░▒▄▒▒▒▒▌░░
		░░░░▀▄▒▒▒▒▒▒▒▒▒▒▄▄▄▀▒▒▒▒▄▀░░░ very impressive
		░░░░░░▀▄▄▄▄▄▄▀▀▀▒▒▒▒▒▄▄▀░░░░░
		░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▀▀░░░░░░░░
	]]
	setObjectScale(self.m_DogeQRFrame, 1.5);
	TextureReplace:new("cj_painting15", "files/images/Other/such_qr_wow.png", false, 1320, 1320, self.m_DogeQRFrame)
	addCommandHandler("doge",
		function()
			localPlayer:giveAchievement(77)
			outputConsole(self.m_DogeString)
		end
	)
end

function EasterEgg:destructor()
	self.m_DogeQRFrame:destroy()
end
