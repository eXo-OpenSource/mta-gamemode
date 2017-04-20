addEventHandler("onClientResourceStart", resourceRoot,
	function()
		if _DEBUG then
			triggerServerEvent("onClientReady", resourceRoot)
		end
	end
)

addEvent("clientDebugElements", true)
addEventHandler("clientDebugElements", resourceRoot,
	function(e)
		if _DEBUG then
			elements = e
			
			addEventHandler("onClientRender", root, trackElements)
		end
	end
)

function trackElements()
	for i,e in ipairs(elements) do
		if isElementSyncer(e.p) then
			local x,y,z = getElementPosition(e.v)
						
			if z > e.h then
				setPedControlState(e.p, "accelerate", false)
				setPedControlState(e.p, "brake_reverse", true)
			elseif z < e.l then
				setPedControlState(e.p, "accelerate", true)
				setPedControlState(e.p, "brake_reverse", false)
			end
		end
	end
end