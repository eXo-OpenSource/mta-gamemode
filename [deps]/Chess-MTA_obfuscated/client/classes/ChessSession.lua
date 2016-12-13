ChessSession = inherit(Singleton)
function ChessSession:constructor( )
	addRemoteEvents{"onClientChessStart", "onClientChessStop", "onClientChessUpdate","onClientChessPieceBeat", "onClientChessClockUpdate"}
	addEventHandler("onClientChessStart", localPlayer, bind(ChessSession.Event_startGame,self))
	addEventHandler("onClientChessUpdate", localPlayer, bind(ChessSession.Event_updateGame,self))
	addEventHandler("onClientChessStop", localPlayer, bind(ChessSession.Event_endGame,self))
	addEventHandler("onClientChessPieceBeat", localPlayer, bind(ChessSession.Event_onBeatPiece, self))
	addEventHandler("onClientChessClockUpdate", localPlayer, bind (ChessSession.Event_onClockUpdate, self))
end

function ChessSession:clear() 
	if self.m_ChessGraphics then 
		delete(self.m_ChessGraphics)
	end
	self.m_ChessGraphics = nil
end

function ChessSession:initialiseGame( initMatrix, isSpeed )
	self:clear()
	self.m_BeatList = {[1] = {}, [2] ={}}
	self.m_IsSpeedChess = isSpeed
	self.m_ChessGraphics = ChessGraphics:new( self.m_Team, self )
	self.m_ChessGraphics:update( initMatrix, true )
end

function ChessSession:nextMove( toIndex, fromIndex )
	if toIndex and fromIndex then 
		triggerServerEvent("onServerGetChessMove", localPlayer, fromIndex, toIndex, self.m_Team)
	end
end

function ChessSession:Event_endGame()
	self:clear()	
end

function ChessSession:Event_onClockUpdate( turn, mTable )
	if self.m_ChessGraphics then 
		self.m_ChessGraphics.m_Clock:update( turn, mTable)
	end
end
function ChessSession:Event_startGame( players , initMatrix, localTeam, isSpeed)
	self.m_Team = localTeam
	self.m_Players = players
	self:initialiseGame( initMatrix , isSpeed)
end

function ChessSession:Event_updateGame( fMatrix , bSound)
	if self.m_ChessGraphics then 
		self.m_ChessGraphics:update( fMatrix )
		if bSound then
			playSound(CHESS_CONSTANT.AUDIO_PATH.."/move.ogg")
		end
	end
end

function ChessSession:Event_onBeatPiece( piece, team)
	if not self.m_BeatList[team][piece] then 
		self.m_BeatList[team][piece] = 0
	end
	self.m_BeatList[team][piece] = self.m_BeatList[team][piece] + 1
end

function ChessSession:destructor()

end

function coreCopy()
	ChessSession:new()
end
addEventHandler("onClientResourceStart", resourceRoot, coreCopy, true, "high+99999")
