local json = require("dkjson")
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


local function write_json_file(file_path, content)
  local file, err = io.open(file_path, "w")  
  if not file then
    return nil, "Could not open file: " .. err  
  end

  file:write(content)  
  file:close()  

  return true
end

-- parsing json content
local function parse_json(content)
  local data, pos, err = json.decode(content, 1, nil)  -- decode json file
  if err then
    return nil, "Error parsing JSON: " .. err  -- if any error happends return error
  end

  return data
end


local function encode_json(data)
  local content, err = json.encode(data, { indent = true })  
  if err then
    return nil, "Error encoding JSON: " .. err  
  end

  return content
end


local function set_item(self)
  local id = tonumber(self.params.id)  
  local new_item = {
    id = id,
    title = self.params.title,
    author = self.params.author,
    publisher = self.params.publisher,
    year = tonumber(self.params.year),
    isbn = self.params.isbn
  }

  local content, err = read_json_file("./DB/db.json")  -- finds json file
  if not content then
    return { status = 500, json = { error = err } }  -- if any error happends return error
  end

  local data, err = parse_json(content)  -- parsing json file content
  if not data then
    return { status = 500, json = { error = err } }  -- if any error happends return error
  end

  if not data.items then
    data.items = {}  -- if any items which is inside the json file, is not exists
  end

  table.insert(data.items, new_item)  

  local new_content, err = encode_json(data)  
  if not new_content then
    return { status = 500, json = { error = err } }  
  end

  local success, err = write_json_file("./DB/db.json", new_content)  
  if not success then
    return { status = 500, json = { error = err } }  
  end

  return { json = { success = true, item = new_item } }  
end

return set_item  -- export function
