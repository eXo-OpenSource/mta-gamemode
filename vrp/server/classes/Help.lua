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
	local query = sql:queryFetch("SELECT h2.Title as Category, h1.Title, h1.Text FROM ??_help h1 INNER JOIN ??_help h2 ON h2.Id = h1.Parent WHERE h1.Parent IS NOT NULL ORDER BY h2.SortId, h1.SortId ASC", sql:getPrefix(), sql:getPrefix())

    self.m_HelpTexts = {}

    local lastCategory = nil
    local data = nil

	for key, value in pairs(query) do

        if lastCategory ~= value["Category"] then
            if data then
                table.insert(self.m_HelpTexts, data)
            end
            lastCategory = value["Category"]

            data = {category = value["Category"], childs = {}}
        end

        table.insert(data.childs,{
            title = utf8.escape(value["Title"]),
            text = utf8.escape(value["Text"])
        })
	end

    if data then
        table.insert(self.m_HelpTexts, data)
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
