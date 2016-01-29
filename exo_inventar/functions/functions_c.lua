_killTimer = killTimer
function killTimer(theTimer)
	if(isTimer(theTimer) and getTimerDetails ( theTimer )) then
		return _killTimer(theTimer)
	else
		return false
	end
end

local mouseState = "up"

function getMouseState()
	return mouseState
end

local function onClick(button,state)
	mouseState = state
end
addEventHandler("onClientClick",getRootElement(),onClick)

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
