-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/CasinoWheel.lua
-- *  PURPOSE:     CasinoWheel
-- *
-- ****************************************************************************

CasinoWheel = inherit(Object)
CasinoWheel.Model = 1895
CasinoWheel.TurnTime = 45000 --ms
CasinoWheel.AnglePerField = 360 / 54
CasinoWheel.FieldValue = 
{
	0, 
	2, 
	10, 
	1, 
	2, 
	1, 
	5, 
	1, 
	2, 
	10, 
	1, 
	2, 
	1, 
	5, 
	2, 
	1, 
	20, 
	1, 
	2, 
	5, 
	10, 
	1,
	2, 
	1, 
	5,
	1,
	2,
	1,
	0,
	2,
	1,
	2,
	1,
	2,
	5,
	1,
	2,
	1,
	5,
	1,
	20,
	1,
	10,
	1,
	2,
	1,
	5,
	1,
	2,
	1,
	5,
	1,
	2,
	1,
}
CasinoWheel.Fields = #CasinoWheel.FieldValue
CasinoWheel.MaximumBet = 50000
function CasinoWheel:constructor(pos, rot, maximumBet, spinTime, id) 
	
	self.m_BankAccountServer = BankServer.get("gameplay.casinowheel")
	self.m_MaximumBet = maximumBet or CasinoWheel.MaximumBet
	self.m_SpinTime = spinTime or CasinoWheel.TurnTime
	self.m_Position = pos
	self.m_Id = id or 0
	self.m_Object = createObject(self.Model, Vector3(pos.x, pos.y, pos.z+0.5), rot)
	self.m_Object:setDoubleSided(true)

	self.m_Clicker = createObject(1898, Vector3(pos.x, pos.y, pos.z+1.55), rot)
	self.m_ClickAlternator = false
	self.m_Ped = NPC:new(142, pos.x, pos.y, pos.z, rot.z)
	self.m_Ped.m_Obj = self.m_Object
	self.m_Ped:setPosition((self.m_Ped.position + self.m_Ped.matrix:getForward()*-0.44))
	self.m_Ped:setPosition(self.m_Ped.position + self.m_Ped.matrix:getRight()*0.2)
	self.m_Ped:setRotation(Vector3(rot.x, rot.y, rot.z+(180+25)))
	self.m_Ped:setFrozen(true)
	self.m_Ped:setImmortal(true) 
	
	self.m_Stand = createObject(1897, Vector3(pos.x, pos.y, pos.z+0.2), rot)
	self.m_Stand:setPosition( self.m_Stand.position + self.m_Stand.matrix:getForward()*0.08)
	self.m_Stand:setScale(1, 1, 1.2)
	self.m_Object:setData("CasinoWheel:ped", self.m_Ped, true)
	self.m_Ped.pone = createObject(1238, self.m_Ped:getPosition())
	self.m_Ped:setData("CasinoWheel:cone", self.m_Ped.pone, true)
	self.m_Ped.pone:setScale(0.6, 0.65, 0.6)
	exports.bone_attach:attachElementToBone(self.m_Ped.pone, self.m_Ped, 1, 0.02, 0.05, 0.29, 3, 0, 90)

	self.m_Players = {}
	self.m_Bets = {}
	self.m_Step = 0

	self:pulse()
	self.m_PulseTime = setTimer(bind(self.pulse, self), self.m_SpinTime / 6 , 0)
	
	
	self.m_OriginalRotation = self.m_Object.rotation
end

function CasinoWheel:spin()
	self.m_Ped:setAnimation("casino", "wof", 1000, false)
	setTimer(function() self.m_Ped:setAnimation("cop_ambient", "coplook_think", 1000, false) end, 1100, 1)
	self.m_WinValue = false
	self.m_Spin = true
	for player, k in pairs(self.m_Players) do 
		player:triggerEvent("CasinoWheel:lockBet")
	end
	setTimer(function()

		local value = math.random(1, #CasinoWheel.FieldValue)
		local spin = (#CasinoWheel.FieldValue*math.random(3, 8))
		local targetRot = CasinoWheel.AnglePerField * (value + spin)
		local leftRight = math.random(-2, 2)
		local spinTime = math.random(8000, 10000)
		self.m_LastSpinTime = spinTime
		leftRight = leftRight/10*CasinoWheel.AnglePerField
		self.m_Object:setRotation(self.m_OriginalRotation.x, 0, self.m_OriginalRotation.z)
		self.m_Object:move(spinTime, self.m_Object.position.x, self.m_Object.position.y, self.m_Object.position.z, 0, targetRot+leftRight, 0, "OutQuad")

		for k, p in pairs(getElementsByType("player")) do 
			p:triggerEvent("CasinoWheel:spinWheel", self:getObject(), self.m_Clicker, spinTime)
		end
		setTimer(function() 
				self.m_WinValue = CasinoWheel.FieldValue[value]
				self:pay()
				self.m_Spin = false
		end, spinTime, 1)
	end, 800, 1)
end

function CasinoWheel:stopPlayer(player)
	if self.m_Players[player] then 
		if self.m_Bets[player] then 
			self:redrawBet(player, true)
			self.m_Players[player] = nil	
		end
	end
end

function CasinoWheel:submitBet(player, bet)
	if self.m_Spin then return player:sendError(_("Warte bis der aktuelle Dreh beendet ist!", player)) end
	if not self.m_Bets[player] then
		self.m_Bets[player] = bet
		local amount = self:calcBet(player)
		if amount > self.m_MaximumBet then 
			self.m_Bets[player] = nil
			return player:sendError(_("Du kannst an diesem Rad maximal $%s einsetzen!", player, convertNumber(self.m_MaximumBet)))
		end
		if player:transferMoney(self.m_BankAccountServer, amount, "Glücksrad-Einsatz", "Gameplay", "Glücksrad-WOF", {silent = false}) then
			self.m_Bets[player] = bet
			player:triggerEvent("CasinoWheel:acceptBet")
		else 
			self.m_Bets[player] = nil
			player:sendError(_("Du hast nicht so viel Geld!", player))
		end
	else 
		player:sendError(_("Ziehe erst deinen Einsatz zurück!", player))
	end
end

function CasinoWheel:pay() 
	for player, bet in pairs(self.m_Bets) do 
		local win = self:calcBetWinOnField(player, tostring(self.m_WinValue))
		if win > 0 then 
			if self.m_BankAccountServer:transferMoney(player, win, "Glücksrad-Gewinn", "Gameplay", "Glücksrad-WOF", {silent = false}) then
				player:sendInfo(_("Glückwunsch! Du hast gewonnen!", player))
			end
		end
		self.m_Bets[player] = nil
	end
	for player, k in pairs(self.m_Players) do 
		player:triggerEvent("CasinoWheel:reset", self.m_WinValue, self.m_SpinTime - self.m_LastSpinTime)
	end
end

function CasinoWheel:redrawBet(player, isStop) 
	if self.m_Players[player] then 
		local betAmount = self:calcBet(player)
		if self.m_BankAccountServer:transferMoney(player, betAmount, "Glücksrad-Rückerstattung", "Gameplay", "Glücksrad-WOF", {silent = true}) then
			self.m_Bets[player] = nil
			if not isStop then
				player:triggerEvent("CasinoWheel:reset")
			end
		end
	end
end

function CasinoWheel:getNumber() 
	local rot = self:getObject():getRotation().y 
	local count = 0
	for i = 1, 54 do 
		if count * CasinoWheel.AnglePerField < rot then 
			count = count + 1
		
		else 
			break
		end
	end
	return count
end

function CasinoWheel:pulse() 
	self.m_Step = self.m_Step + 1
	local timePerStep = self.m_SpinTime / 6
	self.m_Object:setData("CasinoWheel:WheelInfo", ("Nächster Dreh in %s Sekunden!"):format(math.floor((self.m_SpinTime - timePerStep*self.m_Step)/1000)), true)
	if self.m_Step == 6 then 
		self.m_Object:setData("CasinoWheel:WheelInfo", ("Nächster Dreh in %s Sekunden!"):format(math.floor(self.m_SpinTime/1000)), true)
		self.m_Step = 0
		self:spin()
	end
end

function CasinoWheel:getObject() 
	return self.m_Object
end

function CasinoWheel:destructor() 
	if self.m_Object and isValidElement(self.m_Object, "object") then 
		self.m_Object:destroy()
	end
end


function CasinoWheel:calcBetWinOnField(player, field)
    if self.m_Bets[player] then
		local total = 0
    	if self.m_Bets[player][field] then
    	    for color, amount in pairs(self.m_Bets[player][field]) do
    	        total = total +  ROULETTE_TOKENS[color] * amount + (ROULETTE_TOKENS[color] * amount * tonumber(field))
    	    end
    	end
    	return total
	end
end

function CasinoWheel:calcBetOnField(player, field)
    if self.m_Bets[player] then
		local total = 0
    	if self.m_Bets[player][field] then
    	    for color, amount in pairs(self.m_Bets[player][field]) do
    	        total = total + ROULETTE_TOKENS[color]*amount
    	    end
    	end
	    return total
	end
end

function CasinoWheel:calcBet(player)
	if self.m_Bets[player] then
		local total = 0
    	for field, fieldElement in pairs(self.m_Bets[player]) do
    	    total = total + self:calcBetOnField(player, field)
    	end
    	return total
	end
end

