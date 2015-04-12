UtilsTest = inherit(UnitTest)

function UtilsTest:test_table_compare()
    self:assertTrue(table.compare({1}, {1}))
    self:assertTrue(table.compare({1, 2, 3, 4, 5, 6}, {1, 2, 3, 4, 5, 6}))
    self:assertFalse(table.compare({1, 2, 3}, {1, 3, 2}))
    self:assertFalse(table.compare({1, 2, 3}, {1, 2, 3, 4}))
    self:assertTrue(table.compare({1, 2, 3, {}}, {1, 2, 3, {}}))
    self:assertTrue(table.compare({1, 2, 3, {{{{1}}}}}, {1, 2, 3, {{{{1}}}}}))
    self:assertTrue(table.compare({key1 = 2, key2 = 3}, {key1 = 2, key2 = 3}))
    self:assertTrue(table.compare({key1 = 2, key2 = 3, key3 = {key5 = 6}}, {key2 = 3, key1 = 2, key3 = {key5 = 6}}))
    self:assertFalse(table.compare({key1 = 2, key2 = 3, key3 = {{key5 = 6}}}, {key2 = 3, key1 = 2, key3 = {key5 = 6}}))
end

function UtilsTest:test_getPlayersInRange()
    local players = {
        {position = Vector3(10, 0, 0)},
        {position = Vector3(5, 0, 0)},
        {position = Vector3(15, 0, 0)}
    }
    self:assertTrue(#getPlayersInRange(Vector3(0, 0, 0), 10, players) == 2)
end

function UtilsTest:test_getAnglePosition()
    -- Signature: getAnglePosition(x, y, z, rx, ry, rz, distance, angle, height)
    self:assertTableEquals({getAnglePosition(0, 0, 0, 0, 0, 0, 1, 0, 0)}, {0, 1, 0})
    self:assertTableEquals({getAnglePosition(0, 0, 0, 0, 0, 0, 1, 90, 0)}, {1, 0, 0})
    self:assertTableEquals({getAnglePosition(0, 0, 0, 0, 0, 0, 1, 180, 0)}, {0, -1, 0})
end

function UtilsTest:test_fromcolor()
    self:assertTableEquals({fromcolor(-256)}, {255, 255, 0, 255})
    self:assertTableEquals({fromcolor(-1)}, {255, 255, 255, 255})
    self:assertTableEquals({fromcolor(-16777216)}, {0, 0, 0, 255})
end
