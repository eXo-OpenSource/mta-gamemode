MechanicTow = inherit(Company)

function MechanicTow:constructor()
	outputDebug(("[%s] Extra-class successfully loaded! (Id: %d)"):format(self:getName(), self:getId()))
end

function MechanicTow:destuctor()

end
