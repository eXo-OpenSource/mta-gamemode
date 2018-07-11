-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PhoneNumbers.lua
-- *  PURPOSE:     Phone Numbers class
-- *
-- ****************************************************************************
PhoneNumber = inherit(Object)
PhoneNumber.Map = {}
addRemoteEvents{"requestPhoneNumbers"}

PHONE_NUMBER_TYPES = {[1] = "player", [2] = "faction", [3] = "company", [4] = "group"}
for i, v in pairs(PHONE_NUMBER_TYPES) do
	PHONE_NUMBER_TYPES[v] = i
end

PHONE_NUMBER_LENGTH = {[1] = 6, [2] = 3, [3] = 3, [4] = 4}

function PhoneNumber.generateNumber(OwnerType, OwnerId)
	local number = ""
	for i=0, PHONE_NUMBER_LENGTH[OwnerType]-1 do
		number = tonumber(number..math.random(0, 9))
	end
	if PhoneNumber.getInstance(number) == false then
		return PhoneNumber.create(number, OwnerType, OwnerId)
	else
		PhoneNumber.generateNumber(OwnerType, OwnerId)
	end
end

function PhoneNumber.getInstance(number)
	for Id, v in pairs(PhoneNumber.Map) do
		if v:getNumber() == number then
			return v
		end
	end

	return false
end

function PhoneNumber.create(Number, OwnerType, OwnerId)
	sql:queryExec("INSERT INTO ??_phone_numbers(Number, OwnerType, OwnerId) VALUES (?, ?, ?);", sql:getPrefix(), Number, OwnerType, OwnerId)

	local Id = sql:lastInsertId()
	PhoneNumber.Map[Id] = PhoneNumber:new(Id, Number, OwnerType, OwnerId)
	return PhoneNumber.Map[Id]
end

function PhoneNumber.load(OwnerType, OwnerId)
    local row = sql:queryFetchSingle("SELECT Id, Number FROM ??_phone_numbers WHERE OwnerType = ? AND OwnerId = ?;", sql:getPrefix(), OwnerType, OwnerId)
    if not row then
      return false
    end

    PhoneNumber.Map[row.Id] = PhoneNumber:new(row.Id, row.Number, OwnerType, OwnerId)
    return PhoneNumber.Map[row.Id]
end

function PhoneNumber.unload(OwnerType, OwnerId)
    local row = sql:queryFetchSingle("SELECT Id, Number FROM ??_phone_numbers WHERE OwnerType = ? AND OwnerId = ?;", sql:getPrefix(), OwnerType, OwnerId)
    if not row then
      return false
    end
	if PhoneNumber.Map[row.Id] then
    	PhoneNumber.Map[row.Id] = nil
	end
end

function PhoneNumber:constructor(Id, Number, OwnerType, OwnerId)
	self.m_Id = Id
	self.m_Number = Number
	self.m_OwnerType = OwnerType
	self.m_OwnerId = OwnerId
end

function PhoneNumber:destructor()
end

function PhoneNumber:setNumber(Number)
	self.m_Number = Number
	sql:queryExec("UPDATE ??_phone_numbers SET Number = ? WHERE Id = ?;", sql:getPrefix(), self.m_Number, self.m_Id)
end

function PhoneNumber:getId()
	return self.m_Id
end

function PhoneNumber:getNumber()
	return self.m_Number
end

function PhoneNumber:getOwnerType()
	return self.m_OwnerType
end

function PhoneNumber:getOwner(instance)
	if not instance then
		return self.m_OwnerId, self.m_OwnerType
	end

	if self.m_OwnerType == PHONE_NUMBER_TYPES.player then
		local player = Player.getFromId(self.m_OwnerId)
		if player then
			return player
		else
			return false
		end
	elseif self.m_OwnerType == PHONE_NUMBER_TYPES.faction then
		return FactionManager:getSingleton():getFromId(self.m_OwnerId)
	elseif self.m_OwnerType == PHONE_NUMBER_TYPES.company then
		return CompanyManager:getSingleton():getFromId(self.m_OwnerId)
	elseif self.m_OwnerType == PHONE_NUMBER_TYPES.group then
		return GroupManager:getSingleton():getFromId(self.m_OwnerId)
	end
end

addEventHandler("requestPhoneNumbers", root, function()
	local number
	local numTable = {}
	for index, instance in pairs(PhoneNumber.Map) do
		number = instance:getNumber()
		if number then
			if PHONE_NUMBER_TYPES[instance:getOwnerType()] == "faction" or PHONE_NUMBER_TYPES[instance:getOwnerType()] == "company" then
				numTable[number] = {}
				numTable[number]["OwnerName"] = instance:getOwner(instance):getShortName()
			elseif PHONE_NUMBER_TYPES[instance:getOwnerType()] == "group" then
				if instance:getOwner(instance) and instance:getOwner(instance):getName() then
					if #instance:getOwner(instance):getOnlinePlayers() > 0 then
						numTable[number] = {}
						numTable[number]["OwnerName"] = instance:getOwner(instance):getName()
					end
				else
					PhoneNumber.Map[index] = nil
				end
			else
				if instance:getOwner(instance) and instance:getOwner(instance):getName() then
					numTable[number] = {}
					numTable[number]["OwnerName"] = instance:getOwner(instance):getName()
				else
					PhoneNumber.Map[index] = nil
				end
			end

			if numTable[number] then
				numTable[number]["OwnerType"] = PHONE_NUMBER_TYPES[instance:getOwnerType()]
			end
		end
	end
	triggerClientEvent(client, "receivePhoneNumbers", client, numTable)
end)
