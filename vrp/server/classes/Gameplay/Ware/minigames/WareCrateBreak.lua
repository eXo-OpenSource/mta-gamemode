-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareCrateBreak.lua
-- *  PURPOSE:     WareCrateBreak class
-- *
-- ****************************************************************************
WareCrateBreak = inherit(Object)
WareCrateBreak.modeDesc = "Vernichte eine Kiste!"
WareCrateBreak.timeScale = 1
addEvent("onCrateDestroyed",true)
local allowedWeapons = 
{
	0,9,25,31,35,38,
}

function WareCrateBreak:constructor( super )
	self.m_Super = super
	self.m_Super.m_Successors = {}
	self.m_CrateBrake = bind(self.onBreakCrate, self)
	addEventHandler("onCrateDestroyed", root, self.m_CrateBrake)
	self:createCrates()
end

function WareCrateBreak:createCrates()
	if self.m_Super.m_Arena then 
		local x,y,z,width,height = unpack(self.m_Super.m_Arena)
		local crateAmount = math.floor(#self.m_Super.m_Players / 2)
		if crateAmount == 0 then 
			crateAmount = 1
		end
		self.m_CrateTable = {}
		local dummy_car = createVehicle(411,x,y,z)
		setElementAlpha(dummy_car,0)
		local cx,cy,cz
		setElementDimension(dummy_car,self.m_Super.m_Dimension)
		if x and y and z and width and height then 
			for i = 1, crateAmount do 
				self.m_CrateTable[#self.m_CrateTable+1] = createObject(1224,(x+5)+ math.random(0,width-5), (y+5)+ math.random(0,height-5), z+1)
				cx,cy,cz = getElementPosition(self.m_CrateTable[#self.m_CrateTable])
				setElementPosition(dummy_car,cx,cy,cz)
				setElementFrozen(self.m_CrateTable[#self.m_CrateTable],false)
				setElementVelocity(self.m_CrateTable[#self.m_CrateTable],0,0,0.1)
				self.m_CrateTable[#self.m_CrateTable]:setData("ware:crate", true)
				setElementDimension(self.m_CrateTable[#self.m_CrateTable],self.m_Super.m_Dimension)
			end
		end
		destroyElement(dummy_car)
		local randWeap = allowedWeapons[math.random(1, #allowedWeapons)]
		for key, p in ipairs(self.m_Super.m_Players) do 
			giveWeapon(p, randWeap, 9999,true)
		end
	end
end

function WareCrateBreak:onBreakCrate( crate )
	if crate then 
		if isElement(crate) then 
			if crate:getData("ware:crate") then
				if source.bInWare then
					if source.bInWare == self.m_Super then
						self.m_Super:addPlayerToWinners( source ) 
						destroyElement(crate)
					end
				end
			end
		end
	end
end

function WareCrateBreak:destructor()
	for i = 1, #self.m_CrateTable do 	
		if self.m_CrateTable[i] then 
			if isElement(self.m_CrateTable[i]) then
				destroyElement(self.m_CrateTable[i])
			end
		end
	end
	for key, p in ipairs(self.m_Super.m_Players) do
		takeAllWeapons(p)
	end
	removeEventHandler("onCrateDestroyed", root, self.m_CrateBrake)
end