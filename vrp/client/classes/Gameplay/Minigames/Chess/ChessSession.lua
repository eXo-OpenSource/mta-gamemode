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

function ChessSession:Event_endGame( endReason, loser)
	if self.m_ChessGraphics then
		self.m_ChessGraphics.m_GameOver = true
		self.m_ChessGraphics.m_EndReason = endReason
		self.m_ChessGraphics.m_Loser = loser
		localPlayer.m_InChessGame = false
	end
end

function ChessSession:onSurrenderClick()
	triggerServerEvent("onServerGetSurrender", localPlayer)
end

function ChessSession:Event_onClockUpdate( turn, mTable )
	if self.m_ChessGraphics and not self.m_ChessGraphics.m_GameOver then
		self.m_ChessGraphics.m_Clock:update( turn, mTable)
	end
end
function ChessSession:Event_startGame( players , initMatrix, localTeam, isSpeed)
	localPlayer.m_InChessGame = true
	self.m_Team = localTeam
	self.m_Players = players
	self:initialiseGame( initMatrix , isSpeed)
end

function ChessSession:Event_updateGame( fMatrix , bSound, from, to, team)
	if self.m_ChessGraphics then
		self.m_ChessGraphics:update( fMatrix )
		if bSound then
			playSound(CHESS_CONSTANT.AUDIO_PATH.."/move.ogg")
			self.m_ChessGraphics.m_MoveLineAlpha = 255
			if team == self.m_Team then
				self.m_ChessGraphics.m_MoveCol1 = 0
				self.m_ChessGraphics.m_MoveCol2 = 200
			else
				self.m_ChessGraphics.m_MoveCol1 = 200
				self.m_ChessGraphics.m_MoveCol2 = 0
			end
			if team == 2 then
				if self.m_Team == 2 then
					from = math.abs(from-65)
					to = math.abs( to-65)
				end
			else
				if team == 1 then
					if self.m_Team == 2 then
						from = 65- from
						to = 65- to
					end
				end
			end
			self.m_ChessGraphics.m_MoveLineFrom = from
			self.m_ChessGraphics.m_MoveLineTo = to
		end
	end
end

function ChessSession:Event_onBeatPiece( piece, team, piece2, team2)
	if not self.m_BeatList[team][piece] then
		self.m_BeatList[team][piece] = 0
	end
	self.m_BeatList[team][piece] = self.m_BeatList[team][piece] + 1
	self.m_ChessGraphics.m_DrawBeatFeed = true
	self.m_ChessGraphics.m_BeatDrawTick = getTickCount()
	self.m_ChessGraphics.m_BeatenPiece = {piece, team}
	self.m_ChessGraphics.m_BeatingPiece = {piece2, team2}
end


function ChessSession:destructor()

end
