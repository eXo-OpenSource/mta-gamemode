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
