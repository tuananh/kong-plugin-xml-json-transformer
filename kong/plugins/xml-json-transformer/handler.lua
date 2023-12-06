local plugin_name = "xml-json-transformer"
local cjson = require "cjson"
local table_concat = table.concat
local xml2lua = require("xml2lua")
local handler = require("xmlhandler.tree")
local parser = xml2lua.parser(handler)

local xml_json_transformer = {VERSION = "0.1.0", PRIORITY = 990}

function xml_json_transformer:header_filter(conf)
    ngx.header["content-type"] = "application/json"
    ngx.header["content-length"] = nil
end

---[[ runs in the 'access_by_lua_block'
function xml_json_transformer:body_filter(config)
    local chunk, eof = ngx.arg[1], ngx.arg[2]

    if ngx.ctx.buffered == nil then ngx.ctx.buffered = {} end

    if chunk ~= "" and not ngx.is_subrequest then
        table.insert(ngx.ctx.buffered, chunk)
        ngx.arg[1] = nil
    end

    if eof then
        local resp_body = table.concat(ngx.ctx.buffered)
        ngx.ctx.buffered = nil

        local result, errors = pcall(function(resp_body)
            parser:parse(resp_body)
        end, resp_body)

        if not result then
            ngx.log(ngx.ERR, "parse error: malformed xml")
            ngx.arg[1] = resp_body
            ngx.arg[2] = true
        else
            local xml = handler.root
            local json_text = cjson.encode(xml)
            ngx.arg[1] = json_text
            ngx.arg[2] = true
        end
    end

end

return xml_json_transformer

