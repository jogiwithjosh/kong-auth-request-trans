-- local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.kong-auth-request.access"

local AuthRequestHandler = {
  VERSION  = "1.0.0",
  PRIORITY = 900,
}

function AuthRequestHandler:init_worker()
  kong.log.notice("kong-auth-request init")
end

-- local AuthRequestHandler = BasePlugin:extend()

-- AuthRequestHandler.PRIORITY = 900

-- function AuthRequestHandler:new()
--   AuthRequestHandler.super.new(self, "kong-auth-request")
-- end

function AuthRequestHandler:access(conf)
  kong.log.notice("kong-auth-request access")
  -- AuthRequestHandler.super.access(self)
  access.execute(conf)
end

return AuthRequestHandler