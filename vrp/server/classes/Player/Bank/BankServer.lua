-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/BankServer.lua
-- *  PURPOSE:     Bank server class
-- *
-- ****************************************************************************
BankServer = inherit(Singleton)
BankServer.Map = {}

function BankServer:constructor()
    if #sql:queryFetch("SELECT table_name FROM information_schema.tables WHERE table_schema = ? AND table_name = ?", Config.get('mysql')['main']['database'], sql:getPrefix() .. "_server_bank_accounts") == 0 then
        sql:queryExec("CREATE TABLE ??_server_bank_accounts(Id INT PRIMARY KEY AUTO_INCREMENT, Name VARCHAR(32), BankAccount INT); CREATE UNIQUE INDEX ??_server_bank_accounts_Id_uindex ON ??_server_bank_accounts (Id);", sql:getPrefix(), sql:getPrefix(), sql:getPrefix())
    end

    self:loadAccounts()
end

function BankServer:destructor()
    self:save()
end

function BankServer:loadAccounts()
  	local result = sql:queryFetch("SELECT * FROM ??_server_bank_accounts", sql:getPrefix())
  	for k, row in pairs(result) do
        local bankAccount = BankAccount.load(row.BankAccount)
        bankAccount.m_Negative = true
		BankServer.Map[row.Name] = {row.Id, row.BankAccount, bankAccount}
	end
end

function BankServer:save()
    for k, row in pairs(self.Map) do
        row[3]:save()
	end
end

function BankServer:create(name)
    if self.Map[string.lower(name)] then
        error("BankServer.create @ WTF? name does already exist")
    end
    sql:queryExec("INSERT INTO ??_server_bank_accounts (Name, BankAccount) VALUES (?, -1)", sql:getPrefix(), string.lower(name))

    local result = sql:queryFetch("SELECT * FROM ??_server_bank_accounts WHERE Name = ?", sql:getPrefix(), string.lower(name))

    local bankAccount = BankAccount.create(BankAccountTypes.Server, result[1].Id)
    bankAccount.m_Negative = true
    sql:queryExec("UPDATE ??_server_bank_accounts SET BankAccount = ? WHERE Id = ?", sql:getPrefix(), bankAccount.m_Id, result[1].Id)

	BankServer.Map[string.lower(name)] = {result[1].Id, bankAccount.m_Id, bankAccount}

    outputServerLog(("Created server bank account for %s"):format(string.lower(name)))
    return bankAccount.m_Id
end

function BankServer:getFromName(name)
    if self.Map[string.lower(name)] then
        return self.Map[string.lower(name)][2]
    else
        return self:create(name)
    end
end

function BankServer.get(name)
    return BankAccount.Map[BankServer:getSingleton():getFromName(name)]
end