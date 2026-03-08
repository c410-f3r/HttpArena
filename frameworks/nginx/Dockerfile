FROM debian:bookworm AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libssl-dev libpcre2-dev zlib1g-dev wget ca-certificates

# Download nginx source
WORKDIR /tmp
ARG NGINX_VERSION=1.26.2
RUN wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar xzf nginx-${NGINX_VERSION}.tar.gz

# Download cJSON for JSON parsing
RUN wget -q -O /tmp/cJSON.c https://raw.githubusercontent.com/DaveGamble/cJSON/v1.7.18/cJSON.c && \
    wget -q -O /tmp/cJSON.h https://raw.githubusercontent.com/DaveGamble/cJSON/v1.7.18/cJSON.h

# Copy module
COPY ngx_http_httparena_module.c config /tmp/module/
RUN cp /tmp/cJSON.c /tmp/cJSON.h /tmp/module/

# Build nginx with custom module
WORKDIR /tmp/nginx-${NGINX_VERSION}
RUN ./configure \
    --with-http_ssl_module \
    --with-http_v2_module \
    --add-module=/tmp/module \
    --with-cc-opt="-O3 -march=native -flto -DNDEBUG" \
    --with-ld-opt="-flto -lm" && \
    make -j$(nproc)

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 libpcre2-8-0 && \
    rm -rf /var/lib/apt/lists/*
COPY --from=build /tmp/nginx-1.26.2/objs/nginx /usr/sbin/nginx
RUN mkdir -p /usr/local/nginx/logs
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
EXPOSE 8080 8443
CMD ["nginx", "-g", "daemon off;"]
