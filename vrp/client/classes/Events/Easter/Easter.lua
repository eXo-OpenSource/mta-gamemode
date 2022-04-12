-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Easter/Easter.lua
-- *  PURPOSE:     Easter class
-- *
-- ****************************************************************************

Easter = inherit(Singleton)

Easter.HidingRabbitPositions = {
    {2081.79, 1902.12, 14.85, 280},         --The Visage (M)
    {-1846.37, -1712.12, 41.11, 345},       --Whetstone (M)
    {-2706.46, 1930.05, 3.22, 142},         --Gant Bridge (M)
    {1530.45, 1937.2, 10.82, 180},          --Redsands West (D)
    {-154.94, -256.56, 3.91, 180},          --Fleischberg (M)
    {-2177.318, 712.2, 53.89, 180},         --Chinatown SF (M)
    {1635.26, 10.68, 9.24, 160},            --Redcounty Bridge (M)
    {-2510, -686.774, 139.32, 90},          --Missionary Hill (D)
    {-2475.60, 1553.74, 33.23, 180},        --SF Bay Boat (M)
    {249.32, -1465.10, 38.40, 275},         --LS Billboard (M)
    {2542.94, 1028.45, 10.82, 180},         --Come-A-Lot (M)
    {1297.765, 2605.634, 10.82, 0},         --Prickle Pine (D)
    {-1675.48, 1008.66, 7.92, 270},         --SF Labyrinth (SD)
    {679.17, -2621.65, 2.70, 90},           --Fisher Island (M)
    {-1528.61, 2656.57, 56.28, 90},         --El Quebrados (M)
}
Easter.RabbitHints = {
    {"Gestatten, der Osterhase. Dürfte Ich Dich um einen Gefallen bitten?", "Meine 15 Helferchen sind noch nicht wieder da...", "Einen meiner Helfer habe ich mitten in die Stadt der Abenteuer im Norden geschickt.", "Könntest Du Ihn suchen gehen? Sonst erkältet er sich noch...", "Meine Helferchen sind auch ein wenig kurzsichtig.", "Solltest Du Ihn finden, stelle Dich bitte direkt vor ihn, sonst sieht er Dich nicht."},
    {"Ach hallo, den ersten schon gefunden?", "Der Nächste ist leider auf dem Weg nach San Fierro in der Nähe von diesem Berg abhandengekommen...", "Sein Fell war schon richtig schwarz vor Staub. Wo ist es bloß gelandet?"},
    {"Huch, da bist Du ja wieder.", "Schlechte Neuigkeiten. Ein Helferchen sollte ja in diese Kleinstadt im Nordwesten...", "Jetzt steckt der kleine Mann aber fest und kommt von diesem riesigen Bauwerk nicht mehr weg.", "Kannst du ihn schnellstmöglich ausfindig machen? Bitte bitte bitte."},
    {"Wieder zurück? Wunderbar, einen Moment, wo war das noch...", "Achja, das nächste Helferchen ist in der Nähe vom Ersten. Du weißt schon, in der Stadt im Norden.", "Nördlich vom Flughafen soll es vor Gangstern geflüchtet sein und sich versteckt haben.", "Mein Helferchen hat sicher Angst, bitte beeil Dich!"},
    {"Moin moin.", "Also dieses Helferchen wollte ja eigentlich fasten.", "Und ich habs erwischt, wie es sich genüsslich ein paar Dosen Bier reinpfeift!", "Jetzt hat es sich wohl vor Scham versteckt, das Bier war auch ziemlich teuer.", "Hast Du eine Idee, wo es stecken könnte?"},
    {"Hallo erneut, diesmal wirds knifflig.", "Leider keine Ahnung, wo mein Helferchen aus San Fierro geblieben ist.", "Ich weiß aber, dass dort in der Nähe kulturreiche Leute mit ausländischen Wurzeln leben.", "Vielleicht kannst Du etwas mit dem Hinweis anfangen?"},
    {"*schnüff schnüff* Oh, Du bist es.", "Ich habe ganz vergessen, dass ein Helferchen noch nördlich von Los Santos verweilt.", "In der Nähe ist die Autobahn und nebenan soll mal das berühmte Rennen einer alten Gang stattgefunden haben...", "Wo könnte das bloß sein?"},
    {"Juten Tach! Ich hatte gehofft, Dich zu sehen.", "Südlich in San Fierro hat sich wieder eines meiner Helferchen verirrt.", "Soll an einem etwas höher gelegenen Ort sein und man soll da ziemlich guten Empfang haben.", "Sagt Dir das zufällig was?"},
    {"Ahoi, schön Dich hier zu treffen!", "Dieser kleine Frechdachs... Ein Helferchen hat mir vorhin ein Selfie von sich geschickt.", "Ich weiß nicht, wo es steckt, aber im Hintergrund ist ganz viel Elektronik vor großen Fensterscheiben.", "Und durchs Fenster sieht man...große, farbige Metallkästen oder so?", "Bitte sei so lieb und schau dich mal um."},
    {"Hallöchen.", "Gestern Abend hatte ich das Helferchen noch gesehen, erinnere mich aber nicht mehr dran.", "Aber das war hier in der Stadt und mir fällt ein, ich habe Werbung für Verbrennungen gesehen...", "Seltsam, hat sich wohl in meine Erinnerung eingebrannt.", "Egal. Könntest Du dich bitte auf den Weg machen?"},
    {"Da biste ja wieder!", "Diesmal habe ich keine genauen Infos, aber mein Helferlein war kurz vorher noch im Urlaub.", "Es hat sich in Las Venturas einen Hotelaufenthalt gegönnt und ist dann in einem schäbigen Stripties-Schuppen gelandet...", "Bitte bring es zurück bevor ich noch zur Therapie muss, ja?"},
    {"Moin. Auf ein Neues!", "Ich glaube, eins meiner Helferchen will sich vor seiner Arbeit drücken.", "Er wohnt ebenfalls nördlich in der Stadt der Abenteuer, ruhige Gegend muss man sagen. Bis auf das regelmäßige Quietschen von Rädern.", "Du kannst ihm sicher Beine machen oder?"},
    {"Ich grüße dich, hallo.", "Au weia, vielleicht ist es diesmal sogar meine Schuld, dass es sich verlaufen hat.", "Ich habe mein Helferchen in ein Labyrinth in San Fierro geschickt, um dort meine versteckten Ostereier zu finden...", "Kannst Du es bitte dort rausholen?"},
    {"Servus und moin moin!", "Oh, also das könnte schwierig werden.", "Eins meiner Helferchen hat mich angefunkt, dass beim Angeln sein Boot den Geist aufgegeben hat und es jetzt hier feststeckt.", "Wenn Du ihm helfen könntest, wäre das klasse."},
    {"Einen wunderschönen.", "Puh, fast alle Helferchen sind nun zurückgekehrt, jetzt fehlt nur noch eins.", "Es hat sich in einem Dorf im weiten Bone County verschanzt, nachdem es sich beim Ammunation mit Waffen eingedeckt hat.", "Bring es bitte zur Vernunft und komme dann zurück, ja?"},
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

    for index, object in pairs(getElementsByType("object")) do
        if object:getModel() == 3095 then
            local x, y, z = getElementPosition(object)
            if getDistanceBetweenPoints3D(x, y, z, -1677, 1006, 5) < 100 then
                FileTextureReplacer:new(object, "files/images/Textures/JetdoorMetal.png", "sam_camo", {}, true, true)
            end
        end
    end
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