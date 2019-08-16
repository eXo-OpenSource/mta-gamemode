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

addRemoteEvents{"BlackJack:start", "BlackJack:end", "BlackJack:draw", "BlackJack:reset", "BlackJack:notify"}

function BlackJack:constructor() 
	GUIForm.constructor(self, screenWidth/2 - 800/2, screenHeight/2-506/2, 800, 506, false)
	


	self.m_Dealer = {}
	self.m_Player = {}
	self.m_CardTimers = {}
	self:setup()
	
	self.m_BindDrawCard = bind(self.Event_DrawCard, self)
	addEventHandler("BlackJack:draw", localPlayer, self.m_BindDrawCard)

	self.m_ResetCards = bind(self.Event_ResetCards, self)
	addEventHandler("BlackJack:reset", localPlayer, self.m_ResetCards)

	self.m_Notify = bind(self.Event_Notify, self)
	addEventHandler("BlackJack:notify", localPlayer, self.m_Notify)

	triggerServerEvent("BlackJackManager:onReady", localPlayer)

	self.m_BlockInput = true

end

function BlackJack:setup() 
  	--self.m_Table = GUIImageSection:new(0, 0, self.m_Width, self.m_Height, 0, 0, 1000, 1000, "files/images/BlackJack/table.jpg", self)
	GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(51,120,37), self)
	GUIRectangle:new(0, 0, 10, self.m_Height, Color.Wood, self)
	GUIRectangle:new(self.m_Width-10, 0, 10, self.m_Height, Color.Wood, self)
	GUIRectangle:new(0, 0, self.m_Width, 10, Color.Wood, self)
	GUIRectangle:new(0, self.m_Height-10, self.m_Width, 10, Color.Wood, self)

	self.m_DealerImage = GUIImage:new(self.m_Width/2-240, self.m_Height/2-240, 160, 160, self:makeImagePath("dealer_e_open.png"), self)
	GUIRectangle:new(self.m_Width/2-300, self.m_Height/2-80, 600, 3, Color.White, self)


	GUILabel:new(self.m_Width/2-36, self.m_Height/2-210, 72, 10, "Dealer", self):setFont(VRPFont(20)):setAlignX("center")
	self:createBorder(self.m_Width/2-36, self.m_Height/2-190, 72, 100, 2, Color.White, self)
	self.m_DealerValue = GUILabel:new(self.m_Width/2+90, self.m_Height/2-230, 120, 40, "Wert: 0", self):setFont(VRPFont(28)):setAlignX("center")


	GUILabel:new(self.m_Width/2-36, self.m_Height/2+70, 72, 10, "Du", self):setFont(VRPFont(20)):setAlignX("center")
	self:createBorder(self.m_Width/2-36, self.m_Height/2+90, 72, 100, 2, Color.White, self)
	self.m_PlayerValue = GUILabel:new(self.m_Width/2+90, self.m_Height/2+50, 120, 40, "Wert: 0", self):setFont(VRPFont(28)):setAlignX("center")

	


	self.m_BindRender = bind(self.onRender, self)
	addEventHandler("onClientRender", root, self.m_BindRender)


	self.m_BlinkRate = 5000
	self.m_BlinkTimer = setTimer(function() self.m_BlinkRate = math.random(3000, 5000) end, 5000, 0)

	self.m_ResultLabel = GUILabel:new(self.m_Width/2-250, self.m_Height/2-70, 500, 10, "", self):setFont(VRPFont(36)):setAlignX("center"):setVisible(false)

	self.m_RestartButton = GUIButton:new(self.m_Width/2-300, 506-120, 160, 30, "Nochmal", self):setAlternativeColor(tocolor(51,120,37)):setBackgroundColor(Color.White):setEnabled(false):setVisible(false)
	self.m_RestartButton.m_AnimatedBar:setColor(Color.Black)
	self.m_RestartButton.onLeftClick = bind(self.restart, self)

	self.m_EndButton = GUIButton:new(10, 10, 160, 30, "Ende", self):setAlternativeColor(tocolor(51,120,37)):setBackgroundColor(Color.White)
	self.m_EndButton.m_AnimatedBar:setColor(Color.Black)
	self.m_EndButton.onLeftClick = bind(self.cancel, self)

	self.m_HitButton = GUIButton:new(self.m_Width/2-300, 506-60, 160, 30, "Hit", self):setAlternativeColor(tocolor(51,120,37)):setBackgroundColor(Color.White)
	self.m_HitButton.m_AnimatedBar:setColor(Color.Black)
	self.m_HitButton.onLeftClick = bind(self.hit, self)

	self.m_StandButton = GUIButton:new(self.m_Width-260, 506-60, 160, 30, "Stand", self):setAlternativeColor(tocolor(51,120,37)):setBackgroundColor(Color.White)
	self.m_StandButton.m_AnimatedBar:setColor(Color.Black)
	self.m_StandButton.onLeftClick = bind(self.stand, self)
	
	self.m_HitButton:setVisible(false)
	self.m_StandButton:setVisible(false)	
end


function BlackJack:putCardPlayer(card)
	card = ("%s%s"):format(card.Suit, card.Value)
	self.m_Player[#self.m_Player+1] = GUIImage:new(self.m_Width/2-36+(40*#self.m_Player), self.m_Height/2+90, 72, 100, self:makeCardPath(card), self)
end


function BlackJack:putCardDealer(card, hidden)
	card = ("%s%s"):format(card.Suit, card.Value)
	self.m_Dealer[#self.m_Dealer+1] = GUIImage:new(self.m_Width/2-36+(40*#self.m_Dealer), self.m_Height/2-190, 72, 100, self:makeCardPath(hidden and "back" or card), self)
	if hidden then
		self.m_Dealer[#self.m_Dealer].card = card
	end
end

function BlackJack:Event_DrawCard(dealerCards, playerCards, isInitial, playerValue, dealerValue, initialDealerCard) 
	self.m_RestartButton:setVisible(false)
	self.m_RestartButton:setEnabled(false)

	if #dealerCards > 0 then
		self.m_CardTimers[setTimer(function() 
			self:putCardDealer(dealerCards[1]) 
			if not isInitial then
				self.m_DealerValue:setText(("Wert: %s"):format(dealerValue))
			end
		end, 500, 1)] = true
		if isInitial then 
			self.m_CardTimers[setTimer(function() 
				self:putCardDealer(dealerCards[2], true) 
				if playerValue < 21 then
					self.m_HitButton:setVisible(true)
				end
				self.m_StandButton:setVisible(true)
				self.m_DealerValue:setText(("Wert: %s + ?"):format(tonumber(initialDealerCard)))
	
			end, 750, 1)] = true
		end
	end

	if #playerCards > 0 then
		self:putCardPlayer(playerCards[1])
		if isInitial then 
			self.m_CardTimers[setTimer(function() 
				self:putCardPlayer(playerCards[2]) 
				self.m_PlayerValue:setText(("Wert: %s"):format(playerValue))
	
			end, 250, 1)] = true
		else 
			self.m_HitButton:setVisible(true)
			self.m_StandButton:setVisible(true)	
			self.m_PlayerValue:setText(("Wert: %s"):format(playerValue))
			self.m_DealerValue:setText(("Wert: %s"):format(dealerValue))
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
		self.m_CardTimers[setTimer(function() self.m_DealerValue:setText(("Wert: %s"):format(dealerValue)) end, 500, 1)] = true
		
	end

	self:revelDealer()
end

function BlackJack:Event_Notify(text, win, instant)
	if not instant then
		setTimer(function() 
			self.m_BlockInput = true 
			self.m_RestartButton:setVisible(true)
			self.m_RestartButton:setEnabled(true)
			self.m_ResultLabel:setVisible(true) 

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
		self.m_RestartButton:setVisible(true)
		self.m_RestartButton:setEnabled(true)
		self.m_ResultLabel:setVisible(true) 
		self.m_ResultLabel:setText(("%s"):format(text))
		self.m_ResultLabel:setText(("%s"):format(text))
		self.m_HitButton:setVisible(false)
		self.m_StandButton:setVisible(false)
	end
end

function BlackJack:revelDealer() 
	if self.m_Dealer[2] and self.m_Dealer[2].card then 
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
	self.m_DealerValue:setText(("Wert: %s"):format(0))
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
end



function BlackJack:createBorder(x, y, width, height, borderwidth, color)
	local borders = {}
	
	GUIRectangle:new(x, y, width, borderwidth, color, self)
	GUIRectangle:new(x, y+height-borderwidth, width, borderwidth, color, self)

	GUIRectangle:new(x, y, borderwidth, height, color, self)
	GUIRectangle:new(x+width-borderwidth, y, borderwidth, height, color, self)
end

function BlackJack:makeImagePath(file) 
	return ("%s%s"):format(imagePath, file)
end

function BlackJack:makeCardPath(file) 
	return ("%s%s.png"):format(cardPath, file)
end

function BlackJack:hit() 
	if not self.m_BlockInput then
		triggerServerEvent("BlackJackManager:onHit", localPlayer)
	end
end

function BlackJack:stand() 
	if not self.m_BlockInput then
		self.m_HitButton:setVisible(true)
		self.m_StandButton:setVisible(true)	
		triggerServerEvent("BlackJackManager:onStand", localPlayer)
		
	end
end

function BlackJack:restart() 
	self:Event_ResetCards() 
	self.m_ResultLabel:setText("")
	triggerServerEvent("BlackJackManager:onReset", localPlayer)
end

function BlackJack:cancel() 
	triggerServerEvent("BlackJackManager:onCancel", localPlayer)
end


function BlackJack:destructor() 
	if self.m_BlinkTimer then 
		killTimer(self.m_BlinkTimer)
	end
	removeEventHandler("onClientRender", root, self.m_BindRender)
	removeEventHandler("BlackJack:draw", root, self.m_BindDrawCard)
	for timer, k in pairs(self.m_CardTimers) do 
		if timer and isTimer(timer) then 
			killTimer(timer)
		end
	end
end

addEventHandler("BlackJack:start", root, function() 
	if BlackJack:isInstantiated() then 
		delete(BlackJack:getSingleton())
	end
	BlackJack:new()
end)

addEventHandler("BlackJack:cancel", root, function() 
	if BlackJack:isInstantiated() then 
		delete(BlackJack:getSingleton())
	end
end)