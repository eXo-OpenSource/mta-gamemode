GroupTest = inherit(UnitTest)

function GroupTest:init()
    self.m_Group = Group.create("TestGroup")
end

function GroupTest:destructor()
    self:assertTrue(self.m_Group:purge())
end

function GroupTest:test_createGroup()
    self:assertTrue(self.m_Group ~= nil)
    self:assertEquals(type(self.m_Group:getId()), "number")
    self:assertEquals(self.m_Group:getName(), "TestGroup")
end

function GroupTest:test_players()
    self.m_Group:addPlayer(1, 2)
    self:assertTrue(self.m_Group:isPlayerMember(1))
    self:assertTableEquals(self.m_Group:getPlayers(true), {[1] = 2})

    self:assertEquals(self.m_Group:getPlayerRank(1), 2)
    self.m_Group:setPlayerRank(1, 1)
    self:assertEquals(self.m_Group:getPlayerRank(1), 1)

    self.m_Group:removePlayer(1)
    self:assertFalse(self.m_Group:isPlayerMember(1))
end

function GroupTest:test_money()
    self:assertEquals(self.m_Group:getMoney(), 0)
    self.m_Group:setMoney(100)
    self:assertEquals(self.m_Group:getMoney(), 100)
end
