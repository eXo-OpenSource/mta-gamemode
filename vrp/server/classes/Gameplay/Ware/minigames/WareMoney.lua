-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareMoney.lua
-- *  PURPOSE:     Ware Money class
-- *
-- ****************************************************************************
WareMoney = inherit(Object)
WareMoney.modeDesc = "Sammel 6000 Dollar ein!"
WareMoney.time = 1

function WareMoney:constructor( super )
	self.m_Super = super
	self.m_Super.m_Successors = {}
	for key, p in ipairs(self.m_Super.m_Players) do 
		p:setData("ware:money",0)
	end
	self.m_OnPickupHit = bind(self.onCollectPickup, self)
	addEventHandler("onPickupHit", root, self.m_OnPickupHit)
	self:createMoneyAround()
end

function WareMoney:createMoneyAround()
	if self.m_Super.m_Arena then 
		local x,y,z,width,height = unpack(self.m_Super.m_Arena)
		local moneyAmount = math.floor(#self.m_Super.m_Players / 2)
		if moneyAmount == 0 then 
			moneyAmount = 1
		end
		self.m_MoneyPickupTable = {}
		if x and y and z and width and height then 
			for i = 1, moneyAmount*4 do 
				self.m_MoneyPickupTable[#self.m_MoneyPickupTable+1] = createPickup((x+5)+ math.random(0,width-5), (y+5)+ math.random(0,height-5), z+1, 3, 1212)
				self.m_MoneyPickupTable[#self.m_MoneyPickupTable]:setData("ware:money", true)
				setElementDimension(self.m_MoneyPickupTable[#self.m_MoneyPickupTable],self.m_Super.m_Dimension)
			end
		end
	end
end

function WareMoney:onCollectPickup( player )
	local isWareMoney = source:getData("ware:money")
	if isWareMoney then 
		if player:getDimension() == source:getDimension() then 
			player:setData("ware:money", (player:getData("ware:money") or 0)+1500)
			if player:getData("ware:money") >= 6000 then 
				self.m_Super:addPlayerToWinners( player )
			end
		end
	end
end

function WareMoney:destructor()
	local cash 
	for i = 1,#self.m_MoneyPickupTable do 
		cash = self.m_MoneyPickupTable[i]
		if cash then 
			destroyElement(cash)
		end
	end
	removeEventHandler("onPickupHit", root, self.m_OnPickupHit)
end