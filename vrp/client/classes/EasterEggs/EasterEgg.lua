EasterEgg = inherit(Singleton)

function EasterEgg:constructor()
	EasterEgg.Scream:new()
	EasterEgg.QRCode:new()
	EasterEgg.DrWho:new()
	EasterEgg.PewPew:new()

	-- Doge EasterEgg
	self.m_DogeString  =
	[[
		░░░░░░░░░▄░░░░░░░░░░░░░░▄░░░░ wow
		░░░░░░░░▌▒█░░░░░░░░░░░▄▀▒▌░░░
		░░░░░░░░▌▒▒█░░░░░░░░▄▀▒▒▒▐░░░ such iLife
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
	addCommandHandler("doge",
		function()
			localPlayer:giveAchievement(77)
			outputConsole(self.m_DogeString)
		end
	)
	addCommandHandler("ilife",
		function()
			localPlayer:giveAchievement(72)
		end
	)
	addCommandHandler("sbx320",
		function()
			localPlayer:giveAchievement(82)
		end
	)
	addCommandHandler("ekonomie",
		function()
			localPlayer:giveAchievement(82)
		end
	)
end

function EasterEgg:destructor()
end
