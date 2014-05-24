addEventHandler("onClientElementPropertyChanged", root,
	function(propertyName)
		if getElementType(source) == "bus_stop" then
			if propertyName == "markerdistance" then
				local markerDistance = tonumber(exports.edf:edfGetElementProperty(source, "markerdistance"))
				local object = getRepresentation(source, "object")
				local marker = getRepresentation(source, "marker")
				
				if object and marker and markerDistance then
					detachElements(marker)
					local x, y, z = getPositionFromElementOffset(object, -1 * markerDistance, 0, -1)
					setElementData(marker, "position", {x, y, z})
					exports.edf:edfSetElementPosition(marker, x, y, z)
					attachElements(marker, object, -1 * markerDistance, 0, -1)
				end
			end
		end
	end
)

addEventHandler("onClientElementCreate", root,
	function()
		if getElementType(source) == "bus_stop" then
			local markerDistance = tonumber(exports.edf:edfGetElementProperty(source, "markerdistance"))
			local object = getRepresentation(source, "object")
			local marker = getRepresentation(source, "marker")
				
			if object and marker and markerDistance then
				detachElements(marker)
				local x, y, z = getPositionFromElementOffset(object, -1 * markerDistance, 0, -1)
				setElementData(marker, "position", {x, y, z})
				exports.edf:edfSetElementPosition(marker, x, y, z)
				attachElements(marker, object, -1 * markerDistance, 0, -1)
			end
		end
	end
)

function getPositionFromElementOffset(element, offX, offY, offZ)
	local m = getElementMatrix(element)
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z
end

function getRepresentation(element,type)
	local elemTable = {}
	for i,elem in ipairs(getElementsByType(type,element)) do
		if elem ~= exports.edf:edfGetHandle ( elem ) then
			table.insert(elemTable, elem)
		end
	end
	if #elemTable == 0 then
		return false
	elseif #elemTable == 1 then
		return elemTable[1]
	else
		return elemTable
	end
end
