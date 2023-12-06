local plugin_name = "xml-json-transformer"
local cjson = require "cjson"
local lxptable = require "lxp.totable"
local table = require "table"
local tinsert, tremove = table.insert, table.remove
local assert, tostring, type = assert, tostring, type

local xml_json_transformer = {VERSION = "0.1.0", PRIORITY = 990}

local function starttag(p, tag, attr)
    local stack = p:getcallbacks().stack
    local newelement = {tag = tag, attr = attr}
    tinsert(stack, newelement)
end

local function endtag(p, tag)
    local stack = p:getcallbacks().stack
    local element = tremove(stack)

    local level = #stack
    tinsert(stack[level], element)
end

local function text(p, txt)
    local stack = p:getcallbacks().stack
    local element = stack[#stack]
    local n = #element
    if type(element[n]) == "string" and n > 0 then
        element[n] = element[n] .. txt
    else
        tinsert(element, txt)
    end
end

local function parse(o, opts)
    local opts = opts or {}
    local c = {
        StartElement = starttag,
        EndElement = endtag,
        CharacterData = text,
        _nonstrict = true,
        stack = {{}}
    }

    local p = require("lxp").new(c, opts.separator)
    local status, err, line, col, pos = p:parse(o)
    if not status then return nil, err, line, col, pos end

    local status, err, line, col, pos = p:parse() -- close document
    if not status then return nil, err, line, col, pos end
    p:close()
    return c.stack[1][1]
end

function xml_json_transformer:header_filter(conf)
    ngx.header["content-type"] = "application/json"
    ngx.header["content-length"] = nil
end

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

        local ok, data = pcall(parse, resp_body)

        if not ok then
            ngx.log(ngx.ERR, "parse error: malformed xml")
            ngx.arg[1] = resp_body
            ngx.arg[2] = true
        else
            data = lxptable.clean(data)
            local json_text = cjson.encode(data)
            ngx.arg[1] = json_text
            ngx.arg[2] = true
        end
    end

end

return xml_json_transformer

