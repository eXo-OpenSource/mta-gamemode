-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
inherit(DatabasePlayer, Player)
registerElementClass("player", Player)

addEvent("introFinished", true)
addEventHandler("introFinished", root, function()
	client.m_TutorialStage = 3 -- todo: character creation and tutorial mission
	client:spawn() 
end)

function Player:constructor()		
	setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	setElementFrozen(self, true)
end

function Player:destructor()
	if self.m_JobVehicle and isElement(self.m_JobVehicle) then
		destroyElement(self.m_JobVehicle)
	end
	
	self:save()
	
	-- Unload stuff
	if self.m_Inventory then
		self.m_Inventory:unload()
	end
end

function Player:connect()
	if not Ban.checkBan(self) then return end
end

function Player:join()
end

function Player:sendNews()
	self:triggerEvent("ingamenews", Forum:getSingleton():getNews())
end

function Player:triggerEvent(ev, ...)
	triggerClientEvent(self, ev, self, ...)
end

function Player:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), self, r, g, b, true)
end

function Player:startNavigationTo(x, y, z)
	self:triggerEvent("navigationStart", x, y, z)
end

function Player:stopNavigation()
	self:triggerEvent("navigationStop")
end

function Player:loadCharacter()
	DatabasePlayer.Map[self.m_Id] = self
	self:loadCharacterInfo()
	
	-- Send infos to client
	local info = {
		Rank = self:getRank();
	}
	self:triggerEvent("retrieveInfo", info)
	
	-- Add binds
	bindKey(self, "u", "down", "chatbox", "Group")
	
	-- Add command and event handler
	addCommandHandler("Group", Player.staticGroupChatHandler)
end

function Player:createCharacter()
	sql:queryExec("INSERT INTO ??_character(Id) VALUES(?);", sql:getPrefix(), self.m_Id)
	
	self.m_Inventory = Inventory.create()
end

function Player:loadCharacterInfo()
	self:load()
	Blip.sendAllToClient()
end

function Player:save()
	if not self.m_Account or self:isGuest() then	
		return 
	end
	local x, y, z = getElementPosition(self)
	local interior = getElementInterior(self)
	local weapons = ""
	for i = 0, 12 do
		if i == 0 then weapons = getPedWeapon(self, i).."|"..getPedTotalAmmo(self, i)
		else weapons = weapons.."|"..getPedWeapon(self, i).."|"..getPedTotalAmmo(self, i) end
	end
	
	sql:queryExec("UPDATE ??_character SET PosX = ?, PosY = ?, PosZ = ?, Interior = ?, Skin = ?, Weapons = ?, InventoryId = ? WHERE Id = ?;", sql:getPrefix(), x, y, z, interior, getElementModel(self), weapons, self.m_Inventory:getId(), self.m_Id)

	DatabasePlayer.save(self)
end

function Player:spawn()
	spawnPlayer(self, self.m_SavedPosition.X, self.m_SavedPosition.Y, self.m_SavedPosition.Z, 0, self.m_Skin, self.m_SavedInterior, 0)
	setElementFrozen(self, false)
	setElementDimension(self, 0)
	setCameraTarget(self, self)
	fadeCamera(self, true)
end

function Player:respawnAfterDeath()
	spawnPlayer(self, 2028--[[+math.random(-4, 4)--]], -1405--[[+math.random(-2, 2)]], 18)
end

-- Message Boxes
function Player:sendError(text, ...) 	self:triggerEvent("errorBox", text:format(...)) 	end
function Player:sendWarning(text, ...)	self:triggerEvent("warningBox", text:format(...)) 	end
function Player:sendInfo(text, ...)		self:triggerEvent("infoBox", text:format(...))		end
function Player:sendSuccess(text, ...)	self:triggerEvent("successBox", text:format(...))	end
function Player:sendShortMessage(text, ...) self:triggerEvent("shortMessageBox", text:format(...))	end
function Player:isActive() return true end

function Player:setPhonePartner(partner) self.m_PhonePartner = partner end

function Player.staticGroupChatHandler(self, command, ...)
	if self.m_Group then
		self.m_Group:sendMessage(("[GROUP] %s: %s"):format(getPlayerName(self), table.concat({...}, " ")))
	end
end

function Player:reportCrime(crimeType)
	JobPolice:getSingleton():reportCrime(self, crimeType)
end
