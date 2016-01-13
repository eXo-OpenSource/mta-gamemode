PD = inherit(Faction)

function PD:constructor()
  outputDebugString("PD loaded")
end

function PD:destructor()
  outputDebug("PD.destructor")
end
