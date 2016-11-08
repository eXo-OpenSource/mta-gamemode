local SunInstance = nil

SunShader = {}

function SunShader:constructor()
	self.shadersEnabled = "false"
	self.screenWidth, self.screenHeight = guiGetScreenSize()
	
	self.lensFlareDirt = dxCreateTexture("Textures/lensflare_dirt.png")
	self.lensFlareChroma = dxCreateTexture("Textures/lensflare_chroma.png")
	
	self.viewDistance = 0.00005
	
	self.sunColorInner = {0.9, 0.7, 0.6, 1}
	self.sunColorOuter = {0.85, 0.65, 0.55, 1}
	self.sunSize = 0.04
	
	self.excludingTextures = 	{	"waterclear256",
									"*smoke*",
									"*particle*",
									"*cloud*",
									"*splash*",
									"*corona*",
									"*sky*",
									"*radar*",
									"*wgush1*",
									"*debris*",
									"*wjet4*",
									"*gun*",
									"*wake*",
									"*effect*",
									"*fire*",
									"muzzle_texture*",
									"*font*",
									"*icon*",
									"shad_exp",
									"*headlight*", 
									"*corona*",
									"sfnitewindow_alfa", 
									"sfnitewindows", 
									"monlith_win_tex", 
									"sfxref_lite2c",
									"dt_scyscrap_door2", 
									"white", 
									"casinolights*",
									"cj_frame_glass", 
									"custom_roadsign_text", 
									"dt_twinklylites",
									"vgsn_nl_strip", 
									"unnamed", 
									"white64", 
									"lasjmslumwin1",
									"pierwin05_law", 
									"nitwin01_la", 
									"sl_dtwinlights1", 
									"fist",
									"sphere",
									"*spark*",
									"glassmall",
									"*debris*",
									"wgush1",
									"wjet2",
									"wjet4",
									"beastie",
									"bubbles",
									"pointlight",
									"unnamed",
									"txgrass1_1", 
									"txgrass0_1", 
									"txgrass1_0",
									"item*",
									"undefined*",
									"coin*",
									"turbo*",
									"lava*",
									"ampelLight*",
									"*shad*",
									"cj_w_grad"}

	
	self.m_Update = function() self:update() end
	addEventHandler("onClientPreRender", root, self.m_Update)
	
	
	self:createShaders()
	
	self.sun = new(Sun, self)	
	
	addEvent( "switchSunShader", true )
	addEventHandler( "switchSunShader", resourceRoot, bind(self.toggleShaders, self))	
end

function SunShader:toggleShaders(bool)
	if bool == true then
		self:createShaders()
	else 
		self:removeShaders()
	end
end

function SunShader:createShaders()
	if (self.shadersEnabled == "false") then
		self.screenSource = dxCreateScreenSource(self.screenWidth, self.screenHeight)
		self.renderTargetBW = dxCreateRenderTarget(self.screenWidth, self.screenHeight)
		self.renderTargetSun = dxCreateRenderTarget(self.screenWidth, self.screenHeight)
		self.renderTargetGodRaysBase = dxCreateRenderTarget(self.screenWidth, self.screenHeight)
		self.renderTargetGodRays = dxCreateRenderTarget(self.screenWidth, self.screenHeight)
		self.bwShader = dxCreateShader("Shaders/bw.fx")
		self.godRayBaseShader = dxCreateShader("Shaders/godRayBase.fx")
		self.sunShader = dxCreateShader("Shaders/sun.fx")
		self.godRayShader = dxCreateShader("Shaders/godrays.fx")
		self.lensFlareShader = dxCreateShader("Shaders/lensflares.fx")
		self.dynamicLightShader = dxCreateShader("Shaders/dynamiclight.fx", 1000, 0, false, "world,ped,object,other")
		self.vehicleShader = dxCreateShader("Shaders/vehicle.fx", 1000, 0, false, "vehicle")
		
		if (not self.dynamicLightShader) or (not self.vehicleShader) or (not self.bwShader) or (not self.godRayBaseShader) or (not self.sunShader) or (not self.godRayShader) or (not self.lensFlareShader) or (not self.screenSource) or (not self.renderTargetBW) or (not self.renderTargetSun) or (not self.renderTargetGodRaysBase) or (not self.renderTargetGodRays) then
			outputChatBox("Loading sun shader failed. Please use debugscript 3 for further details")
			
			self:removeShaders()
		else
			engineApplyShaderToWorldTexture(self.dynamicLightShader, "*")
			engineApplyShaderToWorldTexture(self.vehicleShader, "*")
			
			for _, texture in ipairs(self.excludingTextures) do
				engineRemoveShaderFromWorldTexture(self.dynamicLightShader, texture)
			end	
			
			self.shadersEnabled = "true"
		end
	end
end

function SunShader:update()
	if (self.dynamicLightShader) and (self.vehicleShader) and (self.bwShader) and (self.godRayBaseShader) and (self.sunShader) and (self.godRayShader) and (self.lensFlareShader) and (self.screenSource) and (self.renderTargetBW) and (self.renderTargetSun) and (self.renderTargetGodRaysBase) and (self.renderTargetGodRays) then	
		if (self.sun) then

			self.sunX, self.sunY, self.sunZ = self.sun:getSunPosition()
			self.sunScreenX, self.sunScreenZ = getScreenFromWorldPosition(self.sunX, self.sunY, self.sunZ, 1, true)
			
			dxUpdateScreenSource(self.screenSource)	
			
			setPlayerHudComponentVisible("all", false)
			setSunSize(0)
			setSunColor (0, 0, 0, 0, 0, 0)
			setSkyGradient(90, 85, 120, 120, 130, 175)
			setCloudsEnabled(false)
			setFarClipDistance(1200)
			setFogDistance(850)
			
			-- object lighting
			dxSetShaderValue(self.dynamicLightShader, "sunPos", {self.sunX, self.sunY, self.sunZ})
			dxSetShaderValue(self.dynamicLightShader, "sunColor", self.sunColorInner)
			dxSetShaderValue(self.dynamicLightShader, "ambientColor", self.sunColorOuter)
			
			-- vehicle lighting
			dxSetShaderValue(self.vehicleShader, "sunPos", {self.sunX, self.sunY, self.sunZ})
			dxSetShaderValue(self.vehicleShader, "sunColor", self.sunColorInner)
			dxSetShaderValue(self.vehicleShader, "ambientColor", self.sunColorOuter)
			
			if (self.sunScreenX) and (self.sunScreenZ) then
				-- scenario bw
				dxSetShaderValue(self.bwShader, "screenSource", self.screenSource)
				dxSetShaderValue(self.bwShader, "viewDistance", self.viewDistance)

				dxSetRenderTarget(self.renderTargetBW, true)
				dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.bwShader)
				dxSetRenderTarget()
				
				-- sun
				dxSetShaderValue(self.sunShader, "screenSource", self.screenSource)
				dxSetShaderValue(self.sunShader, "bwSource", self.renderTargetBW)
				dxSetShaderValue(self.sunShader, "sunPos", {(1 / self.screenWidth) * self.sunScreenX, (1 / self.screenHeight) * self.sunScreenZ})
				dxSetShaderValue(self.sunShader, "sunColorInner", self.sunColorInner)
				dxSetShaderValue(self.sunShader, "sunColorOuter", self.sunColorOuter)
				dxSetShaderValue(self.sunShader, "sunSize", self.sunSize)

				dxSetRenderTarget(self.renderTargetSun, true)
				dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.sunShader)
				dxSetRenderTarget()

				-- godray base
				dxSetShaderValue(self.godRayBaseShader, "screenSource", self.screenSource)
				dxSetShaderValue(self.godRayBaseShader, "renderTargetBW", self.renderTargetBW)
				dxSetShaderValue(self.godRayBaseShader, "renderTargetSun", self.renderTargetSun)
				dxSetShaderValue(self.godRayBaseShader, "screenSize", {self.screenWidth, self.screenHeight})

				dxSetRenderTarget(self.renderTargetGodRaysBase, true)
				dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.godRayBaseShader)
				dxSetRenderTarget()
				
				-- godrays
				dxSetShaderValue(self.godRayShader, "sunLight", self.renderTargetGodRaysBase)
				dxSetShaderValue(self.godRayShader, "lensDirt", self.lensFlareDirt)
				dxSetShaderValue(self.godRayShader, "sunPos", {(1 / self.screenWidth) * self.sunScreenX, (1 / self.screenHeight) * self.sunScreenZ})

				dxSetRenderTarget(self.renderTargetGodRays, true)
				dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.godRayShader)
				dxSetRenderTarget()
				
				
				-- lensflares
				dxSetShaderValue(self.lensFlareShader, "screenSource", self.screenSource)
				dxSetShaderValue(self.lensFlareShader, "sunLight", self.renderTargetGodRays)
				dxSetShaderValue(self.lensFlareShader, "lensDirt", self.lensFlareDirt)
				dxSetShaderValue(self.lensFlareShader, "lensChroma", self.lensFlareChroma)
				dxSetShaderValue(self.lensFlareShader, "sunPos", {(1 / self.screenWidth) * self.sunScreenX, (1 / self.screenHeight) * self.sunScreenZ})
				dxSetShaderValue(self.lensFlareShader, "sunColor", self.sunColorInner)
				dxSetShaderValue(self.lensFlareShader, "screenSize", {self.screenWidth, self.screenHeight})
				
				--dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.bwShader)
				--dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.sunShader)
				--dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.godRayBaseShader)
				--dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.godRayShader)
				dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.lensFlareShader)
			end
		end
	end
	
	
end

function SunShader:removeShaders()
	removeEventHandler("onClientRender", root, self.m_Update)
	
	if (self.dynamicLightShader) then
		destroyElement(self.dynamicLightShader)
		self.dynamicLightShader = nil
	end
	
	if (self.vehicleShader) then
		destroyElement(self.vehicleShader)
		self.vehicleShader = nil
	end

	if (self.bwShader) then
		destroyElement(self.bwShader)
		self.bwShader = nil
	end
	
	if (self.godRayBaseShader) then
		destroyElement(self.godRayBaseShader)
		self.godRayBaseShader= nil
	end
	
	if (self.sunShader) then
		destroyElement(self.sunShader)
		self.sunShader= nil	
	end
	
	if (self.godRayShader) then
		destroyElement(self.godRayShader)
		self.godRayShader= nil	
	end

	if (self.lensFlareShader) then
		destroyElement(self.lensFlareShader)
		self.lensFlareShader= nil	
	end
	
	if (self.screenSource) then
		destroyElement(self.screenSource)
		self.screenSource = nil
	end
	
	if (self.renderTargetBW) then
		destroyElement(self.renderTargetBW)
		self.renderTargetBW = nil
	end
	
	if (self.renderTargetSun) then
		destroyElement(self.renderTargetSun)
		self.renderTargetSun = nil
	end
	
	if (self.renderTargetGodRaysBase) then
		destroyElement(self.renderTargetGodRaysBase)
		self.renderTargetGodRaysBase = nil
	end
	
	if (self.renderTargetGodRays) then
		destroyElement(self.renderTargetGodRays)
		self.renderTargetGodRays = nil
	end
	
	resetSunSize()
	resetSunColor()
	resetSkyGradient()
	resetFarClipDistance()
	resetFogDistance()
	setCloudsEnabled(true)
	
	self.shadersEnabled = "false"
end

function SunShader:destructor()	
	self:removeShaders()
	
	if (self.sun) then
		delete(self.sun)
		self.sun = nil
	end
end

addEventHandler("onClientResourceStart", resourceRoot, 
function(resource)
	if (resource == getThisResource()) then
		SunInstance = new(SunShader)
	end
end)

addEventHandler("onClientResourceStop", resourceRoot, 
function(resource)
	if (resource == getThisResource()) then
		if (SunInstance) then
			delete(SunInstance)
			SunInstance = nil
		end
	end
end)