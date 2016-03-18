LogGUI = inherit(GUIForm)

function LogGUI:constructor(parent, log, players)
	self.m_Log = log
	self.m_Players = players
	GUILabel:new(parent.m_Width*0.02, parent.m_Height*0.02, parent.m_Width*0.2, parent.m_Height*0.08, _"Filter:", parent)
	self.m_Filter = GUIChanger:new(parent.m_Width*0.2, parent.m_Height*0.02, parent.m_Width*0.25, parent.m_Height*0.07, parent)
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
		if self.m_CatFilter then
			if self.m_CatFilter == row.Category then
				self:addLine(row)
			end
		else
			self:addLine(row)
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
		outputChatBox(key)
		self.m_Filter:addItem(key)
	end
	self.m_FilterLoaded = true
end

function LogGUI:addLine(row)
	timeOptical = self:getOpticalTimestamp(row.Timestamp)
	playerName = "[Unbekannt]"
	if self.m_Players[row.UserId] then
		playerName = self.m_Players[row.UserId].name
	end
	self.m_Text = self.m_Text..timeOptical.." - "..playerName.." "..row.Description.."\n"
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
