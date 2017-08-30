-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
VehicleFuel = inherit(GUIForm3D)
inherit(Singleton, VehicleFuel)
addRemoteEvents{"forceCloseVehicleFuel"}

function VehicleFuel:constructor(vehicle, confirmCallback, confirmWithSpace, gasStation)
	self.m_Fuel = 0
	self.m_MouseDown = false
	self.m_Vehicle = vehicle
	self.m_GasStation = gasStation
	self.m_ConfirmCallback = confirmCallback
	self.m_ConfirmWithSpace = confirmWithSpace

	self.m_FuelProgress = CAnimation:new(self, "m_Fuel")

	self.m_HandleClick = bind(VehicleFuel.handleClick, self)
	self.m_Confirm = bind(VehicleFuel.confirm, self)

	local pos = vehicle:getPosition()
	pos.z = pos.z + 1.5
	GUIForm3D.constructor(self, pos, vehicle:getRotation(), Vector2(1, 0.34), Vector2(200,70), 30, true)
	ShortMessage:new(_("Linke Maustaste gedrückt halten zum tanken%s", confirmWithSpace and "\nLeertaste zum übernehmen" or ""), "Fahrzeug befüllen", {230, 100, 0})

	bindKey("mouse1", "both", self.m_HandleClick)
	if confirmWithSpace then bindKey("space", "down", self.m_Confirm) end
end

function VehicleFuel:virtual_destructor()
	if not self.m_ConfirmWithSpace then self:confirm() end
	unbindKey("space", "down", self.m_Confirm)
	unbindKey("mouse1", "both", self.m_HandleClick)
end

function VehicleFuel:confirm()
	if self.m_Fuel > 0 then
		if self.m_ConfirmCallback then self.m_ConfirmCallback(self.m_Vehicle, self.m_Fuel, self.m_GasStation) end
	end
end

function VehicleFuel:handleClick(_, state)
	if isCursorShowing() then return end
	setPedControlState("fire", false)
	toggleControl("fire", false)
	if localPlayer.vehicle then return end

	self.m_MouseDown = state == "down"

	if self.m_MouseDown then
		if localPlayer:getWorldVehicle() ~= self.m_Vehicle then return end
		if self.m_Vehicle:getData("syncEngine") then WarningBox:new("Bitte schalte den Motor aus!") return end

		self.m_FuelProgress:startAnimation(15000 - self.m_Fuel*150, "Linear", 100)
		toggleAllControls(false, true, false)
	else
		self.m_FuelProgress:stopAnimation()
		toggleAllControls(true, true, false)
	end
end

function VehicleFuel:onStreamIn(surface)
	GUIImage:new(0, 0, 128, 128, "files/images/Speedo/fuel.png", surface)
	self.m_Needle = GUIImage:new(0, 0, 128, 128, "files/images/Speedo/fuel_needle.png", surface)
	self.m_Needle.m_Rotation = self.m_Fuel
	self.m_Surface = surface
end

function VehicleFuel:updateRenderTarget()
	if not self.m_Needle then return end
	self.m_Needle.m_Rotation = self.m_Fuel*180/100
	self.m_Surface:anyChange()
end

function VehicleFuel.forceClose()
	if VehicleFuel:isInstantiated() then
		delete(VehicleFuel:getSingleton())
	end
end
addEventHandler("forceCloseVehicleFuel", root, VehicleFuel.forceClose)
