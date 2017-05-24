-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/GasStation.lua
-- *  PURPOSE:     Gas stations
-- *
-- ****************************************************************************
GasStation = inherit(Singleton)

function GasStation:constructor()
	self.m_FillTimer = false

	self.m_Amount = 0
	self.m_Price = 0

	self.m_Shader = dxCreateShader("files/shader/texreplace.fx")
	self.m_ShaderTextures = {"petrolpumpbase_256", "vgnptrpump1_256"}

	self.m_RenderTarget = dxCreateRenderTarget(512,512)

	self.m_Offset = {
		["Amount"] = {50,80,412,60},
		["Price"] = {50,180,412,60}
	}

	if screenWidth > 1024 and screenHeight >= 720 then
		self.m_Font = dxCreateFont("files/fonts/fuelstation.ttf",16)
		self.m_Size = 2
	else
		self.m_Font = dxCreateFont("files/fonts/fuelstation.ttf",12)
		self.m_Size = 1
	end

	self.m_StreamedIn = 0
	self.m_StreamedObjects = {}
	addEventHandler("onClientElementStreamIn",root, bind(self.onStreamIn, self))
	addEventHandler("onClientElementStreamOut",root ,bind(self.onStreamOut, self))

	engineApplyShaderToWorldTexture(self.m_Shader, self.m_ShaderTextures[1])
	engineApplyShaderToWorldTexture(self.m_Shader, self.m_ShaderTextures[2])

	addRemoteEvents{"gasStationStart", "gasStationReset", "gasStationUpdate"}

	addEventHandler("gasStationStart", root, bind(self.onStart, self))
	addEventHandler("gasStationReset", root, bind(self.onReset, self))
	addEventHandler("gasStationUpdate", root, bind(self.onUpdate, self))

	self.m_RenderBind = bind(self.gasRender, self)
end

function GasStation:onStart(shopId)
	ShortMessage:new(_"Drücke Leertaste um zu tanken!")
	self.m_Amount = 0
	self.m_Price = 0
	if not self.m_FillTimer then
		self.m_FillTimer = setTimer(
			function()
				if getKeyState("space") then
					triggerServerEvent("gasStationFill", root, shopId)
				end
			end,
			1000,
			0
		)
	end
end

function GasStation:onReset()
	self.m_Amount = 0
	self.m_Price = 0
	if self.m_FillTimer then
		killTimer(self.m_FillTimer)
		self.m_FillTimer = false
	end
end

function GasStation:onStreamIn()
	if source:getModel() == 1676 then
		self.m_StreamedIn = self.m_StreamedIn+1
		self.m_StreamedObjects[source] = true
		removeEventHandler("onClientRender", root, self.m_RenderBind)
		addEventHandler("onClientRender", root, self.m_RenderBind)
	end
end

function GasStation:onStreamOut()
	if source:getModel() == 1676 then
		self.m_StreamedIn = self.m_StreamedIn-1
		self.m_StreamedObjects[source] = nil
		if self.m_StreamedIn <= 0 then
			removeEventHandler("onClientRender", root, self.m_RenderBind)
		end
	end

end

function GasStation:gasRender()
	local rendering = self:checkRender() 
	if rendering then
		dxSetRenderTarget(self.m_RenderTarget)
		self:renderBackground()
		self:renderDisplay()
		dxSetRenderTarget()
		dxSetShaderValue(self.m_Shader, "gTexture", self.m_RenderTarget)
	end
end

function GasStation:checkRender() 
	for obj, k in pairs(self.m_StreamedObjects) do 
		if obj.getPosition then 
			if getDistanceBetweenPoints3D(obj:getPosition(), localPlayer:getPosition() ) <= 15 then 
				return true
			end
		end
	end
	return false
end

function GasStation:onUpdate(amount, price)
	self.m_Amount = self.m_Amount + amount
	self.m_Price = self.m_Price + price
end

function GasStation:dxDrawBoxText(text , x, y , w , h , ...)
	dxDrawText( text , x , y , x + w , y + h , ... )
end

function GasStation:dxDrawBoxShape( x, y, w, h , ...)
	dxDrawLine( x, y, x+w,y,...)
	dxDrawLine( x, y+h , x +w , y+h,...)

	dxDrawLine( x , y ,x , y+h , ... )
	dxDrawLine( x+w , y ,x+w , y+h , ...)
end

function GasStation:renderBackground()
	dxDrawRectangle( 0,0,512,512,tocolor(80,80,80,255))
	dxDrawRectangle(50,80,412,60,tocolor(0,0,0,255))
	self:dxDrawBoxShape(50,80,412,60 , tocolor(0,80,20,255),3)
	dxDrawRectangle(50,180,412,60,tocolor(0,0,0,255))
	self:dxDrawBoxShape(50,180,412,60,tocolor(0,80,20,255),3)
end

function GasStation:renderDisplay()
	local px,py,width,height = unpack(self.m_Offset["Amount"])
	self:dxDrawBoxText( "LITER / L" , px,py-height, width, height, tocolor(0,0,0,255),self.m_Size-0.4, self.m_Font, "left", "bottom")
	self:dxDrawBoxText( self.m_Amount , px,py,width,height, tocolor(0,130,130,255), self.m_Size, self.m_Font, "center", "center")

	local px_,py_,width_,height_ = unpack(self.m_Offset["Price"])
	self:dxDrawBoxText( "KOSTEN / $" , px_,py+height,width_,py_-(py+height)+(height*0.1),tocolor(0,0,0,255),self.m_Size-0.4,self.m_Font,"left","bottom")
	self:dxDrawBoxText( self.m_Price , px_,py_,width_,height_,tocolor(0,150,0,255), self.m_Size, self.m_Font,"center","center")
end
