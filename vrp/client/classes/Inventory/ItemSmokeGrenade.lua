ItemSmokeGrenade = inherit(Singleton) 

ItemSmokeGrenade.Map = {}

function ItemSmokeGrenade:constructor() 
	addEventHandler("onClientElementStreamIn", root, bind(self.Event_onStreamedIn, self))
	addEventHandler("onClientElementStreamOut", root, bind(self.Event_onStreamedOut, self))
	if core:get("Other", "SmokeLowMode", false) then
		self:useLowMode()
	else 
		self:disableLowMode()
	end
end

function ItemSmokeGrenade:Event_onStreamedIn()
	if source and isElement(source) and source:getType() == "marker" then 
		if source:getData("isSmokeShape") then
			if source:getData("smokeCol") and isElement(source:getData("smokeCol")) then
				ItemSmokeGrenade.Map[source:getData("smokeCol")] = true
				source:getData("smokeCol"):setDimension(1)
			end
		end
	end
end

function ItemSmokeGrenade:useLowMode()
	self.m_ReplaceShader = dxCreateShader("files/shader/texreplace.fx") -- re-enable this if it gets used / fixed (bug with missing vehicle smoke)
	self.m_RenderTarget = dxCreateRenderTarget(4, 4, true)
	dxSetRenderTarget(self.m_RenderTarget) 
		dxDrawImage(0,0,4,4, "files/images/bullethitsmoke.png")
	dxSetRenderTarget()
	dxSetShaderValue(self.m_ReplaceShader, "gTexture", self.m_RenderTarget)
	if self.m_ReplaceShader and self.m_RenderTarget then
		engineApplyShaderToWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
	end
	addEventHandler("onClientRestore", root, function(bCleared) 
		if bCleared then
			dxSetRenderTarget(self.m_RenderTarget) 
			dxDrawImage(0,0,4,4, "files/images/bullethitsmoke.png")
			dxSetRenderTarget()
				dxSetShaderValue(self.m_ReplaceShader, "gTexture", self.m_RenderTarget)
			if self.m_ReplaceShader and self.m_RenderTarget then
				engineApplyShaderToWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
			end
		end
	end)
	ShortMessage:new(_"Achtung! Da du den Low-Mode für Rauch benutzt wird dir evtl. kein Motorrauch angezeigt!", _"Einstellungen", {230, 0, 0}, 10000)
end

function ItemSmokeGrenade:disableLowMode()
	if self.m_ReplaceShader then
		engineRemoveShaderFromWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
	end
end


function ItemSmokeGrenade:Event_onStreamedOut()
	if source and isElement(source) and source:getType() == "marker"  then 
		if source:getData("isSmokeShape") then
			if source:getData("smokeCol") and isElement(source:getData("smokeCol")) then
				ItemSmokeGrenade.Map[source:getData("smokeCol")] = nil

			end
		end
	end
end


function ItemSmokeGrenade:destructor() 

end
