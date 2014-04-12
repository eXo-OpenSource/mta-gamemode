Core = inherit(Object)

function Core:constructor()
	-- Small hack to get the global core immediately
	core = self
	
	-- Instantiate the localPlayer instance right now
	enew(localPlayer, LocalPlayer)
	
	if DEBUG then
		Debugging:new()
	end
	
	self.m_Config = ConfigXML:new("config.xml")
	Version:new()
	Provider:new()
	
	DownloadGUI:new()
	local dgi = DownloadGUI:getSingleton()
	Provider:getSingleton():requestFile("vrp.data", bind(DownloadGUI.onComplete, dgi), bind(DownloadGUI.onProgress, dgi))
end

function Core:ready()
	TranslationManager:new()
	JobManager:new()
	MTAFixes:new()
	ClickHandler:new()
	RadioGUI:new()
	KarmaBar:new()
	CustomModelManager:new()
	
	-- HUD
	--HUDRadar:new()
	HUDSpeedo:new()
	
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
	
	InventoryGUI:new()
	InventoryGUI:getSingleton():close()
	bindKey("i", "down",
		function()
			InventoryGUI:getSingleton():toggle(true)
		end
	)
	
	-- Vehicle shops
	VehicleShop.initializeAll()
	VehicleGarage.initializeAll()
	
	self:createBlips()
end

function Core:destructor()

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
	HUDRadar:getSingleton():addBlip("files/images/Blips/Bank.png", 1660.4, -1272.8)
end

