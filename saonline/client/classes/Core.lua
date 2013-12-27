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
	TranslationManager:new()
	JobManager:new()
	MTAFixes:new()
	ClickHandler:new()
	RadioGUI:new()
	KarmaBar:new()
	
	-- HUD
	--HUDRadar:new()
	
	-- Phone
	Phone:new()
	Phone:getSingleton():close()
	bindKey("k", "down",
		function()
			if not Phone:getSingleton():isVisible() then
				Phone:getSingleton():open()
			else
				Phone:getSingleton():close()
			end
		end
	)
	
	-- Vehicle shops
	VehicleShop.createShops()
end

function Core:destructor()

end

function Core:getConfig()
	return self.m_Config
end
