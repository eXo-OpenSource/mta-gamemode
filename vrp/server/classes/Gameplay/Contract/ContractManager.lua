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
	--> Id - PK
	--> SellerId - group or player
	--> SellerType 	 - 1 = player, 2 = group
	--> Contractor - FK
	--> ContractType - 1 = sell, 2 = rent, 3 = credit
	--> FinishedAt
	--> CreatedAt

	vrp_contracts_data
	--> ContractId - PK
	--> DataKey    - PK
	--> Data

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
	contractor   = player
	data		 = {}
]]
function ContractManager:createContract(contractType, seller, contractor, data)
	if contractType == CONTRACT_TYPES.Sell then
		return SellContract.create(seller, contractor, data)
	elseif contractType == CONTRACT_TYPES.Rent then
		return RentContract.create(seller, contractor, data)
	elseif contractType == CONTRACT_TYPES.Credit then
		return CreditContract.create(seller, contractor, data)
	else
		return false
	end
end

function ContractManager:destructor()
end
