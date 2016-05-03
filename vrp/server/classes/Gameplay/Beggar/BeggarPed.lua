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
	self.m_Type = math.random(1, 3)
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

function BeggarPed:despawn()
    setTimer(function ()
        local newAlpha = self:getAlpha() - 10
        if newAlpha < 10 then newAlpha = 0 end
        if newAlpha == 0 then
            self:destroy()
        else
            self:setAlpha(newAlpha)
        end
    end, 50, 255/10)
end

function BeggarPed:rob(player)
	--if getTickCount() - self.m_LastRobTime < 5*60*1000 then
	--	return
	--end

	-- Give wage
	client:giveMoney(math.random(1, 5), "Bettler-Raub")
	client:giveKarma(-0.15)
	client:sendShortMessage(_("Well done. Du hast einen Bettler ausgeraubt!", player))
    self:sendMessage(client, BeggarPhraseTypes.Rob)

	-- give Achievement
	client:giveAchievement(50)

	-- Update rob time
	self.m_LastRobTime = getTickCount()
end

function BeggarPed:sendMessage(player, type)
    player:sendMessage(_("#FE8A00%s: #FFFFFF%s", player, self.m_Name, BeggarPedManager:getSingleton():getPhrase(self.m_Type, type)))
end

function BeggarPed:Event_onPedWasted(totalAmmo, killer, killerWeapon, bodypart, stealth)
	if killer and killer ~= source and killerWeapon ~= 3 and getElementType(killer) == "player" then
		killer:reportCrime(Crime.Kill)

		-- Take karma
		killer:giveKarma(-0.15)

		-- Destory the Ped
		self:despawn()
	end
end

function BeggarPed:Event_onColShapeHit(hitElement, dim)
    if dim then
        if hitElement:getType() ~= "player" then return end
        self:sendMessage(hitElement, BeggarPhraseTypes.Help)
        hitElement:triggerEvent("setManualHelpBarText", "HelpTextTitles.Gameplay.Beggar", "HelpTexts.Gameplay.Beggar", true)
    end
end

function BeggarPed:Event_onColShapeLeave(hitElement, dim)
    if dim then
        if hitElement:getType() ~= "player" then return end
        self:sendMessage(hitElement, BeggarPhraseTypes.NoHelp)
        hitElement:triggerEvent("resetManualHelpBarText")
    end
end
