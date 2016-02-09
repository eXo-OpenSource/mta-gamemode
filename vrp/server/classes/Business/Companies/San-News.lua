SanNews = inherit(Company)

function SanNews:constructor()
	outputDebug(("[%s] Extra-class successfully loaded! (Id: %d)"):format(self:getName(), self:getId()))
end

function SanNews:destuctor()

end
