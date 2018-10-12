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

function Contract:constructor(id)
	sql:queryFetch(Async.waitFor(self), "SELECT * FROM ??_contracts WHERE Id = ?",
		sql:getPrefix(), id)

	local result = Async.wait()
	local data = result[0]
	if data then
		self.m_Id = data.Id
		self.m_SellerId = data.SellerId
		self.m_SellerType = data.SellerType
		self.m_BuyerId = data.BuyerId
		self.m_BuyerType = data.BuyerType
		self.m_ContractType = data.ContractType
	end
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

function Contract:storeData(data)
	if not self.m_Data then self.m_Data = {} end
	outputServerLog("storing stuff")
	outputServerLog(inspect(data))
	self.m_Data = data
	self:save()
end