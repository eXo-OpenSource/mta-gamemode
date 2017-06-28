LogGUI = inherit(GUIForm)

function LogGUI:constructor(parent, log, players)
	self.m_Log = log
	self.m_Players = players
	GUILabel:new(parent.m_Width*0.02, parent.m_Height*0.02, parent.m_Width*0.2, parent.m_Height*0.08, _"Filter:", parent)
	self.m_Filter = GUIChanger:new(parent.m_Width*0.15, parent.m_Height*0.02, parent.m_Width*0.25, parent.m_Height*0.07, parent)
	GUILabel:new(parent.m_Width*0.44, parent.m_Height*0.02, parent.m_Width*0.2, parent.m_Height*0.08, _"Suche:", parent)
	self.m_Search = GUIEdit:new(parent.m_Width*0.55, parent.m_Height*0.02, parent.m_Width*0.2, parent.m_Height*0.07, parent)
	self.m_SearchButton = VRPButton:new(parent.m_Width*0.78, parent.m_Height*0.02, parent.m_Width*0.2, parent.m_Height*0.07, _"Suchen", true, parent)
	self.m_SearchButton.onLeftClick = function() self:setSearch() end
	self.m_Filter.onChange = function(text, index) self:setFilter(text) end
	self.m_Categories = {}
	self.m_LogGrid = GUIGridList:new(parent.m_Width*0.02, parent.m_Height*0.1, parent.m_Width*0.96, parent.m_Height*0.87, parent)
	self.m_LogGrid:setFont(VRPFont(20))
	self.m_LogGrid:setItemHeight(20)
	self.m_LogGrid:addColumn("Zeit", 0.2)
	self.m_LogGrid:addColumn("Beschreibung", 0.8)
	self:refresh()
end

function LogGUI:updateLog(players, log)
	self.m_Log = log
	self.m_Players = players
	self:refresh()
end

function LogGUI:refresh()
	self.m_LogGrid:clear()
	local item
	for _, row in ipairs(self.m_Log) do
		if not self.m_Categories[row.Category] then self.m_Categories[row.Category] = true end

		local playerName = "[?]"
		local timeOptical = self:getOpticalTimestamp(row.Timestamp)
		if self.m_Players[row.UserId] then
			playerName = self.m_Players[row.UserId].name
		end

		if self:checkCatFilter(row.Category) then
			if self:checkSeachFilter(playerName, row) and #self.m_LogGrid:getItems() < 150 then -- Todo: add user limit or pages?
				item = self.m_LogGrid:addItem(timeOptical, ("%s %s"):format(playerName, row.Description))
				item:setFont(VRPFont(20))
			end
		end
	end

	if not self.m_FilterLoaded then
		self:loadFilter()
	end
end

function LogGUI:loadFilter()
	self.m_Filter:addItem("Alle")
	for key, bool in pairs(self.m_Categories) do
		self.m_Filter:addItem(key)
	end
	self.m_FilterLoaded = true
end

function LogGUI:addLine(playerName, row)
	timeOptical = self:getOpticalTimestamp(row.Timestamp)

	self.m_Text = self.m_Text..timeOptical.." - "..playerName.." "..row.Description.."\n"
end

function LogGUI:setSearch()
	if self.m_Search:getText() == "" then
		self.m_SeachFilter = nil
	else
		self.m_SeachFilter = self.m_Search:getText()
	end
	self:refresh()
end

function LogGUI:checkSeachFilter(playerName, row)
	if self.m_SeachFilter then
		if string.find(string.lower(row.Description), string.lower(self.m_SeachFilter)) or string.find(string.lower(playerName), string.lower(self.m_SeachFilter)) then
			return true
		end
	else
		return true
	end

	return false
end

function LogGUI:checkCatFilter(cat)
	if self.m_CatFilter then
		if self.m_CatFilter == cat then
			return true
		end
	else
		return true
	end

	return false
end

function LogGUI:setFilter(text)
	if text == "Alle" then
		self.m_CatFilter = nil
	else
		self.m_CatFilter = text
	end
	self:refresh()
end


function LogGUI:getOpticalTimestamp(ts)
	local time = getRealTime(ts)
	local month = time.month+1
	local year = time.year-100
	return tostring(time.monthday.."."..month.."."..year.."-"..time.hour..":"..time.minute)
end
