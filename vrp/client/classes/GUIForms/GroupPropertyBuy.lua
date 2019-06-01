-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupPropertyBuy.lua
-- *  PURPOSE:     Group creation GUI class
-- *
-- ****************************************************************************
GroupPropertyBuy = inherit(GUIForm)
inherit(Singleton, GroupPropertyBuy)
addRemoteEvents{"GetImmoForSale","ForceClose" }

function GroupPropertyBuy:constructor()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.3/2, screenWidth*0.4, screenHeight*0.3)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Erwerbliche Immobilien", true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.16, self.m_Width*0.98, self.m_Height*0.04, _"Hier kannst du eine Immobilie für deine Firma/Gang erwerben!", self.m_Window):setFont(VRPFont(self.m_Height*0.11)):setMultiline(true)
	self.m_BuyButton = GUIButton:new(self.m_Width*0.1, self.m_Height*0.8, self.m_Width*0.3, self.m_Height*0.15, _"Kaufen", self.m_Window):setBackgroundColor(Color.Green)
	self.m_PreviewButton = GUIButton:new(self.m_Width*0.6, self.m_Height*0.8, self.m_Width*0.3, self.m_Height*0.15, _"Anschauen", self.m_Window):setBackgroundColor(Color.Orange)
	self.m_BuyButton.onLeftClick = bind(self.BuyButton_Click, self)
	self.m_PreviewButton.onLeftClick = bind(self.PreviewButton_Click, self)
	triggerServerEvent("RequestImmoForSale",localPlayer)
	self.m_GetImmoFunc = bind( GroupPropertyBuy.updateList, self)
	self.m_StartPos = {getElementPosition(localPlayer)}
	addEventHandler("GetImmoForSale", localPlayer, self.m_GetImmoFunc)
	self.m_ForceCloseFunc = bind( GroupPropertyBuy.forceClose, self)
	addEventHandler("ForceClose", localPlayer, self.m_ForceCloseFunc)
end

function GroupPropertyBuy:virtual_destructor()
	removeEventHandler("GetImmoForSale", localPlayer, self.m_GetImmoFunc)
	removeEventHandler("ForceClose", localPlayer, self.m_ForceCloseFunc)
	setElementInterior(localPlayer, 5)
	setElementDimension( localPlayer, 0)
	setElementPosition( localPlayer, self.m_StartPos[1],self.m_StartPos[2],self.m_StartPos[3])
	setCameraInterior(5)
	setCameraTarget(localPlayer)
	setTimer(setElementFrozen, 3000,1,localPlayer,false)
end

function GroupPropertyBuy:forceClose()
	delete( GroupPropertyBuy:getSingleton())
end

function GroupPropertyBuy:BuyButton_Click()
	local selected = self.m_ImmoGrid:getSelectedItem()
	if selected then
		if self.m_ImmoTable then
			triggerServerEvent("GroupPropertyBuy",localPlayer, selected.Id)
		end
	else
		ErrorBox:new(_"Du hast keine Immobilie ausgewählt!")
	end
end

function GroupPropertyBuy:PreviewButton_Click()
	if self.m_ImmoGrid then
		local selected = self.m_ImmoGrid:getSelectedItem()
		if self.m_ImmoTable then
			setElementFrozen(localPlayer,true)
			local matrix = self.m_ImmoTable[selected.Id].m_CamMatrix
			local interior = self.m_ImmoTable[selected.Id].m_Interior
			local dimension = self.m_ImmoTable[selected.Id].m_Dimension
			self:setVisible(false)
			setTimer(function() self:setVisible(true) end, 7500, 1)
			setElementInterior(localPlayer, 0)
			setElementDimension(localPlayer, 0)
			setCameraInterior(0)
			setCameraMatrix(matrix[1], matrix[2], matrix[3],matrix[4], matrix[5], matrix[6])
		end
	end
end

function GroupPropertyBuy:updateList( _table )
	self.m_ImmoTable = _table
	outputDebug(_table)
	if _table then
		self.m_ImmoGrid = GUIGridList:new(self.m_Width*0.05, self.m_Height*0.28, self.m_Width*0.9, self.m_Height*0.5, self.m_Window)
		self.m_ImmoGrid:addColumn(_"Verfügbare Immobilien", 1)
		for id, obj in pairs( _table ) do
			if obj.m_OwnerID == 0 then
				item = self.m_ImmoGrid:addItem(obj.m_Price.."$ - "..obj.m_Name)
				item.Id = id
				item.onLeftDoubleClick = function ()  end
			end
		end
	end
end
