DxHelper = inherit(Singleton)

function DxHelper:constructor()
	self:initScroll()
	self:initDoubleClick()
end

function DxHelper:destructor()

end

function DxHelper:getElementClassName(element)
	if instanceof(element, CacheArea, true) 				then return "CacheArea" end
	if instanceof(element, CacheArea3D, true) 				then return "CacheArea3D" end
	if instanceof(element, DxElement, true) 				then return "DxElement" end
	if instanceof(element, DxRectangle, true) 				then return "DxRectangle" end
	if instanceof(element, GUIButton, true) 				then return "GUIButton" end
	if instanceof(element, GUIButtonMenu, true) 			then return "GUIButtonMenu" end
	if instanceof(element, GUIChanger, true) 				then return "GUIChanger" end
	if instanceof(element, GUICheckbox, true) 				then return "GUICheckbox" end
	if instanceof(element, GUICombobox, true) 				then return "GUICombobox" end
	if instanceof(element, GUICursor, true) 				then return "GUICursor" end
	if instanceof(element, GUIEdit, true) 					then return "GUIEdit" end
	if instanceof(element, GUIElement, true) 				then return "GUIElement" end
	if instanceof(element, GUIForm, true) 					then return "GUIForm" end
	if instanceof(element, GUIForm3D, true) 				then return "GUIForm3D" end
	if instanceof(element, GUIGridList, true) 				then return "GUIGridList" end
	if instanceof(element, GUIGridListItem, true) 			then return "GUIGridListItem" end
	if instanceof(element, GUIImage, true) 					then return "GUIImage" end
	if instanceof(element, GUILabel, true) 					then return "GUILabel" end
	if instanceof(element, GUIMiniMap, true) 				then return "GUIMiniMap" end
	if instanceof(element, GUIMouseMenu, true) 				then return "GUIMouseMenu" end
	if instanceof(element, GUIMouseMenuItem, true) 			then return "GUIMouseMenuItem" end
	if instanceof(element, GUIMouseMenuNoClickItem, true) 	then return "GUIMouseMenuNoClickItem" end
	if instanceof(element, GUIProgressBar, true) 			then return "GUIProgressBar" end
	if instanceof(element, GUIRadioButton, true) 			then return "GUIRadioButton" end
	if instanceof(element, GUIRadioButtonGroup, true) 		then return "GUIRadioButtonGroup" end
	if instanceof(element, GUIRating, true) 				then return "GUIRating" end
	if instanceof(element, GUIRectangle, true) 				then return "GUIRectangle" end
	if instanceof(element, GUIScrollableArea, true) 		then return "GUIScrollableArea" end
	if instanceof(element, GUIScrollableText, true) 		then return "GUIScrollableText" end
	if instanceof(element, GUISlider, true) 				then return "GUISlider" end
	if instanceof(element, GUISwitch, true) 				then return "GUISwitch" end
	if instanceof(element, GUITabControl, true) 			then return "GUITabControl" end
	if instanceof(element, GUITabPanel, true) 				then return "GUITabPanel" end
	if instanceof(element, GUIWebForm, true) 				then return "GUIWebForm" end
	if instanceof(element, GUIWebView, true) 				then return "GUIWebView" end
	if instanceof(element, GUIWindow, true) 				then return "GUIWindow" end

	if instanceof(element, GUIGridEdit, true) 				then return "GUIGridEdit" end
	if instanceof(element, GUIGridCombobox, true) 			then return "GUIGridCombobox" end
	if instanceof(element, GUIGridGridList, true) 			then return "GUIGridGridList" end
	if instanceof(element, GUIGridImage, true) 				then return "GUIGridImage" end
	if instanceof(element, GUIGridRadioButton, true) 		then return "GUIGridRadioButton" end
	if instanceof(element, GUIGridRectangle, true) 			then return "GUIGridRectangle" end
	if instanceof(element, GUIGridEmptyRectangle, true) 	then return "GUIGridEmptyRectangle" end
	if instanceof(element, GUIGridProgressBar, true) 		then return "GUIGridProgressBar" end
	if instanceof(element, GUIGridSlider, true) 			then return "GUIGridSlider" end
	if instanceof(element, GUIGridSwitch, true) 			then return "GUIGridSwitch" end
	if instanceof(element, GUIGridWebView, true) 			then return "GUIGridWebView" end
	if instanceof(element, GUIGridScrollableArea, true) 	then return "GUIGridScrollableArea" end
	if instanceof(element, GUIGridMemo, true) 				then return "GUIGridMemo" end
	if instanceof(element, GUIGridSkribble, true) 			then return "GUIGridSkribble" end
	if instanceof(element, GUIGridRating, true) 			then return "GUIGridRating" end
	if instanceof(element, GUIGridButton, true) 			then return "GUIGridButton" end
	if instanceof(element, GUIGridIconButton, true) 		then return "GUIGridIconButton" end
	if instanceof(element, GUIGridChanger, true) 			then return "GUIGridChanger" end
	if instanceof(element, GUIGridCheckbox, true) 			then return "GUIGridCheckbox" end
	if instanceof(element, GUIGridMiniMap, true) 			then return "GUIGridMiniMap" end
	if instanceof(element, GUIGridLabel, true) 				then return "GUIGridLabel" end
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
