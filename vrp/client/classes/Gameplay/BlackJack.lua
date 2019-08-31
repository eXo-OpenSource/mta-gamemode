-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Minigames/BlackJack.lua
-- *  PURPOSE:     BlackJack
-- *
-- ****************************************************************************

BlackJack = inherit(GUIForm) 
inherit(Singleton, BlackJack)

local imagePath = "files/images/BlackJack/"
local cardPath = "files/images/CardDeck/"
local soundPath = "files/audio/"

addRemoteEvents{"BlackJack:start", "BlackJack:cancel", "BlackJack:end", "BlackJack:draw", "BlackJack:reset", "BlackJack:notify", "BlackJack:insurance", "BlackJack:updateSpectator"}

function BlackJack:constructor(bets, spectate, object, previous) 
	self.m_Shader = DxShader("files/shader/vignette.fx")
	self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

	GUIForm.constructor(self, screenWidth/2 - 800/2, screenHeight/2-506/2, 800, 506, false)
	


	self.m_Dealer = {}
	self.m_Bets = bets
	self.m_Player = {}
	self.m_CardTimers = {}
	self.m_Object = object
	self.m_Spectate = spectate
	self:setup()
	
	self.m_BindDrawCard = bind(self.Event_DrawCard, self)
	addEventHandler("BlackJack:draw", localPlayer, self.m_BindDrawCard)

	self.m_ResetCards = bind(self.Event_ResetCards, self)
	addEventHandler("BlackJack:reset", localPlayer, self.m_ResetCards)

	self.m_Notify = bind(self.Event_Notify, self)
	addEventHandler("BlackJack:notify", localPlayer, self.m_Notify)

	
	self.m_Insurance = bind(self.Event_Insurance, self)
	addEventHandler("BlackJack:insurance", localPlayer, self.m_Insurance)

	self.m_UpdateSpectator = bind(self.Event_UpdateSpectator, self)
	addEventHandler("BlackJack:updateSpectator", localPlayer, self.m_UpdateSpectator)

	if not self.m_Spectate then
		self.m_BlockInput = true
		self.m_StartBorder = self:createBorder(self.m_Width/2-300, self.m_Height/2-20, 160, 30, 2, Color.White, self)

		self.m_StartButton = GUIButton:new(self.m_Width/2-300, self.m_Height/2-20, 160, 30, "Start", self):setAlternativeColor(tocolor(51,120,37, 0)):setBackgroundColor(Color.White):setEnabled(false):setVisible(false)
		self.m_StartButton.m_AnimatedBar:setColor(Color.Black)


		self.m_StartButton.onLeftClick = function() 
			self.m_StartButton:setVisible(false)
			self.m_StartButton:setEnabled(false)
			for i = 1, #self.m_DealerBorder do 
				self.m_DealerBorder[i]:setVisible(false)
			end
			for i = 1, #self.m_PlayerBorder do 
				self.m_PlayerBorder[i]:setVisible(false)
			end
			for i = 1, #self.m_StartBorder do 
				self.m_StartBorder[i]:setVisible(false)
			end
			triggerServerEvent("BlackJackManager:onReady", localPlayer, self.m_Bet) 
		end
		self.m_StartButton:setVisible(true):setEnabled(true)
	end

		
	self.m_ShaderRadius = previous and 20 or 0
	self.m_ShaderDarkness = previous and 1 or 0
end

function BlackJack:setup() 
  	--self.m_Table = GUIImageSection:new(0, 0, self.m_Width, self.m_Height, 0, 0, 1000, 1000, "files/images/BlackJack/table.jpg", self)
	GUIImage:new(0, 0, self.m_Width, self.m_Height, self:makeImagePath("table.jpg"), self)
	GUIRectangle:new(0, 0, 10, self.m_Height, Color.Wood, self)
	GUIRectangle:new(self.m_Width-10, 0, 10, self.m_Height, Color.Wood, self)
	GUIRectangle:new(0, 0, self.m_Width, 10, Color.Wood, self)
	GUIRectangle:new(0, self.m_Height-10, self.m_Width, 10, Color.Wood, self)

	self.m_DealerImage = GUIImage:new(self.m_Width/2-240, self.m_Height/2-240, 160, 160, self:makeImagePath("dealer_e_open.png"), self)
	GUIRectangle:new(self.m_Width/2-300, self.m_Height/2-82, 600, 3, Color.White, self)


	GUILabel:new(self.m_Width/2-36, self.m_Height/2-210, 72, 10, "Dealer", self):setFont(VRPFont(20)):setAlignX("center")
	self.m_DealerBorder = self:createBorder(self.m_Width/2-36, self.m_Height/2-190, 72, 100, 2, Color.White, self)
	self.m_DealerValueShadow = GUILabel:new(self.m_Width/2+91, self.m_Height/2-229, 120, 36, "Wert: 0", self):setFont(VRPFont(28)):setAlignX("center"):setColor(Color.Black):setAlignY("center")
	self.m_DealerValue = GUILabel:new(self.m_Width/2+90, self.m_Height/2-230, 120, 36, "Wert: 0", self):setFont(VRPFont(28)):setAlignX("center"):setAlignY("center")
	self:createBorder(self.m_Width/2+91, self.m_Height/2-229, 120, 36, 2, Color.Black, self)
	self:createBorder(self.m_Width/2+90, self.m_Height/2-230, 120, 36, 2, Color.White, self)

	if not self.m_Spectate then
		GUILabel:new(self.m_Width/2-36, self.m_Height/2+70, 72, 10, "Du", self):setFont(VRPFont(20)):setAlignX("center")
	else 	
		if isValidElement(self.m_Spectate, "player") then 
			GUILabel:new(self.m_Width/2-36, self.m_Height/2+70, 72, 10, self.m_Spectate.name, self):setFont(VRPFont(20)):setAlignX("center")
		end
	end
	self.m_PlayerBorder = self:createBorder(self.m_Width/2-36, self.m_Height/2+90, 72, 100, 2, Color.White, self)
	self.m_PlayerValueShadow = GUILabel:new(self.m_Width/2+91, self.m_Height/2+51, 120, 36, "Wert: 0", self):setFont(VRPFont(28)):setAlignX("center"):setColor(Color.Black):setAlignY("center")
	self.m_PlayerValue = GUILabel:new(self.m_Width/2+90, self.m_Height/2+50, 120, 36, "Wert: 0", self):setFont(VRPFont(28)):setAlignX("center"):setAlignY("center")
	self:createBorder(self.m_Width/2+92, self.m_Height/2+52, 120, 36, 2, Color.Black, self)
	self:createBorder(self.m_Width/2+91, self.m_Height/2+51, 120, 36, 2, Color.White, self)

	self.m_BetChange = GUIChanger:new(self.m_Width/2-100, self.m_Height/2-20, 200, 30, self):setBackgroundColor(Color.Clear):setAlternateColor(Color.Clear)
	self.m_BetChange.m_LeftButton:setColor(Color.Clear)
	self.m_BetChange.m_RightButton:setColor(Color.Clear)
	self.m_Bet = 1
	for k, amount in ipairs(self.m_Bets) do 
		self.m_BetChange:addItem(("$%s"):format(convertNumber(amount)))
	end
	self.m_BetChange.onChange = function(item, index)
		if self.m_Bets[index] then 
			self.m_Bet = index
		end
	end

	self.m_BindRender = bind(self.onRender, self)
	addEventHandler("onClientPreRender", root, self.m_BindRender)

	self.m_BetLabel = GUILabel:new(self.m_Width/2-100, self.m_Height/2-20, 200, 30, "", self):setFont(VRPFont(30*.9)):setAlignX("center"):setAlignY("center"):setVisible(false)

	self.m_BlinkRate = 5000
	self.m_BlinkTimer = setTimer(function() self.m_BlinkRate = math.random(3000, 5000) end, 5000, 0)

	self.m_ResultLabel = GUILabel:new(self.m_Width/2-300, self.m_Height/2-70, 600, 10, "", self):setFont(VRPFont(36)):setAlignX("center"):setVisible(false)

	self.m_RestartButton = GUIButton:new(self.m_Width/2-300, 506-120, 160, 30, "Nochmal", self):setAlternativeColor(Color.Clear):setBackgroundColor(Color.White):setEnabled(false):setVisible(false)
	self.m_RestartButton.m_AnimatedBar:setColor(Color.Black)
	if not self.m_Spectate then
		self.m_RestartButton.onLeftClick = bind(self.restart, self)
	end

	self.m_EndButton = GUIButton:new(10, 20, 160, 30, "← Ende", self):setAlternativeColor(Color.Clear):setBackgroundColor(Color.White)
	self.m_EndButton.m_AnimatedBar:setColor(Color.Black)
	self.m_EndButton.onLeftClick = bind(self.cancel, self)

	self.m_InfoButton = GUIButton:new(self.m_Width-170, 20, 160, 30, "Hilfe", self):setAlternativeColor(Color.Clear):setBackgroundColor(Color.White)
	self.m_InfoButton.m_AnimatedBar:setColor(Color.Black)
	self.m_InfoButton.onLeftClick = bind(self.info, self)

	self.m_HitButton = GUIButton:new(self.m_Width/2-300, 506-60, 160, 30, "Hit", self):setAlternativeColor(Color.Clear):setBackgroundColor(Color.White)
	self.m_HitButton.m_AnimatedBar:setColor(Color.Black)
	if not self.m_Spectate then
		self.m_HitButton.onLeftClick = bind(self.hit, self)
	end

	self.m_InsuranceButton = GUIButton:new(self.m_Width/2-300, 506-130, 160, 30, "Insurance", self):setAlternativeColor(Color.Clear):setBackgroundColor(Color.White):setEnabled(false):setVisible(false)
	self.m_InsuranceButton.m_AnimatedBar:setColor(Color.Black)
	if not self.m_Spectate then
		self.m_InsuranceButton.onLeftClick = bind(self.insurance, self)
	end

	self.m_InsuranceLabel = GUILabel:new(self.m_Width/2-300, 506-130, 160, 30, "Insurance-Wette aktiv!", self):setFont(VRPFont(20)):setAlignX("center"):setAlignY("center"):setVisible(false)

	self.m_StandButton = GUIButton:new(self.m_Width-260, 506-60, 160, 30, "Stand", self):setAlternativeColor(Color.Clear):setBackgroundColor(Color.White)
	self.m_StandButton.m_AnimatedBar:setColor(Color.Black)
	if not self.m_Spectate then
		self.m_StandButton.onLeftClick = bind(self.stand, self)
	end
	self.m_HitButton:setVisible(false)
	self.m_StandButton:setVisible(false)	


	--self.m_SpectatorBorder = self:createBorder(10, 60, 160, 110, 2, Color.White, self)
	self.m_SpectatorGrid = 	GUIGridList:new(10, 60, 160, 109, self, Color.Clear, Color.White):setBackgroundColor(Color.Clear):setColor(Color.Clear)
	self.m_SpectatorGrid:addColumn("Zuschauer 0", 1)
end

function BlackJack:putCardPlayer(card)
	playSound(self:makeSoundPath("card_draw.ogg"))
	card = ("%s%s"):format(card.Suit, card.Value)
	self.m_Player[#self.m_Player+1] = GUIImage:new(self.m_Width/2-36+(40*#self.m_Player), self.m_Height/2+90, 72, 100, self:makeCardPath(card), self)
end

function BlackJack:putCardDealer(card, hidden)
	if #self.m_Dealer == 0 and (tonumber(card.Value) == 1 or tonumber(card.Value) >= 10) then
		if not self.m_Spectate then
			self.m_InsuranceButton:setEnabled(true)
			self.m_InsuranceButton:setVisible(true)
			self.m_InsuranceEnabled = true
		end
	end
	card = ("%s%s"):format(card.Suit, card.Value)
	self.m_Dealer[#self.m_Dealer+1] = GUIImage:new(self.m_Width/2-36+(40*#self.m_Dealer), self.m_Height/2-190, 72, 100, self:makeCardPath(hidden and "back" or card), self)
	playSound(self:makeSoundPath("card_draw.ogg"))
	if hidden then
		self.m_Dealer[#self.m_Dealer].card = card
	end
end

function BlackJack:Event_DrawCard(bet, dealerCards, playerCards, isInitial, playerValue, dealerValue, initialDealerCard) 
	self.m_RestartButton:setVisible(false)
	self.m_RestartButton:setEnabled(false)
	self.m_InsuranceLabel:setVisible(false)
	self.m_BetLabel:setText(("$%s"):format(convertNumber(bet)))
	self.m_BetLabel:setVisible(true)
	self.m_BetChange:setVisible(false)
	if #dealerCards > 0 then
		self.m_CardTimers[setTimer(function() 
			self:putCardDealer(dealerCards[1]) 
			if not isInitial then
				self.m_DealerValue:setText(("Wert: %s"):format(dealerValue))
				self.m_DealerValueShadow:setText(("Wert: %s"):format(dealerValue))
			end
		end, 500, 1)] = true
		if isInitial then 
			self.m_CardTimers[setTimer(function() 
				self:putCardDealer(dealerCards[2], true) 
				if playerValue < 21 then
					if not self.m_Spectate then
						self.m_HitButton:setVisible(true)
					end
				end
				if not self.m_Spectate then
					self.m_StandButton:setVisible(true)
				end
				self.m_DealerValue:setText(("Wert: %s + ?"):format(tonumber(initialDealerCard)))
				self.m_DealerValueShadow:setText(("Wert: %s + ?"):format(tonumber(initialDealerCard)))
			end, 750, 1)] = true
		end
	end

	if #playerCards > 0 then
		self:putCardPlayer(playerCards[1])
		if isInitial then 
			self.m_CardTimers[setTimer(function() 
				self:putCardPlayer(playerCards[2]) 
				self.m_PlayerValue:setText(("Wert: %s"):format(playerValue))
				self.m_PlayerValueShadow:setText(("Wert: %s"):format(playerValue))
			end, 250, 1)] = true
		else 
			if not self.m_Spectate then
				self.m_HitButton:setVisible(true)
				self.m_StandButton:setVisible(true)	
			end
			self.m_PlayerValue:setText(("Wert: %s"):format(playerValue))
			self.m_PlayerValueShadow:setText(("Wert: %s"):format(playerValue))

			self.m_DealerValue:setText(("Wert: %s"):format(dealerValue))
			self.m_DealerValueShadow:setText(("Wert: %s"):format(dealerValue))
		end
		if playerValue == 21 then 
			self.m_HitButton:setVisible(false)
		end
	end

	if isInitial then 
		self.m_BlockInput = true
		self.m_CardTimers[setTimer(function() self.m_BlockInput = false end, 755, 1)] = true
	else 
		self.m_BlockInput = false
		self.m_CardTimers[setTimer(function() 
			self.m_DealerValue:setText(("Wert: %s"):format(dealerValue)) 
			self.m_DealerValueShadow:setText(("Wert: %s"):format(dealerValue))
		end, 500, 1)] = true
		
	end

	self:revelDealer()
end

function BlackJack:Event_UpdateSpectator(spectators) 
	self.m_SpectatorList = spectators
	self.m_SpectatorGrid:clear()
	local count = 0
	if self.m_SpectatorList then 
		for player, k in pairs(self.m_SpectatorList) do 
			if isValidElement(player, "player") then
				self.m_SpectatorGrid:addItem(player.name)
				count = count + 1
			end
		end
	end
	self.m_SpectatorGrid:setColumnText(1, ("Zuschauer %s"):format(count))
end

function BlackJack:Event_Notify(text, win, instant)
	if not instant then
		setTimer(function() 
			self.m_BlockInput = true 
			if not self.m_Spectate then
				self.m_RestartButton:setVisible(true)
				self.m_RestartButton:setEnabled(true)
			end
			self.m_ResultLabel:setVisible(true) 
			if not self.m_Spectate then
				self.m_BetChange:setVisible(true)
			end
			self.m_BetLabel:setVisible(false):setText("")
			self.m_HitButton:setVisible(false)
			self.m_StandButton:setVisible(false)

			if win then 
				self.m_ResultLabel:setText(("%s"):format(text))
			else
				self.m_ResultLabel:setText(("%s"):format(text))
			end
		end, 750, 1)
	else 
		self.m_BlockInput = true 
		if not self.m_Spectate then
			self.m_RestartButton:setVisible(true)
			self.m_RestartButton:setEnabled(true)
		end
		self.m_ResultLabel:setVisible(true) 
		self.m_ResultLabel:setText(("%s"):format(text))
		self.m_ResultLabel:setText(("%s"):format(text))
		self.m_HitButton:setVisible(false)
		self.m_StandButton:setVisible(false)
		if not self.m_Spectate then
			self.m_BetChange:setVisible(true)
		end
		self.m_BetLabel:setVisible(false):setText("")
	end
end

function BlackJack:Event_Insurance() 
	self.m_InsuranceButton:setVisible(false)
	self.m_InsuranceButton:setEnabled(false)
	if not self.m_Spectate then
		self.m_InsuranceLabel:setVisible(true)
	end
end

function BlackJack:revelDealer() 
	if self.m_Dealer[2] and self.m_Dealer[2].card then 
		playSound(self:makeSoundPath("card_draw.ogg"))
		self.m_Dealer[2]:setImage(self:makeCardPath(self.m_Dealer[2].card))
		self.m_Dealer[2].card = nil
	end
end

function BlackJack:Event_ResetCards() 
	for timer, k in pairs(self.m_CardTimers) do 
		if timer and isTimer(timer) then 
			killTimer(timer)
		end
	end
	for i = 1, #self.m_Dealer do 
		self.m_Dealer[i]:delete()
	end
	for i = 1, #self.m_Player do 
		self.m_Player[i]:delete()
	end

	self.m_Dealer = {}
	self.m_Player = {}

	self.m_PlayerValue:setText(("Wert: %s"):format(0))
	self.m_PlayerValueShadow:setText(("Wert: %s"):format(0))
	self.m_DealerValue:setText(("Wert: %s"):format(0))
	self.m_DealerValueShadow:setText(("Wert: %s"):format(0))
	self.m_BlockInput = false
end

function BlackJack:onRender() 
	if self.m_DealerImage then 
		if getTickCount() % self.m_BlinkRate < 400 then 
			self.m_DealerImage:setImage(self:makeImagePath("dealer_e_close.png"))
		else 
			self.m_DealerImage:setImage(self:makeImagePath("dealer_e_open.png"))
		end
	end
	if not self.m_Specting and self.m_Object and isElement(self.m_Object) then 
		local x,y,z = getElementPosition(self.m_Object)
		local x2, y2, z2 = getElementPosition(localPlayer) 
		if getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 5 then 
			self:cancel()
			ErrorBox:new("Du bist zu weit vom Black-Jack entfernt!")
		end
	end
	if self.m_Shader and self.m_ScreenSource then
		if self.m_ShaderDarkness+.05 <= 1 then 
			self.m_ShaderDarkness = self.m_ShaderDarkness + 0.05 
		end
		if self.m_ShaderRadius+1 <=20 then 
			self.m_ShaderRadius = self.m_ShaderRadius + 1 
		end

		dxUpdateScreenSource(self.m_ScreenSource) 
		dxSetShaderValue(self.m_Shader, "ScreenSource", self.m_ScreenSource)
		dxSetShaderValue(self.m_Shader, "radius", self.m_ShaderRadius)
		dxSetShaderValue(self.m_Shader, "darkness", self.m_ShaderDarkness)
		dxDrawImage(0, 0, screenWidth, screenHeight, self.m_Shader)
	end
end

function BlackJack:hit() 
	if not self.m_BlockInput then
		if self.m_InsuranceEnabled then 
			self.m_InsuranceEnabled = false 
			self.m_InsuranceButton:setVisible(false)
			self.m_InsuranceButton:setEnabled(false)
		end
		triggerServerEvent("BlackJackManager:onHit", localPlayer)
	end
end

function BlackJack:insurance() 
	if not self.m_BlockInput then
		triggerServerEvent("BlackJackManager:onInsurance", localPlayer)
	end
end

function BlackJack:stand() 
	if not self.m_BlockInput then
		if not self.m_Spectate then
			self.m_HitButton:setVisible(true)
			self.m_StandButton:setVisible(true)	
		end
		if self.m_InsuranceEnabled then 
			self.m_InsuranceEnabled = false 
			self.m_InsuranceButton:setVisible(false)
			self.m_InsuranceButton:setEnabled(false)
		end
		triggerServerEvent("BlackJackManager:onStand", localPlayer)
	end
end

function BlackJack:restart() 
	self:Event_ResetCards() 
	self.m_ResultLabel:setText("")
	triggerServerEvent("BlackJackManager:onReset", localPlayer, self.m_Bet)
end

function BlackJack:cancel() 
	triggerServerEvent("BlackJackManager:onCancel", localPlayer, self.m_Spectate)
end

function BlackJack:info() 
	self:setVisible(false)
	if not self.m_Info then 	
		self.m_Info = BlackJackHelp:new(self)
	end
end

function BlackJack:destructor() 
	GUIForm.destructor(self)
	if self.m_BlinkTimer then 
		killTimer(self.m_BlinkTimer)
	end
	removeEventHandler("onClientPreRender", root, self.m_BindRender)
	
	removeEventHandler("BlackJack:draw", localPlayer, self.m_BindDrawCard)
	
	removeEventHandler("BlackJack:reset", localPlayer, self.m_ResetCards)
	
	removeEventHandler("BlackJack:notify", localPlayer, self.m_Notify)

	removeEventHandler("BlackJack:insurance", localPlayer, self.m_Insurance)

	removeEventHandler("BlackJack:updateSpectator", localPlayer, self.m_UpdateSpectator)
	
	for timer, k in pairs(self.m_CardTimers) do 
		if timer and isTimer(timer) then 
			killTimer(timer)
		end
	end
	if self.m_ScreenSource then 
		self.m_ScreenSource:destroy() 
	end
	if self.m_Shader then 
		self.m_Shader:destroy()
	end
end



function BlackJack:createBorder(x, y, width, height, borderwidth, color)
	local borders = {}
	
	borders[1] = GUIRectangle:new(x, y, width, borderwidth, color, self)
	borders[2] = GUIRectangle:new(x, y+height-borderwidth, width, borderwidth, color, self)

	borders[3] = GUIRectangle:new(x, y, borderwidth, height, color, self)
	borders[4] = GUIRectangle:new(x+width-borderwidth, y, borderwidth, height, color, self)
	return borders
end

function BlackJack:makeImagePath(file) 
	return ("%s%s"):format(imagePath, file)
end

function BlackJack:makeCardPath(file) 
	return ("%s%s.png"):format(cardPath, file)
end

function BlackJack:makeSoundPath(file) 
	return ("%s%s"):format(soundPath, file)
end


addEventHandler("BlackJack:start", localPlayer, function(bets, spectate, object) 
	local previous = false
	if BlackJack:isInstantiated() then
		previous = true 
		delete(BlackJack:getSingleton())
	end
	BlackJack:new(bets, spectate, object, previous)
end)

addEventHandler("BlackJack:cancel", localPlayer, function() 
	if BlackJack:isInstantiated() then 
		delete(BlackJack:getSingleton())
	end
end)


addEventHandler("BlackJack:sync", localPlayer, function(dealerHand, playerHand) 
	if BlackJack:isInstantiated() then 
		--BlackJack:getSingleton():sync(dealerHand, playerHand, bet)
	end
end)
