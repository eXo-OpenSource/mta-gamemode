ChessGraphics = inherit(Object)
local w,h = screenWidth, screenHeight
local BEAT_ICON_SIZE = w*0.1
local centerX = (CHESS_CONSTANT.START_X + CHESS_CONSTANT.WIDTH*0.5)
local centerY = (CHESS_CONSTANT.START_Y + CHESS_CONSTANT.HEIGHT*0.5)
local imageWidth = CHESS_CONSTANT.WIDTH*0.15

function ChessGraphics:constructor( team, super )
	self.m_Super = super
	self.m_TimeData = super.m_TimeData
	self.m_RenderFunction = bind(ChessGraphics.draw,self)
	self.m_ClickFunction = bind(ChessGraphics.click,self)
	self.m_TeamSide = team
	if super.m_IsSpeedChess then
		self.m_Clock = ChessClock:new( self )
	end
	addEventHandler("onClientRender",root, self.m_RenderFunction)
	addEventHandler("onClientClick",root, self.m_ClickFunction)

	local i = 0
	local tile
	local color
	self.m_ChessTiles =	{}
	for height = 0,7 do
		for width = 0,7 do
			i = i + 1
			color = ((i - 1)/ 8) % 2 < 1
			self.m_ChessTiles[i] = ChessTile:new(i, width,height,color, self)
		end
	end
	self.m_AmbientRand1 =  math.random(1,2)
	self.m_AmbientRand2 =  math.random(1,2)
	showCursor(true)
end


function ChessGraphics:destructor()
	removeEventHandler("onClientRender",root, self.m_RenderFunction)
	removeEventHandler("onClientClick",root, self.m_ClickFunction)
	local i = 0
	local tile
	for height = 0,7 do
		for width = 0,7 do
			i = i + 1
			tile = self.m_ChessTiles[i]
			if tile then
				delete(tile)
			end
		end
	end
	if self.m_Clock then
		delete(self.m_Clock)
	end
	showCursor(false)
end

function ChessGraphics:draw()

	self:drawBoardMargin()
	self:drawTiles()
	self:drawBeaten()
	if self.m_Clock then
		self.m_Clock:draw()
	end
	self:drawMoveLine()
	self:onHover()
	self:drawButtons()
	self:drawBeatFeed()
	if self.m_EndReason and self.m_Loser then
		self:drawEndReason()
	end
	self:drawPawnSelection()
end

function ChessGraphics:drawEndReason( )
	dxDrawRectangle(CHESS_CONSTANT.START_X+CHESS_CONSTANT.MARGIN+1+CHESS_CONSTANT.TILE_SIZE*0.05,10+CHESS_CONSTANT.TILE_SIZE*0.05,CHESS_CONSTANT.WIDTH,CHESS_CONSTANT.FONT_CHAPAZA_HEIGHT,tocolor(0,0,0,240))
	dxDrawRectangle(CHESS_CONSTANT.START_X+CHESS_CONSTANT.MARGIN+1,10,CHESS_CONSTANT.WIDTH,CHESS_CONSTANT.FONT_CHAPAZA_HEIGHT,tocolor(100,100,100,255))
	local text
	if self.m_Loser == localPlayer then
		text = "Gewonnen: "..self.m_EndReason
		local width = dxGetTextWidth(text,1,CHESS_CONSTANT.FONT_CHAPAZA)
		dxDrawImage(CHESS_CONSTANT.START_X+CHESS_CONSTANT.WIDTH-CHESS_CONSTANT.TILE_SIZE*0.25, CHESS_CONSTANT.START_Y-CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.PATH.."crown.png",20,0,0)
		dxDrawText(text,CHESS_CONSTANT.START_X+CHESS_CONSTANT.MARGIN,  10, CHESS_CONSTANT.START_X+CHESS_CONSTANT.WIDTH,10+CHESS_CONSTANT.FONT_CHAPAZA_HEIGHT, tocolor(0, 0, 0,255),CHESS_CONSTANT.FONT_INFO_SCALE,CHESS_CONSTANT.FONT_INFO,"center","center")
	else
		text = "Verloren: "..self.m_EndReason
		local width = dxGetTextWidth(text,1,CHESS_CONSTANT.FONT_CHAPAZA)
		dxDrawText(text, CHESS_CONSTANT.START_X+CHESS_CONSTANT.MARGIN,  10, CHESS_CONSTANT.START_X+CHESS_CONSTANT.WIDTH,10+CHESS_CONSTANT.FONT_CHAPAZA_HEIGHT,tocolor(124, 10, 2,255),CHESS_CONSTANT.FONT_INFO_SCALE,CHESS_CONSTANT.FONT_INFO,"center","center")
	end
end

function ChessGraphics:drawBeatFeed()
	if self.m_DrawBeatFeed then
		if self.m_BeatenPiece and self.m_BeatingPiece then
			if self.m_BeatDrawTick then
				local now = getTickCount()
				if now - self.m_BeatDrawTick <= 10000 then
					local piece1, team1 = self.m_BeatingPiece[1], self.m_BeatingPiece[2]
					local piece2, team2 = self.m_BeatenPiece[1], self.m_BeatenPiece[2]
					local isBlack, isBlack2
					if team1 == 1 then
						isBlack = ""
						isBlack2 = "B"
					else
						isBlack = "B"
						isBlack2 = ""
					end
					dxDrawImage(CHESS_CONSTANT.START_X+((CHESS_CONSTANT.WIDTH*0.5)-CHESS_CONSTANT.TILE_SIZE*0.3)-CHESS_CONSTANT.MARGIN*2,CHESS_CONSTANT.START_Y+CHESS_CONSTANT.HEIGHT+CHESS_CONSTANT.MARGIN*1.5, CHESS_CONSTANT.TILE_SIZE*0.6, CHESS_CONSTANT.TILE_SIZE*0.6, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[piece1]..isBlack..".png")
					dxDrawImage(CHESS_CONSTANT.START_X+((CHESS_CONSTANT.WIDTH*0.5)+CHESS_CONSTANT.TILE_SIZE*0.4)-CHESS_CONSTANT.MARGIN*2,CHESS_CONSTANT.START_Y+CHESS_CONSTANT.HEIGHT+CHESS_CONSTANT.MARGIN*1.5+CHESS_CONSTANT.TILE_SIZE*0.1, CHESS_CONSTANT.TILE_SIZE*0.4,CHESS_CONSTANT.TILE_SIZE*0.4, CHESS_CONSTANT.PATH.."feed.png")
					dxDrawImage(CHESS_CONSTANT.START_X+((CHESS_CONSTANT.WIDTH*0.5)+CHESS_CONSTANT.TILE_SIZE*0.9)-CHESS_CONSTANT.MARGIN*2,CHESS_CONSTANT.START_Y+CHESS_CONSTANT.HEIGHT+CHESS_CONSTANT.MARGIN*1.5, CHESS_CONSTANT.TILE_SIZE*0.6,CHESS_CONSTANT.TILE_SIZE*0.6, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[piece2]..isBlack2..".png")
				else
					self.m_DrawBeatFeed = false
				end
			end
		end
	end
end

function ChessGraphics:drawButtons()
	dxDrawImage(CHESS_CONSTANT.CLOCK_X+CHESS_CONSTANT.CLOCK_WIDTH*1.2,CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.1,CHESS_CONSTANT.TILE_SIZE*0.8,CHESS_CONSTANT.TILE_SIZE*0.8,CHESS_CONSTANT.PATH.."white-flag.png",self.m_SurrenderFlagRotation or 0,0,0,self.m_SurrenderFlagColor or tocolor(255,255,255,255))
	if self.m_GameOver then
		dxDrawImage(CHESS_CONSTANT.CLOCK_X-CHESS_CONSTANT.TILE_SIZE*1.1,CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.1,CHESS_CONSTANT.TILE_SIZE*0.8,CHESS_CONSTANT.TILE_SIZE*0.8,CHESS_CONSTANT.PATH.."exit.png",0,0,0,self.m_CloseFlagColor or tocolor(200,200,200,255))
	end
end

function ChessGraphics:drawPawnSelection()
	if self.m_DrawPawnSelection then

		dxDrawRectangle(centerX-imageWidth*1.1, centerY-imageWidth*0.6, imageWidth*2.2, imageWidth*1.3, tocolor(0, 0, 0, 255))

		dxDrawImage(centerX-imageWidth, centerY-imageWidth*0.5,  imageWidth, imageWidth,  CHESS_CONSTANT.PATH.."tile.png", 0, 0, 0, tocolor(244, 125, 66, 255))
		dxDrawImage(centerX-imageWidth, centerY-imageWidth*0.5,  imageWidth, imageWidth, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[2]..".png")

		dxDrawImage(centerX+imageWidth*0.05, centerY-imageWidth*0.5,  imageWidth, imageWidth, CHESS_CONSTANT.PATH.."tile.png", 0, 0, 0, tocolor(244, 125, 66, 255))
		dxDrawImage(centerX+imageWidth*0.05, centerY-imageWidth*0.5,  imageWidth, imageWidth, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[5]..".png")

		dxDrawText("Tausche die Figur aus! (Autom. Dame)", centerX-imageWidth*1.1, centerY-imageWidth*0.7+1, centerX*2, centerY-imageWidth*0.6+1, tocolor(0, 0, 0, 255), 1, "default-bold", "left", "top")
		dxDrawText("Tausche die Figur aus! (Autom. Dame)", centerX-imageWidth*1.1, centerY-imageWidth*0.7, centerX*2, centerY-imageWidth*0.6, tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top")

	end
end

function ChessGraphics:drawBoardMargin()
	local margin = CHESS_CONSTANT.MARGIN
	dxDrawImage(0,0, w, h,CHESS_CONSTANT.PATH.."table.jpg")
	self:drawAmbient()
	dxDrawImage(CHESS_CONSTANT.START_X-margin,CHESS_CONSTANT.START_Y,margin,CHESS_CONSTANT.HEIGHT,CHESS_CONSTANT.PATH.."board.jpg")
	dxDrawImage(CHESS_CONSTANT.START_X+CHESS_CONSTANT.WIDTH,CHESS_CONSTANT.START_Y,margin,CHESS_CONSTANT.HEIGHT,CHESS_CONSTANT.PATH.."board.jpg")
	dxDrawImage(CHESS_CONSTANT.START_X-margin,CHESS_CONSTANT.START_Y-margin,CHESS_CONSTANT.WIDTH+margin*2,margin,CHESS_CONSTANT.PATH.."board.jpg")
	dxDrawImage(CHESS_CONSTANT.START_X-margin,CHESS_CONSTANT.START_Y+CHESS_CONSTANT.HEIGHT,CHESS_CONSTANT.WIDTH+margin*2,margin,CHESS_CONSTANT.PATH.."board.jpg")
end

function ChessGraphics:drawAmbient()
	if self.m_AmbientRand1 == 1 then
		dxDrawImage(w*0.08,h*0.7, w*0.16, w*0.16,CHESS_CONSTANT.PATH.."cup.png")
	else
		dxDrawImage(w*0.08,h*0.7, w*0.16, w*0.16,CHESS_CONSTANT.PATH.."glass2.png")
	end
	if self.m_AmbientRand2 == 1 then
		dxDrawImage(w*0.08,h*0.1, w*0.16, w*0.16,CHESS_CONSTANT.PATH.."cup.png",40)
	else
		dxDrawImage(w*0.8,h*0.1, w*0.16, w*0.16,CHESS_CONSTANT.PATH.."glass2.png",60)
	end
end
function ChessGraphics:drawTiles()
	local i = 0
	local tile
	for height = 0,7 do
		for width = 0,7 do
			i = i + 1
			tile = self.m_ChessTiles[i]
			if tile then
				tile:draw()
			end
		end
	end
end

function ChessGraphics:drawBeaten()
	local x,y, piece, width
	local left, right = CHESS_CONSTANT.START_X-CHESS_CONSTANT.MARGIN, CHESS_CONSTANT.START_X+CHESS_CONSTANT.WIDTH+CHESS_CONSTANT.MARGIN
	local pieceCount = 0
	local currentPiece = 0
	local iconSize = 0
	for k, v in pairs(self.m_Super.m_BeatList) do
		for piece, count in pairs(v) do
			for i = 1,count do
				if k == 1 then
					dxDrawImage(left - i* CHESS_CONSTANT.TILE_SIZE,CHESS_CONSTANT.START_Y+(piece-1)*CHESS_CONSTANT.TILE_SIZE,  CHESS_CONSTANT.TILE_SIZE,  CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[piece]..".png" )
				else
					dxDrawImage(right + (i-1)*CHESS_CONSTANT.TILE_SIZE,CHESS_CONSTANT.START_Y+(piece-1)*CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[piece].."B.png" )
				end
			end
		end
	end
end

function ChessGraphics:drawMoveLine( )
	if self.m_MoveLineAlpha then
		if self.m_MoveLineAlpha > 0 then
			if 	self.m_MoveLineFrom and self.m_MoveLineTo then
				local index1 = self.m_ChessTiles[self.m_MoveLineFrom]
				local index2 = self.m_ChessTiles[self.m_MoveLineTo]
				if index1 and index2 then
					dxDrawLine(index1.m_PosX+CHESS_CONSTANT.TILE_SIZE/2, index1.m_PosY+CHESS_CONSTANT.TILE_SIZE/2, index2.m_PosX+CHESS_CONSTANT.TILE_SIZE/2, index2.m_PosY+CHESS_CONSTANT.TILE_SIZE/2, tocolor(self.m_MoveCol1,self.m_MoveCol2,0,self.m_MoveLineAlpha),2)
				end
				self.m_MoveLineAlpha = self.m_MoveLineAlpha - 0.9
			end
		end
	end
end

function ChessGraphics:click( button, state)
	if button == "left" and state == "up" then
		if self.m_CurrentCursorTile then
			self:onClick()
			if not self.m_DrawPawnSelection then
				self.m_CurrentCursorTile:onClick()
				self.m_LastClick = self.m_CurrentCursorTile
				self:showAvailableMoves()
				local c,r = ChessRule:getSingleton():getFieldPieceRow( self.m_CurrentCursorTile.m_Index )
			end
		end
	elseif button == "right" and state == "up" then
		if self.m_LastClick then
			self.m_LastClick:removeMarking()
		end
	end
end

function ChessGraphics:onClick()
	if isCursorShowing() then
		local cx, cy = getCursorPosition()
		if cx and cy then
			cx = cx*w
			cy = cy*h
			if cx >= CHESS_CONSTANT.CLOCK_X+CHESS_CONSTANT.CLOCK_WIDTH*1.2 and cx <= CHESS_CONSTANT.CLOCK_X+CHESS_CONSTANT.CLOCK_WIDTH*1.2+CHESS_CONSTANT.TILE_SIZE*0.8 then
				if cy >= CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.1 and cy <= CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.9 then
					self.m_Super:onSurrenderClick()
				end
			end
			if self.m_GameOver then
				if cx >= CHESS_CONSTANT.CLOCK_X- CHESS_CONSTANT.TILE_SIZE*1.1 and cx <= CHESS_CONSTANT.CLOCK_X- CHESS_CONSTANT.TILE_SIZE*0.3 then
					if cy >= CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.1 and cy <= CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.9 then
						delete(self)
					end
				end
			end
			if self.m_DrawPawnSelection then
				local hasSelectedPawn = false
				local selectionPiece = 2
				if cx >= centerX-imageWidth and cx <= centerX then
					if cy >= centerY-imageWidth*0.5 and cy <= centerY + imageWidth*0.5 then
						selectionPiece = 2
						hasSelectedPawn = true
					end
				end
				if cx >= centerX and cx <= centerX+imageWidth then
					if cy >= centerY-imageWidth*0.5 and cy <= centerY + imageWidth*0.5 then
						selectionPiece = 5
						hasSelectedPawn = true
					end
				end
				if hasSelectedPawn then
					if self.m_SelectionTimeout then
						killTimer(self.m_SelectionTimeout)
					end
					self:Event_PawnSelectionConfirm( selectionPiece )
				end
			end
		end
	end
end

function ChessGraphics:onHover()
	if isCursorShowing() then
		local cx, cy = getCursorPosition()
		if cx and cy then
			cx = cx*w
			cy = cy*h
			if cx >= CHESS_CONSTANT.CLOCK_X+CHESS_CONSTANT.CLOCK_WIDTH*1.2 and cx <= CHESS_CONSTANT.CLOCK_X+CHESS_CONSTANT.CLOCK_WIDTH*1.2+CHESS_CONSTANT.TILE_SIZE*0.8 then
				if cy >= CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.1 and cy <= CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.9 then
					self.m_SurrenderFlagColor = tocolor(200,0,0,255)
					self.m_SurrenderFlagRotation = 10
					return
				end
			end
			if cx >= CHESS_CONSTANT.CLOCK_X- CHESS_CONSTANT.TILE_SIZE*1.1 and cx <= CHESS_CONSTANT.CLOCK_X- CHESS_CONSTANT.TILE_SIZE*0.3 then
				if cy >= CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.1 and cy <= CHESS_CONSTANT.CLOCK_Y+CHESS_CONSTANT.TILE_SIZE*0.9 then
					self.m_CloseFlagColor = tocolor(255,255,255,255)
					return
				end
			end
		end
	end
	self.m_SurrenderFlagColor = tocolor(255,255,255,255)
	self.m_SurrenderFlagRotation = 0
	self.m_CloseFlagColor = tocolor(180,180,180,255)
end

function ChessGraphics:showAvailableMoves()
	if self.m_LastClick:isLocalPiece() then
		self.m_CurrentSelectedPiece = self.m_LastClick
		local preIndex, curIndex
		if self.m_PotentialMoves then
			for i = 1,#self.m_PotentialMoves do
				curIndex = self.m_PotentialMoves[i]
				if type(curIndex) == "number" then
					self.m_ChessTiles[curIndex].m_IsPossibleMove = false
				end
			end
		end
		self.m_PotentialMoves = ChessRule:getSingleton():getMoveOptions( self.m_LastClick.m_Piece, self.m_LastClick.m_Index, self.m_LastClick)
		local bFirstElement = false
		local blockDrawing
		local currentStateDirection = ""
		for index = 1,#self.m_PotentialMoves do
			if index ~= 1 then
				curIndex = self.m_PotentialMoves[index]
				preIndex = self.m_PotentialMoves[index-1]
				if type(preIndex) == "string" then
					bFirstElement = true
					blockDrawing = false
					currentStateDirection = preIndex
				else
					bFirstElement = false
				end
				if type(curIndex) == "number" then
					if currentStateDirection ~= "ATTACK" then
						if self.m_ChessTiles[curIndex].m_Piece == 0 then
							if not blockDrawing then
								self.m_ChessTiles[curIndex].m_IsPossibleMove = true
							end
						elseif self.m_ChessTiles[curIndex].m_PieceTeam ~= self.m_TeamSide then
							if not blockDrawing then
								if self.m_LastClick.m_Piece ~= 6 then
									self.m_ChessTiles[curIndex].m_IsPossibleMove = true
									blockDrawing = true
								end
							end
						else
							blockDrawing = true
						end
					else
						if self.m_ChessTiles[curIndex].m_PieceTeam ~= self.m_TeamSide and self.m_ChessTiles[curIndex].m_Piece ~= 0 then
							self.m_ChessTiles[curIndex].m_IsPossibleMove = true
							blockDrawing = true
						end
					end
				else
					blockDrawing = false
				end
			end
		end
	end
end

function ChessGraphics:clickNextMove( tileObj )
	if tileObj and self.m_CurrentSelectedPiece  then
		if self.m_CurrentSelectedPiece:isLocalPiece() then
			local team = tileObj.m_PieceTeam
			local piece = tileObj.m_Piece
			local index = tileObj.m_Index
			local movePieceIndex = self.m_CurrentSelectedPiece.m_Index
			if piece == 0 or team ~= self.m_TeamSide then
				self.m_Super:nextMove( index, movePieceIndex )
			end
		end
	end
end
function ChessGraphics:update( fMatrix, bStart)
	self.m_DrawMatrix = fMatrix
	local tile
	local piece
	local first, limit, step, modify = 1,64, 1
	local index
	if self.m_TeamSide == 2 then --// Flip the whole board so black is on the bottom
		first,limit, step = 64, 1, -1
	end
	for i = first, limit, step do
		if self.m_TeamSide == 2 then
			index = (64 - i)+1
		else
			index = i
		end
		tile = self.m_ChessTiles[index]
		piece = fMatrix[i][1]
		team = fMatrix[i][2]
		if tile then
			tile:setPiece( piece, team, bStart )
		end
	end
	local preIndex, curIndex
	if self.m_PotentialMoves then
		for i = 1,#self.m_PotentialMoves do
			curIndex = self.m_PotentialMoves[i]
			if type(curIndex) == "number" then
				self.m_ChessTiles[curIndex].m_IsPossibleMove = false
			end
		end
	end
end

function ChessGraphics:setPiece( id, intPiece, team)
	if id and intPiece then
		if self.m_ChessTiles[id] then
			self.m_ChessTiles[id]:setPiece( intPiece,  team)
		end
	end
end

function ChessGraphics:setCurrentCursorTile( tile )
	if getKeyState("mouse1") then
		if self.m_LastClick then
			self.m_LastClick.m_LastClicked = false
		end
	end
	if self.m_CurrentCursorTile ~= tile then
		self.m_CurrentCursorTile = tile
	end
end

function ChessGraphics:startPawnSelection( indexPiece, team )
	self.m_DrawPawnSelection = true
	self.m_SelectionIndexPiece = indexPiece
	self.m_SelectionTeam = team
	self.m_TimerTimeoutFunction = bind(ChessGraphics.Event_ChessSelectionTimeout, self)
	self.m_SelectionTimeout = setTimer(  self.m_TimerTimeoutFunction, 10000, 1)
end

function ChessGraphics:Event_PawnSelectionConfirm( piece )
	if self.m_SelectionIndexPiece then
		triggerServerEvent( "onServerGetChessPawnSelection", localPlayer, self.m_SelectionIndexPiece, piece or 2, self.m_SelectionTeam)
	end
	self.m_DrawPawnSelection = false
	self.m_SelectionIndexPiece = nil
	self.m_SelectionTeam = nil
end

function ChessGraphics:Event_ChessSelectionTimeout( )
	if self.m_SelectionIndexPiece then
		triggerServerEvent( "onServerGetChessPawnSelection", localPlayer, self.m_SelectionIndexPiece, 2, self.m_SelectionTeam)
	end
	self.m_DrawPawnSelection = false
	self.m_SelectionIndexPiece = nil
	self.m_SelectionTeam = nil
end
