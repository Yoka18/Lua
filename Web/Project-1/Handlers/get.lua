local json = require("dkjson")
local etlua = require("etlua")
local io = require("io")

-- read json file
local function read_json_file(file_path)
  local file, err = io.open(file_path, "r")  -- Open the file as read mode
  if not file then
    return nil, "Could not open file: " .. err  -- if not opened return error
  end

  local content = file:read("*a")  -- read inside the file
  file:close()  -- close file

  return content
end

-- parsing json content
local function parse_json(content)
  local data, pos, err = json.decode(content, 1, nil)  -- decode json file
  if err then
    return nil, "Error parsing JSON: " .. err  -- if any error happends return error
  end

  return data
end

-- get item which is specified id
local function get_item(self)
  local id = tonumber(self.params.id)  -- get id from url
  local content, err = read_json_file("./DB/db.json")  -- read json file
  if not content then
    return { status = 500, json = { error = err } }  -- if any error happends return error
  end

  local data, err = parse_json(content)  -- parsing json content
  if not data then
    return { status = 500, json = { error = err } }  -- returns if there is a parsing error
  end

  if not data.items then
    return { status = 500, json = { error = "Invalid JSON structure: missing 'items' key" } }
  end

  -- find item which is specified id
  local item = nil
  for _, i in ipairs(data.items) do
    if i.id == id then
      item = i
      break
    end
  end

  if not item then
    return { status = 404, json = { error = "Item not found" } }  -- if could not find item returns error
  end

  -- render and load html template
  local template_path = "./views/index.etlua"
  local template_file, err = io.open(template_path, "r")
  if not template_file then
    return { status = 500, json = { error = "Could not open template file: " .. err } }
  end

  local template = template_file:read("*a")
  template_file:close()

  local render = etlua.compile(template)
  local html = render({ item = item })  -- render html content

  return html  -- returns html content
end

return get_item  -- export function
