-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Contract/ContractManager.lua
-- *  PURPOSE:     Contract manager class
-- *
-- ****************************************************************************
ContractManager = inherit(Singleton)

--[[



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

function ContractManager:destructor()
end
