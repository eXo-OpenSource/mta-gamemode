-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Contract/Contract.lua
-- *  PURPOSE:     Contract class
-- *
-- ****************************************************************************
Contract = inherit(Object)

function Contract.create(sellerId, sellerType, buyerId, buyerType, contractType)
	sql:queryFetch(Async.waitFor(self), "INSERT INTO ??_contracts (SellerId, SellerType, BuyerId, BuyerType, ContractType, CreatedAt) VALUES (?, ?, ?, ?, ?, NOW())",
		sql:getPrefix(), sellerId, sellerType, buyerId, buyerType, contractType)

	local result, numrows, lastInserID = Async.wait()

	return lastInserID
end

function Contract.load(id)
	sql:queryFetch(Async.waitFor(self), "SELECT * FROM ??_contracts WHERE Id = ?",
		sql:getPrefix(), id)

		
	local result = Async.wait()
	
	local data = result[1]
	if data then
		if data.ContractType == CONTRACT_TYPES.Sell then
			return SellContract:new(data.Id, data.SellerId, data.SellerType, data.BuyerId, data.BuyerType, data.ContractType)
		elseif data.ContractType == CONTRACT_TYPES.Rent then
			return RentContract:new(data.Id, data.SellerId, data.SellerType, data.BuyerId, data.BuyerType, data.ContractType)
		elseif data.ContractType == CONTRACT_TYPES.Credit then
			return CreditContract:new(data.Id, data.SellerId, data.SellerType, data.BuyerId, data.BuyerType, data.ContractType)
		end
	else
		return false
	end
	
end

function Contract:constructor(id, sellerId, sellerType, buyerId, buyerType, contractType)
	self.m_Id = id
	self.m_SellerId = sellerId
	self.m_SellerType = sellerType
	self.m_BuyerId = buyerId
	self.m_BuyerType = buyerType
	self.m_ContractType = contractType

	self:getData()
end

function Contract:destructor()
end

function Contract:save()
	outputServerLog("starting saving")
	for k, v in pairs(self.m_Data) do
		sql:queryFetch(Async.waitFor(self), "SELECT * FROM ??_contracts_data WHERE ContractId = ? AND DataKey = ?",
			sql:getPrefix(), self.m_Id, k)
		outputServerLog(tostring(k).. " " .. tostring(v))
		local result, numrows = Async.wait()
		
		if numrows == 0 then
			outputServerLog("dafuq")
			outputServerLog(tostring(self.m_Id) .. " " .. tostring(k) .. " " .. tostring(v))
			sql:queryFetch(Async.waitFor(self), "INSERT INTO ??_contracts_data (ContractId, DataKey, Data) VALUES (?, ?, ?)",
				sql:getPrefix(), self.m_Id, k, v)
		else
			sql:queryFetch(Async.waitFor(self), "UPDATE ??_contracts_data SET Data = ? WHERE ContractId = ? AND DataKey = ?",
				sql:getPrefix(), v, self.m_Id, k)
		end

		Async.wait()
	end
end

function Contract:getData()
	if not self.m_Data then self.m_Data = {} end
	sql:queryFetch(Async.waitFor(self), "SELECT ??_contracts_data WHERE ContractId = ?",
		sql:getPrefix(), v, self.m_Id, k)

	local result = Async.wait()

	for k, v in pairs(result) do
		self.m_Data[v.DataKey] = v.Data
	end
end

function Contract:storeData(data)
	if not self.m_Data then self.m_Data = {} end
	outputServerLog("storing stuff")
	outputServerLog(inspect(data))
	self.m_Data = data
	self:save()
end

function Contract:isElementInContract(id, type)
	return false
end