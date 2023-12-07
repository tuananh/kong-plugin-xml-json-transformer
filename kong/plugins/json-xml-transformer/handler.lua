local plugin_name = "json-xml-transformer"
local cjson = require "cjson"
local table_concat = table.concat
local xml2lua = require("xml2lua")

local json_xml_transformer = {VERSION = "0.1.0", PRIORITY = 990}

function json_xml_transformer:header_filter(conf)
    ngx.header["content-type"] = "application/xml"
    ngx.header["content-length"] = nil
end

function json_xml_transformer:body_filter(config)
    local chunk, eof = ngx.arg[1], ngx.arg[2]

    if ngx.ctx.buffered == nil then ngx.ctx.buffered = {} end

    if chunk ~= "" and not ngx.is_subrequest then
        table.insert(ngx.ctx.buffered, chunk)
        ngx.arg[1] = nil
    end

    if eof then
        local resp_body = table.concat(ngx.ctx.buffered)
        ngx.ctx.buffered = nil

        local ok, data = pcall(cjson.decode, resp_body)

        if not ok then
            ngx.log(ngx.ERR, "parse error: malformed json")
            ngx.arg[1] = resp_body
            ngx.arg[2] = true
        else
            local xml = xml2lua.toXml(data)
            ngx.arg[1] = xml
            ngx.arg[2] = true
        end
    end

end

return json_xml_transformer

