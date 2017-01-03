ItemDestructable = inherit(Singleton)

function ItemDestructable:constructor()
	addEventHandler("onClientObjectBreak", root, bind(self.Event_OnBreak,self))
end


function ItemDestructable:Event_OnBreak()
	triggerServerEvent("onClientBreakItem", source)
end
