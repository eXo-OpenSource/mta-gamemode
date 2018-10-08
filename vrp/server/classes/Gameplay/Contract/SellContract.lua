-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Contract/SellContract.lua
-- *  PURPOSE:     SellContract class
-- *
-- ****************************************************************************
SellContract = inherit(Contract)

--[[
	data = [
		objectType = "item", -- item, vehicle, house, shop, property or service,
		objectAmount = 1, -- for object and service only
		moneyAmount = 1000 
	]
]]
function SellContract.create(sellerId, sellerType, buyerId, buyerType, data)

	if data.objectType == "item" then
		-- only allow B2C and C2C
		if buyerType ~= 1 then
			return false
		end
		-- require atleast one unit
		if data.objectAmount < 1 then
			return false
		end
	elseif data.objectType == "vehicle" then
		-- only allow B2C and C2C
		if buyerType ~= 1 then
			return false
		end
	elseif data.objectType == "house" then
		-- only allow B2C and C2C
		if buyerType ~= 1 then
			return false
		end
	elseif data.objectType == "shop" then
		-- only allow B2B
		if sellerType ~= 2 or buyerType ~= 2 then
			return false
		end
	elseif data.objectType == "property" then
		-- only allow B2B
		if sellerType ~= 2 or buyerType ~= 2 then
			return false
		end
	elseif data.objectType == "service" then
		-- only allow B2C
		if sellerType ~= 2 or buyerType ~= 1 then
			return false
		end
		
		if data.objectAmount < 0 then
			return false
		end
	else
		return false
	end

	-- TODO: Allow 0$ transactions?
	if data.moneyAmount < 0 then
		return false
	end


	-- Contract.create(sellerId, sellerType, contractor, contractType)
	-- local id = Contract.create(CONTRACT_TYPES.Sell, seller, contractor)
	-- sql:

	--[[
		- Object (Item (Player/Group), Vehicle (Player/Group), House (Player/Group), Shop (Group), Property (Group), 'virtual service' (Group))
		- Amount for items
		- Amount of cash
	]]
end

function SellContract:contructor()
end

function SellContract:destructor()
end

function SellContract:save()
end
