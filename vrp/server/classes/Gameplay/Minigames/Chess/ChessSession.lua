local CHESS_DEBUG = false
ChessSession = inherit(Object)

function ChessSession:constructor( id, players, speedchess, time)
	self.m_ID = id
	self.m_Players = players
	self.m_QuitEvent = bind(ChessSession.Event_onPlayerQuit, self)
	addEventHandler("onPlayerQuit", players[1], self.m_QuitEvent)
	addEventHandler("onPlayerQuit", players[2], self.m_QuitEvent)
	if speedchess then
		self.m_GameTime = time or 3*60
	end
	self.m_IsSpeedChess = speedchess
	self.m_LogicHandler = ChessLogic:new( self )
	self.m_LogicHandler:placeStart()
	self:startGame()
	self:nextTurn()
end

function ChessSession:startGame()
	local fMatrix = self.m_LogicHandler:getPositionMatrix()
	if CHESS_DEBUG then
		triggerClientEvent("onClientChessStart", self.m_Players[1], self.m_Players, fMatrix, 1, self.m_IsSpeedChess)
	else
		if self.m_Players[1] ~= self.m_Players[2] then
			triggerClientEvent("onClientChessStart", self.m_Players[1], self.m_Players, fMatrix, 1 , self.m_IsSpeedChess)
			triggerClientEvent("onClientChessStart",self.m_Players[2], self.m_Players, fMatrix, 2, self.m_IsSpeedChess)
		end
	end
	if self.m_IsSpeedChess then
		self.m_TimeTable = {}
		for i = 1,2 do
			self.m_TimeTable[i] = {self.m_Players[i],self.m_GameTime}
		end
	end
end

function ChessSession:movePlayerPiece( player, fromIndex, toIndex, team)
	if self.m_LogicHandler then
		if self.m_Turn == player then
			self.m_LogicHandler:movePiece( fromIndex, toIndex, team )
		end
	end
end

function ChessSession:rankUpPawn( player, toIndex, piece, team ) 
	if self.m_LogicHandler then
		if self.m_Turn == player then
			self.m_LogicHandler:setIndexPiece( toIndex, piece, team)
			self:onUpdateField(self.m_LogicHandler.m_FieldMatrix, true, toIndex, toIndex, team)
			self:nextTurn()
		end
	end
end


function ChessSession:onUpdateField( fMatrix, sound , from, to, team)
	if CHESS_DEBUG then
		triggerClientEvent("onClientChessUpdate", self.m_Players[1], fMatrix)
	else
		if self.m_Players then
			if self.m_Players[1] ~= self.m_Players[2] then
				triggerClientEvent("onClientChessUpdate", self.m_Players[1], fMatrix, sound, from, to, team)
				triggerClientEvent("onClientChessUpdate", self.m_Players[2], fMatrix, sound, from, to, team)
			end
		end
	end
end

function ChessSession:onPieceBeaten( piece, team, piece2, team2)
	triggerClientEvent("onClientChessPieceBeat", self.m_Players[1], piece, team, piece2, team2)
	triggerClientEvent("onClientChessPieceBeat", self.m_Players[2], piece, team, piece2, team2)
end

function ChessSession:endGame( winner, reason )
	triggerClientEvent("onClientChessStop", self.m_Players[1], reason, winner)
	triggerClientEvent("onClientChessStop", self.m_Players[2], reason, winner)
	self.m_End = true
	delete(self)
end

function ChessSession:nextTurn(isPawnRankUp, playerToSelect)
	if isPawnRankUp and playerToSelect then 
		triggerClientEvent("onClientChessChoosePawnRank", self.m_Players[playerToSelect], isPawnRankUp, playerToSelect)
		return
	end
	if self.m_Turn then
		if self.m_Players then
			if self.m_Turn == self.m_Players[2] then
				self.m_Turn = self.m_Players[1]
			else
				self.m_Turn = self.m_Players[2]
			end
			if self.m_IsSpeedChess then
				self:startTurnTime()
			end
		end
	else
		self.m_Turn = self.m_Players[1]
		if self.m_IsSpeedChess then
			if self.m_Players and not self.m_End then
				if self.m_Players[1] then	
					triggerClientEvent("onClientChessClockUpdate", self.m_Players[1], self.m_Turn , self.m_TimeTable)
				end
				if self.m_Players[2] then
					triggerClientEvent("onClientChessClockUpdate", self.m_Players[2], self.m_Turn , self.m_TimeTable)
				end
				self:startTurnTime()
			end
		end
	end
end

function ChessSession:startTurnTime()
	if self.m_Turn then
		if self.m_TurnTimer then
			if isTimer(self.m_TurnTimer) then
				killTimer(self.m_TurnTimer)
			end
			self.m_TurnTimer = nil
		end
		self.m_TurnTimer = setTimer(bind(ChessSession.Timer_syncTime, self), 1000,0)
	end
end

function ChessSession:Timer_syncTime()
	if self.m_IsSpeedChess then
		if self.m_Turn then
			if self.m_Players then
				for i = 1,2 do
					if self.m_TimeTable[i][1] == self.m_Turn then
						self.m_TimeTable[i][2] = self.m_TimeTable[i][2] - 1
					end
					if self.m_TimeTable[i][2] <= 0 then
						self:onTimeEnd( self.m_Turn )
					end
				end
				if self.m_Players then
					if self.m_Players[1] then
						triggerClientEvent("onClientChessClockUpdate", self.m_Players[1], self.m_Turn , self.m_TimeTable)
					end
					if self.m_Players[2] then
						triggerClientEvent("onClientChessClockUpdate", self.m_Players[2], self.m_Turn , self.m_TimeTable)
					end
				end
			end
		end
	end
end

function ChessSession:onTimeEnd( player )
	local winner = self.m_Players[1]
	if player == winner then
		winner = self.m_Players[2]
	end
	self:endGame( winner , "Zeit ausgelaufen!" )
end

function ChessSession:isThisPlayer( player )
	if self.m_Players then
		return self.m_Players[1] == player or self.m_Players[2] == player
	end
	return false
end

function ChessSession:destructor()
	ChessSessionManager:getSingleton():removeReference( self )
	removeEventHandler("onPlayerQuit", self.m_Players[1], self.m_QuitEvent)
	removeEventHandler("onPlayerQuit", self.m_Players[2], self.m_QuitEvent)
	delete(self.m_LogicHandler)
	if isTimer(self.m_TurnTimer) then
		killTimer(self.m_TurnTimer)
	end
	self.m_Players = nil

end
function ChessSession:onKingFall( team )
	if team >= 1 then
		if team == 1 then
			team = 2
		else
			team = 1
		end
		self:endGame( self.m_Players[team] , "Schachmatt!")
	end
end

function ChessSession:Event_onPlayerQuit( )
	local winner = self.m_Players[1]
	if source == self.m_Players[1] then
		winner = self.m_Players[2]
	end
	self:endGame( winner, "Gegner hat verlassen!")
end
