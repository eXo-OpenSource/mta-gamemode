CHESS_PIECES = 
{
	["NOTHING"] = 0,
	["KING"] = 1,
	["QUEEN"] = 2, 
	["ROOK"] = 3,
	["BISHOP"] = 4,
	["KNIGHT"] = 5,
	["PAWN"] = 6,
}

local START_STATE = 
{
	3,5,4,2,1,4,5,3,
	6,6,6,6,6,6,6,6
}

ChessLogic = inherit(Object)

function ChessLogic:constructor(  super )
	local field = 0
	self.m_Super = super
	self.m_FieldMatrix = {	}
	self.m_Beaten = { [1] = {}, [2] = {}}
	for i = 1,8 do 
		for j = 1,8 do 
			field = field + 1
			self.m_FieldMatrix[field] = {0,0}
		end
	end
end

function ChessLogic:placeStart()
	local count = 0
	for row = 8,7, -1 do 
		for field = 8,1, -1 do
			count = count + 1
			self:setFieldPiece( field, row, START_STATE[count], 1)
		end
	end
	count = 0 
	for row = 1, 2, 1 do 
		for field = 1, 8, 1 do
			count = count + 1
			self:setFieldPiece( field, row, START_STATE[count], 2)
		end
	end
	self.m_Super:onUpdateField(self.m_FieldMatrix)
	--setTimer(bind(self.test,self),1000,1)
end

function ChessLogic:movePiece( fromIndex, toIndex, team )
	if team == 2 then 
		toIndex = 65 - toIndex 
		fromIndex = 65 - fromIndex
	end
	local piece = self:getPieceAtIndex( fromIndex )
	if piece[2] == team then 
		if piece[1] ~= 0 then 
			self:setIndexPiece( fromIndex, 0, 0)
		end
	end
	local piece2 = self:getPieceAtIndex( toIndex )
	if piece2[2] ~= team then 
		self:setIndexPiece( toIndex, piece[1], piece[2])
		if piece2[2] ~= 0 then 
			self:onBeatenPiece( piece2[1], piece2[2], piece[1], piece[2])
		end
	end
	local isPawnRankUp = false
	if piece[1] == 6 and ( (piece[2] == 1 and toIndex <= 8) or ( piece[2] == 2 and toIndex > 56)) then 
		self:setIndexPiece( toIndex, 2, piece[2])
		isPawnRankUp = toIndex
	end
	self.m_Super:nextTurn(isPawnRankUp, team)
	self.m_Super:onUpdateField(self.m_FieldMatrix, true, fromIndex, toIndex, team)
	if piece2[1] == 1 then 
		self.m_Super:onKingFall( piece2[2] )
	end
end

function ChessLogic:onBeatenPiece( piece, team, piece2, team2)
	if piece and team then
		table.insert(self.m_Beaten[team] , piece) 
		self.m_Super:onPieceBeaten( piece, team, piece2, team2)
	end
end
--[[
function ChessLogic:test()
	self:setFieldPiece( 1, 1, 0, 0)
	self.m_Super:onUpdateField(self.m_FieldMatrix)
end
--]]

function ChessLogic:setFieldPiece( width, height, piece, team)
	local index = (height-1)*8 + width
	self.m_FieldMatrix[index] = {piece,team}
end

function ChessLogic:setIndexPiece( index, piece, team)
	self.m_FieldMatrix[index] = {piece,team}
end

function ChessLogic:getPieceAtIndex( index )
	return self.m_FieldMatrix[index]
end
function ChessLogic:getPositionMatrix() 
	return self.m_FieldMatrix
end

function ChessLogic:destructor()

end
