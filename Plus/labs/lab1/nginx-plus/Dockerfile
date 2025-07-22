# Use the multi-stage build to add necessary dynamic modules from F5 NGINX private registry (Optional)
FROM private-registry.nginx.com/nginx-plus/modules:r34-prometheus-debian AS prometheus-base
# FROM private-registry.nginx.com/nginx-plus/modules:r34-headers_more-debian as headers_more-base
# FROM private-registry.nginx.com/nginx-plus/modules:r34-otel-debian as otel-base

# Use the NGINX base image from F5 NGINX private registry 
FROM private-registry.nginx.com/nginx-plus/base:r34-debian-bookworm

# Use this section to COPY the dynamic modules to the base image (Optional)
COPY --from=prometheus-base / /
# COPY --from=headers_more-base / /
# COPY --from=otel-base / /

# Use this section to  install additional tools/packages
RUN apt-get update && apt-get install -y curl wget procps net-tools vim tree openssl jq