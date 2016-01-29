a = "ä"
o = "ö"
u = "ü"
s = "ß"
A = "Ä"
O = "Ö"
U = "Ü"

function refreshString(string)
	local nstring,w = string.gsub(string,"Ü","Ue")
	local nstring,w = string.gsub(nstring,"Ö","Oe")
	local nstring,w = string.gsub(nstring,"Ä","Ae")
	local nstring,w = string.gsub(nstring,"ü","ue")
	local nstring,w = string.gsub(nstring,"ö","oe")
	local nstring,w = string.gsub(nstring,"ä","ae")
	local nstring,w = string.gsub(nstring,"ß","sz")
	return nstring
end


function refreshStringManuel(string)
	local nstring,w = string.gsub(string,"Ue",""..U.."")
	local nstring,w = string.gsub(nstring,"Oe",""..O.."")
	local nstring,w = string.gsub(nstring,"Ae",""..A.."")
	local nstring,w = string.gsub(nstring,"ue",""..u.."")
	local nstring,w = string.gsub(nstring,"oe",""..o.."")
	local nstring,w = string.gsub(nstring,"ae",""..a.."")
	local nstring,w = string.gsub(nstring,"*sz",""..s.."")
	return nstring
end

function md5it (player,command, theString) -- open function
  if theString then -- check if the string is exist
    md5string = md5(theString) -- get the md5 string
    outputChatBox(theString.. " -> " .. md5string , player, 255, 0, 0, false) -- output it
  end
end
addCommandHandler ("md5it", md5it)

function MySQL_Save ( strings )
	if(not strings) then
		return error("MySQL_Save > no argument",2)
	end
	return mysql_escape_string ( Datenbank, tostring(strings) )
end

function outputChatBoxInRange(range,message,player,r,g,b)
	
	if(type(range) ~= "number") then
		return error("outputChatBoxInRange > arg #1 not a number",2)
	elseif(type(message) ~= "string") then
		return error("outputChatBoxInRange > arg #2 not a string",2)
	elseif(getElementType(player) ~= "player") then
		return error("outputChatBoxInRange > arg #3 not a player",2)
	end
	local x,y,z = getElementPosition(player)
	if(r == nil) then
		r=255
	end
	if(g == nil) then
		g=255
	end
	if( b == nil) then
		b=255
	end
	local chatSphere = createColSphere( x, y, z, range )
	local nearbyPlayers = getElementsWithinColShape( chatSphere, "player" )
	destroyElement(chatSphere)
	for i, nearbyPlayer in ipairs( nearbyPlayers ) do
		if(nearbyPlayer ~= player) then
			outputChatBox(tostring(message),nearbyPlayer,r,g,b)
		end
	end
end


_setElementData = setElementData
_setElementInteriorTrigger = true
function setElementData ( element, name,value,stream )
    if _setElementInteriorTrigger then
		
		if(not isElement(element)) then
			return error("setElementData > arg #1 not a element",2)
		elseif(type(name) ~= "string") then
			return error("setElementData > arg #2 not a string",2)
		end
		if(not stream or stream == false) then
			_setElementInteriorTrigger = false
			local result = _setElementData ( element, name,value,false)
			_setElementInteriorTrigger = true
		elseif(stream == true) then
			_setElementInteriorTrigger = false
			local result = _setElementData ( element, name,value,true)
			_setElementInteriorTrigger = true
		end
		return result
    end
end

function setData(element,tname,index,value,stream)
	if(not isElement(element)) then
		outputDebugString("Inventar: setData > arg #1 not a element",2)
		return false
	elseif(type(tname) ~= "string") then
		outputDebugString("Inventar: setData > arg #2 not a string",2)
		return false
	end
	if not getElementData(element,tname) then
		setElementData(element,tname,{})
	end
	local invtable = getElementData(element,tname)
	invtable[index] = value
	setElementData(element,tname,invtable,false)
	
	if(stream == true) then
		if(getElementData(element,tname.."_c") == false) then
			setElementData(element,tname.."_c",{})
		end
		local invtable = getElementData(element,tname)
		invtable[index] = value
		setElementData(element,tname.."_c",invtable,true)
		
	end
end

_getElementData = getElementData
_getElementDatTrigger = true
function getElementData ( element, name,index )
    if _getElementDatTrigger then
		if(not element ) then
			return error("getElementData > no argument",2)
		elseif(not isElement(element)) then
			return error("getElementData > arg #1 not a element",2)
		elseif(type(name) ~= "string") then
			return error("getElementData > arg #2 not a string",2)
		end
		local result
		if(not index) then
			_getElementDatTrigger = false
			result = _getElementData ( element, name)
			_getElementDatTrigger = true
		else
			_getElementDatTrigger = false
			if(_getElementData(element,name)) then
				_getElementDatTrigger = true
				
				_getElementDatTrigger = false
				result = _getElementData ( element, name)[index]
				_getElementDatTrigger = true
			else
				_getElementDatTrigger = false
				result = _getElementData ( element, name)
				_getElementDatTrigger = true
			end
			_getElementDatTrigger = true
		end
		return result
    end
end

function table.len(table)
	if(type(table) ~= "table") then
		error("table.len > arg #1 not a table",2)
		return false
	end
	local count = 0
	for index,value in pairs(table) do
		--if(value) then
			count = count + 1
		--end
	end
	return count
end
