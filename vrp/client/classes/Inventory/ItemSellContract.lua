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
