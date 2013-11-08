Core = inherit(Object)

function Core:constructor()
	-- Small hack to get the global core immediately
	core = self
	
	-- Instantiate the localPlayer instance right now
	enew(localPlayer, LocalPlayer)
	
	Version:new()
	
	-- HUD
	HUDRadar:new()
	
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
end

function Core:destructor()

end
