-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GangArea.lua
-- *  PURPOSE:     Gang area (turfing) class
-- *
-- ****************************************************************************
GangArea = inherit(Object)

function GangArea:constructor(Id, wallPosition, rotation, areaPosition, width, height)
	self.m_Id = Id
	self.m_Wall = createObject(7921, wallPosition.X, wallPosition.Y, wallPosition.Z, 0, 0, rotation)
	self.m_Shape = createColSphere(wallPosition.X, wallPosition.Y, wallPosition.Z, 5)
	self.m_TagTexture = false
	self.m_TagSectionTexture = false
	--dxSetTextureEdge(self.m_TagTexture, "border")
	self.m_TagProgress = 128
	self.m_TagSprayedEntirely = false
	self.m_TagText = ""
	self.m_RenderTagFunc = bind(self.renderTag, self)
	self.m_TurfingInProgress = false
	
	local funcSpray = function(weapon,ammo,clip,hitX,hitY, hitZ,element,startX,startY,startZ) if weapon == 41 then self:spray(hitX,hitY,hitZ,startX,startY,startZ) end end
	addEventHandler("onClientColShapeHit", self.m_Shape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				self:setTagText(getElementData(localPlayer, "GroupName"))
				addEventHandler("onClientPlayerWeaponFire", localPlayer, funcSpray)
			end
		end
	)
	addEventHandler("onClientColShapeLeave", self.m_Shape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				removeEventHandler("onClientPlayerWeaponFire", localPlayer, funcSpray)
			end
		end
	)
	
	-- Streaming funcs
	local gangAreaShape = getElementByID("GangArea"..Id)
	addEventHandler("onClientColShapeHit", gangAreaShape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				if not self.m_TurfingInProgress then
					self:setTagText(getElementData(gangAreaShape, "OwnerName"))
				end
				
				if not self.m_TagTexture and not self.m_TagSectionTexture then
					self.m_TagTexture = dxCreateRenderTarget(128, 128, true)
					self.m_TagSectionTexture = dxCreateRenderTarget(128, 128, true)
					self:renderTagTexture()
				end
				addEventHandler("onClientRender", root, self.m_RenderTagFunc)
			end
		end
	)
	addEventHandler("onClientColShapeLeave", gangAreaShape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				if self.m_TagTexture and self.m_TagSectionTexture then
					destroyElement(self.m_TagTexture)
					destroyElement(self.m_TagSectionTexture)
					self.m_TagTexture = nil
					self.m_TagSectionTexture = nil
				end
				removeEventHandler("onClientRender", root, self.m_RenderTagFunc)
			end
		end
	)
end

function GangArea:destructor()
	destroyElement(self.m_Wall)
	destroyElement(self.m_Shape)
	if self.m_TagTexture and self.m_TagSectionTexture then
		destroyElement(self.m_TagTexture)
		destroyElement(self.m_TagSectionTexture)
	end
end

function GangArea:spray(hitX, hitY, hitZ, startX, startY, startZ)
	if self.m_TagProgress < 128 then
		self.m_TagProgress = self.m_TagProgress + 0.5
		self:renderTagTexture()
	else
		if not self.m_TagSprayedEntirely then
			triggerServerEvent("gangAreaTagSprayed", root, self.m_Id)
			self.m_TagSprayedEntirely = true
		end
	end
end

function GangArea:resetTag()
	self.m_TagProgress = 0
	self.m_TagSprayedEntirely = false
end

function GangArea:renderTagTexture()
	outputDebug("GangArea:renderTagTexture()")
	
	-- Render the text to the texture
	dxSetRenderTarget(self.m_TagSectionTexture, true)
	--dxDrawRectangle(0, 0, 128, 128, Color.Yellow)
	dxDrawText(self.m_TagText, 5, 5, 128-5*2, 128-5*2, Color.White, 1, GangAreaManager:getSingleton():getFont(), "center", "center", false, true)
	dxSetRenderTarget(nil)

	-- Next, render the text as section to the actual tag texture
	dxSetRenderTarget(self.m_TagTexture, true)
	dxDrawImageSection(0, 0, 128, math.floor(self.m_TagProgress), 0, 0, 128, math.floor(self.m_TagProgress), self.m_TagSectionTexture)
	dxSetRenderTarget(nil)
end

function GangArea:setTagText(text)
	self.m_TagText = text
end

function GangArea:setTagInstantly(text)
	self:setTagText(text)
	self.m_TagProgress = 128
	self.m_TagSprayedEntirely = true
	
	if self.m_TagSectionTexture and self.m_TagTexture then
		self:renderTagTexture()
	end
end

function GangArea:renderTag()
	local tagStartX, tagStartY, tagStartZ = getPositionFromElementOffset(self.m_Wall, 1.1, 0, 1.1)
	local tagEndX, tagEndY, tagEndZ = getPositionFromElementOffset(self.m_Wall, 1.1, 0, 1.1-2)
	local normalX, normalY, normalZ = getPositionFromElementOffset(self.m_Wall, 3, 0, 0)
	dxDrawMaterialLine3D(tagStartX, tagStartY, tagStartZ, tagEndX, tagEndY, tagEndZ, self.m_TagTexture, 2, Color.White, normalX, normalY, normalZ)
end

function GangArea:isTurfingInProgress()
	return self.m_TurfingInProgress
end

function GangArea:setIsTurfingInProgress(t)
	self.m_TurfingInProgress = t
end
