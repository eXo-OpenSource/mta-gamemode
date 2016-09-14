SpeedCamera = inherit(Object)

--  1516.267, y = -1597.844, z = 13.547
function SpeedCamera:constructor(x, y, z, rx, ry, rz, int, dim)
	if not int then
		int = 0
	end
	if not dim then
		dim = 0
	end

	-- Instances
  self.m_Dim = dim
  self.m_Object = createObject(3902, x, y, z)
  self.m_Collider = createColSphere(0, 0, 0, 6)
	self.m_Collider:setPosition(self.m_Object.matrix:transformPosition(3, 5, 1))
  --self.m_collider:attach(self.m_object, 3, 5, 1)

  self.m_onColShapeHit = bind(self.onColShapeHit, self)
	addEventHandler("onColShapeHit", self.m_Collider, self.m_onColShapeHit)
end

function SpeedCamera:onColShapeHit(element, dim)
  if dim then
    if element:getType() == "player" then
      PlayerManager:getSingleton():breakingNews("%s war zu schnell amk!", element:getName())
    end
  end
end

addCommandHandler("speedi", function(pl)
  local cam = SpeedCamera:new(1516.267, -1597.844, 11.3)
  --cam.m_onColShapeHit(pl, true)
end)
