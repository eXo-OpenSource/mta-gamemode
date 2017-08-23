-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PaintjobPreviewGUI.lua
-- *  PURPOSE:     Paintjob Preview
-- *
-- ****************************************************************************
PaintjobPreviewGUI = inherit(GUIForm)
inherit(Singleton, PaintjobPreviewGUI)
addRemoteEvents{"onClientPreviewVehicleChecked"}
function PaintjobPreviewGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.38/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.38, screenHeight*0.4)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Speziallack - Vorschau", true, true, self)
	GUILabel:new(self.m_Width*0.3, self.m_Height*0.31, self.m_Width*0.7, self.m_Height*0.07, _"Bitte füge unten deine URL welche mit .png oder .jpg endet ein:", self.m_Window):setColor(Color.White)
	GUILabel:new(self.m_Width*0.3, self.m_Height*0.4, self.m_Width*0.7, self.m_Height*0.07, _"Achtung dies ist nur eine Vorschau welche du selbst siehst!", self.m_Window):setColor(Color.White)


	GUILabel:new(self.m_Width*0.3, self.m_Height*0.49, self.m_Width*0.7, self.m_Height*0.07, _"URL:", self.m_Window)
	self.m_PreviewURL = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.51, self.m_Width*0.4, self.m_Height*0.07,  self.m_Window)
	self.m_PreviewButton = VRPButton:new(self.m_Width*0.3, self.m_Height*0.6, self.m_Width*0.4, self.m_Height*0.07, _"Vorschau", true,self.m_Window)
	self.m_PreviewButton.onLeftClick = bind(self.PreviewButton_Click, self)
	self.m_CallBackEvent = bind(self.Event_OnCallBackDownload, self)
	addEventHandler("onClientPreviewVehicleChecked", localPlayer, bind(self.Event_onCheckedVehicle, self))
end


function PaintjobPreviewGUI:PreviewButton_Click()
	triggerServerEvent("checkPaintJobPreviewCar", localPlayer)
end

function PaintjobPreviewGUI:Event_onCheckedVehicle( vehicle )
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh == vehicle then
		local url = self.m_PreviewURL:getText()
		local isPng = string.find( url, ".png")
		local isJpg = string.find( url, ".jpg")
		local isHttp = string.find( url, "http://")
		local veh = getPedOccupiedVehicle(localPlayer)
		if veh then
			if isHttp then
				if isPng or isJpg then
					fetchRemote(url, self.m_CallBackEvent, {veh})
				end
			end
		end
	end
end

function PaintjobPreviewGUI:Event_OnCallBackDownload( rData, errno, vehicle)
	if vehicle then
		if errno == 0 then
			if rData then
				if self.m_PreviewPixels then
					destroyElement(self.m_PreviewPixels)
				end
				self.m_PreviewPixels = dxCreateTexture(rData)
				if self.m_PreviewPixels then
					if self.m_RenderTarget then
						destroyElement(self.m_RenderTarget)
					end
					local width, height = dxGetMaterialSize(self.m_PreviewPixels)
					self.m_RenderTarget = dxCreateRenderTarget(width, height, true)
					if self.m_Shader then
						destroyElement(self.m_Shader)
					end
					self.m_Shader = dxCreateShader("files/shader/texreplace.fx")
					self.m_Texture = VEHICLE_SPECIAL_TEXTURE[getElementModel(vehicle)] or "vehiclegrunge256"
						outputChatBox("Here2")
					if self.m_Shader then
						outputChatBox("Here")
						dxSetShaderValue(self.m_Shader, "gTexture", self.m_Texture)
						engineApplyShaderToWorldTexture(self.m_Shader, self.m_TextureName, self.m_Element)
					end
				end
			end
		end
	end
end

function PaintjobPreviewGUI:AbortButton_Click()
	if self.m_Shader then
		if self.m_TextureName and self.m_Element then
			engineRemoveShaderFromWorldTexture(self.m_Shader, self.m_TextureName, self.m_Element)
		end
	end
	self:close()
end
