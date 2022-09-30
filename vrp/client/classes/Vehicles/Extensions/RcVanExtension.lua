-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/Extensions/RcVanExtension.lua
-- *  PURPOSE:     extension for the Vehicle class to use rc baron with rc van
-- *
-- ****************************************************************************
RcVanExtension = inherit(Singleton)

addRemoteEvents{"RVE:outOfRange", "RVE:withinRange"}
function RcVanExtension:constructor()

    addEventHandler("RVE:outOfRange", root, bind(self.Event_start, self))
    addEventHandler("RVE:withinRange", root, bind(self.Event_stop, self))
end

function RcVanExtension:Event_start()
    self.m_Render = bind(self.outOfRange, self)
	addEventHandler("onClientRender", root, self.m_Render)
end

function RcVanExtension:Event_stop()
    removeEventHandler("onClientRender", root, self.m_Render)
end

function RcVanExtension:outOfRange()
	local offsetX, offsetY = math.random(1,15), math.random(1,15)
    local fade = math.random(20, 120)
	dxDrawImage(-offsetX, -offsetY, screenWidth+15, screenHeight+15, "files/images/Other/slender.jpg", 0, 0, 0, tocolor(255, 255, 255, fade), true)
end