BeggarPedManager = inherit(Singleton)
BeggarPedManager.Map = {}
addRemoteEvents{"robBeggarPed"}

function BeggarPedManager:constructor()
	-- Spawn Peds
	self:spawnPeds()
	self.m_TimedPulse = TimedPulse:new(10*60*1000)
	self.m_TimedPulse:registerHandler(bind(self.spawnPeds, self))

	-- Event Zone
	addEventHandler("robBeggarPed", root, bind(self.Event_robBeggarPed, self))
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
		v:destroy()
	end

	-- Create new Peds
	for i, v in ipairs(BeggarPositions) do
		if chance(50) then -- They only spawn with a probability of 50%
			local ped = BeggarPed:new(v[1], v[2], i)
			self:addRef(ped)
		end
	end
end

function BeggarPedManager:getPhrase(beggarType, phraseType)
	if phraseType == BeggarPhraseTypes.Help then
		return Randomizer:getRandomTableValue(BeggarHelpPhrases[beggarType])
	elseif phraseType == BeggarPhraseTypes.Thanks then
		return Randomizer:getRandomTableValue(BeggarThanksPhrases[beggarType])
	elseif phraseType == BeggarPhraseTypes.NoHelp then
		return Randomizer:getRandomTableValue(BeggarNoHelpPhrases)
	elseif phraseType == BeggarPhraseTypes.Rob then
		return Randomizer:getRandomTableValue(BeggarRobPhrases)
	end
end

function BeggarPedManager:Event_robBeggarPed()
	if not instanceof(source, BeggarPed) then return end
	source:rob(client)
end
