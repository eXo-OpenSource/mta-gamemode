ItemSmokeGrenade = inherit(Singleton) 

function ItemSmokeGrenade:constructor() 
	self.m_ReplaceShader = dxCreateShader("files/shader/texreplace.fx")
	self.m_RenderTarget = dxCreateRenderTarget(8, 8, true)
	dxSetRenderTarget(self.m_RenderTarget) 
		dxDrawImage(0,0,8,8, "files/images/bullethitsmoke.png")
	dxSetRenderTarget()
	dxSetShaderValue(self.m_ReplaceShader, "gTexture", self.m_RenderTarget)
	if self.m_ReplaceShader and self.m_RenderTarget then
		engineApplyShaderToWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
	end
	addEventHandler("onClientRestore", root, function(bCleared) 
		if bCleared then
			dxSetRenderTarget(self.m_RenderTarget) 
			dxDrawImage(0,0,8,8, "files/images/bullethitsmoke.png")
			dxSetRenderTarget()
				dxSetShaderValue(self.m_ReplaceShader, "gTexture", self.m_RenderTarget)
			if self.m_ReplaceShader and self.m_RenderTarget then
				engineApplyShaderToWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
			end
		end
	end)

end

function ItemSmokeGrenade:destructor() 

end
