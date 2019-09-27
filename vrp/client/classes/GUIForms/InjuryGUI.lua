-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InjuryGUI.lua
-- *  PURPOSE:     Injury GUI
-- *
-- ****************************************************************************
InjuryGUI = inherit(GUIForm)
inherit(Singleton, InjuryGUI)

InjuryGUI.BodyPartToImage = 
{
	[3] = "m_InjuryTorso", 
	[4] = "m_InjuryPelvis",
	[5] = "m_InjuryArmLeft",
	[6] = "m_InjuryArmRight", 
	[7] = "m_InjuryLegLeft",
	[8] = "m_InjuryLegRight",
	[9] = "m_InjuryHead",
}

function InjuryGUI:constructor(data, player)
	GUIWindow.updateGrid()

	self.m_Width = grid("x", 16) 	
	self.m_Height = grid("y", 11) 	

	self.m_FontScale = screenHeight / 1080
	GUIForm.constructor(self, screenWidth-self.m_Width, screenHeight-self.m_Height*1.5, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, ("%s"):format((player == localPlayer and "Selbstbehandlung") or ("%s"):format(player:getName())), true, true, self)
	
	GUIGridLabel:new(7, 1, 9, 1, "Behandelbare Wunden:", self)
	GUIGridRectangle:new(1, 1, 6, 10, Color.changeAlpha(Color.Black, 150), self)

	self.m_Injury = GUIGridImage:new(2, 2, 4, 8, "files/images/Other/Injury/BodyInjury.png", self)

	self.m_InjuryHead = GUIGridImage:new(2, 2, 4, 8, "files/images/Other/Injury/BodyInjuryHead.png", self)
	self.m_InjuryHead.label =  GUIGridLabel:new(3.3, 1, 3, 1, "", self):setColor(Color.White)

	self.m_InjuryArmLeft = GUIGridImage:new(2, 2, 4, 8, "files/images/Other/Injury/BodyInjuryArmLeft.png", self)
	self.m_InjuryArmLeft.label =  GUIGridLabel:new(1.3, 4, 3, 1, "", self):setColor(Color.White)

	self.m_InjuryArmRight = GUIGridImage:new(2, 2, 4, 8, "files/images/Other/Injury/BodyInjuryArmRight.png", self)
	self.m_InjuryArmRight.label =  GUIGridLabel:new(5.3, 4, 3, 1, "", self):setColor(Color.White)

	self.m_InjuryTorso = GUIGridImage:new(2, 2, 4, 8, "files/images/Other/Injury/BodyInjuryTorso.png", self)
	self.m_InjuryTorso.label =  GUIGridLabel:new(3.3, 3.1, 3, 1, "", self):setColor(Color.Black)
	
	self.m_InjuryPelvis = GUIGridImage:new(2, 2, 4, 8, "files/images/Other/Injury/BodyInjuryPelvis.png", self)
	self.m_InjuryPelvis.label =  GUIGridLabel:new(3.3, 5, 3, 1, "", self):setColor(Color.Black)

	self.m_InjuryLegLeft = GUIGridImage:new(2, 2, 4, 8, "files/images/Other/Injury/BodyInjuryLegLeft.png", self)
	self.m_InjuryLegLeft.label = GUIGridLabel:new(2, 7, 3, 1, "", self):setColor(Color.White)

	self.m_InjuryLegRight = GUIGridImage:new(2, 2, 4, 8, "files/images/Other/Injury/BodyInjuryLegRight.png", self)
	self.m_InjuryLegRight.label =  GUIGridLabel:new(5, 7, 3, 1, "", self):setColor(Color.White)
	
	self.m_Grid = GUIGridGridList:new(7, 2, 9, 8, self)
	self.m_Grid:addColumn("Wunde", 0.4)
	self.m_Grid:addColumn("Körperteil", 0.3)
	self.m_Grid:addColumn("×", 0.1)
	self.m_Grid:addColumn("✘", 0.1)
	self.m_TreatButton = GUIGridButton:new(7, 10, 9, 1, "Behandeln", self)
	self.m_TreatButton.onLeftClick = bind(self.Event_OnClick, self)
	
	self.m_EstimatedTime = GUIGridLabel:new(2, 10, 4, 1, "", self):setFont(VRPFont(22*self.m_FontScale))

	self.m_Player = player

	self.m_Marked = {}
	self:process(data)
end

function InjuryGUI:process(data)
	self.m_Injuries = {}
	for id, subdata in pairs(data) do 
		local bodypart, weapon, amount = unpack(subdata)
		local damageText = INJURY_WEAPON_TO_CAUSE[weapon] or "Unbekannt"

		if not self.m_Injuries[bodypart] then self.m_Injuries[bodypart] = {} end
		if not self.m_Injuries[bodypart][damageText] then 
			self.m_Injuries[bodypart][damageText]  = 0 
		end
		self.m_Injuries[bodypart][damageText]  = self.m_Injuries[bodypart][damageText] + 1
		self[InjuryGUI.BodyPartToImage[bodypart]].label:setText(("%s×"):format(self:getBodyPartCount(bodypart)))
		self[InjuryGUI.BodyPartToImage[bodypart]]:setColor(self:getColorFromCount(self:getBodyPartCount(bodypart)))
	end

	for bpart, dam in pairs(self.m_Injuries) do 
		for text, count in pairs(self.m_Injuries[bpart]) do 
			local item = self.m_Grid:addItem(text, BODYPART_NAMES[bpart], count, "")
			item:setColumnFont(1, VRPFont(20*self.m_FontScale), 1)
			item.text = text
			item.bodypart = bpart 
			item.count = count
			item.onLeftDoubleClick = function() self:onSelectItem(item) end
		end
	end
end

function InjuryGUI:onSelectItem(item) 
	if self.m_Marked[item] then
		item:setColumnText(4, "")
		self.m_Marked[item] = nil
	else 
		item:setColumnText(4, "✘")
		self.m_Marked[item] = true
	end
	self:calculateTreatment()
end

function InjuryGUI:Event_OnClick() 
	triggerServerEvent("Damage:onTryTreat", localPlayer, self.m_Player, self:prepareData())
end

function InjuryGUI:prepareData() 
	local send = {}
	for item, b in pairs(self.m_Marked) do 
		send[#send+1] = {text = item.text, bodypart = item.bodypart, count = item.count}
	end
	return send
end

function InjuryGUI:calculateTreatment() 
	local timeCount = 0
	for item, b in pairs(self.m_Marked) do 
		local partTime = TIME_FOR_TREAT_BODYPART[item.bodypart] or 1 
		local damageTime = TIME_FOR_TREAT_DAMAGE[item.text] or 1 
		timeCount = timeCount + (partTime*(damageTime*item.count))
	end
	self.m_EstimatedTime:setText(("Behandlungszeit: %ss"):format(math.ceil(timeCount)))
end

function InjuryGUI:getBodyPartCount(bodypart) 
	local count = 0
	for b, data in pairs(self.m_Injuries) do 
		if b == bodypart then
			for damageText, damCount in pairs(self.m_Injuries[b]) do 
				count = count + damCount
			end
		end
	end
	return count
end

function InjuryGUI:destructor()
	GUIForm.destructor(self)
end

function InjuryGUI:getColorFromCount(count) 
	if count > 0 then 
		if count < 7 then
			local color = tocolor(255, 255 - (count/6)*255, 255 - (count/6)*255)
			return color
		else 
			local color = tocolor(255, 0, 0)
			return color
		end 
	else
		return tocolor(255, 255, 255)
	end
end

addEvent("Damage:sendPlayerDamage", true)
addEventHandler("Damage:sendPlayerDamage", localPlayer, function(data, player)
	if InjuryGUI:isInstantiated() then 
		delete(InjuryGUI:getSingleton())
	end
	InjuryGUI:new(data, player)
end)

