-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/InjurySystem/Damage.lua
-- *  PURPOSE:     Damage
-- *
-- ****************************************************************************

Damage = inherit(Object)

function Damage:constructor(id, bodypart, weapon, amount, player) 
	self.m_Id = id
	self.m_Bodypart = bodypart 
	self.m_Weapon = weapon 
	self.m_Amount = amount
	self.m_Player = player
end

function Damage:setAmount(value) self.m_Amount = value end

function Damage:getBodypart() return self.m_Bodypart end 
function Damage:getWeapon() return self.m_Weapon end 
function Damage:getPlayer() return self.m_Player end 
function Damage:getAmount() return self.m_Amount end 
function Damage:getId() return self.m_Id end

function Damage:destructor() 

end