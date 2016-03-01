-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PhoneNumbers.lua
-- *  PURPOSE:     Phone Numbers class
-- *
-- ****************************************************************************
PhoneNumbers = inherit(Singleton)
PHONE_NUMBER_TYPES = {[1] = "player", [2] = "faction", [3] = "company", [4] = "group"}
PHONE_NUMBER_LENGTH = {["player"] = 6, ["faction"] = 3, ["company"] = 3, ["group"] = 4}

function PhoneNumbers:constructor()
	self.m_PhoneNumbers = {}
end

function PhoneNumbers:generateNumber(type, owner)
	local number
	for i=0, PHONE_NUMBER_LENGTH[type] do
		number = number..math.random(0, 9)
	end
	if self:checkNumber(number) == false then
		self:addNumber(number, type, owner)
	else
		self:generateNumber(type, owner)
	end
end

function PhoneNumbers:addNumber(number, type, owner)
	self.m_PhoneNumbers[number] = {}
	self.m_PhoneNumbers[number]["type"] = type
	self.m_PhoneNumbers[number]["owner"] = owner
end

function PhoneNumbers:removeNumber(number)
	table.remove(self.m_PhoneNumbers, table.find(self.m_PhoneNumbers, number))
end

function PhoneNumbers:checkNumber(number)
	if self.m_PhoneNumbers[number] then return true end
	return false
end

function PhoneNumbers:getOwner(number)
	if self.m_PhoneNumbers[number] then
		return self.m_PhoneNumbers[number]["owner"], self.m_PhoneNumbers[number]["type"]
	end
	return false
end
