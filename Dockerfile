FROM openresty/openresty:alpine-fat

RUN opm get \
      knyar/nginx-lua-prometheus \
      SkyLothar/lua-resty-jwt \
      ledgetech/lua-resty-http

RUN luarocks install lua-resty-cookie
