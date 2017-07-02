BeggarPedManager = inherit(Singleton)
BeggarPedManager.Map = {}
addRemoteEvents{"robBeggarPed", "giveBeggarPedMoney", "giveBeggarItem", "acceptTransport", "sellBeggarWeed", "beggarPlaced"}

function BeggarPedManager:constructor()
	-- Spawn Peds
	self:loadPositions()
	self:spawnPeds()

	self.m_TimedPulse = TimedPulse:new(30*60*1000)
	self.m_TimedPulse:registerHandler(bind(self.spawnPeds, self))

	addCommandHandler("createPed", bind(self.createPed, self))

	-- Event Zone
	addEventHandler("robBeggarPed", root, bind(self.Event_robBeggarPed, self))
	addEventHandler("giveBeggarPedMoney", root, bind(self.Event_giveBeggarMoney, self))
	addEventHandler("giveBeggarItem", root, bind(self.Event_giveBeggarItem, self))
	addEventHandler("acceptTransport", root, bind(self.Event_acceptTransport, self))
	addEventHandler("sellBeggarWeed", root, bind(self.Event_sellWeed, self))
	addEventHandler("beggarPlaced", root, bind(self.Event_beggarPlaced, self))

end

function BeggarPedManager:destructor()
	if self.m_TimedPulse then
		delete(self.m_TimedPulse)
	end
end

function BeggarPedManager:addRef(ref)
	BeggarPedManager.Map[ref:getId()] = ref
end

function BeggarPedManager:removeRef(ref)
	BeggarPedManager.Map[ref:getId()] = nil
end

function BeggarPedManager:loadPositions()
	self.m_Positions = {}
	local result = sql:queryFetch("SELECT * FROM ??_npc", sql:getPrefix())
 	for i, row in pairs(result) do
	 	self.m_Positions[row.Id] = {
			 ["Pos"] = Vector3(row.PosX, row.PosY, row.PosZ),
			 ["Rot"] = Vector3(0, 0, row.Rot),
			 ["Names"] = row.Names and fromJSON(row.Names) or {},
			 ["Roles"] = row.Roles and fromJSON(row.Roles) or {}
			}
	end
end

function BeggarPedManager:spawnPeds()
	-- Delete current Peds
	for i, v in pairs(self.Map) do
		if not v.vehicle then
			v:destroy()
		end
	end

	-- Create new Peds
	for i, v in ipairs(self.m_Positions) do
		if chance(50) then -- They only spawn with a probability of 50%
			local ped = BeggarPed:new(v.Pos, v.Rot, i, v.Names, v.Roles)
			self:addRef(ped)
		end
	end
end

function BeggarPedManager:getPhrase(beggarType, phraseType, arg1)
	if phraseType == BeggarPhraseTypes.Help then
		return Randomizer:getRandomTableValue(BeggarHelpPhrases[beggarType])
	elseif phraseType == BeggarPhraseTypes.Thanks then
		return Randomizer:getRandomTableValue(BeggarThanksPhrases[beggarType])
	elseif phraseType == BeggarPhraseTypes.NoHelp then
		return Randomizer:getRandomTableValue(BeggarNoHelpPhrases)
	elseif phraseType == BeggarPhraseTypes.Rob then
		return Randomizer:getRandomTableValue(BeggarRobPhrases)
	elseif phraseType == BeggarPhraseTypes.Decline then
		return Randomizer:getRandomTableValue(BeggarDeclinePhrases)
		elseif phraseType == BeggarPhraseTypes.InVehicle then
		return Randomizer:getRandomTableValue(BeggarInVehiclePhrases)
	elseif phraseType == BeggarPhraseTypes.NoTrust then
		return Randomizer:getRandomTableValue(BeggarNoTrustPhrases)
	elseif phraseType == BeggarPhraseTypes.Destination then
		return Randomizer:getRandomTableValue(BeggarDestinationPhrases):format(arg1)
	end
end

function BeggarPedManager:Event_robBeggarPed()
	if not instanceof(source, BeggarPed) then return end
	source:rob(client)
end

function BeggarPedManager:Event_giveBeggarMoney(amount)
	if not instanceof(source, BeggarPed) then return end
	source:giveMoney(client, amount)
end

function BeggarPedManager:Event_giveBeggarItem(item)
	if not instanceof(source, BeggarPed) then return end
	source:giveItem(client, item)
end

function BeggarPedManager:Event_acceptTransport()
	if not instanceof(source, BeggarPed) then return end
	source:acceptTransport(client)
end

function BeggarPedManager:Event_sellWeed(amount)
	if not instanceof(source, BeggarPed) then return end
	source:sellWeed(client, amount)
end

function BeggarPedManager:createPed(player)
	if player:getRank() < ADMIN_RANK_PERMISSION["npcControl"] then
		player:sendError(_("Du darfst diese Funktion nicht nutzen!!", player))
		return
	end

	-- Start the object placer on the client
	player:triggerEvent("objectPlacerStart", Randomizer:getRandomTableValue(BeggarSkins), "beggarPlaced", false)
	return true
end

function BeggarPedManager:Event_beggarPlaced(x, y, z, rotation)
	if client.m_PlacingInfo then
		client:sendError(_("Du kannst nur ein Objekt zur selben Zeit setzen!", client))
		return false
	end

	if sql:queryExec("INSERT INTO ??_npc (PosX, PosY, PosZ, Rot) VALUES (?, ?, ?, ?)", sql:getPrefix(), x, y, z, rotation) then
		local ped = BeggarPed:new(Vector3(x, y, z), Vector3(0, 0, rotation), sql:lastInsertId(), {}, {})
		self:addRef(ped)
		client:sendInfo(_("Neuen NPC hinzugefügt!", client))
	end
end
