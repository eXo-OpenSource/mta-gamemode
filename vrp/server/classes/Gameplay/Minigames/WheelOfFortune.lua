-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/WheelOfFortune.lua
-- *  PURPOSE:     create a wheel of fortune and manage it
-- *
-- ****************************************************************************

WheelOfFortune = inherit(Object)
WheelOfFortune.Map = {}
addRemoteEvents{"WheelOfFortuneClicked"}

function WheelOfFortune:constructor(pos, rz)
    self.m_FootObj = createObject(1897, pos, 0, 0, rz)
    
    local m = self.m_FootObj.matrix
    self.m_CursorObj = createObject(1898, self.m_FootObj.position + m.forward*-0.1 + m.up*1.08, self.m_FootObj.rotation)
    self.m_WheelObj = createObject(1895, self.m_FootObj.position + m.forward*-0.08 + m.up*0.01, self.m_FootObj.rotation)
    self.m_WheelObj:setDoubleSided(true)
    
    self.m_CollisonHandler = createObject(1320, self.m_FootObj.position, self.m_FootObj.rotation) -- foot
    self.m_CollisonHandler:setAlpha(0)
    self.m_CollisonHandler:setData("clickable", true, true)
    addEventHandler("WheelOfFortuneClicked", self.m_CollisonHandler, bind(WheelOfFortune.onClicked, self))

    self.m_InUse = false
    WheelOfFortune.Map[self.m_FootObj] = self
end


function WheelOfFortune:onClicked()
    --garbage collection
    if self.m_InUse then
        if not isElement(self.m_InUse) or not  self.m_InUse.isLoggedIn or not self.m_InUse:isLoggedIn() then
            self.m_InUse = false
        end
    end
    --actual functions
    if not self.m_InUse then
        self.m_InUse = client
        self:start(client)
    else
        client:sendWarning(_("Das Glücksrad wird gerade von %s verwendet.", client, self.m_InUse:getName()))
    end
end

function WheelOfFortune:start(player)
    local power = math.random(500, 1000) -- maybe replace it with some kind of power meter like the fishing rod ?
    local x,y,z=getElementPosition(self.m_WheelObj)
    triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "WheelOfFortunePlaySound", resourceRoot, x, y, z, power*10)
    moveObject(self.m_WheelObj, power*10, x, y, z, 0, power, 0, "OutQuad")

    setTimer(function(marker)
        getElementRotation(self.m_WheelObj) --MTA bug, muss bleiben
        local _,ry,_= getElementRotation(self.m_WheelObj)
        if ry+3.3335>=360 then
            ry=ry+3.3335-360
        else
            ry=ry+3.3335
        end
        self:givePrice(player, WheelOfFortune.WinRotations[math.floor((ry)/6.667+1)])
        self.m_InUse = false
    end,power*10+1000,1,marker)
end

function WheelOfFortune:givePrice(player, type)
    player:sendShortMessage(_("Du hast einen Preis vom Typ %s gewonnen.", player, type))
end



WheelOfFortune.WinRotations = {
    [1]="1$",
    [2]="*",
    [3]="2$",
    [4]="10$",
    [5]="1$",
    [6]="2$",
    [7]="1$",
    [8]="5$",
    [9]="1$",
    [10]="2$",
    [11]="10$",
    [12]="1$",
    [13]="2$",
    [14]="1$",
    [15]="5$",
    [16]="2$",
    [17]="1$",
    [18]="20$",
    [19]="1$",
    [20]="2$",
    [21]="5$",
    [22]="10$",
    [23]="1$",
    [24]="2$",
    [25]="1$",
    [26]="5$",
    [27]="1$",
    [28]="2$",
    [29]="1$",
    [30]="*",
    [31]="2$",
    [32]="1$",
    [33]="2$",
    [34]="1$",
    [35]="2$",
    [36]="5$",
    [37]="1$",
    [38]="2$",
    [39]="1$",
    [40]="5$",
    [41]="1$",
    [42]="20$",
    [43]="1$",
    [44]="10$",
    [45]="1$",
    [46]="2$",
    [47]="1$",
    [48]="5$",
    [49]="1$",
    [50]="2$",
    [51]="1$",
    [52]="5$",
    [53]="1$",
    [54]="2$",
}