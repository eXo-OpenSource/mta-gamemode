LogGUI = inherit(GUIForm)

function LogGUI:constructor(parent, log, players)
	self.m_Log = log
	self.m_Players = players
	GUILabel:new(parent.m_Width*0.02, parent.m_Height*0.02, parent.m_Width*0.2, parent.m_Height*0.08, _"Filter:", parent)
	self.m_Filter = GUIChanger:new(parent.m_Width*0.15, parent.m_Height*0.02, parent.m_Width*0.25, parent.m_Height*0.07, parent)
	GUILabel:new(parent.m_Width*0.44, parent.m_Height*0.02, parent.m_Width*0.2, parent.m_Height*0.08, _"Suche:", parent)
	self.m_Search = GUIEdit:new(parent.m_Width*0.55, parent.m_Height*0.02, parent.m_Width*0.2, parent.m_Height*0.07, parent)
	self.m_SearchButton = GUIButton:new(parent.m_Width*0.78, parent.m_Height*0.02, parent.m_Width*0.2, parent.m_Height*0.07, _"Suchen", parent)
	self.m_SearchButton.onLeftClick = function() self:setSearch() end
	self.m_Filter.onChange = function(text, index) self:setFilter(text) end
	self.m_Categories = {}
	self.m_LogText = GUIScrollableText:new(parent.m_Width*0.02, parent.m_Height*0.1, parent.m_Width*0.98, parent.m_Height*0.8, "", parent.m_Height*0.065, parent)
	self:refresh()
end

function LogGUI:refresh()
	self.m_Text = ""
	local playerName, timeOptical
	for k, row in ipairs(self.m_Log) do
		if not self.m_Categories[row.Category] then self.m_Categories[row.Category] = true end

		playerName = "[Unbekannt]"
		if self.m_Players[row.UserId] then
			playerName = self.m_Players[row.UserId].name
		end

		if self:checkCatFilter(row.Category) then
			if self:checkSeachFilter(playerName, row) then
				self:addLine(playerName, row)
			end
		end
	end

	if not self.m_FilterLoaded then
		self:loadFilter()
	end

	self.m_LogText:setText(self.m_Text)
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
