Nametag = inherit(Singleton)

local NAMETAG_COLSHAPE_SIZE = 20

Nametag.BUFF_IMG = {
	["wanteds"] = "...";
}

function isCursorOverArea ( x,y,w,h )
	if isCursorShowing () then
		local cursorPos = {getCursorPosition()}
		local mx, my = cursorPos[1]*screenWidth,cursorPos[2]*screenHeight
		if mx >= x and mx <= x+w and my >= y and my <= y+h then
			return true
		end
	end	
	return false
end

function Nametag:constructor()
	
	self.m_Players = {}
	self.m_PlayerBuffs = {}
	self.m_Colshape = createColSphere(0,0,0,NAMETAG_COLSHAPE_SIZE)
	self.m_IsModifying = false
	self.m_Bone = 8
	
	self:enter(localPlayer,true)
	
	self.m_Draw = bind(self.draw,self)
	self.m_Enter = bind(self.enter,self)
	self.m_Leave = bind(self.leave,self)
	self.m_Quit = bind(self.quit,self)
	
	addEventHandler("onClientColShapeHit",self.m_Colshape,self.m_Enter)
	addEventHandler("onClientColShapeLeave",self.m_Colshape,self.m_Leave)
	addEventHandler("onClientPlayerQuit",root,self.m_Quit)
	addEventHandler("onClientRender",root,self.m_Draw)
	
	-- test
	
	self:addBuff(localPlayer,"test",math.random(100))
	
	addCommandHandler("party",
		function(cmd,arg)
			self:addBuff(localPlayer,"test",math.random(100)) -- element, string, int
		end
	)
end

function Nametag:addBuff(player,buff,amount)
	if not self.m_PlayerBuffs[player] then
		self.m_PlayerBuffs[player] = {}
	end
	table.insert(self.m_PlayerBuffs[player], { BUFF = buff, AMOUNT = amount } )
	return self.m_PlayerBuffs[player][#self.m_PlayerBuffs[player]]
end

function Nametag:leave(hitElement,dim)
	if dim and getElementType(hitElement) == "player" then
		self.m_Players[hitElement] = nil
	end
end

function Nametag:enter(hitElement,dim)
	if dim and getElementType(hitElement) == "player" then
		self.m_Players[hitElement] = true
	end
end

function Nametag:quit()
	if self.m_Players[source] then
		self.m_Players[source] = nil
	end
end

function Nametag:draw()
	local px,py,pz = getElementPosition(localPlayer)
	setElementPosition(self.m_Colshape,px,py,pz)
	
	for player in pairs(self.m_Players) do
		if player ~= localPlayer or self.m_IsModifying then
			local px,py,pz = getPedBonePosition(player,self.m_Bone)
			pz = pz + 0.3
			local x,y = getScreenFromWorldPosition(px,py,pz)
			-- isLineOfSightClear (float,float,float,float,float,float,bool,bool,bool,bool,bool)
			if x and y then
				local name = getPlayerName(player):gsub("#%d%d%d%d%d%d%d%d","")
				dxDrawText(name,x-(dxGetTextWidth(name,2.1,"default-bold")/2),y,0,0,Color.Black,2.1,"default-bold")
				dxDrawText(name,x-(dxGetTextWidth(name,2,"default-bold")/2),y,0,0,Color.White,2,"default-bold")
				dxDrawRectangle(x-(220/2),y-45,220,30,tocolor(0,0,0,125))
				dxDrawRectangle(x-(200/2),y-40,getElementHealth(player)*2,20,tocolor(0,125,0,125))
				dxDrawRectangle(x-(200/2),y-40,getPedArmor(player)*2,20,tocolor(0,0,125,125))
				
				-- DRAW BUFFS
				
				if self.m_PlayerBuffs[player] then
					for key, buff in ipairs(self.m_PlayerBuffs[player]) do
						local i = key-1
						local row = math.floor(i/3)
						local itemInRow = i-row*3
						dxDrawRectangle(x+(itemInRow*(220/3))-100,y-100-(row*40),40,30,Color.White)
						dxDrawText     (buff.AMOUNT,x+(itemInRow*(220/3))-75,y-85-(row*40),0,0,Color.Black)
					end
				end
					
			end
			
			if self.m_IsModifying and player == localPlayer then
				for i = 1,54,1 do
					local bonePosition = {getPedBonePosition(player,i)}
					if bonePosition[2] then
						local x,y = getScreenFromWorldPosition(unpack(bonePosition))
						if x and y then
							if i == self.m_Bone then
								dxDrawRectangle(x,y,5,5,Color.Green)
							else
								dxDrawRectangle(x,y,5,5,Color.Red)
								if isCursorOverArea(x,y,5,5) and getKeyState("mouse1") then
									self.m_Bone = i
								end
							end
						end
					end
				end
			end
			
		end
	end
end

function Nametag:destructor()

end