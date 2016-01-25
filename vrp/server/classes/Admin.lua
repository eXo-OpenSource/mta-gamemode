-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Admin.lua
-- *  PURPOSE:     Admin class
-- *
-- ****************************************************************************
Admin = inherit(Singleton)

function Admin:constructor()
  self.m_OnlineAdmins = {}
	
	self.m_RankNames = {
		[1] = "Supporter",
		[2] = "Moderator",
		[3] = "Super-Moderator",
		[4] = "Administrator",
		[5] = "Projektleiter"
	}
	
	addRemoteEvents{"adminSetPlayerFaction"}
	
	addCommandHandler("admins", bind(self.onlineList, self))
	addCommandHandler("a", bind(self.chat, self))
	addCommandHandler("o", bind(self.ochat, self))
	addCommandHandler("adminmenu", bind(self.openAdminMenu, self))
	addEventHandler("adminSetPlayerFaction", root, bind(self.Event_adminSetPlayerFaction, self))
	outputDebugString("Admin loaded")
end

function Admin:destructor()
	removeCommandHandler("admins", bind(self.onlineList, self))
	removeCommandHandler("a", bind(self.chat, self))
	removeCommandHandler("o", bind(self.ochat, self))
end

function Admin:addAdmin(player,rank)
	outputDebugString("Added Admin "..player:getName())
	self.m_OnlineAdmins[player] = rank
end

function Admin:removeAdmin(player)
	self.m_OnlineAdmins[player] = nil
end

function Admin:openAdminMenu( player ) 
	if self.m_OnlineAdmins[player] > 0 then
		triggerClientEvent(player,"showAdminMenu",player)
	end
end

function Admin:chat(player,cmd,...)
	if player:getRank() >= RANK.Supporter then
		local msg = table.concat( {...}, " " )
		local rankName = self.m_RankNames[player:getRank()]
		local text = ("[ %s %s ]: %s"):format(_(rankName, player), player:getName(), msg)
		self:sendMessage(text,255,255,0)
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:sendMessage(msg,r,g,b)
	for key, value in pairs(self.m_OnlineAdmins) do
		outputChatBox(msg, key, r,g,b)
	end
end

function Admin:ochat(player,cmd,...)
	if player:getRank() >= RANK.Supporter then
		local rankName = self.m_RankNames[player:getRank()]
		local msg = table.concat( {...}, " " )
		outputChatBox(("[ %s %s ]: %s"):format(_(rankName, player), player:getName(), msg), root, 50, 200, 255)
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:onlineList(player)
	
		outputChatBox("Folgende Teammitglieder sind derzeit online:",player,50,200,255)
		for key, value in pairs(self.m_OnlineAdmins) do
			outputChatBox(self.m_RankNames[value].." "..key:getName(),player,255,255,255)
		end

end

function Admin:Event_adminSetPlayerFaction(targetPlayer,Id)
	if client:getRank() >= RANK.Supporter then
		local faction = FactionManager:getSingleton():getFromId(Id)
		if faction then
			faction:addPlayer(targetPlayer,6)
			client:sendInfo(_("Du hast den Spieler in die Fraktion "..faction:getName().." gesetzt!", client))
		else
			client:sendError(_("Fraktion nicht gefunden!", client))
		end
	end
end