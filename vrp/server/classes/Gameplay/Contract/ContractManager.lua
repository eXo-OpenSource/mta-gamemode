-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Contract/ContractManager.lua
-- *  PURPOSE:     Contract manager class
-- *
-- ****************************************************************************
ContractManager = inherit(Singleton)

CONTRACT_TYPES = {
	Sell = 1,
	Rent = 2,
	Credit = 3
}
--[[

	vrp_contracts
	--> Id             - PK
	--> SellerId       - player or group
	--> SellerType 	   - 1 = player, 2 = group
	--> BuyerId        - player or group
	--> BuyerType      -  1 = player, 2 = group
	--> ContractType   - 1 = sell, 2 = rent, 3 = credit
	--> FinishedAt
	--> CreatedAt

CREATE TABLE `vrp_contracts`  (
  `Id` int(0) NOT NULL AUTO_INCREMENT,
  `SellerId` int(0) NOT NULL,
  `SellerType` int(0) NOT NULL,
  `BuyerId` int(0) NOT NULL,
  `BuyerType` int(0) NOT NULL,
  `ContractType` int(0) NOT NULL,
  `FinishedAt` datetime(0) NULL,
  `CreatedAt` datetime(0) NOT NULL,
  PRIMARY KEY (`Id`)
);

	vrp_contracts_data
	--> ContractId - PK
	--> DataKey    - PK
	--> Data

CREATE TABLE `vrp_contracts_data`  (
  `ContractId` int(0) NOT NULL,
  `DataKey` varchar(32) NOT NULL,
  `Data` text NOT NULL,
  PRIMARY KEY (`ContractId`, `DataKey`)
);
	(Example: SellingPrice = 5000)



	Types
		- Sell (simple transaction C2C or B2C)
			- Goes directly
			- Will be used for eXo Bay with an lock for the vehicle and money
			- Sell an 'virtual' service to an player (only B2C)
		- Rent (B2C)
			- Rent a vehicle to an player
			- Depost an defined bail
			- Rent a 'virtual' good to an player
		- Credit (B2C)
			- Interest
			- With an security (for example an vehicle)

	Type Data
		- Sell
			- Object (Item (Player/Group), Vehicle (Player/Group), House (Player/Group), Shop (Group), Property (Group), 'virtual service' (Group))
			- Amount for items
			- Amount of cash
		- Rent
			- Object (Vehicle or 'virtual service')
			- Amount of cash
		- Credit
			- Amount of money for credit
			- Interest
			- Paymant plan

	Contract termination
		> Only for Rent or Credit
		- Rent
			- Renter breaks the contract
				- Rentee gets his bail back
			- Rentee breaks the contract
				- Renter gets the bail
			- Contract ends with consent of both
				- Rentee gets his bail back
		- Credit
			- Borrower breaks the contract
				- If the borrower can't pay anymore the security goes over to the creditor
			- Creditor breaks the contract
				- He can't break the contract at all
			- Contract ends with consent of both
				- They can choose how it ends - one final payment or security goes to the creditor

]]

function ContractManager:constructor()
end

function ContractManager:loadContract(id)
end

--[[
	contractType = "sell" or "rent" or "credit"
	seller       = player or group (type "Firma")
	buyer   	 = player or group (type "Firma")
	data		 = {}
]]
function ContractManager:createContract(contractType, seller, buyer, data)
	local sellerId = -1
	local sellerType = -1
	local buyerId = -1
	local buyerType = -1

	if not seller then
		return false
	elseif type(seller) == "table" and instanceof(seller, Group) then
		if seller:getType() == "Firma" then
			sellerId = seller.m_Id
			sellerType = 2
		else
			return false
		end
	else
		if seller.type and seller.type == "player" then
			sellerId = seller.m_Id
			sellerType = 1
		else
			return false
		end
	end

	if not buyer then
		return false
	elseif type(buyer) == "table" and instanceof(buyer, Group) then
		if buyer:getType() == "Firma" then
			buyerId = buyer.m_Id
			buyerType = 2
		else
			return false
		end
	else
		if buyer.type and buyer.type == "player" then
			buyerId = buyer.m_Id
			buyerType = 1
		else
			return false
		end
	end


	if contractType == CONTRACT_TYPES.Sell then
		return SellContract.create(sellerId, sellerType, buyerId, buyerType, data)
	elseif contractType == CONTRACT_TYPES.Rent then
		return RentContract.create(sellerId, sellerType, buyerId, buyerType, data)
	elseif contractType == CONTRACT_TYPES.Credit then
		return CreditContract.create(sellerId, sellerType, buyerId, buyerType, data)
	else
		return false
	end
end

function ContractManager:destructor()
end

addCommandHandler("ccon", function()

	Async.create(
		function ()
			outputServerLog("Testi")
			local con = SellContract.create(1, 1, 1, 1, {objectType = "item", objectAmount = 1, moneyAmount = 1})
			outputServerLog(tostring(con))
			outputServerLog("Laterli")
		end
	)()

end)