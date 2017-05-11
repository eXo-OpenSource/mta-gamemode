-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StateEvidenceGUI.lua
-- *  PURPOSE:     StateEvidenceGUI class
-- *
-- ****************************************************************************
StateEvidenceGUI = inherit(GUIForm)
inherit(Singleton, StateEvidenceGUI)

addRemoteEvents{"State:sendEvidenceItems","State:clearEvidenceItems"}
function StateEvidenceGUI:constructor( evidenceTable )
	GUIForm.constructor(self, screenWidth/2-(500/2), screenHeight/2-(370/2), 500, 370)
	self.m_Window = GUIWindow:new(0,0,500,370,_"Asservatenkammer",true,true,self)

	self.m_List = GUIGridList:new(30, 50, self.m_Width-60, 270, self.m_Window)
	self.m_List:addColumn(_"Objekt", 0.2)
	self.m_List:addColumn(_"Menge", 0.05)
	self.m_List:addColumn(_"Besitzer", 0.25)
	self.m_List:addColumn(_"Konfeszierender", 0.25)
	self.m_List:addColumn(_"Datum", 0.25)
	self.m_EvidenceTable = evidenceTable

--[[
	self.m_mitKaution = GUIButton:new(30, 265, self.m_Width-60, 35,_"mit Kaution einknasten", self.m_Window)
	self.m_mitKaution:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_mitKaution.onLeftClick = bind(self.factionArrestMitKaution,self)
]]

	self:refreshGrid()
	self.m_DestroyEvidenceButton= GUIButton:new( (self.m_Width/2) - 70, 330, 140, 30, FontAwesomeSymbols.Refresh, self.m_Window):setFont(FontAwesome(15))
	self.m_DestroyEvidenceButton.onLeftClick = function ()
		triggerServerEvent("State:onRequestEvidenceDestroy", localPlayer)
	end
end

function StateEvidenceGUI:clearList()
	self.m_EvidenceTable = {}
	self.m_List:clear()
end

function StateEvidenceGUI:refreshGrid()
	self.m_List:clear()
	local type_, var1, var2, var3, cop, timeStamp
	local item
	for key,evidenceItems in ipairs(self.m_EvidenceTable) do
		type_, var1, var2, var3, cop, timeStamp = evidenceItems[1], evidenceItems[2], evidenceItems[3], evidenceItems[4], evidenceItems[5], evidenceItems[6]
		if var1 then
			if type_ == "Waffe" then var1 = getWeaponNameFromID(var1) or "Unbekannt"end
			item = self.m_List:addItem(var1 or "Unbekannt", var2 or 1, var3 or "Unbekannt", cop or "Unbekannt", self:getOpticalTimestamp(timeStamp or getRealTime().timestamp)) 
			item.onLeftClick = function() end
		end
	end
end

function StateEvidenceGUI:getOpticalTimestamp(ts)
	if type(ts) == "string" then tonumber(ts) end
	local time = getRealTime(ts)
	local month = time.month+1
	local year = time.year-100
	return tostring(time.monthday.."."..month.."."..year.."-"..time.hour..":"..time.minute)
end

addEventHandler("State:sendEvidenceItems", root,
		function( ev )
			StateEvidenceGUI:new( ev )
		end
	)

addEventHandler("State:clearEvidenceItems", root,
	function( )
		if StateEvidenceGUI:isInstantiated() then
			StateEvidenceGUI:getSingleton():clearList()
		end
	end
)