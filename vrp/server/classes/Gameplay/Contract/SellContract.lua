-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Contract/SellContract.lua
-- *  PURPOSE:     SellContract class
-- *
-- ****************************************************************************
SellContract = inherit(Contract)

function SellContract.create(seller, contractor, data)
	-- Contract.create(sellerId, sellerType, contractor, contractType)
	-- local id = Contract.create(CONTRACT_TYPES.Sell, seller, contractor)

end

function SellContract:contructor()
end

function SellContract:destructor()
end

function SellContract:save()
end
