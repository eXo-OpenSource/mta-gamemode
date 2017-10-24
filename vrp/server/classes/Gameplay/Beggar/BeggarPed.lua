BeggarPed = inherit(Object)

function BeggarPed:new(id, classId, position, rotation, ...)
	local class = BeggarPedManager.Classes[classId]["Class"]
	if class then
		local ped = Ped.create(Randomizer:getRandomTableValue(BeggarSkins), position, rotation.z)
		enew(ped, class, id, classId, ...)
		return ped
	else
		outputDebugString("Class for Beggar not found! "..classId)
		return false
	end
end

BeggarPed.constructor = pure_virtual

function BeggarPed:virtual_constructor(id, classId)
	self.m_Id = id
	self.m_Name = Randomizer:getRandomTableValue(BeggarNames)
	self.m_ColShape = createColSphere(self:getPosition(), 10)
	self.m_Type = classId
	self.m_RoleName = BeggarTypeNames[self.m_Type]

	self.m_LastRobTime = 0

	addEventHandler("onPedWasted", self, bind(self.Event_onPedWasted, self))
	addEventHandler("onColShapeHit", self.m_ColShape, bind(self.Event_onColShapeHit, self))
	addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.Event_onColShapeLeave, self))

	if chance(50) then
		local animation = Randomizer:getRandomTableValue(BeggarAnimations)
		self:setAnimation(unpack(animation))
	end

	-- Set ElementDatas
	self:setData("clickable", true, true)
	self:setData("BeggarName", self.m_Name, true)
	self:setData("BeggarId", self.m_Id, true)
	self:setData("BeggarType", self.m_Type, true)
end

function BeggarPed:virtual_destructor()
	if self.m_ColShape and isElement(self.m_ColShape) then destroyElement(self.m_ColShape) end

	-- Remove ref
	BeggarPedManager:getSingleton():removeRef(self)
end

function BeggarPed:getId()
	return self.m_Id
end

function BeggarPed:despawn()
	self.m_Despawning = true
    setTimer(function ()
		if self and isElement(self) and self:getAlpha() then
			local newAlpha = self:getAlpha() - 10
			if newAlpha < 10 then newAlpha = 0 end
			if newAlpha == 0 then
				self:destroy()
			else
				self:setAlpha(newAlpha)
			end
		else
			killTimer(sourceTimer)
		end
    end, 50, 255/10)
end

function BeggarPed:rob(player)
	if self.m_Despawning then return end
	if getTickCount() - self.m_LastRobTime < 10*60*1000 then
		player:sendMessage(_("#FE8A00%s: #FFFFFFIch wurde gerade erst ausgeraubt. Bei mir gibts nichts zu holen.", player, self.m_Name))
		return
	end
	if not player.vehicle then
		-- Give wage
		local money = math.random(1, 5)
		player:giveCombinedReward("Bettler-Raub", {
			money = money,
			karma = -math.ceil(money/2),
		})
		self:sendMessage(player, BeggarPhraseTypes.Rob)
		player:meChat(true, ("packt %s und entreißt ihm %s"):format(self.m_Name, money == 1 and "einen Schein" or "ein paar Scheine"))
		-- give Achievement
		player:giveAchievement(50)

		-- Update rob time
		self.m_LastRobTime = getTickCount()
		self.m_Robber = player:getId()
	else
		self:sendMessage(player, BeggarPhraseTypes.InVehicle)
	end
end

function BeggarPed:sendMessage(player, type, arg)
    player:sendMessage(_("#FE8A00%s: #FFFFFF%s", player, self.m_Name, BeggarPedManager:getSingleton():getPhrase(self.m_Type, type, arg)))
end

function BeggarPed:Event_onPedWasted(totalAmmo, killer, killerWeapon, bodypart, stealth)
	if killer and killer ~= source and killerWeapon ~= 3 and getElementType(killer) == "player" then
		--killer:reportCrime(Crime.Kill)

		-- Take karma
		killer:giveKarma(-3)

		-- Destory the Ped
		self:despawn()

		-- Give Wanteds
		killer:giveWanteds(4)
		killer:sendMessage("Verbrechen begangen: Mord, 4 Wanteds", 255, 255, 0)
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
