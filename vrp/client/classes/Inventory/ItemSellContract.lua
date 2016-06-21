-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/ItemSellContract.lua
-- *  PURPOSE:     SellContract Client Item Class
-- *
-- ****************************************************************************
ItemSellContract = inherit( Object )

addRemoteEvents{"vehicleConfirmSell","vehicleStartSell","closeVehicleContract","closeVehicleAccept"}

function ItemSellContract:constructor() 
	self.m_Func = function( ts ) self:initSellGUI( ts ) end
	addEventHandler("vehicleStartSell", localPlayer,  self.m_Func)
	addEventHandler("vehicleConfirmSell", localPlayer,  bind(self.Event_ConfirmSell, self ))
	addEventHandler("closeVehicleContract", localPlayer,  bind(self.Event_CloseTrade, self ))
	addEventHandler("closeVehicleAccept", localPlayer,  bind(self.Event_CloseAccept, self ))
	self.m_DMVSeller = createPed( 17, 808.28339, 4233.49902, 15.7443)
	setElementInterior( self.m_DMVSeller, 1,  808.28339, 4233.49902, 15.7443)
	setElementFrozen( self.m_DMVSeller , true )
	addEventHandler("onClientPedDamage",self.m_DMVSeller, cancelEvent)
	addEventHandler("onClientClick",root, bind( self.Event_Click, self ))
	setElementRotation( self.m_DMVSeller, 0,0,-160)
end

function ItemSellContract:Event_Click( b ,s, _, _, _, _, _, cW ) 
	if cW == self.m_DMVSeller then 
		if VehicleTransactionPapersGUI:isInstantiated() then delete( VehicleTransactionPapersGUI:getSingleton() ) end
		VehicleTransactionPapersGUI:new( )
	end
end

function ItemSellContract:Event_CloseTrade( ) 
	if VehicleSellGUI:isInstantiated() then delete( VehicleSellGUI:getSingleton() ) end
end

function ItemSellContract:Event_CloseAccept( ) 
	if VehicleSellAcceptGUI:isInstantiated() then delete( VehicleSellAcceptGUI:getSingleton() ) end
end

function ItemSellContract:Event_ConfirmSell( player, price, car, player2)
	if VehicleSellAcceptGUI:isInstantiated() then return end
	VehicleSellAcceptGUI:getSingleton( player2, price, car )
end
function ItemSellContract:initSellGUI( timestamp )
	local veh = getPedOccupiedVehicle( localPlayer )
	if veh then
		if VehicleSellGUI:isInstantiated() then delete( VehicleSellGUI:getSingleton() ) end
		VehicleSellGUI:getSingleton( timestamp or {0,0,0}, veh ):new( timestamp or {0,0,0}, veh)
	end
end
