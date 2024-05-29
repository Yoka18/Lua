local lapis = require("lapis")
local app = lapis.Application()

-- Include GET and SET
local get_item = require("handlers.get")
local set_item = require("handlers.set")

-- Define GET and SET
app:match("/get/:id", get_item)  -- GET route
app:post("/set/:id", set_item)  -- SET route

return app
