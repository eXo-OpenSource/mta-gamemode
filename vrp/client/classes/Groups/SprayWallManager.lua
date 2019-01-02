-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/SprayWallManager.lua
-- *  PURPOSE:     SprayWall manager class
-- *
-- ****************************************************************************
SprayWallManager = inherit(Singleton)

function SprayWallManager:constructor()
	self.m_Map = {}
	self.m_Font = VRPFont(32, Fonts.Ghetto) --dxCreateFont("files/fonts/Ghetto.ttf", 20, false)

	for i, info in ipairs(SprayWallData) do
		self.m_Map[i] = SprayWall:new(i, info.wallPosition, info.wallRotation)
	end

	addRemoteEvents{ "SprayWallOnGroupNameChange"}
	addEventHandler("SprayWallOnGroupNameChange", root, bind(self.Event_onGroupChangeName, self))
end

function SprayWallManager:getFont()
	return getVRPFont(self.m_Font)
end

function SprayWallManager:Event_onGroupChangeName(oldname, newname)
	for i, v in pairs(self.m_Map) do
		local ele = getElementByID("SprayWall"..v.m_Id)
		if isElement(ele) then
			if getElementData(ele, "OwnerName") == oldname then
				setElementData(ele, "OwnerName", newname)

				v.m_OldTagText = ""
				v.m_TagText = newname
			end
		end
	end
end
