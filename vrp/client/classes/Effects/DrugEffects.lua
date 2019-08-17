-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/DrugEffects.lua
-- *  PURPOSE:     DrugEffects
-- *
-- ****************************************************************************
DrugEffects = inherit(Singleton)
addRemoteEvents{"onClientDrugEffect"}

function DrugEffects:constructor()
	self.m_Classes = {
		weed = DrugsWeed:new(),
		heroin = DrugsHeroin:new(),
		shrooms = DrugsShroom:new(),
		cocaine = DrugsCocaine:new()
	}

	addEventHandler("onClientDrugEffect", localPlayer, bind(self.onDrugEffect, self))
end

function DrugEffects:destructor()
end

function DrugEffects:onDrugEffect(drug, duration)
	if self.m_ActiveDrug then
		self.m_Classes[self.m_ActiveDrug]:stopRender()
	end

	local class = self.m_Classes[drug]

	class:onUse()
	self.m_ActiveDrug = drug

	if duration then
		self.m_ItemExpire = duration / 1000
		self.m_LastTick = getTickCount()
		if self.m_ExpireFunc then
		  removeEventHandler("onClientRender", root, self.m_ExpireFunc)
		end

		self.m_ExpireFunc = bind(DrugEffects.onExpire, self)
		addEventHandler("onClientRender", root, self.m_ExpireFunc)
	end
end

function DrugEffects:onExpire()
	local now = getTickCount()
	if now - self.m_LastTick >= 1000 then
	  self.m_ItemExpire = self.m_ItemExpire -1
	  self.m_LastTick = now
	  if self.m_ItemExpire <= 0 then
		if self.m_ActiveDrug then
			self.m_Classes[self.m_ActiveDrug]:onExpire()
			self.m_ActiveDrug = nil
		end

		removeEventHandler("onClientRender", root, self.m_ExpireFunc)
	  end
	end
	dxDrawText(self.m_ItemExpire, 0 ,screenHeight*0.1 ,screenWidth , screenHeight, tocolor( 255,255,255,255), 1, "default-bold","center","top")
  end
