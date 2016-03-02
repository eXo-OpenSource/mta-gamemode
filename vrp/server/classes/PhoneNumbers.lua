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
	self:loadNumbers()
	addRemoteEvents{"requestPhoneNumbers"}
	addEventHandler("requestPhoneNumbers", root, bind(self.Event_requestNumbers, self))
end

function PhoneNumbers:loadNumbers()
	local result = sql:queryFetch("SELECT * FROM ??_phone_numbers", sql:getPrefix())
	for k, row in ipairs(result) do
		self:loadSingleNumber(row.Number, row.OwnerType, row.Owner)
	end
end

function PhoneNumbers:loadSingleNumber(number, typeId, ownerId)
	local owner = false
	if typeId == 1 then
		owner = DatabasePlayer.get(ownerId)
	elseif typeId == 2 then
		owner = FactionManager:getFromId(ownerId)
	elseif typeId == 3 then
		owner = CompanyManager:getFromId(ownerId)
	elseif typeId == 4 then
		owner = GroupManager:getFromId(ownerId)
	end

	self.m_PhoneNumbers[number] = {}
	self.m_PhoneNumbers[number]["type"] = PHONE_NUMBER_TYPES[typeId]
	self.m_PhoneNumbers[number]["ownerId"] = ownerId

	if owner then
	--if owner and owner:getName() then
		self.m_PhoneNumbers[number]["owner"] = owner
		--self.m_PhoneNumbers[number]["ownerName"] = owner:getName()
		self.m_PhoneNumbers[number]["ownerId"] = ownerId
	else
		outputDebugString("Owner not found! Type: "..PHONE_NUMBER_TYPES[typeId].." Number: "..number.." ID: "..ownerId)
	end
end

function PhoneNumbers:loadOrGenerateNumber(type, ownerId)
	if not self:getNumber(type, ownerId) then
		return self:generateNumber(type, ownerId)
	end
end

function PhoneNumbers:getNumber(type, ownerId)
	for index, num in pairs(self.m_PhoneNumbers) do
		if num["type"] == type and num["ownerId"] == ownerId then
			return index
		end
	end
	return false
end

function PhoneNumbers:generateNumber(type, owner)
	local number = ""
	for i=0, PHONE_NUMBER_LENGTH[type]-1 do
		number = tonumber(number..math.random(0, 9))
	end
	if self:checkNumber(number) == false then
		return self:saveNumber(number, type, owner)
	else
		self:generateNumber(type, owner)
	end
end

function PhoneNumbers:saveNumber(number, type, ownerId)
	local typeId = 0
	for index, key in pairs(PHONE_NUMBER_TYPES) do
		if key == type then
			typeId = index
		end
	end
	outputDebug("Saved PhoneNumber "..number.." Typ: "..typeId.." Owner: "..ownerId)

	sql:queryFetch("INSERT INTO ??_phone_numbers (Number, OwnerType, Owner) VALUES (?, ?, ?)", sql:getPrefix(), number, typeId, ownerId)
	self:loadSingleNumber(number, typeId, ownerId)
	return number
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

function PhoneNumbers:Event_requestNumbers()
	client:triggerEvent("receivePhoneNumbers", self.m_PhoneNumbers)
end
