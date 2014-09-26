Nametag = inherit(Singleton)

addEvent("reciveNametagBuffs", true)

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
	self.m_IsModifying = false
	self.m_Bone = 8
	
	self.m_Draw = bind(self.draw,self)
	self.m_ReciveBuffs = bind(self.reciveBuffs,self)
	
	addEventHandler("onClientRender",root,self.m_Draw)
	addEventHandler("reciveNametagBuffs",root,self.m_ReciveBuffs)

end

function Nametag:reciveBuffs(buffs)
	self.m_PlayerBuffs = buffs
	
	for key, value in pairs(self.m_PlayerBuffs) do
		if not self.m_Players[getPlayerFromName(key)] then
			self.m_Players[getPlayerFromName(key)] = true
		end
	end
end

function Nametag:onUnknownSpotted(player)
	self.m_Players[player] = true
	self.m_PlayerBuffs[getPlayerName(player)] = {}
	triggerServerEvent("requestNametagBuffs",localPlayer)
end

function Nametag:draw()

	for _, player in ipairs(getElementsByType("player")) do
		if not self.m_Players[player] then
			self:onUnknownSpotted(player)
		end
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
				
				if self.m_PlayerBuffs[getPlayerName(player)] then
					for key, buff in ipairs(self.m_PlayerBuffs[getPlayerName(player)]) do
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