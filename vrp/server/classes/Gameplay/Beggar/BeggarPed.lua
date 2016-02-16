BeggarPed = inherit(Object)

function BeggarPed:new(position, rotation, ...)
    local ped = Ped.create(Randomizer:getRandomTableValue(BeggarSkins), position, rotation.z)
    enew(ped, self, ...)
	addEventHandler("onPedWasted", ped, bind(self.Event_onPedWasted, ped))

    return ped
end

function BeggarPed:constructor(Id)
	self.m_Id = Id
	self.m_Name = Randomizer:getRandomTableValue(BeggarNames)
	self.m_ColShape = ColShape.Sphere(self:getPosition(), 10)
	self.m_Type = 1
	self.m_LastRobTime = 0

	addEventHandler("onColShapeHit", self.m_ColShape, bind(self.Event_onColShapeHit, self))
	addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.Event_onColShapeLeave, self))

	if chance(50) then
		outputDebug("setting animation")
		local animation = Randomizer:getRandomTableValue(BeggarAnimations)
		outputTable(animation)
		self:setAnimation(unpack(animation))
	end

	-- Set ElementDatas
	self:setData("clickable", true, true)
	self:setData("BeggarName", self.m_Name, true)
	self:setData("BeggarId", self.m_Id, true)
end

function BeggarPed:destructor()
	if self.m_ColShape then
		self.m_ColShape:destroy()
	end

	-- Remove ref
	BeggarPedManager:getSingleton():removeRef(self)
end

function BeggarPed:getId()
	return self.m_Id
end

function BeggarPed:rob(player)
	--if getTickCount() - self.m_LastRobTime < 5*60*1000 then
	--	return
	--end

	-- Give wage
	client:giveMoney(math.random(1, 5))
	client:giveKarma(-0.1)
	client:sendShortMessage(_("Well done. Du hast einen Bettler ausgeraubt!", player))

	-- give Achievement
	client:giveAchievement(50)

	-- Update rob time
	self.m_LastRobTime = getTickCount()
end

function BeggarPed:Event_onPedWasted(totalAmmo, killer, killerWeapon, bodypart, stealth)
	if killer and killer ~= source and killerWeapon ~= 3 and getElementType(killer) == "player" then
		killer:reportCrime(Crime.Kill)

		-- Take karma
		killer:giveKarma(-0.15)

		-- Destory the Ped
		self:destroy()
	end
end

function BeggarPed:Event_onColShapeHit()
	outputDebug(BeggarPedManager:getSingleton():getPhrase(self.m_Type, BeggarPhraseTypes.Help))
end

function BeggarPed:Event_onColShapeLeave()
	outputDebug(BeggarPedManager:getSingleton():getPhrase(self.m_Type, BeggarPhraseTypes.NoHelp))
end
