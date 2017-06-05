-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Help.lua
-- *  PURPOSE:     Server Help Class
-- *
-- ****************************************************************************

Help = inherit(Singleton)

function Help:constructor()
	outputServerLog("Loading help texts...")
    
    addRemoteEvents{"helpCheckHash"}

    addEventHandler("helpCheckHash", root, bind(self.Event_helpCheckHash, self))

    self:loadHelpTexts()
end

function Help:loadHelpTexts()
	local query = sql:queryFetch("SELECT hc.Category, ht.Title, ht.Text FROM ??_helpCategory hc INNER JOIN ??_help ht ON ht.Category = hc.Id ORDER BY hc.SortId, ht.SortId ASC", sql:getPrefix(), sql:getPrefix())

    self.m_HelpTexts = {}

	for key, value in pairs(query) do
        if not self.m_HelpTexts[value["Category"]] then
            self.m_HelpTexts[value["Category"]] = {}
        end

        table.insert(self.m_HelpTexts[value["Category"]],{
            title = utf8.escape(value["Title"]),
            text = utf8.escape(value["Text"])
        })
	end

    self.m_HelpTexts = toJSON(self.m_HelpTexts)
    self.m_HelpHash = hash("sha1", self.m_HelpTexts)
end


function Help:Event_helpCheckHash(hash)
    if hash ~= self.m_HelpHash then
        client:triggerEvent("helpTextReceive", self.m_HelpTexts)
    end
end

function Help:destructor()

end

--[[
    CREATE TABLE `vrp`.`vrp_help` (
    `Id` INT NOT NULL AUTO_INCREMENT,
    `SortId` INT NULL,
    `Category` INT NOT NULL,
    `Title` VARCHAR(45) NULL,
    `Text` LONGTEXT NULL,
    PRIMARY KEY (`Id`))
    ENGINE = InnoDB;

    CREATE TABLE `vrp`.`vrp_helpCategory` (
    `Id` INT NOT NULL AUTO_INCREMENT,
    `Category` VARCHAR(45) NULL,
    `SortId` INT NULL,
    PRIMARY KEY (`Id`))
    ENGINE = InnoDB;
]]