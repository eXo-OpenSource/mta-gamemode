-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Easter/Easter.lua
-- *  PURPOSE:     Easter class
-- *
-- ****************************************************************************

Easter = inherit(Singleton)

Easter.HidingRabbitPositions = {
    {-793.63, 2266.08, 59.08, 87},      --Hütte LV
    {2005.65, 2929.34, 47.76, 0},       --Wasserpumpe LV
    {1407.69, -1301.61, 9.90, 181},     --Kanal LS
    {2771.18, -1400.64, 27.18, 0},      --East LS
    {2228.90, 171.31, 27.48, 90},       --Palomino Creek Garage
    {-1229.49, 54.32, 14.23, 341},      --SF Airport
    {1715.99, 1303, 11.4, 0},           --LV Airport
    {-2452.75, -128.38, 26.16, 90},     --Hashburry Savehouse Garage
    {964.13, 2160.65, 10.82, 270},      --Whitewood Warehouse
    {-1675.48, 1008.66, 7.92, 270},     --SF Labyrinth
    {2001.10, -1043.30, 42.04, 210},    --LS Sign
    {2222.58, 1115.95, 47.65, 152},     --Come-A-Lot
    {-2648.39, 377.80, 13.53, 132},     --SF Cityhall
}
Easter.RabbitHints = {
    {"Gestatten, der Osterhase. Dürfte Ich dich um einen Gefallen Bitten?", "Meine 13 Helferchen sind noch nicht wieder da...", "Einen meiner Helfer habe Ich Richtung Sherman Damm geschickt...", "Könntest Du Ihn suchen gehen?", "Solltest Du Ihn finden, stelle Dich bitte direkt vor ihn, sonst sieht er Dich nicht."},
    {"Hey. Mein nächstes Helferchen habe Ich in die Nähe von Prickle Pine geschickt.", "Viel Glück beim Suchen! Und... Danke..."},
    {"Hi. Meinem nächsten Helferchen habe Ich gesagt, es solle hier in der Nähe bleiben...", "Wo er wohl ist?"},
    {"Schön, dass Du wieder da bist...", "Meinem vierten Helferchen sagte Ich, es solle ein paar Eier im Osten der Stadt verstecken."},
    {"Ich freue mich, Dich zu sehen!", "Ich sagte meinem fünften Helferchen, es solle in die ländlicheren Städte im Norden gehen.", "Würdest Du für mich nachsehen?"},
    {"Hallo erstmal!", "Ich erinnere mich, ein Helferchen in die Hafengegend von San Fierro geschickt zu haben..."},
    {"Guten Tag!", "Das nächste Helferchen habe Ich zum Flughafen in Las Venturas geschickt!", "Wieso sie sich wohl alle verstecken?"},
    {"Hi.", "Ich kann mich nur so halb erinnern, wo Ich mein nächstes Helferchen hingeschickt habe...", "Es war irgendeine Hippie-Gegend..."},
    {"Kennst Du die Industrie Gegend im Nord-Westen von Las Venturas?", "Dort habe Ich ein weiteres Helferchen hingeschickt."},
    {"Hey.", "Ich habe mich ein bisschen umgehorcht.",  "Ein Helferchen soll sich in einem komischen Labyrinth in San Fierro verlaufen haben...", "Kannst Du es bitte da rausholen?"},
    {"Ein weiteres Helferchen, sollte sich irgendwo im Nord-Osten von Los Santos aufhalten.", "Er kommt auf die absurdesten Ideen..."},
    {"Mir wurde etwas zugetragen.", "Eines meiner Helferchen soll sich in der Nähe eines der Hotels in Las Venturas verlaufen haben.", "Bitte finde Ihn... Diese Hotels sind so riesig..."},
    {"Vielen vielen Dank, dass Du meine Helferchen gefunden hast...", "Ein letztes Helferchen fehlt aber noch. Er sollte eigentlich zum Krankenhaus in San Fierro...", "Ob er dort ist, ist die andere Frage..."},
}
addRemoteEvents{"Easter:loadHidingRabbit"}

function Easter:constructor()
    RabbitManager:new()

    self.m_Blip = Blip:new("BunnyHead.png", 1477.5, -1663, 200, {177, 162, 133})
    self.m_Blip:setDisplayText("Osterhase")

    self.m_Rabbit = createPed(304, 1480.62, -1673.24, 14.05, 180)
    RabbitManager:getSingleton():setPedRabbit(self.m_Rabbit)
    RabbitManager:getSingleton():setPedIdleStance(self.m_Rabbit)
    RabbitManager:getSingleton():addPedEggBasket(self.m_Rabbit)

    self.m_Marker = createMarker(1480.53, -1675.5, 13.1, "cylinder", 1, 255, 255, 255, 255)
    triggerEvent("elementInfoCreate", localPlayer, self.m_Marker, "Osterhase", 1, "Egg", true)
    addEventHandler("onClientMarkerHit", self.m_Marker, bind(self.onClientMarkerHit, self))

    self.m_HidingRabbits = {}
    addEventHandler("Easter:loadHidingRabbit", root, bind(self.loadHidingRabbit, self))
    triggerServerEvent("Easter:requestHidingRabbits", localPlayer) 
end

function Easter:loadHidingRabbit(rabbitsFound)
    local rabbit = rabbitsFound+1
    if rabbit <= #Easter.HidingRabbitPositions then
        self.m_HidingRabbitId = rabbit
        self.m_HidingRabbit = createPed(304, unpack(Easter.HidingRabbitPositions[rabbit]))
        RabbitManager:getSingleton():setPedRabbit(self.m_HidingRabbit)
        RabbitManager:getSingleton():setPedIdleStance(self.m_HidingRabbit)
        RabbitManager:getSingleton():addPedEggBasket(self.m_HidingRabbit)
        self.m_HidingRabbit.colshape = createColSphere(self.m_HidingRabbit.position + self.m_HidingRabbit.matrix.forward*2, 1)
        addEventHandler("onClientColShapeHit", self.m_HidingRabbit.colshape, 
            function(hitElement, matchingDim)
                if matchingDim then
                    if hitElement == localPlayer then
                        DialogGUI:new(bind(self.onHidingRabbitFound, self),
                            "Du hast mich gefunden, Danke!",
                            "Ich kehre nun zurück zum Pershing Square!"
                        )
                    end
                end
            end
        )
    end
end

function Easter:destroyHidingRabbit()
    RabbitManager:getSingleton():removePedIdleStance(self.m_HidingRabbit)
    RabbitManager:getSingleton():removePedEggBasket(self.m_HidingRabbit)
    self.m_HidingRabbit.colshape:destroy()
    self.m_HidingRabbit:destroy()
    self.m_HidingRabbit = nil
    self.m_HidingRabbitId = nil
end

function Easter:onClientMarkerHit(hitElement, matchingDim)
    if matchingDim then
        if hitElement == localPlayer then
            if self.m_HidingRabbitId then
                DialogGUI:new(false,
                    unpack(Easter.RabbitHints[self.m_HidingRabbitId])
                )
            else
                DialogGUI:new(false,
                    "Vielen herzlichen Dank für deine Hilfe!"
                )
            end
        end
    end
end

function Easter:onHidingRabbitFound()
    fadeCamera(false, 0.001)
    setTimer(
        function()
            triggerServerEvent("Easter:onHidingRabbitFound", localPlayer, self.m_HidingRabbitId)
            self:destroyHidingRabbit()
            triggerServerEvent("Easter:requestHidingRabbits", localPlayer) 
            fadeCamera(true)
        end
    , 500, 1)
end

function Easter.updateTextures() 
	Easter.Textures = {}
	function Easter.updateTexture(texname, file, object)
		if not Easter.Textures[file] then
			Easter.Textures[file] = {}
			Easter.Textures[file].shader = dxCreateShader("files/shader/texreplace.fx")
			Easter.Textures[file].tex = dxCreateTexture(file)
			dxSetShaderValue(Easter.Textures[file].shader, "gTexture", Easter.Textures[file].tex)
		end

		engineApplyShaderToWorldTexture(Easter.Textures[file].shader, texname, object)
	end

	for index, object in pairs(getElementsByType("object")) do
		if object:getModel() == 2347 and getElementData(object, "EasterSlotmachine") then
			Easter.updateTexture("cj_wheel_69256", "files/images/Events/Easter/slot_1.png", object) -- 69
			Easter.updateTexture("cj_wheel_B1256", "files/images/Events/Easter/slot_2.png", object) -- Gold 1
			Easter.updateTexture("cj_wheel_B2256", "files/images/Events/Easter/slot_7.png", object) -- Gold 2
			Easter.updateTexture("cj_wheel_Bell256", "files/images/Events/Easter/slot_4.png", object) -- Glocke
			Easter.updateTexture("cj_wheel_Cherry256", "files/images/Events/Easter/slot_5.png", object) -- Kirsche
			Easter.updateTexture("cj_wheel_Grape256", "files/images/Events/Easter/slot_6.png", object) -- Traube
		elseif object:getModel() == 2325 and object:getData("Easter") then
			Easter.updateTexture("slot5_ind", "files/images/Events/Easter/slotmachine"..math.random(1,2)..".jpg", object)
		end
	end
end