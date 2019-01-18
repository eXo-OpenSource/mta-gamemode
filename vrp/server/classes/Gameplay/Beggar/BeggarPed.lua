BeggarPed = inherit(Object)

function BeggarPed:new(id, classId, position, rotation, ...)
	local class = BeggarPedManager.Classes[classId]["Class"]
	if class then
		local ped = Ped.create(Randomizer:getRandomTableValue(BeggarSkins), position, rotation.z, true)
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
	self:setData("Ped:fakeNameTag", self.m_Name, true)
	self.m_ColShape = createColSphere(self:getPosition(), 10)
	self.m_Type = classId
	self.m_RoleName = BeggarTypeNames[self.m_Type]

	self.m_LastRobTime = 0
	self.m_BankAccountServer = BankServer.get("gameplay.beggar")

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
	if self.m_AbortRescueTimer and isTimer(self.m_AbortRescueTimer) then killTimer(self.m_AbortRescueTimer) end
	if self.m_LootPickup and isElement(self.m_LootPickup) then destroyElement(self.m_LootPickup) end
	if self.m_DeathPickup then
		FactionRescue:getSingleton():removePedDeathPickup(self)
	end
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
	if not self:isMoneyRobbable() then
		player:sendMessage(_("#FE8A00%s: #FFFFFFIch wurde gerade erst ausgeraubt. Bei mir gibts nichts zu holen.", player, self.m_Name))
		return
	end
	if not player.vehicle then
		-- Give wage
		local money = math.random(1, 5)
		player:giveCombinedReward("Bettler-Raub", {
			money = {
				mode = "give",
				bank = false,
				amount = money,
				toOrFrom = self.m_BankAccountServer or BankServer.get("gameplay.beggar"),
				category = "Gameplay",
				subcategory = "BeggarRob"
			},
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
	self.m_Dead = true
	--create a rescue mission if there is someone online, otherwise just despawn him
	if #FactionRescue:getSingleton():getOnlinePlayers(true, false) >= 1 then
		self:setHealth(20)
		self:setData("NPC:Immortal", true, true)
		self:setAnimation("wuzi","cs_dead_guy", -1, true, false, false, true)
		FactionRescue:getSingleton():createPedDeathPickup(self, self.m_Name)
		self.m_AbortRescueTimer = setTimer(function()
			if self.m_DeathPickup then
				FactionRescue:getSingleton():removePedDeathPickup(self)
				self:despawn()
			end
		end, 5000 * 60, 1) -- 5 minutes
	else
		setTimer(function()
			self:despawn()
		end, 15000, 1)
	end

	--give loot
	self:createLootPickup()

	if killer and isElement(killer) and getElementType(killer) == "vehicle" then killer = killer.controller end
	if killer and killer ~= source and killerWeapon ~= 3 and getElementType(killer) == "player" then
		-- Take karma
		killer:takeKarma(3)
		-- Give Wanteds
		if (getZoneName(self.position, true) == "Los Santos" and chance(50) or chance(25)) then
			setTimer(function()
				if killer and isElement(killer) then
				killer:sendWarning("Dein Mord wurde von einem Augenzeuge an das LSPD gemeldet!")
				killer:giveWanteds(4)
				killer:sendMessage("Verbrechen begangen: Mord, 4 Wanteds", 255, 255, 0)
				end
			end, math.random(2000, 10000), 1)
		end
	end
end

function BeggarPed:isMoneyRobbable()
	return getTickCount() - self.m_LastRobTime > 10*60*1000
end

function BeggarPed:createLootPickup()
	self.m_LootPickup = Pickup(self.position + Vector3((math.random(0, 2)-1)/10, (math.random(0, 2)-1)/10, -0.7), 3, 1279, 0)
	addEventHandler("onPickupHit", self.m_LootPickup, function(hitPlayer)
		if self.m_Despawning then return end
		if hitPlayer:getType() == "player" and not hitPlayer.vehicle then
			if self.m_LootPickup and isElement(self.m_LootPickup) then destroyElement(self.m_LootPickup) end
			if source and isElement(source) then destroyElement(source) end
			hitPlayer:giveCombinedReward("Bettler-Raub", {
				money = {
					mode = "give",
					bank = false,
					amount = math.random(1,3),
					toOrFrom = self.m_BankAccountServer or BankServer.get("gameplay.beggar"),
					category = "Gameplay",
					subcategory = "BeggarRob"
				},
				karma = -math.random(0, 1),
			})
			if chance(25) then
				if self.giveLoot then
					self:giveLoot(hitPlayer)
				else
					local amount = math.random(1,2)
					hitPlayer:getInventory():giveItem("Diebesgut", amount)
					hitPlayer:sendInfo(_("Du hast %s Diebesgut von %s erhalten.", hitPlayer, amount, self.m_Name))
				end

			end
		end
	end)
end

--function BeggarPed:

function BeggarPed:Event_onColShapeHit(hitElement, dim)
    if dim and not self.m_Dead then
        if hitElement:getType() ~= "player" then return end
        self:sendMessage(hitElement, BeggarPhraseTypes.Help)
		hitElement:triggerEvent("setManualHelpBarText", "HelpTextTitles.Gameplay.Beggar", "HelpTexts.Gameplay.Beggar", true)
    end
end

function BeggarPed:Event_onColShapeLeave(hitElement, dim)
    if dim and not self.m_Dead then
        if hitElement:getType() ~= "player" then return end
        self:sendMessage(hitElement, BeggarPhraseTypes.NoHelp)
		hitElement:triggerEvent("resetManualHelpBarText")
    end
end
