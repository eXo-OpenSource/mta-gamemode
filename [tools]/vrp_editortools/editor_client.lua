addEventHandler("onClientElementPropertyChanged", root,
	function(propertyName)
		if getElementType(source) == "bus_stop" then
			if propertyName == "markerdistance" then
				local markerDistance = tonumber(exports.edf:edfGetElementProperty(source, "markerdistance"))
				local object = getRepresentation(source, "object")
				local marker = getRepresentation(source, "marker")
				
				if object and object[1] and marker and markerDistance then
					detachElements(marker)
					local x, y, z = getPositionFromElementOffset(object[1], -1 * markerDistance, 0, -1.5)
					setElementData(marker, "position", {x, y, z})
					exports.edf:edfSetElementPosition(marker, x, y, z)
					attachElements(marker, object[1], -1 * markerDistance, 0, -1)
				end
			end
		elseif getElementType(source) == "gangarea" then
			
		end
	end
)

addEventHandler("onClientElementCreate", root,
	function()		
		if getElementType(source) == "bus_stop" then
			local markerDistance = tonumber(exports.edf:edfGetElementProperty(source, "markerdistance"))
			local object = f(source, "object")
			local marker = getRepresentation(source, "marker")
				
			if object and object[1] and marker and markerDistance then
				detachElements(marker)
				local x, y, z = getPositionFromElementOffset(object[1], -1 * markerDistance, 0, -1)
				setElementData(marker, "position", {x, y, z})
				exports.edf:edfSetElementPosition(marker, x, y, z)
				attachElements(marker, object[1], -1 * markerDistance, 0, -1)
			end
		elseif getElementType(source) == "gangarea" then
			local x, y, z = exports.edf:edfGetElementPosition(source)
			exports.edf:edfSetElementProperty(source, "areaX", x)
			exports.edf:edfSetElementProperty(source, "areaY", y)
		elseif getElementType(source) == "guiwall" then
			local object = getRepresentation(source, "object")
			local marker = getRepresentation(source, "marker")
			
			for index, obj in pairs(object) do
				setElementDoubleSided(obj, true)
			end
			
			local x,y,z = getElementPosition(object[1])
			exports.edf:edfSetElementProperty(source, "startPosX", x)
			exports.edf:edfSetElementProperty(source, "startPosY", y)
			exports.edf:edfSetElementProperty(source, "startPosZ", z)
			
			detachElements(marker)
			local x1, y1, z1 = getPositionFromElementOffset(object[1], 1, 5, -1)
			exports.edf:edfSetElementPosition(marker, x1, y1, z1)
			attachElements(marker, object[1], 1, 5, -1)
		end
	end
)

local greenTexture = dxCreateTexture(":vrp_editortools/green.png")

addEventHandler("onClientRender", root,
	function()
		for k, gangarea in pairs(getElementsByType("gangarea")) do
			local areaX, areaY = exports.edf:edfGetElementProperty(gangarea, "areaX"), exports.edf:edfGetElementProperty(gangarea, "areaY")
			local width, height = exports.edf:edfGetElementProperty(gangarea, "width"), exports.edf:edfGetElementProperty(gangarea, "height")
			if areaX and areaY and width and height then
				local z = getGroundPosition(areaX, areaY, 50)
				if z then
					dxDrawRectangle3D(areaX, areaY, z+1, width, height, tocolor(255, 255, 0, 200), 0, areaX, areaY-height/2, z+2)
				end
			end
		end
		
		for k, guiwall in pairs(getElementsByType("guiwall")) do
			local startPosX, startPosY, startPosZ = exports.edf:edfGetElementProperty(guiwall, "startPosX"), exports.edf:edfGetElementProperty(guiwall, "startPosY"), exports.edf:edfGetElementProperty(guiwall, "startPosZ")
			local sizeX, sizeY, sizeZ = exports.edf:edfGetElementProperty(guiwall, "sizeX"), exports.edf:edfGetElementProperty(guiwall, "sizeY"), exports.edf:edfGetElementProperty(guiwall, "sizeZ")
			local width = exports.edf:edfGetElementProperty(guiwall, "width")
			if startPosX and startPosY then
				
				local marker = getRepresentation(guiwall, "marker")
				local x1, y1, z1 = exports.edf:edfGetElementPosition(marker)
				dxDrawMaterialLine3D ( startPosX, startPosY, startPosZ, startPosX+sizeX, startPosY+sizeY, startPosZ+sizeZ, greenTexture, width, nil, x1, y1, z1)
			end
		end
	end
)

bindKey("num_0", "down",
	function()
		local selectedObject = exports.editor_main:getSelectedElement()
		if not selectedObject or getElementType(selectedObject) ~= "gangarea"  then
			return
		end
		
		local x, y = getElementPosition(localPlayer)
		exports.edf:edfSetElementProperty(selectedObject, "areaX", x)
		exports.edf:edfSetElementProperty(selectedObject, "areaY", y)
	end
)


-- Utils
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

local dot = dxCreateRenderTarget(1,1)
dxSetRenderTarget(dot)
dxDrawRectangle(0, 0, 1, 1, tocolor(255,255,255,255))
dxSetRenderTarget()
function dxDrawRectangle3D(x,y,z,w,h,c,r,normalX,normalY,normalZ)
	local lx, ly, lz = x+w, y, (z+tonumber(r or 0)) or z
	return dxDrawMaterialLine3D(x, y-h/2, z, lx, ly-h/2, lz, dot, h, c, normalX, normalY, normalZ)
end
