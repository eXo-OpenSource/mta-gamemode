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
	GUIMouseMenu.constructor(self, posX, posY, 300, 0)

    self:addItem(_("Besitzer: %s", tostring(element:getData("Owner")))):setTextColor(Color.Red)
	
	self:addItem(_("Objekt: %s", tostring(element:getData("Name")))):setTextColor(Color.LightBlue)

    self:addItem(_"Verschieben",
		function()
			if self:getElement() then
				triggerServerEvent("worldItemMove", self:getElement())
			end
		end
	):setIcon(FontAwesomeSymbols.Arrows)

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

	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["showWorldItemInformation"] then
        self:addItem(_"Informationen >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(WorldItemInformationMouseMenu:new(posX, posY, element), element)
				end
			end
		):setIcon(FontAwesomeSymbols.Info)
    end
end



function WorldItemInformationMouseMenu:constructor(posX, posY, element)
    GUIMouseMenu.constructor(self, posX, posY, 300, 0)

    self:addItem(_("Ersteller: %s", element:getData("Placer"))):setTextColor(Color.White)
    self:addItem(_("Zeit: %s", getOpticalTimestamp(element:getData("PlacedTimestamp")))):setTextColor(Color.White)
    self:addItem(_("min. Rang: %s", element:getData("MinRank") or 0)):setTextColor(Color.White)
    self:addItem(_("Superuser: %s", element:getData("SuperOwner") and element:getData("Owner") or element:getData("Placer"))):setTextColor(Color.White)
	self:addItem(_("Model: %s", tostring(getElementModel(element)))):setTextColor(Color.White)
end