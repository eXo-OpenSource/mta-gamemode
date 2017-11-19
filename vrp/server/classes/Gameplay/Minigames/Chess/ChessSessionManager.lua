ChessSessionManager = inherit(Singleton)

addRemoteEvents{"onServerGetChessMove", "onServerGetSurrender", "chessQuestion", "chessQuestionAccept", "chessQuestionDecline", "onServerGetChessPawnSelection"}


function ChessSessionManager:constructor()
	self.m_Map = {	}
	addEventHandler("onServerGetChessMove", root, bind(ChessSessionManager.Event_GetChessMove, self))
	addEventHandler("onServerGetChessPawnSelection", root, bind(ChessSessionManager.Event_GetPawnSelection, self))
	addEventHandler("onServerGetSurrender", root, bind(ChessSessionManager.Event_GetSurrender, self))
end

function ChessSessionManager:destructor()

end

function ChessSessionManager:Event_newGame( player1, player2)
	if not self:getPlayerGame( player1 ) and not self:getPlayerGame( player2 ) then
		self.m_Map[#self.m_Map+1] = ChessSession:new(#self.m_Map+1, {player1,player2}, true, 6*60)
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

function ChessSessionManager:Event_GetPawnSelection( toIndex, pieceSelection, team ) 
	if client then
		if client == source then
			local gObject = self:getPlayerGame( client )
			if gObject then
				gObject:rankUpPawn( client, toIndex, pieceSelection, team)
			end
		end
	end
end

function ChessSessionManager:Event_GetSurrender()
	if client then
		if client == source then
			local gObject = self:getPlayerGame( client )
			if gObject then
				local winner
				if gObject.m_Players[1] == client then
					winner = gObject.m_Players[2]
				else
					winner = gObject.m_Players[1]
				end
				gObject:endGame( winner, "Kapitulation!" )
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

addEventHandler("chessQuestionAccept", root,
	function(host)
		ChessSessionManager:getSingleton():Event_newGame(host, client)
		client.chessPlaying = true
		host.chessSendRequest = false
	end
)

addEventHandler("chessQuestionDecline", root,
	function(host)
		if host.chessSendRequest then
			host:sendError(_("Der Spieler %s hat abgelehnt!", host, client.name))
			host.chessSendRequest = false
		end
	end
)

addEventHandler("chessQuestion", root,
    function(target)
		if client.chessSendRequest then client:sendError(_("Du hast dem Spieler bereits eine Anfrage gesendet", client)) return end
		client:sendShortMessage(_("Du hast eine Schach-Anfrage an %s gesendet!", client, target:getName()))
		client.chessSendRequest = true
		target:triggerEvent("onAppDashboardGameInvitation", client, "Schach", "chessQuestionAccept", "chessQuestionDecline", client)
	end
)
