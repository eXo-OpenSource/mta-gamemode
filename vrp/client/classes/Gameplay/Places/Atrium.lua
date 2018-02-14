Atrium = inherit(Singleton)
Atrium.ImagePlates = {
    {Vector3(1735.4553, -1659.8776, 20.9), Vector3(90, 0, 90), "Life's a Palm Beach\nFotografie auf Klarlack, 2005\n"},
    {Vector3(1735.4553, -1652.5779, 20.9), Vector3(90, 0, 90), "'Perfektion in Symmetrie'\n\n"},
    {Vector3(1735.4553, -1645.4031, 20.9), Vector3(90, 0, 90), "Ernst Scherz: Don't drink and drive, just sauf and lauf,\nÖl auf Leinwand, 1967"},
    {Vector3(1700.3312, -1656.9199, 20.9), Vector3(90, 0, 270), "Brücken\n"},
    {Vector3(1700.3312, -1661.8949, 20.9), Vector3(90, 0, 270), "hairy pussy\n\n"},
    {Vector3(1703.156, -1674.2695, 20.9), Vector3(90, 0, 0), "Ohne Titel - Ohne Worte - Miese Zeiten\n\n"},
    {Vector3(1707.1813, -1674.2695, 20.9), Vector3(90, 0, 0), "lsdocks\n\n"},
}

function Atrium:constructor()
    for i,v in pairs(Atrium.ImagePlates) do
        local o = createObject(1337, v[1], v[2]) --2190
        setElementData(o, "clickable", 5)
        o:setData("onClickEvent", function()
            ShortMessage:new(v[3], _"Informationstafel", Color.Grey)
        end)
    end
end
