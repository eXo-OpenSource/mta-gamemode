-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIPaydayBox.lua
-- *  PURPOSE:     Payday box class
-- *
-- ****************************************************************************
GUIPaydayBox = inherit(GUIRectangle)
inherit(GUIPaydayBox)

function GUIPaydayBox:constructor(texts)
	self.m_AnimTime = 1000
	self.m_MoneyFadeTime = 5000
	localPlayer.m_PaydayShowing = true
	if core:get("HUD", "paydayBox_relative", true) then
		self.m_W = screenWidth * 0.2
		self.m_H = self.m_W
		self.m_HeaderHeight = screenWidth * 0.027
		self.m_MoneySize = screenWidth * 0.01
	else
		self.m_W = 384
		self.m_H = self.m_W
		self.m_HeaderHeight = 52
		self.m_MoneySize = 20
	end
	
	
	GUIRectangle.constructor(self, screenWidth/2 - self.m_W/2, -self.m_H, self.m_W, self.m_H)
	self.m_BaseHeight = self.m_HeaderHeight/1.5 + self.m_HeaderHeight/2
	self:setColor(Color.Grey)

	self.m_PaydayTexts = texts
	self:createUI()

	playSound("files/audio/Payday.mp3")

	self.m_Close = bind(self.endPayday, self)

	setTimer(function()
		bindKey("space", "down", self.m_Close)
	end,self.m_AnimTime,1)

	self.m_MoneyRenderEvent = bind(GUIPaydayBox.renderMoney, self)
	addEventHandler("onClientRender", root, self.m_MoneyRenderEvent)

	self.m_Animation = Animation.Move:new(self, self.m_AnimTime, self.m_AbsoluteX, self.m_HeaderHeight, "OutQuad")

	if PublicTransportTaxoMeterGUI:isInstantiated() then
		PublicTransportTaxoMeterGUI:getSingleton():hide()
	end
end

function GUIPaydayBox:endPayday()
	unbindKey("space", "down", self.m_Close)
	localPlayer.m_PaydayShowing = false
	self.m_Animation = Animation.Move:new(self, self.m_AnimTime, self.m_AbsoluteX, -self.m_BaseHeight, "InQuad")
	setTimer(function() delete(self) end, self.m_AnimTime * 1.5, 1)

	if PublicTransportTaxoMeterGUI:isInstantiated() then
		PublicTransportTaxoMeterGUI:getSingleton():show()
	end
end

function GUIPaydayBox:createUI()
	--header
	GUIImage:new(self.m_W/3, -self.m_HeaderHeight/2, self.m_W/3, self.m_HeaderHeight, "files/images/LogoNoFont.png", self)
	GUILabel:new(self.m_W/3, self.m_HeaderHeight/3, self.m_W/3, self.m_HeaderHeight/1.5, _"Zahltag", self):setAlignX("center")
	GUILabel:new(0, self.m_HeaderHeight*0.1, self.m_W - self.m_HeaderHeight*0.1, self.m_HeaderHeight/3, _"Leertaste zum Ausblenden", self):setAlignX("right"):setColor(Color.LightGrey)
	GUILabel:new(self.m_HeaderHeight*0.1, self.m_HeaderHeight/1.5, self.m_W, self.m_HeaderHeight/2, _"Einkommen", self):setAlignX("left")
	GUILabel:new(0, self.m_HeaderHeight/1.5, self.m_W - self.m_HeaderHeight*0.1, self.m_HeaderHeight/2, _"Ausgaben", self):setAlignX("right")
	local i_inc = 0
	local i_out = 0
	local margin = self.m_HeaderHeight*0.1
	local money_margin = self.m_HeaderHeight

	--create income and outgoing list
	if self.m_PaydayTexts["income"] then
		for _, value in ipairs(self.m_PaydayTexts["income"]) do
			GUILabel:new(margin, self.m_BaseHeight + self.m_HeaderHeight/2.5*i_inc, self.m_W, self.m_HeaderHeight/2.5, value[2].."$", self):setAlignX("left")
			GUILabel:new(money_margin + margin, self.m_BaseHeight + self.m_HeaderHeight/2.5*i_inc, self.m_W, self.m_HeaderHeight/2.5, value[1], self):setAlignX("left")
			i_inc = i_inc + 1
		end
	end
	if self.m_PaydayTexts["outgoing"] then
		for _, value in ipairs(self.m_PaydayTexts["outgoing"]) do
			GUILabel:new(0, self.m_BaseHeight + self.m_HeaderHeight/2.5*i_out, self.m_W - margin - money_margin, self.m_HeaderHeight/2.5, value[1], self):setAlignX("right")
			GUILabel:new(0, self.m_BaseHeight + self.m_HeaderHeight/2.5*i_out, self.m_W - margin, self.m_HeaderHeight/2.5, value[2].."$", self):setAlignX("right")
			i_out = i_out + 1
		end
	end
	self.m_BaseHeight = self.m_BaseHeight + math.max(i_inc, i_out) * self.m_HeaderHeight/2.5
	
	--subtotal
	GUIRectangle:new(margin, self.m_BaseHeight, self.m_W - margin*2, 2, Color.LightBlue, self)
	self.m_BaseHeight = self.m_BaseHeight + 4
	GUILabel:new(margin, self.m_BaseHeight, self.m_W, self.m_HeaderHeight/2, self.m_PaydayTexts["totalIncome"][1][2].."$", self):setAlignX("left")
	GUILabel:new(0, self.m_BaseHeight, self.m_W - margin, self.m_HeaderHeight/2, self.m_PaydayTexts["totalOutgoing"][1][2].."$", self):setAlignX("right")
	
	--total
	self.m_BaseHeight = self.m_BaseHeight + self.m_HeaderHeight/2
	GUILabel:new(margin, self.m_BaseHeight, self.m_W - margin*2, self.m_HeaderHeight/1.5, ("%s: %s$"):format(self.m_PaydayTexts["total"][1][1], self.m_PaydayTexts["total"][1][2]), self)
		:setAlignX("center")
	self.m_BaseHeight = self.m_BaseHeight + self.m_HeaderHeight/1.5
	
	--infos
	if self.m_PaydayTexts["info"] then
		GUIRectangle:new(margin, self.m_BaseHeight, self.m_W - margin*2, 2, Color.LightBlue, self)
		self.m_BaseHeight = self.m_BaseHeight + 4
		GUILabel:new(margin, self.m_BaseHeight, self.m_W, self.m_HeaderHeight/2, _"weitere Informationen", self):setAlignX("left")
		self.m_BaseHeight = self.m_BaseHeight + self.m_HeaderHeight/2
		for _, text in pairs(self.m_PaydayTexts["info"]) do
			GUILabel:new(margin, self.m_BaseHeight, self.m_W, self.m_HeaderHeight/2.5, text[1], self)
			self.m_BaseHeight = self.m_BaseHeight + self.m_HeaderHeight/2.5
		end
	end

	self:setSize(self.m_Width, self.m_BaseHeight)
	self:setPosition(screenWidth/2 - self.m_W/2, -self.m_BaseHeight)

	--spawn money 
	self.m_FloatingMoneyMap = {}
	self.m_MoneySpawnStart = getTickCount()
	for i = 1, math.abs(self.m_PaydayTexts["total"][1][2]) / 100 do
		table.insert(self.m_FloatingMoneyMap, {screenWidth/2 + math.random(-self.m_Width/2, self.m_Width/2), math.random(-self.m_MoneySize, 0), math.random(self.m_HeaderHeight*2, self.m_HeaderHeight*4)})
	end
end


function GUIPaydayBox:renderMoney() -- draw method hook
	if self.m_FloatingMoneyMap then
		local time = getTickCount()
		if time - self.m_MoneySpawnStart > self.m_MoneyFadeTime then
			removeEventHandler("onClientRender", root, self.m_MoneyRenderEvent)
		end
		for i, v in pairs(self.m_FloatingMoneyMap) do
			local size_multiplicator =  (v[3] / (self.m_HeaderHeight * 3)) -- range: 2/3 (small bill) to 4/3 (large bill)
			local size = size_multiplicator * self.m_MoneySize -- adapt money size to animation speed
			local swingAspect = math.sin((time + i * 100)/500 * size_multiplicator)
			local x, y = v[1] + swingAspect * size, -size + v[2] + v[3] * (time - self.m_MoneySpawnStart) / self.m_MoneyFadeTime
			if self.m_PaydayTexts["total"][1][2] > 0 then
				dxDrawImage(v[1] + swingAspect * size, -size + v[2] + v[3] * (time - self.m_MoneySpawnStart) / self.m_MoneyFadeTime, 
					size, size, "files/images/HUD/payday_money.png", swingAspect * -(30*size_multiplicator), 0, 0, 
					tocolor(20, 200, 40, 255 - 255 * (time - self.m_MoneySpawnStart) / self.m_MoneyFadeTime))
			else
				dxDrawText("-", x, y, x, y, tocolor(200, 20, 40, 255 - 255 * (time - self.m_MoneySpawnStart) / self.m_MoneyFadeTime), size/10,
					"default-bold", "center", "center", false, false, false, false, true, swingAspect * -(30*size_multiplicator))
			end
		end
	end
end

addEvent("paydayBox", true)
addEventHandler("paydayBox", root,function(...)	GUIPaydayBox:new(...) end)
