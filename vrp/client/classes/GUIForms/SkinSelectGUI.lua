-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SkinSelectGUI.lua
-- *  PURPOSE:     GUI label class
-- *
-- ****************************************************************************
SkinSelectGUI = inherit(GUIForm)
inherit(Singleton, SkinSelectGUI)
addRemoteEvents{"openSkinSelectGUI"}
local images_per_row = 5
--[[
	skinTable = { skinId1, skinId2}
	allSkins = {[skinId1] = rank, [skinId2] = rank2}
]]

function SkinSelectGUI:constructor(skinTable, groupId, groupType, editable, allSkins)
	
	local skin_count = skinTable and type(skinTable) == "table" and table.size(skinTable) or 0
	local areaHeight = math.min(math.ceil(skin_count/5)*5, 10)
	self.m_SkinCount = skin_count
	self.m_SkinTableEdit = skinTable -- this table gets used to edit the available skins (with special skin)
	self.m_SkinTable = {} -- this table gets used to select the skins (without special skin)
	for i, v in pairs(skinTable) do
		if allSkins[v] ~= -1 then table.insert(self.m_SkinTable, v) end
	end
	self.m_AllSkins = allSkins
	self.m_SkinsEditable = editable -- boolean
	self.m_GroupId = groupId
	self.m_GroupType = groupType
	GUIWindow.updateGrid()		
	self.m_Width = grid("x", 16) 	
	self.m_Height = grid("y", areaHeight + 1) 


	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kleidungs-Auswahl", true, true, self)
	if editable then
		self.m_Window:addTitlebarButton(FontAwesomeSymbols.Cogs, bind(SkinSelectGUI.setEditable, self))
	end
	self.m_ScrollableArea = GUIGridScrollableArea:new(1, 1, 15, areaHeight, 15, 0 , true, false, self.m_Window, 1)
	
	self:loadSkins()
end

function SkinSelectGUI:loadSkins()
	local row = 0
	local i = 1
	local skin_count = table.size(self.m_Edit and self.m_SkinTableEdit or self.m_SkinTable)

	self.m_ScrollableArea:clear()
	self.m_ScrollableArea:resize(15, math.ceil(skin_count/5)*5)
	self.m_ScrollableArea:updateGrid()
	self.m_SkinUpdateTimer = setTimer(function()
		local skinId = self.m_Edit and self.m_SkinTableEdit[i] or self.m_SkinTable[i] 
		local x, y, w, h = (i-1)*3 + 1 - row*images_per_row*3, row*images_per_row + 1, 3, 5
		
		local image = GUIGridWebView:new(x, y, w, h, INGAME_WEB_PATH .. "/ingame/skinPreview/skinPreview.php?skin="..skinId, true, self.m_ScrollableArea)
		image.onDocumentReady = function()
			nextframe(function()
				image:setRenderingEnabled(false)
				image:setControlsEnabled(false)
			end)
		end
		image.onLeftClick = function()	
			if self.m_Edit then return false end
			if self.m_GroupType == "faction" then
				triggerServerEvent("factionPlayerSelectSkin", localPlayer, skinId)
				core:set("Cache", "LastFactionSkin", skinId)
			elseif self.m_GroupType == "company" then
				triggerServerEvent("companyPlayerSelectSkin", localPlayer, skinId)
				core:set("Cache", "LastCompanySkin", skinId)
			end
		end
		if self.m_Edit then
			local changer = GUIGridChanger:new(x, y + h - 1, w, 1, self.m_ScrollableArea)
			for i = 0, (self.m_GroupType == "company" and 5 or 6) do	
				changer:addItem("Rang "..i)
			end
			if self.m_GroupType == "faction" then
				changer:addItem("Spezial")
			end
			if self.m_AllSkins[skinId] == -1 then --special skin
				changer:setIndex(#changer.m_Items, true)
			else
				changer:setIndex(self.m_AllSkins[skinId] + 1, true)
			end
			changer.onChange = function(item, index)
				if index == #changer.m_Items and self.m_GroupType == "faction" then  --special skin
					self.m_AllSkins[skinId] = -1
				else
					self.m_AllSkins[skinId] = index - 1
				end
			end
		else
			GUIGridLabel:new(x, y + h - 1, w, 1, "Skin "..skinId, self.m_ScrollableArea):setAlignX("center")
		end
		if i % images_per_row == 0 then row = row + 1 end
		i = i + 1
	end, 50, skin_count)
end

function SkinSelectGUI:setEditable()
	if isTimer(self.m_SkinUpdateTimer) then return end
	if self.m_Edit then -- perform checks if changes are valid
		local specials = 0
		local rank0s = 0
		for i,v in pairs(self.m_AllSkins) do
			if v == -1 then specials = specials + 1 end
			if v == 0 then rank0s = rank0s + 1 end
		end
		if self.m_GroupType == "faction" then
			--if specials < 1 then return ErrorBox:new(_"Es muss mindestens eine Spezialkleidung ausgewählt werden.") end
			if specials > 1 then return ErrorBox:new(_"Es darf maximal eine Spezialkleidung ausgewählt werden.") end
		end
		if rank0s < 1 then return ErrorBox:new(_"Es muss mindestens eine Kleidung für Rang 0 festgelegt werden.") end
		if self.m_GroupType == "faction" then
			triggerServerEvent("factionUpdateSkinPermissions", localPlayer, self.m_AllSkins)
		elseif self.m_GroupType == "company" then
			triggerServerEvent("companyUpdateSkinPermissions", localPlayer, self.m_AllSkins)
		end
		self.m_Edit = false --skins get reloaded as gui gets rebuilt
	else 
		self.m_Edit = true
		self:loadSkins()
	end
	
end

function SkinSelectGUI:destructor()
	if isTimer(self.m_SkinUpdateTimer) then
		killTimer(self.m_SkinUpdateTimer)
	end
	if self.m_Edit then
		ErrorBox:new(_"Einstellungen wurden nicht gespeichert (Bitte zuerst Edit-Modus beenden)!")
	end
	GUIForm.destructor(self)
end


function SkinSelectGUI.open(skinTable, groupId, groupType, editable, allSkins)
	if SkinSelectGUI:isInstantiated() then
		delete(SkinSelectGUI:getSingleton())
	end
	SkinSelectGUI:new(skinTable, groupId, groupType, editable, allSkins)
end
addEventHandler("openSkinSelectGUI", root, SkinSelectGUI.open)
