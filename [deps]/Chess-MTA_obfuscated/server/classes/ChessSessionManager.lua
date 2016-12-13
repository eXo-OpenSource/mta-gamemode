ChessSessionManager = inherit(Singleton)

function ChessSessionManager:constructor()
	self.m_Map = {	}
	addRemoteEvents{"onServerGetChessMove"}
	addEventHandler("onServerGetChessMove",root, bind(ChessSessionManager.Event_GetChessMove,self))
end

function ChessSessionManager:destructor()

end

function ChessSessionManager:Event_newGame( player1, player2)
	if not self:getPlayerGame( player1 ) and not self:getPlayerGame( player2 ) then 
		outputChatBox("Spiel ist noch in Entwicklung und hat keine Gewinnerehrung!",player1, 200,0,0)
		outputChatBox("Spiel ist noch in Entwicklung und hat keine Gewinnerehrung!",player2, 200,0,0)
		self.m_Map[#self.m_Map+1] = ChessSession:new(#self.m_Map+1, {player1,player2}, true)
	end
end

function ChessSessionManager:removeReference( obj )
	for i = 1, #self.m_Map do 
		if obj == self.m_Map[i] then 
			table.remove(self.m_Map, i)
		end
	end
end
function ChessSessionManager:Event_GetChessMove( toIndex, fromIndex, team)
	if client then 
		if client == source then 
			local gObject = self:getPlayerGame( client )
			if gObject then 
				gObject:movePlayerPiece( client, toIndex, fromIndex, team)
			end
		end
	end
end
--// G/S
function ChessSessionManager:getPlayerGame( player ) 
	local gObject
	for index = 1,#self.m_Map do 
		gObject = self.m_Map[index]
		if gObject then 
			if gObject:isThisPlayer( player ) then 
				return gObject 
			end
		else 
			self.m_Map[index] = nil
		end
	end
	return false
end

function coreCopy()
	ChessSessionManager:new()
end
addEventHandler("onResourceStart", resourceRoot, coreCopy, true, "high+99999")

addCommandHandler("chess",function( source , cmd, player) 	
	if player then
		if getPlayerFromName(player) then
			return ChessSessionManager:getSingleton():Event_newGame( source, getPlayerFromName(player) )
		end
	end
	return outputChatBox("Spieler nicht gefunden gib den genauen Namen ein!",source, 200,0,0)
end)