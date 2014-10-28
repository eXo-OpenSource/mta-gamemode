Core = inherit(Object)

function Core:constructor()
	-- Small hack to get the global core immediately
	core = self
	
	-- Instantiate the localPlayer instance right now
	enew(localPlayer, LocalPlayer)
	
	if DEBUG then
		Debugging:new()
	end
	
	Cursor = GUICursor:new()
	
	self.m_Config = ConfigXML:new("config.xml")
	Version:new()
	Provider:new()
	
	DownloadGUI:new()
	local dgi = DownloadGUI:getSingleton()
	Provider:getSingleton():requestFile("vrp.data", bind(DownloadGUI.onComplete, dgi), bind(DownloadGUI.onProgress, dgi))
end

function Core:ready()
	TranslationManager:new()
	MTAFixes:new()
	ClickHandler:new()
	CustomModelManager:new()
	GangAreaManager:new()
	HelpBar:new()
	JobManager:new()
	AmmuNationGUI:new()
	HouseGUI:new()
	Housing:new()
	
	VehicleShop.initializeAll()
	VehicleGarages:new()
	GasStationGUI:new()
	
	HelpTexts.translateAll()
end

function Core:afterLogin()
	RadioGUI:new()
	KarmaBar:new()
	HUDSpeedo:new()
	Nametag:new()
	--HUDRadar:new()
	--HUDUI:new()
	HUDRadar:getSingleton():show()
	HUDUI:getSingleton():show()
	Collectables:new()
	
	-- Phone
	Phone:new()
	Phone:getSingleton():close()
	bindKey("k", "down",
		function()
			Phone:getSingleton():toggle(true)
		end
	)
	
	PolicePanel:new()
	PolicePanel:getSingleton():close()
	bindKey("f2", "down",
		function()
			if localPlayer:getJob() == JobPolice:getSingleton() then
				PolicePanel:getSingleton():toggle(true)
			end
		end
	)
	
	SelfGUI:new()
	SelfGUI:getSingleton():close()
	addCommandHandler("self", function() SelfGUI:getSingleton():open() end)
	
	ScoreboardGUI:new():close()
	bindKey("tab", "down", function() ScoreboardGUI:getSingleton():setVisible(true):bringToFront() end)
	bindKey("tab", "up", function() ScoreboardGUI:getSingleton():setVisible(false) end)
	
	self:createBlips()
end

function Core:destructor()
	delete(Cursor)
	delete(self.m_Config)
end

function Core:getConfig()
	return self.m_Config
end

function Core:get(...)
	return self.m_Config:get(...)
end

function Core:set(...)
	return self.m_Config:set(...)
end

function Core:createBlips()
	Blip:new("Bank.png", 1660.4, -1272.8)
end

function Core:throwInternalError(message)
	-- Todo: Send it to the server
	outputChatBox("Internal error: "..message)
end
