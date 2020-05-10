-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/Items/SpeedCamWorldItem.lua
-- *  PURPOSE:
-- *
-- ****************************************************************************
SpeedCamWorldItem = inherit(FactionWorldItem)
SpeedCamWorldItem.Map = {}

function SpeedCamWorldItem.onPlace(player, placingInfo, position, rotation)
	if not position then return end
	player:getInventory():takeItem(placingInfo.item.Id, 1)
	player:sendInfo(_("%s hinzugefügt!", player, placingInfo.itemData.Name))
	local faction = player:getFaction()
	local int = player:getInterior()
	local dim = player:getDimension()
	-- (item, owner, pos, rotation, breakable, player, isPermanent, locked, value, interior, dimension, databaseId)
	-- FactionWorldItem:new(self, player:getFaction(), position, rotation, true, player)
	-- (itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
	SpeedCamWorldItem:new(placingInfo.itemData, player:getId(), faction:getId(), DbElementType.Faction, position, rotation, dim, int, false, "", {}, true, false)
end

function SpeedCamWorldItem.requestAllPunishments()
    for id, speedcam in pairs(SpeedCamWorldItem.Map) do
        speedcam:requestPunishments()
    end
end

function SpeedCamWorldItem:constructor(itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
    SpeedCamWorldItem.Map[self.m_Id] = self
    self.m_Offenders = {}
    self.m_Limit = 80

	addEventHandler("onClientBreakItem", self:getObject(), function()
		source.m_Super:onDelete()
    end)
end

function SpeedCamWorldItem:destructor()
    SpeedCamWorldItem.Map[self.m_Id] = nil
    if self.m_ColShape then
        self.m_ColShape:destroy()
    end
end

function SpeedCamWorldItem:onColShapeHit(hitElement, matchingDim)
    if hitElement:getType() == "vehicle" then
        if hitElement.controller then
            local heightDifference = hitElement:getPosition().z - self:getObject():getPosition().z

            if heightDifference >= 0 and heightDifference <= 4 then
                if hitElement:getSpeed() > self.m_Limit + 5 then
                    self:createFlashEffect(hitElement.controller)
                    if hitElement.controller:getFaction() and (hitElement.controller:getFaction():isStateFaction() or hitElement.controller:getFaction():isRescueFaction()) and hitElement.controller:isFactionDuty() then return end

                    if not self.m_Offenders[hitElement.controller:getId()] then
                        self.m_Offenders[hitElement.controller:getId()] = {}
                    end
                    self.m_Offenders[hitElement.controller:getId()][#self.m_Offenders[hitElement.controller:getId()]+1] = {
                        vehicle = hitElement:getModel(),
                        color = getColorNameFromVehicle(hitElement:getColor(), hitElement:getColor()),
                        speed = hitElement:getSpeed(),
                        limit = self.m_Limit,
                        timestamp = getRealTime().timestamp
                    }
                end
            end
        end
    end
end

function SpeedCamWorldItem:createFlashEffect(player)
    if not isElement(self.m_Marker) then
        self.m_Marker = createMarker(self:getObject().position+self:getObject().matrix.right/2+Vector3(0,0,3.5), "corona", 0.5, 255, 0, 0, 255)
        setTimer(function() self.m_Marker:destroy() end, 250, 1)
    end
end

function SpeedCamWorldItem:requestPunishments()
    local totalAmount = 0
    local totalBills = 0
    for playerId, bills in pairs(self.m_Offenders) do
        --local text = "Du wurdest geblitzt und die Fotos wurden ausgewertet! Dir wird folgendes zur Last gelegt:\n\n"
        local amount = 0
        for index, bill in pairs(bills) do
            local billCosts = (math.floor(bill.speed)-bill.limit)*15
            amount = amount + billCosts
            totalBills = totalBills + 1
            --text = ("%s#%d: Geschwindigkeit: %d (+%d km/h), Strafe: %d$, Fahrzeug: %s, Farbe: %s\n"):format(text, index, bill.speed, bill.speed-bill.limit, billCosts, getVehicleNameFromModel(bill.vehicle), bill.color)
        end
        text = ("Du wurdest geblitzt und die Fotos wurden ausgewertet!\nDir wird folgendes zur Last gelegt:\n\n%d Geschwindigkeitsüberschreitungen\n(Ort: %s)\n\nGesamtbetrag: %s$"):format(#bills, self.m_ZoneName, addComas(tostring(amount)))
        totalAmount = totalAmount + amount

		local bankAccount = BankAccount.loadByOwner(playerId, 1)
        if bankAccount:transferMoney({FactionManager:getSingleton():getFromId(1), nil, true}, amount, "Blitzer-Strafe", "Gameplay", "Speedcam") then
            local offender, offline = DatabasePlayer.get(playerId)

            if offline then
                offender:addOfflineMessage(text, 1)
                delete(offender)
            else
				offender:sendShortMessage(text, "SA Police Department")
            end

            bankAccount:save()
        end
    end

    self.m_Offenders = {}
    if totalAmount > 0 then
        FactionState:getSingleton():sendShortMessage(("Die Fotos eines Blitzers (Ort: %s) wurden ausgewertet! Die insgesamt %d Strafzahlungen belaufen sich auf %s$!"):format(self.m_ZoneName, totalBills, addComas(tostring(totalAmount))))
    end
end

function SpeedCamWorldItem:onChanged()
    local object = self:getObject()
    if self.m_ColShape then
        self:requestPunishments()
        self.m_ColShape:destroy()
    end

    self.m_ZoneName = getZoneName(object:getPosition())

    --the speedcam model is rotated by 90 degrees, that needs to be considered while doing the math
    local firstVec = object.position
    local secondVec = object.position + object.matrix.forward * -4.5 + object.matrix.right * 20
    local thirdVec = object.position + object.matrix.forward * 4.5 + object.matrix.right * 20
    self.m_ColShape = createColPolygon(firstVec.x, firstVec.y, firstVec.x, firstVec.y, secondVec.x, secondVec.y, thirdVec.x, thirdVec.y)
    addEventHandler("onColShapeHit", self.m_ColShape, bind(self.onColShapeHit, self))
end