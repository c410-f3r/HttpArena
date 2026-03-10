FROM openresty/openresty:alpine

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY handler.lua /usr/local/openresty/lualib/handler.lua

EXPOSE 8080 8443

CMD ["openresty", "-g", "daemon off;"]
