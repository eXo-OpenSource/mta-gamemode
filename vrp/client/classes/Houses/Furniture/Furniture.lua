Furniture = inherit(Object)

function Furniture.create(model, position, rotation, dimension, interior)
	local obj = enew(createObject(model, position, rotation), Furniture)
	obj:setDimension(dimension)
	obj:setInterior(interior)
	return obj
end

function Furniture:constructor()

end

function Furniture:destructor()

end

function Furniture:destroy()



	destroyElement(self)
end

function Furniture:onClick()

end
