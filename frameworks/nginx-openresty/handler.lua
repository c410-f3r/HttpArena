local cjson = require "cjson"

local _M = {}

local json_resp = ""
local large_resp = ""
local static_files = {}

function _M.init()
    local mime = {
        css = "text/css", js = "application/javascript", html = "text/html",
        woff2 = "font/woff2", svg = "image/svg+xml", webp = "image/webp",
        json = "application/json",
    }

    -- Load small dataset
    local f = io.open(os.getenv("DATASET_PATH") or "/data/dataset.json", "r")
    if f then
        local data = cjson.decode(f:read("*a"))
        f:close()
        for _, item in ipairs(data) do
            item.total = math.floor(item.price * item.quantity * 100 + 0.5) / 100
        end
        json_resp = cjson.encode({items = data, count = #data})
    end

    -- Load large dataset
    f = io.open("/data/dataset-large.json", "r")
    if f then
        local data = cjson.decode(f:read("*a"))
        f:close()
        for _, item in ipairs(data) do
            item.total = math.floor(item.price * item.quantity * 100 + 0.5) / 100
        end
        large_resp = cjson.encode({items = data, count = #data})
    end

    -- Load static files
    local handle = io.popen("ls /data/static 2>/dev/null")
    if handle then
        for name in handle:lines() do
            local file = io.open("/data/static/" .. name, "rb")
            if file then
                local ext = name:match("%.(%w+)$")
                static_files[name] = {
                    data = file:read("*a"),
                    ct = mime[ext] or "application/octet-stream",
                }
                file:close()
            end
        end
        handle:close()
    end
end

local function sum_args()
    local args = ngx.req.get_uri_args()
    local sum = 0
    for _, v in pairs(args) do
        if type(v) == "table" then
            for _, val in ipairs(v) do
                sum = sum + (tonumber(val) or 0)
            end
        else
            sum = sum + (tonumber(v) or 0)
        end
    end
    return sum
end

function _M.pipeline()
    ngx.header["Content-Type"] = "text/plain"
    ngx.print("ok")
end

function _M.baseline11()
    local sum = sum_args()
    if ngx.req.get_method() == "POST" then
        ngx.req.read_body()
        local body = ngx.req.get_body_data()
        if body then
            sum = sum + (tonumber(body) or 0)
        end
    end
    ngx.header["Content-Type"] = "text/plain"
    ngx.print(string.format("%d", sum))
end

function _M.baseline2()
    ngx.header["Content-Type"] = "text/plain"
    ngx.print(string.format("%d", sum_args()))
end

function _M.json()
    if json_resp == "" then
        ngx.status = 500
        ngx.print("dataset not loaded")
        return
    end
    ngx.header["Content-Type"] = "application/json"
    ngx.print(json_resp)
end

function _M.compression()
    if large_resp == "" then
        ngx.status = 500
        ngx.print("dataset not loaded")
        return
    end
    ngx.header["Content-Type"] = "application/json"
    ngx.print(large_resp)
end

function _M.upload()
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    if not body then
        local fname = ngx.req.get_body_file()
        if fname then
            local f = io.open(fname, "rb")
            if f then
                body = f:read("*a")
                f:close()
            end
        end
    end
    if not body then
        ngx.status = 400
        ngx.print("no body")
        return
    end
    ngx.header["Content-Type"] = "text/plain"
    ngx.print(string.format("%08x", ngx.crc32_long(body)))
end

function _M.static_file()
    local name = ngx.var.uri:match("/static/(.+)")
    if not name then
        ngx.status = 404
        ngx.print("not found")
        return
    end
    local sf = static_files[name]
    if not sf then
        ngx.status = 404
        ngx.print("not found")
        return
    end
    ngx.header["Content-Type"] = sf.ct
    ngx.print(sf.data)
end

return _M
