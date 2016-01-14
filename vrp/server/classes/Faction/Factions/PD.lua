FactionPolice = inherit(Faction)

function FactionPolice:constructor()
  outputDebugString("FactionPolice loaded")
end

function FactionPolice:destructor()
  outputDebug("FactionPolice.destructor")
end

function FactionPolice:getClassId()
  return 1
end
