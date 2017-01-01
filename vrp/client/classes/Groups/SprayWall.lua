-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/SprayWall.lua
-- *  PURPOSE:     Spray Wall class
-- *
-- ****************************************************************************
SprayWall = inherit(Object)

function SprayWall:constructor(Id, wallPosition, rotation)
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
	self.m_SprayWallShape = getElementByID("SprayWall"..Id)


	self.m_SprayFunc =
		function(weapon,ammo,clip,hitX,hitY, hitZ,element,startX,startY,startZ)
			if weapon == 41 then
				self:spray(hitX,hitY,hitZ,startX,startY,startZ)
			end
		end

	addEventHandler("onClientColShapeHit", self.m_Shape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				if hitElement:getGroupType() == "Gang" then
					InfoBox:new(_"Du kannst diese Wand mit der Spraydose besprühen!")
				end
				self:setTagText(localPlayer:getGroupName())
				addEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_SprayFunc)
			end
		end
	)
	addEventHandler("onClientColShapeLeave", self.m_Shape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				removeEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_SprayFunc)
				if self.m_IsSpraying then
					self:refresh()
				end
				self.m_IsSpraying = false
			end
		end
	)


	-- Streaming funcs
	addEventHandler("onClientColShapeHit", self.m_SprayWallShape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				outputChatBox("spray StreamIn "..Id)
				self:createTextures()
				self:refresh()
				addEventHandler("onClientRender", root, self.m_RenderTagFunc)
			end
		end
	)
	addEventHandler("onClientColShapeLeave", self.m_SprayWallShape,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
								outputChatBox("spray StreamOut")

				self:destroyTextures()
				removeEventHandler("onClientRender", root, self.m_RenderTagFunc)
			end
		end
	)

	addEventHandler("onClientElementDataChange", SprayWallShape, function(dataName)
		if dataName == "OwnerName" then
			self:refresh()
		end
	end)

	addEventHandler("onClientRestore", root,
		function(didClearRenderTargets)
			if didClearRenderTargets then
				if localPlayer:isWithinColShape(self.m_SprayWallShape) then
					outputDebug("Recreating tag textures")
					self:renderTagTexture()
				end
			end
		end
	)
end

function SprayWall:destructor()
	destroyElement(self.m_Wall)
	destroyElement(self.m_Shape)
	self:destroyTextures()
end

function SprayWall:refresh()
	local text = getElementData(self.m_SprayWallShape, "OwnerName") or ""
	self.m_OldTagText = text
	self.m_TagText = text
	self:setTagInstantly(text)
end

function SprayWall:spray(hitX, hitY, hitZ, startX, startY, startZ)
	if localPlayer:getGroupName() then -- does the player have a group?
		if self.m_TagText ~= localPlayer:getGroupName() then -- is its already its own?
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
				if self.m_IsSpraying then
					triggerServerEvent("sprayWallTagSprayed", root, self.m_Id)
					self.m_IsSpraying = false
				end
			end
		else
			InfoBox:new(_"Diese Wand ist bereits mit eurem Ganglogo besprayt!")
			removeEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_SprayFunc)
		end
	end
end

function SprayWall:resetTag(restoreOld)
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

function SprayWall:renderTagTexture()
	-- Render the text to the texture
	dxSetRenderTarget(self.m_TagSectionTexture, true)
		--dxDrawRectangle(0, 0, 128, 128, Color.Yellow)
		dxDrawText(self.m_TagText, 5, 5, 128-5*2, 128-5*2, Color.Red, 1, SprayWallManager:getSingleton():getFont(), "center", "center", false, true)
		dxSetRenderTarget(nil)

		-- Next, render the text as section to the actual tag texture
		dxSetRenderTarget(self.m_TagTexture, true)
		dxDrawText(self.m_OldTagText, 5, 5, 128-5*2, 128-5*2, Color.White, 1, SprayWallManager:getSingleton():getFont(), "center", "center", false, true)
		dxDrawImageSection(0, 0, 128, math.floor(self.m_TagProgress), 0, 0, 128, math.floor(self.m_TagProgress), self.m_TagSectionTexture)
	dxSetRenderTarget(nil)
end

function SprayWall:setTagText(text)
	self.m_OldTagText = self.m_TagText
	self.m_TagText = text
end

function SprayWall:setTagInstantly(text)
	self:setTagText(text)
	self.m_TagProgress = 128

	if self.m_TagSectionTexture and self.m_TagTexture then
		self:renderTagTexture()
	end
end

function SprayWall:renderTag()
	local tagStartX, tagStartY, tagStartZ = getPositionFromElementOffset(self.m_Wall, 1.1, 0, 1.1)
	local tagEndX, tagEndY, tagEndZ = getPositionFromElementOffset(self.m_Wall, 1.1, 0, 1.1-2)
	local normalX, normalY, normalZ = getPositionFromElementOffset(self.m_Wall, 3, 0, 0)
	dxDrawMaterialLine3D(tagStartX, tagStartY, tagStartZ, tagEndX, tagEndY, tagEndZ, self.m_TagTexture, 2, Color.White, normalX, normalY, normalZ)
end

function SprayWall:createTextures()
	if not self.m_TagTexture and not self.m_TagSectionTexture then
		self.m_TagTexture = dxCreateRenderTarget(128, 128, true)
		self.m_TagSectionTexture = dxCreateRenderTarget(128, 128, true)
		self:renderTagTexture()
	end
end

function SprayWall:destroyTextures()
	if self.m_TagTexture and self.m_TagSectionTexture then
		destroyElement(self.m_TagTexture)
		destroyElement(self.m_TagSectionTexture)
		self.m_TagTexture = nil
		self.m_TagSectionTexture = nil
	end
end

