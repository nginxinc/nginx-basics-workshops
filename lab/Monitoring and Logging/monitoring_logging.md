# Monitoring and Logging​

## Intro

The [NGINX Plus API](https://www.nginx.com/products/nginx/live-activity-monitoring/) supports other features in addition to live activity monitoring, including dynamic configuration of upstream server groups (replacing the separate Upstream Conf module originally used for that purpose) and key‑value stores. The NGINX Plus dashboard was updated to use the API in NGINX Plus R14.

Live examples:​
 * A [sample configuration](https://gist.github.com/nginx-gists/a51341a11ff1cf4e94ac359b67f1c4ae) file for the NGINX Plus API
 * Example live dashboard: [demo.nginx.com](https://demo.nginx.com)
 * Raw JSON output: [demo.nginx.com/api​](https://demo.nginx.com/api)
 * Swagger-UI: [demo.nginx.com/swagger-ui](https://demo.nginx.com/swagger-ui/)
 * API YAML: [demo.nginx.com/swagger-ui](https://demo.nginx.com/swagger-ui/nginx_api.yaml)

## Task 1: Explore the Live Activity Monitoring JSON Feed​ from demo.nginx.com

When you access the API, NGINX Plus returns a JSON‑formatted document containing the current statistics. You can request complete statistics at `/api/[api-version]/`, where `[api-version]` is the version number of the NGINX Plus API. 

Lets look at the Live Activity Monitoring JSON Feed​ in detail. Drill down to obtain subsets of the data or single data points, at specific API endpoints, and Parse JSON data using `jq` and `curl` from command line:

1. `/api/api-version/nginx/` – Basic version, uptime, and identification information​

```bash
curl -s https://demo.nginx.com/api/6/nginx/ | jq 

{
  "version": "1.19.0",
  "build": "nginx-plus-r22",V
  "address": "206.251.255.64",
  "generation": 42,
  "load_timestamp": "2020-06-23T10:00:01.090Z",
  "timestamp": "2020-06-23T17:32:39.399Z",
  "pid": 5079,
  "ppid": 61031
}
```

2. `/api/api-version/connections/` – Total active and idle connections​

```bash
curl -s https://demo.nginx.com/api/6/connections/ | jq 
{
  "accepted": 25011760,
  "dropped": 0,
  "active": 1,
  "idle": 60
}
```

3. `/api/api-version/http/server_zones/` – Request and response counts for each HTTP status zone​

```bash
curl -s https://demo.nginx.com/api/6/http/server_zones/ | jq

{
  "hg.nginx.org": {
    "processing": 0,
    "requests": 0,
    "responses": {
      "1xx": 0,
      "2xx": 0,
      "3xx": 0,
      "4xx": 0,
      "5xx": 0,
      "total": 0
    },
    "discarded": 0,
    "received": 0,
    "sent": 0
  },
  "trac.nginx.org": {
    "processing": 0,
    "requests": 0,
    "responses": {
      "1xx": 0,
      "2xx": 0,
      "3xx": 0,
      "4xx": 0,
      "5xx": 0,
      "total": 0
    },
    "discarded": 0,
    "received": 0,
    "sent": 0
  },
  "lxr.nginx.org": {
    "processing": 0,
    "requests": 2635,
    "responses": {
      "1xx": 0,
      "2xx": 2505,
      "3xx": 17,
      "4xx": 76,
      "5xx": 37,
      "total": 2635
    },
    "discarded": 0,
    "received": 856154,
    "sent": 62626264
  }
}
# Trimmed
```

4. `/api/api-version/http/caches/` – Instrumentation for each named cache zone

```bash
curl -s https://demo.nginx.com/api/6/http/caches/ | jq

{
  "http_cache": {
    "size": 0,
    "max_size": 536870912,
    "cold": false,
    "hit": {
      "responses": 0,
      "bytes": 0
    },
    "stale": {
      "responses": 0,
      "bytes": 0
    },
    "updating": {
      "responses": 0,
      "bytes": 0
    },
    "revalidated": {
      "responses": 0,
      "bytes": 0
    },
    "miss": {
      "responses": 0,
      "bytes": 0,
      "responses_written": 0,
      "bytes_written": 0
    },
    "expired": {
      "responses": 0,
      "bytes": 0,
      "responses_written": 0,
      "bytes_written": 0
    },
    "bypass": {
      "responses": 0,
      "bytes": 0,
      "responses_written": 0,
      "bytes_written": 0
    }
  }
}
```

5. `/api/api-version/stream/upstreams/` – Request and response counts, response time, health‑check status, and uptime statistics per server in each TCP/UDP upstream group

```bash
curl -s https://demo.nginx.com/api/6/stream/upstreams/ | jq


{                                                                                                                                                           
  "postgresql_backends": {                                                                                                                                  
    "peers": [                                                                                                                                              
      {                                                                                                                                                     
        "id": 0,                                                                                                                                            
        "server": "10.0.0.2:15432",                                                                                                                         
        "name": "10.0.0.2:15432",                                                                                                                           
        "backup": false,                                                                                                                                    
        "weight": 1,                                                                                                                                        
        "state": "up",                                                                                                                                      
        "active": 0,                                                                                                                                        
        "max_conns": 42,                                                                                                                                    
        "connections": 9250,                                                                                                                                
        "connect_time": 1,                                                                                                                                  
        "first_byte_time": 1,                                                                                                                               
        "response_time": 1,                                                                                                                                 
        "sent": 952750,                                                                                                                                     
        "received": 1850000,                                                                                                                                
        "fails": 0,                                                                                                                                         
        "unavail": 0,                                                                                                                                       
        "health_checks": {                                                                                                                                  
          "checks": 5564,                                                                                                                                   
          "fails": 0,                                                                                                                                       
          "unhealthy": 0,                                                                                                                                   
          "last_passed": true                                                                                                                               
        },                                                                                                                                                  
        "downtime": 0,                                                                                                                                      
        "selected": "2020-06-23T17:43:55Z"                                                                                                                  
      },                                                                                                                                                    
      {                                                                                                                                                     
        "id": 1,                                                                                                                                            
        "server": "10.0.0.2:15433",                                                                                                                         
        "name": "10.0.0.2:15433",                                                                                                                           
        "backup": false,                                                                                                                                    
        "weight": 1,                                                                                                                                        
        "state": "up",                                                                                                                                      
        "active": 0,                                                                                                                                        
        "connections": 9250,       
        # etc..

```

6. `/api/api-version/ssl/` – SSL/TLS statistics

```bash
curl -s https://demo.nginx.com/api/6/ssl/ | jq

{
  "handshakes": 784975,
  "handshakes_failed": 70687,
  "session_reuses": 122210
}

```

## Task 2
