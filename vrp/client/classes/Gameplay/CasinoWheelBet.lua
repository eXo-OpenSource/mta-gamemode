-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Minigames/CasinoWheelBet.lua
-- *  PURPOSE:     CasinoWheelBet
-- *
-- ****************************************************************************
CasinoWheelBet = inherit(GUIForm)
inherit(Singleton, CasinoWheelBet)

CasinoWheelBet.ColorNames = {
    ["blue"] = "blau",
    ["green"] = "grün",
    ["pink"] = "pink",
    ["red"] = "rot",
    ["yellow"] = "gelb",
    ["gray"] = "grau",
    ["black"] = "schwarz"
}



function CasinoWheelBet:constructor()
    GUIForm.constructor(self, screenWidth/2 - 720/2, screenHeight-400, 720, 360, false)
    self.m_CurrentNumber = 0


    self.m_Table = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/CasinoWheel/table.png", self)


    self.m_InfoLabel = GUILabel:new(49, 57, 370, 30, "", self):setFont(VRPFont(24))
    self.m_BetLabel = GUILabel:new(49, 270, 370, 30, "", self):setFont(VRPFont(24))

    self.m_BetButton = GUIButton:new(458, 280, 98, 30, "Setzen", self):setAlternativeColor(tocolor(11,54,42)):setBackgroundColor(Color.White)
    self.m_BetButton.m_AnimatedBar:setColor(tocolor(0, 153, 0))
    self.m_BetButton.onLeftClick = bind(self.submit, self)

    self.m_RedrawButton = GUIButton:new(458, 280, 98, 30, "Zurück", self):setAlternativeColor(tocolor(11,54,42)):setBackgroundColor(Color.White):setVisible(false):setEnabled(false)
    self.m_RedrawButton.m_AnimatedBar:setColor(tocolor(0, 153, 0))
    self.m_RedrawButton.onLeftClick = bind(self.redraw, self)


    self.m_EndButton = GUIButton:new(560, 280, 94, 30, "Ende", self):setAlternativeColor(tocolor(11,54,42)):setBackgroundColor(Color.White)
    self.m_EndButton.m_AnimatedBar:setColor(Color.Black)
    self.m_EndButton.onLeftClick = function() 
        delete(self)
    end

    self.m_RenderMouseToken = bind(self.renderMouseToken, self)
    self.m_ClickEventBind = bind(self.onClickEvent, self)

    self.m_PlacedToken = {}
    self.m_PlacedTokenImages = {}
    self.m_TableLocked = false

    

    self:createTokens()
    self:createFields()
end

function CasinoWheelBet:reset() 
    self:clearTokens()
    self.m_BetButton:setVisible(true)
    self.m_BetButton:setEnabled(true)

    self.m_RedrawButton:setVisible(false)
    self.m_RedrawButton:setEnabled(false)
end

function CasinoWheelBet:activateRedraw() 
    self.m_BetButton:setVisible(false)
    self.m_BetButton:setEnabled(false)

    self.m_RedrawButton:setVisible(true)
    self.m_RedrawButton:setEnabled(true)
end


function CasinoWheelBet:lockBet() 
    self.m_BetButton:setVisible(true)
    self.m_BetButton:setEnabled(false)

    self.m_RedrawButton:setVisible(false)
    self.m_RedrawButton:setEnabled(false)
end


function CasinoWheelBet:destructor()
    removeEventHandler("onClientRender", root, self.m_RenderMouseToken)
    removeEventHandler("onClientClick", root, self.m_ClickEventBind)
    GUIForm.destructor(self)
    CasinoWheel:getSingleton():stop()
    setCameraTarget(localPlayer)
end

function CasinoWheelBet:updateRenderTarget()
	self.m_Circle:setRotation(-self.m_CircleRot)
	self.m_CurrentNumber = CasinoWheelBet_NUMBERS[math.floor(self.m_CircleRot%360/9.73)+1]

	self.m_CurrentLabel:setText(self.m_CurrentNumber)
	self.m_CurrentRect:setColor(self.m_Color[self.m_CurrentNumber])
end

function CasinoWheelBet:onSpinDone()
    triggerServerEvent("CasinoWheelBetOnSpinDone", localPlayer, clientNumber)
	setTimer(function()
		 self.m_TableLocked = false
		 self:clearTokens()
	end, 2000, 1)
end

function CasinoWheelBet:spin()
    if self.m_TableLocked then
        ErrorBox:new(_"Der Tisch ist gesperrt!")
        return
    end
	if self:calcBet() == 0 then
		ErrorBox:new(_"Du hast nichts gesetzt!")
        return
	end
	if localPlayer:getMoney() < self:calcBet() then
		ErrorBox:new(_"Du hast nicht genug Geld dabei!")
        return
	end
	self.m_TableLocked = true
    triggerServerEvent("CasinoWheelBetSpin", root, self.m_PlacedToken)
end

function CasinoWheelBet:cheatSpin(value)
    if self.m_TableLocked then
        ErrorBox:new(_"Der Tisch ist gesperrt!")
        return
    end
	self.m_TableLocked = true
    triggerServerEvent("CasinoWheelBetCheatSpin", root, self.m_PlacedToken, value)
end


function CasinoWheelBet:createFields() 
    self.m_Fields = {}
    self.m_Fields["20"] = GUIRectangle:new(56, 100, 85, 56, Color.Clear, self)
    self.m_Fields["20"].value = "Zahl 20"

    self.m_Fields["5"] = GUIRectangle:new(196, 100, 85, 56, Color.Clear, self)
    self.m_Fields["5"].value = "Zahl 5"

    self.m_Fields["1"] = GUIRectangle:new(337, 100, 85, 56, Color.Clear, self)
    self.m_Fields["1"].value = "Zahl 1"

    self.m_Fields["10"] = GUIRectangle:new(56, 198, 85, 56, Color.Clear, self)
    self.m_Fields["10"].value = "Zahl 10"

    self.m_Fields["2"] = GUIRectangle:new(196, 198, 85, 56, Color.Clear, self)
    self.m_Fields["2"].value = "Zahl 2"

    self.m_Fields["40"] = GUIRectangle:new(337, 198, 85, 56, Color.Clear, self)
    self.m_Fields["40"].value = "Stern"
    
    for field, label in pairs(self.m_Fields) do 
        label.onHover = function()
            nextframe(function()
                self.m_InfoLabel:setText(("%s - Du hast auf das Feld %s gesetzt!"):format(label.value, toMoneyString(self:calcBetOnField(field))))
            end)
        end

        label.onUnhover = function()
            for index, field2 in pairs(self.m_Fields) do
                field2:setColor(Color.Clear)
            end
            self.m_InfoLabel:setText("")
        end
        label.onLeftClickDown = function()
            if self.m_AttachedToken then
                self:placeToken(field)
            else
                --outputChatBox("Du hast auf das Feld "..field.." ohne Jetton geklickt!", 255, 0, 0)
            end
        end

        label.onRightClick = function()
            self:removeTokensFromField(field, true)
        end
    end
end


function CasinoWheelBet:placeToken(field)
    if self.m_TableLocked then
        ErrorBox:new(_"Der Tisch ist gesperrt!")
        return
    end

    local color = self.m_AttachedToken

    if self:calcBet() + ROULETTE_TOKENS[color] > 400000  then
        ErrorBox:new(_("Der maximal Einsatz beträgt %s!", "lol"))
        return
    end

	if localPlayer:getMoney() < self:calcBet() + ROULETTE_TOKENS[color] then
		ErrorBox:new(_"Du hast nicht genug Geld dabei!")
        return
	end

    if not self.m_PlacedToken[field] then self.m_PlacedToken[field] = {} self.m_PlacedTokenImages[field] = {} end
    if not self.m_PlacedToken[field][color] then
        self.m_PlacedToken[field][color] = 0
        if not self.m_PlacedTokenImages[field][color] then
            local offset = self:getDifferentTokensOnField(field)*5
            self.m_PlacedTokenImages[field][color] = GUIImage:new(0, offset, 28, 28, ("files/images/Roulette/token_%s.png"):format(color), self.m_Fields[field])
        end
    end
    self.m_PlacedToken[field][color] =  self.m_PlacedToken[field][color] + 1
    self:updateBetGui()
    self.m_InfoLabel:setText(("%s - Du hast auf das Feld %s gesetzt!"):format(field, toMoneyString(self:calcBetOnField(field))))
    ShortMessage:new(_("Du hast deinen %d. %sen Token auf das %s gesetzt!", self.m_PlacedToken[field][color], CasinoWheelBet.ColorNames[color], field), "Glücksrad")
    setTimer(function()
        self:attachTokenToMouse(color)
    end, 75, 1)
end

function CasinoWheelBet:clearTokens(output)
    if self.m_TableLocked then
		ErrorBox:new(_"Der Tisch ist gesperrt!")
        return
    end
    for field, fieldElement in pairs(self.m_Fields) do
        self:removeTokensFromField(field)
    end
    self.m_PlacedToken = {}
    self.m_PlacedTokenImages = {}
    self:updateBetGui()
	if output then
		ShortMessage:new(_"Du hast alle Jetons vom Tisch entfernt!")
	end
end

function CasinoWheelBet:removeTokensFromField(field, output)
    if self.m_TableLocked then
        ErrorBox:new(_"Der Tisch ist gesperrt!")
        return
    end
    if self.m_PlacedTokenImages[field] then
        for color, tokenImg in pairs(self.m_PlacedTokenImages[field]) do
            delete(tokenImg)
        end
    end
    if self.m_PlacedToken[field] then
        self.m_PlacedToken[field] = {}
        self.m_PlacedTokenImages[field] = {}
        self:updateBetGui()
        if output then ShortMessage:new(_("Du hast alle Jetons vom Feld %s entfernt!", field)) end
    end
end

function CasinoWheelBet:updateBetGui()
    self.m_BetLabel:setText(("Gesamter Einsatz: %s"):format(toMoneyString(self:calcBet())))
end

function CasinoWheelBet:calcBet()
    local total = 0
    for field, fieldElement in pairs(self.m_Fields) do
        total = total + self:calcBetOnField(field)
    end
    return total
end

function CasinoWheelBet:calcBetOnField(field)
    local total = 0
    if self.m_PlacedToken[field] then
        for color, amount in pairs(self.m_PlacedToken[field]) do
            total = total + ROULETTE_TOKENS[color]*amount
        end
    end
    return total
end

function CasinoWheelBet:getDifferentTokensOnField(field)
    local count = 0
    if self.m_PlacedTokenImages[field] then
        for i, v in pairs(self.m_PlacedTokenImages[field]) do
            count = count+1
        end
    end
    return count
end

function CasinoWheelBet:attachTokenToMouse(color)
    self.m_AttachedToken = color
    
    removeEventHandler("onClientRender", root, self.m_RenderMouseToken)
    addEventHandler("onClientRender", root, self.m_RenderMouseToken)
    
    removeEventHandler("onClientClick", root, self.m_ClickEventBind)
    addEventHandler("onClientClick", root, self.m_ClickEventBind)
end

function CasinoWheelBet:onClickEvent(btn, state)
    nextframe(function()
        if state == "down" then
            self.m_AttachedToken = nil
            removeEventHandler("onClientRender", root, self.m_RenderMouseToken)
        end
    end)
end
function CasinoWheelBet:renderMouseToken()
    if isCursorShowing() and self.m_AttachedToken then
        local cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
        dxDrawImage(cursorX, cursorY, 28, 28, ("files/images/Roulette/token_%s.png"):format(self.m_AttachedToken))
    end
end

function CasinoWheelBet:createTokens()
    self.m_Token = {}
    local i = 0

    for color, amount in spairs(ROULETTE_TOKENS, function(t,a,b) return t[b] > t[a] end) do
        self.m_Token[color] = GUIImage:new(570, 50+i*30, 28, 28, ("files/images/Roulette/token_%s.png"):format(color), self)
		self.m_Token[color].label = GUILabel:new(570-100, 50+i*30, 100, 28, ("$%s"):format(convertNumber(amount)), self):setAlign("center", "center"):setFont(VRPFont(28))
        self.m_Token[color].amount = amount
        self.m_Token[color].onHover = function() self.m_InfoLabel:setText(("%ser Jetton - Wert pro Stück: %s"):format(CasinoWheelBet.ColorNames[color], toMoneyString(amount))) end
        self.m_Token[color].onUnhover = function() self.m_InfoLabel:setText("") end
        self.m_Token[color].onLeftClick = function() self:attachTokenToMouse(color) end
		 self.m_Token[color].label.onLeftClick = function() self:attachTokenToMouse(color) end
        i = i+1
    end
end

function CasinoWheelBet:submit() 
    if self.m_PlacedToken and self.m_PlacedToken ~= {} then
        triggerServerEvent("CasinoWheel:onPlayerSubmitBet", localPlayer, self.m_PlacedToken)
    end
end

function CasinoWheelBet:redraw() 
    triggerServerEvent("CasinoWheel:onPlayerRedrawBet", localPlayer)
end