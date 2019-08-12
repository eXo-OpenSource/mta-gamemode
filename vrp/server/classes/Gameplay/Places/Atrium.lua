
Atrium = inherit(Singleton)
function Atrium:constructor()
    --parkdeck
    InteriorEnterExit:new(Vector3(1699.02, -1667.94, 20.19), Vector3(1701.11, -1667.85, 20.23), 270, 90, 1, 1)
    --terrasse
    InteriorEnterExit:new(Vector3(1726.99, -1636.20, 20.22), Vector3(1726.89, -1638.65, 20.23), 180, 0, 1, 1)
end
