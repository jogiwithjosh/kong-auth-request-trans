local http = require "resty.http"
-- local cjson = require "cjson.safe"

local ngx = ngx
local ngx_var = ngx.var

local _M = {}

function _M.execute(conf)
    local ok, err
    local scheme, host, port, _ = unpack(http:parse_uri(conf.auth_uri))

    local client = http.new()
    client:set_timeout(conf.timeout)
    client:connect(host, port)
    if scheme == "https" then
        local ok, err = client:ssl_handshake()
        if not ok then
            kong.log.err(err)
            return kong.response.exit(500, { message = "An unexpected error occurred" })
        end
    end

    local auth_request = _M.new_auth_request(conf.origin_request_headers_to_forward_to_auth, conf.keepalive_timeout)

    local res, err = client:request_uri(conf.auth_uri, auth_request)

    if not res then
        kong.log.err(err)
        return kong.response.exit(500, { message = "An unexpected error occurred" })
    end

    if res.status > 299 then
        return kong.response.exit(res.status, res.body)
    end

    kong.log.info("request was successful")
    kong.log.info("conf.auth_response_headers_to_forward: ", conf.auth_response_headers_to_forward)
    for _, name in ipairs(conf.auth_response_headers_to_forward) do
        kong.log.info("conf.auth_response_headers_to_forward: ", name)
    end
    kong.log.info("res headers: ", res.headers)
    for _, name in ipairs(res.headers) do
        kong.log.info("res headers: ", name)
    end
    for _, name in ipairs(conf.auth_response_headers_to_forward) do
        if res.headers[name] then
            kong.service.request.set_header(name, res.headers[name])
        end
    end
end

function _M.new_auth_request(origin_request_headers_to_forward_to_auth, keepalive_timeout)
    -- may have been changed by the request transformer plugin
    local upstream_uri = ngx_var.upstream_uri or kong.request.get_path()

    local headers = {
        charset = "utf-8",
        ["content-type"] = "application/json",
        ["x-original-method"] = kong.request.get_method(),
        ["x-raw-original-url"] = kong.request.get_path(),
        ["x-original-url"] = upstream_uri
    }
    for _, name in ipairs(origin_request_headers_to_forward_to_auth) do
        local header_val = kong.request.get_header(name)
        if header_val then
            headers[name] = header_val
        end
    end
    return {
        method = "GET",
        headers = headers,
        body = "",
        keepalive_timeout = keepalive_timeout
    }
end

return _M
