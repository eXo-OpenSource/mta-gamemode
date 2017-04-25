-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleCustomTextureShop.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleCustomTextureShop = inherit(Singleton)

addRemoteEvents{"vehicleCustomTextureBuy", "vehicleCustomTextureAbbort", "vehicleCustomTextureLoadPreview",
"texturePreviewRequestTextures", "texturePreviewStartPreview", "texturePreviewUpdateStatus", "texturePreviewClose"}


function VehicleCustomTextureShop:constructor()
	self.m_Path = "http://picupload.pewx.de/textures/"

	self.m_GarageInfo = {
        -- Entrance - Exit (pos, rot) - Interior
        {
            Vector3(1851, -1856.4, 12.4), -- LS El Corona
            {Vector3(1839.3, -1856.7, 13.2), 90},
            Vector3(1010.9, -982.59998, 2436.1001)
        }
    }

	self.m_Info = createPickup(1844.30, -1861.05, 13.38, 3, 1239, 0)
	addEventHandler("onPickupHit", self.m_Info, bind(self.onInfoPickupHit, self))


    for garageId, info in pairs(self.m_GarageInfo) do
        local position = info[1]
        local colshape = createColSphere(position, 3)
        addEventHandler("onColShapeHit", colshape, bind(self.EntryColShape_Hit, self, garageId))

        Blip:new("TuningGarage.png", position.x, position.y,root,600)
    end

	Player.getQuitHook():register(
        function(player)
            if player.TempTexVehicle then delete(player.TempTexVehicle) end
        end
    )

    addEventHandler("vehicleCustomTextureLoadPreview", root, bind(self.Event_texturePreview, self))

	addEventHandler("vehicleCustomTextureBuy", root, bind(self.Event_vehicleTextureBuy, self))
    addEventHandler("vehicleCustomTextureAbbort", root, bind(self.Event_vehicleUpgradesAbort, self))

	addEventHandler("texturePreviewStartPreview", root, bind(self.Event_texPreviewStartPreview, self))
	addEventHandler("texturePreviewUpdateStatus", root, bind(self.Event_texPreviewUpdateStatus, self))
	addEventHandler("texturePreviewClose", root, bind(self.Event_texPreviewClose, self))

end

function VehicleCustomTextureShop:EntryColShape_Hit(garageId, hitElement, matchingDimension)
    if getElementType(hitElement) == "player" and matchingDimension then
        local vehicle = hitElement:getOccupiedVehicle()
        if not vehicle or hitElement:getOccupiedVehicleSeat() ~= 0 then return end

        if instanceof(vehicle, CompanyVehicle) then
          if not vehicle:canBeModified() then
              hitElement:sendError(_("Dieser Firmenwagen darf nicht getunt werden!", hitElement))
              return
          end
		elseif instanceof(vehicle, FactionVehicle) then
          if not vehicle:canBeModified() then
              hitElement:sendError(_("Dieser Fraktions-Wagen darf nicht getunt werden!", hitElement))
              return
          end
        elseif instanceof(vehicle, GroupVehicle) then
            if not vehicle:canBeModified() then
                hitElement:sendError(_("Dein Leader muss das Tunen von Fahrzeugen aktivieren! Im Firmen/Gangmenü unter Leader!", hitElement))
                return
            end
        elseif vehicle:isPermanent() then
            if vehicle:getOwner() ~= hitElement:getId() then
                hitElement:sendError(_("Du kannst nur deine eigenen Fahrzeuge tunen!", hitElement))
                return
            end
        else
            hitElement:sendWarning(_("Achtung! Du tunst gerade ein temporäres Fahrzeug!", hitElement))
        end

		if not vehicle.m_Tunings then
              hitElement:sendError(_("Dieses Fahrzeug kann nicht getuned werden!", hitElement))
		end

        -- Remove occupants
        for seat, player in pairs(vehicle:getOccupants() or {}) do
            if seat ~= 0 then
                player:removeFromVehicle()
            end
        end

        local vehicleType = vehicle:getVehicleType()
        if vehicleType == VehicleType.Automobile or vehicleType == VehicleType.Bike then
            self:openFor(hitElement, vehicle, garageId)
        else
            hitElement:sendError(_("Mit diesem Fahrzeugtyp kannst du die Tuningwerkstatt nicht betreten!", hitElement))
        end
    end
end

function VehicleCustomTextureShop:onInfoPickupHit(hitElement)
	if hitElement:getType() == "player" and not hitElement.vehicle then
		hitElement:triggerEvent("vehicleCustomTextureShopInfo")
	end
end

function VehicleCustomTextureShop:openFor(player, vehicle, garageId)
    player:triggerEvent("vehicleCustomTextureShopEnter", vehicle or player:getPedOccupiedVehicle(), self.m_Path, self:getTextures(player, vehicle))
    vehicle:setFrozen(true)
    player:setFrozen(true)
    local position = self.m_GarageInfo[garageId][3]
    vehicle:setPosition(position)
    setTimer(function() warpPedIntoVehicle(player, vehicle) end, 500, 1)
    player.m_VehicleTuningGarageId = garageId
	vehicle.OldTexture = vehicle.m_Tunings:getTuning("Texture")
	vehicle.OldColor1 = vehicle.m_Tunings:getTuning("Color1")
	vehicle.OldColor2 = vehicle.m_Tunings:getTuning("Color2")
end

function VehicleCustomTextureShop:closeFor(player, vehicle, doNotCallEvent)
    if not doNotCallEvent then
        player:triggerEvent("vehicleCustomTextureShopExit")
    end

    local garageId = player.m_VehicleTuningGarageId
    if garageId then
        local position, rotation = unpack(self.m_GarageInfo[garageId][2])
        if vehicle then
            vehicle:setFrozen(false)
            vehicle:setPosition(position)
            vehicle:setRotation(0, 0, rotation)
        end

        player:setPosition(position) -- Set player position also as it will not be updated automatically before quit
        player:setFrozen(false)
        player.m_VehicleTuningGarageId = nil

        -- Hackfix for MTA issue #4658
        if vehicle and getVehicleType(vehicle) == VehicleType.Bike then
            teleportPlayerNextToVehicle(player, vehicle)
            warpPedIntoVehicle(player, vehicle)
        end

    end
end

function VehicleCustomTextureShop:getTextures(player, vehicle)
	--local result = sql:queryFetch("SELECT * FROM ??_textureshop", sql:getPrefix()) --DEVELOP
	local result = sql:queryFetch("SELECT * FROM ??_textureshop WHERE Status = ? AND (Model = ? or Model = 0) AND (UserId = ? OR Public = 1) ORDER BY Date DESC", sql:getPrefix(), TEXTURE_STATUS.Active, vehicle:getModel(), player:getId())
	return result
end

function VehicleCustomTextureShop:Event_vehicleUpgradesAbort()
   	local veh = client:getOccupiedVehicle()
	veh.m_Tunings:saveTuning("Color1", veh.OldColor1)
	veh.m_Tunings:saveTuning("Color2", veh.OldColor2)
	for textureName, texturePath in pairs(veh.OldTexture) do
		self:setTexture(veh, texturePath, textureName)
	end
	self:closeFor(client, veh)
end

function VehicleCustomTextureShop:Event_texturePreview(url, color1, color2)
	source.m_Tunings:saveTuning("Color1", color1)
	source.m_Tunings:saveTuning("Color2", color2)
	self:setTexture(source, url)
end

function VehicleCustomTextureShop:Event_vehicleTextureBuy(id, url, color1, color2)
	if client:getMoney() >= 15000 then
		--Todo Add Money Funcs/Checks
		client:takeMoney(15000, "Custom-Texture")
		source.OldTexture = {["vehiclegrunge256"] = url}
		source.OldColor1 = color1
		source.OldColor2 = color2
		source.m_Tunings:saveTuning("Color1", color1)
		source.m_Tunings:saveTuning("Color2", color2)
		self:setTexture(source, url)
		client:sendInfo("Textur gekauft!")
	else
		client:sendError(_("Du hast nicht genug Geld dabei!", client))
	end
end

function VehicleCustomTextureShop:setTexture(vehicle, url, textureName)
	local textureName = VEHICLE_SPECIAL_TEXTURE[vehicle:getModel()] or textureName ~= nil and textureName or "vehiclegrunge256"
	vehicle.m_Tunings:addTexture(url, textureName)
	vehicle.m_Tunings:applyTuning()
end

--Texture Preview

addEventHandler("texturePreviewRequestTextures", root, function(admin)
	local result

	if admin then
		result = sql:queryFetch("SELECT * FROM ??_textureshop WHERE Status = ?", sql:getPrefix(), TEXTURE_STATUS.Pending)
	else
		result = sql:queryFetch("SELECT * FROM ??_textureshop WHERE UserId = ? AND Status = ?", sql:getPrefix(), client:getId(), TEXTURE_STATUS.Testing)
	end

	for id, row in ipairs(result) do
		result[id]["UserName"] = Account.getNameFromId(row["UserId"])
	end
	client:triggerEvent("texturePreviewLoadTextures", result)
end)

function VehicleCustomTextureShop:Event_texPreviewStartPreview(url, model)

	if client.TempTexVehicle then client.TempTexVehicle:destroy() end
	local player = client
	model = model > 0 and model or math.random(400, 600)

	client.TempTexVehicle = TemporaryVehicle.create(model, 1944.97, -2307.69, 14.54)
	local veh = client.TempTexVehicle
	veh:setDimension(client:getId()+1000)
	client:setDimension(client:getId()+1000)

	veh.m_Tunings = VehicleTuning:new(veh)
	veh.m_Tunings:saveTuning("Color1", {255, 255, 255})
	veh.m_Tunings:saveTuning("Color2", {255, 255, 255})

	client:setDimension(client:getId()+1000)

	client:setData("TexturePreviewCar", veh, true)
	self:setTexture(veh, url)
end

function VehicleCustomTextureShop:Event_texPreviewUpdateStatus(id, status)
	if status == TEXTURE_STATUS.Active then
		if client:getRank() < ADMIN_RANK_PERMISSION["vehicleTexture"] then
			client:sendError(_("Du bist kein Moderator oder höher!", client))
			return
		end
		client:sendInfo(_("Du hast die Textur bestätigt!", client))
	elseif status == TEXTURE_STATUS.Declined then
		if client:getRank() < ADMIN_RANK_PERMISSION["vehicleTexture"] then
			client:sendError(_("Du bist kein Moderator oder höher!", client))
			return
		end
		client:sendInfo(_("Du hast die Textur abgelehnt!", client))
	elseif status == TEXTURE_STATUS.Pending then
		local result = sql:queryFetchSingle("SELECT UserId FROM ??_textureshop WHERE Id = ?;", sql:getPrefix(), id)
		if result and result.UserId and result.UserId == client:getId() then
			client:sendInfo(_("Du hast die Textur zur Überprüfung freigegeben!", client))
		else
			client:sendError(_("Du kannst nur eigene Texturen zur Überprüfung freigeben!", client))
			return
		end
	else
		client:sendError(_("Ungültiger Status!", client))
		return
	end

	sql:queryExec("UPDATE ??_textureshop SET Status = ? WHERE Id = ?;", sql:getPrefix(), status, id)
end

function VehicleCustomTextureShop:Event_texPreviewClose()
	if client.TempTexVehicle then
		client.TempTexVehicle:setDimension(0)
		delete(client.TempTexVehicle)
	end
	client:setDimension(0)
end
