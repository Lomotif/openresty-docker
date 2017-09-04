-- init_by_lua_block for auto_ssl
-- Ref: https://github.com/GUI/lua-resty-auto-ssl

-- Helper functions
local function split(str,pat)
  local tbl={}
  str:gsub(pat,function(x) tbl[x]=true end)
  return tbl
end

-- Define a function to determine which SNI domains to automatically handle
-- and register new certificates for. Defaults to not allowing any domains,
-- so this must be configured.
-- Set the environment variable AUTO_SSL_DOMAINS with a comma-separated list
-- of domains to automatically register, eg
--
--   AUTO_SSL_DOMAINS=test1.example.com,test2.example.com
--

-- local staging = true
local production = string.lower(os.getenv('AUTO_SSL_PROD_CA') or '')
-- local staging = string.lower(os.getenv('AUTO_SSL_STAGING_CA'))
production = (production == '1' or production == 'true')

local domains = split(os.getenv('AUTO_SSL_DOMAINS'), '[^,]*')
auto_ssl = (require "resty.auto-ssl").new()
auto_ssl:set("allow_domain", function(domain)
  return (domains[domain] ~= nil)  -- Return true if domain[domain] is not nil, ie. domain exists in table
end)
auto_ssl:set("dir", "/etc/nginx/letsencrypt")

-- Use the LetsEncrypt production CA only if the environment variable AUTO_SSL_PROD_CA
-- is a tru-ish value, eg. "1", or "true"
if production then
  ngx.log(ngx.STDERR, "Using PRODUCTION LetsEncrypt CA")
else
  ngx.log(ngx.STDERR, "Using STAGING LetsEncrypt CA")
  auto_ssl:set("ca", "https://acme-staging.api.letsencrypt.org/directory")
end

auto_ssl:init()

return auto_ssl
