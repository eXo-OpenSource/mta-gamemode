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
end

function FactoryWarManager:destructor()

end

function FactoryWarManager:startAttack(id, faction, attacker)
    if DrugFactoryManager.Map[id] then
        local factory = DrugFactoryManager.Map[id]
        if not self.m_AttackRunning then
            if factory:getOwner() ~= faction then
                if faction > 4 then
                    if getRealTime().timestamp - factory:getLastAttack() > 86400 then
                        if #FactionManager:getSingleton():getFromId(faction):getOnlinePlayers(true) > 2 or DEBUG then
                            if #FactionManager:getSingleton():getFromId(factory:getOwner()):getOnlinePlayers(true) > 2 or DEBUG then
                                self.m_AttackRunning = true
                                FactionManager:getSingleton():getFromId(faction):sendMessage(("[Fabrikwar] #FFFFFFEure Fraktion startet einen Angriff auf die %s Fabrik in %s!"):format(factory:getType(), getZoneName(factory.m_Blip:getPosition())), 200, 50, 50, true)
                                FactionManager:getSingleton():getFromId(factory:getOwner()):sendMessage(("[Fabrikwar] #FFFFFFEure %s Fabrik in %s wird von der Fraktion %s angegriffen!"):format(factory:getType(), getZoneName(factory.m_Blip:getPosition()), FactionManager:getSingleton():getFromId(faction):getName()), 200, 50, 50, true)
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

function FactoryWarManager:isFactoryWar()
    return self.m_AttackRunning
end