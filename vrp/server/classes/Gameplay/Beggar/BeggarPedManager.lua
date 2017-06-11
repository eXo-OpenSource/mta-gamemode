BeggarPedManager = inherit(Singleton)
BeggarPedManager.Map = {}
addRemoteEvents{"robBeggarPed", "giveBeggarPedMoney", "giveBeggarItem", "acceptTransport", "sellBeggarWeed"}

function BeggarPedManager:constructor()
	-- Spawn Peds
	self:spawnPeds()
	self.m_TimedPulse = TimedPulse:new(30*60*1000)
	self.m_TimedPulse:registerHandler(bind(self.spawnPeds, self))

	-- Event Zone
	addEventHandler("robBeggarPed", root, bind(self.Event_robBeggarPed, self))
	addEventHandler("giveBeggarPedMoney", root, bind(self.Event_giveBeggarMoney, self))
	addEventHandler("giveBeggarItem", root, bind(self.Event_giveBeggarItem, self))
	addEventHandler("acceptTransport", root, bind(self.Event_acceptTransport, self))
	addEventHandler("sellBeggarWeed", root, bind(self.Event_sellWeed, self))
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

function BeggarPedManager:spawnPeds()
	-- Delete current Peds
	for i, v in pairs(self.Map) do
		if not v.vehicle then
			v:destroy()
		end
	end

	-- Create new Peds
	for i, v in ipairs(BeggarPositions) do
		if chance(50) then -- They only spawn with a probability of 50%
			local ped = BeggarPed:new(v[1], v[2], i)
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
