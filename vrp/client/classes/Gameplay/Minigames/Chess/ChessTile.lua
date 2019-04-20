ChessTile = inherit(Object)
function ChessTile:constructor(id, x,y, bStartDark, super)
	self.m_Super = super
	self.m_X = x
	self.m_Y = y
	self.m_Piece = 0
	self.m_Index = id
	self.m_NotMoved = true
	if not bStartDark then
		if id % 2 == 0 then
			self.m_Color = CHESS_CONSTANT.TILE_COLORS[1]
		else
			self.m_Color = CHESS_CONSTANT.TILE_COLORS[2]
		end
	else
		if id % 2 == 0 then
			self.m_Color = CHESS_CONSTANT.TILE_COLORS[2]
		else
			self.m_Color = CHESS_CONSTANT.TILE_COLORS[1]
		end
	end
	self.m_PosX = CHESS_CONSTANT.START_X + self.m_X*CHESS_CONSTANT.TILE_SIZE
	self.m_PosY = CHESS_CONSTANT.START_Y + self.m_Y*CHESS_CONSTANT.TILE_SIZE
end

function ChessTile:destructor()

end

function ChessTile:draw()
	self:update()
	self:drawTile()
	self:drawPiece()
	if self.m_LastClicked then
		self:drawMarking()
	end
	if self.m_IsPossibleMove then
		dxDrawRectangle(self.m_PosX, self.m_PosY, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.NEXT_STEP_COLOR)
	end
end

function ChessTile:update()
	if self:isCursorInTile() then
		local r,w = ChessRule:getSingleton():getFieldPieceRow( self.m_Index )
		local ind = ChessRule:getSingleton():getFieldPieceIndex( r,w)
		self.m_Super:setCurrentCursorTile( self )
	end
end

function ChessTile:drawTile()
	dxDrawImage(self.m_PosX, self.m_PosY, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE,CHESS_CONSTANT.PATH..CHESS_CONSTANT.URL_TILE..".png", 0,0,0,self.m_Color)
end

function ChessTile:drawPiece()
	if self.m_Piece > 0  then
		if self.m_PieceTeam == 1 then
			dxDrawImage(self.m_PosX+1, self.m_PosY+1, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[self.m_Piece].."B.png")
			dxDrawImage(self.m_PosX, self.m_PosY, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[self.m_Piece]..".png")
		elseif self.m_PieceTeam == 2 then
			dxDrawImage(self.m_PosX+1, self.m_PosY+1, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[self.m_Piece]..".png")
			dxDrawImage(self.m_PosX, self.m_PosY, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.PATH..CHESS_CONSTANT.CHESS_URL[self.m_Piece].."B.png")
		end
	end
end

function ChessTile:drawMarking()
	if self:isLocalPiece() then
		dxDrawRectangle(self.m_PosX, self.m_PosY, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE,CHESS_CONSTANT.MARK_COLOR)
	else
		dxDrawRectangle(self.m_PosX, self.m_PosY, CHESS_CONSTANT.TILE_SIZE, CHESS_CONSTANT.TILE_SIZE,CHESS_CONSTANT.ERROR_MARK_COLOR)
	end
end

function ChessTile:setPiece( intPiece, intTeam, bStart )
	if not bStart then
		if intPiece == 6 and self.m_Y ~= 6 then
			self.m_NotMoved = false
		end
	end
	self.m_Piece = intPiece
	self.m_PieceTeam = intTeam
end

function ChessTile:removeMarking()
	if self:isCursorInTile() then
		self.m_LastClicked = false
	end
end

function ChessTile:onClick()
	if self:isCursorInTile() then
		self.m_LastClicked = true
	end
	if self.m_IsPossibleMove then
		self.m_Super:clickNextMove( self )
	end
end

function ChessTile:isCursorInTile()
	if isCursorShowing() then
		local cx,cy = getCursorPosition()
		if cx and cy then
			cx = cx*screenWidth
			cy = cy*screenHeight
			if cx >= self.m_PosX and cx <= self.m_PosX + CHESS_CONSTANT.TILE_SIZE then
				if cy >= self.m_PosY and cy <= self.m_PosY + CHESS_CONSTANT.TILE_SIZE then
					return true
				end
			end
		end
	end
	return false
end

function ChessTile:isLocalPiece()
	if self.m_Piece > 0  then
		if self.m_PieceTeam == self.m_Super.m_TeamSide then
			return true
		else
			return false
		end
	end
	return false
end
