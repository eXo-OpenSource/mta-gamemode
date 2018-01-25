-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionInsurgent.lua
-- *  PURPOSE:     Insurgent Faction Class
-- *
-- ****************************************************************************

FactionInsurgent = inherit(Singleton)
local MOVE_DAY_TIME = 36*((60*1000)*60)

function FactionInsurgent:constructor() 
	self.m_Map = MapParser:new(":exo_maps/fraktionen/terroristtown.map")
	addRemoteEvents{"onTransmitterHit"}
	self.m_Map:create(0)
	local x, y, z = getElementPosition(self.m_Map:getElements(1)[1])
	local bin = createObject(1337, x, y, z) 
	setElementAlpha(bin, 0)
	setElementCollisionsEnabled(bin, false)
	for key, obj in ipairs(self.m_Map.m_Maps[1]) do 
		if isElement(obj) then
			attachRotationAdjusted ( obj, bin)
		end
	end
	self.m_MapIslandRoot = bin
	createBlipAttachedTo(bin, 0, 2, 200, 0, 0)
	moveObject(bin, MOVE_DAY_TIME/2, -1*math.random(4819, 6000), -3000, z) 
	setTimer(moveObject, MOVE_DAY_TIME/2, 1, bin, MOVE_DAY_TIME/2, -1*math.random(4819, 6000), 3000, z)

end

function FactionInsurgent:getIslandPosition() 
	local x, y, z = getElementPosition(self.m_MapIslandRoot) 
	return x, y, z
end

function FactionInsurgent:Event_onTransmitterHit() 

end

function FactionInsurgent:destructor() 

end

