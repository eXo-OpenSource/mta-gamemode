-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/DrugFactories/FactoryWarManager.lua
-- *  PURPOSE:     Factory War Manager class
-- *
-- ****************************************************************************
FactoryWarManager = inherit(Singleton)

function FactoryWarManager:constructor()
    self.m_AttackRunning = false
    self.m_Id = false
    self.m_ColShapeHitBind = bind(self.onColShapeHit, self)
    self.m_DisqualifyBind = bind(self.onDisqualify, self)

    PlayerManager:getSingleton():getWastedHook():register(self.m_DisqualifyBind)
    Player.getQuitHook():register(self.m_DisqualifyBind)
end

function FactoryWarManager:destructor()

end

function FactoryWarManager:prepareAttack(id, faction, attacker)
    if DrugFactoryManager.Map[id] then
        local factory = DrugFactoryManager.Map[id]
        if not self.m_AttackRunning then
            if factory:getOwner() ~= faction then
                if faction > 4 then
                    if getRealTime().timestamp - factory:getLastAttack() > 86400 then
                        if #FactionManager:getSingleton():getFromId(faction):getOnlinePlayers(true) > 2 or DEBUG then
                            if #FactionManager:getSingleton():getFromId(factory:getOwner()):getOnlinePlayers(true) > 2 or DEBUG then
                                self.m_AttackRunning = true
                                self.m_Id = id
                                self.m_Attackers = FactionManager:getSingleton():getFromId(faction)
                                self.m_Defenders = FactionManager:getSingleton():getFromId(factory:getOwner())
                                self.m_ColShape = createColSphere(factory:getManager():getPosition(), 5)

                                addEventHandler("onColShapeHit", self.m_ColShape, self.m_ColShapeHitBind)

                                self.m_Attackers:sendMessage(("[Fabrikwar] #FFFFFFEure Fraktion startet einen Angriff auf die %s Fabrik in %s!"):format(factory:getType(), getZoneName(factory.m_Blip:getPosition())), 50, 200, 50, true)
                                self.m_Defenders:sendMessage(("[Fabrikwar] #FFFFFFEure %s Fabrik in %s wird von der Fraktion %s angegriffen!"):format(factory:getType(), getZoneName(factory.m_Blip:getPosition()), FactionManager:getSingleton():getFromId(faction):getName()), 200, 50, 50, true)
                            else
                                attacker:sendError("Es müssen mindestens zwei aktive Spieler der gegnerischen Fraktion online sein!")
                            end
                        else
                            attacker:sendError("Es müssen mindestens zwei aktive Spieler deiner Fraktion online sein!")
                        end
                    else
                        attacker:sendError("Diese Fabrik ist noch nicht angreifbar!")
                    end
                else
                    attacker:sendError("Du kannst keine Fabrik angreifen!")
                end
            else
                attacker:sendError("Du kannst deine eigene Fabrik nicht angreifen!")
            end
        else
            attacker:sendError("Es läuft bereits ein Fabrikwar!")
        end
    else
        outputDebugString("Internal Error: Factory not found")
    end
end

function FactoryWarManager:onColShapeHit(hitElement, matchingDimension)
    if matchingDimension then
        local attackersInCol = 0
        local defendersInCol = 0
        for key, player in ipairs(getElementsWithinColShape(source, "player")) do
            if player:getFaction() and player:getFaction() == self.m_Attackers then
                attackersInCol = attackersInCol + 1
            elseif player:getFaction() and player:getFaction() == self.m_Defenders then
                defendersInCol = defendersInCol + 1
            end
        end

        if attackersInCol > 2 then
            if attackersInCol == defendersInCol then
                self.m_Participants = {}
                for key, player in ipairs(getElementsWithinColShape(source, "player")) do
                    if player:getFaction() and (player:getFaction() == self.m_Attackers or player:getFaction() == self.m_Defenders) then
                        player:outputChat("[Fabrikwar] #FFFFFFDu nimmst am Fabrikwar teil! Sucht euch Deckung, in 2 Minuten geht der Kampf los!", 50, 200, 50, true)
                        self.m_Participants[#self.m_Participants+1] = player
                        player.m_FactoryWarParticipant = true
                    end
                end
                setTimer(self.startAttack, 120000, 1, self)
                removeEventHandler("onColShapeHit", self.m_ColShape, self.m_ColShapeHitBind)
            end
        end
    end
end

function FactoryWarManager:onDisqualify(player)
    if player then
        if player.m_FactoryWarParticipant then
            player.m_FactoryWarParticipant = false
            local aliveAttackers = 0
            local aliveDefenders = 0
            if self.m_Participants then
                for index = 1, #self.m_Participants do
                    if isElement(self.m_Participants[index]) then
                        if player:getFaction() and self.m_Participants[index]:getFaction() then
                            if self.m_Participants[index]:getFaction() == self.m_Attackers then
                                aliveAttackers = aliveAttackers + 1
                            else
                                aliveDefenders = aliveDefenders + 1
                            end

                            if player:getFaction() == self.m_Participants[index]:getFaction() then
                                player:getFaction():sendMessage("[Fabrikwar] #FFFFFFEin Mitglied ("..player:getName()..") ist ausgeschieden!", 200, 50, 50, true)
                            else
                                self.m_Participants[index]:getFaction():sendMessage("[Fabrikwar] #FFFFFFEin Gegner ("..player:getName()..") ist ausgeschieden!", 50, 200, 50, true)
                            end
                        end
                    end
                end
            end

            if aliveAttackers == 0 then
                self:endAttack(self.m_Defenders)
                self.m_Defenders:sendMessage("[Fabrikwar] #FFFFFFIhr habt die Fabrik verteidigt!", 200, 50, 50, true)
                self.m_Attackers:sendMessage("[Fabrikwar] #FFFFFFIhr habt die Fabrik nicht erobern können!", 50, 200, 50, true)
            elseif aliveDefenders == 0 then
                self:endAttack(self.m_Attackers)
                self.m_Defenders:sendMessage("[Fabrikwar] #FFFFFFIhr habt die Fabrik nicht verteidigen können!", 200, 50, 50, true)
                self.m_Attackers:sendMessage("[Fabrikwar] #FFFFFFIhr habt die Fabrik erobert!", 50, 200, 50, true)
            end
        end
    end
end

function FactoryWarManager:startAttack()
    if self:isFactoryWar() then
        self.m_EndTimer = setTimer(self.endAttack, 600000, 1, self)
    end
end

function FactoryWarManager:endAttack(faction)
    if DrugFactoryManager:getSingleton().Map[self.m_Id] then
        local factory = DrugFactoryManager:getSingleton().Map[self.m_Id]
        factory:setOwner(faction:getId())
        self.m_AttackRunning = false
        self.m_Id = false
        self.m_Attackers = false
        self.m_Defenders = false
        self.m_ColShape:destroy()
    end
end

function FactoryWarManager:isFactoryWar()
    return self.m_AttackRunning
end