local typedefs = require "kong.db.schema.typedefs"

return {
  name = "xml-json-transformer",
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
          {
            ignore_content_type = {
              type = "boolean",
              required = false,
              default = false,
            },
          },
          -- Describe your plugin's configuration's schema here.        
        },
      },
    },
  },
  entity_checks = {
    -- Describe your plugin's entity validation rules
  },
}