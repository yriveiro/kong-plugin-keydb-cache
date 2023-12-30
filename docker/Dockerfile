FROM kong:3.5.0

USER root

COPY --chmod=755 . /tmp/kong-plugin-remote-cache

WORKDIR /tmp/kong-plugin-remote-cache
RUN <<EOF
  luarocks make
  rm -fr /tmp/*
  rm -fr ~/.cache/luarocks
EOF

WORKDIR /
USER kong
