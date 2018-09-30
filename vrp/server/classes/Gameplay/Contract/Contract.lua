-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Contract/Contract.lua
-- *  PURPOSE:     Contract class
-- *
-- ****************************************************************************
Contract = inherit(Object)

function Contract.create(sellerId, sellerType, contractor, contractType)
	db:queryFetch(Async.waitFor(self), "INSERT INTO ??_contracts (SellerId, SellerType, Contractor, ContractType, CreatedAt) VALUES (?, ?, ?, ?, NOW())",
		sql:getPrefix(), sellerId, sellerType, contractor, contractType)

	local result, numrows, lastInserID = Async.wait()

	return lastInserID
end

function Contract:contructor()
end

function Contract:destructor()
end

function Contract:save()
end
