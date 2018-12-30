Atrium = inherit(Singleton)
Atrium.ImagePlates = {
    {Vector3(1735.4553, -1659.8776, 20.9), Vector3(90, 0, 90), "Life's a Palm Beach\nFreddy Feuerfelsen\nFotografie auf Klarlack\n2005"},
    {Vector3(1735.4553, -1652.5779, 20.9), Vector3(90, 0, 90), "Perfektion in Symmetrie\nKarsten Stahl\n\n"},
    {Vector3(1735.4553, -1645.4031, 20.9), Vector3(90, 0, 90), "Don't drink and drive, just sauf and lauf\nErnst Scherz\nAquarell auf Bambus-Papier\n1967"},
    {Vector3(1700.3412, -1656.9199, 20.9), Vector3(90, 0, 270), "Brücken\nSchteven K.\n\n"},
    {Vector3(1700.3412, -1661.8949, 20.9), Vector3(90, 0, 270), "hairy pussy\nFliesentisch Klaus\n\n"},
    {Vector3(1703.156, -1674.25, 20.9), Vector3(90, 0, 0), "Ohne Titel - Ohne Worte - Miese Zeiten\nStummy Stumpf\n\n"},
    {Vector3(1707.1813, -1674.25, 20.9), Vector3(90, 0, 0), "SWT rush mit Booten, Jungs!\nAxel Schweiß\n\n"},
}

function Atrium:constructor()
    --not enough data, maybe add an automated draw contest
   --[[ for i,v in pairs(Atrium.ImagePlates) do
        local o = createObject(2190, v[1], v[2])
        setElementData(o, "clickable", true)
        setElementInterior(o, 1)
        setElementDimension(o, 1)
        o:setData("onClickEvent", function()
            ShortMessage:new(v[3], _"Informationstafel", Color.Grey)
        end)
    end]]
end
