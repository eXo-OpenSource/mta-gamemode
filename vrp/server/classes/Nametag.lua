Nametag = inherit(Singleton)

addEvent("requestNametagBuffs", true)

function Nametag:constructor()
	self.m_PlayerBuffs = {}
	addEventHandler("requestNametagBuffs", root, bind(self.sendPlayerBuffs,self))
end

function Nametag:addBuff(player,buff,amount)
	if not self.m_PlayerBuffs[getPlayerName(player)] then
		self.m_PlayerBuffs[getPlayerName(player)] = {}
	end
	if not self:stackBuffs(player,buff,amount) then
		table.insert(self.m_PlayerBuffs[getPlayerName(player)], { BUFF = buff, AMOUNT = amount } )
	end
	triggerClientEvent(root,"reciveNametagBuffs",root,self.m_PlayerBuffs)
end

function Nametag:stackBuffs(player,buff,amount)
	for key, value in pairs(self.m_PlayerBuffs[getPlayerName(player)]) do
		if value.BUFF == buff then
			value.AMOUNT = value.AMOUNT + amount
			return true
		end
	end
	return false
end

function Nametag:removeBuff(player,buff)
	if not self.m_PlayerBuffs[getPlayerName(player)] then
		self.m_PlayerBuffs[getPlayerName(player)] = {}
		return
	end
	for key, value in pairs(self.m_PlayerBuffs[getPlayerName(player)]) do
		if value.BUFF == buff then
			table.remove(self.m_PlayerBuffs[getPlayerName(player)],key)
		end
	end
	triggerClientEvent(root,"reciveNametagBuffs",root,self.m_PlayerBuffs)
end

function Nametag:sendPlayerBuffs(player)
	if player then
		client = player
	end
	triggerClientEvent(client,"reciveNametagBuffs",client,self.m_PlayerBuffs)
end
