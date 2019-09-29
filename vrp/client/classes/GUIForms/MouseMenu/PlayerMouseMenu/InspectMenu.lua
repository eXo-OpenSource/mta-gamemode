-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/PlayerMouseMenu/InspectMenu.lua
-- *  PURPOSE:     Inspect mouse menu class
-- *
-- ****************************************************************************
InspectMenu = inherit(GUIMouseMenu)

function InspectMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	self.m_AnimationTick = getTickCount() 
	local fontScale = (screenHeight/1080)
	self.m_TreatButton = GUIButton:new(0, 0, screenWidth*0.05, screenHeight*0.025, "Behandeln", nil, Color.White):setBackgroundColor(Color.Clear):setAlternativeColor(Color.Clear):setFont(VRPFont(22*fontScale, Fonts.EkMukta_Bold)):setColor(Color.White):setAlign("center", "center")
	self.m_TreatButton:setBarEnabled(false)
	self.m_TreatLineColor = false
	self.m_TreatAlpha = 0
	self.m_TreatButton.onHover = function() 
		playSound("files/audio/walkie_click.ogg")
		self.m_TreatButton:setColor(Color.Black)
		self.m_TreatLineColor = true 
		self.m_AnimationTreatFade = CAnimation:new(self, "m_TreatAlpha")
		self.m_AnimationTreatFade:startAnimation(200, "OutQuad", 255)
	end 
	self.m_TreatButton.onUnhover = function() 
		self.m_TreatButton:setColor(Color.White)
		self.m_TreatLineColor = false
		self.m_TreatAlpha = 0
		if self.m_AnimationTreatFade then 
			self.m_AnimationTreatFade:stopAnimation()
		end
	end 	
	self.m_TreatButton.onLeftClick = function() 
		delete(self) 
		triggerServerEvent("Damage:getPlayerDamage", localPlayer, element)
	end

	self.m_InspectWeapon = GUIButton:new(0, 0, screenWidth*0.05, screenHeight*0.025, "Waffen", nil, Color.White):setBackgroundColor(Color.Clear):setAlternativeColor(Color.Clear):setFont(VRPFont(22*fontScale, Fonts.EkMukta_Bold)):setColor(Color.White):setAlign("center", "center")
	self.m_InspectWeapon:setBarEnabled(false)
	self.m_WeaponLineColor = false
	self.m_WeaponAlpha = 0
	self.m_InspectWeapon.onHover = function() 
		playSound("files/audio/walkie_click.ogg")
		self.m_InspectWeapon:setColor(Color.Black)
		self.m_WeaponLineColor = true 
		self.m_AnimationWeaponFade = CAnimation:new(self, "m_WeaponAlpha")
		self.m_AnimationWeaponFade:startAnimation(200, "OutQuad", 255)
	end 
	self.m_InspectWeapon.onUnhover = function() 
		self.m_InspectWeapon:setColor(Color.White)
		self.m_WeaponLineColor = false
		self.m_WeaponAlpha = 0
		if self.m_AnimationWeaponFade then 
			self.m_AnimationWeaponFade:stopAnimation()
		end
	end 	
	self.m_InspectWeapon.onLeftClick = function() delete(self) end
	self:adjustWidth()
	self.m_RenderBind = bind(self.forceChange, self)
	addEventHandler("onClientRender", root, self.m_RenderBind)
end

function InspectMenu:forceChange() 
	self:Event_onDraw()
end

function InspectMenu:Event_onDraw() 
	if self.m_Element and isElement(self.m_Element) and isElementStreamedIn(self.m_Element) and self.m_Element:getHealth() ~= 0 then 
		local x,y,z = getElementPosition(self.m_Element)
		if getDistanceBetweenPoints2D(x, y, localPlayer.position.x, localPlayer.position.y) < 4.5 then 
			local bx, by, bz = getPedBonePosition(self.m_Element, 3)
			local cx, cy, z = getCameraMatrix()
			if bx then 
				local prog = (getTickCount() - self.m_AnimationTick) / 800
				if prog > 1 then prog = 1 end
				local easeProg = getEasingValue(prog, "OutBack")
				local alpha = 255*prog
				local sx, sy = getScreenFromWorldPosition(bx, by, bz-.1) 
				if sx then 
					dxSetBlendMode("add") 

					self.m_TreatButton:setAlpha(alpha)
					
					self.m_TreatButton:setPosition(sx+((screenWidth*.07)*easeProg)+2, (sy-screenHeight*.04) - screenHeight*0.0125)
					
					
					dxDrawRectangle(sx+screenWidth*.02,  (sy-screenHeight*.04)-1, screenWidth*.05*easeProg, 4, Color.changeAlpha(Color.Black, alpha))
					dxDrawRectangle(sx+screenWidth*.02,  (sy-screenHeight*.04), screenWidth*.05*easeProg, 2, Color.changeAlpha(Color.White, alpha))
					dxDrawRectangle(sx+((screenWidth*.07)*easeProg), (sy-screenHeight*.04) - screenHeight*0.0125, 2,  screenHeight*0.025, self.m_TreatLineColor and Color.changeAlpha(Color.Red, alpha) or Color.changeAlpha(Color.White, alpha))
					
					dxDrawCircle(sx+screenWidth*.02, (sy-screenHeight*.04)+1, screenWidth*0.01*prog, 0, 360, Color.changeAlpha(Color.White, alpha*(1-prog)))
					dxDrawCircle(sx+screenWidth*.02, (sy-screenHeight*.04)+1, screenWidth*0.002*prog, 0, 360, Color.changeAlpha(Color.White, alpha))

					if self.m_TreatLineColor then
						dxDrawRectangle(sx+((screenWidth*.07)*easeProg)+2 + screenWidth* 0.05, (sy-screenHeight*.04) - screenHeight*0.0125, screenWidth*0.015, screenHeight*0.025, Color.changeAlpha(Color.Red, self.m_TreatAlpha)) 
						dxDrawText("+", (sx+((screenWidth*.07)*easeProg)+2) + screenWidth* 0.05, (sy-screenHeight*.04) - screenHeight*0.0125, (sx+((screenWidth*.07)*easeProg)+2) + (screenWidth* 0.05) + (screenWidth*0.015),  (sy-screenHeight*.04) - screenHeight*0.0125+ screenHeight*0.025, Color.changeAlpha(Color.White, self.m_TreatAlpha), 2, "default-bold", "center", "center") 
					else 
						self.m_TreatButton:setBackgroundColor(Color.Clear)
						self.m_TreatButton:setAlternativeColor(Color.Clear)
					end

					sx, sy = getScreenFromWorldPosition(bx, by, bz-.3) 
					if sx and sy then 
						self.m_InspectWeapon:setAlpha(alpha)
					
						self.m_InspectWeapon:setPosition(sx-((screenWidth*.14)*easeProg), (sy-screenHeight*.04) - screenHeight*0.0125)

						
						dxDrawRectangle(sx-((screenWidth*.09)*easeProg)+2,  (sy-screenHeight*.04)-1, screenWidth*.07*easeProg, 4, Color.changeAlpha(Color.Black, alpha))
						dxDrawRectangle(sx-((screenWidth*.09)*easeProg)+2,  (sy-screenHeight*.04), screenWidth*.07*easeProg, 2, Color.changeAlpha(Color.White, alpha))

						dxDrawRectangle((sx-((screenWidth*.09)*easeProg)), (sy-screenHeight*.04) - screenHeight*0.0125, 2,  screenHeight*0.025, self.m_WeaponLineColor and Color.changeAlpha(Color.DarkBlue, alpha) or Color.changeAlpha(Color.White, alpha))
						
						dxDrawCircle(sx-screenWidth*.02, (sy-screenHeight*.04)+1, screenWidth*0.01*prog, 0, 360, Color.changeAlpha(Color.White, alpha*(1-prog)))
						dxDrawCircle(sx-screenWidth*.02, (sy-screenHeight*.04)+1, screenWidth*0.002*prog, 0, 360, Color.changeAlpha(Color.White, alpha))
						
						if self.m_WeaponLineColor then
							dxDrawRectangle((sx-((screenWidth*.14)*easeProg)) - screenWidth*0.015, (sy-screenHeight*.04) - screenHeight*0.0125, screenWidth*0.015, screenHeight*0.025, Color.changeAlpha(Color.DarkBlue, self.m_WeaponAlpha)) 
							dxDrawText(" !", (sx-((screenWidth*.14)*easeProg)) -  screenWidth*0.015, (sy-screenHeight*.04) - screenHeight*0.0125, (sx-((screenWidth*.14)*easeProg)),  (sy-screenHeight*.04) - screenHeight*0.0125+ screenHeight*0.025, Color.changeAlpha(Color.White, self.m_WeaponAlpha), 1, "default-bold", "center", "center") 
						else 
							self.m_InspectWeapon:setBackgroundColor(Color.Clear)
							self.m_InspectWeapon:setAlternativeColor(Color.Clear)
						end
					else 
						delete(self)
					end
					dxSetBlendMode("blend")  
				else 
					delete(self)
				end
			else 
				delete(self)
			end
		else 
			delete(self)
		end
	else 
		delete(self)
	end
end

function InspectMenu:destructor()
	self.m_TreatButton:delete()
	self.m_InspectWeapon:delete()
	removeEventHandler("onClientRender", root, self.m_RenderBind)
	GUIMouseMenu.destructor(self)
	GUIElement.destructor(self)
end

