local lapis = require("lapis")
local app = lapis.Application()
local json = require("dkjson")
local etlua = require("etlua")
local io = require("io")


local function read_json_file(file_path)
  local file, err = io.open(file_path, "r")
  if not file then
    return nil, "Could not open file: " .. err
  end

  local content = file:read("*a")
  file:close()

  return content
end


local function parse_json(content)
  local data, pos, err = json.decode(content, 1, nil)
  if err then
    return nil, "Error parsing JSON: " .. err
  end

  return data
end


app:match("/get/:id", function(self)
  local id = tonumber(self.params.id)
  local content, err = read_json_file("./DB/db.json")
  if not content then
    return { status = 500, json = { error = err } }
  end

  local data, err = parse_json(content)
  if not data then
    return { status = 500, json = { error = err } }
  end

  if not data.items then
    return { status = 500, json = { error = "Invalid JSON structure: missing 'items' key" } }
  end


  local item = nil
  for _, i in ipairs(data.items) do
    if i.id == id then
      item = i
      break
    end
  end

  if not item then
    return { status = 404, json = { error = "Item not found" } }
  end


  local template_path = "./views/index.etlua"
  local template_file, err = io.open(template_path, "r")
  if not template_file then
    return { status = 500, json = { error = "Could not open template file: " .. err } }
  end

  local template = template_file:read("*a")
  template_file:close()

  local render = etlua.compile(template)
  local html = render({ item = item })

  return html
end)

return app
