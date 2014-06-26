Nametag = inherit(Singleton)

local NAMETAG_COLSHAPE_SIZE = 20
local NAMETAG_SIZE_MAX = 1.5
local NAMETAG_SIZE_MIN = 0.75

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
	self.m_Colshape = createColSphere(0,0,0,NAMETAG_COLSHAPE_SIZE)
	self.m_Size = 1
	self.m_LocalX,self.m_LocalY = false,false
	
	
	self:enter(localPlayer,true)
	
	self.m_Draw = bind(self.draw,self)
	self.m_Enter = bind(self.enter,self)
	self.m_Leave = bind(self.leave,self)
	self.m_Quit = bind(self.quit,self)
	self.m_Key = bind(self.key,self)
	
	addEventHandler("onClientColShapeHit",self.m_Colshape,self.m_Enter)
	addEventHandler("onClientColShapeLeave",self.m_Colshape,self.m_Leave)
	addEventHandler("onClientPlayerQuit",root,self.m_Quit)
	addEventHandler("onClientRender",root,self.m_Draw)
	addEventHandler("onClientKey",root,self.m_Key)
	
	addCommandHandler("eeeeee",
		function(cmd,arg)
			self.m_Size = tonumber(arg)
		end
	)
end

function Nametag:key(key,press)
	if getKeyState("lctrl") and self.m_LocalX and isCursorShowing() then
		local x,y = self.m_LocalX,self.m_LocalY
		
		if key == "mouse_wheel_up" or key == "mouse_wheel_down" then
			if isCursorOverArea (x-(300*self.m_Size/2),y,300*self.m_Size,50*self.m_Size) and not isCursorOverArea(x-(300*self.m_Size/2)+20*self.m_Size,y-(self.m_Size-1*(17*self.m_Size)),(getElementHealth(localPlayer)*260/100)*self.m_Size,22.5*self.m_Size) then
				
				if key == "mouse_wheel_up" then
					self.m_Size = self.m_Size + 0.05
				else
					self.m_Size = self.m_Size - 0.05
				end
				
				self.m_Size = math.max(math.min(self.m_Size,NAMETAG_SIZE_MAX),NAMETAG_SIZE_MIN)
			end
		end
	end
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
		
		setPlayerNametagShowing (player,false)
		
		local x,y,z = getPedBonePosition(player,8)
		z = z + 0.4
		
		if player == localPlayer and not getKeyState ("lctrl") then
			return
		end
		
		
		if isLineOfSightClear(px,py,pz,x,y,z,true,true,false,true) then
			local x,y = getScreenFromWorldPosition(x,y,z)
			if x and y then
				
				if player == localPlayer then
					self.m_LocalX,self.m_LocalY = x,y
				end
				
				dxDrawRectangle(x-(300*self.m_Size/2),y,300*self.m_Size,50*self.m_Size,tocolor(50,50,50,125))
				dxDrawRectangle(x-(300*self.m_Size/2)+20*self.m_Size,y-(self.m_Size-1*(17*self.m_Size)),(getElementHealth(player)*260/100)*self.m_Size,22.5*self.m_Size,tocolor(0,125,0))
				dxDrawText(getPlayerName(player),x-dxGetTextWidth(getPlayerName(player),1.2,"default-bold")/2,y,0,0,tocolor(255,255,255),1.2,"default-bold")
			end
		end
	end
end

function Nametag:destructor()

end

Nametag:new()