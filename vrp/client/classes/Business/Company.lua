-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Business/Company.lua
-- *  PURPOSE:     Base Company Super Class
-- *
-- ****************************************************************************

Company = inherit(Object)

-- implement by children
Company.constructor = pure_virtual
Company.destructor = pure_virtual
Company.start = pure_virtual -- Todo: don't know for what, ask Jusonex :P
Company.stop = pure_virtual -- Same here.

function Company:virtual_constructor(name, desc, position)
  outputDebug("Company.virtual_constructor")

  self.m_Name = name
  self.m_Description = desc
  self.m_Position = position
  self.m_Pickup = Pickup.create(self.m_Position, 3, 1239)
  self.m_Blip = Blip:new(("%s.png"):format(name), self.m_Position.x, self.m_Position.y)

  addEventHandler("onClientPickupHit", self.m_Pickup, bind(Company.onInfoHit, self))
end

function Company:virtual_destructor()
  if self.m_Blip then
    delete(self.m_Blip)
  end
  destroyElement(self.m_Pickup)

  CompanyManager:getSingleton():removeRef(self)
end

function Company:receiveSyncInfo(players, money)
  self.m_Players = players
  self.m_Money = money
end

function Company:setId(Id)
  self.m_Id = Id
end

function Company:getId()
  return self.m_Id
end

function Company:getName()
  return self.m_Name
end

function Company:getMoney()
	return self.m_Money
end

function Company:getDescription ()
  return self.m_Description
end

function Company:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player then
			players[#players + 1] = player
		end
	end
	return players
end

function Company:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Company:onInfoHit(p)
  --CompanyInfoGUI:new(self.m_Id) -- Todo: Information GUI

  p:sendMessage("-- Testing the availability of the important data --")
  p:sendMessage("Company Id: "..self:getId())
  p:sendMessage("Company Name: "..self:getName())
  p:sendMessage("Company Description: "..self:getDescription())
  p:sendMessage("Company Bank: $"..self:getMoney())
  p:sendMessage("Company Position: "..tostring(self.m_Position))
  p:sendMessage("Company Membercount: "..table.size(self.m_Players))
end
