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
	self.m_Wall = createObject(7921, wallPosition.x, wallPosition.y, wallPosition.z, 0, 0, rotation)
	self.m_Shape = createColSphere(wallPosition.x, wallPosition.y, wallPosition.z, 5)
	self.m_TagTexture = nil
	self.m_TagSectionTexture = nil
	self.m_TagProgress = 128
	self.m_IsSpraying = false
	self.m_TagText = ""
	self.m_OldTagText = ""
	self.m_RenderTagFunc = bind(self.renderTag, self)
	self.m_TurfingInProgress = false
	
	local funcSpray = function(weapon,ammo,clip,hitX,hitY, hitZ,element,startX,startY,startZ) if weapon == 41 then self:spray(hitX,hitY,hitZ,startX,startY,startZ) end end
	addEventHandler("onClientColShapeHit", self.m_Shape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				self.m_IsSpraying = false
				self:setTagText(localPlayer:getGroupName())
				addEventHandler("onClientPlayerWeaponFire", localPlayer, funcSpray)
			end
		end
	)
	addEventHandler("onClientColShapeLeave", self.m_Shape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				removeEventHandler("onClientPlayerWeaponFire", localPlayer, funcSpray)
				self.m_IsSpraying = false
				
				if not self.m_TurfingInProgress then
					self:resetTag(true)
				end
			end
		end
	)
	
	-- Streaming funcs
	local gangAreaShape = getElementByID("GangArea"..Id)
	addEventHandler("onClientColShapeHit", gangAreaShape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				self:setTagText(getElementData(gangAreaShape, "OwnerName") or "")
				
				self:createTextures()
				addEventHandler("onClientRender", root, self.m_RenderTagFunc)
			end
		end
	)
	addEventHandler("onClientColShapeLeave", gangAreaShape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				self:destroyTextures()
				removeEventHandler("onClientRender", root, self.m_RenderTagFunc)
			end
		end
	)
end

function GangArea:destructor()
	destroyElement(self.m_Wall)
	destroyElement(self.m_Shape)
	self:destroyTextures()
end

function GangArea:spray(hitX, hitY, hitZ, startX, startY, startZ)
	self:createTextures()

	if not self.m_IsSpraying then
		self.m_TagProgress = 0
	end

	if self.m_TagProgress < 128 then
		self.m_TagProgress = self.m_TagProgress + 0.5
		self:renderTagTexture()
		self.m_IsSpraying = true
	else
		self.m_TagProgress = 128
		if self.m_IsSpraying and not self.m_TurfingInProgress then
			triggerServerEvent("gangAreaTagSprayed", root, self.m_Id)
			self.m_IsSpraying = false
		end
	end
end

function GangArea:resetTag(restoreOld)
	self.m_TagProgress = 0
	
	if restoreOld then
		self.m_TagText = self.m_OldTagText
		self.m_OldTagText = ""
		self.m_TagProgress = 128
	end
	if self.m_TagTexture then
		self:renderTagTexture()
	end
end

function GangArea:renderTagTexture()
	-- Render the text to the texture
	dxSetRenderTarget(self.m_TagSectionTexture, true)
	--dxDrawRectangle(0, 0, 128, 128, Color.Yellow)
	dxDrawText(self.m_TagText, 5, 5, 128-5*2, 128-5*2, Color.White, 1, GangAreaManager:getSingleton():getFont(), "center", "center", false, true)
	dxSetRenderTarget(nil)

	-- Next, render the text as section to the actual tag texture
	dxSetRenderTarget(self.m_TagTexture, true)
	dxDrawText(self.m_OldTagText, 5, 5, 128-5*2, 128-5*2, Color.White, 1, GangAreaManager:getSingleton():getFont(), "center", "center", false, true)
	dxDrawImageSection(0, 0, 128, math.floor(self.m_TagProgress), 0, 0, 128, math.floor(self.m_TagProgress), self.m_TagSectionTexture)
	dxSetRenderTarget(nil)
end

function GangArea:setTagText(text)
	self.m_OldTagText = self.m_TagText
	self.m_TagText = text
end

function GangArea:setTagInstantly(text)
	self:setTagText(text)
	self.m_TagProgress = 128
	
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

function GangArea:createTextures()
	if not self.m_TagTexture and not self.m_TagSectionTexture then
		self.m_TagTexture = dxCreateRenderTarget(128, 128, true)
		self.m_TagSectionTexture = dxCreateRenderTarget(128, 128, true)
		self:renderTagTexture()
	end
end

function GangArea:destroyTextures()
	if self.m_TagTexture and self.m_TagSectionTexture then
		destroyElement(self.m_TagTexture)
		destroyElement(self.m_TagSectionTexture)
		self.m_TagTexture = nil
		self.m_TagSectionTexture = nil
	end
end

function GangArea:isTurfingInProgress()
	return self.m_TurfingInProgress
end

function GangArea:setIsTurfingInProgress(t)
	self.m_TurfingInProgress = t
end
