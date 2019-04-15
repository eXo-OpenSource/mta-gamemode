-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/StateEvidence.lua
-- *  PURPOSE:     state evidence storage
-- *
-- ****************************************************************************

StateEvidence = inherit(Singleton)
addRemoteEvents{"State:startEvidenceTruck"}

--[[
    Id
    Type
    Object
    Amount
    UserId
    Date
]]

function StateEvidence:constructor()
    addEventHandler("State:startEvidenceTruck", root, bind(self.Event_startEvidenceTruck,self))
	
	self:createEvidencePickup(255.29, 90.78, 1002.45, 6, 0)
	self:createEvidencePickup(1579.43, -1691.53, 5.92, 0, 5)
	self:loadObjectData()
end

function StateEvidence:loadObjectData()
	self.m_EvidenceRoomItems = sql:queryFetch("SELECT * FROM ??_state_evidence", sql:getPrefix()) or {}
	self.m_FillState = 0
	for i, v in pairs(self.m_EvidenceRoomItems) do
		self.m_EvidenceRoomItems[i].UserName = Account.getNameFromId(v.UserId) or "Unbekannt"
		self.m_FillState = self.m_FillState + self:getObjectPrice(v.Type, v.Object, v.Amount)
	end
end


function StateEvidence:createEvidencePickup( x,y,z, int, dim )
	local pickup = createPickup(x,y,z,3, 2061, 10)
	setElementInterior(pickup, int)
	setElementDimension(pickup, dim)
	addEventHandler("onPickupUse", pickup, function( hitElement )
		local dim = source:getDimension() == hitElement:getDimension()
		if hitElement:getType() == "player" and dim then
			if hitElement:getFaction() and hitElement:getFaction():isStateFaction() and hitElement:isFactionDuty() then
				hitElement.evidencePickup = source
				self:showEvidenceStorage( hitElement )
			else
				hitElement:sendError(_("Nur für Staatsfraktionisten im Dienst!", hitElement))
			end
		end
	end)
	ElementInfo:new(pickup, "Asservatenkammer", 1 )
end

function StateEvidence:getObjectPrice(type, object, amount)
	if type == "Item" then return STATE_EVIDENCE_OBJECT_PRICE.Item * amount end
	if type == "Waffe" then return STATE_EVIDENCE_OBJECT_PRICE.Waffe * amount * factionWeaponDepotInfo[tonumber(object)].WaffenPreis end
	if type == "Munition" then return STATE_EVIDENCE_OBJECT_PRICE.Munition * amount * factionWeaponDepotInfo[tonumber(object)].MagazinPreis end
end

--base function (do not call directly)
function StateEvidence:insertNewObject(type, object, amount, userid)
	local timeStamp = getRealTime().timestamp
    if self.m_EvidenceRoomItems then
		if self.m_FillState < STATE_EVIDENCE_MAX_OBJECTS  then
            sql:queryExec("INSERT INTO ??_state_evidence (Type, Object, Amount, UserId, Timestamp) VALUES(?, ?, ?, ?, ?)",
            sql:getPrefix(), type, object, amount, userid, timeStamp)
			table.insert(self.m_EvidenceRoomItems, {
				Type = type, 
				Object = object, 
				Amount = amount, 
				UserId = userid,
				Date = timeStamp, 
				UserName = Account.getNameFromId(userid),
				Id = sql:lastInsertId()
			})
			self.m_FillState = self.m_FillState + self:getObjectPrice(type, object, amount)
            return true
        else
            FactionState:getSingleton():sendShortMessage("Die Asservatenkammer ist voll, die Waffe konnte nicht mehr eingelagert werden!")
        end
    end
end

--multiple weapons
function StateEvidence:addWeaponsToEvidence(player, weaponId, weaponCount, noMessage)	
	if self:insertNewObject("Waffe", weaponId, weaponCount, player and player:getId() or 0) then
		player:getFaction():addLog(player, "Asservate", ("hat %s %s konfisziert!"):format(weaponCount, WEAPON_NAMES[weaponId or 0]))
        if not noMessage then player:sendShortMessage(("Du hast %s %s konfisziert."):format(weaponCount, WEAPON_NAMES[weaponId or 0])) end
        return true
    end
end

--ammo without weapon
function StateEvidence:addMunitionToEvidence(player, weaponId, ammo, noMessage)	
	if self:insertNewObject("Munition", weaponId, ammo, player and player:getId() or 0) then
		player:getFaction():addLog(player, "Asservate", ("hat %s %s-Munition konfisziert!"):format(ammo, WEAPON_NAMES[weaponId or 0]))
        if not noMessage then player:sendShortMessage(("Du hast %s %s-Schuss konfisziert."):format(ammo, WEAPON_NAMES[weaponId or 0])) end
        return true
    end
end

--one weapon with ammo (utility function, e.g. frisking)
function StateEvidence:addWeaponWithMunitionToEvidence(player, weaponId, ammo, noMessage)	
    if self:addWeaponsToEvidence(player, weaponId, 1, true) and self:addMunitionToEvidence(player, weaponId, ammo, true) then
		if not noMessage then player:sendShortMessage(("Du hast ein/e(n) %s mit %s Schuss konfisziert."):format(WEAPON_NAMES[weaponId or 0], ammo)) end
		return true
    end
end

--one item with optional stack size
function StateEvidence:addItemToEvidence(player, itemName, amount, noMessage)
	if self:insertNewObject("Item", itemName, amount, player and player:getId() or 0) then
		player:getFaction():addLog(player, "Asservate", ("hat %s %s konfisziert!"):format(amount, itemName))
		if not noMessage then player:sendShortMessage(("Du hast %s %s konfisziert."):format(amount, itemName)) end
		return true
    end
end

function StateEvidence:showEvidenceStorage(player)
	if player then
		if player:isFactionDuty() and player:getFaction() and player:getFaction():isStateFaction() then
			player:triggerEvent("State:sendEvidenceItems", self.m_EvidenceRoomItems, self.m_FillState)
		end
	end
end

function StateEvidence:Event_startEvidenceTruck()
	if client:isFactionDuty() and client:getFaction() and client:getFaction():isStateFaction() then
		if ActionsCheck:getSingleton():isActionAllowed(client) then
			local evObj
			local totalMoney = 0
			local objToDelete = {}
			for i = 1, #self.m_EvidenceRoomItems do
				evObj = self.m_EvidenceRoomItems[i]
				local price = self:getObjectPrice(evObj.Type, evObj.Object, evObj.Amount)

				if(totalMoney + price <= EVIDENCETRUCK_MAX_LOAD) then
					totalMoney = totalMoney + price
					table.insert(objToDelete, evObj.Id)
				end
			end
			if totalMoney > 0 then
				ActionsCheck:getSingleton():setAction("Geldtransport")
				FactionState:getSingleton():sendMoveRequest(TSConnect.Channel.STATE)
				StateEvidenceTruck:new(client, totalMoney)
				PlayerManager:getSingleton():breakingNews("Ein Geld-Transporter ist unterwegs! Bitte bleiben Sie vom Transport fern!")
				Discord:getSingleton():outputBreakingNews("Ein Geld-Transporter ist unterwegs! Bitte bleiben Sie vom Transport fern!")
				FactionState:getSingleton():sendShortMessage(client:getName().." hat einen Geldtransport gestartet!",10000)
				StatisticsLogger:getSingleton():addActionLog("Geld-Transport", "start", client, client:getFaction(), "faction")
				sql:queryFetchSingle(function()
					self:loadObjectData()
				end, "DELETE FROM ??_state_evidence WHERE Id IN (??)",sql:getPrefix(), table.concat(objToDelete, ","))
				
			else
				client:sendError(_("In der Asservatenkammer befindet sich zu wenig Material!", client))
			end
		end
	end
end