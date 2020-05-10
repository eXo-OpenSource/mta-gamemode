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
	if not element:getData("WorldItem:anonymousInfo") then
		self:addItem(_("Besitzer: %s", tostring(element:getData("Owner")))):setTextColor(Color.Red)
	elseif localPlayer:getRank() > 4 and localPlayer:getPublicSync("supportMode") then
		self:addItem(_("Besitzer: %s", tostring(element:getData("Owner")))):setTextColor(Color.Red)
	end
	self:addItem(_("Objekt: %s", tostring(element:getData("Name")))):setTextColor(Color.Accent)

	self:addModelSpecificItems(element)

	if self:hasPermissionTo("moveWorldItem", element, true) then
		self:addItem(_"Verschieben", -- maybe some other day
			function()
				if self:getElement() then
					triggerServerEvent("worldItemMove", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Arrows)
	end

	if self:hasPermissionTo("", element, true) then
		self:addItem(_"Aufheben",
			function()
				if self:getElement() then
					triggerServerEvent("worldItemCollect", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Double_Up)
	end

	if self:hasPermissionTo("deleteWorldItem", element, true) then
		self:addItem(_"Löschen",
			function()
				if self:getElement() then
					triggerServerEvent("worldItemDelete", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Trash)
	end

	if self:hasPermissionTo("moveWorldItem", element, true) then
		if getElementData(element, "detonatorSlam") then
			self:addItem(_"Bewegungsmelder",
				function()
					if self:getElement() then
						triggerServerEvent("onSlamToggleLaser", element)
					end
				end
			):setIcon(FontAwesomeSymbols.Bomb)
		end
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
		if self:hasPermissionTo("showWorldItemInformation", element, true) then
			self:addItem(_"Musik ändern",
				function()
					if element then
						StreamGUI:new("Musik ändern", function(url) triggerServerEvent("itemRadioChangeURL", element, url) end, function() triggerServerEvent("itemRadioStopSound", element) end)
					end
				end
			):setIcon(FontAwesomeSymbols.Music)
		end
		self:addItem(_"Sound an/aus",
			function()
				if element then
					if element.Sound and isElement(element.Sound) then
						if element.Sound:getVolume() == 0 then
							element.Sound:setVolume(1)
						else
							element.Sound:setVolume(0)
						end
					end
				end
			end
		):setIcon(FontAwesomeSymbols.SoundOn)
	elseif model == 1238 then -- Warnkegel
		if self:hasPermissionTo("", element, true) then
			self:addItem(_"Warnleuchte",
				function()
					if element then
						triggerServerEvent("worldItemToggleBlinkingLight", element)
					end
				end
			):setIcon(FontAwesomeSymbols.Lightbulb)
		end
	end
end


function WorldItemMouseMenu:hasPermissionTo(action, element, ownerPriority)
	local superUserName = element:getData("SuperOwner") and element:getData("Owner") or element:getData("Placer")
	local lpSuperUser = (localPlayer:getName() == superUserName
		or (localPlayer:getFaction() and localPlayer:getFaction():getShortName() == superUserName)
		or (localPlayer:getCompany() and localPlayer:getCompany():getName() == superUserName)
	)
	if ADMIN_RANK_PERMISSION[action] then --specified action
		if localPlayer:getRank() >= ADMIN_RANK_PERMISSION[action] and localPlayer:getPublicSync("supportMode") then --if allowed
			return true
		end

		return ownerPriority and lpSuperUser --just return it if owner can peform admin funcs (e.g. move)
	else -- not an admin action
		return lpSuperUser --basic owner check
	end
	--[[if (localPlayer:getName() == superUserName or localPlayer:getFaction():getShortName() == superUserName) then
		if ownerPriority or not ADMIN_RANK_PERMISSION[action] then --owner can use admin funcs or there is no func

		end
	else
		if ADMIN_RANK_PERMISSION[action] then
			if localPlayer:getRank() >= ADMIN_RANK_PERMISSION[action] then
				return true
			else
				return false
			end
		end
	end
	return (localPlayer:getName() == superUserName or localPlayer:getFaction():getShortName() == superUserName) ]]
end


function WorldItemInformationMouseMenu:constructor(posX, posY, element)
    GUIMouseMenu.constructor(self, posX, posY, 300, 1)
	if not element:getData("WorldItem:anonymousInfo") then
		self:addItem(_("Ersteller: %s", element:getData("Placer"))):setTextColor(Color.White)
	elseif localPlayer:getRank() > 4 and localPlayer:getPublicSync("supportMode") then
		self:addItem(_("Ersteller: %s", element:getData("Placer"))):setTextColor(Color.White)
    end
	self:addItem(_("Zeit: %s", getOpticalTimestamp(element:getData("PlacedTimestamp")))):setTextColor(Color.White)
    self:addItem(_("min. Rang: %s", element:getData("MinRank") or 0)):setTextColor(Color.White)
    self:addItem(_("Superowner: %s", element:getData("SuperOwner") and element:getData("Owner") or element:getData("Placer"))):setTextColor(Color.White)
	self:addItem(_("Model: %s", tostring(getElementModel(element)))):setTextColor(Color.White)

	self:adjustWidth()
end
