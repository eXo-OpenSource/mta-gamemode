-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/Quests/PriestQuest.lua
-- *  PURPOSE:     Priest Quest class
-- *
-- ****************************************************************************

PriestQuest = inherit(HalloweenQuest)

function PriestQuest:constructor()
    self.m_Totem = createObject(3524, -325, 2222, 44.3, 0, 0, 284.5)

    self.m_ColShape = createColSphere(-325, 2222, 44.3, 40)
    addEventHandler("onClientColShapeHit", self.m_ColShape, bind(self.onClientColShapeHit, self))

    self.m_Priest = HalloweenGhost:new(Vector3(-326.721, 2221.383, 43.517), 104, 0, 0, false, bind(self.onGhostKill, self))
    self.m_Priest:setModel(68)
    self.m_Priest:setHealth(1000)

    self.m_RenderBind = bind(self.render, self)

    HalloweenGhost.MarkerSpeed = 1500
    HalloweenGhost.AttackCooldown = 5000
    HalloweenGhost.MarkerSize = 5
end

function PriestQuest:virtual_destructor()
    self.m_Totem:destroy()
    self.m_Ghost:destroy()
    delete(self.m_Priest)
    if isEventHandlerAdded("onClientClick", root, self.m_ClickBind) then
        removeEventHandler("onClientClick", root, self.m_ClickBind)
    end
end

function PriestQuest:startQuest()
    self:createDialog(bind(self.onStart, self),
        "Geh und zerstör das Totem!"
    )
end

function PriestQuest:onStart()
    triggerServerEvent("Halloween:giveGhostCleaner", localPlayer)
    self.m_QuestMessage = ShortMessage:new("Zerstöre das Totem!", "Halloween: Quest", Color.Orange, -1, false, false, false, false, true)
end

function PriestQuest:onClientColShapeHit(hitElement, matchingDimension)
    if matchingDimension then
        if hitElement == localPlayer then
            self.m_ColShape:destroy()
            toggleAllControls(false)
            self:createDialog(bind(self.createGhost, self),
                "Dachtest Du wirklich, Du könntest meine Pläne durchkreuzen?",
                "Du bist viel zu spät um die Welt zu retten, Du Witzfigur von Mensch!",
                "Ich werde nun zu einem Wesen, welches viel mächtiger als jeglicher Mensch ist!",
                "Ich werde nun zu einem Geistigen!"
            )
        end
    end
end

function PriestQuest:createGhost()
    self.m_Ghost = createPed(260, -331.463, 2220.617, 55.634)
    self.m_Ghost:attach(self.m_Priest.m_MoveObject, 0.25, 0, 0, 0, 0, 104)
    self.m_Ghost:setRotation(0, 0, 104)
    self.m_Ghost:setFrozen(true)

    self.m_GhostShader = dxCreateShader("files/shader/pedSize.fx", 0, 0, false, "ped")
    dxSetShaderValue(self.m_GhostShader, "size", -1, -1, -1)
    engineApplyShaderToWorldTexture(self.m_GhostShader, "*", self.m_Ghost)


    self.m_Priest:setAlpha(250)

    self.m_PriestShader = dxCreateShader("files/shader/pedWall.fx", 0, 0, false, "ped")
    dxSetShaderValue(self.m_PriestShader, "sSpecularPower", 150)
    dxSetShaderValue(self.m_PriestShader, "sColorizePed", {1, 0, 0, 0})
    
    self.m_Priest.m_MoveObject:move(3000, -326.721, 2221.383, 66.517, 0, 0, 0, "InOutQuad")


    setTimer(
        function()
            self.m_SizeStartTime = getTickCount()
            self.m_SizeEndTime = self.m_SizeStartTime + 3000
            addEventHandler("onClientRender", root, self.m_RenderBind)
        end
    , 4000, 1)
end

function PriestQuest:render()
    local now = getTickCount()
	local elapsedTime = now - self.m_SizeStartTime
	local duration = self.m_SizeEndTime - self.m_SizeStartTime
	local progress = elapsedTime / duration
    size = interpolateBetween(0, 0, 0, 10, 0, 0, progress, "OutQuad")
    dxSetShaderValue(self.m_GhostShader, "size", size, size, size)

    position = interpolateBetween(0, 0, 0, 3.5, 0, 0, progress, "OutQuad")
    self.m_Ghost:attach(self.m_Priest.m_MoveObject, 0.25, 0, -position)

    if size >= 10 then
        if not self.m_VisibleStartTime then
            self.m_VisibleStartTime = getTickCount()
            self.m_VisibleEndTime = self.m_VisibleStartTime + 5000
            engineApplyShaderToWorldTexture(self.m_PriestShader, "*" , self.m_Priest.m_Ped)
        end

        local now = getTickCount()
	    local elapsedTime = now - self.m_VisibleStartTime
	    local duration = self.m_VisibleEndTime - self.m_VisibleStartTime
	    local progress = elapsedTime / duration
        alpha = interpolateBetween(0, 0, 0, 1.0, 0, 0, progress, "Linear")
        dxSetShaderValue(self.m_PriestShader, "sColorizePed", {1, 0, 0, alpha})

        if alpha >= 1.0 then
            if not self.m_PriestAttack then
                self.m_PriestAttack = true
                self.m_Priest:setAttackMode(true)
                self.m_Priest:setHealth(30)
                self.m_QuestMessage:setText("Töte den Priester!")
                toggleAllControls(true)
            end
        end
    end

    if self.m_InvisibleStartTime then
        local now = getTickCount()
        local elapsedTime = now - self.m_InvisibleStartTime
        local duration = self.m_InvisibleEndTime - self.m_InvisibleStartTime
        local progress = elapsedTime / duration
        alpha = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "Linear")
        self.m_Ghost:setAlpha(alpha)
        if alpha <= 0 then
            removeEventHandler("onClientRender", root, self.m_RenderBind)
        end
    end

end

function PriestQuest:onGhostKill()
    self.m_InvisibleStartTime = getTickCount()
    self.m_InvisibleEndTime = self.m_InvisibleStartTime + 3000
    self.m_QuestMessage:setText("Zerstöre das letzte Totem!")
    setElementData(self.m_Totem, "clickable", true)
    self.m_Totem:setData("onClickEvent", 
        function()
            self.m_Totem:destroy()
            SuccessBox:new("Totem abgebaut!")
            self:setSucceeded()
            self.m_QuestMessage:setText("Kehre nun zum Friedhof zurück!")
        end
    )
end

function PriestQuest:endQuest()
    self:createDialog(false, 
        "Du bist einem Priester begegnet, der sich in einen riesigen Geist verwandelt hat?",
        "Und Du hast ihn getötet?!",
        "Du bist ein echter Held!",
        "Du hast die Welt vor dem sicheren Untergang bewahrt!",
        "Hier, eine Belohung für deine wundervolle Arbeit!"
    )
end