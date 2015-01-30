-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/DrivingSchool.lua
-- *  PURPOSE:     Driving school class
-- *
-- ****************************************************************************
DrivingSchool = inherit(Singleton)

function DrivingSchool:constructor()
	self.m_TexReplace = TextureReplace:new("forlease_law", "files/images/DrivingSchool.png", false, 256, 256)
	self.m_Marker = Marker.create(-2033.1, -117.6, 1034.2, "cylinder", 1, 255, 255, 0)
	self.m_Marker:setInterior(3)
	self.m_Blip = Blip:new("DrivingSchool.png", 1052.5, -1524)
	
	addEventHandler("onClientMarkerHit", self.m_Marker,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				DrivingSchoolGUI:getSingleton():setVisible(true)
			end
		end
	)
end

function DrivingSchool:destructor()
	self.m_Marker:destroy()
end
