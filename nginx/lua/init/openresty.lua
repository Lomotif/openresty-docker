-- Init module for our OpenResty image

-- Set up Prometheus logging

local _M = {}

prometheus = require("prometheus").init("prometheus_metrics")
_M.metric_requests = prometheus:counter(
  "nginx_http_requests_total", "Number of HTTP requests", {"host", "status"})
_M.metric_latency = prometheus:histogram(
  "nginx_http_request_duration_seconds", "HTTP request latency", {"host"})
_M.metric_connections = prometheus:gauge(
  "nginx_http_connections", "Number of HTTP connections", {"state"})
_M.metric_response_sizes = prometheus:histogram(
  "nginx_http_response_size_bytes", "Size of HTTP responses", {"host"},
  {10,100,1000,10000,100000,1000000}
)

return _M
