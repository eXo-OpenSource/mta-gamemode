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
		objectType = "item", -- item, weapon, vehicle, house, shop, property or service,
		objectId = 123,
		objectAmount = 1, -- for item and service only
		moneyAmount = 1000,
		itemValue = 'X'
	]
]]
function SellContract.create(sellerId, sellerType, buyerId, buyerType, data)

	if data.objectType == "item" then
		-- only allow C2C UNTIL inventory rework then also B2C
		if sellerType ~= 1 and buyerType ~= 1 then
			return _("Gegenstände können nur zwischen Spielern gehandlet werden!")
		end
		-- require atleast one unit
		if data.objectAmount < 1 then
			return _("Die mindestmenge Beträgt 1 Stück!")
		end
		local sellerInventory = InventoryManager:getSingleton():loadInventory(sellerId)
		local buyerInventory = InventoryManager:getSingleton():loadInventory(buyerId)

		if sellerInventory:getItemAmount(data.objectId) < data.objectAmount then
			return _("Der Verkäufer hat nicht den Gegenstand mit der angegeben Menge!")
		end

		-- if buyerInventory:canReceiveItem(data.())
		-- if client:getInventory():getItemAmount(item) >= amount then

	if data.objectType == "weapon" then
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

	-- Create contract
	local id = Contract.create(sellerId, sellerType, buyerId, buyerType, CONTRACT_TYPES.Sell)
	local sellContract = SellContract:new(id, sellerId, sellerType, buyerId, buyerType, CONTRACT_TYPES.Sell)
	sellContract:storeData(data)
	-- Contract.create(sellerId, sellerType, contractor, contractType)
	-- local id = Contract.create(CONTRACT_TYPES.Sell, seller, contractor)
	-- sql:

	--[[
		- Object (Item (Player/Group), Vehicle (Player/Group), House (Player/Group), Shop (Group), Property (Group), 'virtual service' (Group))
		- Amount for items
		- Amount of cash
	]]
	return sellContract
end

function SellContract:execute()

end
--[[
function SellContract:constructor(id)
	sql:queryFetch(Async.waitFor(self), "SELECT * FROM ??_contracts WHERE Id = ?",
		sql:getPrefix(), id)

	outputServerLog("constructing")
	local result = Async.wait()
	outputServerLog(inspect(result))
	local data = result[1]
	if data then
		self.m_Id = data.Id
		self.m_SellerId = data.SellerId
		self.m_SellerType = data.SellerType
		self.m_BuyerId = data.BuyerId
		self.m_BuyerType = data.BuyerType
		self.m_ContractType = data.ContractType
	end
end

function SellContract:destructor()
end
]]
