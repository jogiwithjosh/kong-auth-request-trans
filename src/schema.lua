local typedefs = require "kong.db.schema.typedefs"

return {
  name = "kong-auth-request-trans",
  fields = {
    {
      -- this plugin will only be applied to Services or Routes
      consumer = typedefs.no_consumer
    },
    {
      -- this plugin will only run within Nginx HTTP module
      protocols = typedefs.protocols_http
    },
    {
      config = {
        type = "record",
        fields = {
            {timeout = { default = 10000, type = "number" }},
            {keepalive_timeout = { default = 60000, type = "number" }},
            {auth_uri = { required = true, type = "string" }},
            {origin_request_headers_to_forward_to_auth = { type = "array", elements = {type = "string"}, default = {} }},
            {auth_response_headers_to_forward = { type = "array", elements = {type = "string"}, default = {} }}
        
        },
      },
    },
  },
  entity_checks = {
    -- Describe your plugin's entity validation rules
  },
}
