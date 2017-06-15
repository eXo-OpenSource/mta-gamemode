-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/WorldItemMouseMenu.lua
-- *  PURPOSE:     provide mouse menu for world item interaction
-- *
-- ****************************************************************************
WorldItemMouseMenu = inherit(GUIMouseMenu)
WorldItemInformationMouseMenu = inherit(GUIMouseMenu)

function WorldItemMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1)

    self:addItem(_("Besitzer: %s", tostring(element:getData("Owner")))):setTextColor(Color.Red)
	
	self:addItem(_("Objekt: %s", tostring(element:getData("Name")))):setTextColor(Color.LightBlue)

	self:addModelSpecificItems(element)

	if self:hasPermissionTo("moveWorldItem", element) then
		self:addItem(_"Verschieben", -- maybe some other day
			function()
				if self:getElement() then
					triggerServerEvent("worldItemMove", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Arrows)
	end

	if self:hasPermissionTo("", element) then
		self:addItem(_"Aufheben",
			function()
				if self:getElement() then
					triggerServerEvent("worldItemCollect", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Double_Up)
	end

	if self:hasPermissionTo("deleteWorldItem", element) then
		self:addItem(_"Löschen",
			function()
				if self:getElement() then
					triggerServerEvent("worldItemDelete", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Trash)
	end

	if self:hasPermissionTo("showWorldItemInformation", element) then
        self:addItem(_"Informationen >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(WorldItemInformationMouseMenu:new(posX, posY, self:getElement()), self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Info)
    end
	self:adjustWidth()
end

function WorldItemMouseMenu:addModelSpecificItems(element)
	local model = getElementModel(element)
	if model == 2226 then -- Radio
		if self:hasPermissionTo("showWorldItemInformation", element) then
			self:addItem(_"Musik ändern",
				function()
					if element then
						StreamGUI:new("Musik ändern", function(url) triggerServerEvent("itemRadioChangeURL", element, url) end, function() triggerServerEvent("itemRadioStopSound", element) end)
					end
				end
			):setIcon(FontAwesomeSymbols.Music)
		end
	elseif model == 1238 then -- Warnkegel
		if self:hasPermissionTo("", element) then
			self:addItem(_"Warnleuchte",
				function()
					if element then
						triggerServerEvent("worldItemToggleConeLight", element)
					end
				end
			):setIcon(FontAwesomeSymbols.Lightbulb)
		end
	elseif model == 3902 then -- Blitzer
		if self:hasPermissionTo("", element) then
			self:addItem(_("Einnahmen: %d$", element:getData("earning"))):setTextColor(Color.LightBlue)
		end
	end
end


function WorldItemMouseMenu:hasPermissionTo(action, element)
	if ADMIN_RANK_PERMISSION[action] then
		if localPlayer:getRank() >= ADMIN_RANK_PERMISSION[action] then 
			return true 
		else 
			return false 
		end
	end
	local superUserName = element:getData("SuperOwner") and element:getData("Owner") or element:getData("Placer")
	return (localPlayer:getName() == superUserName or localPlayer:getFaction():getShortName() == superUserName) 
end


function WorldItemInformationMouseMenu:constructor(posX, posY, element)
    GUIMouseMenu.constructor(self, posX, posY, 300, 1)

    self:addItem(_("Ersteller: %s", element:getData("Placer"))):setTextColor(Color.White)
    self:addItem(_("Zeit: %s", getOpticalTimestamp(element:getData("PlacedTimestamp")))):setTextColor(Color.White)
    self:addItem(_("min. Rang: %s", element:getData("MinRank") or 0)):setTextColor(Color.White)
    self:addItem(_("Superowner: %s", element:getData("SuperOwner") and element:getData("Owner") or element:getData("Placer"))):setTextColor(Color.White)
	self:addItem(_("Model: %s", tostring(getElementModel(element)))):setTextColor(Color.White)

	self:adjustWidth()
end