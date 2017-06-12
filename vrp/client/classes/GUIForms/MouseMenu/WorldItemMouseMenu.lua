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

    self:addItem(_"Verschieben", -- maybe some other day
		function()
			if self:getElement() then
				triggerServerEvent("worldItemMove", self:getElement())
			end
		end
	):setIcon(FontAwesomeSymbols.Arrows)

	self:addModelSpecificItems(element)

	self:addItem(_"Aufheben",
		function()
			if self:getElement() then
				triggerServerEvent("worldItemCollect", self:getElement())
			end
		end
	):setIcon(FontAwesomeSymbols.Double_Up)

    self:addItem(_"Löschen",
        function()
            if self:getElement() then
                triggerServerEvent("worldItemDelete", self:getElement())
            end
        end
    ):setIcon(FontAwesomeSymbols.Trash)

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
	if model == 2226 then
		if self:hasPermissionTo("showWorldItemInformation", element) then
			self:addItem(_"Musik ändern",
				function()
					if self:getElement() then
						StreamGUI:new("Musik ändern", function(url) triggerServerEvent("itemRadioChangeURL", self:getElement(), url) end, function() triggerServerEvent("itemRadioStopSound", self:getElement()) end)
					end
				end
			):setIcon(FontAwesomeSymbols.Music)
		end
	end
end


function WorldItemMouseMenu:hasPermissionTo(action, element)
	if ADMIN_RANK_PERMISSION[action] and localPlayer:getRank() >= ADMIN_RANK_PERMISSION[action] then return true end
	
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