--[[
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
--]]
local CHESS_RULE = 
{
	[1] = {1,1,1,1,1,1,1,1},		
	[2] = {8,8,8,8,8,8,8,8}, -- UP,DOWN,LEFT,RIGHT,DOWN-LEFT,UP-LEFT,DOWN-RIGHT,UP-RIGHT
	[3] = {8,8,8,8,0,0,0,0},
	[4] = {0,0,0,0,8,8,8,8},
	[5] = {"JMP-RELATIVE",6,10,15,17,-6,-10,-15,-17},
	[6] = {1,0,0,0,0,0,0,0,2,2,1,1},
}
ChessRule = inherit(Singleton)

function ChessRule:constructor()

end

function ChessRule:update( localTeam )
	self.m_Team = localTeam
end

function ChessRule:getMoveOptions( piece, index, tile )
	local rule = CHESS_RULE[piece]
	local moves = {}
	local newIndex, row, col, field
	if rule then
		local v1 = rule[1]
		row, col = self:getFieldPieceRow( index)
		if type(v1) == "number" then 
			--// RELATIVE MOVES
			local _, v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12 = unpack(rule)
			moves[#moves+1] = "UP"
			for i = 1,v1 do 
				field = ChessRule:getFieldPieceIndex( row, col-i)
				if field >= 1 and field <= 64 then
					moves[#moves+1] = field
				end
			end
			moves[#moves+1] = "DOWN"
			for i = 1,v2 do 
				field = ChessRule:getFieldPieceIndex( row, col+i)
				if field >= 1 and field <= 64 then
					moves[#moves+1] = field
				end
			end
			moves[#moves+1] = "LEFT"
			for i = 1,v3 do 
				field = ChessRule:getFieldPieceIndex( row+i, col)
				if field >= 1 and field <= 64 then
					moves[#moves+1] = field
				end
			end
			moves[#moves+1] = "RIGHT"
			for i = 1,v4 do 
				field = ChessRule:getFieldPieceIndex( row-i, col)
				if field >= 1 and field <= 64 then
					moves[#moves+1] = field
				end
			end
			moves[#moves+1] = "DIAG"
			for i = 1,v5 do 
				field = ChessRule:getFieldPieceIndex( row-i, col+i)
				if field >= 1 and field <= 64 then
					moves[#moves+1] = field
				end
			end
			moves[#moves+1] = "DIAG"
			for i = 1,v6 do 
				field = ChessRule:getFieldPieceIndex( row-i, col-i)
				if field >= 1 and field <= 64 then
					moves[#moves+1] = field
				end
			end
			moves[#moves+1] = "DIAG"
			for i = 1,v7 do 
				field = ChessRule:getFieldPieceIndex( row+i, col+i)
				if field >= 1 and field <= 64 then
					moves[#moves+1] = field
				end
			end
			moves[#moves+1] = "DIAG"
			for i = 1,v8 do 
				field = ChessRule:getFieldPieceIndex( row+i, col-i)
				if field >= 1 and field <= 64 then
					moves[#moves+1] = field
				end
			end
			--// SPECIAL RULES
			if piece == 6 then 	--// PAWN CAN MOVE TWO STEPS FORWARD IN BASE
				if tile.m_NotMoved then
					moves[#moves+1] = "TOP2"
					for i = 1,v10 do 
						field = ChessRule:getFieldPieceIndex( row, col-i)
						if field >= 1 and field <= 64 then
							moves[#moves+1] = field
						end
					end
				end
				moves[#moves+1] = "ATTACK"
				for i = 1,v11 do 
					field = ChessRule:getFieldPieceIndex( row-i, col-i)
					if field >= 1 and field <= 64 then
						moves[#moves+1] = field
					end
				end
				for i = 1,v12 do 
					field = ChessRule:getFieldPieceIndex( row+i, col-i)
					if field >= 1 and field <= 64 then
						moves[#moves+1] = field
					end
				end
			end
		elseif type(v1) == "string" then 
			moves[#moves+1] = "JUMP"
			
			local nIndex  = self:getFieldPieceIndex( row+1, col+2)
			if nIndex >= 1 and nIndex <= 64 then
				moves[#moves+1] = nIndex
				moves[#moves+1] = "JUMP"
			end
			nIndex  =  self:getFieldPieceIndex( row+1, col-2)
			if nIndex >= 1 and nIndex <= 64 then
				moves[#moves+1] = nIndex
				moves[#moves+1] = "JUMP"
			end
			nIndex  =  self:getFieldPieceIndex( row-1, col+2)
			if nIndex >= 1 and nIndex <= 64 then
				moves[#moves+1] = nIndex
				moves[#moves+1] = "JUMP"
			end
			nIndex  = self:getFieldPieceIndex( row-1, col-2)
			if nIndex >= 1 and nIndex <= 64 then
				moves[#moves+1] = nIndex
				moves[#moves+1] = "JUMP"
			end
			nIndex  = self:getFieldPieceIndex( row+2, col+1)
			if nIndex >= 1 and nIndex <= 64 then
				moves[#moves+1] = nIndex
				moves[#moves+1] = "JUMP"
			end
			nIndex  = self:getFieldPieceIndex( row+2, col-1)
			if nIndex >= 1 and nIndex <= 64 then
				moves[#moves+1] = nIndex
				moves[#moves+1] = "JUMP"
			end
			nIndex  = self:getFieldPieceIndex( row-2, col+1)
			if nIndex >= 1 and nIndex <= 64 then
				moves[#moves+1] = nIndex
				moves[#moves+1] = "JUMP"
			end
			nIndex  = self:getFieldPieceIndex( row-2, col-1)
			if nIndex >= 1 and nIndex <= 64 then
				moves[#moves+1] = nIndex
				moves[#moves+1] = "JUMP"
			end
		end
	end
	return moves;
end

function ChessRule:getFieldPieceIndex( width, height)
	local index = (height-1)*8 + width
	if height <= 0 or height > 8 then return -1 end
	if width <= 0 or width > 8 then return -1 end
	return index
end

function ChessRule:getFieldPieceRow( index )
	local row = ((index -1) / 8) + 1
	local col = ((index-1) % 8) +1
	return col, math.floor(row)
end