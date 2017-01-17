DxHelper = inherit(Singleton)

function DxHelper:constructor()
	self:initScroll()
	self:initDoubleClick()
end

function DxHelper:destructor()

end

function DxHelper:initScroll()
	local on_scroll_up = function()
		local hoveredElement = GUIElement.getHoveredElement()
		while hoveredElement do
			-- Trigger events up the tree
			if hoveredElement.onInternalMouseWheelUp then hoveredElement:onInternalMouseWheelUp() end
			if hoveredElement.onMouseWheelUp then hoveredElement:onMouseWheelUp() end
			hoveredElement = hoveredElement.m_Parent
		end
	end
	local on_scroll_down = function()
		local hoveredElement = GUIElement.getHoveredElement()
			while hoveredElement do
				-- Trigger events up the tree
				if hoveredElement.onInternalMouseWheelDown then hoveredElement:onInternalMouseWheelDown() end
				if hoveredElement.onMouseWheelDown then hoveredElement:onMouseWheelDown() end
				hoveredElement = hoveredElement.m_Parent
			end
	end

	addEventHandler("onClientKey", root, function(key, press)
		if press then
			if key == "mouse_wheel_up" then
				on_scroll_up()
			elseif key == "mouse_wheel_down" then
				on_scroll_down()
			end
		end
	end)
end

function DxHelper:initDoubleClick()
	addEventHandler("onClientDoubleClick", root,
		function(button, absoluteX, absoluteY)
			local guiElement = GUIElement.getHoveredElement()

			if guiElement and guiElement:isVisible(true) then
				if button == "left" and guiElement.onLeftDoubleClick then
					guiElement:onLeftDoubleClick(absoluteX, absoluteY)
				end
				if button == "right" and guiElement.onRightDoubleClick then
					guiElement:onRightDoubleClick(absoluteX, absoluteY)
				end
			end
		end
	)
end
