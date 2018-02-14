
Atrium = inherit(Singleton)
function Atrium:constructor()
    --[[
        1654.06, -1654.98, 22.52
        Rotation: -0.00, 0.00, 173.55
        Position: 1659.50, -1641.74, 83.78
        Rotation: -0.00, 0.00, 358.54
    ]]
    local elevator = Elevator:new()
    elevator:addStation("Heliport", Vector3(1659.50, -1641.74, 83.78))
    elevator:addStation("Terrasse", Vector3(1654.06, -1654.98, 22.52), 180)

end
