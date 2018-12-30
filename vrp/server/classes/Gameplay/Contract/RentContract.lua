-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Contract/RentContract.lua
-- *  PURPOSE:     RentContract class
-- *
-- ****************************************************************************
RentContract = inherit(Contract)


--[[
	data = [
        objectType = "vehicle", -- vehicle or service,
        objectId = 23123 -- only for vehicle
		objectAmount = 1, -- for service only
        upFrontPayment = 1000,
        paymentAmount = 100,
		paymentInterval = 0, -- 0 = ever payday, or every x day count
		duration = 1 -- in hours
	]
]]
function RentContract.create(sellerId, sellerType, buyerId, buyerType, data)

	-- only allow B2C
	if buyerType ~= 1 or sellerType ~= 2 then
		return false
    end

    if data.objectType == "vehicle" then
        if not data.objectid then
            return false
        end
        -- TODO: check if vehicle exists
	elseif data.objectType == "service" then
		if data.objectAmount < 0 then
			return false
		end
	else
		return false
	end

	if data.upFrontPayment <= 0 then
		return false
	end

	if data.paymentAmount <= 0 then
		return false
    end

    if data.upFrontPayment == 0 and data.paymentAmount == 0 then
        return false
    end

	-- Create contract
	local id = Contract.create(sellerId, sellerType, buyerId, buyerType, CONTRACT_TYPES.Sell)
	local rentContract = RentContract:new(id, sellerId, sellerType, buyerId, buyerType, CONTRACT_TYPES.Sell)
	rentContract:storeData(data)
	-- Contract.create(sellerId, sellerType, contractor, contractType)
	-- local id = Contract.create(CONTRACT_TYPES.Sell, seller, contractor)
	-- sql:

	--[[
		- Object (Item (Player/Group), Vehicle (Player/Group), House (Player/Group), Shop (Group), Property (Group), 'virtual service' (Group))
		- Amount for items
		- Amount of cash
	]]
	return rentContract
end

function RentContract:isElementInContract(id, type)
    if self.m_Data.objectType == "vehicle" and type == "vehicle" then
        if self.m_Data.objectId == id then
            return true
        end
    end
	return false
end
