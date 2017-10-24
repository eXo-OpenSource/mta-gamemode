Roulette = inherit(GUIForm)
inherit(Singleton, Roulette)

Roulette.ColorNames = {
    ["blue"] = "blau",
    ["green"] = "grün",
    ["pink"] = "pink",
    ["red"] = "rot",
    ["yellow"] = "gelb",
    ["gray"] = "grau",
    ["black"] = "schwarz"
}

addRemoteEvents{"rouletteOpen", "rouletteClose", "rouletteStartSpin"}

function Roulette:constructor()
    GUIForm.constructor(self, screenWidth/2 - 1024/2, screenHeight/2-506/2, 1024, 506, false)
    self.m_CurrentNumber = 0

	self.m_CircleRot = 0
	self.m_CircleAnimation = CAnimation:new(self, bind(Roulette.onSpinDone, self), "m_CircleRot")

    self.m_Table = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Roulette/table.png", self)
    self.m_Circle = GUIImage:new(64, 168, 263, 263, "files/images/Roulette/circle.png", self)
    self.m_Arrow = GUIImage:new(34, 278, 57, 41, "files/images/Roulette/Arrow.png", self)

    self:loadColors()

    self.m_CurrentRect = GUIRectangle:new(17, 445, 80, 40, self.m_Color[self.m_CurrentNumber], self)
    self.m_CurrentLabel = GUILabel:new(17, 445, 80, 40, self.m_CurrentNumber, self):setAlignX("center"):setAlignY("center")

    self.m_InfoLabel = GUILabel:new(400, 478, 400, 24, "", self)

    self.m_RenderMouseToken = bind(self.renderMouseToken, self)

    self.m_PlacedToken = {}
    self.m_PlacedTokenImages = {}
    self.m_TableLocked = false

    self:createFields()
    self:createTokens()

    self.m_StartSpinEvent = bind(self.Event_startSpin, self)

    addEventHandler("rouletteStartSpin", root, self.m_StartSpinEvent)
end

function Roulette:destructor()
    GUIForm.destructor(self)
	removeEventHandler("rouletteStartSpin", root, self.m_StartSpinEvent)
end

function Roulette:loadColors()
    self.m_Color = {}
    for index, number in pairs(ROULETTE_NUMBERS) do
        if (index%2 == 0) then
            self.m_Color[number] = tocolor(255, 0, 0)
        else
            self.m_Color[number] = tocolor(0, 0, 0)
        end
    end
    self.m_Color[0] = tocolor(0, 255, 0)
end

function Roulette:updateRenderTarget()
	self.m_Circle:setRotation(-self.m_CircleRot)
	self.m_CurrentNumber = ROULETTE_NUMBERS[math.floor(self.m_CircleRot%360/9.73)+1]

	self.m_CurrentLabel:setText(self.m_CurrentNumber)
	self.m_CurrentRect:setColor(self.m_Color[self.m_CurrentNumber])
end

function Roulette:onSpinDone()
    triggerServerEvent("rouletteOnSpinDone", localPlayer, clientNumber)
	setTimer(function()
		 self.m_TableLocked = false
		 self:clearTokens()
	end, 2000, 1)
end

function Roulette:spin()
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
    triggerServerEvent("rouletteSpin", root, self.m_PlacedToken)
end

function Roulette:cheatSpin(value)
    if self.m_TableLocked then
        ErrorBox:new(_"Der Tisch ist gesperrt!")
        return
    end
	self.m_TableLocked = true
    triggerServerEvent("rouletteCheatSpin", root, self.m_PlacedToken, value)
end


function Roulette:Event_startSpin(target)
	local rotation = table.find(ROULETTE_NUMBERS, target)*9.73 - 9.73/2
    local uselessRotation = math.random(3, 7)*360
    local absoluteRotation = rotation+uselessRotation

    if not self.m_CircleAnimation:isAnimationRendered() then
		self.m_CircleRot = 0
		self.m_CircleAnimation:startAnimation(10000/2880*absoluteRotation, "OutQuad", absoluteRotation)
	else
		self.m_CircleAnimation:stopAnimation()
	end
end

function Roulette:createFields()
    self.m_Fields = {}
    self.m_Fields[0] = GUIRectangle:new(431, 202, 34, 152, Color.Clear, self)
    local num = 1
    local x, y = 467, 306
    for i=1, 12 do
        self.m_Fields[num+2] = GUIRectangle:new(x, y-104, 34, 49, Color.Clear, self)
        self.m_Fields[num+1] = GUIRectangle:new(x, y-52, 34, 49, Color.Clear, self)
        self.m_Fields[num] =  GUIRectangle:new(x, y, 34, 49, Color.Clear, self)
        num = num+3
        x = x + 35
	end

    self.m_Fields["2-1_3"] = GUIRectangle:new(x, y-104, 34, 49, Color.Clear, self)
    self.m_Fields["2-1_2"] = GUIRectangle:new(x, y-52, 34, 49, Color.Clear, self)
    self.m_Fields["2-1_1"] = GUIRectangle:new(x, y, 34, 49, Color.Clear, self)

    x, y = 467, 150
    self.m_Fields["1-18"] = GUIRectangle:new(x, y, 68, 49, Color.Clear, self)
    self.m_Fields["even"] = GUIRectangle:new(x+70*1, y, 68, 49, Color.Clear, self)
    self.m_Fields["red"] =  GUIRectangle:new(x+70*2, y, 68, 49, Color.Clear, self)
    self.m_Fields["black"] = GUIRectangle:new(x+70*3, y, 68, 49, Color.Clear, self)
    self.m_Fields["odd"] =  GUIRectangle:new(x+70*4, y, 68, 49, Color.Clear, self)
    self.m_Fields["19-36"] = GUIRectangle:new(x+70*5, y, 68, 49, Color.Clear, self)

    x, y = 467, 358
    self.m_Fields["1st 12"] =  GUIRectangle:new(x, y, 139, 49, Color.Clear, self)
    self.m_Fields["2nd 12"] =  GUIRectangle:new(x+140*1, y, 139, 49, Color.Clear, self)
    self.m_Fields["3rd 12"] =  GUIRectangle:new(x+140*2, y, 139, 49, Color.Clear, self)

	for field, fieldElement in pairs(self.m_Fields) do
        fieldElement.onHover = function()
            nextframe(function()
                for index, number in pairs(ROULETTE_WINNUMBERS[field]) do
                    self.m_Fields[number]:setColor(tocolor(255, 255, 0, 128))
                end
                self.m_InfoLabel:setText(("Feld \"%s\" - Du hast auf das Feld %s gesetzt!"):format(field, toMoneyString(self:calcBetOnField(field))))
            end)
        end
        fieldElement.onUnhover = function()
            for index, field2 in pairs(self.m_Fields) do
                field2:setColor(Color.Clear)
            end
            self.m_InfoLabel:setText("")

        end
        fieldElement.onLeftClickDown = function()
            if self.m_AttachedToken then
                self:placeToken(field)
            else
                --outputChatBox("Du hast auf das Feld "..field.." ohne Jetton geklickt!", 255, 0, 0)
            end
        end
        fieldElement.onRightClick = function()
            self:removeTokensFromField(field, true)
        end

	end
end

function Roulette:placeToken(field)
    if self.m_TableLocked then
        ErrorBox:new(_"Der Tisch ist gesperrt!")
        return
    end

    local color = self.m_AttachedToken

    if self:calcBet() + ROULETTE_TOKENS[color] > ROULETTE_MAX_BET then
        ErrorBox:new(_("Der maximal Einsatz beträgt %s!", toMoneyString(ROULETTE_MAX_BET)))
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
    self.m_InfoLabel:setText(("Feld \"%s\" - Du hast auf das Feld %s gesetzt!"):format(field, toMoneyString(self:calcBetOnField(field))))
    ShortMessage:new(_("Du hast deinen %d. %sen Token auf das Feld %s gesetzt!", self.m_PlacedToken[field][color], Roulette.ColorNames[color], field), "Roulette")
    setTimer(function()
        self:attachTokenToMouse(color)
    end, 75, 1)
end

function Roulette:clearTokens(output)
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

function Roulette:removeTokensFromField(field, output)
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

function Roulette:updateBetGui()
    RouletteGUI:getSingleton().m_BetLabel:setText(("Gesamter Einsatz:\n%s"):format(toMoneyString(self:calcBet())))
end

function Roulette:calcBet()
    local total = 0
    for field, fieldElement in pairs(self.m_Fields) do
        total = total + self:calcBetOnField(field)
    end
    return total
end

function Roulette:calcBetOnField(field)
    local total = 0
    if self.m_PlacedToken[field] then
        for color, amount in pairs(self.m_PlacedToken[field]) do
            total = total + ROULETTE_TOKENS[color]*amount
        end
    end
    return total
end

function Roulette:getDifferentTokensOnField(field)
    local count = 0
    if self.m_PlacedTokenImages[field] then
        for i, v in pairs(self.m_PlacedTokenImages[field]) do
            count = count+1
        end
    end
    return count
end

function Roulette:attachTokenToMouse(color)
    self.m_AttachedToken = color
    addEventHandler("onClientRender", root, self.m_RenderMouseToken)
    addEventHandler("onClientClick", root, function(btn, state)
        nextframe(function()
            if state == "down" then
                self.m_AttachedToken = nil
                removeEventHandler("onClientRender", root, self.m_RenderMouseToken)
            end
        end)
    end)
end

function Roulette:renderMouseToken()
    if isCursorShowing() and self.m_AttachedToken then
        local cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
        dxDrawImage(cursorX, cursorY, 28, 28, ("files/images/Roulette/token_%s.png"):format(self.m_AttachedToken))
    end
end

function Roulette:createTokens()
    self.m_Token = {}
    local i = 0

    for color, amount in spairs(ROULETTE_TOKENS, function(t,a,b) return t[b] > t[a] end) do
        self.m_Token[color] = GUIImage:new(450+40*i, 440, 28, 28, ("files/images/Roulette/token_%s.png"):format(color), self)
        self.m_Token[color].amount = amount
        self.m_Token[color].onHover = function() self.m_InfoLabel:setText(("%ser Jetton - Wert pro Stück: %s"):format(Roulette.ColorNames[color], toMoneyString(amount))) end
        self.m_Token[color].onUnhover = function() self.m_InfoLabel:setText("") end
        self.m_Token[color].onLeftClick = function() self:attachTokenToMouse(color) end
        i = i+1
    end
end

addEventHandler("rouletteOpen", root, function()
    Roulette:new()
end)


addEventHandler("rouletteClose", root, function()
    delete(Roulette:getSingleton())
end)
