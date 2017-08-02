MessageBoxManager = {}
MessageBoxManager.Map = {}
MessageBoxManager.Mode = true

function MessageBoxManager.resortPositions ()
	for i = #MessageBoxManager.Map, 1, -1 do
		local obj = MessageBoxManager.Map[i]
		local prevObj = MessageBoxManager.Map[i + 1]
		local x, y = HUDRadar:getSingleton():getPosition()

		if obj.m_Animation then
			delete(obj.m_Animation)
		end

		if prevObj then
			local y
			if not prevObj.m_Animation then
				y = prevObj.m_AbsoluteY
			else
				y = prevObj.m_Animation.m_TY
			end
			obj.m_Animation = Animation.Move:new(obj, 250, obj.m_AbsoluteX, y - obj.m_Height - 5)
		elseif not obj.m_AlphaFaded then
			Animation.FadeAlpha:new(obj, 500, 0, 200)
			if obj.m_Texture then
				Animation.FadeAlpha:new(obj.m_Texture, 500, 0, 200)
			end
			obj.m_AlphaFaded = true
		else
			obj.m_Animation = Animation.Move:new(obj, 250, x, y - x - obj.m_Height)
		end
	end
end

function MessageBoxManager.recalculatePositions()
	for i = #MessageBoxManager.Map, 1, -1 do
		local obj = MessageBoxManager.Map[i]
		local prevObj = MessageBoxManager.Map[i + 1]
		local x, y = HUDRadar:getSingleton():getPosition()

		if obj.m_Animation then
			delete(obj.m_Animation)
		end

		if prevObj then
			obj.m_Animation = Animation.Move:new(obj, 250, obj.m_AbsoluteX, prevObj.m_Animation.m_TY - obj.m_Height - 5)
		else

			obj.m_Animation = Animation.Move:new(obj, 250, x, y - x - obj.m_Height)
		 --guielement, time, tx, ty, easing
		end
	end
end

function MessageBoxManager.onRadarPositionChange()
	MessageBoxManager.Mode = not MessageBoxManager.Mode
	MessageBoxManager.recalculatePositions()
end

function testMessages()
	ShortMessage:new("Hi im a ShortMessage.")
	ToastSuccess:new("Hi im a SuccessToast.")
	ShortMessage:new("Hi im a ShortMessage with title", "u suck")
	ToastError:new("im a important error!!11eleven!!!")
	ToastWarning:new("U suck!")
	ShortMessage:new("u 2.")
end
