-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/AtmManager.lua
-- *  PURPOSE:     ATM Manager class
-- *
-- ****************************************************************************

AtmManager = inherit(Singleton)
AtmManager.BombTime = 10 * 1000
AtmManager.BrokenTime = 10 * 60 * 1000
AtmManager.Cooldown = 60 * 60 * 1000

AtmManager.HackSuccessNotificationChance = 99
AtmManager.HackSuccessPhotoChance = 75

AtmManager.NotificationCooldown = 30000
AtmManager.HackFailNotificationChance = 99
AtmManager.HackFailPhotoChance = 75

AtmManager.HackMoneyDropChance = 65
AtmManager.HackMinMoney = 2000
AtmManager.HackMaxMoney = 5000

AtmManager.BombMoneyDropChance = 45
AtmManager.BombMinMoney = 750
AtmManager.BombMaxMoney = 5000

addRemoteEvents{"onAtmStartHacking", "onAtmHackSuccess", "onAtmHackFail"}

function AtmManager:constructor()
    self.m_AtmCooldowns = {} -- used for cooldown between actions per atm
    self.m_PlayerCooldowns = {} -- used for cooldown between actions per player
    self.m_ExplodedAtms = {}
    self.m_HackedAtms = {}

    self.m_BankAccountServer = BankServer.get("gameplay.atm_sabotage")

    addEventHandler("onAtmStartHacking", root, bind(self.Event_onStartHacking, self))
    addEventHandler("onAtmHackSuccess", root, bind(self.Event_onHackSuccess, self))
    addEventHandler("onAtmHackFail", root, bind(self.Event_onHackFail, self))

    self.m_FixTimer = setTimer(bind(self.fixAtms, self), 60000, 0)

    for key, object in pairs(getElementsByType("object")) do
        if object:getModel() == ATM_NORMAL_MODEL then
            if object:getInterior() == 0 and object:getDimension() == 0 then 
                object.BombArea = BombArea:new(object:getPosition(), bind(self.onBombPlace, self, object), bind(self.onBombExplode, self, object), AtmManager.BombTime)
                addEventHandler("onElementDestroy", object, bind(self.onAtmObjectDestroy, self, object))
            end
        end
    end
end

function AtmManager:fixAtms()
    for atm, time in pairs(self.m_ExplodedAtms) do
        if not isElement(atm) then return end
        if getTickCount() - time > AtmManager.BrokenTime then
            atm:setData("isExploded", false, true)
            self.m_ExplodedAtms[atm] = nil
            atm:setAlpha(255)
            atm:setCollisionsEnabled(true)
            atm.brokenObject:destroy()
        end
    end

    for atm, time in pairs(self.m_HackedAtms) do
        if not isElement(atm) then return end
        if getTickCount() - time > AtmManager.BrokenTime then
            atm:setData("isHacked", false, true)
            self.m_HackedAtms[atm] = nil
        end
    end
end

function AtmManager:Event_onStartHacking(atm)
    if self.m_AtmCooldowns[atm] then
        if getTickCount() - self.m_AtmCooldowns[atm] < AtmManager.Cooldown then
            client:sendError(_("Dieser Bankautomat wurde erst kürzlich sabotiert!", client))
            return
        end
    end
    if self.m_PlayerCooldowns[client:getId()] then
        if getTickCount() - self.m_PlayerCooldowns[client:getId()] < AtmManager.Cooldown then
            client:sendError(_("Du kannst nur alle %d Minuten einen Bankautomaten sabotieren!", client, AtmManager.Cooldown/60/1000))
            return
        end
    end
    client.m_LastAtmHacked = atm
    triggerClientEvent(client, "startCircuitBreaker", client, "onAtmHackSuccess", "onAtmHackFail", atm)
end

function AtmManager:Event_onHackSuccess()
    local atm = client.m_LastAtmHacked
    if self.m_AtmCooldowns[atm] then
        if getTickCount() - self.m_AtmCooldowns[atm] < AtmManager.Cooldown then
            return
        end
    end
    if self.m_PlayerCooldowns[client:getId()] then
        if getTickCount() - self.m_PlayerCooldowns[client:getId()] < AtmManager.Cooldown then
            return
        end
    end
    self.m_AtmCooldowns[atm] = getTickCount()
    self.m_PlayerCooldowns[client:getId()] = getTickCount()
    self.m_HackedAtms[atm] = getTickCount()
    atm:setData("isHacked", true, true)

    if chance(AtmManager.HackMoneyDropChance) then
        local amount = math.random(AtmManager.HackMinMoney, AtmManager.HackMaxMoney)
        self.m_BankAccountServer:transferMoney(client, amount, "Bankautomat sabotiert", "Gameplay", "ATM-Sabotage")
    else
        client:sendError(_("Das Geldfach des Bankautomaten öffnet sich nicht, scheinbar ist es durch irgendetwas blockiert!", client))
    end

    if chance(AtmManager.HackSuccessNotificationChance) then
        if chance(AtmManager.HackSuccessPhotoChance) then
            FactionState:getSingleton():sendWarning("Der Sicherheitsalarm eines Bankautomaten in %s wurde ausgelöst! Ein Foto der Überwachungskamera zeigt jemanden, der auf die Personenbeschreibung von %s passt!", "Neuer Einsatz!", true, serialiseVector(atm:getPosition()), getZoneName(atm:getPosition()), client:getName())
        else
            FactionState:getSingleton():sendWarning("Der Sicherheitsalarm eines Bankautomaten in %s wurde ausgelöst!", "Neuer Einsatz!", true, serialiseVector(atm:getPosition()), getZoneName(atm:getPosition()))
        end
    end
end

function AtmManager:Event_onHackFail()
    local atm = client.m_LastAtmHacked
    if chance(AtmManager.HackFailNotificationChance) then
        if not atm.LastNotification then 
            atm.LastNotification = 0
        end
        if getTickCount() - atm.LastNotification > AtmManager.NotificationCooldown then
            atm.LastNotification = getTickCount()
            if chance(AtmManager.HackFailPhotoChance) then
                FactionState:getSingleton():sendWarning("Ein Bankautomat in %s meldet merkwürdige Aktivitäten! Ein Foto der Überwachungskamera zeigt jemanden, der auf die Personenbeschreibung von %s passt!", "Kontrolle notwendig!", true, serialiseVector(atm:getPosition()), getZoneName(atm:getPosition()), client:getName())
            else
                FactionState:getSingleton():sendWarning("Ein Bankautomat in %s meldet merkwürdige Aktivitäten!", "Kontrolle notwendig!", true, serialiseVector(atm:getPosition()), getZoneName(atm:getPosition()))
            end
        end
    end
end

function AtmManager:onBombPlace(atm, bombArea, player)
    if self.m_AtmCooldowns[atm] then
        if getTickCount() - self.m_AtmCooldowns[atm] < AtmManager.Cooldown then
            player:sendError(_("Dieser Bankautomat wurde erst kürzlich sabotiert!", player))
            return false
        end
    end
    if self.m_PlayerCooldowns[player:getId()] then
        if getTickCount() - self.m_PlayerCooldowns[player:getId()] < AtmManager.Cooldown then
            player:sendError(_("Du kannst nur alle %d Minuten einen Bankautomaten sabotieren!", player, AtmManager.Cooldown/60/1000))
            return false
        end
    end
end

function AtmManager:onBombExplode(atm, bombArea, player)
    if not isElement(player) then return end
    if self.m_AtmCooldowns[atm] then
        if getTickCount() - self.m_AtmCooldowns[atm] < AtmManager.Cooldown then
            return
        end
    end
    self.m_AtmCooldowns[atm] = getTickCount()
    self.m_PlayerCooldowns[player:getId()] = getTickCount()
    self.m_ExplodedAtms[atm] = getTickCount()
    atm:setAlpha(0)
    atm:setCollisionsEnabled(false)
    atm:setData("isExploded", true, true)
    atm.brokenObject = createObject(ATM_BROKEN_MODEL, atm:getPosition(), atm:getRotation())
    atm.brokenObject:setInterior(atm:getInterior())
    atm.brokenObject:setDimension(atm:getDimension())

    if chance(AtmManager.BombMoneyDropChance) then
        local amount = math.random(AtmManager.BombMinMoney, AtmManager.BombMaxMoney)
        self.m_BankAccountServer:transferMoney(player, amount, "Bankautomat gesprengt", "Gameplay", "ATM-Sabotage")
    else
        player:sendError(_("Die Explosion am Bankautomaten hat alle Geldscheine zerfetzt, Du gehst leer aus!", player))
    end
    FactionState:getSingleton():sendWarning("Ein Bankautomat in %s meldet merkwürdige Aktivitäten!", "Kontrolle notwendig!", true, serialiseVector(atm:getPosition()), getZoneName(atm:getPosition()))
end

function AtmManager:onAtmObjectDestroy(object)
    self.m_AtmCooldowns[object] = nil
    self.m_ExplodedAtms[object] = nil
    self.m_HackedAtms[object] = nil
    if object.BombArea then
        delete(object.BombArea)
    end
end