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

	addRemoteEvents{"requestPhoneNumbers"}
	addEventHandler("requestPhoneNumbers", root, bind(self.Event_requestNumbers, self))
end

function PhoneNumbers:loadNumbers()
	local result = sql:queryFetch("SELECT * FROM ??_phone_numbers", sql:getPrefix())
	for k, row in ipairs(result) do
		local owner
		if row.OwnerType == 1 then
			--owner = DatabasePlayer:getFromId(row.Owner)
		elseif row.OwnerType == 2 then
			owner = FactionManager:getSingleton():getFromId(row.Owner)
		elseif row.OwnerType == 3 then
			owner = CompanyManager:getSingleton():getFromId(row.Owner)
		elseif row.OwnerType == 4 then
			owner = GroupManager:getSingleton():getFromId(row.Owner)
		end
		if owner then
			self:loadSingleNumber(row.Number, row.OwnerType, owner)
		else
			outputDebugString("Error Loading Number "..row.Number)
		end
	end
end

function PhoneNumbers:loadSingleNumber(number, typeId, owner)
	--outputDebugString("Load Single Number: Type: "..PHONE_NUMBER_TYPES[typeId].." Number: "..number)
	if owner and owner:getName() then
		self.m_PhoneNumbers[number] = {}
		self.m_PhoneNumbers[number]["owner"] = owner
		self.m_PhoneNumbers[number]["type"] = PHONE_NUMBER_TYPES[typeId]
	else
		outputDebugString("Owner not found! Type: "..PHONE_NUMBER_TYPES[typeId].." Number: "..number)
	end
end

function PhoneNumbers:loadOrGenerateNumber(type, owner)
	if not self:getNumber(type, owner) then
		return self:generateNumber(type, owner)
	end
end

function PhoneNumbers:getNumber(type, owner)
	for index, num in pairs(self.m_PhoneNumbers) do
		if num["type"] == type and num["owner"]:getId() == owner:getId() then
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

function PhoneNumbers:saveNumber(number, type, owner)
	local typeId = 0
	for index, key in pairs(PHONE_NUMBER_TYPES) do
		if key == type then
			typeId = index
		end
	end
	outputDebug("Saved PhoneNumber "..number.." Typ: "..typeId.." Owner: "..owner:getId())

	sql:queryFetch("INSERT INTO ??_phone_numbers (Number, OwnerType, Owner) VALUES (?, ?, ?)", sql:getPrefix(), number, typeId, owner:getId())
	self:loadSingleNumber(number, typeId, owner)
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
