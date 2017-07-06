{
    meta = {
        date = "2017-07-05",
        author = "MegaThorx"
    },
    up = function()
        DbSchema:create("test", function(table)
            table:increments("id")
            table:string("name")
            table:string("password")
        end)
    end,

    down = function()
        DbSchema:drop("test")
    end
}