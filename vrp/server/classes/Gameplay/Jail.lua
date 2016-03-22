-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Jail.lua
-- *  PURPOSE:     Jail server-side class
-- *
-- ****************************************************************************

Jail = inherit(Singleton)

function Jail:constructor()
	self:createGate(Vector3(162.400390625, 359.2998046875, 7992), 0, Vector3(151.80000305176 , 369.20001220703 , 7983.7998046875), 0)
end

function Jail:createGate(gatePos, gateRot, keypadPos, keypadRot)
	local gate = createObject(2930, gatePos, 0, 0, gateRot)
	local keypad = createObject(2886, keypadPos, 0, 0, keypadRot)
end
