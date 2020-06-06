PickupMoney = inherit(Object)
PickupMoney.Map = { }

function PickupMoney:constructor(x, y, z, dim, int, amount)
	self.m_Entity = createPickup(x, y, z, 3, 1212, 0)
	self.m_Money = amount
	self.m_Entity:setDimension(dim)
	self.m_Entity:setInterior(int)

	addEventHandler("onPickupHit", self.m_Entity, bind(self.pickup, self))
end

function PickupMoney:pickup(player)
	if player and isElement(player) then
		if self.m_Money and self.m_Money > 0 then
			Guns:getSingleton().m_BankAccountServerCorpse:transferMoney(player, self.m_Money, "bei Leiche gefunden", "Player", "Corpse")
			self.m_Money = 0
		end
		delete(self)
	end
end

function PickupMoney:destructor()
	if self.m_Entity then
		if isElement(self.m_Entity) then
			destroyElement(self.m_Entity)
		end
	end
end
