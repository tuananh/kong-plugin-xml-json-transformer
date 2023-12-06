local plugin_name = "xml-json-transformer"
local cjson = require "cjson"
local table_concat = table.concat
local xml2lua = require("xml2lua")
local handler = require("xmlhandler.tree")
local parser = xml2lua.parser(handler)

local xml_json_transformer = {
  VERSION  = "0.1.0",
  PRIORITY = 990,
}

function xml_json_transformer:header_filter(conf)
  ngx.header["content-type"] = "application/json"
  ngx.header["content-length"] = nil
end

---[[ runs in the 'access_by_lua_block'
function xml_json_transformer:body_filter(config)
  local ctx = ngx.ctx 
  local response_body =''

  local resp_body = string.sub(ngx.arg[1], 1, 1000)  
    ctx.buffered = string.sub((ctx.buffered or "") .. resp_body, 1, 1000)
    -- arg[2] is true if this is the last chunk
    if ngx.arg[2] then
      response_body = ctx.buffered
    end
  parser:parse(resp_body)

  local xml = handler.root
  json_text = cjson.encode(xml)
  ngx.arg[1] = json_text
  ngx.arg[2] = true

end 

return xml_json_transformer

