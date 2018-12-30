ExecutionPed = inherit(Object)
ExecutionPed.Map = {}

local AnimationTable = 
{
{"crack","crckidle1"},
{"wuzi","cs_dead_guy"},
}

function ExecutionPed:constructor( player, weapon, bodypart )
	if ExecutionPed.Map[player] then delete(ExecutionPed.Map[player]) end
	outputDebug(player:getFaction() and not player:getFaction():isEvilFaction() and player:isFactionDuty())
	player:setReviveWeapons(player:getFaction() and not player:getFaction():isEvilFaction() and player:isFactionDuty())
	local pos = player:getPosition()
	local dim = player:getDimension()
	local int = player:getInterior()
	local rx, ry, rz = getElementRotation( player )
	self.m_Entity = createPed(source:getModel(), pos)
	self.m_Entity:setDimension(dim)
	self.m_Entity:setInterior(int)
	setElementRotation(self.m_Entity, rx, ry, rz)
	if bodypart == 9 then
		setPedHeadless(self.m_Entity, true)
	end
	setElementData(self.m_Entity, "NPC:namePed", getPlayerName(source))
	setElementData(self.m_Entity, "NPC:isDyingPed", true)
	setElementHealth(self.m_Entity, 20)
	self.m_Entity.m_ExecutedPlayer = player
	self.m_Player = player
	setElementAlpha(player, 0)
	setElementCollisionsEnabled(player, false)
	self:setRandomAnimation()
	ExecutionPed.Map[player] = self
end

function ExecutionPed:setRandomAnimation() 
	local randomAnimation = math.random(1, #AnimationTable) 
	local block, anim = unpack(AnimationTable[randomAnimation])
	setPedAnimation( self.m_Entity, block, anim, -1, true, false, false, true)
end

function ExecutionPed:putOnStretcher( stretcher ) 
	if isElement(stretcher) then 
		stretcher:attach(self.m_Entity, Vector3(0, 1.4, -0.5))
	end
end

function ExecutionPed:destructor() 
	if isElement( self.m_Entity ) then destroyElement( self.m_Entity ) end 
	setElementAlpha(self.m_Player, 255) 
	setElementCollisionsEnabled( self.m_Player, true)
	if ExecutionPed.Map[self.m_Player] then ExecutionPed.Map[self.m_Player] = nil end
end
