-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
FishingRodGUI = inherit(GUIForm)
inherit(Singleton, FishingRodGUI)

addRemoteEvents{"showFishingRodGUI"}

function FishingRodGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-150, screenHeight/2-75, 300, 150)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Angelrute", true, true, self)

	--todo
	-- FishingRod condition (if added)
	-- Add baits?!
end

addEventHandler("showFishingRodGUI", root,
	function(...)
		if not FishingRodGUI:isInstantiated() then
			FishingRodGUI:new(...)
		end
	end
)
