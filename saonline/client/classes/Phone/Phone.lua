-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Phone/Phone.lua
-- *  PURPOSE:     Phone class
-- *
-- ****************************************************************************
Phone = inherit(Singleton)

function Phone:constructor()
	self.m_Apps = {}
	
	-- Register apps
	self:registerApp(AppHelloWorld)
	
	-- Add event handlers
	addEventHandler("onClientRender", root, bind(self.draw, self))
end

function Phone:destructor()
end

function Phone:draw()
	-- Draw phone
	dxDrawImage(screenWidth-270, screenHeight-500, 250, 490, "files/images/Phone/Phone.png") -- 1.96
	
	-- Draw app icons
	for k, app in ipairs(self.m_Apps) do
		dxDrawImage(screenWidth-240, screenHeight-440, 64, 64, app:getIconPath())
	end

	-- Draw app surface
	for k, app in ipairs(self.m_Apps) do
		if app:isOpen() then
			if app.render then
				app:render()
			end
		end
	end
end

function Phone:registerApp(app)
	table.insert(self.m_Apps, app)
end

addCommandHandler("phone",
	function()
		local p = Phone:new()
		
	end
)