LogGUI = inherit(GUIForm)
LogGUI.AmountPerLoad = 150

function LogGUI:constructor(parent, url)
	local yOffset = 0
	if not parent then
		GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
		self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Logs", true, true, self)
		self.m_Window:deleteOnClose(true)
		parent = self.m_Window
		yOffset = 40
	end

	self.m_Url = url

	GUILabel:new(parent.m_Width*0.02, parent.m_Height*0.02+yOffset, parent.m_Width*0.2, parent.m_Height*0.08, _"Filter:", parent)
	self.m_Filter = GUIChanger:new(parent.m_Width*0.15, parent.m_Height*0.02+yOffset, parent.m_Width*0.25, parent.m_Height*0.07, parent)
	GUILabel:new(parent.m_Width*0.44, parent.m_Height*0.02+yOffset, parent.m_Width*0.2, parent.m_Height*0.08, _"Suche:", parent)
	self.m_Search = GUIEdit:new(parent.m_Width*0.55, parent.m_Height*0.02+yOffset, parent.m_Width*0.2, parent.m_Height*0.07, parent)
	self.m_SearchButton = GUIButton:new(parent.m_Width*0.78, parent.m_Height*0.02+yOffset, parent.m_Width*0.2, parent.m_Height*0.07, _"Suchen", parent):setBarEnabled(true)
	self.m_SearchButton.onLeftClick = function() self:setSearch() end
	self.m_Filter.onChange = function(text, index) self:setFilter(text) end
	self.m_Categories = {}
	self.m_LogGrid = GUIGridList:new(parent.m_Width*0.02, parent.m_Height*0.1+yOffset, parent.m_Width*0.96, parent.m_Height*0.87-yOffset, parent)
	self.m_LogGrid:setFont(VRPFont(20))
	self.m_LogGrid:setItemHeight(20)
	self.m_LogGrid:addColumn("Zeit", 0.2)
	self.m_LogGrid:addColumn("Beschreibung", 0.8)
	self.m_LogGrid:onScrollDown(bind(self.onScrollDown, self))
	self:updateLog(0, 100)
end

function LogGUI:updateLog(start, amount)
	self.m_Cache = {}

	local options = {
		["postData"] =  ("secret=%s"):format("8H041OAyGYk8wEpIa1Fv")
	}

	local url = ("%s&start=%d&amount=%d"):format(self.m_Url, start, amount)
	--outputChatBox( url)
	fetchRemote(url, options,
			function(responseData, responseInfo)
				self.m_Cache = fromJSON(responseData)
				if self.m_Cache then
					self.m_Cache = table.setIndexToInteger(self.m_Cache)
					self:refreshGrid()
				end
			end
		)
end

function LogGUI:addBackButton(callBack)
	if self.m_Window then
		self.m_Window:addBackButton(function () callBack() delete(self) end)
	end
end

function LogGUI:onScrollDown()
	self:updateLog(#self.m_LogGrid:getItems(), LogGUI.AmountPerLoad)
end


function LogGUI:refreshGrid()
	local item
	for i, row in ipairs(self.m_Cache) do
		if not self.m_Categories[row.Category] then self.m_Categories[row.Category] = true end
		local timeOptical = self:getOpticalTimestamp(row.Timestamp)

		if self:checkCatFilter(row.Category) then
			if self:checkSeachFilter(row) then
				item = self.m_LogGrid:addItem(timeOptical, ("%s %s"):format(row.UserName, row.Description))
				item:setFont(VRPFont(20))
			end
		end
	end
	self.m_Cache = {}
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

function LogGUI:setSearch()
	if self.m_Search:getText() == "" then
		self.m_SeachFilter = nil
	else
		self.m_SeachFilter = self.m_Search:getText()
	end
	self.m_LogGrid:clear()
	self:updateLog(0, LogGUI.AmountPerLoad)
end

function LogGUI:checkSeachFilter(row)
	if self.m_SeachFilter then
		if string.find(string.lower(row.Description), string.lower(self.m_SeachFilter)) or string.find(string.lower(row.UserName), string.lower(self.m_SeachFilter)) then
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
	self.m_LogGrid:clear()
	self:updateLog(0, LogGUI.AmountPerLoad)
end


function LogGUI:getOpticalTimestamp(ts)
	local time = getRealTime(ts)
	local month = time.month+1
	local year = time.year-100
	return tostring(time.monthday.."."..month.."."..year.."-"..time.hour..":"..time.minute)
end
